module Main exposing (Model, Msg(..), init, subscriptions, update, view)

import Angle
import Axis3d exposing (Axis3d)
import Axis3dEx as Axis3d
import Browser.Dom
import Browser.Events
import Buildings
import Camera3d
import Direction2d exposing (Direction2d)
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Environment
import File exposing (File)
import File.Select
import GameLogic
import Html exposing (Html)
import Html.Events
import Html.Events.Extra.Mouse
import Html.Events.Extra.Touch
import Json.Decode
import Json.Encode
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import LineSegment3d
import MeshBuilder
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Minimap
import MinimapPort
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Point3d
import Point3dEx as Point3d
import Quantity exposing (Quantity)
import Rectangle2d exposing (Rectangle2d)
import Rectangle2dEx as Rectangle2d
import ShortestPath
import SketchPlane3d
import StepImport
import Surface exposing (Surface, SurfacePoint)
import Task
import Vector2d exposing (Vector2d)
import Vector2i exposing (Vector2i)
import Vector3d
import View
import Viewpoint3d
import WallCollision
import WebGL
import WorldMesh



---- MODEL ----


type alias LoadedModel_ =
    { keys : List Key
    , previousKeys : List Key
    , mouseLastDown : Maybe { position : Point2d Pixels ScreenCoordinate, time : Duration }
    , mouseLastUp : Maybe { position : Point2d Pixels ScreenCoordinate, time : Duration }
    , mousePosition : Maybe (Point2d Pixels ScreenCoordinate)
    , moveAction : Maybe { direction : Direction2d ScreenCoordinate, endTime : Duration }

    -- Where the mouse was last while the middle button is held to turn the camera
    , cameraDrag : Maybe (Point2d Pixels ScreenCoordinate)

    -- How far the camera is tilted from looking straight down on the player, in radians
    , cameraPitch : Float
    , windowSize : Vector2i Pixels ScreenCoordinate
    , surface : Surface WorldCoordinate
    , surfacePoint : SurfacePoint

    -- How high the player is above the surface: up stairs or on a roof (see `Buildings`)
    , height : Float

    -- What the minimap shows and where it was laid out from, and where it's being laid out from now
    , minimap : Maybe { point : SurfacePoint, meshes : Minimap.Meshes }
    , minimapRequest : Maybe SurfacePoint
    , cameraNormal : Direction3d WorldCoordinate
    , cameraUp : Direction3d WorldCoordinate
    , time : Duration

    -- Walls the player has placed, oldest first, how many of them the minimap has been sent, and how
    -- they're drawn
    , placedWalls : List (List ( Float, Float, Float ))
    , placedWallsSent : Int
    , placedWallMesh : WebGL.Mesh WorldMesh.WallVertex

    -- All the walls that stop the player, placed ones included
    , wallCollision : WallCollision.Walls
    , wallPlacing : Maybe WallPlacing

    -- The world being played in: the one made in code, or one imported from a STEP file
    , level : Level

    -- What the scale field for importing says, and what went wrong importing last, if anything
    , importScale : String
    , importError : Maybe String

    -- How many minimap drawings still to come are of the world before the last import
    , staleMinimaps : Int
    }


{-| How a world is drawn, and whether it has the buildings (roofs and stairs, see `Buildings`) in it.
-}
type alias Level =
    { world : WebGL.Mesh MeshBuilder.Vertex
    , walls : WebGL.Mesh WorldMesh.WallVertex
    , roofs : WebGL.Mesh WorldMesh.WallVertex
    , buildings : Bool
    }


defaultLevel : Level
defaultLevel =
    { world = MeshData.webGlMesh
    , walls = MeshData.wallMesh
    , roofs = MeshData.roofMesh
    , buildings = True
    }


{-| A wall the player is placing (pressing W starts one where they stand, Enter finishes it where they
are, Escape stops). It's the shortest path along the surface between those two points, shown in light
gray until it's finished.
-}
type alias WallPlacing =
    { start : SurfacePoint
    , path : Maybe ShortestPath.Path
    , mesh : WebGL.Mesh WorldMesh.WallVertex

    -- Where the player was when the path was last found, and when it was last searched for all
    -- round rather than followed from the one before (see `ShortestPath.follow`)
    , foundFor : Maybe (Point3d.Point3d Meters WorldCoordinate)
    , searchedFor : Maybe (Point3d.Point3d Meters WorldCoordinate)
    }


