module TriangleSide exposing (..)

import LineSegment3d exposing (LineSegment3d)
import Triangle3d exposing (Triangle3d)


type TriangleSide
    = SideZero
    | SideOne
    | SideTwo


toInt : TriangleSide -> Int
toInt edge =
    case edge of
        SideZero ->
            0

        SideOne ->
            1

        SideTwo ->
            2


toEdge : Int -> TriangleSide
toEdge index =
    case modBy 3 index of
        0 ->
            SideZero

        1 ->
            SideOne

        _ ->
            SideTwo


getTriangleEdge : TriangleSide -> Triangle3d units coordinates -> LineSegment3d units coordinates
getTriangleEdge triangleEdge triangle =
    let
        ( first, second, third ) =
            Triangle3d.edges triangle
    in
    case triangleEdge of
        SideZero ->
            first

        SideOne ->
            second

        SideTwo ->
            third
