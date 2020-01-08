module SurfaceMesh.Triangle exposing (Triangle, andThen, edges, from, fromTriangle2d, fromTriangle3d, getSide, getVertex, hasUniqueVertices, map, toList)

import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import SurfaceMesh.TriangleEdge exposing (TriangleEdge(..))
import SurfaceMesh.TriangleVertex exposing (TriangleVertex(..))
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)


type alias Triangle a =
    ( a, a, a )


from : a -> a -> a -> Triangle a
from v0 v1 v2 =
    ( v0, v1, v2 )


map : (a -> b) -> Triangle a -> Triangle b
map mapFunc ( v0, v1, v2 ) =
    from (mapFunc v0) (mapFunc v1) (mapFunc v2)


andThen : (a -> Maybe b) -> Triangle a -> Maybe (Triangle b)
andThen andThenFunc ( v0, v1, v2 ) =
    Maybe.map3
        from
        (andThenFunc v0)
        (andThenFunc v1)
        (andThenFunc v2)


toList : Triangle a -> List a
toList ( v0, v1, v2 ) =
    [ v0, v1, v2 ]


edges : Triangle a -> List ( a, a )
edges ( v0, v1, v2 ) =
    [ ( v0, v1 ), ( v1, v2 ), ( v2, v0 ) ]


hasUniqueVertices : Triangle a -> Bool
hasUniqueVertices ( v0, v1, v2 ) =
    v0 /= v1 && v1 /= v2 && v2 /= v0


getSide : TriangleEdge -> Triangle a -> ( a, a )
getSide side ( v0, v1, v2 ) =
    case side of
        EdgeZero ->
            ( v0, v1 )

        EdgeOne ->
            ( v1, v2 )

        EdgeTwo ->
            ( v2, v0 )


getVertex : TriangleVertex -> Triangle a -> a
getVertex triangleVertex ( v0, v1, v2 ) =
    case triangleVertex of
        VertexZero ->
            v0

        VertexOne ->
            v1

        VertexTwo ->
            v2


fromTriangle3d : Triangle3d units coordinates -> Triangle (Point3d units coordinates)
fromTriangle3d =
    Triangle3d.vertices


fromTriangle2d : Triangle2d units coordinates -> Triangle (Point2d units coordinates)
fromTriangle2d =
    Triangle2d.vertices
