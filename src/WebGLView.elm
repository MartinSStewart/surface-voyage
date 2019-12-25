module WebGLView exposing (view)

import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html.Attributes
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import MeshBuilder
import Point3d exposing (Point3d)
import Quantity
import Vector3d
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend


view (( windowWidth, windowHeight ) as windowSize) mesh =
    WebGL.toHtml
        [ Html.Attributes.width windowWidth
        , Html.Attributes.height windowHeight
        ]
        [ WebGL.entityWith
            [ WebGL.Settings.cullFace WebGL.Settings.back
            , Blend.add Blend.one Blend.oneMinusSrcAlpha
            ]
            vertexShader
            fragmentShader
            mesh
            (uniforms windowSize)
        ]


uniforms : ( Int, Int ) -> Uniforms
uniforms windowSize =
    { rotation = Mat4.identity -- Mat4.makeRotate 40 (Vec3.vec3 0 1 1)
    , perspective = perspective windowSize
    , camera = cameraMatrix
    }


perspective : ( Int, Int ) -> Mat4
perspective ( windowWidth, windowHeight ) =
    Mat4.makePerspective
        60
        ((max 1 windowWidth |> toFloat) / (max 1 windowHeight |> toFloat))
        0.1
        100


cameraMatrix =
    Mat4.makeLookAt
        (Vec3.vec3 0 0 2)
        (Vec3.vec3 0 0 0)
        (Vec3.vec3 0 1 0)


type alias Uniforms =
    { rotation : Mat4
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
        uniform mat4 rotation;
        varying vec4 vcolor;
        void main () {
            gl_Position = perspective * camera * rotation * vec4(position, 1.0);
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