type Model
    = LoadingModel LoadingModel_
    | LoadedModel LoadedModel_
    | FailureModel FailureModel_


type alias LoadingModel_ =
    { windowSize : Vector2i Pixels ScreenCoordinate }


type alias FailureModel_ =
    { message : String }


initLoadedModel : Vector2i Pixels ScreenCoordinate -> Model
initLoadedModel windowSize =
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
                    , cameraDrag = Nothing
                    , cameraPitch = 0
                    , windowSize = windowSize
                    , surface = surface
                    , surfacePoint = surfacePoint
                    , height = 0
                    , minimap = Nothing
                    , minimapRequest = Nothing
                    , cameraNormal = cameraNormal surface surfacePoint |> Maybe.withDefault Direction3d.z
                    , cameraUp = cameraUp surface surfacePoint |> Maybe.withDefault Direction3d.y
                    , time = Quantity.zero
                    , placedWalls = []
                    , placedWallsSent = 0
                    , placedWallMesh = WebGL.triangles []
                    , wallCollision = MeshData.wallCollision
                    , wallPlacing = Nothing
                    , level = defaultLevel
                    , importScale = "1"
                    , importError = Nothing
                    , staleMinimaps = 0
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
    , Browser.Dom.getViewport
        |> Task.perform
            (\{ viewport } -> Vector2i.pixels (round viewport.width) (round viewport.height) |> GotWindowSize)
        |> Cmd.map LoadingMsg
    )



---- UPDATE ----


type LoadingMsg_
    = GotWindowSize (Vector2i Pixels ScreenCoordinate)


type LoadedMsg_
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize (Vector2i Pixels ScreenCoordinate)
    | AnimationFrameDelta Duration
    | MouseEvent MouseEvent_
    | MinimapDrawn Json.Decode.Value
    | ImportPressed
    | ImportFileSelected File
    | ImportFileLoaded String
    | ImportScaleChanged String


type MouseEventType
    = MouseEventDown
    | MouseEventMove
    | MouseEventUp


