module Evergreen.V1.Main exposing (..)

import Duration
import Evergreen.V1.Buildings
import Evergreen.V1.Details
import Evergreen.V1.Direction2d
import Evergreen.V1.Direction3d
import Evergreen.V1.GridLevel
import Evergreen.V1.LevelEditor
import Evergreen.V1.MeshBuilder
import Evergreen.V1.MeshData
import Evergreen.V1.Minimap
import Evergreen.V1.Point2d
import Evergreen.V1.Point3d
import Evergreen.V1.ShortestPath
import Evergreen.V1.Surface
import Evergreen.V1.Vector2i
import Evergreen.V1.View
import Evergreen.V1.WallCollision
import Evergreen.V1.WorldMesh
import File
import Html.Events.Extra.Mouse
import Keyboard
import Length
import Pixels
import WebGL


type alias LoadingModel_ =
    { windowSize : Evergreen.V1.Vector2i.Vector2i Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate
    }


type alias Placing =
    { tool : Evergreen.V1.LevelEditor.Tool
    , elevation : Float
    , points : List ( Float, Float, Float )
    , from : Evergreen.V1.Surface.SurfacePoint
    , leg : Maybe Evergreen.V1.ShortestPath.Path
    , target : Evergreen.V1.Buildings.Vec
    , foundFor : Maybe (Evergreen.V1.Point3d.Point3d Length.Meters Evergreen.V1.MeshData.WorldCoordinate)
    , searchedFor : Maybe Evergreen.V1.Buildings.Vec
    , walls : WebGL.Mesh Evergreen.V1.WorldMesh.WallVertex
    , ground : WebGL.Mesh Evergreen.V1.MeshBuilder.Vertex
    }


type alias Undo =
    { placed : Evergreen.V1.LevelEditor.Placed
    , ground : Maybe Evergreen.V1.GridLevel.Level
    }


type alias GroundPreview =
    { for :
        { edges : List Evergreen.V1.GridLevel.Edge
        , piece : Evergreen.V1.GridLevel.Piece
        , flipped : Bool
        }
    , result : Result String (List Evergreen.V1.GridLevel.Cell)
    , mesh : WebGL.Mesh Evergreen.V1.MeshBuilder.Vertex
    }


type alias Level =
    { world : WebGL.Mesh Evergreen.V1.MeshBuilder.Vertex
    , details : Evergreen.V1.Details.Patches
    , walls : WebGL.Mesh Evergreen.V1.WorldMesh.WallVertex
    , roofs : List ( Evergreen.V1.Buildings.Roof, WebGL.Mesh Evergreen.V1.WorldMesh.WallVertex )
    , wallLines : List Evergreen.V1.Buildings.Wall
    , buildings : Evergreen.V1.Buildings.Buildings
    , collision : Evergreen.V1.WallCollision.Walls
    }


type alias LoadedModel_ =
    { keys : List Keyboard.Key
    , previousKeys : List Keyboard.Key
    , mouseLastDown :
        Maybe
            { position : Evergreen.V1.Point2d.Point2d Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate
            , time : Duration.Duration
            }
    , mouseLastUp :
        Maybe
            { position : Evergreen.V1.Point2d.Point2d Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate
            , time : Duration.Duration
            }
    , mousePosition : Maybe (Evergreen.V1.Point2d.Point2d Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate)
    , moveAction :
        Maybe
            { direction : Evergreen.V1.Direction2d.Direction2d Evergreen.V1.MeshData.ScreenCoordinate
            , endTime : Duration.Duration
            }
    , cameraDrag : Maybe (Evergreen.V1.Point2d.Point2d Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate)
    , cameraPitch : Float
    , windowSize : Evergreen.V1.Vector2i.Vector2i Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate
    , surface : Evergreen.V1.Surface.Surface Evergreen.V1.MeshData.WorldCoordinate
    , surfacePoint : Evergreen.V1.Surface.SurfacePoint
    , height : Float
    , minimap :
        Maybe
            { point : Evergreen.V1.Surface.SurfacePoint
            , meshes : Evergreen.V1.Minimap.Meshes
            }
    , minimapRequest : Maybe Evergreen.V1.Surface.SurfacePoint
    , cameraNormal : Evergreen.V1.Direction3d.Direction3d Evergreen.V1.MeshData.WorldCoordinate
    , cameraUp : Evergreen.V1.Direction3d.Direction3d Evergreen.V1.MeshData.WorldCoordinate
    , time : Duration.Duration
    , editing : Bool
    , tool : Evergreen.V1.LevelEditor.Tool
    , placing : Maybe Placing
    , placed : Evergreen.V1.LevelEditor.Placed
    , undo : List Undo
    , placedUnsent : Bool
    , ground : Maybe Evergreen.V1.GridLevel.Level
    , groundEdges : List Evergreen.V1.GridLevel.Edge
    , groundFlipped : Bool
    , wholeSide : Bool
    , groundPreview : Maybe GroundPreview
    , groundUnsent : Bool
    , layers : List Evergreen.V1.View.Layer
    , pathMesh : WebGL.Mesh Evergreen.V1.MeshBuilder.Vertex
    , wallCollision : Evergreen.V1.WallCollision.Walls
    , level : Level
    , importScale : String
    , importError : Maybe String
    , staleMinimaps : Int
    }


type alias FailureModel_ =
    { message : String
    }


type Model
    = LoadingModel LoadingModel_
    | LoadedModel LoadedModel_
    | FailureModel FailureModel_


type LoadingMsg_
    = GotWindowSize (Evergreen.V1.Vector2i.Vector2i Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate)


type MouseEventType
    = MouseEventDown
    | MouseEventMove
    | MouseEventUp


type alias MouseEvent_ =
    { position : Evergreen.V1.Point2d.Point2d Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate
    , eventType : MouseEventType
    , button : Html.Events.Extra.Mouse.Button
    }


type LoadedMsg_
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize (Evergreen.V1.Vector2i.Vector2i Pixels.Pixels Evergreen.V1.MeshData.ScreenCoordinate)
    | AnimationFrameDelta Duration.Duration
    | MouseEvent MouseEvent_
    | MinimapDrawn
        (Maybe
            { point : Evergreen.V1.Surface.SurfacePoint
            , meshes : Evergreen.V1.Minimap.Meshes
            }
        )
    | ImportPressed
    | ImportFileSelected File.File
    | ImportFileLoaded String
    | ImportScaleChanged String
    | EditPressed
    | ToolPressed Evergreen.V1.LevelEditor.Tool
    | NewLevelPressed
    | FlipPressed
    | WholeSidePressed
    | SaveLevelPressed
    | LoadLevelPressed
    | LevelFileSelected File.File
    | LevelFileLoaded String


type Msg
    = LoadingMsg LoadingMsg_
    | LoadedMsg LoadedMsg_
