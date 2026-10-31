module Main exposing (Model, Msg(..), init, subscriptions, update, view)

import Angle
import Axis3d exposing (Axis3d)
import Axis3dEx as Axis3d
import Browser.Dom
import Browser.Events
import Buildings exposing (Buildings)
import Camera3d
import Details
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
import File.Download
import File.Select
import GameLogic
import GridLevel
import Html exposing (Html)
import Html.Events
import Html.Events.Extra.Mouse
import Html.Events.Extra.Touch
import Json.Decode
import Json.Encode
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import LevelEditor exposing (Tool(..))
import LineSegment3d
import Math.Vector3
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
import WorldShapes



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

    -- Whether the player is making the level (see `LevelEditor`), with which tool, and what they're
    -- placing with it now
    , editing : Bool
    , tool : Tool
    , placing : Maybe Placing

    -- What the player has placed, what was placed before each change (for undoing), and whether the
    -- minimap has been sent it yet
    , placed : LevelEditor.Placed
    , undo : List Undo
    , placedUnsent : Bool

    -- The level's ground, when it's made of grid pieces (see `GridLevel`), and its open edges. Which
    -- way round the next piece goes, whether it goes along the whole side of the edge, and how it
    -- would look on the edge it would go on. And whether the minimap has been sent the ground yet.
    , ground : Maybe GridLevel.Level
    , groundEdges : List GridLevel.Edge
    , groundFlipped : Bool
    , wholeSide : Bool
    , groundPreview : Maybe GroundPreview
    , groundUnsent : Bool

    -- How the level and what's placed in it are drawn (see `View.view`)
    , layers : List View.Layer
    , pathMesh : WebGL.Mesh MeshBuilder.Vertex

    -- All the walls that stop the player, placed ones included
    , wallCollision : WallCollision.Walls

    -- The world being played in: the one made in code, or one imported from a STEP file
    , level : Level

    -- What the scale field for importing says, and what went wrong importing last, if anything
    , importScale : String
    , importError : Maybe String

    -- How many minimap drawings still to come are of the world before the last import
    , staleMinimaps : Int
    }


{-| What was placed, and the ground, before a change, to go back to when it's undone.
-}
type alias Undo =
    { placed : LevelEditor.Placed
    , ground : Maybe GridLevel.Level
    }


{-| The piece the player has picked put on the edges nearest them: the level with it on, or why it
can't go there, and how it looks.
-}
type alias GroundPreview =
    { for : { edges : List GridLevel.Edge, piece : GridLevel.Piece, flipped : Bool }
    , result : Result String (List GridLevel.Cell)
    , mesh : WebGL.Mesh MeshBuilder.Vertex
    }


{-| How a world is drawn, the walls and buildings (roofs and stairs, see `Buildings`) it comes with,
the walls that stop the player, and the pebbles, rocks and plants lying about (see `Details`).
-}
type alias Level =
    { world : WebGL.Mesh MeshBuilder.Vertex
    , details : Details.Patches
    , walls : WebGL.Mesh WorldMesh.WallVertex
    , roofs : List ( Buildings.Roof, WebGL.Mesh WorldMesh.WallVertex )
    , wallLines : List Buildings.Wall
    , buildings : Buildings
    , collision : WallCollision.Walls
    }


defaultLevel : Level
defaultLevel =
    { world = MeshData.webGlMesh
    , details = MeshData.details
    , walls = MeshData.wallMesh
    , roofs = MeshData.roofMeshes
    , wallLines = List.map (\points -> { points = points, bottom = 0 }) WorldShapes.walls
    , buildings = Buildings.default
    , collision = MeshData.wallCollision
    }


