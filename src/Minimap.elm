module Minimap exposing (Vertex, meshes, size, view)

{-| A map of the surface around the player, laid out flat with the player in the middle facing up.

Each piece of the surface has its own mesh, cut from the textured world model, whose vertices store
where they are in that piece's chart. Every frame `Surface.flattenAround` works out where each piece
goes on the map, and the vertex shader moves the vertices there. So the map follows the player
without rebuilding any meshes, and the texture comes along from the model's UVs.

-}

import Array exposing (Array)
import Environment
import Html exposing (Html)
import Html.Attributes
import Length exposing (Length)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import MeshBuilder
import Pixels exposing (Pixels)
import Point3d exposing (Point3d)
import Quantity exposing (Quantity)
import Surface exposing (Surface, SurfacePoint)
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend
import WebGL.Settings.DepthTest
import WebGL.Texture exposing (Texture)


size : Quantity Int Pixels
size =
    Pixels.pixels 220


{-| How far from the player the minimap shows
-}
viewRadius : Length
viewRadius =
    Length.meters 3


{-| Triangles longer than this are split before they go on the map. The map bends straight lines, so
long triangles would show the bend as a crease.
-}
maxEdgeLength : Float
maxEdgeLength =
    0.25


type alias Vertex =
    { chart : Vec2
    , uv : Vec2
    }


{-| One mesh per piece of the surface, made from the world model's triangles.
-}
meshes : Surface coordinates -> List ( MeshBuilder.Vertex, MeshBuilder.Vertex, MeshBuilder.Vertex ) -> Array (WebGL.Mesh Vertex)
meshes surface triangles =
    let
        toMapVertex piece vertex =
            let
                position =
                    Vec3.toRecord vertex.position

                chart =
                    Surface.chartCoordinate surface piece (Point3d.meters position.x position.y position.z)
            in
            { chart = Vec2.vec2 chart.re chart.im, uv = vertex.uv }

        byPiece =
            List.concatMap split triangles
                |> List.foldl
                    (\(( v0, v1, v2 ) as triangle) pieces ->
                        let
                            centroid =
                                Vec3.add v0.position v1.position |> Vec3.add v2.position |> Vec3.scale (1 / 3) |> Vec3.toRecord
                        in
                        case Surface.nearestPiece (Point3d.meters centroid.x centroid.y centroid.z) surface of
                            Just piece ->
                                Array.set
                                    piece
                                    (( toMapVertex piece v0, toMapVertex piece v1, toMapVertex piece v2 )
                                        :: (Array.get piece pieces |> Maybe.withDefault [])
                                    )
                                    pieces

                            Nothing ->
                                pieces
                    )
                    (Array.repeat (Surface.pieceCount surface) [])
    in
    Array.map WebGL.triangles byPiece


split : ( MeshBuilder.Vertex, MeshBuilder.Vertex, MeshBuilder.Vertex ) -> List ( MeshBuilder.Vertex, MeshBuilder.Vertex, MeshBuilder.Vertex )
split ( v0, v1, v2 ) =
    let
        d01 =
            Vec3.distance v0.position v1.position

        d12 =
            Vec3.distance v1.position v2.position

        d20 =
            Vec3.distance v2.position v0.position

        midpoint a b =
            { position = Vec3.add a.position b.position |> Vec3.scale 0.5
            , normal = a.normal
            , uv = Vec2.add a.uv b.uv |> Vec2.scale 0.5
            }
    in
    if max d01 (max d12 d20) <= maxEdgeLength then
        [ ( v0, v1, v2 ) ]

    else if d01 >= d12 && d01 >= d20 then
        split ( v0, midpoint v0 v1, v2 ) ++ split ( midpoint v0 v1, v1, v2 )

    else if d12 >= d20 then
        split ( v0, v1, midpoint v1 v2 ) ++ split ( v0, midpoint v1 v2, v2 )

    else
        split ( v0, v1, midpoint v2 v0 ) ++ split ( midpoint v2 v0, v1, v2 )


view : Surface coordinates -> Array (WebGL.Mesh Vertex) -> Texture -> SurfacePoint -> Html msg
view surface pieceMeshes texture surfacePoint =
    let
        sizeInPixels =
            Pixels.inPixels size

        radius =
            Length.inMeters viewRadius

        placements =
            Surface.flattenAround radius surfacePoint surface

        terrain index placement =
            case Array.get placement.piece pieceMeshes of
                Just mesh ->
                    Just
                        (WebGL.entityWith
                            [ WebGL.Settings.DepthTest.less { write = True, near = 0, far = 1 } ]
                            terrainVS
                            terrainFS
                            mesh
                            { texture = texture
                            , exponent = placement.exponent
                            , mobiusA = complex placement.mobius.a
                            , mobiusB = complex placement.mobius.b
                            , mobiusC = complex placement.mobius.c
                            , mobiusD = complex placement.mobius.d
                            , scale = 1 / radius
                            , distance = placement.distance / radius + toFloat index * 1.0e-4
                            , window = Vec2.vec2 placement.window.center placement.window.halfWidth
                            , tint = tint index
                            }
                        )

                Nothing ->
                    Nothing
    in
    WebGL.toHtmlWith
        [ WebGL.alpha True, WebGL.antialias, WebGL.depth 1, WebGL.clearColor 0.12 0.14 0.18 1 ]
        [ Html.Attributes.width sizeInPixels
        , Html.Attributes.height sizeInPixels
        , Html.Attributes.style "display" "block"
        ]
        (List.indexedMap terrain placements
            |> List.filterMap identity
            |> (\entities ->
                    entities
                        ++ [ WebGL.entityWith
                                [ Blend.add Blend.one Blend.oneMinusSrcAlpha ]
                                markerVS
                                markerFS
                                playerMarker
                                {}
                           ]
               )
        )


