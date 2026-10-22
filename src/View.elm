module View exposing (camera, cameraFocalPoint, cameraRay, cameraSketchPlane, view)

import Angle
import Axis2d
import Axis3d exposing (Axis3d)
import Basics.Extra exposing (flip)
import Camera3d exposing (Camera3d)
import Color
import Direction2d exposing (Direction2d)
import Direction3d exposing (Direction3d)
import Duration exposing (Duration)
import GameLogic
import Geometry.Interop.LinearAlgebra.Point2d as Point2d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Geometry.Interop.LinearAlgebra.Vector2d as Vector2d
import Html exposing (Html)
import Html.Attributes
import Length exposing (Length, Meters)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import Maybe.Extra as Maybe
import MeshBuilder exposing (Vertex)
import MeshData exposing (ScreenCoordinate, WorldCoordinate)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Point3d.Projection
import Quantity
import Rectangle2dEx as Rectangle2d
import SketchPlane3d
import Surface exposing (Surface, SurfacePoint)
import Vector2d
import Vector2i exposing (Vector2i)
import Vector3d
import Viewpoint3d exposing (Viewpoint3d)
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend
import WebGL.Settings.DepthTest
import WorldMesh exposing (WallVertex)


type alias Config a =
    { a
        | time : Duration
        , surface : Surface WorldCoordinate
        , surfacePoint : SurfacePoint
        , cameraNormal : Direction3d WorldCoordinate
        , cameraUp : Direction3d WorldCoordinate
        , windowSize : Vector2i Pixels ScreenCoordinate
        , moveAction : Maybe { direction : Direction2d ScreenCoordinate, endTime : Duration }
    }


view : Config a -> WebGL.Mesh Vertex -> WebGL.Mesh WallVertex -> Html msg
view config webGlMesh wallMesh =
    let
        ( windowWidth, windowHeight ) =
            Vector2i.toTuple Pixels.inPixels config.windowSize

        playerPosition =
            Surface.worldPosition config.surfacePoint config.surface

        camera_ =
            camera config

        cameraMatrix_ =
            camera_ |> Camera3d.viewMatrix
    in
    WebGL.toHtml
        [ Html.Attributes.width windowWidth
        , Html.Attributes.height windowHeight
        ]
        ([ entity
            worldVS
            worldFS
            webGlMesh
            (uniforms config cameraMatrix_ Mat4.identity)
         ]
            ++ (case playerPosition of
                    Just playerPosition_ ->
                        [ entity
                            worldVS
                            worldFS
                            playerMesh
                            (uniforms config cameraMatrix_ (playerPosition_ |> Point3d.toVec3 |> Mat4.makeTranslate))
                        , entity
                            wallVS
                            worldFS
                            wallMesh
                            { perspective = perspective config.windowSize
                            , camera = cameraMatrix_
                            , player = Point3d.toVec3 playerPosition_
                            , eyeHeight = Length.inMeters wallEyeHeight
                            }
                        ]

                    Nothing ->
                        []
               )
            ++ Maybe.toList (drawMoveAction config camera_)
        )


entity : Shader attributes uniforms varyings -> Shader {} uniforms varyings -> WebGL.Mesh attributes -> uniforms -> WebGL.Entity
entity =
    WebGL.entityWith
        [ WebGL.Settings.cullFace WebGL.Settings.back
        , Blend.add Blend.one Blend.oneMinusSrcAlpha
        , WebGL.Settings.DepthTest.less { write = True, near = 0.001, far = 10000 }
        ]


uiEntity =
    WebGL.entityWith
        [ Blend.add Blend.one Blend.oneMinusSrcAlpha
        , WebGL.Settings.DepthTest.always { write = False, near = 0.001, far = 10000 }
        ]


playerMesh : WebGL.Mesh Vertex
playerMesh =
    MeshBuilder.cube
        |> MeshBuilder.map
            (\a ->
                { color = Vec3.vec3 0.85 0.1 0.1
                , position =
                    Point3d.translateBy (Vector3d.meters -0.5 -0.5 -0.5) a
                        |> Point3d.scaleAbout Point3d.origin 0.1
                        |> Point3d.toVec3
                , normal = Vec3.vec3 0 0 1
                }
            )
        |> MeshBuilder.toWebGlMesh


