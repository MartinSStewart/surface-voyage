module Main exposing (Model, Msg(..), init, main, update, view)

import Angle
import Axis2d
import Axis3d exposing (Axis3d)
import Axis3dEx as Axis3d
import Browser
import Browser.Events
import Camera3d
import Direction2d exposing (Direction2d)
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import Element exposing (Element)
import Environment
import Html exposing (Html)
import Html.Events.Extra.Mouse
import Json.Decode
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import LineSegment3d
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import ObjData
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Point3d
import Point3dEx as Point3d
import Quantity exposing (Quantity)
import Rectangle2d exposing (Rectangle2d)
import SketchPlane3d
import SurfaceMesh.Mesh as Mesh exposing (Mesh)
import SurfaceMesh.Path as Path
import SurfaceMesh.SurfacePoint as SurfacePoint exposing (SurfacePoint)
import Task
import Vector2d exposing (Vector2d)
import Vector2i exposing (Vector2i)
import Vector3d
import View
import Viewpoint3d
import WebGL.Texture as Texture exposing (Texture)



---- MODEL ----


type alias LoadedModel_ =
    { keys : List Key
    , previousKeys : List Key
    , mouseLastDown : Maybe { position : Point2d Pixels ScreenCoordinate, time : Duration }
    , mouseLastUp : Maybe { position : Point2d Pixels ScreenCoordinate, time : Duration }
    , mousePosition : Maybe (Point2d Pixels ScreenCoordinate)
    , moveAction : Maybe { direction : Direction2d ScreenCoordinate, endTime : Duration }
    , windowSize : Vector2i Pixels ScreenCoordinate
    , surfacePoint : SurfacePoint Meters
    , cameraNormal : Direction3d WorldCoordinate
    , cameraUp : Direction3d WorldCoordinate
    , time : Duration
    , assetId : Int
    , texture : Texture
    }


type Model
    = LoadingModel LoadingModel_
    | LoadedModel LoadedModel_
    | FailureModel FailureModel_


type alias LoadingModel_ =
    { windowSize : Vector2i Pixels ScreenCoordinate }


type alias FailureModel_ =
    { message : String }


type alias Flags =
    { windowWidth : Int
    , windowHeight : Int
    }


initLoadedModel : Vector2i Pixels ScreenCoordinate -> Texture -> LoadedModel_
initLoadedModel windowSize texture =
    let
        surfacePoint =
            Mesh.nearestSurfacePoint (Point3d.meters 1.688355538015691 0.598373 -1.4172405276507476) MeshData.surfaceMesh
                |> SurfacePoint.pointTowards (Point3d.meters 1.6587441968454457 0.598373 -1.0518184469830478) MeshData.surfaceMesh
    in
    { keys = []
    , previousKeys = []
    , mouseLastDown = Nothing
    , mousePosition = Nothing
    , mouseLastUp = Nothing
    , moveAction = Nothing
    , windowSize = windowSize
    , surfacePoint = surfacePoint
    , cameraNormal = cameraNormal MeshData.surfaceMesh surfacePoint |> Maybe.withDefault Direction3d.z
    , cameraUp = cameraUp MeshData.surfaceMesh surfacePoint |> Maybe.withDefault Direction3d.y
    , time = Quantity.zero
    , assetId = ObjData.assetId
    , texture = texture
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { windowSize = Vector2i.pixels flags.windowWidth flags.windowHeight
      }
        |> LoadingModel
    , Texture.loadWith
        { magnify = Texture.nearest
        , minify = Texture.linear
        , horizontalWrap = Texture.clampToEdge
        , verticalWrap = Texture.clampToEdge
        , flipY = True
        }
        "./world.png"
        |> Task.attempt TextureLoaded
        |> Cmd.map LoadingMsg
    )



---- UPDATE ----


type LoadingMsg_
    = TextureLoaded (Result Texture.Error Texture)


type LoadedMsg_
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize (Vector2i Pixels ScreenCoordinate)
    | AnimationFrameDelta Duration
    | MouseEvent MouseEvent_


type MouseEventType
    = MouseEventDown
    | MouseEventMove
    | MouseEventUp


type alias MouseEvent_ =
    { position : Point2d Pixels ScreenCoordinate
    , eventType : MouseEventType
    }


