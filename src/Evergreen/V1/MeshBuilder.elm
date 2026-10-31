module Evergreen.V1.MeshBuilder exposing (..)

import Math.Vector3


type alias Vertex =
    { position : Math.Vector3.Vec3
    , normal : Math.Vector3.Vec3
    , color : Math.Vector3.Vec3
    }
