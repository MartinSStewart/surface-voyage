module MeshData exposing (..)

import Array
import Basics.Extra exposing (flip)
import Color
import Dict
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Length exposing (Meters)
import List.Nonempty
import Math.Vector3 as Vec3
import Math.Vector4 as Vec4
import MeshBuilder exposing (MeshPart, Vertex)
import OBJ
import OBJ.Types exposing (Mesh(..))
import Point3d
import Random
import SurfaceMesh.Mesh as Mesh
import SurfaceMesh.Triangle as Triangle
import SurfaceMesh.TriangleVertex as TriangleVertex
import WebGL


type WorldCoordinate
    = WorldCoordinate Never


type ScreenCoordinate
    = ScreenCoordinate Never


baseCube =
    MeshBuilder.cube


colorToVec4 color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Vec4.vec4 (red * alpha) (green * alpha) (blue * alpha) alpha


cubeColors =
    List.Nonempty.Nonempty (Color.rgb 0.9 0.1 0.1)
        [ Color.rgb 0.1 0.9 0.1
        , Color.rgb 0.1 0.1 0.9
        , Color.rgb 0.9 0.9 0.1
        , Color.rgb 0.9 0.1 0.9
        , Color.rgb 0.1 0.9 0.9
        ]


renderCube : WebGL.Mesh Vertex
renderCube =
    MeshBuilder.splitFacesCube
        |> MeshBuilder.map
            (\{ position, cubeFaceIndex } ->
                { color = cubeColors |> List.Nonempty.get cubeFaceIndex |> colorToVec4
                , position = position |> Point3d.toVec3
                , normal = Vec3.vec3 0 0 1
                }
            )
        |> MeshBuilder.toWebGlMesh


squareData =
    { vertices = Array.fromList [ Point3d.meters 0 0 0, Point3d.meters 1 0 0, Point3d.meters 0 1 0, Point3d.meters 0.5 0.5 0.707, Point3d.meters 1 1 1 ]
    , indices = [ ( 0, 1, 2 ), ( 3, 2, 1 ), ( 4, 3, 1 ) ]
    }