type Msg
    = LoadingMsg LoadingMsg_
    | LoadedMsg LoadedMsg_


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( LoadedModel model_, LoadedMsg msg_ ) ->
            updateLoadedModel msg_ model_ |> Tuple.mapBoth LoadedModel (Cmd.map LoadedMsg)

        ( LoadingModel model_, LoadingMsg msg_ ) ->
            updateLoadingModel msg_ model_ |> Tuple.mapSecond (Cmd.map LoadingMsg)

        ( FailureModel _, _ ) ->
            ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


updateLoadedModel : LoadedMsg_ -> LoadedModel_ -> ( LoadedModel_, Cmd LoadedMsg_ )
updateLoadedModel msg model =
    case msg of
        NoOp ->
            model |> addCmdNone

        KeyMsg keyMsg ->
            keyMsgUpdate keyMsg model

        WindowResize windowSize ->
            { model | windowSize = windowSize } |> addCmdNone

        AnimationFrameDelta delta ->
            { model | time = Quantity.plus model.time delta } |> step |> addCmdNone

        MouseEvent event ->
            case event.eventType of
                MouseEventDown ->
                    let
                        centerPoint =
                            Point2d.translateBy (Vector2i.toVector2d model.windowSize |> Vector2d.scaleBy 0.5) Point2d.origin

                        sketchPlane =
                            View.camera model MeshData.surfaceMesh
                                |> Camera3d.viewpoint
                                |> Viewpoint3d.viewPlane
                                |> SketchPlane3d.translateAlongOwn SketchPlane3d.normalAxis (Length.meters -1.15)

                        --Maybe.map2
                        --    SketchPlane3d.withNormalDirection
                        --    (model.surfacePoint |> SurfacePoint.getNormal MeshData.surfaceMesh)
                        --    (SurfacePoint.worldPosition model.surfacePoint MeshData.surfaceMesh)
                    in
                    { model
                        | mouseLastDown = Just { position = event.position, time = model.time }
                        , moveAction =
                            let
                                --startPoint : Maybe (Point2d Meters coordinates2d)
                                startPoint =
                                    Point2d.origin

                                --cameraRay model centerPoint |> Axis3d.intersectionWithSketchPlane sketchPlane_
                                --endPoint : Maybe (Point2d Meters coordinates2d)
                                endPoint =
                                    cameraRay model event.position |> Axis3d.intersectionWithSketchPlane sketchPlane
                            in
                            case ( startPoint, endPoint ) of
                                ( start, Just end ) ->
                                    let
                                        endTime =
                                            Point2d.distanceFrom start end |> Quantity.at_ playerSpeed

                                        direction =
                                            Direction2d.from start end |> Maybe.withDefault Direction2d.y
                                    in
                                    Just { direction = direction |> Direction2d.mirrorAcross Axis2d.x, endTime = Quantity.plus model.time endTime }

                                _ ->
                                    Nothing
                    }
                        |> addCmdNone

                MouseEventMove ->
                    { model | mousePosition = Just event.position } |> addCmdNone

                MouseEventUp ->
                    { model | mouseLastUp = Just { position = event.position, time = model.time } } |> addCmdNone


playerSpeed =
    Length.meters 0.6 |> Quantity.per (Duration.seconds 1)


updateLoadingModel : LoadingMsg_ -> LoadingModel_ -> ( Model, Cmd LoadingMsg_ )
updateLoadingModel msg model =
    case msg of
        TextureLoaded result ->
            case result of
                Ok texture ->
                    ( initLoadedModel model.windowSize texture |> LoadedModel, Cmd.none )

                Err _ ->
                    ( FailureModel { message = "Failed to load texture" }, Cmd.none )


keyMsgUpdate keyMsg model =
    let
        newKeys =
            Keyboard.update keyMsg model.keys
    in
    { model | keys = newKeys, previousKeys = model.keys }
        |> addCmdNone


step : LoadedModel_ -> LoadedModel_
step model =
    model
        |> stepMovement
        |> stepCamera


frameDuration =
    Duration.seconds (1 / 60)


