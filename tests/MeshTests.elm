module MeshTests exposing (..)

import Basics.Extra exposing (flip)
import Expect
import Mesh
import MeshBuilder
import Point3d
import Point3dExTests exposing (fuzzPoint3dRange, pointEqualWithin)
import Test exposing (Test, describe, fuzz, fuzz2, test)
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
