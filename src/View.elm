module View exposing (view)

import Angle
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import Element exposing (Element)
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Geometry.Interop.LinearAlgebra.Vector3d as Vector3d
import Html.Attributes
import Length exposing (Meters)
import LineSegment3d
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import MeshBuilder
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Pixels exposing (Pixels)
import Point3d exposing (Point3d)
import Polyline3d
import Quantity
import SurfaceMesh.Mesh as Mesh exposing (Mesh)
import SurfaceMesh.Path as Path
import SurfaceMesh.SurfacePoint as SurfacePoint exposing (SurfacePoint)
import Vector2i exposing (Vector2i)
import Vector3d
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend
import WebGL.Settings.DepthTest


type alias Config a =
    { a
        | time : Duration
        , surfacePoint : SurfacePoint Meters
        , cameraNormal : Direction3d WorldCoordinate
        , cameraUp : Direction3d WorldCoordinate

        --, mesh : Mesh Meters WorldCoordinate
        --, webGlMesh : WebGL.Mesh Vertex
        , windowSize : Vector2i Pixels ScreenCoordinate
    }


view : Config a -> WebGL.Mesh Vertex -> Mesh Meters WorldCoordinate -> Element msg
view config webGlMesh mesh =
    let
        ( windowWidth, windowHeight ) =
            Vector2i.toTuple Pixels.inPixels config.windowSize

        playerPosition =
            SurfacePoint.worldPosition config.surfacePoint mesh

        cameraMatrix_ =
            cameraMatrix config mesh
    in
    WebGL.toHtml
        [ Html.Attributes.width windowWidth
        , Html.Attributes.height windowHeight
        ]
        ([ entity
            vertexShader
            fragmentShader
            webGlMesh
            (uniforms config cameraMatrix_ Mat4.identity)
         ]
            ++ (case playerPosition of
                    Just playerPosition_ ->
                        [ entity
                            vertexShader
                            fragmentShader
                            playerMesh
                            (uniforms config cameraMatrix_ (playerPosition_ |> Point3d.toVec3 |> Mat4.makeTranslate))
                        ]

                    Nothing ->
                        []
               )
        )
        |> Element.html


entity =
    WebGL.entityWith
        [ WebGL.Settings.cullFace WebGL.Settings.back
        , Blend.add Blend.one Blend.oneMinusSrcAlpha
        , WebGL.Settings.DepthTest.less { write = True, near = 0.001, far = 10000 }
        ]


playerMesh =
    MeshBuilder.cube
        |> MeshBuilder.map
            (\a ->
                { color = Vec4.vec4 0 0 0 1
                , position =
                    Point3d.translateBy (Vector3d.meters -0.5 -0.5 -0.5) a
                        |> Point3d.scaleAbout Point3d.origin 0.1
                        |> Point3d.toVec3
                , normal = Vec3.vec3 0 0 1
                }
            )
        |> MeshBuilder.toWebGlMesh


uniforms : Config a -> Mat4 -> Mat4 -> Uniforms
uniforms confg cameraMatrix_ local =
    { local = local
    , perspective = perspective confg.windowSize
    , camera = cameraMatrix_
    }


perspective : Vector2i Pixels ScreenCoordinate -> Mat4
perspective windowSize =
    let
        ( windowWidth, windowHeight ) =
            Vector2i.toTuple Pixels.inPixels windowSize
    in
    Mat4.makePerspective
        60
        ((max 1 windowWidth |> toFloat) / (max 1 windowHeight |> toFloat))
        0.1
        100


cameraMatrix : Config a -> Mesh Meters WorldCoordinate -> Mat4
cameraMatrix config mesh =
    let
        distance =
            2

        playerPosition =
            SurfacePoint.worldPosition config.surfacePoint mesh
    in
    case playerPosition of
        Just playerPosition_ ->
            let
                cameraPosition =
                    Point3d.translateIn config.cameraNormal (Length.meters 2) playerPosition_ |> Point3d.toVec3

                up =
                    Vector3d.withLength (Length.meters 1) config.cameraUp |> Vector3d.toVec3
            in
            Mat4.makeLookAt
                cameraPosition
                (Point3d.toVec3 playerPosition_)
                up

        _ ->
            Mat4.makeLookAt
                (Vec3.vec3 0 0 2)
                (Vec3.vec3 0.5 0.5 0.5)
                (Vec3.vec3 0 0 1)


type alias Uniforms =
    { local : Mat4
    , perspective : Mat4
    , camera : Mat4
    }


type alias Vertex =
    { color : Vec4
    , position : Vec3
    , normal : Vec3
    }


vertexShader : Shader Vertex Uniforms { vcolor : Vec4 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec4 color;
        attribute vec3 normal;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform mat4 local;
        varying vec4 vcolor;
        void main () {
            gl_Position = perspective * camera * local * vec4(position, 1.0);
            vcolor = color;
        }
    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec4 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec4 vcolor;
        void main () {
            gl_FragColor = vcolor;
        }
    |]
