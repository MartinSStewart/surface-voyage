module SurfaceMesh.TriangleEdge exposing (..)

import LineSegment3d exposing (LineSegment3d)
import Triangle3d exposing (Triangle3d)


type TriangleEdge
    = EdgeZero
    | EdgeOne
    | EdgeTwo


toInt : TriangleEdge -> Int
toInt edge =
    case edge of
        EdgeZero ->
            0

        EdgeOne ->
            1

        EdgeTwo ->
            2


fromInt : Int -> TriangleEdge
fromInt index =
    case modBy 3 index of
        0 ->
            EdgeZero

        1 ->
            EdgeOne

        _ ->
            EdgeTwo


getTriangleEdge : TriangleEdge -> Triangle3d units coordinates -> LineSegment3d units coordinates
getTriangleEdge triangleEdge triangle =
    let
        ( first, second, third ) =
            Triangle3d.edges triangle
    in
    case triangleEdge of
        EdgeZero ->
            first

        EdgeOne ->
            second

        EdgeTwo ->
            third
