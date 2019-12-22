module Mesh exposing (fromVertsAndIndices, getAdjacentTriangles, getTriangles, getVertices)

import Array exposing (Array)
import Dict exposing (Dict)
import LineSegment3d exposing (LineSegment3d)
import List.Extra as List
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import SketchPlane3d exposing (SketchPlane3d)
import Triangle exposing (Triangle)
import Triangle3d exposing (Triangle3d)
import Vector2d exposing (Vector2d)


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias Mesh_ units coordinates =
    { triangles : Array (Triangle VertexId)
    , vertices : Array (Point3d units coordinates)
    , adjacentTriangles : Dict ( TriangleId, Int ) TriangleId
    }


getTriangles : Mesh units coordinates -> Array (Triangle VertexId)
getTriangles (Mesh mesh) =
    mesh.triangles


getVertices : Mesh units coordinates -> Array (Point3d units coordinates)
getVertices (Mesh mesh) =
    mesh.vertices


getAdjacentTriangles : Mesh units coordinates -> Dict ( TriangleId, Int ) TriangleId
getAdjacentTriangles (Mesh mesh) =
    mesh.adjacentTriangles


fromVertsAndIndices : Array (Point3d units coordinates) -> Array (Triangle VertexId) -> Mesh units coordinates
fromVertsAndIndices vertices triangleIndices =
    let
        orderTuple ( a, b ) =
            if a < b then
                ( a, b )

            else
                ( b, a )

        validTriangles =
            triangleIndices
                |> Array.filter
                    (\tri -> Triangle.andThen (\index -> Array.get index vertices) tri /= Nothing)

        adjacentTrianglePairs =
            Array.toList validTriangles
                |> List.indexedMap Tuple.pair
                |> List.concatMap
                    (\( triIndex, tri ) ->
                        Triangle.edges tri
                            |> List.indexedMap
                                (\edgeIndex edge ->
                                    { edge = orderTuple edge, edgeIndex = edgeIndex, triIndex = triIndex }
                                )
                    )
                |> List.gatherEqualsBy .edge

        adjacentTriangles =
            adjacentTrianglePairs
                |> List.concatMap
                    (\( { edgeIndex, triIndex }, rest ) ->
                        case rest of
                            [] ->
                                []

                            other :: [] ->
                                [ ( ( triIndex, edgeIndex ), other.triIndex )
                                , ( ( other.triIndex, other.edgeIndex ), triIndex )
                                ]

                            _ ->
                                Debug.todo "Handle nonmanifold case."
                    )
                |> Dict.fromList
    in
    { triangles = validTriangles
    , vertices = vertices
    , adjacentTriangles = adjacentTriangles
    }
        |> Mesh


type alias VertexId =
    Int


type alias TriangleId =
    Int


type alias SurfaceMarkerId =
    Int


type TriangleEdge
    = SideOne
    | SideTwo
    | SideThree


getTriangleEdge : TriangleEdge -> Triangle3d units coordinates -> LineSegment3d units coordinates
getTriangleEdge triangleEdge triangle =
    let
        ( first, second, third ) =
            Triangle3d.edges triangle
    in
    case triangleEdge of
        SideOne ->
            first

        SideTwo ->
            second

        SideThree ->
            third


getTriangle : Mesh units coordinates -> TriangleId -> Maybe (Triangle3d units coordinates)
getTriangle (Mesh mesh) triangleId =
    Array.get triangleId mesh.triangles
        |> Maybe.andThen
            (\{ v0, v1, v2 } ->
                Maybe.map3
                    (\v0_ v1_ v2_ -> Triangle3d.fromVertices ( v0_, v1_, v2_ ))
                    (Array.get v0 mesh.vertices)
                    (Array.get v1 mesh.vertices)
                    (Array.get v2 mesh.vertices)
            )


type alias AdjacentTriangle =
    { triangleId : TriangleId, flipped : Bool }


adjacentTriangle : Mesh units coordinates -> TriangleId -> TriangleEdge -> Maybe AdjacentTriangle
adjacentTriangle mesh triangleId =
    Debug.todo ""


type SurfaceMarker units coordinates
    = SurfaceMarker (SurfaceMarker_ units coordinates)


type alias SurfaceMarker_ units coordinates =
    { triangleId : TriangleId
    , position : Point2d units coordinates
    , side : SurfaceSide
    }


type SurfaceSide
    = Front
    | Back


type MeshSurfaceCoordinates
    = MeshSurfaceCoordinates Never


getSketchPlane :
    Mesh units coordinates
    -> SurfaceMarker units coordinates
    -> Maybe (SketchPlane3d units coordinates { defines : MeshSurfaceCoordinates })
getSketchPlane mesh (SurfaceMarker marker) =
    getTriangle mesh marker.triangleId
        |> Maybe.andThen
            (\triangle ->
                let
                    ( first, second, third ) =
                        Triangle3d.vertices triangle
                in
                SketchPlane3d.throughPoints first second third
            )


move :
    Mesh units coordinates
    -> Vector2d units coordinates
    -> SurfaceMarker units coordinates
    -> SurfaceMarker units coordinates
move mesh movement position =
    case getSketchPlane mesh position of
        Just triangle ->
            let
                a =
                    5
            in
            Debug.todo ""

        Nothing ->
            position
