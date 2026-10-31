module Evergreen.V1.LevelEditor exposing (..)

import Evergreen.V1.Buildings
import Evergreen.V1.GridLevel


type Tool
    = WallTool
    | StairsTool
    | PathTool
    | RoofTool
    | GroundTool Evergreen.V1.GridLevel.Piece


type alias Placed =
    { walls : List Evergreen.V1.Buildings.Wall
    , stairs : List Evergreen.V1.Buildings.Stairs
    , paths : List (List ( Float, Float, Float ))
    , roofs : List Evergreen.V1.Buildings.Roof
    }
