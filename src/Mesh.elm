module Mesh exposing
    ( Error(..)
    , Mesh
    , SurfacePoint
    , fromVerticesAndIndices
    , getAdjacentTriangle
    , getTriangle
    , getTriangles
    , getVertices
    , nearestSurfacePoint
    , surfacePointToWorld
    )

import Array exposing (Array)
import Basics.Extra exposing (flip)
import Dict exposing (Dict)
import Direction2d
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
import TriangleSide exposing (TriangleSide)
import Vector2d exposing (Vector2d)


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias Mesh_ units coordinates =
    { triangles : Array (Triangle VertexId)
    , vertices : Array (Point3d units coordinates)
    , adjacentTriangles : Dict ( TriangleId_, EdgeIndex_ ) ( TriangleId, TriangleSide )
    }


getTriangles : Mesh units coordinates -> Array (Triangle VertexId)
getTriangles (Mesh mesh) =
    mesh.triangles


getVertices : Mesh units coordinates -> Array (Point3d units coordinates)
getVertices (Mesh mesh) =
    mesh.vertices


getAdjacentTriangles : Mesh units coordinates -> Dict ( TriangleId_, Int ) ( TriangleId, TriangleSide )
getAdjacentTriangles (Mesh mesh) =
    mesh.adjacentTriangles


type Error
    = EdgeSharedBy3OrMoreTriangles
    | TriangleVerticesNotUnique
    | OneOrMoreInvalidTriangles
    | TriangleVertexNotFound


fromVerticesAndIndices : Array (Point3d units coordinates) -> List (Triangle VertexId_) -> Result Error (Mesh units coordinates)
fromVerticesAndIndices vertices triangles =
    let
        triangleVertexNotFound =
            triangles
                |> List.all
                    (\tri -> Triangle.andThen (\index -> Array.get index vertices) tri /= Nothing)
                |> not

        triangleVerticesNotUnique =
            triangles
                |> List.all Triangle.hasUniqueVertices
                |> not
    in
    if triangleVertexNotFound then
        Err TriangleVertexNotFound

    else if triangleVerticesNotUnique then
        Err TriangleVerticesNotUnique

    else
        case List.head triangles of
            Just _ ->
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
                                            [ ( ( triIndex, edgeIndex ), ( TriangleId other.triIndex, TriangleSide.toEdge other.edgeIndex ) )
                                            , ( ( other.triIndex, other.edgeIndex ), ( TriangleId triIndex, TriangleSide.toEdge edgeIndex ) )
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
                        { triangles = triangles |> List.map (Triangle.map VertexId) |> Array.fromList
                        , vertices = vertices
                        , adjacentTriangles = Dict.fromList list
                        }
                            |> Mesh
                            |> Ok

                    Nothing ->
                        Err EdgeSharedBy3OrMoreTriangles

            Nothing ->
                Err OneOrMoreInvalidTriangles


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


getTriangle : Mesh units coordinates -> TriangleId -> Maybe (Triangle3d units coordinates)
getTriangle mesh triangleId =
    getTriangleVertices triangleId mesh
        |> Maybe.andThen
            (\( v0, v1, v2 ) ->
                Maybe.map3
                    (\v0_ v1_ v2_ -> Triangle3d.fromVertices ( v0_, v1_, v2_ ))
                    (getVertex v0 mesh)
                    (getVertex v1 mesh)
                    (getVertex v2 mesh)
            )


getTriangleVertices : TriangleId -> Mesh units coordinates -> Maybe (Triangle VertexId)
getTriangleVertices (TriangleId triangleId) (Mesh mesh) =
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
    }


type SurfaceSide
    = Front
    | Back


type SurfaceCoordinates
    = SurfaceCoordinates Never


type AdjacentSurfaceCoordinates
    = AdjacentSurfaceCoordinates Never


