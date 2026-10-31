module Evergreen.V1.GridLevel exposing (..)


type Piece
    = SmallSquare
    | LargeSquare
    | InsideCurve
    | OutsideCurve
    | SmallBend
    | LargeBend
    | SharpTurn
    | WideTurn


type alias IVec =
    { x : Int
    , y : Int
    , z : Int
    }


type Curve
    = Segment IVec IVec
    | Arc
        { center : IVec
        , radius : Int
        , from : IVec
        , to : IVec
        }


type Profile
    = ProfileLine ( Int, Int ) ( Int, Int )
    | ProfileArc
        { from : ( Int, Int )
        , to : ( Int, Int )
        , center : ( Int, Int )
        }


type alias Revolution =
    { center : IVec
    , axis : IVec
    , x : IVec
    , profile : Profile
    }


type Cell
    = FlatCell
        { normal : IVec
        , loop : List Curve
        }
    | RoundCell Revolution


type alias Level =
    { cells : List Cell
    }


type Across
    = Along IVec
    | Radial Int


type alias Edge =
    { curve : Curve
    , out : Across
    , normal : Across
    }
