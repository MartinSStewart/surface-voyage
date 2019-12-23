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
                case mesh vertices triangles of
                    Ok mesh_ ->
                        mesh_ |> Mesh.getTriangles |> Expect.equal triangles

                    Err _ ->
                        Expect.fail "Failed to create mesh"
        , test "fromVertsAndIndices getIndices" <|
            \_ ->
                case mesh vertices triangles of
                    Ok mesh_ ->
                        mesh_ |> Mesh.getVertices |> Expect.equal vertices

                    Err _ ->
                        Expect.fail "Failed to create mesh"

        --, test "fromVertsAndIndices getAdjacentTriangles" <|
        --    \_ ->
        --        let
        --            expected =
        --                Dict.fromList [ ( ( 0, 1 ), 1 ), ( ( 1, 0 ), 0 ) ]
        --        in
        --        mesh vertices triangles |> Mesh.getAdjacentTriangles |> Expect.equal expected
        --, test "degenerate fromVertsAndIndices getAdjacentTriangles" <|
        --    \_ ->
        --        let
        --            expected =
        --                Dict.fromList
        --                    [ ( ( 0, 0 ), 1 )
        --                    , ( ( 0, 1 ), 1 )
        --                    , ( ( 0, 2 ), 1 )
        --                    , ( ( 1, 0 ), 0 )
        --                    , ( ( 1, 1 ), 0 )
        --                    , ( ( 1, 2 ), 0 )
        --                    ]
        --        in
        --        mesh degenerateVertices degenerateTriangles |> Mesh.getAdjacentTriangles |> Expect.equal expected
        ]


triangles =
    Array.fromList [ Triangle.from 0 2 1, Triangle.from 1 2 3 ]


vertices =
    Array.fromList [ Point3d.meters 0 0 0, Point3d.meters 0 1 0, Point3d.meters 1 1 0, Point3d.meters 1 0 0 ]


degenerateVertices =
    Array.fromList [ Point3d.meters 0 0 0, Point3d.meters 0 1 0, Point3d.meters 1 1 0 ]


degenerateTriangles =
    Array.fromList [ Triangle.from 0 2 1, Triangle.from 0 1 2 ]


mesh verts tris =
    Mesh.fromVertsAndIndices verts tris
