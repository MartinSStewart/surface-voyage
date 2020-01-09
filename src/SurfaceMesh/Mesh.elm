module SurfaceMesh.Mesh exposing
    ( Error(..)
    , Mesh
    , TriangleId
    , defaultMesh
    , errorToString
    , fromVerticesAndIndices
    , getAdjacentTriangle
    , getAdjacentTriangle_
    , getTriangleData
    , getTriangleEdgeFrame
    , getTriangleEdgeFrame_
    , getVertices
    , move
    , nearestSurfacePoint
    )

import Angle exposing (Angle)
import Array exposing (Array)
import Axis2d
import Basics.Extra exposing (flip)
import Dict exposing (Dict)
import Direction2d exposing (Direction2d)
import Frame2d exposing (Frame2d)
import LineSegment2d
import List.Extra as List
import List.Nonempty as Nonempty
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Point3dEx
import Quantity exposing (Quantity)
import SketchPlane3d exposing (SketchPlane3d)
import SurfaceMesh.Interpolative as Interpolative exposing (Interpolative)
import SurfaceMesh.Triangle as Triangle exposing (Triangle)
import SurfaceMesh.TriangleData as TriangleData
import SurfaceMesh.TriangleEdge as TriangleEdge exposing (TriangleEdge)
import SurfaceMesh.TriangleVertex as TriangleVertex
import SurfaceMesh.Types as Types exposing (VertexId(..))
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)
import Vector2d exposing (Vector2d)


type alias Mesh units coordinates =
    Types.Mesh units coordinates


type alias TriangleId =
    Types.TriangleId


getTriangles : Mesh units coordinates -> Array (Types.TriangleData units coordinates)
getTriangles (Types.Mesh mesh) =
    mesh.triangles


getVertices : Mesh units coordinates -> Array (Point3d units coordinates)
getVertices (Types.Mesh mesh) =
    mesh.vertices


getTriangleData : Types.TriangleId -> Types.Mesh units coordinates -> Maybe (Types.TriangleData units coordinates)
getTriangleData =
    Types.getTriangleData


type Error
    = EdgeSharedBy3OrMoreTriangles
    | TriangleIsDegenerate
    | TriangleVertexNotFound


errorToString : Error -> String
errorToString error =
    case error of
        EdgeSharedBy3OrMoreTriangles ->
            "An edge is shared by 3 or more triangles"

        TriangleIsDegenerate ->
            "Triange is degenerate"

        TriangleVertexNotFound ->
            "Triangle vertex is not found"


generateTriangleData :
    Array (Point3d units coordinates)
    -> List (Triangle Types.VertexId_)
    -> Result Error (List (Types.TriangleData units coordinates))
