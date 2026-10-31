module Evergreen.V1.Details exposing (..)

import Evergreen.V1.WorldMesh
import WebGL


type alias Vec =
    { x : Float
    , y : Float
    , z : Float
    }


type Kind
    = Pebble
    | Rock
    | Tuft
    | Flower
    | RoundTree
    | Pine


type alias Detail =
    { position : Vec
    , normal : Vec
    , kind : Kind
    , size : Float
    , seed : Int
    }


type Patches
    = Patches
        (List
            { details : List Detail
            , mesh : WebGL.Mesh Evergreen.V1.WorldMesh.WallVertex
            }
        )
