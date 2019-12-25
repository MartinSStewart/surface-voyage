module View exposing (view)

import Duration exposing (Duration)
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html.Attributes
import Length exposing (Meters)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import Mesh exposing (SurfacePoint)
import MeshBuilder
import Point3d exposing (Point3d)
import Quantity exposing (Quantity)
import Vector3d
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend
import WebGL.Settings.DepthTest


type alias Config a =
    { a
        | time : Duration
        , surfacePoint : SurfacePoint Meters
    }


view config (( windowWidth, windowHeight ) as windowSize) mesh playerPosition =
    WebGL.toHtml
        [ Html.Attributes.width windowWidth
        , Html.Attributes.height windowHeight
        ]
        ([ entity
            vertexShader
            fragmentShader
            mesh
            (uniforms config.time Mat4.identity windowSize)
         ]
            ++ (case playerPosition of
                    Just playerPosition_ ->
                        [ entity
                            vertexShader
                            fragmentShader
                            playerMesh
                            (uniforms config.time (playerPosition_ |> Point3d.toVec3 |> Mat4.makeTranslate) windowSize)
                        ]

                    Nothing ->
                        []
               )
        )


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


uniforms : Duration -> Mat4 -> ( Int, Int ) -> Uniforms
uniforms time local windowSize =
    { local = local
    , perspective = perspective windowSize
    , camera = cameraMatrix time
    }


perspective : ( Int, Int ) -> Mat4
perspective ( windowWidth, windowHeight ) =
    Mat4.makePerspective
        60
        ((max 1 windowWidth |> toFloat) / (max 1 windowHeight |> toFloat))
        0.1
        100


cameraMatrix time =
    let
        time_ =
            Duration.inSeconds time

        distance =
            2
    in
    Mat4.makeLookAt
        (Vec3.vec3 (cos time_ * distance + 0.5) (sin time_ * distance + 0.5) 2)
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
