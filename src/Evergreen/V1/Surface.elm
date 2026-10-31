module Evergreen.V1.Surface exposing (..)

import Array


type alias Vec =
    { x : Float
    , y : Float
    , z : Float
    }


type Edge2d
    = SegmentEdge
        { ax : Float
        , ay : Float
        , bx : Float
        , by : Float
        }
    | ArcEdge
        { cx : Float
        , cy : Float
        , r : Float
        , a0 : Float
        , swept : Float
        }


type alias Flat =
    { origin : Vec
    , u : Vec
    , v : Vec
    , n : Vec
    , edges : Array.Array Edge2d
    }


type ProfileSeg
    = LineSeg
        { s0 : Float
        , len : Float
        , r0 : Float
        , h0 : Float
        , dr : Float
        , dh : Float
        }
    | ArcSeg
        { s0 : Float
        , len : Float
        , cr : Float
        , ch : Float
        , radius : Float
        , a0 : Float
        , dir : Float
        }


type alias Feature =
    { origin : Vec
    , ex : Vec
    , ey : Vec
    , ez : Vec
    , segments : List ProfileSeg
    , length : Float
    , sweep :
        Maybe
            { from : Float
            , to : Float
            }
    , chirality : Float
    }


type Piece
    = FlatPiece Flat
    | FeaturePiece Feature


type alias Box =
    { min : Vec
    , max : Vec
    }


type Surface coordinates
    = Surface
        { pieces : Array.Array Piece
        , seams : Array.Array (Array.Array (Maybe ( Int, Int )))
        , boxes : Array.Array Box
        }


type alias SurfacePoint_ =
    { piece : Int
    , a : Float
    , b : Float
    , heading : Float
    }


type SurfacePoint
    = SurfacePoint SurfacePoint_
