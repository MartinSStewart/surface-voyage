module Main exposing (Model, Msg(..), init, subscriptions, update, view)

import Angle
import Axis2d
import Axis3d exposing (Axis3d)
import Axis3dEx as Axis3d
import Browser.Dom
import Browser.Events
import Camera3d
import Direction2d exposing (Direction2d)
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import Element exposing (Element)
import Element.Border
import Environment
import GameLogic
import Html exposing (Html)
import Html.Events
import Html.Events.Extra.Mouse
import Html.Events.Extra.Touch
import Json.Decode
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import LineSegment3d
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Minimap
import MinimapPort
import ObjData
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Point3d
import Point3dEx as Point3d
import Quantity exposing (Quantity)
import Rectangle2d exposing (Rectangle2d)
import Rectangle2dEx as Rectangle2d
import SketchPlane3d
import Surface exposing (Surface, SurfacePoint)
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
    , surface : Surface WorldCoordinate
    , surfacePoint : SurfacePoint

    -- What the minimap shows and where it was laid out from, and where it's being laid out from now
    , minimap : Maybe { point : SurfacePoint, meshes : Minimap.Meshes }
    , minimapRequest : Maybe SurfacePoint
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


initLoadedModel : Vector2i Pixels ScreenCoordinate -> Texture -> Model
initLoadedModel windowSize texture =
    case MeshData.surface of
        Ok surface ->
            case
                Surface.nearestSurfacePoint (Point3d.meters 1.688355538015691 0.598373 -1.4172405276507476) surface
                    |> Maybe.map (Surface.pointTowards (Point3d.meters 1.6587441968454457 0.598373 -1.0518184469830478) surface)
            of
                Just surfacePoint ->
                    { keys = []
                    , previousKeys = []
                    , mouseLastDown = Nothing
                    , mousePosition = Nothing
                    , mouseLastUp = Nothing
                    , moveAction = Nothing
                    , windowSize = windowSize
                    , surface = surface
                    , surfacePoint = surfacePoint
                    , minimap = Nothing
                    , minimapRequest = Nothing
                    , cameraNormal = cameraNormal surface surfacePoint |> Maybe.withDefault Direction3d.z
                    , cameraUp = cameraUp surface surfacePoint |> Maybe.withDefault Direction3d.y
                    , time = Quantity.zero
                    , assetId = ObjData.assetId
                    , texture = texture
                    }
                        |> LoadedModel

                Nothing ->
                    FailureModel { message = "The world has no surface to stand on" }

        Err error ->
            FailureModel { message = Surface.errorToString error }


init : ( Model, Cmd Msg )
init =
    ( { windowSize = Vector2i.pixels 0 0
      }
        |> LoadingModel
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform
                (\{ viewport } -> Vector2i.pixels (round viewport.width) (round viewport.height) |> GotWindowSize)
        , Texture.loadWith
            { magnify = Texture.nearest
            , minify = Texture.linear
            , horizontalWrap = Texture.clampToEdge
            , verticalWrap = Texture.clampToEdge
            , flipY = True
            }
            "/world.png"
            |> Task.attempt TextureLoaded
        ]
        |> Cmd.map LoadingMsg
    )



---- UPDATE ----


type LoadingMsg_
    = GotWindowSize (Vector2i Pixels ScreenCoordinate)
    | TextureLoaded (Result Texture.Error Texture)


