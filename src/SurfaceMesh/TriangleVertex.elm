module SurfaceMesh.TriangleVertex exposing (..)

import Point3d exposing (Point3d)
import Triangle3d exposing (Triangle3d)


type TriangleVertex
    = VertexZero
    | VertexOne
    | VertexTwo


toInt : TriangleVertex -> Int
toInt vertex =
    case vertex of
        VertexZero ->
            0

        VertexOne ->
            1

        VertexTwo ->
            2


fromInt : Int -> TriangleVertex
fromInt index =
    case modBy 3 index of
        0 ->
            VertexZero

        1 ->
            VertexOne

        _ ->
            VertexTwo


getTriangleVertex : TriangleVertex -> Triangle3d units coordinates -> Point3d units coordinates
getTriangleVertex triangleVertex triangle =
    let
        ( first, second, third ) =
            Triangle3d.vertices triangle
    in
    case triangleVertex of
        VertexZero ->
            first

        VertexOne ->
            second

        VertexTwo ->
            third