type alias MouseEvent_ =
    { position : Point2d Pixels ScreenCoordinate
    , eventType : MouseEventType
    , button : Html.Events.Extra.Mouse.Button
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

        MinimapDrawn _ ->
            if model.staleMinimaps > 0 then
                ( { model | staleMinimaps = model.staleMinimaps - 1 }, Cmd.none )

            else
                minimapDrawn msg model

        ImportPressed ->
            ( model, File.Select.file [ ".step", ".stp", ".STEP", ".STP" ] ImportFileSelected )

        ImportFileSelected file ->
            ( model, File.toString file |> Task.perform ImportFileLoaded )

        ImportFileLoaded text ->
            importLevel text model

        ImportScaleChanged text ->
            { model | importScale = text } |> addCmdNone

        MouseEvent event ->
            mouseEvent event model


minimapDrawn : LoadedMsg_ -> LoadedModel_ -> ( LoadedModel_, Cmd LoadedMsg_ )
minimapDrawn msg model =
    case msg of
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

        _ ->
            ( model, Cmd.none )


{-| Replace the world with the solid in a STEP file (see `StepImport`), with the player on top of it.
Nothing that was made for the world in code comes with it: no paths, walls or buildings. The minimap
worker is sent the file too, so that it lays out the same surface.
-}
importLevel : String -> LoadedModel_ -> ( LoadedModel_, Cmd LoadedMsg_ )
importLevel text model =
    let
        scale =
            String.toFloat model.importScale |> Maybe.withDefault 1
    in
    case
        StepImport.surface scale text
            |> Result.andThen
                (\surface ->
                    startOn surface
                        |> Result.fromMaybe "There's nowhere on the surface to stand"
                        |> Result.map (Tuple.pair surface)
                )
    of
        Ok ( surface, surfacePoint ) ->
            ( { model
                | surface = surface
                , surfacePoint = surfacePoint
                , height = 0
                , level =
                    { world = WorldMesh.mesh surface []
                    , walls = WebGL.triangles []
                    , roofs = WebGL.triangles []
                    , buildings = False
                    }
                , importError = Nothing
                , moveAction = Nothing
                , minimap = Nothing
                , minimapRequest = Nothing
                , staleMinimaps =
                    if model.minimapRequest == Nothing then
                        model.staleMinimaps

                    else
                        model.staleMinimaps + 1
                , cameraNormal = cameraNormal surface surfacePoint |> Maybe.withDefault Direction3d.y
                , cameraUp = cameraUp surface surfacePoint |> Maybe.withDefault Direction3d.z
                , placedWalls = []
                , placedWallsSent = 0
                , placedWallMesh = WebGL.triangles []
                , wallCollision = WallCollision.none
                , wallPlacing = Nothing
              }
            , Json.Encode.object [ ( "step", Json.Encode.string text ), ( "scale", Json.Encode.float scale ) ]
                |> MinimapPort.drawMinimap
            )

        Err message ->
            ( { model | importError = Just message }, Cmd.none )


{-| The middle of the top of a surface (the side up in the CAD program), facing away from the front
-}
startOn : Surface WorldCoordinate -> Maybe SurfacePoint
startOn surface =
    let
        positions =
            Surface.tessellate (pi / 12) surface
                |> List.concatMap (\( a, b, c ) -> [ a.position, b.position, c.position ])

        range get =
            ( List.map get positions |> List.minimum, List.map get positions |> List.maximum )
    in
    case ( range .x, range .y, range .z ) of
        ( ( Just minX, Just maxX ), ( Just _, Just maxY ), ( Just minZ, Just maxZ ) ) ->
            let
                x =
                    (minX + maxX) / 2

                z =
                    (minZ + maxZ) / 2
            in
            Surface.nearestSurfacePoint (Point3d.meters x (maxY + 1) z) surface
                |> Maybe.map (Surface.pointTowards (Point3d.meters x maxY (z - 1)) surface)

        _ ->
            Nothing


mouseEvent : MouseEvent_ -> LoadedModel_ -> ( LoadedModel_, Cmd LoadedMsg_ )
mouseEvent event model =
    case ( event.eventType, event.button ) of
        ( MouseEventDown, Html.Events.Extra.Mouse.MainButton ) ->
            { model
                | mouseLastDown = Just { position = event.position, time = model.time }
                , moveAction =
                    let
                        ray =
                            View.cameraRay model event.position

                        endPoint =
                            ray
                                |> Axis3d.intersectionWithSketchPlane (View.cameraSketchPlane model)
                                -- Clicking above the horizon would otherwise walk the other way
                                |> Maybe.andThen
                                    (\end ->
                                        if Point3d.signedDistanceAlong ray (Point3d.on (View.cameraSketchPlane model) end) |> Quantity.greaterThan Quantity.zero then
                                            Just end

                                        else
                                            Nothing
                                    )
                    in
                    case endPoint of
                        Just end ->
                            let
                                endTime =
                                    Point2d.distanceFrom Point2d.origin end |> Quantity.at_ GameLogic.playerSpeed

                                direction =
                                    Direction2d.from Point2d.origin end |> Maybe.withDefault Direction2d.y
                            in
                            Just { direction = direction, endTime = Quantity.plus model.time endTime }

                        Nothing ->
                            Nothing
            }
                |> addCmdNone

        ( MouseEventDown, Html.Events.Extra.Mouse.MiddleButton ) ->
            { model | cameraDrag = Just event.position } |> addCmdNone

        ( MouseEventDown, _ ) ->
            model |> addCmdNone

        ( MouseEventMove, _ ) ->
            { model | mousePosition = Just event.position } |> dragCamera event.position |> addCmdNone

        ( MouseEventUp, Html.Events.Extra.Mouse.MiddleButton ) ->
            { model | cameraDrag = Nothing } |> addCmdNone

        ( MouseEventUp, _ ) ->
            { model | mouseLastUp = Just { position = event.position, time = model.time } } |> addCmdNone


{-| Dragging with the middle button held turns the camera around the player: sideways turns the player
(so the arrow keys and the minimap turn with the camera), up tilts the camera from looking straight
down on the player towards looking ahead, and down tilts it back.
-}
dragCamera : Point2d Pixels ScreenCoordinate -> LoadedModel_ -> LoadedModel_
dragCamera position model =
    case model.cameraDrag of
        Just previous ->
            let
                { x, y } =
                    Vector2d.from previous position |> Vector2d.toPixels
            in
            { model
                | cameraDrag = Just position
                , surfacePoint = Surface.rotateBy (Angle.radians (-x * cameraDragSpeed)) model.surfacePoint
                , cameraPitch = clamp 0 maxCameraPitch (model.cameraPitch - y * cameraDragSpeed)
            }

        Nothing ->
            model


{-| How far the camera turns per pixel dragged, in radians
-}
cameraDragSpeed : Float
cameraDragSpeed =
    0.006


{-| How far the camera can tilt from looking straight down, in radians (75 degrees)
-}
maxCameraPitch : Float
maxCameraPitch =
    1.3


updateLoadingModel : LoadingMsg_ -> LoadingModel_ -> ( Model, Cmd LoadingMsg_ )
updateLoadingModel msg model =
    case msg of
        GotWindowSize windowSize ->
            ( initLoadedModel windowSize, Cmd.none )


keyMsgUpdate keyMsg model =
    let
        newKeys =
            Keyboard.update keyMsg model.keys
    in
    { model | keys = newKeys, previousKeys = model.keys }
        |> placeWalls
        |> addCmdNone


placeWalls : LoadedModel_ -> LoadedModel_
placeWalls model =
    if Keyboard.isPressed model Keyboard.Escape then
        { model | wallPlacing = Nothing }

    else if Keyboard.isPressed model Keyboard.Enter then
        case model.wallPlacing of
            Just placing ->
                -- Searched for again, in case the path followed isn't the shortest any more
                case
                    Surface.worldPosition model.surfacePoint model.surface
                        |> Maybe.andThen (\position -> ShortestPath.between model.surface placing.start position placing.path)
                of
                    Just path ->
                        let
                            placedWalls =
                                model.placedWalls ++ [ path.points ]
                        in
                        { model
                            | wallPlacing = Nothing
                            , placedWalls = placedWalls
                            , placedWallMesh = WorldMesh.placedWallMesh model.surface { preview = False } placedWalls
                            , wallCollision = WallCollision.add model.surface [ path.points ] model.wallCollision
                        }

                    Nothing ->
                        { model | wallPlacing = Nothing }

            Nothing ->
                model

    else if Keyboard.isPressed model (Keyboard.Character "W") && not (isPlacingWall model) then
        { model
            | wallPlacing =
                Just
                    { start = model.surfacePoint
                    , path = Nothing
                    , mesh = WebGL.triangles []
                    , foundFor = Nothing
                    , searchedFor = Nothing
                    }
        }

    else
        model


isPlacingWall : LoadedModel_ -> Bool
isPlacingWall model =
    case model.wallPlacing of
        Just _ ->
            True

        Nothing ->
            False


{-| Keep the wall being placed going from where it started to where the player is.
-}
stepWallPlacing : LoadedModel_ -> LoadedModel_
stepWallPlacing model =
    case ( model.wallPlacing, Surface.worldPosition model.surfacePoint model.surface ) of
        ( Just placing, Just position ) ->
            if placing.foundFor == Just position then
                model

            else
                let
                    searchAgain =
                        case ( placing.path, placing.searchedFor ) of
                            ( Just _, Just lastSearch ) ->
                                Point3d.distanceFrom lastSearch position |> Quantity.greaterThan searchEvery

                            _ ->
                                True

                    followed =
                        if searchAgain then
                            Nothing

                        else
                            placing.path |> Maybe.andThen (ShortestPath.follow model.surface placing.start position)

                    ( path, searchedFor ) =
                        case followed of
                            Just _ ->
                                ( followed, placing.searchedFor )

                            Nothing ->
                                ( ShortestPath.between model.surface placing.start position placing.path, Just position )
                in
                { model
                    | wallPlacing =
                        Just
                            { placing
                                | path = path
                                , mesh =
                                    WorldMesh.placedWallMesh model.surface
                                        { preview = True }
                                        (Maybe.map (.points >> List.singleton) path |> Maybe.withDefault [])
                                , foundFor = Just position
                                , searchedFor = searchedFor
                            }
                }

        _ ->
            model


{-| How far the player moves between looking all round for the shortest path for the wall they're
placing. In between, the path found last is followed, which is quicker, but stays the same side of
the hole even if the other side gets shorter.
-}
searchEvery : Length.Length
searchEvery =
    Length.centimeters 15


step : LoadedModel_ -> LoadedModel_
step model =
    model
        |> stepMovement
        |> stepHeight
        |> stepCamera
        |> stepWallPlacing


frameDuration =
    Duration.seconds (1 / 60)


stepMovement model =
    let
        movement =
            Keyboard.arrowDown model |> Vector2d.direction

        walk direction =
            let
                angle =
                    Direction2d.angleFrom Direction2d.y direction

                distance =
                    GameLogic.playerSpeed |> Quantity.for frameDuration
            in
            if model.height < WallCollision.blocksBelow then
                WallCollision.move model.surface model.wallCollision angle distance model.surfacePoint

            else
                Surface.move model.surface angle distance model.surfacePoint
                    |> Maybe.map Surface.pathEnd
                    |> Maybe.withDefault model.surfacePoint
    in
    { model
        | surfacePoint =
            case movement of
                Just direction ->
                    walk direction

                Nothing ->
                    case model.moveAction of
                        Just { direction, endTime } ->
                            if endTime |> Quantity.greaterThan model.time then
                                walk direction

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

        placedWallsUnsent =
            List.length model.placedWalls > model.placedWallsSent
    in
    if model.minimapRequest == Nothing && (movedFar || placedWallsUnsent) then
        ( { model | minimapRequest = Just model.surfacePoint, placedWallsSent = List.length model.placedWalls }
        , Json.Encode.object
            (( "point", Surface.encodeSurfacePoint model.surfacePoint )
                :: (if placedWallsUnsent then
                        [ ( "placedWalls"
                          , Json.Encode.list
                                (Json.Encode.list (\( x, y, z ) -> Json.Encode.list Json.Encode.float [ x, y, z ]))
                                (List.drop model.placedWallsSent model.placedWalls)
                          )
                        ]

                    else
                        []
                   )
            )
            |> MinimapPort.drawMinimap
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


stepHeight : LoadedModel_ -> LoadedModel_
stepHeight model =
    case Surface.worldPosition model.surfacePoint model.surface of
        Just position ->
            if not model.level.buildings then
                model

            else
                { model | height = Buildings.heightAfter (Duration.inSeconds frameDuration) model.height (Point3d.toMeters position) }

        Nothing ->
            model


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

        -- Stops the browser scrolling or pasting on a middle click, as that turns the camera
        , Element.htmlAttribute <|
            Html.Events.preventDefaultOn "mousedown"
                (Json.Decode.field "button" Json.Decode.int |> Json.Decode.map (\button -> ( NoOp, button == 1 )))
        , Element.inFront <|
            Element.column [ Element.spacing 6, Element.padding 4 ]
                [ Element.text "Move with arrow keys or mouse click. Hold the middle mouse button and drag to turn the camera"
                , Element.text
                    (case model.wallPlacing of
                        Just _ ->
                            "Move to where the wall should end and press Enter, or Escape to cancel"

                        Nothing ->
                            "Press W to start a wall where you're standing"
                    )
                , importControls model
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
        (Element.html
            (View.view model
                { world = model.level.world
                , walls = model.level.walls :: model.placedWallMesh :: (Maybe.map (.mesh >> List.singleton) model.wallPlacing |> Maybe.withDefault [])
                , roofs = model.level.roofs
                , player = WorldMesh.playerMesh
                }
            )
        )


{-| A button to import a world from a STEP file, how much to scale it by, and what went wrong importing
it last. Mouse presses on them don't walk the player there.
-}
importControls : LoadedModel_ -> Element LoadedMsg_
importControls model =
    Element.column
        [ Element.spacing 4
        , Element.htmlAttribute <| Html.Events.stopPropagationOn "mousedown" (Json.Decode.succeed ( NoOp, True ))
        ]
        [ Element.row [ Element.spacing 8 ]
            [ Element.Input.button
                [ Element.Background.color (Element.rgb 0.95 0.95 0.95)
                , Element.Border.rounded 4
                , Element.Border.width 1
                , Element.Border.color (Element.rgb 0.6 0.6 0.6)
                , Element.paddingXY 8 4
                ]
                { onPress = Just ImportPressed, label = Element.text "Import STEP file" }
            , Element.Input.text
                [ Element.width (Element.px 70), Element.paddingXY 6 4 ]
                { onChange = ImportScaleChanged
                , text = model.importScale
                , placeholder = Nothing
                , label = Element.Input.labelLeft [ Element.centerY ] (Element.text "Scale")
                }
            ]
        , case model.importError of
            Just message ->
                Element.paragraph [ Element.Font.color (Element.rgb 0.75 0 0), Element.width (Element.maximum 600 Element.fill) ] [ Element.text message ]

            Nothing ->
                Element.none
        ]


mouseDecoder : MouseEventType -> Json.Decode.Decoder LoadedMsg_
mouseDecoder eventType =
    Json.Decode.map
        (\{ pagePos, button } ->
            MouseEvent
                { position = Point2d.pixels (Tuple.first pagePos) (Tuple.second pagePos)
                , eventType = eventType
                , button = button
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
                , button = Html.Events.Extra.Mouse.MainButton
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