getSketchPlane :
    Mesh units coordinates
    -> TriangleId
    -> Maybe ( Triangle3d units coordinates, SketchPlane3d units coordinates { defines : SurfaceCoordinates } )
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


getTriangleEdgeFrame :
    Mesh units coordinates
    -> TriangleId
    -> TriangleSide
    -> Maybe (Frame2d units SurfaceCoordinates { defines : AdjacentSurfaceCoordinates })
getTriangleEdgeFrame mesh triangleId triangleSide =
    case ( getAdjacentTriangle mesh ( triangleId, triangleSide ), getSketchPlane mesh triangleId ) of
        ( Just adjacentTriangleData, Just ( triangle, sketchPlane ) ) ->
            case getSketchPlane mesh adjacentTriangleData.triangleId of
                Just ( adjacentTriangle, adjacentSketchPlane ) ->
                    let
                        ( e0, e1 ) =
                            Triangle3d.projectInto sketchPlane triangle
                                |> Triangle.fromTriangle2d
                                |> Triangle.getSide triangleSide

                        ( ae0, ae1 ) =
                            Triangle3d.projectInto adjacentSketchPlane adjacentTriangle
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
                        Debug.todo "Handle isEdgeReversed case"

                    else
                        Frame2d.atOrigin
                            |> Frame2d.rotateBy angleDiff
                            |> Frame2d.translateBy (Vector2d.from e0 ae0)
                            |> Just

                Nothing ->
                    Nothing

        _ ->
            Nothing


move : Mesh units coordinates -> Vector2d units SurfaceCoordinates -> SurfacePoint units -> SurfacePoint units
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

                intersection =
                    [ e0, e1, e2 ]
                        |> List.indexedMap Tuple.pair
                        |> List.filterMap
                            (\( index, edge ) ->
                                LineSegment2d.intersectionPoint moveLine edge
                                    |> Maybe.map
                                        (\intersectionPoint ->
                                            { edge = edge
                                            , sideIndex = TriangleSide.toEdge index
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
                            case getSketchPlane mesh adjacentTriangle.triangleId of
                                Just adjacentSketchPlane ->
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

                                        endPointOnAdjacentTriangle =
                                            getSketchPlane

                                        newSurfacePoint =
                                            SurfacePoint
                                                { triangleId = adjacentTriangle.triangleId
                                                , position = newSurfacePosition
                                                }
                                    in
                                    move mesh Vector2d.zero newSurfacePoint

                                Nothing ->
                                    SurfacePoint
                                        { triangleId = triangleId
                                        , position = Interpolative.fromPoint2d triangle2d intersectionPoint
                                        }

                        Nothing ->
                            SurfacePoint
                                { triangleId = triangleId
                                , position = Interpolative.fromPoint2d triangle2d intersectionPoint
                                }

                Nothing ->
                    SurfacePoint { triangleId = triangleId, position = Interpolative.fromPoint2d triangle2d endPoint }

        Nothing ->
            surfacePoint


getAdjacentTriangle :
    Mesh units coordinates
    -> ( TriangleId, TriangleSide )
    -> Maybe { triangleId : TriangleId, side : TriangleSide, isEdgeReversed : Bool }
getAdjacentTriangle mesh ( TriangleId triangleId, side ) =
    getAdjacentTriangles mesh
        |> Dict.get ( triangleId, TriangleSide.toInt side )
        |> Maybe.andThen
            (\( adjacentTriangleId, adjacentSide ) ->
                Maybe.map2
                    (\triangleSide adjacentTriangleSide ->
                        { triangleId = adjacentTriangleId
                        , side = adjacentSide
                        , isEdgeReversed = triangleSide /= adjacentTriangleSide
                        }
                    )
                    (getTriangleVertices (TriangleId triangleId) mesh |> Maybe.map (Triangle.getSide side))
                    (getTriangleVertices adjacentTriangleId mesh |> Maybe.map (Triangle.getSide side))
            )
