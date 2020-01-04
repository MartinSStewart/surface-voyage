module Mesh exposing
    ( AdjacentSurfaceCoordinates
    , Error(..)
    , Mesh
    , SurfaceCoordinates
    , SurfacePoint
    , SurfaceSide(..)
    , TriangleData
    , TriangleId
    , VertexId
    , fromVerticesAndIndices
    , getAdjacentTriangle
    , getAdjacentTriangle_
    , getTriangleData
    , getTriangleEdgeFrame
    , getTriangleEdgeFrame_
    , getVertices
    , move
    , nearestSurfacePoint
    , surfacePointDirectionTowards
    , surfacePointPosition
    , surfacePointRotateBy
    , surfacePointToWorld
    , surfacePointTriangleId
    )

import Angle exposing (Angle)
import Array exposing (Array)
import Basics.Extra exposing (flip)
import Dict exposing (Dict)
import Direction2d exposing (Direction2d)
import Frame2d exposing (Frame2d)
import Interpolative exposing (Interpolative)
import LineSegment2d
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Point3dEx
import Quantity
import SketchPlane3d exposing (SketchPlane3d)
import Triangle exposing (Triangle)
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)
import TriangleEdge exposing (TriangleEdge)
import TriangleVertex
import Vector2d exposing (Vector2d)
import Vector3d


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias TriangleData units coordinates =
    { indices : Triangle VertexId
    , sketchPlane : SketchPlane3d units coordinates { defines : SurfaceCoordinates }
    , triangle2d : Triangle2d units SurfaceCoordinates
    , adjacent : Triangle (Maybe AdjacentTriangle)
    }


type alias AdjacentTriangle =
    { adjacentId : TriangleId, adjacentEdge : TriangleEdge }


triangleDataGetTriangle3d : TriangleData units coordinates -> Triangle3d units coordinates
triangleDataGetTriangle3d { sketchPlane, triangle2d } =
    Triangle3d.on sketchPlane triangle2d


type alias Mesh_ units coordinates =
    { triangles : Array (TriangleData units coordinates)
    , vertices : Array (Point3d units coordinates)
    }


getTriangles : Mesh units coordinates -> Array (TriangleData units coordinates)
getTriangles (Mesh mesh) =
    mesh.triangles


getVertices : Mesh units coordinates -> Array (Point3d units coordinates)
getVertices (Mesh mesh) =
    mesh.vertices


type Error
    = EdgeSharedBy3OrMoreTriangles
    | TriangleIsDegenerate
    | TriangleVertexNotFound