cameraRay : Config a -> Point2d Pixels ScreenCoordinate -> Axis3d Meters WorldCoordinate
cameraRay config point =
    Camera3d.ray
        (camera config)
        (Rectangle2d.positionAndSize Point2d.origin (Vector2i.toVector2d config.windowSize))
        point


{-| A plane in front of the camera in world coordinates that's the same distance from the camera as the player
-}
cameraSketchPlane : Config a -> SketchPlane3d.SketchPlane3d Meters WorldCoordinate defines2
cameraSketchPlane config =
    camera config
        |> Camera3d.viewpoint
        |> Viewpoint3d.viewPlane
        |> SketchPlane3d.translateAlongOwn SketchPlane3d.normalAxis (Length.meters -2)


uniforms : Config a -> Mat4 -> Mat4 -> Uniforms
uniforms config cameraMatrix_ local =
    { local = local
    , perspective = perspective config.windowSize
    , camera = cameraMatrix_
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


cameraFocalPoint : Config a -> Maybe (Point3d Meters WorldCoordinate)
cameraFocalPoint config =
    Surface.worldPosition config.surfacePoint config.surface


camera : Config a -> Camera3d Meters WorldCoordinate
camera config =
    let
        distance =
            Length.meters 2

        viewpoint =
            case cameraFocalPoint config of
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


colorToVec4 color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Vec4.vec4 (red * alpha) (green * alpha) (blue * alpha) alpha


type alias Uniforms =
    { local : Mat4
    , perspective : Mat4
    , camera : Mat4
    }


type alias MoveActionVertex =
    { position : Vec2
    , t : Float
    }


type alias MoveActionUniforms =
    { start : Vec2
    , end : Vec2
    , camera : Mat4
    , perspective : Mat4
    , color : Vec4
    }


drawMoveAction : Config a -> Camera3d Meters WorldCoordinate -> Maybe WebGL.Entity
drawMoveAction config camera_ =
    let
        { x, y } =
            Vector2i.toPixels config.windowSize
    in
    case config.moveAction of
        Just moveAction ->
            let
                distance : Length
                distance =
                    moveAction.endTime |> Quantity.minus config.time |> Quantity.at GameLogic.playerSpeed |> Quantity.max Quantity.zero

                fadeStart : Length
                fadeStart =
                    Length.meters 0.1

                endPoint =
                    Point2d.origin
                        |> Point2d.translateIn (moveAction.direction |> Direction2d.mirrorAcross Axis2d.x) distance
                        |> Point3d.on (cameraSketchPlane config)
                        |> Point3d.Projection.toScreenSpace camera_ (Rectangle2d.positionAndSize Point2d.origin (Vector2i.toVector2d config.windowSize))
                        |> Maybe.withDefault Point2d.origin
                        |> Point2d.toVec2
            in
            uiEntity
                moveActionVS
                moveActionFS
                moveActionMesh
                { start = Vec2.vec2 (x // 2 |> toFloat) (y // 2 |> toFloat)
                , end = endPoint
                , camera =
                    Viewpoint3d.lookAt
                        { eyePoint = Point3d.meters 0 0 1
                        , focalPoint = Point3d.origin
                        , upDirection = Direction3d.y
                        }
                        |> Viewpoint3d.viewMatrix
                , color = Color.rgba 1 0 0 (Quantity.ratio distance fadeStart |> min 1) |> colorToVec4
                , perspective = Mat4.makeOrtho2D 0 (toFloat x) (toFloat y) 0
                }
                |> Just

        Nothing ->
            Nothing


moveActionMesh : WebGL.Mesh MoveActionVertex
moveActionMesh =
    let
        count =
            6

        mapCircle scale index circle =
            circle
                |> MeshBuilder.map
                    (\p ->
                        let
                            { x, y } =
                                Point2d.unwrap p
                        in
                        { position = Vec2.vec2 (x * scale) (y * scale), t = toFloat index / (count - 1) }
                    )
    in
    MeshBuilder.hollowCircle 12 0.5
        |> List.repeat (count - 1)
        |> List.indexedMap (mapCircle 5)
        |> (::) (MeshBuilder.hollowCircle 16 0.7 |> mapCircle 10 (count - 1))
        |> MeshBuilder.Compound
        |> MeshBuilder.toWebGlMesh


moveActionVS : Shader MoveActionVertex MoveActionUniforms { vcolor : Vec4 }
moveActionVS =
    [glsl|
        attribute vec2 position;
        attribute float t;
        uniform vec2 start;
        uniform vec2 end;
        uniform mat4 camera;
        uniform mat4 perspective;
        uniform vec4 color;
        varying vec4 vcolor;
        void main () {
            gl_Position = perspective * camera * vec4(((end - start) * t) + position + start, 0.0, 1.0);
            vcolor = color;
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


worldVS : Shader Vertex Uniforms { color_ : Vec3, normal_ : Vec3 }
worldVS =
    [glsl|
        attribute vec3 position;
        attribute vec3 normal;
        attribute vec3 color;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform mat4 local;
        varying vec3 color_;
        varying vec3 normal_;
        void main () {
            gl_Position = perspective * camera * local * vec4(position, 1.0);
            color_ = color;
            normal_ = normal;
        }
    |]


{-| Lit from one side, softly, so that the shape of things shows without anything going dark.
-}
worldFS : Shader {} u { color_ : Vec3, normal_ : Vec3 }
worldFS =
    [glsl|
        precision mediump float;
        varying vec3 color_;
        varying vec3 normal_;
        void main () {
            vec3 light = normalize(vec3(0.4, 1.0, 0.3));
            float shade = 0.75 + 0.25 * dot(normalize(normal_), light);
            gl_FragColor = vec4(color_ * shade, 1.0);
        }
    |]


{-| How high above the player the eye is that the walls are drawn from. The lower it is, the further
the walls' tops and sides spread out on the surface.
-}
wallEyeHeight : Length
wallEyeHeight =
    Length.meters 0.4


{-| The walls are drawn flat on the surface, like a picture painted on the ground that looks 3D from
one spot: an eye `wallEyeHeight` above the player.

The surface curves, so each wall is drawn as if the ground were flat between the player and it: the
player stands `distance` back from where the wall stands, in the direction away from the player along
the surface there, and the eye is above that. Each corner is drawn where the line from that eye
through it meets the ground, so walls lean straight away from the player, more the further away they
are. Corners are kept below 80% of the eye's height, so tall walls don't stretch away forever, and
are moved no further from where they stand than the surface stays flat (`reach`), so that they don't
hang off edges or float over curves.

Walls overlap on the surface, so their depth is set by how far from the eye they are rather than
where they're drawn: nearer is on top. All of it is a few millimeters above the surface, so it's
drawn over the paving.

-}
wallVS : Shader WallVertex { perspective : Mat4, camera : Mat4, player : Vec3, eyeHeight : Float } { color_ : Vec3, normal_ : Vec3 }
wallVS =
    [glsl|
        attribute vec3 position;
        attribute vec3 normal;
        attribute vec3 color;
        attribute vec3 base;
        attribute vec3 up;
        attribute float reach;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform vec3 player;
        uniform float eyeHeight;
        varying vec3 color_;
        varying vec3 normal_;
        void main () {
            vec3 fromPlayer = base - player;
            vec3 away = fromPlayer - dot(fromPlayer, up) * up;
            float awayLength = length(away);
            vec3 foot = awayLength > 0.0 ? base - away * (length(fromPlayer) / awayLength) : base;
            vec3 eye = foot + eyeHeight * up;
            float height = dot(position - base, up);
            float k = clamp(height / eyeHeight, 0.0, 0.8);
            vec3 onSurface = position - height * up;
            vec3 shift = (onSurface - foot) * k / (1.0 - k);
            float shiftLength = length(shift);
            if (shiftLength > reach) {
                shift *= reach / shiftLength;
            }
            vec3 image = onSurface + shift + 0.004 * up;
            vec4 clip = perspective * camera * vec4(image, 1.0);
            clip.z -= 0.0001 * (1.0 + 4.0 / (1.0 + distance(position, eye))) * clip.w;
            gl_Position = clip;
            color_ = color;
            normal_ = normal;
        }
    |]
