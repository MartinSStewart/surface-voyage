module MeshTests exposing (..)

import Basics.Extra exposing (flip)
import Expect
import Fuzz
import Length exposing (Meters)
import Mesh
import MeshBuilder
import Point2d
import Point3d
import Point3dExTests exposing (fuzzPoint3dRange, pointEqualWithin)
import Quantity
import Test exposing (Test, describe, fuzz, fuzz2, only, test)
import TriangleSide exposing (TriangleEdge(..))
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


frameTest : Test
frameTest =
    test "frame test" <|
        \_ ->
            let
                triangleId =
                    Mesh.nearestSurfacePoint (Point3d.meters 0 1 0) twoTriangleSurface |> Mesh.surfacePointTriangleId

                frame =
                    Mesh.getTriangleEdgeFrame twoTriangleSurface triangleId EdgeTwo |> Debug.log "frame"
            in
            Expect.fail ""


getAdjacentTriangleTest : Test
getAdjacentTriangleTest =
    test "adjacent triangle test" <|
        \_ ->
            let
                triangleId =
                    Mesh.nearestSurfacePoint (Point3d.meters 0 1 0) twoTriangleSurface |> Mesh.surfacePointTriangleId

                adjacentTriangleId =
                    Mesh.nearestSurfacePoint (Point3d.meters 1 0 0) twoTriangleSurface |> Mesh.surfacePointTriangleId
            in
            Mesh.getAdjacentTriangle twoTriangleSurface ( triangleId, EdgeTwo )
                |> Expect.equal (Just { triangleId = adjacentTriangleId, side = EdgeZero, isEdgeReversed = True })


moveAcrossEdgeTest : Test
moveAcrossEdgeTest =
    test "moveAcrossEdgeTest" <|
        \_ ->
            Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) twoTriangleSurface
                |> Mesh.move twoTriangleSurface (Vector2d.meters 0.6 0)
                |> flip Mesh.surfacePointToWorld twoTriangleSurface
                |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.8 0.5 0))
                |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")


moveWithinTriangleTest : Test
moveWithinTriangleTest =
    test "moveWithinTriangleTest" <|
        \_ ->
            Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) twoTriangleSurface
                |> Mesh.move twoTriangleSurface (Vector2d.meters 0.1 0)
                |> flip Mesh.surfacePointToWorld twoTriangleSurface
                |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.3 0.5 0))
                |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
