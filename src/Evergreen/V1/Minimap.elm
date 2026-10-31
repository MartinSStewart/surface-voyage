module Evergreen.V1.Minimap exposing (..)

import Math.Vector2
import WebGL


type alias Meshes =
    { paving :
        WebGL.Mesh
            { position : Math.Vector2.Vec2
            }
    , walls :
        WebGL.Mesh
            { position : Math.Vector2.Vec2
            }
    }