type LoadedMsg_
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize (Vector2i Pixels ScreenCoordinate)
    | AnimationFrameDelta Duration
    | MouseEvent MouseEvent_
    | MinimapDrawn Json.Decode.Value


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
            { model | time = Quantity.plus model.time delta } |> step |> stepMinimap

        MinimapDrawn value ->
            ( case
                Json.Decode.decodeValue
                    (Json.Decode.map2 (\point meshes -> { point = point, meshes = meshes })
                        (Json.Decode.field "point" Surface.surfacePointDecoder)
                        (Json.Decode.field "drawing" Minimap.meshesDecoder)
                    )
                    value
              of
                Ok minimap ->
                    { model | minimap = Just minimap, minimapRequest = Nothing }

                Err _ ->
                    { model | minimapRequest = Nothing }
            , Cmd.none
            )

        MouseEvent event ->
            case event.eventType of
                MouseEventDown ->
                    { model
                        | mouseLastDown = Just { position = event.position, time = model.time }
                        , moveAction =
                            let
                                endPoint =
                                    View.cameraRay model event.position |> Axis3d.intersectionWithSketchPlane (View.cameraSketchPlane model)
                            in
                            case endPoint of
                                Just end ->
                                    let
                                        endTime =
                                            Point2d.distanceFrom Point2d.origin end |> Quantity.at_ GameLogic.playerSpeed

                                        direction =
                                            Direction2d.from Point2d.origin end |> Maybe.withDefault Direction2d.y
                                    in
                                    Just { direction = direction |> Direction2d.mirrorAcross Axis2d.x, endTime = Quantity.plus model.time endTime }

                                Nothing ->
                                    Nothing
                    }
                        |> addCmdNone

                MouseEventMove ->
                    { model | mousePosition = Just event.position } |> addCmdNone

                MouseEventUp ->
                    { model | mouseLastUp = Just { position = event.position, time = model.time } } |> addCmdNone


updateLoadingModel : LoadingMsg_ -> LoadingModel_ -> ( Model, Cmd LoadingMsg_ )
updateLoadingModel msg model =
    case msg of
        GotWindowSize windowSize ->
            ( LoadingModel { model | windowSize = windowSize }, Cmd.none )

        TextureLoaded result ->
            case result of
                Ok texture ->
                    ( initLoadedModel model.windowSize texture, Cmd.none )

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
                        Surface.move
                            model.surface
                            (Direction2d.angleFrom Direction2d.y direction)
                            (GameLogic.playerSpeed |> Quantity.for frameDuration)
                            model.surfacePoint
                    of
                        Just path ->
                            Surface.pathEnd path

                        Nothing ->
                            model.surfacePoint

                Nothing ->
                    case model.moveAction of
                        Just { direction, endTime } ->
                            if endTime |> Quantity.greaterThan model.time then
                                case
                                    Surface.move
                                        model.surface
                                        (Direction2d.angleFrom Direction2d.y direction)
                                        (GameLogic.playerSpeed |> Quantity.for frameDuration)
                                        model.surfacePoint
                                of
                                    Just path ->
                                        Surface.pathEnd path

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


{-| Laying out the minimap takes a while, so a web worker does it (see `MinimapWorker`), one layout at
a time. A new one is asked for once the player has moved far enough from where the last one was laid
out from for it to show. In between, the minimap is moved and turned to keep up (see `minimapView`).
-}
stepMinimap : LoadedModel_ -> ( LoadedModel_, Cmd LoadedMsg_ )
stepMinimap model =
    let
        movedFar =
            case model.minimap of
                Just minimap ->
                    Maybe.map2 Point3d.distanceFrom
                        (Surface.worldPosition model.surfacePoint model.surface)
                        (Surface.worldPosition minimap.point model.surface)
                        |> Maybe.map (Quantity.greaterThan (Length.centimeters 2))
                        |> Maybe.withDefault True

                Nothing ->
                    True
    in
    if model.minimapRequest == Nothing && movedFar then
        ( { model | minimapRequest = Just model.surfacePoint }
        , Surface.encodeSurfacePoint model.surfacePoint |> MinimapPort.drawMinimap
        )

    else
        ( model, Cmd.none )


{-| Where the player is now on the minimap last laid out, and how far they have turned since. This is
close enough for the few centimeters the player moves before the next layout comes.
-}
minimapView : LoadedModel_ -> Html msg
minimapView model =
    let
        unmoved =
            { offset = { x = 0, y = 0 }, turn = 0 }

        moved =
            case model.minimap of
                Just minimap ->
                    Maybe.map5
                        (\p0 f0 n0 p f ->
                            let
                                forward =
                                    Direction3d.unwrap f0

                                up =
                                    Direction3d.unwrap n0

                                -- forward x up
                                right =
                                    { x = forward.y * up.z - forward.z * up.y
                                    , y = forward.z * up.x - forward.x * up.z
                                    , z = forward.x * up.y - forward.y * up.x
                                    }

                                d =
                                    Vector3d.from p0 p |> Vector3d.unwrap

                                dot u v =
                                    u.x * v.x + u.y * v.y + u.z * v.z

                                facing =
                                    Direction3d.unwrap f
                            in
                            { offset = { x = dot d right, y = dot d forward }
                            , turn = atan2 -(dot facing right) (dot facing forward)
                            }
                        )
                        (Surface.worldPosition minimap.point model.surface)
                        (Surface.worldDirection model.surface minimap.point)
                        (Surface.normal model.surface minimap.point)
                        (Surface.worldPosition model.surfacePoint model.surface)
                        (Surface.worldDirection model.surface model.surfacePoint)
                        |> Maybe.withDefault unmoved

                Nothing ->
                    unmoved
    in
    Minimap.view (Maybe.map .meshes model.minimap) moved


