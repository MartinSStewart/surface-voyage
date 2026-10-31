module Evergreen.V1.Buildings exposing (..)


type alias Vec =
    { x : Float
    , y : Float
    , z : Float
    }


type alias Wall =
    { points : List ( Float, Float, Float )
    , bottom : Float
    }


type alias Stairs =
    { bottom : Vec
    , top : Vec
    , width : Float
    , height : Float
    , steps : Int
    , elevation : Float
    }


type alias Roof =
    { corners : List Vec
    , height : Float
    , overhang : Float
    }


type alias Buildings =
    { roofs : List Roof
    , stairs : List Stairs
    }