generateTriangleData :
    Array (Point3d units coordinates)
    -> List (Triangle VertexId_)
    -> Result Error (List (TriangleData units coordinates))
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

        adjacentTriangles : Maybe (Dict ( TriangleId_, VertexId_ ) AdjacentTriangle)
        adjacentTriangles =
            adjacentTrianglePairs
                |> List.foldl
                    (\( { edgeIndex, triIndex }, rest ) state ->
                        case ( rest, state ) of
                            ( [], Just list ) ->
                                Just list

                            ( other :: [], Just list ) ->
                                [ ( ( triIndex, edgeIndex )
                                  , { adjacentId = TriangleId other.triIndex, adjacentEdge = TriangleEdge.fromInt other.edgeIndex }
                                  )
                                , ( ( other.triIndex, other.edgeIndex )
                                  , { adjacentId = TriangleId triIndex, adjacentEdge = TriangleEdge.fromInt edgeIndex }
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
                                                { indices = Triangle.map VertexId indices
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


fromVerticesAndIndices : Array (Point3d units coordinates) -> List (Triangle VertexId_) -> Result Error (Mesh units coordinates)
fromVerticesAndIndices vertices triangles =
    case generateTriangleData vertices triangles of
        Ok triangleData ->
            { triangles = Array.fromList triangleData
            , vertices = vertices
            }
                |> Mesh
                |> Ok

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


type SurfacePoint units
    = SurfacePoint SurfacePoint_


type alias SurfacePoint_ =
    { triangleId : TriangleId
    , position : Interpolative
    , direction : Direction2d SurfaceCoordinates
    , faceSide : SurfaceSide
    }


surfacePointRotateBy : Angle -> SurfacePoint units -> SurfacePoint units
surfacePointRotateBy angle (SurfacePoint surfacePoint) =
    SurfacePoint { surfacePoint | direction = Direction2d.rotateBy angle surfacePoint.direction }


surfacePointSetDirection : Direction2d SurfaceCoordinates -> SurfacePoint units -> SurfacePoint units
surfacePointSetDirection direction (SurfacePoint surfacePoint) =
    SurfacePoint { surfacePoint | direction = direction }


surfacePointDirectionTowards : Point3d units coordinates -> Mesh units coordinates -> SurfacePoint units -> SurfacePoint units
surfacePointDirectionTowards point mesh surfacePoint =
    case getTriangleData (surfacePointTriangleId surfacePoint) mesh of
        Just triangleData ->
            let
                a =
                    surfacePointPosition surfacePoint |> Interpolative.toPoint2d triangleData.triangle2d
            in
            case Point3d.projectInto triangleData.sketchPlane point |> Direction2d.from a of
                Just newDirection ->
                    surfacePointSetDirection newDirection surfacePoint

                Nothing ->
                    surfacePoint

        _ ->
            surfacePoint


surfacePointTriangleId : SurfacePoint units -> TriangleId
surfacePointTriangleId (SurfacePoint surfacePoint) =
    surfacePoint.triangleId


surfacePointPosition : SurfacePoint units -> Interpolative
surfacePointPosition (SurfacePoint surfacePoint) =
    surfacePoint.position


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
    -> Maybe (Frame2d units SurfaceCoordinates { defines : SurfaceCoordinates })
getTriangleEdgeFrame mesh triangleId triangleSide =
    case ( getTriangleData triangleId mesh, getAdjacentTriangle mesh triangleId triangleSide ) of
        ( Just triangleData, Just adjacentTriangleData ) ->
            getTriangleEdgeFrame_ triangleSide triangleData adjacentTriangleData |> Just

        _ ->
            Nothing


vector2dChangeCoordinate v =
    Vector2d.toTuple rawQuantity v |> Vector2d.fromTuple Quantity.Quantity


getTriangleEdgeFrame_ :
    TriangleEdge
    -> TriangleData units coordinates
    -> AdjacentTriangleData units coordinates
    -> Frame2d units SurfaceCoordinates { defines : SurfaceCoordinates }
getTriangleEdgeFrame_ triangleSide triangleData adjacentTriangleData =
    let
        ( e0, e1 ) =
            triangleData.triangle2d
                |> Triangle.fromTriangle2d
                |> Triangle.getSide triangleSide

        ( ae0, ae1 ) =
            adjacentTriangleData.triangleData.triangle2d
                |> Triangle.fromTriangle2d
                |> Triangle.getSide adjacentTriangleData.side

        _ =
            adjacentTriangleData.triangleData |> triangleDataGetTriangle3d |> Debug.log "triangle 3d"

        eAngle =
            Direction2d.from e0 e1 |> Maybe.withDefault Direction2d.y

        aeAngle =
            Direction2d.from ae0 ae1 |> Maybe.withDefault Direction2d.y

        angleDiff =
            Direction2d.angleFrom eAngle aeAngle

        --adjacentEdge =
        --    Triangle.getSide adjacentTriangleData.side adjacentTriangle2d
    in
    if adjacentTriangleData.isEdgeReversed then
        Frame2d.atOrigin
            |> Frame2d.rotateBy angleDiff
            |> Frame2d.translateBy (Vector2d.from ae0 e0)
            |> Debug.log "flipped"

    else
        Frame2d.atOrigin
            |> Frame2d.rotateBy angleDiff
            |> Frame2d.translateBy (Vector2d.from e0 ae0)
            |> Debug.log "notflipped"



--flatten :
--    Mesh units coordinates
--    -> Vector2d units SurfaceCoordinates
--    -> SurfacePoint units
--    -> List ( TriangleId, TriangleData units coordinates )
--flatten mesh movement (SurfacePoint ({ triangleId, position, direction } as surfacePoint)) =
--    case traverseStart mesh triangleId of
--        Just traverse ->
--            let
--                triangleData =
--                    getCurrentTriangle traverse
--
--                _ =
--                    triangleDataGetTriangle3d triangleData |> Debug.log "triangle3d"
--
--                ( e0, e1, e2 ) =
--                    triangleData.triangle2d |> Debug.log "triangle2d" |> Triangle2d.edges
--
--                point =
--                    Interpolative.toPoint2d triangleData.triangle2d position |> Debug.log "point"
--
--                endPoint =
--                    Direction2d.angleFrom Direction2d.y direction
--                        |> flip Vector2d.rotateBy movement
--                        |> flip Point2d.translateBy point
--                        |> Debug.log "endpoint"
--
--                moveLine =
--                    LineSegment2d.from point endPoint |> Debug.log "moveLine"
--
--                intersection =
--                    [ e0, e1, e2 ]
--                        |> List.indexedMap Tuple.pair
--                        |> List.filterMap
--                            (\( index, edge ) ->
--                                LineSegment2d.intersectionPoint moveLine edge
--                                    |> Maybe.map
--                                        (\intersectionPoint ->
--                                            { edge = edge
--                                            , sideIndex = TriangleEdge.fromInt index
--                                            , intersectionPoint = intersectionPoint
--                                            }
--                                        )
--                            )
--                        {- We want the maximum (not minimum) distance intersection because if we ever end up with two intersections,
--                           the nearest one is due to our starting position lying on the triangle edge
--                        -}
--                        |> List.maximumBy (.intersectionPoint >> Point2d.distanceFrom point >> rawQuantity)
--                        |> Debug.log "intersection"
--            in
--            case intersection of
--                Just { edge, sideIndex, intersectionPoint } ->
--                    [ (triangleId, triangleData) ] --getTriangleEdgeFrame_ sideIndex triangleData
--
--                Nothing ->
--                    [(triangleId, triangleData)]
--
--        Nothing ->
--            []


traverseStart :
    Mesh units coordinates
    -> TriangleId
    -> Maybe (Traverse units coordinates)
traverseStart mesh triangleId =
    case getTriangleData triangleId mesh of
        Just triangleData ->
            { mesh = mesh, currentTriangle = triangleData } |> Traverse |> Just

        Nothing ->
            Nothing


traverseNext : TriangleEdge -> Traverse units coordinates -> Maybe (Traverse units coordinates)
traverseNext triangleEdge (Traverse { mesh, currentTriangle }) =
    case getAdjacentTriangle_ mesh currentTriangle triangleEdge of
        Just adjacentTriangle ->
            { mesh = mesh, currentTriangle = adjacentTriangle.triangleData } |> Traverse |> Just

        Nothing ->
            Nothing


type Traverse units coordinates
    = Traverse (Traverse_ units coordinates)


type alias Traverse_ units coordinates =
    { mesh : Mesh units coordinates
    , currentTriangle : TriangleData units coordinates
    }


getCurrentTriangle : Traverse units coordinates -> TriangleData units coordinates
getCurrentTriangle (Traverse traverse) =
    traverse.currentTriangle


move : Mesh units coordinates -> Vector2d units SurfaceCoordinates -> SurfacePoint units -> SurfacePoint units
move mesh movement (SurfacePoint ({ triangleId, position, direction } as surfacePoint)) =
    let
        _ =
            Debug.log "start" surfacePoint
    in
    case getTriangleData triangleId mesh of
        Just triangleData ->
            let
                _ =
                    triangleDataGetTriangle3d triangleData |> Debug.log "triangle3d"

                ( e0, e1, e2 ) =
                    triangleData.triangle2d |> Debug.log "triangle2d" |> Triangle2d.edges

                point =
                    Interpolative.toPoint2d triangleData.triangle2d position |> Debug.log "point"

                endPoint =
                    Direction2d.angleFrom Direction2d.y direction
                        |> flip Vector2d.rotateBy movement
                        |> flip Point2d.translateBy point
                        |> Debug.log "endpoint"

                moveLine =
                    LineSegment2d.from point endPoint |> Debug.log "moveLine"

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
                        |> Debug.log "intersection"
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
                                        |> Debug.log "t"

                                --movementLeft =
                                --    Quantity.ratio
                                --        (Point2d.distanceFrom intersectionPoint point)
                                --        (Vector2d.length movement)
                                --        |> (-) 1
                                --        |> flip Vector2d.scaleBy movement
                                frame =
                                    getTriangleEdgeFrame_ sideIndex triangleData adjacentTriangle

                                newMovement : Vector2d units SurfaceCoordinates
                                newMovement =
                                    Vector2d.relativeTo frame movement |> vector2dChangeCoordinate |> Debug.log "newMovement"

                                newSurfacePosition =
                                    Interpolative.fromTriangleSide
                                        (if adjacentTriangle.isEdgeReversed then
                                            1 - t

                                         else
                                            t
                                        )
                                        adjacentTriangle.side
                                        |> Debug.log "newSurfacePosition"

                                newSurfacePoint =
                                    SurfacePoint
                                        { triangleId = adjacentTriangle.triangleId
                                        , position = newSurfacePosition
                                        , direction = Direction2d.x
                                        , faceSide = Front
                                        }
                                        |> Debug.log "newSurfacePoint"
                            in
                            move mesh newMovement newSurfacePoint

                        Nothing ->
                            SurfacePoint
                                { triangleId = triangleId
                                , position = Interpolative.fromPoint2d triangleData.triangle2d intersectionPoint
                                , direction = Direction2d.x
                                , faceSide = Front
                                }
                                |> Debug.log "NothingA"

                Nothing ->
                    SurfacePoint
                        { surfacePoint
                            | triangleId = triangleId
                            , position = Interpolative.fromPoint2d triangleData.triangle2d endPoint
                        }
                        |> Debug.log "NothingB"

        Nothing ->
            SurfacePoint surfacePoint |> Debug.log "NothingC"


type alias AdjacentTriangleData units coordinates =
    { triangleId : TriangleId
    , triangleData : TriangleData units coordinates
    , side : TriangleEdge
    , isEdgeReversed : Bool
    }


getAdjacentTriangle :
    Mesh units coordinates
    -> TriangleId
    -> TriangleEdge
    -> Maybe (AdjacentTriangleData units coordinates)
getAdjacentTriangle mesh triangleId side =
    case getTriangleData triangleId mesh of
        Just triangleData ->
            getAdjacentTriangle_ mesh triangleData side

        Nothing ->
            Nothing


getAdjacentTriangle_ :
    Mesh units coordinates
    -> TriangleData units coordinates
    -> TriangleEdge
    -> Maybe (AdjacentTriangleData units coordinates)
getAdjacentTriangle_ mesh triangleData side =
    triangleData.adjacent
        |> Triangle.getVertex (TriangleEdge.toInt side |> TriangleVertex.fromInt)
        |> Maybe.andThen
            (\{ adjacentId, adjacentEdge } ->
                getTriangleData adjacentId mesh
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
