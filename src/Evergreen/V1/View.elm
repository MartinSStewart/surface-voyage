module Evergreen.V1.View exposing (..)

import Evergreen.V1.Buildings
import Evergreen.V1.WorldMesh
import WebGL


type alias Layer =
    { walls : List (WebGL.Mesh Evergreen.V1.WorldMesh.WallVertex)
    , roofs : List ( Evergreen.V1.Buildings.Roof, WebGL.Mesh Evergreen.V1.WorldMesh.WallVertex )
    }
