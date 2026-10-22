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


type alias GridVertex =
    { chart : Vec2
    , uv : Vec2
    , position : Vec3
    }


{-| More than any piece has, for giving each triangle its own id.
-}
maxTrianglesPerPiece : Int
maxTrianglesPerPiece =
    1000000


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


{-| A triangle in chart coordinates (corners (x0, y0), (x1, y1), (x2, y2)), with the inverse of its
edge matrix for barycentric coordinates. `id` is unique across all pieces.
-}
type alias LookupTriangle =
    { id : Int
    , x0 : Float
    , y0 : Float
    , x1 : Float
    , y1 : Float
    , x2 : Float
    , y2 : Float
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

    -- The first corner in 3D, and vectors giving the barycentric coordinates of a point in 3D
    -- (projected onto the triangle's plane) relative to it
    , corner : Vec3
    , along1 : Vec3
    , along2 : Vec3
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
            { chart = Vec2.vec2 chart.re chart.im, uv = vertex.uv, position = vertex.position }

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

        forDrawing { chart, uv } =
            { chart = chart, uv = uv }
    in
    Meshes
        { pieces = Array.map (List.map (\( v0, v1, v2 ) -> ( forDrawing v0, forDrawing v1, forDrawing v2 )) >> WebGL.triangles) byPiece
        , lookup = Array.indexedMap buildGrid byPiece
        }


buildGrid : Int -> List ( GridVertex, GridVertex, GridVertex ) -> Grid
buildGrid piece triangles =
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

        insert ( id, ( v0, v1, v2 ) ) cells =
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

                    q0 =
                        v0.position

                    e1 =
                        Vec3.sub v1.position q0

                    e2 =
                        Vec3.sub v2.position q0

                    g11 =
                        Vec3.dot e1 e1

                    g12 =
                        Vec3.dot e1 e2

                    g22 =
                        Vec3.dot e2 e2

                    gram =
                        g11 * g22 - g12 * g12

                    triangle =
                        { id = piece * maxTrianglesPerPiece + id
                        , x0 = p0.x
                        , y0 = p0.y
                        , x1 = p1.x
                        , y1 = p1.y
                        , x2 = p2.x
                        , y2 = p2.y
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
                        , corner = q0
                        , along1 = Vec3.sub (Vec3.scale g22 e1) (Vec3.scale g12 e2) |> Vec3.scale (1 / gram)
                        , along2 = Vec3.sub (Vec3.scale g11 e2) (Vec3.scale g12 e1) |> Vec3.scale (1 / gram)
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
    , cells = List.foldl insert (Array.repeat (columns * rows) []) (List.indexedMap Tuple.pair triangles)
    }


{-| The triangle a chart coordinate is in, or failing that the nearest one in the same cell.
-}
lookupTriangle : Grid -> Surface.Complex -> Maybe LookupTriangle
lookupTriangle grid { re, im } =
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


{-| The texture coordinate at a chart coordinate, by carrying the triangle's texture coordinates on
across its plane.
-}
uvIn : LookupTriangle -> Float -> Float -> { x : Float, y : Float }
uvIn triangle re im =
    let
        dx =
            re - triangle.x0

        dy =
            im - triangle.y0

        l1 =
            triangle.m00 * dx + triangle.m01 * dy

        l2 =
            triangle.m10 * dx + triangle.m11 * dy
    in
    { x = triangle.u + l1 * triangle.du1 + l2 * triangle.du2
    , y = triangle.v + l1 * triangle.dv1 + l2 * triangle.dv2
    }


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


{-| The first triangle containing the point, or failing that the one it's least far outside.
-}
closestTriangle : Float -> Float -> List LookupTriangle -> Maybe LookupTriangle -> Float -> Maybe LookupTriangle
closestTriangle re im candidates best bestOutside =
    case candidates of
        triangle :: rest ->
            let
                dx =
                    re - triangle.x0

                dy =
                    im - triangle.y0

                l1 =
                    triangle.m00 * dx + triangle.m01 * dy

                l2 =
                    triangle.m10 * dx + triangle.m11 * dy

                outside =
                    max 0 -l1 + max 0 -l2 + max 0 (l1 + l2 - 1)
            in
            if outside <= 0 then
                Just triangle

            else if outside < bestOutside then
                closestTriangle re im rest (Just triangle) outside

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


{-| Map position and texture coordinate in one attribute, as making each attribute takes a while.
`clip` is where the vertex is relative to a world model triangle (barycentric coordinates): the
fragment shader leaves out what's outside that triangle. Its third part is the depth.
-}
type alias FanVertex =
    { positionAndUv : Vec4
    , clip : Vec3
    }


{-| Fan triangles whose corners are further apart than this on the surface straddle a fold, where
neighbouring paths went different ways (one down the hole, one back out of it), and are left out.
-}
maxFanEdge : Float
maxFanEdge =
    0.6


{-| Triangles between neighbouring fan paths, `Surface.fanSpacing` meters long.

The world model's texture is cut up into many small islands (the hole's wall especially), so
blending texture coordinates across a fan triangle would show whatever lies between the islands.
Instead each fan triangle is cut along the world model's triangles, and each bit takes its texture
from its own triangle.

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
                            case Array.get sample.piece lookup |> Maybe.andThen (\grid -> lookupTriangle grid sample.chart) of
                                Just triangle ->
                                    let
                                        map =
                                            { x = distance * cos ray.angle, y = distance * sin ray.angle }

                                        uv =
                                            uvIn triangle sample.chart.re sample.chart.im
                                    in
                                    Just
                                        { map = map
                                        , uv = uv
                                        , vertex = fanVertex map uv
                                        , position = sample.position
                                        , chart = sample.chart
                                        , triangle = triangle
                                        , piece = sample.piece
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


type alias FanPoint =
    { map : { x : Float, y : Float }
    , uv : { x : Float, y : Float }
    , vertex : FanVertex
    , position : { x : Float, y : Float, z : Float }
    , chart : Surface.Complex
    , triangle : LookupTriangle
    , piece : Int
    }


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


addTriangle : FanPoint -> FanPoint -> FanPoint -> List ( FanVertex, FanVertex, FanVertex ) -> List ( FanVertex, FanVertex, FanVertex )
addTriangle a b c triangles =
    if not (near a.position b.position && near b.position c.position && near c.position a.position) then
        triangles

    else if sameIsland a b && sameIsland a c && sameIsland b c then
        ( a.vertex, b.vertex, c.vertex ) :: triangles

    else
        cutAlongModel a b c triangles


{-| Whether two fan points' texture coordinates can be blended: they're in the same world model
triangle, or carrying one's triangle on to the other gets close to the other's texture coordinate.
Carrying on goes through 3D, as the two may be on different pieces.
-}
sameIsland : FanPoint -> FanPoint -> Bool
sameIsland p q =
    if p.triangle.id == q.triangle.id then
        True

    else
        let
            ( l1, l2 ) =
                barycentric p.triangle q.position

            carried =
                { x = p.triangle.u + l1 * p.triangle.du1 + l2 * p.triangle.du2
                , y = p.triangle.v + l1 * p.triangle.dv1 + l2 * p.triangle.dv2
                }
        in
        abs (carried.x - q.uv.x) + abs (carried.y - q.uv.y) < islandTolerance


{-| Where a point in 3D is relative to a world model triangle (after being projected onto its
plane), as the weights of its second and third corners.
-}
barycentric : LookupTriangle -> { x : Float, y : Float, z : Float } -> ( Float, Float )
barycentric triangle position =
    let
        offset =
            Vec3.sub (Vec3.fromRecord position) triangle.corner
    in
    ( Vec3.dot triangle.along1 offset, Vec3.dot triangle.along2 offset )


{-| How far apart, in texture coordinates, two estimates of the same point's texture coordinate can
be and still be on the same island of the texture.
-}
islandTolerance : Float
islandTolerance =
    0.01


fanVertex : { x : Float, y : Float } -> { x : Float, y : Float } -> FanVertex
fanVertex map uv =
    { positionAndUv = Vec4.vec4 map.x map.y uv.x uv.y, clip = noClip }


{-| A fan triangle once for each world model triangle its corners are in, coloured from that
triangle's texture coordinates carried on across the whole fan triangle, and cut down to that
triangle by the fragment shader. This is worked out in 3D, as the corners may be on different
pieces. A fan triangle is about as big as these, so it seldom reaches into any others, and if it
does the same triangle in one colour behind covers the gap.
-}
cutAlongModel : FanPoint -> FanPoint -> FanPoint -> List ( FanVertex, FanVertex, FanVertex ) -> List ( FanVertex, FanVertex, FanVertex )
cutAlongModel a b c triangles =
    let
        models =
            a.triangle
                :: (if b.triangle.id /= a.triangle.id then
                        [ b.triangle ]

                    else
                        []
                   )
                ++ (if c.triangle.id /= a.triangle.id && c.triangle.id /= b.triangle.id then
                        [ c.triangle ]

                    else
                        []
                   )

        cut model p =
            let
                ( l1, l2 ) =
                    barycentric model p.position
            in
            { positionAndUv =
                Vec4.vec4
                    p.map.x
                    p.map.y
                    (model.u + l1 * model.du1 + l2 * model.du2)
                    (model.v + l1 * model.dv1 + l2 * model.dv2)
            , clip = Vec3.vec3 l1 l2 cutDepth
            }

        -- The middle of a model triangle, well away from the edge of its island
        fill p =
            { positionAndUv =
                Vec4.vec4
                    p.map.x
                    p.map.y
                    (a.triangle.u + (a.triangle.du1 + a.triangle.du2) / 3)
                    (a.triangle.v + (a.triangle.dv1 + a.triangle.dv2) / 3)
            , clip = fillClip
            }
    in
    List.foldl (\model acc -> ( cut model a, cut model b, cut model c ) :: acc)
        (( fill a, fill b, fill c ) :: triangles)
        models


cutDepth : Float
cutDepth =
    0.6


{-| Keeps everything, behind the cut triangles.
-}
fillClip : Vec3
fillClip =
    Vec3.vec3 0.25 0.25 0.62


{-| Keeps everything, in front.
-}
noClip : Vec3
noClip =
    Vec3.vec3 0.25 0.25 cutDepth


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


fanVS : Shader FanVertex { texture : Texture, tint : Vec4 } { uv_ : Vec2, clip_ : Vec2 }
fanVS =
    [glsl|
        attribute vec4 positionAndUv;
        attribute vec3 clip;
        varying vec2 uv_;
        varying vec2 clip_;

        void main () {
            gl_Position = vec4(positionAndUv.xy, clip.z * 2.0 - 1.0, 1.0);
            uv_ = positionAndUv.zw;
            clip_ = clip.xy;
        }
    |]


fanFS : Shader {} { texture : Texture, tint : Vec4 } { uv_ : Vec2, clip_ : Vec2 }
fanFS =
    [glsl|
        precision highp float;
        uniform sampler2D texture;
        uniform vec4 tint;
        varying vec2 uv_;
        varying vec2 clip_;

        void main () {
            if (clip_.x < -0.0005 || clip_.y < -0.0005 || clip_.x + clip_.y > 1.0005) {
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
