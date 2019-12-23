module Mesh exposing (adjacentTriangle, fromVertsAndIndices, getAdjacentTriangles, getTriangle, getTriangles, getVertices)

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
import Vector3d


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias Mesh_ units coordinates =
    { triangles : Array (Triangle VertexId_)
    , vertices : Array (Point3d units coordinates)
    , adjacentTriangles : Dict ( TriangleId_, EdgeIndex_ ) ( TriangleId, TriangleEdge )
    }


getTriangles : Mesh units coordinates -> Array (Triangle VertexId_)
getTriangles (Mesh mesh) =
    mesh.triangles


getVertices : Mesh units coordinates -> Array (Point3d units coordinates)
getVertices (Mesh mesh) =
    mesh.vertices


getAdjacentTriangles : Mesh units coordinates -> Dict ( TriangleId_, Int ) ( TriangleId, TriangleEdge )
getAdjacentTriangles (Mesh mesh) =
    mesh.adjacentTriangles


type Error
    = NonManifold
    | EmptyMesh


fromVertsAndIndices : Array (Point3d units coordinates) -> Array (Triangle VertexId_) -> Result Error (Mesh units coordinates)
fromVertsAndIndices vertices triangleIndices =
    let
        validTriangles =
            triangleIndices
                |> Array.filter
                    (\tri -> Triangle.andThen (\index -> Array.get index vertices) tri /= Nothing)
    in
    case Array.get 0 validTriangles of
        Just _ ->
            let
                orderTuple ( a, b ) =
                    if a < b then
                        ( a, b )

                    else
                        ( b, a )

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
                        |> List.foldl
                            (\( { edgeIndex, triIndex }, rest ) state ->
                                case ( rest, state ) of
                                    ( [], Just list ) ->
                                        Just list

                                    ( other :: [], Just list ) ->
                                        [ ( ( triIndex, edgeIndex ), ( TriangleId other.triIndex, intToEdge other.edgeIndex ) )
                                        , ( ( other.triIndex, other.edgeIndex ), ( TriangleId triIndex, intToEdge edgeIndex ) )
                                        ]
                                            ++ list
                                            |> Just

                                    _ ->
                                        Nothing
                            )
                            (Just [])
            in
            case adjacentTriangles of
                Just list ->
                    { triangles = validTriangles
                    , vertices = vertices
                    , adjacentTriangles = Dict.fromList list
                    }
                        |> Mesh
                        |> Ok

                Nothing ->
                    Err NonManifold

        Nothing ->
            Err EmptyMesh


type alias VertexId_ =
    Int


type TriangleId
    = TriangleId Int


type VertexId
    = VertexId Int


type alias EdgeIndex_ =
    Int


type alias TriangleId_ =
    Int


type alias SurfaceMarkerId_ =
    Int


type TriangleEdge
    = SideOne
    | SideTwo
    | SideThree



--nearestSurfacePoint : Point3d unit coordinates -> Mesh unit coordinates -> TriangleId
--nearestSurfacePoint point mesh =
--    getTriangles mesh


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
getTriangle (Mesh mesh) (TriangleId triangleId) =
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
    { triangleId : TriangleId_, flipped : Bool }


edgeToInt edge =
    case edge of
        SideOne ->
            0

        SideTwo ->
            1

        SideThree ->
            2


intToEdge index =
    case index of
        0 ->
            SideOne

        1 ->
            SideTwo

        _ ->
            SideThree


adjacentTriangle : TriangleId -> TriangleEdge -> Mesh units coordinates -> Maybe ( TriangleId, TriangleEdge )
adjacentTriangle (TriangleId triangleId) edge (Mesh mesh) =
    Dict.get ( triangleId, edgeToInt edge ) mesh.adjacentTriangles


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
