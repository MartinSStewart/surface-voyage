module MeshData exposing (..)

import Color
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Length exposing (Meters)
import List.Nonempty
import Math.Vector3 as Vec3
import Math.Vector4 as Vec4
import Mesh
import MeshBuilder exposing (Vertex)
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


surfaceCube : Result Mesh.Error (Mesh.Mesh Meters WorldCoordinate)
surfaceCube =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices baseCube
    in
    Mesh.fromVerticesAndIndices verts indices
