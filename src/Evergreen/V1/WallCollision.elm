module Evergreen.V1.WallCollision exposing (..)


type alias Vec =
    { x : Float
    , y : Float
    , z : Float
    }


type alias Segment =
    { a : Vec
    , b : Vec
    , bottom : Float
    }


type Walls
    = Walls (List Segment)
