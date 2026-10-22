module Minimap exposing (Meshes, Vertex, emptyMeshes, meshes, size, view)

{-| A map of the surface around the player, with the player in the middle facing up. Distances from
the player are kept: a circle round the middle is everything that far away to walk to, walking
straight.

Flat faces and rounded edges unroll without stretching, so they are drawn whole from the textured
world model, cut up by surface piece, with each vertex storing where it is in its piece's chart. The
vertex shader moves them into place. Paths that cross the hole or a rounded corner bend, so beyond
those the map is drawn from a fan of paths traced out from the player each frame, coloured by
looking up where each point is in the world model.

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


{-| Triangles longer than this are split before they go on the map, so that looking up a point in
them finds a triangle close to the surface.
-}
maxEdgeLength : Float
maxEdgeLength =
    0.25


type alias Vertex =
    { chart : Vec2
    , uv : Vec2
    }


{-| The world model cut up by surface piece: a mesh per piece, and a way to look up the texture
coordinate of a point on a piece from its chart coordinate.
-}
type Meshes
    = Meshes
        { pieces : Array (WebGL.Mesh Vertex)
        , lookup : Array Grid
        }


emptyMeshes : Meshes
emptyMeshes =
    Meshes { pieces = Array.empty, lookup = Array.empty }


{-| A piece's triangles, bucketed by where they are in its chart.
-}
type alias Grid =
    { minRe : Float
    , minIm : Float
    , cellSize : Float
    , columns : Int
    , rows : Int
    , cells : Array (List LookupTriangle)
    }


{-| A triangle in chart coordinates, with the inverse of its edge matrix for barycentric
coordinates.
-}
type alias LookupTriangle =
    { re : Float
    , im : Float
    , m00 : Float
    , m01 : Float
    , m10 : Float
    , m11 : Float

    -- The texture coordinate at the first corner, and how it changes along the two edges
    , u : Float
    , v : Float
    , du1 : Float
    , dv1 : Float
    , du2 : Float
    , dv2 : Float
    }


maxGridSize : Int
maxGridSize =
    256


meshes : Surface coordinates -> List ( MeshBuilder.Vertex, MeshBuilder.Vertex, MeshBuilder.Vertex ) -> Meshes
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
    Meshes
        { pieces = Array.map WebGL.triangles byPiece
        , lookup = Array.map buildGrid byPiece
        }


buildGrid : List ( Vertex, Vertex, Vertex ) -> Grid
buildGrid triangles =
    let
        charts =
            List.concatMap (\( v0, v1, v2 ) -> [ Vec2.toRecord v0.chart, Vec2.toRecord v1.chart, Vec2.toRecord v2.chart ]) triangles

        minRe =
            List.map .x charts |> List.minimum |> Maybe.withDefault 0

        maxRe =
            List.map .x charts |> List.maximum |> Maybe.withDefault 0

        minIm =
            List.map .y charts |> List.minimum |> Maybe.withDefault 0

        maxIm =
            List.map .y charts |> List.maximum |> Maybe.withDefault 0

        -- About two cells per triangle
        cellSize =
            max 1.0e-6 (sqrt ((maxRe - minRe) * (maxIm - minIm) / toFloat (2 * max 1 (List.length triangles))))
                |> max (max (maxRe - minRe) (maxIm - minIm) / toFloat maxGridSize)

        columns =
            floor ((maxRe - minRe) / cellSize) + 1

        rows =
            floor ((maxIm - minIm) / cellSize) + 1

        cellOf re im =
            ( clamp 0 (columns - 1) (floor ((re - minRe) / cellSize)), clamp 0 (rows - 1) (floor ((im - minIm) / cellSize)) )

        insert ( v0, v1, v2 ) cells =
            let
                p0 =
                    Vec2.toRecord v0.chart

                p1 =
                    Vec2.toRecord v1.chart

                p2 =
                    Vec2.toRecord v2.chart

                e1x =
                    p1.x - p0.x

                e1y =
                    p1.y - p0.y

                e2x =
                    p2.x - p0.x

                e2y =
                    p2.y - p0.y

                determinant =
                    e1x * e2y - e2x * e1y
            in
            if abs determinant < 1.0e-18 then
                cells

            else
                let
                    uv0 =
                        Vec2.toRecord v0.uv

                    uv1 =
                        Vec2.toRecord v1.uv

                    uv2 =
                        Vec2.toRecord v2.uv

                    triangle =
                        { re = p0.x
                        , im = p0.y
                        , m00 = e2y / determinant
                        , m01 = -e2x / determinant
                        , m10 = -e1y / determinant
                        , m11 = e1x / determinant
                        , u = uv0.x
                        , v = uv0.y
                        , du1 = uv1.x - uv0.x
                        , dv1 = uv1.y - uv0.y
                        , du2 = uv2.x - uv0.x
                        , dv2 = uv2.y - uv0.y
                        }

                    ( c0, r0 ) =
                        cellOf (min p0.x (min p1.x p2.x)) (min p0.y (min p1.y p2.y))

                    ( c1, r1 ) =
                        cellOf (max p0.x (max p1.x p2.x)) (max p0.y (max p1.y p2.y))
                in
                List.range r0 r1
                    |> List.concatMap (\row -> List.range c0 c1 |> List.map (\column -> row * columns + column))
                    |> List.foldl
                        (\index acc -> Array.set index (triangle :: (Array.get index acc |> Maybe.withDefault [])) acc)
                        cells
    in
    { minRe = minRe
    , minIm = minIm
    , cellSize = cellSize
    , columns = columns
    , rows = rows
    , cells = List.foldl insert (Array.repeat (columns * rows) []) triangles
    }


{-| The texture coordinate at a chart coordinate: from the triangle it's in, or failing that the
nearest one in the same cell.
-}
lookupUv : Grid -> Surface.Complex -> Maybe { x : Float, y : Float }
lookupUv grid { re, im } =
    let
        column =
            floor ((re - grid.minRe) / grid.cellSize)

        row =
            floor ((im - grid.minIm) / grid.cellSize)
    in
    if column < 0 || row < 0 || column >= grid.columns || row >= grid.rows then
        Nothing

    else
        case Array.get (row * grid.columns + column) grid.cells of
            Just candidates ->
                closestTriangle re im candidates Nothing 0.5

            Nothing ->
                Nothing


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


{-| The texture coordinate from the first triangle containing the point, or failing that from the
one it's least far outside.
-}
closestTriangle : Float -> Float -> List LookupTriangle -> Maybe { x : Float, y : Float } -> Float -> Maybe { x : Float, y : Float }
closestTriangle re im candidates best bestOutside =
    case candidates of
        triangle :: rest ->
            let
                dx =
                    re - triangle.re

                dy =
                    im - triangle.im

                l1 =
                    triangle.m00 * dx + triangle.m01 * dy

                l2 =
                    triangle.m10 * dx + triangle.m11 * dy

                outside =
                    max 0 -l1 + max 0 -l2 + max 0 (l1 + l2 - 1)
            in
            if outside < bestOutside then
                let
                    c1 =
                        clamp 0 1 l1

                    c2 =
                        clamp 0 (1 - c1) l2

                    uv =
                        { x = triangle.u + c1 * triangle.du1 + c2 * triangle.du2
                        , y = triangle.v + c1 * triangle.dv1 + c2 * triangle.dv2
                        }
                in
                if outside <= 0 then
                    Just uv

                else
                    closestTriangle re im rest (Just uv) outside

            else
                closestTriangle re im rest best bestOutside

        [] ->
            best


view : Surface coordinates -> Meshes -> Texture -> SurfacePoint -> Html msg
view surface (Meshes { pieces, lookup }) texture surfacePoint =
    let
        sizeInPixels =
            Pixels.inPixels size

        radius =
            Length.inMeters viewRadius

        layout =
            Surface.mapAround radius surfacePoint surface

        terrain index placement =
            case Array.get placement.piece pieces of
                Just mesh ->
                    Just
                        (WebGL.entityWith
                            [ WebGL.Settings.DepthTest.less { write = True, near = 0, far = 1 } ]
                            terrainVS
                            terrainFS
                            mesh
                            { texture = texture
                            , scale = complex placement.scale |> Vec2.scale (1 / radius)
                            , offset = complex placement.offset |> Vec2.scale (1 / radius)
                            , depth = placement.distance / radius / 4 + toFloat index * 1.0e-4
                            , window = Vec2.vec2 placement.window.center placement.window.halfWidth
                            , hole =
                                case placement.hole of
                                    Just hole ->
                                        Vec3.vec3 (hole.center.re / radius) (hole.center.im / radius) (hole.radius / radius)

                                    Nothing ->
                                        Vec3.vec3 0 0 0
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
        (WebGL.entityWith
            [ WebGL.Settings.DepthTest.less { write = True, near = 0, far = 1 } ]
            fanVS
            fanFS
            (fanMesh lookup radius layout.fan)
            { texture = texture, tint = fanTint }
            :: (List.indexedMap terrain layout.placements |> List.filterMap identity)
            ++ [ WebGL.entityWith
                    [ Blend.add Blend.one Blend.oneMinusSrcAlpha ]
                    markerVS
                    markerFS
                    playerMarker
                    {}
               ]
        )


type alias FanVertex =
    { position : Vec2
    , uv : Vec2
    }


{-| Fan triangles whose corners are further apart than this on the surface straddle a fold, where
neighbouring paths went different ways (one down the hole, one back out of it), and are left out.
-}
maxFanEdge : Float
maxFanEdge =
    0.6


{-| Triangles between neighbouring fan paths, `Surface.fanSpacing` meters long.
-}
fanMesh : Array Grid -> Float -> List (List Surface.FanRay) -> WebGL.Mesh FanVertex
fanMesh lookup radius groups =
    let
        pointsOf ray =
            { first = ray.firstSample
            , points =
                ray.samples
                    |> List.indexedMap
                        (\i sample ->
                            let
                                distance =
                                    toFloat (ray.firstSample + i) * Surface.fanSpacing / radius
                            in
                            case Array.get sample.piece lookup |> Maybe.andThen (\grid -> lookupUv grid sample.chart) of
                                Just uv ->
                                    Just
                                        { vertex = { position = Vec2.vec2 (distance * cos ray.angle) (distance * sin ray.angle), uv = Vec2.fromRecord uv }
                                        , position = sample.position
                                        }

                                Nothing ->
                                    Nothing
                        )
                    |> Array.fromList
            }

        addGroup rays triangles =
            case List.map pointsOf rays of
                first :: rest ->
                    List.foldl (\right ( left, acc ) -> ( right, between left right acc )) ( first, triangles ) rest |> Tuple.second

                [] ->
                    triangles
    in
    List.foldl addGroup [] groups |> WebGL.triangles


{-| Add the triangles between two neighbouring fan paths.
-}
between :
    { first : Int, points : Array (Maybe FanPoint) }
    -> { first : Int, points : Array (Maybe FanPoint) }
    -> List ( FanVertex, FanVertex, FanVertex )
    -> List ( FanVertex, FanVertex, FanVertex )
between left right triangles =
    let
        last =
            min (left.first + Array.length left.points) (right.first + Array.length right.points) - 2

        at ray j =
            Array.get (j - ray.first) ray.points |> Maybe.andThen identity

        go j acc =
            if j > last then
                acc

            else
                case ( at left j, at right j ) of
                    ( Just a, Just b ) ->
                        case ( at right (j + 1), at left (j + 1) ) of
                            ( Just c, Just d ) ->
                                go (j + 1) (addTriangle a c d (addTriangle a b c acc))

                            _ ->
                                go (j + 1) acc

                    _ ->
                        go (j + 1) acc
    in
    go (max left.first right.first) triangles


type alias FanPoint =
    { vertex : FanVertex
    , position : { x : Float, y : Float, z : Float }
    }


addTriangle : FanPoint -> FanPoint -> FanPoint -> List ( FanVertex, FanVertex, FanVertex ) -> List ( FanVertex, FanVertex, FanVertex )
addTriangle a b c triangles =
    if near a.position b.position && near b.position c.position && near c.position a.position then
        ( a.vertex, b.vertex, c.vertex ) :: triangles

    else
        triangles


near : { x : Float, y : Float, z : Float } -> { x : Float, y : Float, z : Float } -> Bool
near p q =
    (p.x - q.x) ^ 2 + (p.y - q.y) ^ 2 + (p.z - q.z) ^ 2 < maxFanEdge * maxFanEdge


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


{-| In debug builds the fan is tinted too.
-}
fanTint : Vec4
fanTint =
    if Environment.isDebug then
        Vec4.vec4 1 0 1 0.3

    else
        Vec4.vec4 0 0 0 0


complex : Surface.Complex -> Vec2
complex { re, im } =
    Vec2.vec2 re im


type alias Uniforms =
    { texture : Texture
    , scale : Vec2
    , offset : Vec2
    , depth : Float
    , window : Vec2
    , hole : Vec3
    , tint : Vec4
    }


terrainVS : Shader Vertex Uniforms { uv_ : Vec2, w : Vec2 }
terrainVS =
    [glsl|
        attribute vec2 chart;
        attribute vec2 uv;
        uniform vec2 scale;
        uniform vec2 offset;
        uniform float depth;
        varying vec2 uv_;
        varying vec2 w;

        void main () {
            w = vec2(scale.x * chart.x - scale.y * chart.y, scale.x * chart.y + scale.y * chart.x) + offset;
            gl_Position = vec4(w, depth * 2.0 - 1.0, 1.0);
            uv_ = uv;
        }
    |]


terrainFS : Shader {} Uniforms { uv_ : Vec2, w : Vec2 }
terrainFS =
    [glsl|
        precision mediump float;
        uniform sampler2D texture;
        uniform vec2 window;
        uniform vec3 hole;
        uniform vec4 tint;
        varying vec2 uv_;
        varying vec2 w;

        void main () {
            // Only what straight paths reach through the pieces on the way here
            if (window.y < 3.14159) {
                float offset = mod(atan(w.y, w.x) - window.x + 3.14159265, 6.28318531) - 3.14159265;
                if (abs(offset) > window.y + 0.002) {
                    discard;
                }
            }
            // and not behind the hole
            if (hole.z > 0.0) {
                vec2 closest = clamp(dot(hole.xy, w) / dot(w, w), 0.0, 1.0) * w;
                if (distance(closest, hole.xy) < hole.z) {
                    discard;
                }
            }
            vec4 color = texture2D(texture, uv_);
            gl_FragColor = vec4(mix(color.rgb, tint.rgb, tint.a), color.a);
        }
    |]


fanVS : Shader FanVertex { texture : Texture, tint : Vec4 } { uv_ : Vec2 }
fanVS =
    [glsl|
        attribute vec2 position;
        attribute vec2 uv;
        varying vec2 uv_;

        void main () {
            gl_Position = vec4(position, 0.8, 1.0);
            uv_ = uv;
        }
    |]


fanFS : Shader {} { texture : Texture, tint : Vec4 } { uv_ : Vec2 }
fanFS =
    [glsl|
        precision mediump float;
        uniform sampler2D texture;
        uniform vec4 tint;
        varying vec2 uv_;

        void main () {
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
