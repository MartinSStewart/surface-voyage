module MeshData exposing (ScreenCoordinate, WorldCoordinate, minimapMeshes, surface, webGlMesh)

import Array exposing (Array)
import Dict
import Geometry.Interop.LinearAlgebra.Direction3d as Direction3d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Math.Vector2 as Vec2
import Math.Vector3 as Vec3
import MeshBuilder exposing (Vertex)
import Minimap
import OBJ
import OBJ.Types exposing (Mesh(..))
import ObjData
import Surface exposing (Surface)
import WebGL
import World


type WorldCoordinate
    = WorldCoordinate Never


type ScreenCoordinate
    = ScreenCoordinate Never


surface : Result Surface.Error (Surface WorldCoordinate)
surface =
    World.surface


getVerticesAndIndices : Mesh -> { vertices : List Vertex, indices : List ( Int, Int, Int ) }
getVerticesAndIndices mesh =
    case mesh of
        WithTexture { vertices, indices } ->
            { vertices =
                vertices
                    |> List.map (\v -> { position = v.position, normal = v.normal, uv = v.texCoord })
            , indices = reverseIndices indices
            }

        WithoutTexture { vertices, indices } ->
            { vertices =
                vertices
                    |> List.map (\v -> { position = v.position, normal = Vec3.vec3 0 0 0, uv = Vec2.vec2 0 0 })
            , indices = reverseIndices indices
            }

        WithTextureAndTangent { vertices, indices } ->
            { vertices =
                vertices
                    |> List.map (\v -> { position = v.position, normal = v.normal, uv = v.texCoord })
            , indices = reverseIndices indices
            }


reverseIndices : List ( Int, Int, Int ) -> List ( Int, Int, Int )
reverseIndices indices =
    List.map (\( v0, v1, v2 ) -> ( v2, v1, v0 )) indices


{-| Move a vertex of the Blender model onto the surface, so that what you see is where you walk.
The model keeps its triangles and texture coordinates.
-}
snapToSurface : Surface WorldCoordinate -> Vertex -> Vertex
snapToSurface surface_ vertex =
    case Surface.nearestPoint (Point3d.fromVec3 vertex.position) surface_ of
        Just { position, normal } ->
            { vertex | position = Point3d.toVec3 position, normal = Direction3d.toVec3 normal }

        Nothing ->
            vertex


{-| The world model's vertices, moved onto the surface, and its triangles.
-}
model : { vertices : List Vertex, indices : List ( Int, Int, Int ) }
model =
    case OBJ.parseObjStringWith OBJ.defaultSettings ObjData.objData of
        Ok objFile ->
            case objFile |> Dict.values |> List.head |> Maybe.andThen (Dict.values >> List.head) of
                Just mesh ->
                    let
                        { vertices, indices } =
                            getVerticesAndIndices mesh
                    in
                    { vertices =
                        case surface of
                            Ok surface_ ->
                                List.map (snapToSurface surface_) vertices

                            Err _ ->
                                vertices
                    , indices = indices
                    }

                Nothing ->
                    { vertices = [], indices = [] }

        Err _ ->
            { vertices = [], indices = [] }


{-| The textured world model.
-}
webGlMesh : WebGL.Mesh Vertex
webGlMesh =
    MeshBuilder.VerticesAndIndices model.vertices model.indices |> MeshBuilder.toWebGlMesh


{-| The textured world model cut up by surface piece, for drawing the minimap.
-}
minimapMeshes : Minimap.Meshes
minimapMeshes =
    case surface of
        Ok surface_ ->
            let
                vertices =
                    Array.fromList model.vertices
            in
            model.indices
                |> List.filterMap
                    (\( i0, i1, i2 ) ->
                        Maybe.map3 (\v0 v1 v2 -> ( v0, v1, v2 ))
                            (Array.get i0 vertices)
                            (Array.get i1 vertices)
                            (Array.get i2 vertices)
                    )
                |> Minimap.meshes surface_

        Err _ ->
            Minimap.emptyMeshes
