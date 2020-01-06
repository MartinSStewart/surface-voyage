module MeshTests exposing (..)

import Array
import Basics.Extra exposing (flip)
import Expect
import Frame2d
import Fuzz
import Interpolative
import InterpolativeTests exposing (rawQuantity)
import Length exposing (Meters)
import Mesh exposing (TriangleData, TriangleId)
import MeshBuilder
import Plane3d
import Point2d
import Point3d
import Point3dExTests exposing (fuzzPoint3dRange, pointEqualWithin)
import Quantity
import Test exposing (Test, describe, fuzz, fuzz2, only, test)
import Triangle2d
import TriangleEdge exposing (TriangleEdge(..))
import Vector2d
import Vector3d


nearestSurfacePoint : Test
nearestSurfacePoint =
    describe "nearestSurfacePoint"
        [ fuzz (fuzzPoint3dRange -2 2) "Round trip from nearestSurfacePoint to surfacePointToWorld" <|
            \point ->
                case Mesh.nearestSurfacePoint point surfaceCube |> flip Mesh.surfacePointToWorld surfaceCube of
                    Just expected ->
                        case
                            Mesh.nearestSurfacePoint expected surfaceCube
                                |> flip Mesh.surfacePointToWorld surfaceCube
                        of
                            Just actual ->
                                pointEqualWithin expected actual

                            Nothing ->
                                Expect.fail "This should never happen."

                    Nothing ->
                        Expect.fail "Failed to convert surface point into Point3d."
        ]


baseCube =
    MeshBuilder.cube |> MeshBuilder.map (Point3d.translateBy (Vector3d.meters -0.5 -0.5 -0.5))


surfaceCube =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices baseCube
    in
    case Mesh.fromVerticesAndIndices verts indices of
        Ok mesh ->
            mesh

        Err error ->
            error |> Debug.toString |> Debug.todo


twoTriangleMesh =
    MeshBuilder.square
        |> MeshBuilder.map (\point -> Point3d.xyz (Point2d.xCoordinate point) (Point2d.yCoordinate point) Quantity.zero)


twoTriangleSurface : Mesh.Mesh Meters coordinates
twoTriangleSurface =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices twoTriangleMesh
    in
    case Mesh.fromVerticesAndIndices verts indices of
        Ok mesh ->
            mesh

        Err error ->
            error |> Debug.toString |> Debug.todo


twoTriangleMesh2 =
    MeshBuilder.square2
        |> MeshBuilder.map (\point -> Point3d.xyz (Point2d.xCoordinate point) (Point2d.yCoordinate point) Quantity.zero)


twoTriangleSurface2 : Mesh.Mesh Meters coordinates
twoTriangleSurface2 =
    case
        Mesh.fromVerticesAndIndices
            (Array.fromList [ Point3d.meters 0 0 0, Point3d.meters 1 0 0, Point3d.meters 0 1 0, Point3d.meters 1 1 0 ])
            [ ( 0, 1, 2 ), ( 1, 2, 3 ) ]
    of
        Ok mesh ->
            mesh

        Err error ->
            error |> Debug.toString |> Debug.todo


vector2dChangeCoordinate v =
    Vector2d.toTuple rawQuantity v |> Vector2d.fromTuple Quantity.Quantity



--frameTest2 =
--    only <|
--        test "frame test 2" <|
--            \_ ->
--                let
--                    mesh =
--                        twoTriangleSurface2
--
--                    triangleId =
--                        Mesh.nearestSurfacePoint (Point3d.meters 0 0 0) mesh |> Mesh.surfacePointTriangleId
--                in
--                case Mesh.getTriangleData triangleId mesh of
--                    Just triangleData ->
--                        let
--                            connectedEdge =
--                                getConnectedEdge triangleData
--
--                            _ =
--                                triangleData.triangle2d |> Debug.log "top left tri"
--                        in
--                        case Mesh.getAdjacentTriangle_ mesh triangleData connectedEdge of
--                            Just adjacentTriangle ->
--                                let
--                                    frame =
--                                        Mesh.getTriangleEdgeFrame_ connectedEdge triangleData adjacentTriangle
--
--                                    a : Triangle2d.Triangle2d Meters Mesh.SurfaceCoordinates
--                                    a =
--                                        adjacentTriangle.triangleData.triangle2d
--                                            |> Triangle2d.relativeTo frame
--                                            |> Debug.log "a"
--
--                                    b : Triangle2d.Triangle2d Meters Mesh.SurfaceCoordinates
--                                    b =
--                                        adjacentTriangle.triangleData.triangle2d
--                                            |> Triangle2d.placeIn frame
--                                            |> Debug.log "b"
--                                in
--                                Expect.pass
--
--                            Nothing ->
--                                Expect.fail "failed 2"
--
--                    Nothing ->
--                        Expect.fail "failed 1"
--frameTest : Test
--frameTest =
--    only <|
--        test "frame test" <|
--            \_ ->
--                let
--                    surfacePoint =
--                        Mesh.nearestSurfacePoint (Point3d.meters 0.5 0.5 0) twoTriangleSurface
--
--                    triangleId =
--                        Mesh.surfacePointTriangleId surfacePoint
--                in
--                case Mesh.getTriangleData triangleId twoTriangleSurface of
--                    Just triangleData ->
--                        let
--                            edge =
--                                getConnectedEdge triangleData
--                        in
--                        case Mesh.getAdjacentTriangle twoTriangleSurface triangleId edge of
--                            Just adjacent ->
--                                let
--                                    frame =
--                                        Mesh.getTriangleEdgeFrame_ edge triangleData adjacent
--
--                                    position =
--                                        Mesh.surfacePointPosition surfacePoint |> Interpolative.toPoint2d triangleData.triangle2d
--                                in
--                                position |> Point2d.relativeTo frame |> Mesh.surfacePointToWorld |> Expect.equal expected
--
--                            Nothing ->
--                                Expect.fail "Failed to get adjacent triangle data"
--
--                    Nothing ->
--                        Expect.fail "Failed to get triangle data"


