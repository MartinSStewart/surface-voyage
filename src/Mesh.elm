module Mesh exposing
    ( Error(..)
    , Mesh
    , SurfacePoint
    , adjacentTriangle
    , fromVerticesAndIndices
    , getAdjacentTriangles
    , getTriangle
    , getTriangles
    , getVertices
    , nearestSurfacePoint
    , surfacePointToWorld
    )

import Array exposing (Array)
import Basics.Extra exposing (flip)
import Dict exposing (Dict)
import Interpolative exposing (Interpolative)
import LineSegment2d
import LineSegment3d exposing (LineSegment3d)
import List.Extra as List
import Point2d exposing (Point2d)
import Point2dEx
import Point3d exposing (Point3d)
import Point3dEx
import Quantity
import SketchPlane3d exposing (SketchPlane3d)
import Triangle exposing (Triangle)
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)
import Vector2d exposing (Vector2d)


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias Mesh_ units coordinates =
    { triangles : Array (Triangle VertexId)
    , vertices : Array (Point3d units coordinates)
    , adjacentTriangles : Dict ( TriangleId_, EdgeIndex_ ) ( TriangleId, TriangleEdge )
    }


getTriangles : Mesh units coordinates -> Array (Triangle VertexId)
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
    | NoValidTriangles
    | TriangleVertexNotFound


fromVerticesAndIndices : Array (Point3d units coordinates) -> List (Triangle VertexId_) -> Result Error (Mesh units coordinates)
fromVerticesAndIndices vertices triangleIndices =
    let
        validTriangles =
            triangleIndices
                |> List.all
                    (\tri -> Triangle.andThen (\index -> Array.get index vertices) tri /= Nothing)
    in
    if validTriangles then
        case List.head triangleIndices of
            Just _ ->
                let
                    orderTuple ( a, b ) =
                        if a < b then
                            ( a, b )

                        else
                            ( b, a )

                    adjacentTrianglePairs =
                        triangleIndices
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
                        { triangles = triangleIndices |> List.map (Triangle.map VertexId) |> Array.fromList
                        , vertices = vertices
                        , adjacentTriangles = Dict.fromList list
                        }
                            |> Mesh
                            |> Ok

                    Nothing ->
                        Err NonManifold

            Nothing ->
                Err NoValidTriangles

    else
        Err TriangleVertexNotFound


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


allTriangleIds (Mesh mesh) =
    Array.length mesh.triangles - 1


nearestSurfacePoint : Point3d unit coordinates -> Mesh unit coordinates -> SurfacePoint unit
nearestSurfacePoint point mesh =
    allTriangleIds mesh
        |> List.range 0
        |> List.filterMap
            (\triangleId ->
                TriangleId triangleId
                    |> getTriangle mesh
                    |> Maybe.map
                        (\triangle ->
                            { triangleId = TriangleId triangleId
                            , nearestPoint = Point3dEx.nearestPointOnTriangle triangle point
                            }
                        )
            )
        |> List.minimumBy (.nearestPoint >> Point3d.distanceFrom point >> rawQuantity)
        |> Maybe.map
            (\{ triangleId, nearestPoint } ->
                SurfacePoint
                    { triangleId = triangleId
                    , position =
                        case getSketchPlane mesh triangleId of
                            Just ( triangle, sketchPlane ) ->
                                let
                                    triangle2d =
                                        Triangle3d.projectInto sketchPlane triangle
                                in
                                Point3d.projectInto sketchPlane nearestPoint |> Interpolative.fromPoint2d triangle2d

                            _ ->
                                Debug.todo "Handle degenerate case"
                    }
            )
        |> Maybe.withDefault (SurfacePoint { triangleId = TriangleId 0, position = Interpolative.from 0 0 })


surfacePointToWorld : SurfacePoint unit -> Mesh unit coordinates -> Maybe (Point3d unit coordinates)
surfacePointToWorld (SurfacePoint surfacePoint) mesh =
    case getTriangle mesh surfacePoint.triangleId of
        Just triangle ->
            Interpolative.toPoint3d triangle surfacePoint.position |> Just

        Nothing ->
            Nothing


rawQuantity (Quantity.Quantity value) =
    value


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
            (\( VertexId v0, VertexId v1, VertexId v2 ) ->
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


type SurfacePoint units
    = SurfacePoint SurfacePoint_


type alias SurfacePoint_ =
    { triangleId : TriangleId
    , position : Interpolative
    }


type SurfaceSide
    = Front
    | Back


type MeshSurfaceCoordinates
    = MeshSurfaceCoordinates Never


getSketchPlane :
    Mesh units coordinates
    -> TriangleId
    -> Maybe ( Triangle3d units coordinates, SketchPlane3d units coordinates { defines : MeshSurfaceCoordinates } )
getSketchPlane mesh triangleId =
    getTriangle mesh triangleId
        |> Maybe.andThen
            (\triangle ->
                let
                    ( first, second, third ) =
                        Triangle3d.vertices triangle
                in
                SketchPlane3d.throughPoints first second third |> Maybe.map (Tuple.pair triangle)
            )


move : Mesh units coordinates -> Vector2d units MeshSurfaceCoordinates -> SurfacePoint units -> SurfacePoint units
move mesh movement ((SurfacePoint { triangleId, position }) as surfacePoint) =
    case getSketchPlane mesh triangleId of
        Just ( triangle, sketchPlane ) ->
            let
                triangle2d =
                    Triangle3d.projectInto sketchPlane triangle

                ( e0, e1, e2 ) =
                    Triangle2d.edges triangle2d

                point =
                    Interpolative.toPoint2d triangle2d position

                endPoint =
                    Point2d.translateBy movement point

                moveLine =
                    LineSegment2d.from point endPoint

                intersections =
                    [ e0, e1, e2 ]
                        |> List.indexedMap Tuple.pair
                        |> List.filterMap (\( index, edge ) -> LineSegment2d.intersectionPoint moveLine edge |> Maybe.map Tuple.pair index)
                        |> List.minimumBy
                            (\index intersection ->
                                0
                            )
            in
            if Point2dEx.insideTriangle triangle endPoint then
                SurfacePoint { triangleId = triangleId, position = Interpolative.fromPoint2d triangle2d endPoint }

            else
                let
                    ( e0, e1, e2 ) =
                        Triangle2d.edges triangle

                    moveLine =
                        LineSegment2d.from position newPosition
                in
                0

        Nothing ->
            surfacePoint