cameraRay : LoadedModel_ -> Point2d Pixels ScreenCoordinate -> Axis3d Meters WorldCoordinate
cameraRay model point =
    let
        screenRect =
            Rectangle2d.from Point2d.origin (Point2d.translateBy (Vector2i.toVector2d model.windowSize) Point2d.origin)
    in
    Camera3d.ray (View.camera model MeshData.surfaceMesh) screenRect point


stepMovement model =
    let
        movement =
            Keyboard.arrowDown model |> Vector2d.direction
    in
    { model
        | surfacePoint =
            case movement of
                Just direction ->
                    case
                        Mesh.move
                            MeshData.surfaceMesh
                            (Direction2d.angleFrom Direction2d.y direction)
                            (playerSpeed |> Quantity.for frameDuration)
                            model.surfacePoint
                    of
                        Just path ->
                            Path.endPoint path

                        Nothing ->
                            model.surfacePoint

                Nothing ->
                    case model.moveAction of
                        Just { direction, endTime } ->
                            if endTime |> Quantity.greaterThan model.time then
                                case
                                    Mesh.move
                                        MeshData.surfaceMesh
                                        (Direction2d.angleFrom Direction2d.y direction)
                                        (playerSpeed |> Quantity.for frameDuration)
                                        model.surfacePoint
                                of
                                    Just path ->
                                        Path.endPoint path

                                    Nothing ->
                                        model.surfacePoint

                            else
                                model.surfacePoint

                        Nothing ->
                            model.surfacePoint
        , moveAction =
            case movement of
                Just _ ->
                    Nothing

                Nothing ->
                    model.moveAction
    }


stepCamera model =
    { model
        | cameraNormal =
            case cameraNormal MeshData.surfaceMesh model.surfacePoint of
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
            case cameraUp MeshData.surfaceMesh model.surfacePoint of
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
    in
    List.range 0 (detail - 1)
        |> List.map (\value -> Angle.radians (pi * 2 * toFloat value / detail))
        |> List.concatMap a
        |> vectorSum
        |> Vector3d.direction


vectorSum =
    List.foldl Vector3d.plus Vector3d.zero


addCmdNone : a -> ( a, Cmd msg )
addCmdNone a =
    ( a, Cmd.none )


addCmd : Cmd msg -> a -> ( a, Cmd msg )
addCmd cmd a =
    ( a, cmd )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [] <|
        case model of
            LoadedModel model_ ->
                viewSuccessModel model_

            FailureModel model_ ->
                Element.text model_.message

            LoadingModel _ ->
                Element.none


viewSuccessModel : LoadedModel_ -> Element Msg
viewSuccessModel model =
    Element.el
        [ Element.inFront <|
            Element.column [ Element.spacing 6, Element.padding 4 ]
                [ Element.text "Move with arrow keys"
                , if Environment.isDebug then
                    SurfacePoint.worldPosition model.surfacePoint MeshData.surfaceMesh
                        |> Maybe.map Point3d.pointToString
                        |> Maybe.withDefault ""
                        |> Element.text

                  else
                    Element.none
                ]
        ]
        (Element.html (View.view model MeshData.webGlMesh MeshData.surfaceMesh))


mouseDecoder : MouseEventType -> Json.Decode.Decoder LoadedMsg_
mouseDecoder eventType =
    Json.Decode.map
        (\{ pagePos } ->
            MouseEvent
                { position = Point2d.pixels (Tuple.first pagePos) (Tuple.second pagePos)
                , eventType = eventType
                }
        )
        Html.Events.Extra.Mouse.eventDecoder


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        LoadedModel _ ->
            Sub.batch
                [ Sub.map KeyMsg Keyboard.subscriptions
                , Browser.Events.onMouseDown (mouseDecoder MouseEventDown)
                , Browser.Events.onMouseUp (mouseDecoder MouseEventUp)
                , Browser.Events.onMouseMove (mouseDecoder MouseEventMove)
                , Browser.Events.onResize (\w h -> Vector2i.pixels w h |> WindowResize)
                , Browser.Events.onAnimationFrameDelta (Duration.milliseconds >> AnimationFrameDelta)
                ]
                |> Sub.map LoadedMsg

        LoadingModel _ ->
            Sub.none

        FailureModel _ ->
            Sub.none



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
