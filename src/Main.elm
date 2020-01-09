module Main exposing (Model, Msg(..), init, main, update, view)

import Angle
import Browser
import Browser.Events
import Direction2d
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import Element exposing (Element)
import Html exposing (Html)
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import LineSegment3d
import MeshBuilder exposing (Vertex)
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Pixels exposing (Pixels)
import Point2d
import Point3d
import Quantity exposing (Quantity)
import SurfaceMesh.Mesh as Mesh exposing (Mesh)
import SurfaceMesh.Path as Path
import SurfaceMesh.SurfacePoint as SurfacePoint exposing (SurfacePoint)
import Vector2d
import Vector2i exposing (Vector2i)
import Vector3d
import View
import WebGL



---- MODEL ----


type alias SuccessModel_ =
    { keys : List Key
    , previousKeys : List Key
    , windowSize : Vector2i Pixels ScreenCoordinate
    , surfacePoint : SurfacePoint Meters
    , cameraNormal : Direction3d WorldCoordinate
    , cameraUp : Direction3d WorldCoordinate
    , time : Duration
    , mesh : Mesh Meters WorldCoordinate
    , webGlMesh : WebGL.Mesh Vertex
    }


type Model
    = SuccessModel SuccessModel_
    | FailureModel FailureModel_


type alias FailureModel_ =
    { message : String }


type alias Flags =
    { windowWidth : Int
    , windowHeight : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    case MeshData.surfaceCube of
        Ok mesh ->
            let
                surfacePoint =
                    Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.2 1) mesh
            in
            ( SuccessModel
                { keys = []
                , previousKeys = []
                , windowSize = Vector2i.pixels flags.windowWidth flags.windowHeight
                , surfacePoint = surfacePoint
                , cameraNormal = cameraNormal mesh surfacePoint |> Maybe.withDefault Direction3d.z
                , cameraUp = cameraUp mesh surfacePoint |> Maybe.withDefault Direction3d.y
                , time = Quantity.zero
                , mesh = mesh
                , webGlMesh = MeshData.renderCube
                }
            , Cmd.none
            )

        Err _ ->
            ( FailureModel { message = "" }
            , Cmd.none
            )



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize (Vector2i Pixels ScreenCoordinate)
    | AnimationFrameDelta Duration


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        SuccessModel model_ ->
            updateSuccessModel msg model_ |> Tuple.mapFirst SuccessModel

        FailureModel _ ->
            ( model, Cmd.none )


updateSuccessModel : Msg -> SuccessModel_ -> ( SuccessModel_, Cmd Msg )
updateSuccessModel msg model =
    case msg of
        NoOp ->
            model |> addCmdNone

        KeyMsg keyMsg ->
            keyMsgUpdate keyMsg model

        WindowResize windowSize ->
            { model | windowSize = windowSize } |> addCmdNone

        AnimationFrameDelta delta ->
            { model | time = Quantity.plus model.time delta } |> step |> addCmdNone


keyMsgUpdate keyMsg model =
    let
        newKeys =
            Keyboard.update keyMsg model.keys
    in
    { model | keys = newKeys, previousKeys = model.keys }
        |> addCmdNone


step : SuccessModel_ -> SuccessModel_
step model =
    { model
        | surfacePoint =
            case Keyboard.arrowDown model |> Vector2d.direction of
                Just direction ->
                    case
                        Mesh.move
                            model.mesh
                            (Direction2d.angleFrom Direction2d.y direction)
                            (Length.meters 0.01)
                            model.surfacePoint
                    of
                        Just path ->
                            Path.endPoint path

                        Nothing ->
                            model.surfacePoint

                Nothing ->
                    model.surfacePoint
        , cameraNormal =
            case cameraNormal model.mesh model.surfacePoint of
                Just newCameraNormal ->
                    if Direction3d.angleFrom newCameraNormal model.cameraNormal |> Quantity.lessThan (Angle.degrees 1) then
                        newCameraNormal

                    else
                        Vector3d.withLength (Length.meters 1) newCameraNormal
                            |> Vector3d.plus (Vector3d.withLength (Length.meters 5) model.cameraNormal)
                            |> Vector3d.direction
                            |> Maybe.withDefault model.cameraNormal

                Nothing ->
                    model.cameraNormal
        , cameraUp =
            case cameraUp model.mesh model.surfacePoint of
                Just newCameraUp ->
                    if Direction3d.angleFrom newCameraUp model.cameraUp |> Quantity.lessThan (Angle.degrees 1) then
                        newCameraUp

                    else
                        Vector3d.withLength (Length.meters 1) newCameraUp
                            |> Vector3d.plus (Vector3d.withLength (Length.meters 5) model.cameraUp)
                            |> Vector3d.direction
                            |> Maybe.withDefault model.cameraUp

                Nothing ->
                    model.cameraUp
    }


cameraUp : Mesh units coordinates -> SurfacePoint units -> Maybe (Direction3d coordinates)
cameraUp mesh surfacePoint =
    SurfacePoint.worldDirection mesh surfacePoint


cameraNormal : Mesh Meters WorldCoordinate -> SurfacePoint Meters -> Maybe (Direction3d WorldCoordinate)
cameraNormal mesh surfacePoint =
    let
        a angleOffset =
            case Mesh.move mesh angleOffset (Length.meters 0.3) surfacePoint of
                Just path ->
                    case Path.edgeNormals mesh path of
                        Just edges ->
                            edges
                                |> List.map
                                    (\( line, normal ) ->
                                        let
                                            length =
                                                LineSegment3d.length line
                                        in
                                        Vector3d.withLength length normal
                                    )

                        Nothing ->
                            []

                Nothing ->
                    []

        detail =
            4

        b =
            List.range 0 (detail - 1)
                |> List.map (\value -> Angle.radians (pi * 2 * toFloat value / detail))
                --[ Angle.radians 0, Angle.radians (pi / 2), Angle.radians pi, Angle.radians (-pi / 2) ]
                |> List.concatMap a
    in
    b |> vectorSum |> Vector3d.direction


vectorSum =
    List.foldl Vector3d.plus Vector3d.zero


addCmdNone : a -> ( a, Cmd msg )
addCmdNone a =
    ( a, Cmd.none )


addCmd : Cmd msg -> a -> ( a, Cmd msg )
addCmd cmd a =
    ( a, cmd )


twoTriangleMesh =
    MeshBuilder.square
        |> MeshBuilder.map
            (\point ->
                Point3d.xyz
                    (Point2d.xCoordinate point)
                    (Point2d.yCoordinate point)
                    Quantity.zero
            )


twoTriangleSurface : Mesh.Mesh Meters coordinates
twoTriangleSurface =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices twoTriangleMesh
    in
    case Mesh.fromVerticesAndIndices verts indices of
        Ok mesh ->
            mesh

        Err error ->
            error |> Debug.toString |> Debug.todo



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [] <|
        case model of
            SuccessModel model_ ->
                viewSuccessModel model_

            FailureModel model_ ->
                Element.text model_.message


viewSuccessModel : SuccessModel_ -> Element Msg
viewSuccessModel model =
    Element.el
        [ Element.inFront <| Element.text "Move with arrow keys" ]
        (View.view model)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Sub.map KeyMsg Keyboard.subscriptions
        , Browser.Events.onResize (\w h -> Vector2i.pixels w h |> WindowResize)
        , Browser.Events.onAnimationFrameDelta (Duration.milliseconds >> AnimationFrameDelta)
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
