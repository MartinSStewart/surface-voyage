module View exposing (camera, cameraFocalPoint, view)

import Angle
import Camera3d exposing (Camera3d)
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html exposing (Html)
import Html.Attributes
import Length exposing (Meters)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 exposing (Vec4)
import MeshBuilder exposing (Vertex)
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Pixels exposing (Pixels)
import Point3d exposing (Point3d)
import SurfaceMesh.Mesh exposing (Mesh)
import SurfaceMesh.SurfacePoint as SurfacePoint exposing (SurfacePoint)
import Vector2i exposing (Vector2i)
import Vector3d
import Viewpoint3d exposing (Viewpoint3d)
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend
import WebGL.Settings.DepthTest
import WebGL.Texture exposing (Texture)


type alias Config a =
    { a
        | time : Duration
        , surfacePoint : SurfacePoint Meters
        , cameraNormal : Direction3d WorldCoordinate
        , cameraUp : Direction3d WorldCoordinate
        , windowSize : Vector2i Pixels ScreenCoordinate
        , texture : Texture
    }


view : Config a -> WebGL.Mesh Vertex -> Mesh Meters WorldCoordinate -> Html msg
view config webGlMesh mesh =
    let
        ( windowWidth, windowHeight ) =
            Vector2i.toTuple Pixels.inPixels config.windowSize

        playerPosition =
            SurfacePoint.worldPosition config.surfacePoint mesh

        cameraMatrix_ =
            camera config mesh |> Camera3d.viewMatrix
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


entity : Shader attributes uniforms varyings -> Shader {} uniforms varyings -> WebGL.Mesh attributes -> uniforms -> WebGL.Entity
entity =
    WebGL.entityWith
        [ WebGL.Settings.cullFace WebGL.Settings.back
        , Blend.add Blend.one Blend.oneMinusSrcAlpha
        , WebGL.Settings.DepthTest.less { write = True, near = 0.001, far = 10000 }
        ]


playerMesh : WebGL.Mesh { uv : Vec2.Vec2, position : Vec3, normal : Vec3 }
playerMesh =
    MeshBuilder.cube
        |> MeshBuilder.map
            (\a ->
                { uv = Vec2.vec2 1 1
                , position =
                    Point3d.translateBy (Vector3d.meters -0.5 -0.5 -0.5) a
                        |> Point3d.scaleAbout Point3d.origin 0.1
                        |> Point3d.toVec3
                , normal = Vec3.vec3 0 0 1
                }
            )
        |> MeshBuilder.toWebGlMesh


uniforms : Config a -> Mat4 -> Mat4 -> Uniforms
uniforms config cameraMatrix_ local =
    { local = local
    , perspective = perspective config.windowSize
    , camera = cameraMatrix_
    , texture = config.texture
    }


fieldOfView =
    Angle.degrees 60


perspective : Vector2i Pixels ScreenCoordinate -> Mat4
perspective windowSize =
    let
        ( windowWidth, windowHeight ) =
            Vector2i.toTuple Pixels.inPixels windowSize
    in
    Mat4.makePerspective
        (Angle.inDegrees fieldOfView)
        ((max 1 windowWidth |> toFloat) / (max 1 windowHeight |> toFloat))
        0.1
        100


cameraFocalPoint : Config a -> Mesh Meters WorldCoordinate -> Maybe (Point3d Meters WorldCoordinate)
cameraFocalPoint config mesh =
    SurfacePoint.worldPosition config.surfacePoint mesh


camera : Config a -> Mesh Meters WorldCoordinate -> Camera3d Meters WorldCoordinate
camera config mesh =
    let
        distance =
            Length.meters 2

        viewpoint =
            case cameraFocalPoint config mesh of
                Just playerPosition_ ->
                    Viewpoint3d.lookAt
                        { eyePoint = Point3d.translateIn config.cameraNormal distance playerPosition_
                        , focalPoint = playerPosition_
                        , upDirection = config.cameraUp
                        }

                _ ->
                    Viewpoint3d.lookAt
                        { eyePoint = Point3d.meters 0 0 2
                        , focalPoint = Point3d.origin
                        , upDirection = Direction3d.y
                        }
    in
    Camera3d.perspective { viewpoint = viewpoint, clipDepth = Length.meters 0.01, verticalFieldOfView = fieldOfView }


type alias Uniforms =
    { local : Mat4
    , perspective : Mat4
    , camera : Mat4
    , texture : Texture
    }


type alias MoveActionVertex =
    { position : Vec3
    , t : Float
    }


type alias MoveActionUniforms =
    { start : Vec2
    , end : Vec2
    , camera : Mat4
    }


moveActionVS : Shader MoveActionVertex MoveActionUniforms { vcolor : Vec4 }
moveActionVS =
    [glsl|
        attribute vec3 position;
        attribute float t;
        uniform vec2 start;
        uniform vec2 end;
        varying vec4 vcolor;
        void main () {
            gl_Position = perspective * camera * local * vec4(position, 1.0);
            vcolor = uv;
        }
    |]


moveActionFS : Shader {} MoveActionUniforms { vcolor : Vec4 }
moveActionFS =
    [glsl|
        precision mediump float;
        varying vec4 vcolor;
        void main () {
            gl_FragColor = vcolor;
        }
    |]


vertexShader : Shader Vertex Uniforms { uv_ : Vec2 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec2 uv;
        attribute vec3 normal;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform mat4 local;
        varying vec2 uv_;
        void main () {
            gl_Position = perspective * camera * local * vec4(position, 1.0);
            uv_ = uv;
        }
    |]


fragmentShader : Shader {} Uniforms { uv_ : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        uniform sampler2D texture;
        varying vec2 uv_;
        void main () {
            gl_FragColor = texture2D(texture, uv_);
        }
    |]
