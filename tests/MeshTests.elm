module MeshTests exposing (..)

import Angle
import Array
import Basics.Extra exposing (flip)
import Direction3d
import Expect
import InterpolativeTests exposing (rawQuantity)
import Length exposing (Meters)
import MeshBuilder
import Point2d
import Point3d
import Point3dExTests exposing (fuzzPoint3dRange)
import Quantity
import SurfaceMesh.Mesh as Mesh exposing (TriangleId)
import SurfaceMesh.Path as Path
import SurfaceMesh.SurfacePoint as SurfacePoint
import SurfaceMesh.TriangleData as TriangleData exposing (TriangleData)
import SurfaceMesh.TriangleEdge as TriangleEdge exposing (TriangleEdge(..))
import Test exposing (Test, describe, fuzz, only, test)
import Triangle2d
import Vector3d


nearestSurfacePoint : Test
nearestSurfacePoint =
    describe "nearestSurfacePoint"
        [ fuzz (fuzzPoint3dRange -2 2) "Round trip from nearestSurfacePoint to surfacePointToWorld" <|
            \point ->
                case Mesh.nearestSurfacePoint point surfaceCube |> flip SurfacePoint.worldPosition surfaceCube of
                    Just expected ->
                        case
                            Mesh.nearestSurfacePoint expected surfaceCube
                                |> flip SurfacePoint.worldPosition surfaceCube
                        of
                            Just actual ->
                                Point3dExTests.pointEqualWithin expected actual

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


frameTest2 =
    test "frame test 2" <|
        \_ ->
            let
                mesh =
                    twoTriangleSurface2

                triangleId =
                    Mesh.nearestSurfacePoint (Point3d.meters 0 0 0) mesh |> SurfacePoint.triangleId
            in
            case Mesh.getTriangleData triangleId mesh of
                Just triangleData ->
                    let
                        connectedEdge =
                            getConnectedEdge triangleData
                    in
                    case Mesh.getAdjacentTriangle_ mesh triangleData connectedEdge of
                        Just adjacentTriangle ->
                            let
                                frame =
                                    Mesh.getTriangleEdgeFrame_ connectedEdge triangleData adjacentTriangle
                            in
                            adjacentTriangle.triangleData.triangle2d
                                |> Triangle2d.placeIn frame
                                |> triangle2dWithin (Triangle2d.from (Point2d.meters 1 0) (Point2d.meters 0 1) (Point2d.meters 1 1))

                        Nothing ->
                            Expect.fail "failed 2"

                Nothing ->
                    Expect.fail "failed 1"


frameTest3 =
    test "frame test 3" <|
        \_ ->
            let
                mesh =
                    twoTriangleSurface3

                triangleId =
                    Mesh.nearestSurfacePoint (Point3d.meters 0 0 0) mesh |> SurfacePoint.triangleId
            in
            case Mesh.getTriangleData triangleId mesh of
                Just triangleData ->
                    let
                        connectedEdge =
                            getConnectedEdge triangleData
                    in
                    case Mesh.getAdjacentTriangle_ mesh triangleData connectedEdge of
                        Just adjacentTriangle ->
                            let
                                frame =
                                    Mesh.getTriangleEdgeFrame_ connectedEdge triangleData adjacentTriangle
                            in
                            adjacentTriangle.triangleData.triangle2d
                                |> Triangle2d.placeIn frame
                                |> triangle2dWithin (Triangle2d.from (Point2d.meters 1 0) (Point2d.meters 1 1) (Point2d.meters 0 1))

                        Nothing ->
                            Expect.fail "failed 2"

                Nothing ->
                    Expect.fail "failed 1"


pointToString point =
    let
        ( x, y ) =
            Point2d.toTuple rawQuantity point
    in
    "(" ++ String.fromFloat x ++ ", " ++ String.fromFloat y ++ ")"


equalWithin expected actual =
    (abs (expected - actual) < 0.001)
        || (abs (expected - actual) < (abs expected * 0.001))


pointEqualWithin expected actual =
    let
        ( ex, ey ) =
            Point2d.toTuple rawQuantity expected

        ( ax, ay ) =
            Point2d.toTuple rawQuantity actual
    in
    equalWithin ex ax && equalWithin ey ay


triangle2dWithin expected actual =
    let
        ( e0, e1, e2 ) =
            Triangle2d.vertices expected

        ( a0, a1, a2 ) =
            Triangle2d.vertices actual
    in
    if pointEqualWithin e0 a0 && pointEqualWithin e1 a1 && pointEqualWithin e2 a2 then
        Expect.pass

    else
        Expect.fail
            ("Expected: {"
                ++ pointToString e0
                ++ ", "
                ++ pointToString e1
                ++ ", "
                ++ pointToString e2
                ++ "}    Actual: {"
                ++ pointToString a0
                ++ ", "
                ++ pointToString a1
                ++ ", "
                ++ pointToString a2
                ++ "}"
            )


getAdjacentTriangleTest : Test
getAdjacentTriangleTest =
    test "getAdjacentTriangle test" <|
        \_ ->
            let
                surfacePoint =
                    Mesh.nearestSurfacePoint (Point3d.meters 0 1 0) twoTriangleSurface

                triangleId =
                    SurfacePoint.triangleId surfacePoint
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


start =
    Point3d.meters 0.1 0.4 0


end =
    Point3d.meters 0.9 0.4 0


twoTriangleSurface3 : Mesh.Mesh Meters coordinates
twoTriangleSurface3 =
    case
        Mesh.fromVerticesAndIndices
            (Array.fromList [ Point3d.meters 0 0 0, Point3d.meters 1 0 0, Point3d.meters 0 1 0, Point3d.meters 1 1 0 ])
            [ ( 0, 1, 2 ), ( 1, 3, 2 ) ]
    of
        Ok mesh ->
            mesh

        Err error ->
            error |> Debug.toString |> Debug.todo


moveOnTriangle : Test
moveOnTriangle =
    describe "Move on triangle"
        [ test "moveWithinTriangleTest" <|
            \_ ->
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) twoTriangleSurface2
                    |> SurfacePoint.directionFromWorldDirection Direction3d.x twoTriangleSurface2
                    |> Mesh.move twoTriangleSurface2 Quantity.zero (Length.meters 0.1)
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition twoTriangleSurface2)
                    |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.3 0.5 0))
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , test "moveAcrossEdgeTest" <|
            \_ ->
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) twoTriangleSurface2
                    |> SurfacePoint.pointTowards (Point3d.meters 1 0.5 0) twoTriangleSurface2
                    |> Mesh.move twoTriangleSurface2 Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition twoTriangleSurface2)
                    |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.8 0.5 0))
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , test "moveAcrossEdgeTest 2" <|
            \_ ->
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.4 0) twoTriangleSurface2
                    |> SurfacePoint.pointTowards (Point3d.meters 1 0.4 0) twoTriangleSurface2
                    |> Mesh.move twoTriangleSurface2 Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition twoTriangleSurface2)
                    |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.8 0.4 0))
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , test "moveAcrossEdgeTest 3" <|
            \_ ->
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.4 0) twoTriangleSurface3
                    |> SurfacePoint.pointTowards (Point3d.meters 1 0.4 0) twoTriangleSurface3
                    |> Mesh.move twoTriangleSurface3 Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition twoTriangleSurface3)
                    |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.8 0.4 0))
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , test "preserveDirectionTest" <|
            \_ ->
                let
                    expected =
                        Direction3d.x

                    mesh =
                        twoTriangleSurface2
                in
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) mesh
                    |> SurfacePoint.directionFromWorldDirection expected mesh
                    |> Mesh.move mesh Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> SurfacePoint.worldDirection mesh)
                    |> Maybe.map (Direction3d.equalWithin (Angle.radians 0.001) expected >> Expect.true "Directions don't match")
                    |> Maybe.withDefault (Expect.fail "Couldn't get direction")
        , test "preserveDirectionTest2" <|
            \_ ->
                let
                    expected =
                        Direction3d.x

                    mesh =
                        twoTriangleSurface3
                in
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) mesh
                    |> SurfacePoint.directionFromWorldDirection expected mesh
                    |> Mesh.move mesh Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> SurfacePoint.worldDirection mesh)
                    |> Maybe.map (Direction3d.equalWithin (Angle.radians 0.001) expected >> Expect.true "Directions don't match")
                    |> Maybe.withDefault (Expect.fail "Couldn't get direction")
        , test "preserveDirectionTest3" <|
            \_ ->
                let
                    expected =
                        Direction3d.x

                    mesh =
                        twoTriangleSurface2
                in
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) mesh
                    |> SurfacePoint.directionFromWorldDirection expected mesh
                    |> Mesh.move mesh Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> Mesh.move mesh Quantity.zero (Length.meters 0.1))
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition mesh)
                    |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.9 0.5 0))
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , only <|
            test "moveAcrossEdgeTest5" <|
                \_ ->
                    let
                        mesh =
                            twoTriangleSurface2
                    in
                    Mesh.nearestSurfacePoint end mesh
                        |> SurfacePoint.directionFromWorldDirection Direction3d.x mesh
                        |> Mesh.move mesh Quantity.zero (Length.meters -0.8)
                        |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition mesh)
                        |> Maybe.map (Point3dExTests.pointEqualWithin start)
                        |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , test "moveAcrossEdgeTest6" <|
            \_ ->
                let
                    mesh =
                        twoTriangleSurface2
                in
                Mesh.nearestSurfacePoint start mesh
                    |> SurfacePoint.directionFromWorldDirection Direction3d.x mesh
                    |> Mesh.move mesh Quantity.zero (Length.meters 0.8)
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition mesh)
                    |> Maybe.map (Point3dExTests.pointEqualWithin end)
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        , test "moveAcrossEdgeTest7" <|
            \_ ->
                let
                    mesh =
                        twoTriangleSurface3
                in
                Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.5 0) mesh
                    |> SurfacePoint.directionFromWorldDirection Direction3d.x mesh
                    |> Mesh.move mesh Quantity.zero (Length.meters 0.6)
                    |> Maybe.andThen (Path.endPoint >> Mesh.move mesh Quantity.zero (Length.meters 0.1))
                    |> Maybe.andThen (Path.endPoint >> flip SurfacePoint.worldPosition mesh)
                    |> Maybe.map (Point3dExTests.pointEqualWithin (Point3d.meters 0.9 0.5 0))
                    |> Maybe.withDefault (Expect.fail "Failed to convert surface point to world coordinates")
        ]
