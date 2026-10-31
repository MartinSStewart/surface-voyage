module Evergreen.V1.ShortestPath exposing (..)


type alias Path =
    { turn : Float
    , length : Float
    , points : List ( Float, Float, Float )
    }
