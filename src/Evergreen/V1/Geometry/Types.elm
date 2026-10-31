module Evergreen.V1.Geometry.Types exposing (..)


type Point2d units coordinates
    = Point2d
        { x : Float
        , y : Float
        }


type Direction2d coordinates
    = Direction2d
        { x : Float
        , y : Float
        }


type Direction3d coordinates
    = Direction3d
        { x : Float
        , y : Float
        , z : Float
        }


type Point3d units coordinates
    = Point3d
        { x : Float
        , y : Float
        , z : Float
        }
