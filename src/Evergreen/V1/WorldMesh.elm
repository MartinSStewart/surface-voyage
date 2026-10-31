module Evergreen.V1.WorldMesh exposing (..)

import Math.Vector3


type alias WallVertex =
    { position : Math.Vector3.Vec3
    , normal : Math.Vector3.Vec3
    , color : Math.Vector3.Vec3
    , base : Math.Vector3.Vec3
    , up : Math.Vector3.Vec3
    }