splitEdges : MeshPart a -> MeshPart { triangleIndex : Int, vertex : a }
splitEdges meshPart =
    let
        ( vertices, indices ) =
            MeshBuilder.toVerticesAndIndices meshPart

        newVertices =
            indices
                |> List.indexedMap Tuple.pair
                |> List.concatMap
                    (\( index, triangle ) ->
                        case Triangle.andThen (flip Array.get vertices) triangle of
                            Just triangle_ ->
                                [ { triangleIndex = index, vertex = Triangle.getVertex TriangleVertex.VertexZero triangle_ }
                                , { triangleIndex = index, vertex = Triangle.getVertex TriangleVertex.VertexOne triangle_ }
                                , { triangleIndex = index, vertex = Triangle.getVertex TriangleVertex.VertexTwo triangle_ }
                                ]

                            Nothing ->
                                []
                    )

        newIndices =
            List.range 0 (List.length newVertices // 3 - 1)
                |> List.map (\index -> ( index * 3, index * 3 + 1, index * 3 + 2 ))
    in
    MeshBuilder.VerticesAndIndices newVertices newIndices


squareSurface : Result Mesh.Error (Mesh.Mesh Meters coordinates)
squareSurface =
    Mesh.fromVerticesAndIndices squareData.vertices squareData.indices


squareMesh : WebGL.Mesh Vertex
squareMesh =
    MeshBuilder.VerticesAndIndices
        (Array.toList squareData.vertices)
        squareData.indices
        |> splitEdges
        |> MeshBuilder.map
            (\{ triangleIndex, vertex } ->
                { position = Point3d.toVec3 vertex
                , normal = Vec3.vec3 0 0 0
                , color = Random.initialSeed triangleIndex |> Random.step randomColor |> Tuple.first |> colorToVec4
                }
            )
        |> MeshBuilder.toWebGlMesh


randomColor =
    Random.map3 Color.rgb
        (Random.float 0.1 0.9)
        (Random.float 0.1 0.9)
        (Random.float 0.1 0.9)


surfaceCube : Result Mesh.Error (Mesh.Mesh Meters WorldCoordinate)
surfaceCube =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices baseCube
    in
    Mesh.fromVerticesAndIndices verts indices


triangleTube =
    """# Blender v2.81 (sub 16) OBJ File: ''
       # www.blender.org
       o Plane_Plane.001
       v 1.000000 -0.078415 0.921585
       v 1.000000 -0.078415 -0.600024
       v 1.000000 -0.698886 0.921585
       v 1.000000 0.000000 1.000000
       v 1.000000 0.000000 -1.000000
       v 1.000000 -0.815546 1.000000
       v -1.000000 -0.082097 0.917903
       v -1.000000 -0.082097 -0.581244
       v -1.000000 -0.693409 0.917903
       v -1.000000 0.000000 -1.000000
       v -1.000000 0.000000 1.000000
       v -1.000000 -0.815546 1.000000
       vt 1.000000 0.000000
       vt 0.000000 1.000000
       vt 0.000000 0.000000
       vt 1.000000 0.000000
       vt 1.000000 1.000000
       vt 0.000000 0.041049
       vt 1.000000 0.039208
       vt 1.000000 0.039208
       vt 1.000000 0.800012
       vt 0.000000 0.790622
       vt 0.000000 0.041049
       vt 0.000000 0.000000
       vn 0.5773 0.5773 0.5773
       vn -0.5394 0.1620 -0.8263
       vn -0.5773 0.5773 0.5773
       vn 0.5596 -0.6878 0.4623
       vn 0.5394 0.1620 -0.8263
       vn -0.9454 0.2704 -0.1818
       vn 0.9049 -0.3009 -0.3009
       vn 0.9460 0.2690 -0.1808
       vn 0.9948 -0.0195 0.0994
       vn -0.9947 -0.0197 0.1007
       vn -0.9041 -0.3021 -0.3021
       vn -0.5596 -0.6878 0.4623
       s 1
       f 4/1/1 10/2/2 11/3/3
       f 11/3/3 6/4/4 4/1/1
       f 6/4/4 10/2/2 5/5/5
       f 9/6/6 1/7/7 3/8/8
       f 2/9/9 4/1/1 1/7/7
       f 3/8/8 4/1/1 6/4/4
       f 2/9/9 6/4/4 5/5/5
       f 8/10/10 3/8/8 2/9/9
       f 8/10/10 11/3/3 10/2/2
       f 9/6/6 11/3/3 7/11/11
       f 8/10/10 12/12/12 9/6/6
       f 8/10/10 1/7/7 7/11/11
       f 4/1/1 5/5/5 10/2/2
       f 11/3/3 12/12/12 6/4/4
       f 6/4/4 12/12/12 10/2/2
       f 9/6/6 7/11/11 1/7/7
       f 2/9/9 5/5/5 4/1/1
       f 3/8/8 1/7/7 4/1/1
       f 2/9/9 3/8/8 6/4/4
       f 8/10/10 9/6/6 3/8/8
       f 8/10/10 7/11/11 11/3/3
       f 9/6/6 12/12/12 11/3/3
       f 8/10/10 10/2/2 12/12/12
       f 8/10/10 2/9/9 1/7/7


"""


convertVertices vertices =
    vertices |> List.map (.position >> Point3d.fromVec3) |> Array.fromList


convertWebGlVertices : List { a | position : Vec3.Vec3 } -> List { color : Vec4.Vec4, position : Vec3.Vec3, normal : Vec3.Vec3 }
convertWebGlVertices vertices =
    vertices
        |> List.indexedMap
            (\index { position } ->
                { color = Random.initialSeed index |> Random.step randomColor |> Tuple.first |> colorToVec4
                , position = position
                , normal = Vec3.vec3 0 0 0
                }
            )


convertIndices indices =
    indices |> List.map Triangle.reverse


meshObject : ( Result Mesh.Error (Mesh.Mesh units coordinates), WebGL.Mesh { color : Vec4.Vec4, position : Vec3.Vec3, normal : Vec3.Vec3 } )
meshObject =
    case OBJ.parseObjStringWith OBJ.defaultSettings triangleTube of
        Ok objFile ->
            case objFile |> Dict.toList |> List.head |> Maybe.map Tuple.second of
                Just mesh ->
                    case mesh |> Dict.toList |> List.head |> Maybe.map Tuple.second of
                        Just (WithTexture { vertices, indices }) ->
                            ( Mesh.fromVerticesAndIndices (convertVertices vertices) (convertIndices indices)
                            , MeshBuilder.VerticesAndIndices (convertWebGlVertices vertices) (convertIndices indices) |> MeshBuilder.toWebGlMesh
                            )

                        Just (WithoutTexture { vertices, indices }) ->
                            ( Mesh.fromVerticesAndIndices (convertVertices vertices) (convertIndices indices)
                            , MeshBuilder.VerticesAndIndices (convertWebGlVertices vertices) (convertIndices indices) |> MeshBuilder.toWebGlMesh
                            )

                        Just (WithTextureAndTangent { vertices, indices }) ->
                            ( Mesh.fromVerticesAndIndices (convertVertices vertices) (convertIndices indices)
                            , MeshBuilder.VerticesAndIndices (convertWebGlVertices vertices) (convertIndices indices) |> MeshBuilder.toWebGlMesh
                            )

                        Nothing ->
                            ( Err Mesh.TriangleIsDegenerate, WebGL.triangles [] )

                Nothing ->
                    ( Err Mesh.TriangleIsDegenerate, WebGL.triangles [] )

        Err error ->
            ( Err Mesh.TriangleIsDegenerate, WebGL.triangles [] )


webGlMesh =
    Tuple.second meshObject


surfaceMesh =
    case meshObject of
        ( Ok a, _ ) ->
            a

        ( Err a, _ ) ->
            Mesh.defaultMesh
