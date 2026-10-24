module View exposing (Layer, camera, cameraFocalPoint, cameraRay, cameraSketchPlane, view)

import Angle
import Axis3d exposing (Axis3d)
import Basics.Extra exposing (flip)
import Buildings
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
        , cameraPitch : Float
        , windowSize : Vector2i Pixels ScreenCoordinate
        , moveAction : Maybe { direction : Direction2d ScreenCoordinate, endTime : Duration }
        , height : Float
    }


{-| What's drawn flat on the surface in one storey (see `Buildings.storey`): the walls and stairs that
stand on it, and the roofs on top of them.
-}
type alias Layer =
    { walls : List (WebGL.Mesh WallVertex)
    , roofs : List ( Buildings.Roof, WebGL.Mesh WallVertex )
    }


{-| The world and what's on it (paths, say), then each storey from the ground up, so that each roof
covers what's under it and what stands on it shows over it. Then what's being placed, and the
player, squashed down when they're crouching.
-}
view :
    Config a
    ->
        { world : List (WebGL.Mesh Vertex)
        , layers : List Layer
        , preview : List (WebGL.Mesh WallVertex)
        , player : WebGL.Mesh WallVertex
        , crouching : Bool
        }
    -> Html msg
view config meshes =
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
        (List.map (\mesh -> entity worldVS worldFS mesh (uniforms config cameraMatrix_ Mat4.identity)) meshes.world
            ++ (case playerPosition of
                    Just playerPosition_ ->
                        let
                            flatUniforms =
                                { perspective = perspective config.windowSize
                                , camera = cameraMatrix_
                                , player = Point3d.toVec3 playerPosition_
                                , eyeHeight = Length.inMeters wallEyeHeight + config.height
                                , maxShift = Length.inMeters wallMaxShift
                                , local = Mat4.identity
                                , lift = 0
                                , layer = 0
                                }
                        in
                        List.concatMap
                            (\( index, layer ) ->
                                List.map (\walls -> entity wallVS worldFS walls { flatUniforms | layer = toFloat index }) layer.walls
                                    ++ List.filterMap
                                        (\( roof, mesh ) ->
                                            if Buildings.underRoof config.height (Point3d.toMeters playerPosition_) roof then
                                                -- So the player can see inside
                                                Nothing

                                            else
                                                Just (roofEntity wallVS worldFS mesh flatUniforms)
                                        )
                                        layer.roofs
                            )
                            (List.indexedMap Tuple.pair meshes.layers)
                            -- What's being placed shows over everything
                            ++ List.map (\mesh -> entity wallVS worldFS mesh { flatUniforms | layer = toFloat (List.length meshes.layers) }) meshes.preview
                            ++ (case playerFrame config playerPosition_ of
                                    Just frame ->
                                        let
                                            squashed =
                                                if meshes.crouching then
                                                    Mat4.scale3 1 1 crouchHeight frame

                                                else
                                                    frame
                                        in
                                        [ entity wallVS worldFS meshes.player { flatUniforms | local = squashed, lift = config.height, layer = toFloat (round (config.height / Buildings.storey)) } ]

                                    Nothing ->
                                        []
                               )

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


{-| Roofs cover whatever is drawn flat under them, so they're drawn over it regardless of depth.
-}
roofEntity : Shader attributes uniforms varyings -> Shader {} uniforms varyings -> WebGL.Mesh attributes -> uniforms -> WebGL.Entity
roofEntity =
    WebGL.entityWith
        [ WebGL.Settings.cullFace WebGL.Settings.back
        , Blend.add Blend.one Blend.oneMinusSrcAlpha
        , WebGL.Settings.DepthTest.always { write = False, near = 0.001, far = 10000 }
        ]


uiEntity =
    WebGL.entityWith
        [ Blend.add Blend.one Blend.oneMinusSrcAlpha
        , WebGL.Settings.DepthTest.always { write = False, near = 0.001, far = 10000 }
        ]


{-| How much shorter the player is while crouching
-}
crouchHeight : Float
crouchHeight =
    0.6


{-| Where the player is standing and which way they face: right, forward and the surface's outward
normal there are x, y and z.
-}
playerFrame : Config a -> Point3d Meters WorldCoordinate -> Maybe Mat4
playerFrame config position =
    Maybe.map2
        (\forward up ->
            let
                f =
                    Direction3d.unwrap forward |> Vec3.fromRecord

                u =
                    Direction3d.unwrap up |> Vec3.fromRecord
            in
            Mat4.mul
                (Point3d.toVec3 position |> Mat4.makeTranslate)
                (Mat4.makeBasis (Vec3.cross f u) f u)
        )
        (Surface.worldDirection config.surface config.surfacePoint)
        (Surface.normal config.surface config.surfacePoint)


{-| The ray from the camera through a point on the screen (in page coordinates, y down)
-}
cameraRay : Config a -> Point2d Pixels ScreenCoordinate -> Axis3d Meters WorldCoordinate
cameraRay config point =
    Camera3d.ray
        (camera config)
        (Rectangle2d.positionAndSize Point2d.origin (Vector2i.toVector2d config.windowSize))
        (flipScreenY config point)


{-| Page coordinates have y down, `Camera3d` screen coordinates have it up
-}
flipScreenY : Config a -> Point2d Pixels ScreenCoordinate -> Point2d Pixels ScreenCoordinate
flipScreenY config point =
    Point2d.xy
        (Point2d.xCoordinate point)
        (Vector2i.toVector2d config.windowSize |> Vector2d.yComponent |> Quantity.minus (Point2d.yCoordinate point))


{-| The ground plane under the camera in world coordinates: through the player, with x to the right on
screen and y forward. Looking straight down, it's the camera's view plane moved to the player.
-}
cameraSketchPlane : Config a -> SketchPlane3d.SketchPlane3d Meters WorldCoordinate defines2
cameraSketchPlane config =
    let
        plane =
            camera config
                |> Camera3d.viewpoint
                |> Viewpoint3d.viewPlane
                |> SketchPlane3d.translateAlongOwn SketchPlane3d.normalAxis (Quantity.negate cameraDistance)
    in
    plane |> SketchPlane3d.rotateAround (SketchPlane3d.xAxis plane) (Angle.radians -config.cameraPitch)


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


cameraDistance : Length
cameraDistance =
    Length.meters 2


{-| The camera looks at the player from `cameraDistance` away: straight down at them, or tilted
back by `cameraPitch` to look ahead.
-}
camera : Config a -> Camera3d Meters WorldCoordinate
camera config =
    let
        viewpoint =
            case cameraFocalPoint config of
                Just playerPosition_ ->
                    let
                        n =
                            Direction3d.toVector config.cameraNormal

                        u =
                            Direction3d.toVector config.cameraUp

                        tilted a b =
                            Vector3d.plus (Vector3d.scaleBy (cos config.cameraPitch) a) (Vector3d.scaleBy (sin config.cameraPitch) b)
                                |> Vector3d.direction
                    in
                    Viewpoint3d.lookAt
                        { eyePoint =
                            Point3d.translateIn
                                (tilted n (Vector3d.reverse u) |> Maybe.withDefault config.cameraNormal)
                                cameraDistance
                                playerPosition_
                        , focalPoint = playerPosition_
                        , upDirection = tilted u n |> Maybe.withDefault config.cameraUp
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
                        |> Point2d.translateIn moveAction.direction distance
                        |> Point3d.on (cameraSketchPlane config)
                        |> Point3d.Projection.toScreenSpace camera_ (Rectangle2d.positionAndSize Point2d.origin (Vector2i.toVector2d config.windowSize))
                        |> Maybe.withDefault Point2d.origin
                        |> flipScreenY config
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


{-| How high above the player the eye is that the walls are drawn from (more when the player is up
on something). The lower it is, the further the walls' tops and sides spread out on the surface.
-}
wallEyeHeight : Length
wallEyeHeight =
    Length.meters 1


{-| The furthest a wall's corner can be drawn from where it would be without perspective, so walls
far from the player don't stretch out too far.
-}
wallMaxShift : Length
wallMaxShift =
    Length.meters 1


{-| The walls are drawn flat on the surface, like a picture painted on the ground that looks 3D from
one spot: an eye `wallEyeHeight` above the player.

The surface curves, so each wall is drawn as if the ground were flat between the player and it: the
player stands `distance` back from where the wall stands, in the direction away from the player along
the surface there, and the eye is above that. Each corner is drawn where the line from that eye
through it meets the ground, so walls lean straight away from the player, more the further away they
are. Corners are kept below 80% of the eye's height, so tall walls don't stretch away forever, and
are moved no more than `maxShift`, so far away walls don't either. They're drawn in the tangent plane where the wall stands, however far that is from it, so near edges
and curves they can hang off the surface or sink into it.

Walls overlap on the surface, so their depth is set by how far from the eye they are rather than
where they're drawn: nearer is on top. And each storey (`layer`, see `Layer`) is on top of the ones
below it, as the walls under a roof would otherwise poke through the walls standing on it. All of it is a few millimeters above the surface, so it's
drawn over the paving.

The player is drawn the same way, from a mesh made where they stand (see `WorldMesh.playerMesh`):
`local` moves it there and `lift` raises it by how high they are. For everything else they're the
identity and 0.

-}
wallVS : Shader WallVertex { perspective : Mat4, camera : Mat4, player : Vec3, eyeHeight : Float, maxShift : Float, local : Mat4, lift : Float, layer : Float } { color_ : Vec3, normal_ : Vec3 }
wallVS =
    [glsl|
        attribute vec3 position;
        attribute vec3 normal;
        attribute vec3 color;
        attribute vec3 base;
        attribute vec3 up;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform vec3 player;
        uniform float eyeHeight;
        uniform mat4 local;
        uniform float lift;
        uniform float layer;
        uniform float maxShift;
        varying vec3 color_;
        varying vec3 normal_;
        void main () {
            vec3 standsOn = (local * vec4(base, 1.0)).xyz;
            vec3 outward = normalize((local * vec4(up, 0.0)).xyz);
            vec3 corner = (local * vec4(position, 1.0)).xyz + lift * outward;
            vec3 fromPlayer = standsOn - player;
            vec3 away = fromPlayer - dot(fromPlayer, outward) * outward;
            float awayLength = length(away);
            vec3 foot = awayLength > 0.0 ? standsOn - away * (length(fromPlayer) / awayLength) : standsOn;
            vec3 eye = foot + eyeHeight * outward;
            float height = dot(corner - standsOn, outward);
            float k = clamp(height / eyeHeight, 0.0, 0.8);
            vec3 onSurface = corner - height * outward;
            vec3 shift = (onSurface - foot) * k / (1.0 - k);
            float shiftLength = length(shift);
            if (shiftLength > maxShift) {
                shift *= maxShift / shiftLength;
            }
            vec3 image = onSurface + shift + 0.004 * outward;
            vec4 clip = perspective * camera * vec4(image, 1.0);
            clip.z -= (0.0001 * (1.0 + 4.0 / (1.0 + distance(corner, eye))) + 0.001 * layer) * clip.w;
            gl_Position = clip;
            color_ = color;
            normal_ = (local * vec4(normal, 0.0)).xyz;
        }
    |]
