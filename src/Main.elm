module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events
import Color
import Direction2d
import Duration exposing (Duration)
import Element exposing (Element)
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html exposing (Html)
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import List.Nonempty
import Math.Vector3 as Vec3
import Math.Vector4 as Vec4
import Mesh exposing (Mesh, SurfacePoint)
import MeshBuilder exposing (Vertex)
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Pixels exposing (Pixels)
import Point2d
import Point3d
import Quantity exposing (Quantity)
import Vector2d
import Vector2i exposing (Vector2i)
import View
import WebGL



---- MODEL ----


type alias SuccessModel_ =
    { keys : List Key
    , previousKeys : List Key
    , windowSize : Vector2i Pixels ScreenCoordinate
    , surfacePoint : SurfacePoint Meters
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
            ( SuccessModel
                { keys = []
                , previousKeys = []
                , windowSize = Vector2i.pixels flags.windowWidth flags.windowHeight
                , surfacePoint =
                    Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.2 1) mesh
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
                        Just { end } ->
                            end

                        Nothing ->
                            model.surfacePoint

                Nothing ->
                    model.surfacePoint
    }


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
    View.view model


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
