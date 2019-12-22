module Tests exposing (..)

import Array
import Dict
import Expect
import Mesh
import Point3d
import Test exposing (..)
import Triangle


all : Test
all =
    describe "A Test Suite"
        [ test "fromVertsAndIndices getTriangles" <|
            \_ ->
                mesh |> Mesh.getTriangles |> Expect.equal triangles
        , test "fromVertsAndIndices getIndices" <|
            \_ ->
                mesh |> Mesh.getVertices |> Expect.equal vertices
        , test "fromVertsAndIndices getAdjacentTriangles" <|
            \_ ->
                let
                    expected =
                        Dict.fromList [ ( ( 0, 1 ), 1 ), ( ( 1, 0 ), 0 ) ]
                in
                mesh |> Mesh.getAdjacentTriangles |> Expect.equal expected
        ]


triangles =
    Array.fromList [ Triangle.from 0 2 1, Triangle.from 1 2 3 ]


vertices =
    Array.fromList [ Point3d.meters 0 0 0, Point3d.meters 0 1 0, Point3d.meters 1 1 0, Point3d.meters 1 0 0 ]


mesh =
    Mesh.fromVertsAndIndices vertices triangles