generateTriangleData vertices triangles =
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

        adjacentTriangles : Maybe (Dict ( Types.TriangleId_, Types.VertexId_ ) Types.AdjacentTriangle)
        adjacentTriangles =
            adjacentTrianglePairs
                |> List.foldl
                    (\( { edgeIndex, triIndex }, rest ) state ->
                        case ( rest, state ) of
                            ( [], Just list ) ->
                                Just list

                            ( other :: [], Just list ) ->
                                [ ( ( triIndex, edgeIndex )
                                  , { adjacentId = Types.TriangleId other.triIndex, adjacentEdge = TriangleEdge.fromInt other.edgeIndex }
                                  )
                                , ( ( other.triIndex, other.edgeIndex )
                                  , { adjacentId = Types.TriangleId triIndex, adjacentEdge = TriangleEdge.fromInt edgeIndex }
                                  )
                                ]
                                    ++ list
                                    |> Just

                            _ ->
                                Nothing
                    )
                    (Just [])
                |> Maybe.map Dict.fromList
    in
    case adjacentTriangles of
        Just adjacentTriangles_ ->
            triangles
                |> List.indexedMap Tuple.pair
                |> List.foldr
                    (\( triangleId, indices ) state ->
                        case state of
                            Ok triangleData_ ->
                                case Triangle.andThen (flip Array.get vertices) indices of
                                    Just ( v0, v1, v2 ) ->
                                        case SketchPlane3d.throughPoints v0 v1 v2 of
                                            Just sketchPlane ->
                                                { indices = Triangle.map Types.VertexId indices
                                                , sketchPlane = sketchPlane
                                                , triangle2d = Triangle3d.from v0 v1 v2 |> Triangle3d.projectInto sketchPlane
                                                , adjacent =
                                                    Triangle.from
                                                        (Dict.get ( triangleId, 0 ) adjacentTriangles_)
                                                        (Dict.get ( triangleId, 1 ) adjacentTriangles_)
                                                        (Dict.get ( triangleId, 2 ) adjacentTriangles_)
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

        Nothing ->
            Err
                EdgeSharedBy3OrMoreTriangles


fromVerticesAndIndices : Array (Point3d units coordinates) -> List (Triangle Types.VertexId_) -> Result Error (Mesh units coordinates)
fromVerticesAndIndices vertices triangles =
    case generateTriangleData vertices triangles of
        Ok triangleData ->
            { triangles = Array.fromList triangleData
            , vertices = vertices
            }
                |> Types.Mesh
                |> Ok

        Err error ->
            Err error


defaultMesh : Types.Mesh units coordinates
defaultMesh =
    { triangles =
        Array.fromList
            [ { indices = Triangle.from (VertexId 0) (VertexId 1) (VertexId 2)
              , sketchPlane = SketchPlane3d.xy
              , triangle2d =
                    Triangle2d.from
                        (Point2d.unsafe { x = 0, y = 0 })
                        (Point2d.unsafe { x = 1, y = 0 })
                        (Point2d.unsafe { x = 0, y = 1 })
              , adjacent = Triangle.from Nothing Nothing Nothing
              }
            ]
    , vertices =
        Array.fromList
            [ Point3d.unsafe { x = 0, y = 0, z = 0 }
            , Point3d.unsafe { x = 1, y = 0, z = 0 }
            , Point3d.unsafe { x = 0, y = 1, z = 0 }
            ]
    }
        |> Types.Mesh


allTriangleIds (Types.Mesh mesh) =
    Array.length mesh.triangles - 1


nearestSurfacePoint : Point3d unit coordinates -> Mesh unit coordinates -> Types.SurfacePoint unit
nearestSurfacePoint point mesh =
    let
        thisShouldNeverHappenDefaultValue =
            Types.SurfacePoint
                { triangleId = Types.TriangleId -1
                , position = Interpolative.from 0 0
                , direction = Direction2d.x
                , faceSide = Types.Front
                }
    in
    allTriangleIds mesh
        |> List.range 0
        |> List.filterMap
            (\triangleId ->
                Types.TriangleId triangleId
                    |> flip Types.getTriangleData mesh
                    |> Maybe.map
                        (\triangleData ->
                            { triangleId = Types.TriangleId triangleId
                            , nearestPoint = Point3dEx.nearestPointOnTriangle (TriangleData.worldTriangle triangleData) point
                            }
                        )
            )
        |> List.minimumBy (.nearestPoint >> Point3d.distanceFrom point >> rawQuantity)
        |> Maybe.map
            (\{ triangleId, nearestPoint } ->
                Types.SurfacePoint
                    { triangleId = triangleId
                    , position =
                        case Types.getTriangleData triangleId mesh of
                            Just triangleData ->
                                Point3d.projectInto triangleData.sketchPlane nearestPoint |> Interpolative.fromPoint2d triangleData.triangle2d

                            _ ->
                                Interpolative.from 0 0
                    , direction = Direction2d.x
                    , faceSide = Types.Front
                    }
            )
        |> Maybe.withDefault thisShouldNeverHappenDefaultValue


rawQuantity (Quantity.Quantity value) =
    value


getVertex : Types.VertexId -> Mesh units coordinates -> Maybe (Point3d units coordinates)
getVertex (Types.VertexId vertexId) (Types.Mesh mesh) =
    Array.get vertexId mesh.vertices


getTriangleEdgeFrame :
    Mesh units coordinates
    -> Types.TriangleId
    -> TriangleEdge
    -> Maybe (Frame2d units Types.SurfaceCoordinate { defines : Types.SurfaceCoordinate })
getTriangleEdgeFrame mesh triangleId triangleSide =
    case ( Types.getTriangleData triangleId mesh, getAdjacentTriangle mesh triangleId triangleSide ) of
        ( Just triangleData, Just adjacentTriangleData ) ->
            getTriangleEdgeFrame_ triangleSide triangleData adjacentTriangleData |> Just

        _ ->
            Nothing


getTriangleEdgeFrame_ :
    TriangleEdge
    -> Types.TriangleData units coordinates
    -> AdjacentTriangleData units coordinates
    -> Frame2d units Types.SurfaceCoordinate { defines : Types.SurfaceCoordinate }
getTriangleEdgeFrame_ triangleSide triangleData adjacentTriangleData =
    let
        ( e0, e1 ) =
            triangleData.triangle2d
                |> Triangle.fromTriangle2d
                |> Triangle.getSide triangleSide

        axis =
            Axis2d.through e0 (Direction2d.from e0 e1 |> Maybe.withDefault Direction2d.x)

        ( ae0, ae1 ) =
            adjacentTriangleData.triangleData.triangle2d
                |> Triangle.fromTriangle2d
                |> Triangle.getSide adjacentTriangleData.side
                |> (\( a, b ) ->
                        if adjacentTriangleData.isEdgeReversed then
                            ( b, a )

                        else
                            ( a, b )
                   )

        eAngle =
            Direction2d.from e0 e1 |> Maybe.withDefault Direction2d.y

        aeAngle =
            Direction2d.from ae0 ae1 |> Maybe.withDefault Direction2d.y

        angleDiff =
            Direction2d.angleFrom aeAngle eAngle
    in
    if adjacentTriangleData.isEdgeReversed then
        Frame2d.atOrigin
            --|> Frame2d.rotateBy angleDiff
            --(Quantity.plus angleDiff (Angle.radians pi))
            |> Frame2d.translateBy (Vector2d.from ae0 e0)
            |> Frame2d.rotateAround e0 angleDiff
        --|> Frame2d.mirrorAcross axis

    else
        Frame2d.atOrigin
            |> Frame2d.rotateBy angleDiff
            |> Frame2d.translateBy (Vector2d.from ae0 e0)
            |> Frame2d.mirrorAcross axis


move :
    Mesh units coordinates
    -> Angle
    -> Quantity Float units
    -> Types.SurfacePoint units
    -> Maybe (Types.Path units coordinates)
move mesh rotationOffset distance surfacePoint =
    case moveHelper mesh rotationOffset distance surfacePoint [] of
        Just path ->
            Types.Path path |> Just

        Nothing ->
            Nothing


moveHelper :
    Mesh units coordinates
    -> Angle
    -> Quantity Float units
    -> Types.SurfacePoint units
    -> List ( Types.SurfacePoint units, Types.SurfacePoint units )
    -> Maybe (Nonempty.Nonempty ( Types.SurfacePoint units, Types.SurfacePoint units ))
moveHelper mesh rotationOffset distance surfacePoint path =
    let
        (Types.SurfacePoint ({ triangleId, position, direction, faceSide } as surfacePoint_)) =
            surfacePoint
    in
    case Types.getTriangleData triangleId mesh of
        Just triangleData ->
            let
                ( e0, e1, e2 ) =
                    triangleData.triangle2d |> Triangle2d.edges

                point =
                    Interpolative.toPoint2d triangleData.triangle2d position

                endPoint =
                    Point2d.translateIn (Direction2d.rotateBy rotationOffset direction) distance point

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
                                            , sideIndex = TriangleEdge.fromInt index
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
                    case getAdjacentTriangle_ mesh triangleData sideIndex of
                        Just adjacentTriangle ->
                            let
                                t =
                                    Quantity.ratio
                                        (Point2d.distanceFrom intersectionPoint (LineSegment2d.startPoint edge))
                                        (LineSegment2d.length edge)

                                intersectionPoint3d =
                                    intersectionPoint |> Point3d.on triangleData.sketchPlane

                                frame =
                                    getTriangleEdgeFrame_ sideIndex triangleData adjacentTriangle

                                newSurfacePosition0 =
                                    Interpolative.fromTriangleSide t adjacentTriangle.side

                                newSurfacePosition1 =
                                    Interpolative.fromTriangleSide (1 - t) adjacentTriangle.side

                                b =
                                    newSurfacePosition0 |> Interpolative.toPoint3d (TriangleData.worldTriangle adjacentTriangle.triangleData)

                                c =
                                    newSurfacePosition1 |> Interpolative.toPoint3d (TriangleData.worldTriangle adjacentTriangle.triangleData)

                                newDistance =
                                    distance
                                        |> Quantity.minus (Point2d.distanceFrom point intersectionPoint)
                                        |> Quantity.max Quantity.zero

                                newSurfacePoint =
                                    Types.SurfacePoint
                                        { triangleId = adjacentTriangle.triangleId
                                        , position =
                                            if
                                                Point3d.distanceFrom intersectionPoint3d b
                                                    |> Quantity.lessThan (Point3d.distanceFrom intersectionPoint3d c)
                                            then
                                                newSurfacePosition0

                                            else
                                                newSurfacePosition1
                                        , direction = Direction2d.relativeTo frame direction
                                        , faceSide =
                                            if adjacentTriangle.isEdgeReversed then
                                                faceSide

                                            else
                                                flipFaceSide faceSide
                                        }
                            in
                            moveHelper
                                mesh
                                rotationOffset
                                newDistance
                                newSurfacePoint
                                (( surfacePoint, newSurfacePoint ) :: path)

                        Nothing ->
                            Nonempty.Nonempty
                                ( surfacePoint
                                , Types.SurfacePoint
                                    { triangleId = triangleId
                                    , position = Interpolative.fromPoint2d triangleData.triangle2d intersectionPoint
                                    , direction = surfacePoint_.direction
                                    , faceSide = surfacePoint_.faceSide
                                    }
                                )
                                path
                                |> Just

                Nothing ->
                    let
                        endPosition =
                            Interpolative.fromPoint2d triangleData.triangle2d endPoint
                    in
                    Nonempty.Nonempty
                        ( surfacePoint
                        , Types.SurfacePoint
                            { triangleId = triangleId
                            , position = endPosition
                            , direction = surfacePoint_.direction
                            , faceSide = surfacePoint_.faceSide
                            }
                        )
                        path
                        |> Just

        Nothing ->
            Nothing


flipFaceSide faceSide =
    case faceSide of
        Types.Front ->
            Types.Back

        Types.Back ->
            Types.Front


type alias AdjacentTriangleData units coordinates =
    { triangleId : Types.TriangleId
    , triangleData : Types.TriangleData units coordinates
    , side : TriangleEdge
    , isEdgeReversed : Bool
    }


getAdjacentTriangle :
    Mesh units coordinates
    -> Types.TriangleId
    -> TriangleEdge
    -> Maybe (AdjacentTriangleData units coordinates)
getAdjacentTriangle mesh triangleId side =
    case Types.getTriangleData triangleId mesh of
        Just triangleData ->
            getAdjacentTriangle_ mesh triangleData side

        Nothing ->
            Nothing


getAdjacentTriangle_ :
    Mesh units coordinates
    -> Types.TriangleData units coordinates
    -> TriangleEdge
    -> Maybe (AdjacentTriangleData units coordinates)
getAdjacentTriangle_ mesh triangleData side =
    triangleData.adjacent
        |> Triangle.getVertex (TriangleEdge.toInt side |> TriangleVertex.fromInt)
        |> Maybe.andThen
            (\{ adjacentId, adjacentEdge } ->
                Types.getTriangleData adjacentId mesh
                    |> Maybe.map
                        (\adjacentTriangleData ->
                            let
                                triangleSide =
                                    Triangle.getSide side triangleData.indices

                                adjacentTriangleSide =
                                    Triangle.getSide adjacentEdge adjacentTriangleData.indices
                            in
                            { triangleId = adjacentId
                            , triangleData = adjacentTriangleData
                            , side = adjacentEdge
                            , isEdgeReversed = triangleSide /= adjacentTriangleSide
                            }
                        )
            )
