module Mesh exposing
    ( Error(..)
    , Mesh
    , SurfacePoint
    , fromVerticesAndIndices
    , getAdjacentTriangle
    , getTriangleData
    , getTriangleEdgeFrame
    , getVertices
    , move
    , nearestSurfacePoint
    , surfacePointToWorld
    , surfacePointTriangleId
    )

import Array exposing (Array)
import Basics.Extra exposing (flip)
import Dict exposing (Dict)
import Direction2d exposing (Direction2d)
import Frame2d exposing (Frame2d)
import Interpolative exposing (Interpolative)
import LineSegment2d
import List.Extra as List
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Point3dEx
import Quantity
import SketchPlane3d exposing (SketchPlane3d)
import Triangle exposing (Triangle)
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)
import TriangleEdge exposing (TriangleEdge)
import Vector2d exposing (Vector2d)


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias TriangleData units coordinates =
    { indices : Triangle VertexId
    , sketchPlane : SketchPlane3d units coordinates { defines : SurfaceCoordinates }
    , triangle2d : Triangle2d units SurfaceCoordinates
    }


triangleDataGetTriangle3d : TriangleData units coordinates -> Triangle3d units coordinates
triangleDataGetTriangle3d { sketchPlane, triangle2d } =
    Triangle3d.on sketchPlane triangle2d


type alias Mesh_ units coordinates =
    { triangles : Array (TriangleData units coordinates)
    , vertices : Array (Point3d units coordinates)
    , adjacentTriangles : Dict ( TriangleId_, EdgeIndex_ ) ( TriangleId, TriangleEdge )
    }


getTriangles : Mesh units coordinates -> Array (TriangleData units coordinates)
getTriangles (Mesh mesh) =
    mesh.triangles


getVertices : Mesh units coordinates -> Array (Point3d units coordinates)
getVertices (Mesh mesh) =
    mesh.vertices


getAdjacentTriangles : Mesh units coordinates -> Dict ( TriangleId_, Int ) ( TriangleId, TriangleEdge )
getAdjacentTriangles (Mesh mesh) =
    mesh.adjacentTriangles


type Error
    = EdgeSharedBy3OrMoreTriangles
    | TriangleIsDegenerate
    | TriangleVertexNotFound



--generateTriangleData : Array (Point3d units coordinates) -> List (Triangle VertexId_) -> Result Error (TriangleData units coordinates)


generateTriangleData vertices triangles =
    triangles
        |> List.foldl
            (\indices state ->
                case state of
                    Ok triangleData_ ->
                        case Triangle.andThen (flip Array.get vertices) indices of
                            Just ( v0, v1, v2 ) ->
                                case SketchPlane3d.throughPoints v0 v1 v2 of
                                    Just sketchPlane ->
                                        { indices = Triangle.map VertexId indices
                                        , sketchPlane = sketchPlane
                                        , triangle2d = Triangle3d.from v0 v1 v2 |> Triangle3d.projectInto sketchPlane
                                        }
                                            :: triangleData_
                                            |> Ok

                                    Nothing ->
                                        Err TriangleIsDegenerate

                            Nothing ->
                                Err TriangleVertexNotFound

                    Err _ ->
                        state
            )
            (Ok [])