{-| Something the player is placing (see `LevelEditor`), shown in lighter colors until it's finished.
Walls and paths go along the shortest path on the surface from corner to corner (see `ShortestPath`).
-}
type alias Placing =
    { tool : Tool

    -- The bottom of the storey the player was in when they started
    , elevation : Float

    -- Walls and paths: the line up to the last corner. Stairs: the bottom. Roofs: the corners so far.
    , points : List ( Float, Float, Float )

    -- Walls and paths: where the line goes on from, and the way from there to `target`
    , from : SurfacePoint
    , leg : Maybe ShortestPath.Path

    -- Where the next corner (or the end) would go: where the player is, or close by (see `LevelEditor`)
    , target : Buildings.Vec

    -- Where the player was when `leg` was last found, and when it was last searched for all round
    -- rather than followed from the one before (see `ShortestPath.follow`)
    , foundFor : Maybe (Point3d.Point3d Meters WorldCoordinate)
    , searchedFor : Maybe Buildings.Vec
    , walls : WebGL.Mesh WorldMesh.WallVertex
    , ground : WebGL.Mesh MeshBuilder.Vertex
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
                    , editing = False
                    , tool = WallTool
                    , placing = Nothing
                    , placed = LevelEditor.empty
                    , undo = []
                    , placedUnsent = False
                    , ground = Nothing
                    , groundEdges = []
                    , groundFlipped = False
                    , wholeSide = False
                    , groundPreview = Nothing
                    , groundUnsent = False
                    , layers = layers surface defaultLevel LevelEditor.empty
                    , pathMesh = WebGL.triangles []
                    , wallCollision = wallCollision surface defaultLevel LevelEditor.empty
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
    | MinimapDrawn (Maybe { point : SurfacePoint, meshes : Minimap.Meshes })
    | ImportPressed
    | ImportFileSelected File
    | ImportFileLoaded String
    | ImportScaleChanged String
    | EditPressed
    | ToolPressed Tool
    | NewLevelPressed
    | FlipPressed
    | WholeSidePressed
    | SaveLevelPressed
    | LoadLevelPressed
    | LevelFileSelected File
    | LevelFileLoaded String


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

        EditPressed ->
            toggleEditing model |> addCmdNone

        ToolPressed tool ->
            selectTool tool model |> addCmdNone

        NewLevelPressed ->
            newGroundLevel model |> addCmdNone

        FlipPressed ->
            { model | groundFlipped = not model.groundFlipped } |> addCmdNone

        WholeSidePressed ->
            { model | wholeSide = not model.wholeSide } |> addCmdNone

        SaveLevelPressed ->
            case model.ground of
                Just ground ->
                    ( model, File.Download.string "level.json" "application/json" (Json.Encode.encode 0 (GridLevel.encode ground)) )

                Nothing ->
                    ( model, Cmd.none )

        LoadLevelPressed ->
            ( model, File.Select.file [ ".json", "application/json" ] LevelFileSelected )

        LevelFileSelected file ->
            ( model, File.toString file |> Task.perform LevelFileLoaded )

        LevelFileLoaded text ->
            case Json.Decode.decodeString GridLevel.decoder text of
                Ok ground ->
                    { model | placed = LevelEditor.empty, undo = [] }
                        |> setGround (Just ground)
                        |> startOnGround
                        |> setPlaced LevelEditor.empty
                        |> addCmdNone

                Err _ ->
                    { model | importError = Just "That file isn't a level saved from the game" } |> addCmdNone

        MouseEvent event ->
            mouseEvent event model


minimapDrawn : LoadedMsg_ -> LoadedModel_ -> ( LoadedModel_, Cmd LoadedMsg_ )
minimapDrawn msg model =
    case msg of
        MinimapDrawn maybeMinimap ->
            ( case maybeMinimap of
                Just minimap ->
                    { model | minimap = Just minimap, minimapRequest = Nothing }

                Nothing ->
                    { model | minimapRequest = Nothing }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


{-| Decode what the minimap worker sends back as soon as it arrives from the port, since Lamdera
doesn't allow a `Json.Decode.Value` in `FrontendMsg`.
-}
decodeMinimapDrawn : Json.Decode.Value -> Maybe { point : SurfacePoint, meshes : Minimap.Meshes }
decodeMinimapDrawn value =
    Json.Decode.decodeValue
        (Json.Decode.map2 (\point meshes -> { point = point, meshes = meshes })
            (Json.Decode.field "point" Surface.surfacePointDecoder)
            (Json.Decode.field "drawing" Minimap.meshesDecoder)
        )
        value
        |> Result.toMaybe


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
            let
                level =
                    { world = WorldMesh.mesh surface []
                    , details = Details.scatter surface |> Details.patches
                    , walls = WebGL.triangles []
                    , roofs = []
                    , wallLines = []
                    , buildings = Buildings.none
                    , collision = WallCollision.none
                    }
            in
            ( { model
                | surface = surface
                , surfacePoint = surfacePoint
                , height = 0
                , level = level
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
                , placing = Nothing
                , placed = LevelEditor.empty
                , undo = []
                , placedUnsent = False
                , ground = Nothing
                , groundEdges = []
                , groundPreview = Nothing
                , layers = layers surface level LevelEditor.empty
                , pathMesh = WebGL.triangles []
                , wallCollision = wallCollision surface level LevelEditor.empty
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
        |> editKeys
        |> addCmdNone


{-| E goes in and out of making the level. While making it, 1 to 4 pick a tool (see
`LevelEditor.tools`), Space starts placing something or adds a corner to it, Enter finishes it,
Escape stops placing it, and Backspace (or Ctrl+Z) takes away what was placed last.
-}
editKeys : LoadedModel_ -> LoadedModel_
editKeys model =
    let
        pressed =
            Keyboard.isPressed model
    in
    if pressed (Keyboard.Character "E") then
        toggleEditing model

    else if not model.editing then
        model

    else if pressed (Keyboard.Character "N") then
        newGroundLevel model

    else if isGroundTool model.tool && pressed (Keyboard.Character "R") then
        { model | groundFlipped = not model.groundFlipped }

    else if isGroundTool model.tool && pressed (Keyboard.Character "Q") then
        { model | wholeSide = not model.wholeSide }

    else if isGroundTool model.tool && pressed Keyboard.Spacebar then
        placeGround model

    else if pressed Keyboard.Escape then
        { model | placing = Nothing }

    else if pressed Keyboard.Enter then
        finishPlacing model

    else if pressed Keyboard.Spacebar then
        case model.placing of
            Just placing ->
                if placing.tool == StairsTool then
                    finishPlacing model

                else
                    addCorner placing model

            Nothing ->
                startPlacing model

    else if pressed Keyboard.Backspace || Keyboard.actionPressed model == Just Keyboard.UndoAction then
        case ( model.placing, model.undo ) of
            ( Just _, _ ) ->
                { model | placing = Nothing }

            ( Nothing, previous :: older ) ->
                { model | undo = older } |> restore previous

            ( Nothing, [] ) ->
                model

    else
        case
            List.indexedMap Tuple.pair LevelEditor.tools
                |> List.filter (\( i, _ ) -> pressed (Keyboard.Character (toolKey i)))
                |> List.head
        of
            Just ( _, tool ) ->
                selectTool tool model

            Nothing ->
                model


{-| The key for the tool at an index: 1 to 9, then 0, - and =.
-}
toolKey : Int -> String
toolKey index =
    case index of
        9 ->
            "0"

        10 ->
            "-"

        11 ->
            "="

        _ ->
            String.fromInt (index + 1)


isGroundTool : Tool -> Bool
isGroundTool tool =
    case tool of
        GroundTool _ ->
            True

        _ ->
            False


{-| Start a new level made of grid pieces: a flat rectangle, with the player in the middle.
-}
newGroundLevel : LoadedModel_ -> LoadedModel_
newGroundLevel model =
    { model
        | placed = LevelEditor.empty
        , undo = []
        , placing = Nothing
        , tool =
            if isGroundTool model.tool then
                model.tool

            else
                GroundTool GridLevel.SmallSquare
    }
        |> setGround (Just GridLevel.start)
        |> startOnGround
        |> setPlaced LevelEditor.empty


startOnGround : LoadedModel_ -> LoadedModel_
startOnGround model =
    case
        Surface.nearestSurfacePoint GridLevel.startPosition.position model.surface
            |> Maybe.map (Surface.pointTowards GridLevel.startPosition.facing model.surface)
    of
        Just surfacePoint ->
            { model
                | surfacePoint = surfacePoint
                , height = 0
                , moveAction = Nothing
                , cameraNormal = cameraNormal model.surface surfacePoint |> Maybe.withDefault Direction3d.y
                , cameraUp = cameraUp model.surface surfacePoint |> Maybe.withDefault Direction3d.z
            }

        Nothing ->
            model


{-| Put the piece picked on the edges highlighted, if it fits there.
-}
placeGround : LoadedModel_ -> LoadedModel_
placeGround model =
    case model.groundPreview of
        Just shown ->
            case shown.result of
                Ok cells ->
                    case Maybe.map (GridLevel.add cells) model.ground of
                        Just (Ok ground) ->
                            { model | undo = { placed = model.placed, ground = model.ground } :: model.undo }
                                |> setGround (Just ground)

                        Just (Err message) ->
                            { model | groundPreview = Just { shown | result = Err message } }

                        Nothing ->
                            model

                Err _ ->
                    model

        Nothing ->
            model


{-| Change the ground the level is made of (or go back to the world made in code, for Nothing), with
the player staying where they are on it.
-}
setGround : Maybe GridLevel.Level -> LoadedModel_ -> LoadedModel_
setGround ground model =
    let
        built =
            case ground of
                Just ground_ ->
                    GridLevel.surface ground_ |> Result.toMaybe |> Maybe.map (\surface -> ( surface, groundLevel surface ))

                Nothing ->
                    MeshData.surface |> Result.toMaybe |> Maybe.map (\surface -> ( surface, defaultLevel ))
    in
    case built of
        Just ( surface, level ) ->
            let
                position =
                    Surface.worldPosition model.surfacePoint model.surface

                ahead =
                    Maybe.map2 (\p d -> Point3d.translateIn d (Length.centimeters 5) p)
                        position
                        (Surface.worldDirection model.surface model.surfacePoint)

                surfacePoint =
                    position
                        |> Maybe.andThen (\p -> Surface.nearestSurfacePoint p surface)
                        |> Maybe.map
                            (\point ->
                                case ahead of
                                    Just ahead_ ->
                                        Surface.pointTowards ahead_ surface point

                                    Nothing ->
                                        point
                            )
            in
            case surfacePoint of
                Just surfacePoint_ ->
                    { model
                        | ground = ground
                        , groundEdges = Maybe.map GridLevel.openEdges ground |> Maybe.withDefault []
                        , groundPreview = Nothing
                        , groundUnsent = True
                        , surface = surface
                        , surfacePoint = surfacePoint_
                        , level = level
                        , minimap = Nothing
                        , minimapRequest = Nothing
                        , staleMinimaps =
                            if model.minimapRequest == Nothing then
                                model.staleMinimaps

                            else
                                model.staleMinimaps + 1
                    }
                        |> setPlaced model.placed

                Nothing ->
                    model

        Nothing ->
            model


{-| How a level made of grid pieces is drawn: its ground with pebbles, rocks, plants and trees
scattered over it (see `Details`), nothing else on it.
-}
groundLevel : Surface WorldCoordinate -> Level
groundLevel surface =
    { world = WorldMesh.mesh surface []
    , walls = WebGL.triangles []
    , roofs = []
    , wallLines = []
    , buildings = Buildings.none
    , collision = WallCollision.none
    , details = Details.scatter surface |> Details.patches
    }


{-| Go back to before a change.
-}
restore : Undo -> LoadedModel_ -> LoadedModel_
restore previous model =
    (if previous.ground == model.ground then
        model

     else
        setGround previous.ground model
    )
        |> setPlaced previous.placed


{-| Keep the piece picked showing on the open edge nearest the player.
-}
stepGroundPreview : LoadedModel_ -> LoadedModel_
stepGroundPreview model =
    case ( model.tool, model.ground, Surface.worldPosition model.surfacePoint model.surface ) of
        ( GroundTool piece, Just ground, Just position ) ->
            if model.editing then
                case GridLevel.nearestEdge model.groundEdges (Point3d.toMeters position) of
                    Just edge ->
                        let
                            for =
                                { edges =
                                    if model.wholeSide then
                                        GridLevel.wholeSide model.groundEdges edge

                                    else
                                        [ edge ]
                                , piece = piece
                                , flipped = model.groundFlipped
                                }
                        in
                        if Maybe.map .for model.groundPreview == Just for then
                            model

                        else
                            let
                                cells =
                                    GridLevel.attach piece model.groundFlipped for.edges

                                result =
                                    cells
                                        |> Result.fromMaybe "That piece can't go on this edge"
                                        |> Result.andThen (\cells_ -> GridLevel.fits cells_ ground |> Result.map (\() -> cells_))
                            in
                            { model
                                | groundPreview =
                                    Just
                                        { for = for
                                        , result = result
                                        , mesh =
                                            WorldMesh.groundPreview
                                                (cells |> Maybe.andThen (GridLevel.cellsSurface >> Result.toMaybe))
                                                (Result.toMaybe result /= Nothing)
                                                (List.map GridLevel.edgeSamples for.edges)
                                        }
                            }

                    Nothing ->
                        { model | groundPreview = Nothing }

            else
                model

        _ ->
            model


toggleEditing : LoadedModel_ -> LoadedModel_
toggleEditing model =
    { model | editing = not model.editing, placing = Nothing }


selectTool : Tool -> LoadedModel_ -> LoadedModel_
selectTool tool model =
    { model
        | editing = True
        , tool = tool
        , placing =
            if Maybe.map .tool model.placing == Just tool then
                model.placing

            else
                Nothing
    }


{-| Start placing something with the tool picked, where the player is (or close by, see `target`).
-}
startPlacing : LoadedModel_ -> LoadedModel_
startPlacing model =
    case Surface.worldPosition model.surfacePoint model.surface of
        Just position_ ->
            let
                position =
                    Point3d.toMeters position_

                elevation =
                    LevelEditor.elevationAt model.height

                start =
                    target model model.tool elevation [] position

                from =
                    if start == position then
                        Just model.surfacePoint

                    else
                        Surface.nearestSurfacePoint (Point3d.fromMeters start) model.surface
            in
            case from of
                Just from_ ->
                    { model
                        | placing =
                            Just
                                { tool = model.tool
                                , elevation = elevation
                                , points = [ toTuple start ]
                                , from = from_
                                , leg = Nothing
                                , target = start
                                , foundFor = Nothing
                                , searchedFor = Nothing
                                , walls = WebGL.triangles []
                                , ground = WebGL.triangles []
                                }
                    }

                Nothing ->
                    model

        Nothing ->
            model


{-| Where the next corner or the end of what's being placed goes, with the player at `position`.
-}
target : LoadedModel_ -> Tool -> Float -> List ( Float, Float, Float ) -> Buildings.Vec -> Buildings.Vec
target model tool elevation points position =
    case tool of
        WallTool ->
            LevelEditor.snapEnd
                (List.map .points (LevelEditor.wallsAt elevation (model.level.wallLines ++ model.placed.walls))
                    -- So a wall can go round and end where it started
                    ++ (if List.length points > 2 then
                            [ List.take 1 points ]

                        else
                            []
                       )
                )
                position

        PathTool ->
            LevelEditor.snapEnd model.placed.paths position

        RoofTool ->
            LevelEditor.roofCorner (model.level.wallLines ++ model.placed.walls) elevation position

        StairsTool ->
            LevelEditor.stairsTop (allBuildings model).roofs elevation position

        GroundTool _ ->
            position


{-| Walls and paths: add the way to `target` to the line, and go on from there. Roofs: add a corner.
-}
addCorner : Placing -> LoadedModel_ -> LoadedModel_
addCorner placing model =
    case placing.tool of
        RoofTool ->
            { model | placing = Just { placing | points = withCorner placing.target placing.points, foundFor = Nothing } }

        _ ->
            case ( legTo model placing, Surface.nearestSurfacePoint (Point3d.fromMeters placing.target) model.surface ) of
                ( Just leg, Just from ) ->
                    { model
                        | placing =
                            Just
                                { placing
                                    | points = alongLeg placing leg
                                    , from = from
                                    , leg = Nothing
                                    , foundFor = Nothing
                                    , searchedFor = Nothing
                                }
                    }

                _ ->
                    model


{-| The corners with another one, unless it's where the last one is.
-}
withCorner : Buildings.Vec -> List ( Float, Float, Float ) -> List ( Float, Float, Float )
withCorner corner corners =
    if List.any (\c -> distanceBetween (fromTuple c) corner < 0.01) (List.take 1 (List.reverse corners)) then
        corners

    else
        corners ++ [ toTuple corner ]


{-| The shortest way from where the line being placed goes on from to its target, searched for all
round, as it's going to stay.
-}
legTo : LoadedModel_ -> Placing -> Maybe ShortestPath.Path
legTo model placing =
    ShortestPath.between model.surface placing.from (Point3d.fromMeters placing.target) placing.leg


{-| The line so far and then a leg of it, ending exactly on the target (it can be a hair off it).
-}
alongLeg : Placing -> ShortestPath.Path -> List ( Float, Float, Float )
alongLeg placing leg =
    placing.points ++ (List.drop 1 leg.points |> List.reverse |> List.drop 1 |> List.reverse) ++ [ toTuple placing.target ]


finishPlacing : LoadedModel_ -> LoadedModel_
finishPlacing model =
    case model.placing of
        Just placing ->
            let
                line =
                    case legTo model placing of
                        Just leg ->
                            alongLeg placing leg

                        Nothing ->
                            placing.points

                placed =
                    model.placed

                done =
                    { model | placing = Nothing }
            in
            case placing.tool of
                WallTool ->
                    if List.length line < 2 then
                        done

                    else
                        done |> place { placed | walls = LevelEditor.addWall { points = line, bottom = placing.elevation } placed.walls }

                PathTool ->
                    if List.length line < 2 then
                        done

                    else
                        done |> place { placed | paths = placed.paths ++ [ line ] }

                RoofTool ->
                    case withCorner placing.target placing.points |> closeRoof of
                        corners ->
                            if List.length corners < 3 then
                                done

                            else
                                done
                                    |> place
                                        { placed
                                            | roofs =
                                                placed.roofs
                                                    ++ [ { corners = List.map fromTuple corners
                                                         , height = placing.elevation + Buildings.storey
                                                         , overhang = WorldMesh.wallThickness / 2
                                                         }
                                                       ]
                                        }

                StairsTool ->
                    case stairsFor placing of
                        Just stairs ->
                            done |> place { placed | stairs = placed.stairs ++ [ stairs ] }

                        Nothing ->
                            done

                GroundTool _ ->
                    done

        Nothing ->
            model


{-| A roof's corners without the last one if it's back on the first.
-}
closeRoof : List ( Float, Float, Float ) -> List ( Float, Float, Float )
closeRoof corners =
    case ( corners, List.reverse corners ) of
        ( first :: _ :: _ :: _ :: _, last :: rest ) ->
            if distanceBetween (fromTuple first) (fromTuple last) < 0.01 then
                List.reverse rest

            else
                corners

        _ ->
            corners


{-| Stairs from where the player started placing them to the target, if that's far enough away.
-}
stairsFor : Placing -> Maybe Buildings.Stairs
stairsFor placing =
    case placing.points of
        bottom :: _ ->
            let
                length =
                    distanceBetween (fromTuple bottom) placing.target
            in
            if length < 0.05 then
                Nothing

            else
                Just
                    { bottom = fromTuple bottom
                    , top = placing.target
                    , width = 0.1
                    , height = Buildings.storey
                    , steps = LevelEditor.stepsFor length
                    , elevation = placing.elevation
                    }

        [] ->
            Nothing


{-| Change what's placed, so it can be undone.
-}
place : LevelEditor.Placed -> LoadedModel_ -> LoadedModel_
place placed model =
    { model | undo = { placed = model.placed, ground = model.ground } :: model.undo } |> setPlaced placed


setPlaced : LevelEditor.Placed -> LoadedModel_ -> LoadedModel_
setPlaced placed model =
    { model
        | placed = placed
        , placedUnsent = True
        , layers = layers model.surface model.level placed
        , pathMesh = WorldMesh.pathMesh model.surface { preview = False } placed.paths
        , wallCollision = wallCollision model.surface model.level placed
    }


{-| All the walls that stop the player: the level's own, the trunks of its trees that nothing's been
placed on (see `Details`), and the placed ones.
-}
wallCollision : Surface WorldCoordinate -> Level -> LevelEditor.Placed -> WallCollision.Walls
wallCollision surface level placed =
    WallCollision.add surface
        (placed.walls ++ Details.trunks (placedObstacles surface placed) level.details)
        level.collision


{-| What's been placed that the level's pebbles, rocks, plants and trees are kept off.
-}
placedObstacles : Surface WorldCoordinate -> LevelEditor.Placed -> Details.Obstacles
placedObstacles surface placed =
    Details.obstacles surface { walls = placed.walls, pavings = [], paths = placed.paths, stairs = placed.stairs }


{-| The level's buildings and the ones placed.
-}
allBuildings : LoadedModel_ -> Buildings
allBuildings model =
    Buildings.append model.level.buildings (LevelEditor.buildings model.placed)


{-| What's drawn flat on the surface, storey by storey (see `View.Layer`): the level's own walls and
roofs, then what's been placed. The pebbles, rocks and plants go on the ground floor, where nothing
placed is.
-}
layers : Surface WorldCoordinate -> Level -> LevelEditor.Placed -> List View.Layer
layers surface level placed =
    let
        storeyOf height =
            round (height / Buildings.storey)

        top =
            (List.map (.bottom >> storeyOf) placed.walls
                ++ List.map (.elevation >> storeyOf) placed.stairs
                ++ List.map (\roof -> storeyOf roof.height - 1) (placed.roofs ++ List.map Tuple.first level.roofs)
            )
                |> List.maximum
                |> Maybe.withDefault 0

        details =
            Details.meshes (placedObstacles surface placed) level.details

        layer i =
            { walls =
                (if i == 0 then
                    details ++ [ level.walls ]

                 else
                    []
                )
                    ++ [ WorldMesh.wallMesh surface
                            { walls = WorldMesh.wallColor, stairs = WorldMesh.stairsColor }
                            (List.filter (\wall -> storeyOf wall.bottom == i) placed.walls)
                            (List.filter (\stairs -> storeyOf stairs.elevation == i) placed.stairs)
                       ]
            , roofs =
                List.filter (\( roof, _ ) -> storeyOf roof.height == i + 1) level.roofs
                    ++ (placed.roofs
                            |> List.filter (\roof -> storeyOf roof.height == i + 1)
                            |> List.map (\roof -> ( roof, WorldMesh.roofMesh surface Nothing roof ))
                       )
            }
    in
    List.range 0 (max 0 top) |> List.map layer


{-| Keep what's being placed going to where the player is.
-}
stepPlacing : LoadedModel_ -> LoadedModel_
stepPlacing model =
    case ( model.placing, Surface.worldPosition model.surfacePoint model.surface ) of
        ( Just placing, Just position ) ->
            if placing.foundFor == Just position then
                model

            else
                let
                    goal =
                        target model placing.tool placing.elevation placing.points (Point3d.toMeters position)

                    moved =
                        { placing | target = goal, foundFor = Just position }
                in
                { model | placing = Just (preview model moved) }

        _ ->
            model


{-| What's being placed, drawn in lighter colors, with the way to its target found again for walls and
paths.
-}
preview : LoadedModel_ -> Placing -> Placing
preview model placing =
    let
        previewWalls walls stairs =
            WorldMesh.wallMesh model.surface { walls = previewColor, stairs = previewColor } walls stairs
    in
    case placing.tool of
        RoofTool ->
            let
                corners =
                    withCorner placing.target placing.points
            in
            { placing
                | ground = WorldMesh.pathMesh model.surface { preview = True } [ corners ++ List.take 1 corners ]
                , walls =
                    if List.length corners >= 3 then
                        WorldMesh.roofMesh model.surface
                            (Just previewColor)
                            { corners = List.map fromTuple corners, height = placing.elevation + Buildings.storey, overhang = WorldMesh.wallThickness / 2 }

                    else
                        WebGL.triangles []
            }

        StairsTool ->
            { placing | walls = previewWalls [] (stairsFor placing |> Maybe.map List.singleton |> Maybe.withDefault []) }

        _ ->
            let
                searchAgain =
                    case ( placing.leg, placing.searchedFor ) of
                        ( Just _, Just lastSearch ) ->
                            distanceBetween lastSearch placing.target > Length.inMeters searchEvery

                        _ ->
                            True

                followed =
                    if searchAgain then
                        Nothing

                    else
                        placing.leg |> Maybe.andThen (ShortestPath.follow model.surface placing.from (Point3d.fromMeters placing.target))

                ( leg, searchedFor ) =
                    case followed of
                        Just _ ->
                            ( followed, placing.searchedFor )

                        Nothing ->
                            ( legTo model placing, Just placing.target )

                line =
                    case leg of
                        Just leg_ ->
                            alongLeg placing leg_

                        Nothing ->
                            placing.points
            in
            if placing.tool == PathTool then
                { placing | leg = leg, searchedFor = searchedFor, ground = WorldMesh.pathMesh model.surface { preview = True } [ line ] }

            else
                { placing | leg = leg, searchedFor = searchedFor, walls = previewWalls [ { points = line, bottom = placing.elevation } ] [] }


previewColor : Math.Vector3.Vec3
previewColor =
    Math.Vector3.vec3 0.82 0.82 0.82


{-| How far the player moves between looking all round for the shortest way for the wall or path
they're placing. In between, the way found last is followed, which is quicker, but stays the same side
of the hole even if the other side gets shorter.
-}
searchEvery : Length.Length
searchEvery =
    Length.centimeters 15


toTuple : Buildings.Vec -> ( Float, Float, Float )
toTuple v =
    ( v.x, v.y, v.z )


fromTuple : ( Float, Float, Float ) -> Buildings.Vec
fromTuple ( x, y, z ) =
    { x = x, y = y, z = z }


distanceBetween : Buildings.Vec -> Buildings.Vec -> Float
distanceBetween a b =
    sqrt ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)


step : LoadedModel_ -> LoadedModel_
step model =
    model
        |> stepMovement
        |> stepHeight
        |> stepCamera
        |> stepPlacing
        |> stepGroundPreview


frameDuration =
    Duration.seconds (1 / 60)


stepMovement model =
    let
        movement =
            Keyboard.arrowDown model |> Vector2d.direction

        crouching =
            isCrouching model

        speed =
            if crouching then
                Quantity.multiplyBy crouchSpeed GameLogic.playerSpeed

            else
                GameLogic.playerSpeed

        buildings =
            allBuildings model

        supportAt point =
            Surface.worldPosition point model.surface
                |> Maybe.map (Point3d.toMeters >> Buildings.standingHeight buildings model.height)

        support =
            supportAt model.surfacePoint |> Maybe.withDefault 0

        -- Crouching, the player doesn't step off anything they'd drop down from
        keepsFooting point =
            not crouching || (supportAt point |> Maybe.map (\h -> h >= support - Buildings.maxStepUp) |> Maybe.withDefault False)

        walkBy angle distance =
            if model.editing then
                -- Making the level, the player goes through walls
                Surface.move model.surface angle distance model.surfacePoint
                    |> Maybe.map Surface.pathEnd
                    |> Maybe.withDefault model.surfacePoint

            else
                WallCollision.move model.surface model.wallCollision model.height angle distance model.surfacePoint

        walk direction =
            let
                angle =
                    Direction2d.angleFrom Direction2d.y direction

                distance =
                    speed |> Quantity.for frameDuration

                -- At an edge, sliding along it if the player is going along it as well as over it
                slides =
                    [ 1, -1 ]
                        |> List.map (\side -> walkBy (Quantity.plus angle (Angle.degrees (45 * side))) (Quantity.multiplyBy (sqrt 0.5) distance))
            in
            (walkBy angle distance :: slides)
                |> List.filter keepsFooting
                |> List.head
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


{-| Holding Shift, the player crouches: they walk slower and don't step off ledges, which makes it
easier to walk right up to a roof's edge to place a wall on it, over the wall under it.
-}
isCrouching : LoadedModel_ -> Bool
isCrouching model =
    Keyboard.isDown model Keyboard.Shift


crouchSpeed : Float
crouchSpeed =
    0.5


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

        encodeLines =
            Json.Encode.list (Json.Encode.list (\( x, y, z ) -> Json.Encode.list Json.Encode.float [ x, y, z ]))
    in
    if model.minimapRequest == Nothing && (movedFar || model.placedUnsent || model.groundUnsent) then
        ( { model | minimapRequest = Just model.surfacePoint, placedUnsent = False, groundUnsent = False }
        , Json.Encode.object
            (( "point", Surface.encodeSurfacePoint model.surfacePoint )
                :: (case ( model.groundUnsent, model.ground ) of
                        ( True, Just ground ) ->
                            [ ( "ground", GridLevel.encode ground ) ]

                        ( True, Nothing ) ->
                            [ ( "ground", Json.Encode.null ) ]

                        ( False, _ ) ->
                            []
                   )
                ++ (if model.placedUnsent then
                        [ ( "placed"
                          , Json.Encode.object
                                [ ( "walls", encodeLines (List.map .points model.placed.walls) )
                                , ( "paths", encodeLines model.placed.paths )
                                ]
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
            { model | height = Buildings.heightAfter (allBuildings model) (Duration.inSeconds frameDuration) model.height (Point3d.toMeters position) }

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
            Element.column
                [ Element.spacing 6
                , Element.padding 4

                -- Clear of the minimap
                , Element.width (Element.maximum (Tuple.first (Vector2i.toTuple Pixels.inPixels model.windowSize) - Pixels.inPixels Minimap.size - 40) Element.shrink)
                ]
                [ Element.text "Move with arrow keys or mouse click, hold Shift to crouch. Hold the middle mouse button and drag to turn the camera"
                , editorControls model
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
                { world =
                    model.level.world
                        :: model.pathMesh
                        :: (Maybe.map (.ground >> List.singleton) model.placing |> Maybe.withDefault [])
                        ++ (case ( model.editing && isGroundTool model.tool, model.groundPreview ) of
                                ( True, Just groundPreview ) ->
                                    [ groundPreview.mesh ]

                                _ ->
                                    []
                           )
                , grid =
                    if model.editing && model.ground /= Nothing then
                        GridLevel.cellSize

                    else
                        0
                , layers = model.layers
                , preview = Maybe.map (.walls >> List.singleton) model.placing |> Maybe.withDefault []
                , player = WorldMesh.playerMesh
                , crouching = isCrouching model
                }
            )
        )


{-| A button to start and stop making the level, and while making it, the tools to pick from (see
`LevelEditor`) and what to do with the one picked. Mouse presses on them don't walk the player there,
and don't focus the buttons, as Space and Enter would press a focused button again.
-}
editorControls : LoadedModel_ -> Element LoadedMsg_
editorControls model =
    let
        button selected onPress label =
            Element.Input.button
                [ Element.Background.color
                    (if selected then
                        Element.rgb 0.75 0.85 1

                     else
                        Element.rgb 0.95 0.95 0.95
                    )
                , Element.Border.rounded 4
                , Element.Border.width 1
                , Element.Border.color (Element.rgb 0.6 0.6 0.6)
                , Element.paddingXY 8 4
                ]
                { onPress = Just onPress, label = Element.text label }
    in
    Element.column
        [ Element.spacing 4
        , Element.htmlAttribute <| Html.Events.custom "mousedown" (Json.Decode.succeed { message = NoOp, stopPropagation = True, preventDefault = True })
        ]
        (if model.editing then
            let
                toolButtons =
                    List.indexedMap
                        (\i tool -> ( tool, button (tool == model.tool) (ToolPressed tool) (toolKey i ++ " " ++ LevelEditor.toolName tool) ))
                        LevelEditor.tools

                ( groundButtons, otherButtons ) =
                    List.partition (Tuple.first >> isGroundTool) toolButtons
            in
            [ Element.wrappedRow [ Element.spacing 8 ] (button True EditPressed "Stop editing (E)" :: List.map Tuple.second otherButtons)
            , Element.wrappedRow [ Element.spacing 8 ]
                (Element.text "Ground:"
                    :: List.map Tuple.second groundButtons
                    ++ [ button False NewLevelPressed "New level (N)"
                       , button False LoadLevelPressed "Load level"
                       ]
                    ++ (if model.ground /= Nothing then
                            [ button False SaveLevelPressed "Save level" ]

                        else
                            []
                       )
                )
            , Element.paragraph [] [ Element.text (LevelEditor.toolHint model.tool { placing = model.placing /= Nothing }) ]
            , case model.tool of
                GroundTool piece ->
                    if model.ground == Nothing then
                        Element.text "This level isn't made of grid pieces. Press N to start a new one from a flat rectangle"

                    else
                        Element.column [ Element.spacing 4 ]
                            [ Element.row [ Element.spacing 8 ]
                                [ button model.groundFlipped FlipPressed "Flip (R)"
                                , button model.wholeSide WholeSidePressed "Whole side (Q)"
                                ]
                            , Element.paragraph [] [ Element.text (GridLevel.pieceHint piece model.groundFlipped) ]
                            , case Maybe.map .result model.groundPreview of
                                Just (Err message) ->
                                    Element.el [ Element.Font.color (Element.rgb 0.75 0 0) ] (Element.text message)

                                _ ->
                                    Element.none
                            ]

                _ ->
                    Element.none
            , Element.paragraph [] [ Element.text "You go through walls while editing. Escape stops placing, Backspace takes away what you placed last" ]
            ]

         else
            [ button False EditPressed "Edit level (E)" ]
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
                , MinimapPort.minimapDrawn (decodeMinimapDrawn >> MinimapDrawn)
                ]
                |> Sub.map LoadedMsg

        LoadingModel _ ->
            Sub.none

        FailureModel _ ->
            Sub.none
