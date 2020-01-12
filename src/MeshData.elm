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
import ObjData
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


convertVertices : List Vec3.Vec3 -> Array.Array (Point3d.Point3d units coordinates)
convertVertices vertices =
    vertices |> List.map Point3d.fromVec3 |> Array.fromList


convertWebGlVertices : List Vec3.Vec3 -> List { color : Vec4.Vec4, position : Vec3.Vec3, normal : Vec3.Vec3 }
convertWebGlVertices vertices =
    vertices
        |> List.indexedMap
            (\index position ->
                { color = Random.initialSeed index |> Random.step randomColor |> Tuple.first |> colorToVec4
                , position = position
                , normal = Vec3.vec3 0 0 0
                }
            )


convertIndices : List (Triangle.Triangle a) -> List (Triangle.Triangle a)
convertIndices indices =
    indices |> List.map Triangle.reverse


type Error
    = ParseError
    | MeshError Mesh.Error


getVerticesAndIndices : Mesh -> { vertices : List Vec3.Vec3, indices : List (Triangle.Triangle Int) }
getVerticesAndIndices mesh =
    case mesh of
        WithTexture { vertices, indices } ->
            { vertices = List.map .position vertices, indices = convertIndices indices }

        WithoutTexture { vertices, indices } ->
            { vertices = List.map .position vertices, indices = convertIndices indices }

        WithTextureAndTangent { vertices, indices } ->
            { vertices = List.map .position vertices, indices = convertIndices indices }


parsedObj : Result Error ( Mesh.Mesh units coordinates, WebGL.Mesh Vertex )
parsedObj =
    case OBJ.parseObjStringWith OBJ.defaultSettings ObjData.objData of
        Ok objFile ->
            case objFile |> Dict.toList |> List.head |> Maybe.map Tuple.second of
                Just mesh ->
                    case mesh |> Dict.toList |> List.head |> Maybe.map Tuple.second of
                        Just mesh_ ->
                            let
                                { vertices, indices } =
                                    getVerticesAndIndices mesh_
                            in
                            case Mesh.fromVerticesAndIndices (convertVertices vertices) indices of
                                Ok surfaceMesh_ ->
                                    Ok
                                        ( surfaceMesh_
                                        , MeshBuilder.VerticesAndIndices (convertWebGlVertices vertices) indices |> MeshBuilder.toWebGlMesh
                                        )

                                Err error ->
                                    MeshError error |> Err

                        Nothing ->
                            Err ParseError

                Nothing ->
                    Err ParseError

        Err error ->
            Err ParseError


webGlMesh =
    case parsedObj of
        Ok ( _, a ) ->
            a

        Err _ ->
            WebGL.triangles []



--Tuple.second meshObject


surfaceMesh =
    case parsedObj of
        Ok ( a, _ ) ->
            a

        Err _ ->
            Mesh.defaultMesh