{-| In debug builds each placed piece is tinted a different colour, to show how the map is pieced
together.
-}
tint : Int -> Vec4
tint index =
    if Environment.isDebug then
        let
            hue =
                toFloat index * 0.618034 - toFloat (floor (toFloat index * 0.618034))
        in
        Vec4.vec4 (0.5 + 0.5 * cos (2 * pi * hue)) (0.5 + 0.5 * cos (2 * pi * (hue - 1 / 3))) (0.5 + 0.5 * cos (2 * pi * (hue - 2 / 3))) 0.4

    else
        Vec4.vec4 0 0 0 0


complex : Surface.Complex -> Vec2
complex { re, im } =
    Vec2.vec2 re im


type alias Uniforms =
    { texture : Texture
    , exponent : Float
    , mobiusA : Vec2
    , mobiusB : Vec2
    , mobiusC : Vec2
    , mobiusD : Vec2
    , scale : Float
    , distance : Float
    , window : Vec2
    , tint : Vec4
    }


terrainVS : Shader Vertex Uniforms { uv_ : Vec2, offMap : Float }
terrainVS =
    [glsl|
        attribute vec2 chart;
        attribute vec2 uv;
        uniform float exponent;
        uniform vec2 mobiusA;
        uniform vec2 mobiusB;
        uniform vec2 mobiusC;
        uniform vec2 mobiusD;
        uniform float scale;
        uniform float distance;
        uniform vec2 window;
        varying vec2 uv_;
        varying float offMap;

        vec2 cmul(vec2 a, vec2 b) {
            return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
        }

        vec2 cdiv(vec2 a, vec2 b) {
            return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / dot(b, b);
        }

        void main () {
            vec2 q = chart;
            if (exponent != 0.0) {
                vec2 z = exponent * chart;
                q = exp(z.x) * vec2(cos(z.y), sin(z.y));
            }
            vec2 w = cdiv(cmul(mobiusA, q) + mobiusB, cmul(mobiusC, q) + mobiusD) * scale;

            // How far outside the window this point is
            float outside = 0.0;
            if (window.y < 3.14159 && length(w) > 1e-6) {
                float offset = mod(atan(w.y, w.x) - window.x + 3.14159265, 6.28318531) - 3.14159265;
                outside = max(0.0, abs(offset) - window.y) * length(w);
            }
            // Where copies of a piece overlap, the one seen through its window goes on top, then the
            // one reached first
            float depth = min(0.999, (distance + 4.0 * outside) / 8.0);
            gl_Position = vec4(w, depth * 2.0 - 1.0, 1.0);
            uv_ = uv;
            // A vertex flung far off the map would smear its triangles across it
            offMap = length(w) > 3.0 ? 1.0 : 0.0;
        }
    |]


terrainFS : Shader {} Uniforms { uv_ : Vec2, offMap : Float }
terrainFS =
    [glsl|
        precision mediump float;
        uniform sampler2D texture;
        uniform vec4 tint;
        varying vec2 uv_;
        varying float offMap;

        void main () {
            if (offMap > 0.0) {
                discard;
            }
            vec4 color = texture2D(texture, uv_);
            gl_FragColor = vec4(mix(color.rgb, tint.rgb, tint.a), color.a);
        }
    |]


{-| An arrow in the middle of the minimap pointing the way the player is facing
-}
playerMarker : WebGL.Mesh { position : Vec2 }
playerMarker =
    let
        scale =
            0.09

        point x y =
            { position = Vec2.vec2 (x * scale) (y * scale) }
    in
    WebGL.triangles
        [ ( point 0 1, point -0.7 -0.7, point 0 -0.3 )
        , ( point 0 1, point 0 -0.3, point 0.7 -0.7 )
        ]


markerVS : Shader { position : Vec2 } {} {}
markerVS =
    [glsl|
        attribute vec2 position;
        void main () {
            gl_Position = vec4(position, 0.0, 1.0);
        }
    |]


markerFS : Shader {} {} {}
markerFS =
    [glsl|
        precision mediump float;
        void main () {
            gl_FragColor = vec4(0.85, 0.1, 0.1, 1.0);
        }
    |]