getAdjacentTriangleTest : Test
getAdjacentTriangleTest =
    test "getAdjacentTriangle test" <|
        \_ ->
            let
                surfacePoint =
                    Mesh.nearestSurfacePoint (Point3d.meters 0 1 0) twoTriangleSurface

                triangleId : TriangleId
                triangleId =
                    Mesh.surfacePointTriangleId surfacePoint
            in
            case Mesh.getTriangleData triangleId twoTriangleSurface |> Maybe.map getConnectedEdge of
                Just edge ->
                    Mesh.getAdjacentTriangle twoTriangleSurface triangleId edge
                        |> Maybe.map (.triangleId >> (/=) triangleId)
                        |> Expect.equal (Just True)

                Nothing ->
                    Expect.fail "Failed to get connected edge"


getConnectedEdge : TriangleData units coordinates -> TriangleEdge
getConnectedEdge triangleData =
    case triangleData.adjacent of
        ( Just _, _, _ ) ->
            EdgeZero

        ( Nothing, Just _, _ ) ->
            EdgeOne

        ( Nothing, Nothing, Just _ ) ->
            EdgeTwo

        ( Nothing, Nothing, Nothing ) ->
            EdgeZero



--getAdjacentTriangleTest : Test
--getAdjacentTriangleTest =
--    test "adjacent triangle test" <|
--        \_ ->
--            let
--                triangleId =
--                    Mesh.nearestSurfacePoint (Point3d.meters 0 1 0) twoTriangleSurface |> Mesh.surfacePointTriangleId
--
--                adjacentTriangleId =
--                    Mesh.nearestSurfacePoint (Point3d.meters 1 0 0) twoTriangleSurface |> Mesh.surfacePointTriangleId
--            in
--            Mesh.getAdjacentTriangle twoTriangleSurface ( triangleId, EdgeTwo )
--                |> Expect.equal (Just { triangleId = adjacentTriangleId, triangleData = , side = EdgeZero, isEdgeReversed = True })


moveAcrossEdgeTest : Test
moveAcrossEdgeTest =
    test "moveAcrossEdgeTest" <|
        \_ ->
            Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) twoTriangleSurface2
                |> Mesh.surfacePointDirectionTowards (Point3d.meters 0.2 1 0) twoTriangleSurface2
                |> Mesh.move twoTriangleSurface2 (Vector2d.meters 0.6 0)
                |> flip Mesh.surfacePointToWorld twoTriangleSurface2
                |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.8 0.5 0))
                |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")


moveAcrossEdgeTest2 : Test
moveAcrossEdgeTest2 =
    test "moveAcrossEdgeTest 2" <|
        \_ ->
            Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.4 0) twoTriangleSurface2
                |> Mesh.surfacePointDirectionTowards (Point3d.meters 0.2 1 0) twoTriangleSurface2
                |> Mesh.move twoTriangleSurface2 (Vector2d.meters 0.6 0)
                |> flip Mesh.surfacePointToWorld twoTriangleSurface2
                |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.8 0.4 0))
                |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")


moveWithinTriangleTest : Test
moveWithinTriangleTest =
    test "moveWithinTriangleTest" <|
        \_ ->
            Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) twoTriangleSurface2
                |> Mesh.surfacePointDirectionTowards (Point3d.meters 0.2 0 0) twoTriangleSurface2
                |> Mesh.move twoTriangleSurface2 (Vector2d.meters 0.1 0)
                |> flip Mesh.surfacePointToWorld twoTriangleSurface2
                |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.3 0.5 0))
                |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