stepCamera model =
    { model
        | cameraNormal =
            case cameraNormal model.surface model.surfacePoint of
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
            case cameraUp model.surface model.surfacePoint of
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


cameraUp : Surface WorldCoordinate -> SurfacePoint -> Maybe (Direction3d WorldCoordinate)
cameraUp surface surfacePoint =
    Surface.worldDirection surface surfacePoint


cameraNormal : Surface WorldCoordinate -> SurfacePoint -> Maybe (Direction3d WorldCoordinate)
cameraNormal surface surfacePoint =
    let
        a angleOffset =
            case Surface.move surface angleOffset (Length.meters 0.3) surfacePoint of
                Just path ->
                    Surface.pathSegments path
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
                viewSuccessModel model_ |> Element.map LoadedMsg

            FailureModel model_ ->
                Element.text model_.message

            LoadingModel _ ->
                Element.none


viewSuccessModel : LoadedModel_ -> Element LoadedMsg_
viewSuccessModel model =
    Element.el
        [ Element.htmlAttribute <| Html.Events.Extra.Touch.onStart touchHandler
        , Element.inFront <|
            Element.column [ Element.spacing 6, Element.padding 4 ]
                [ Element.text "Move with arrow keys or mouse click"
                , if Environment.isDebug then
                    Surface.worldPosition model.surfacePoint model.surface
                        |> Maybe.map Point3d.pointToString
                        |> Maybe.withDefault ""
                        |> Element.text

                  else
                    Element.none
                ]
        , Element.inFront <|
            Element.el
                [ Element.alignRight
                , Element.alignTop
                , Element.moveLeft 12
                , Element.moveDown 12
                , Element.width (Element.px (Pixels.inPixels Minimap.size))
                , Element.height (Element.px (Pixels.inPixels Minimap.size))
                , Element.Border.rounded (Pixels.inPixels Minimap.size)
                , Element.Border.width 3
                , Element.Border.color (Element.rgb 0.95 0.95 0.95)
                , Element.clip
                ]
                (Element.html (minimapView model))
        ]
        (Element.html (View.view model MeshData.webGlMesh))


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


touchHandler : Html.Events.Extra.Touch.Event -> LoadedMsg_
touchHandler event =
    event.touches
        |> List.head
        |> Maybe.map
            (\{ pagePos } ->
                { position = Point2d.pixels (Tuple.first pagePos) (Tuple.second pagePos)
                , eventType = MouseEventDown
                }
                    |> MouseEvent
            )
        |> Maybe.withDefault NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        LoadedModel _ ->
            Sub.batch
                [ Sub.map KeyMsg Keyboard.subscriptions
                , Browser.Events.onMouseDown (mouseDecoder MouseEventDown)
                , Browser.Events.onMouseUp (mouseDecoder MouseEventUp)
                , Browser.Events.onMouseMove (mouseDecoder MouseEventMove)
                , Browser.Events.onMouseDown (mouseDecoder MouseEventDown)
                , Browser.Events.onMouseMove (mouseDecoder MouseEventMove)
                , Browser.Events.onResize (\w h -> Vector2i.pixels w h |> WindowResize)
                , Browser.Events.onAnimationFrameDelta (Duration.milliseconds >> AnimationFrameDelta)
                , MinimapPort.minimapDrawn MinimapDrawn
                ]
                |> Sub.map LoadedMsg

        LoadingModel _ ->
            Sub.none

        FailureModel _ ->
            Sub.none