fromVerticesAndIndices : Array (Point3d units coordinates) -> List (Triangle VertexId_) -> Result Error (Mesh units coordinates)
fromVerticesAndIndices vertices triangles =
    case generateTriangleData vertices triangles of
        Ok triangleData ->
            let
                orderTuple ( a, b ) =
                    if a < b then
                        ( a, b )

                    else
                        ( b, a )

                adjacentTrianglePairs =
                    triangles
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
                                        [ ( ( triIndex, edgeIndex ), ( TriangleId other.triIndex, TriangleEdge.toEdge other.edgeIndex ) )
                                        , ( ( other.triIndex, other.edgeIndex ), ( TriangleId triIndex, TriangleEdge.toEdge edgeIndex ) )
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
                    { triangles = Array.fromList triangleData
                    , vertices = vertices
                    , adjacentTriangles = Dict.fromList list
                    }
                        |> Mesh
                        |> Ok

                Nothing ->
                    Err EdgeSharedBy3OrMoreTriangles

        Err error ->
            Err error


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


allTriangleIds (Mesh mesh) =
    Array.length mesh.triangles - 1


nearestSurfacePoint : Point3d unit coordinates -> Mesh unit coordinates -> SurfacePoint unit
nearestSurfacePoint point mesh =
    allTriangleIds mesh
        |> List.range 0
        |> List.filterMap
            (\triangleId ->
                TriangleId triangleId
                    |> flip getTriangleData mesh
                    |> Maybe.map
                        (\triangleData ->
                            { triangleId = TriangleId triangleId
                            , nearestPoint = Point3dEx.nearestPointOnTriangle (triangleDataGetTriangle3d triangleData) point
                            }
                        )
            )
        |> List.minimumBy (.nearestPoint >> Point3d.distanceFrom point >> rawQuantity)
        |> Maybe.map
            (\{ triangleId, nearestPoint } ->
                SurfacePoint
                    { triangleId = triangleId
                    , position =
                        case getTriangleData triangleId mesh of
                            Just triangleData ->
                                Point3d.projectInto triangleData.sketchPlane nearestPoint |> Interpolative.fromPoint2d triangleData.triangle2d

                            _ ->
                                Debug.todo "Handle degenerate case"
                    , direction = Direction2d.x
                    , faceSide = Front
                    }
            )
        |> Maybe.withDefault
            (SurfacePoint
                { triangleId = TriangleId -1
                , position = Interpolative.from 0 0
                , direction = Direction2d.x
                , faceSide = Front
                }
            )


surfacePointToWorld : SurfacePoint unit -> Mesh unit coordinates -> Maybe (Point3d unit coordinates)
surfacePointToWorld (SurfacePoint surfacePoint) mesh =
    case getTriangleData surfacePoint.triangleId mesh of
        Just triangleData ->
            Interpolative.toPoint3d (triangleDataGetTriangle3d triangleData) surfacePoint.position |> Just

        Nothing ->
            Nothing


rawQuantity (Quantity.Quantity value) =
    value


getTriangleData : TriangleId -> Mesh units coordinates -> Maybe (TriangleData units coordinates)
getTriangleData (TriangleId triangleId) (Mesh mesh) =
    Array.get triangleId mesh.triangles


getVertex : VertexId -> Mesh units coordinates -> Maybe (Point3d units coordinates)
getVertex (VertexId vertexId) (Mesh mesh) =
    Array.get vertexId mesh.vertices


type alias AdjacentTriangle =
    { triangleId : TriangleId_, flipped : Bool }


type SurfacePoint units
    = SurfacePoint SurfacePoint_


type alias SurfacePoint_ =
    { triangleId : TriangleId
    , position : Interpolative
    , direction : Direction2d SurfaceCoordinates
    , faceSide : SurfaceSide
    }


surfacePointTriangleId : SurfacePoint units -> TriangleId
surfacePointTriangleId (SurfacePoint surfacePoint) =
    surfacePoint.triangleId


type SurfaceSide
    = Front
    | Back


type SurfaceCoordinates
    = SurfaceCoordinates Never


type AdjacentSurfaceCoordinates
    = AdjacentSurfaceCoordinates Never


getTriangleEdgeFrame :
    Mesh units coordinates
    -> TriangleId
    -> TriangleEdge
    -> Maybe (Frame2d units SurfaceCoordinates { defines : AdjacentSurfaceCoordinates })
getTriangleEdgeFrame mesh triangleId triangleSide =
    case ( getTriangleData triangleId mesh, getAdjacentTriangle mesh ( triangleId, triangleSide ) ) of
        ( Just triangleData, Just adjacentTriangleData ) ->
            let
                ( e0, e1 ) =
                    triangleData.triangle2d
                        |> Triangle.fromTriangle2d
                        |> Triangle.getSide triangleSide

                ( ae0, ae1 ) =
                    adjacentTriangleData.triangleData.triangle2d
                        |> Triangle.fromTriangle2d
                        |> Triangle.getSide adjacentTriangleData.side

                eAngle =
                    Direction2d.from e0 e1 |> Maybe.withDefault Direction2d.x

                aeAngle =
                    Direction2d.from ae0 ae1 |> Maybe.withDefault Direction2d.x

                angleDiff =
                    Direction2d.angleFrom eAngle aeAngle

                --adjacentEdge =
                --    Triangle.getSide adjacentTriangleData.side adjacentTriangle2d
            in
            if adjacentTriangleData.isEdgeReversed then
                Frame2d.atOrigin
                    |> Frame2d.rotateBy angleDiff
                    |> Frame2d.translateBy (Vector2d.from e0 ae0)
                    |> Just

            else
                Frame2d.atOrigin
                    |> Frame2d.rotateBy angleDiff
                    |> Frame2d.translateBy (Vector2d.from e0 ae0)
                    |> Just

        _ ->
            Nothing


move : Mesh units coordinates -> Vector2d units SurfaceCoordinates -> SurfacePoint units -> SurfacePoint units
move mesh movement (SurfacePoint ({ triangleId, position } as surfacePoint)) =
    case getTriangleData triangleId mesh of
        Just triangleData ->
            let
                ( e0, e1, e2 ) =
                    Triangle2d.edges triangleData.triangle2d

                point =
                    Interpolative.toPoint2d triangleData.triangle2d position

                endPoint =
                    Point2d.translateBy movement point

                moveLine =
                    LineSegment2d.from point endPoint

                intersection =
                    [ e0, e1, e2 ]
                        |> List.indexedMap Tuple.pair
                        |> List.filterMap
                            (\( index, edge ) ->
                                LineSegment2d.intersectionPoint moveLine edge
                                    |> Maybe.map
                                        (\intersectionPoint ->
                                            { edge = edge
                                            , sideIndex = TriangleEdge.toEdge index
                                            , intersectionPoint = intersectionPoint
                                            }
                                        )
                            )
                        {- We want the maximum (not minimum) distance intersection because if we ever end up with two intersections,
                           the nearest one is due to our starting position lying on the triangle edge
                        -}
                        |> List.maximumBy (.intersectionPoint >> Point2d.distanceFrom point >> rawQuantity)
            in
            case intersection of
                Just { edge, sideIndex, intersectionPoint } ->
                    case getAdjacentTriangle mesh ( triangleId, sideIndex ) of
                        Just adjacentTriangle ->
                            let
                                t =
                                    Quantity.ratio
                                        (Point2d.distanceFrom intersectionPoint point)
                                        (LineSegment2d.length edge)

                                --movementLeft =
                                --    Quantity.ratio
                                --        (Point2d.distanceFrom intersectionPoint point)
                                --        (Vector2d.length movement)
                                --        |> (-) 1
                                --        |> flip Vector2d.scaleBy movement
                                newSurfacePosition =
                                    Interpolative.fromTriangleSide
                                        (if adjacentTriangle.isEdgeReversed then
                                            1 - t

                                         else
                                            t
                                        )
                                        adjacentTriangle.side

                                --endPointOnAdjacentTriangle =
                                --    getSketchPlane
                                newSurfacePoint =
                                    SurfacePoint
                                        { triangleId = adjacentTriangle.triangleId
                                        , position = newSurfacePosition
                                        , direction = Direction2d.x
                                        , faceSide = Front
                                        }
                            in
                            move mesh Vector2d.zero newSurfacePoint

                        Nothing ->
                            SurfacePoint
                                { triangleId = triangleId
                                , position = Interpolative.fromPoint2d triangleData.triangle2d intersectionPoint
                                , direction = Direction2d.x
                                , faceSide = Front
                                }

                Nothing ->
                    SurfacePoint
                        { surfacePoint
                            | triangleId = triangleId
                            , position = Interpolative.fromPoint2d triangleData.triangle2d endPoint
                        }

        Nothing ->
            SurfacePoint surfacePoint


getAdjacentTriangle :
    Mesh units coordinates
    -> ( TriangleId, TriangleEdge )
    ->
        Maybe
            { triangleId : TriangleId
            , triangleData : TriangleData units coordinates
            , side : TriangleEdge
            , isEdgeReversed : Bool
            }
getAdjacentTriangle mesh ( TriangleId triangleId, side ) =
    getAdjacentTriangles mesh
        |> Dict.get ( triangleId, TriangleEdge.toInt side )
        |> Maybe.andThen
            (\( adjacentTriangleId, adjacentSide ) ->
                Maybe.map2
                    (\triangleData adjacentTriangleData ->
                        let
                            triangleSide =
                                Triangle.getSide side triangleData.indices

                            adjacentTriangleSide =
                                Triangle.getSide adjacentSide adjacentTriangleData.indices
                        in
                        { triangleId = adjacentTriangleId
                        , triangleData = adjacentTriangleData
                        , side = adjacentSide
                        , isEdgeReversed = triangleSide /= adjacentTriangleSide
                        }
                    )
                    (getTriangleData (TriangleId triangleId) mesh)
                    (getTriangleData adjacentTriangleId mesh)
            )
