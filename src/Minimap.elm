module Minimap exposing (imagesAround, size, view)

{-| A map of the surface around the player, with the player in the middle facing up. Distances from
the player are kept: a circle round the middle is everything that far away to walk to, walking
straight.

The map shows shapes on the surface (see `Shapes`): walls as lines and paving as filled areas. Each
shape point near enough to the player is put on the map, sometimes in more than one place, as there
can be more than one straight way to walk to it. Flat faces and rounded edges unroll without
stretching, so points on those go where their piece is placed. Paths that cross the hole or a
rounded corner bend, so beyond those, points are found among a fan of paths traced out from the
player.

-}

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes
import Length exposing (Length)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Pixels exposing (Pixels)
import Point3d
import Quantity exposing (Quantity)
import Shapes exposing (ShapePoint, Shapes)
import Surface exposing (Surface, SurfacePoint)
import WebGL exposing (Shader)
import WebGL.Settings.Blend as Blend


size : Quantity Int Pixels
size =
    Pixels.pixels 500


{-| How far from the player the minimap shows
-}
viewRadius : Length
viewRadius =
    Length.meters 4


{-| How wide walls are drawn, in pixels
-}
wallWidth : Float
wallWidth =
    2.5


type alias MapPoint =
    { x : Float, y : Float }


view : Surface coordinates -> Shapes -> SurfacePoint -> Html msg
view surface shapes surfacePoint =
    let
        sizeInPixels =
            Pixels.inPixels size

        radius =
            Length.inMeters viewRadius

        images =
            imagesAround surface shapes surfacePoint

        withImages index =
            Maybe.map2 Tuple.pair (Array.get index shapes.points) (Array.get index images)

        walls =
            shapes.walls
                |> List.concatMap (\wall -> wallQuads (wallWidth / toFloat sizeInPixels * 2 * radius) (List.filterMap withImages wall))

        paving =
            shapes.pavingTriangles
                |> List.concatMap
                    (\( i, j, k ) ->
                        Maybe.map3 pavingTriangles (withImages i) (withImages j) (withImages k)
                            |> Maybe.withDefault []
                    )
    in
    WebGL.toHtmlWith
        [ WebGL.alpha True, WebGL.antialias, WebGL.clearColor (144 / 255) (187 / 255) (146 / 255) 1 ]
        [ Html.Attributes.width sizeInPixels
        , Html.Attributes.height sizeInPixels
        , Html.Attributes.style "display" "block"
        ]
        [ WebGL.entity shapeVS shapeFS (toMesh radius paving) { color = Vec3.vec3 (187 / 255) (157 / 255) (72 / 255) }
        , WebGL.entity shapeVS shapeFS (toMesh radius walls) { color = Vec3.vec3 0 0 0 }
        , WebGL.entityWith
            [ Blend.add Blend.one Blend.oneMinusSrcAlpha ]
            markerVS
            markerFS
            playerMarker
            {}
        ]



---- WHERE POINTS GO ----


{-| Where each shape point goes on the map, in meters, in as many places as there are straight ways
to walk to it within `viewRadius`.
-}
imagesAround : Surface coordinates -> Shapes -> SurfacePoint -> Array (List MapPoint)
imagesAround surface shapes surfacePoint =
    let
        radius =
            Length.inMeters viewRadius

        layout =
            Surface.mapAround radius surfacePoint surface
    in
    case Surface.worldPosition surfacePoint surface of
        Just position ->
            let
                player =
                    Point3d.toMeters position

                throughPlacements =
                    Array.map
                        (\point ->
                            if distance point.position player <= radius + 0.05 then
                                List.filterMap (placementImage radius point) layout.placements
                                    |> List.foldl addImage []

                            else
                                []
                        )
                        shapes.points
            in
            fanTriangles layout.fan |> List.foldl (addFanImages shapes) throughPlacements

        Nothing ->
            Array.empty


{-| Where a point goes on the map through a placed piece, if that part of the piece is shown.
-}
placementImage : Float -> ShapePoint -> Surface.Placement -> Maybe MapPoint
placementImage radius point placement =
    if placement.piece /= point.piece then
        Nothing

    else
        let
            w =
                Surface.placeOnMap placement point.chart

            lengthSquared =
                w.re * w.re + w.im * w.im

            inWindow =
                placement.window.halfWidth >= pi || abs (angleBetween (atan2 w.im w.re) placement.window.center) <= placement.window.halfWidth + 0.002

            behindHole =
                case placement.hole of
                    Just hole ->
                        let
                            t =
                                if lengthSquared > 0 then
                                    clamp 0 1 ((hole.center.re * w.re + hole.center.im * w.im) / lengthSquared)

                                else
                                    0
                        in
                        (t * w.re - hole.center.re) ^ 2 + (t * w.im - hole.center.im) ^ 2 < hole.radius * hole.radius

                    Nothing ->
                        False
        in
        if inWindow && not behindHole && lengthSquared < (1.2 * radius) ^ 2 then
            Just { x = w.re, y = w.im }

        else
            Nothing


{-| From one angle to another, between -pi and pi.
-}
angleBetween : Float -> Float -> Float
angleBetween a b =
    let
        d =
            a - b + pi
    in
    d - 2 * pi * toFloat (floor (d / (2 * pi))) - pi


{-| A point traced on the fan. `map` is in meters.
-}
type alias FanPoint =
    { map : MapPoint
    , position : Vec
    , chart : Surface.Complex
    , piece : Int
    }


type alias Vec =
    { x : Float, y : Float, z : Float }


{-| A fan triangle, and the box round it with `maxOffSurface` to spare.
-}
type alias FanTriangle =
    { a : FanPoint
    , b : FanPoint
    , c : FanPoint
    , min : Vec
    , max : Vec
    }


{-| Fan triangles whose corners are further apart than this on the surface straddle a fold, where
neighbouring paths went different ways (one down the hole, one back out of it), and are left out.
-}
maxFanEdge : Float
maxFanEdge =
    0.6


{-| Triangles between neighbouring fan paths, `Surface.fanSpacing` meters long.
-}
fanTriangles : List (List Surface.FanRay) -> List FanTriangle
fanTriangles groups =
    let
        pointsOf ray =
            { first = ray.firstSample
            , points =
                ray.samples
                    |> List.indexedMap
                        (\i sample ->
                            let
                                distanceOnMap =
                                    toFloat (ray.firstSample + i) * Surface.fanSpacing
                            in
                            { map = { x = distanceOnMap * cos ray.angle, y = distanceOnMap * sin ray.angle }
                            , position = sample.position
                            , chart = sample.chart
                            , piece = sample.piece
                            }
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
    List.foldl addGroup [] groups


{-| Add the triangles between two neighbouring fan paths.
-}
between :
    { first : Int, points : Array FanPoint }
    -> { first : Int, points : Array FanPoint }
    -> List FanTriangle
    -> List FanTriangle
between left right triangles =
    let
        last =
            min (left.first + Array.length left.points) (right.first + Array.length right.points) - 2

        at ray j =
            Array.get (j - ray.first) ray.points

        add a b c acc =
            if near a.position b.position && near b.position c.position && near c.position a.position then
                { a = a
                , b = b
                , c = c
                , min =
                    { x = min a.position.x (min b.position.x c.position.x) - maxOffSurface
                    , y = min a.position.y (min b.position.y c.position.y) - maxOffSurface
                    , z = min a.position.z (min b.position.z c.position.z) - maxOffSurface
                    }
                , max =
                    { x = max a.position.x (max b.position.x c.position.x) + maxOffSurface
                    , y = max a.position.y (max b.position.y c.position.y) + maxOffSurface
                    , z = max a.position.z (max b.position.z c.position.z) + maxOffSurface
                    }
                }
                    :: acc

            else
                acc

        go j acc =
            if j > last then
                acc

            else
                case ( ( at left j, at right j ), ( at right (j + 1), at left (j + 1) ) ) of
                    ( ( Just a, Just b ), ( Just c, Just d ) ) ->
                        go (j + 1) (add a c d (add a b c acc))

                    _ ->
                        go (j + 1) acc
    in
    go (max left.first right.first) triangles


near : Vec -> Vec -> Bool
near p q =
    distance p q < maxFanEdge


inBox : { a | min : Vec, max : Vec } -> Vec -> Bool
inBox box p =
    p.x >= box.min.x && p.x <= box.max.x && p.y >= box.min.y && p.y <= box.max.y && p.z >= box.min.z && p.z <= box.max.z


{-| Add where the shape points in a fan triangle go on the map.
-}
addFanImages : Shapes -> FanTriangle -> Array (List MapPoint) -> Array (List MapPoint)
addFanImages shapes triangle images =
    Shapes.foldWithin { min = triangle.min, max = triangle.max }
        (\index acc ->
            case Array.get index shapes.points of
                Just point ->
                    -- Most points looked at aren't near the triangle at all
                    if inBox triangle point.position then
                        case fanImage triangle point of
                            Just image ->
                                Array.set index (addImage image (Array.get index acc |> Maybe.withDefault [])) acc

                            Nothing ->
                                acc

                    else
                        acc

                Nothing ->
                    acc
        )
        images
        shapes


{-| A point further than this from a fan triangle, in meters, is on some other part of the surface.
-}
maxOffSurface : Float
maxOffSurface =
    0.05


fanImage : FanTriangle -> ShapePoint -> Maybe MapPoint
fanImage { a, b, c, min, max } point =
    let
        p =
            point.position

        weights () =
            if a.piece == point.piece && b.piece == point.piece && c.piece == point.piece then
                -- In the piece's chart, where the fan's points were found
                let
                    e1x =
                        b.chart.re - a.chart.re

                    e1y =
                        b.chart.im - a.chart.im

                    e2x =
                        c.chart.re - a.chart.re

                    e2y =
                        c.chart.im - a.chart.im

                    dx =
                        point.chart.re - a.chart.re

                    dy =
                        point.chart.im - a.chart.im

                    determinant =
                        e1x * e2y - e2x * e1y
                in
                if abs determinant < 1.0e-14 then
                    Nothing

                else
                    Just ( (e2y * dx - e2x * dy) / determinant, (e1x * dy - e1y * dx) / determinant )

            else
                -- Across pieces, in 3D
                let
                    e1 =
                        sub b.position a.position

                    e2 =
                        sub c.position a.position

                    d =
                        sub point.position a.position

                    g11 =
                        dot e1 e1

                    g12 =
                        dot e1 e2

                    g22 =
                        dot e2 e2

                    gram =
                        g11 * g22 - g12 * g12

                    l1 =
                        (g22 * dot e1 d - g12 * dot e2 d) / gram

                    l2 =
                        (g11 * dot e2 d - g12 * dot e1 d) / gram

                    off =
                        { x = d.x - l1 * e1.x - l2 * e2.x, y = d.y - l1 * e1.y - l2 * e2.y, z = d.z - l1 * e1.z - l2 * e2.z }
                in
                if gram < 1.0e-14 || dot off off > maxOffSurface * maxOffSurface then
                    Nothing

                else
                    Just ( l1, l2 )
    in
    case
        if p.x < min.x || p.x > max.x || p.y < min.y || p.y > max.y || p.z < min.z || p.z > max.z then
            Nothing

        else
            weights ()
    of
        Just ( l1, l2 ) ->
            if l1 >= -1.0e-3 && l2 >= -1.0e-3 && l1 + l2 <= 1.001 then
                Just
                    { x = a.map.x + l1 * (b.map.x - a.map.x) + l2 * (c.map.x - a.map.x)
                    , y = a.map.y + l1 * (b.map.y - a.map.y) + l2 * (c.map.y - a.map.y)
                    }

            else
                Nothing

        Nothing ->
            Nothing


{-| Images closer than this, in meters, are the same one found twice (in two fan triangles that
share an edge, or in the fan and a placed piece both).
-}
sameImage : Float
sameImage =
    0.02


addImage : MapPoint -> List MapPoint -> List MapPoint
addImage image images =
    if List.any (\other -> mapDistance image other < sameImage) images then
        images

    else
        image :: images



---- DRAWING ----


{-| Two images of neighbouring shape points belong together if they're no further apart on the map
than this many times their distance on the surface (plus `sameImage`). Away from the player the map
stretches sideways, but images of the same point reached different ways are much further apart.
-}
maxStretch : Float
maxStretch =
    4


closestMatch : Float -> MapPoint -> List MapPoint -> Maybe MapPoint
closestMatch surfaceDistance image candidates =
    let
        reach =
            maxStretch * surfaceDistance + sameImage
    in
    candidates
        |> List.foldl
            (\candidate best ->
                let
                    d =
                        mapDistance image candidate
                in
                case best of
                    Just ( bestDistance, _ ) ->
                        if d < bestDistance then
                            Just ( d, candidate )

                        else
                            best

                    Nothing ->
                        if d <= reach then
                            Just ( d, candidate )

                        else
                            Nothing
            )
            Nothing
        |> Maybe.map Tuple.second


{-| Each wall segment as a quad, made longer by half the width at each end so that corners are
filled.
-}
wallQuads : Float -> List ( ShapePoint, List MapPoint ) -> List ( MapPoint, MapPoint, MapPoint )
wallQuads width points =
    case points of
        ( p, pImages ) :: ((( q, qImages ) :: _) as rest) ->
            List.concatMap
                (\a ->
                    case closestMatch (distance p.position q.position) a qImages of
                        Just b ->
                            quad width a b

                        Nothing ->
                            []
                )
                pImages
                ++ wallQuads width rest

        _ ->
            []


quad : Float -> MapPoint -> MapPoint -> List ( MapPoint, MapPoint, MapPoint )
quad width a b =
    let
        length =
            max 1.0e-9 (mapDistance a b)

        ux =
            (b.x - a.x) / length * width / 2

        uy =
            (b.y - a.y) / length * width / 2

        corner s t p =
            { x = p.x + s * ux - t * uy, y = p.y + s * uy + t * ux }

        a1 =
            corner -1 1 a

        a2 =
            corner -1 -1 a

        b1 =
            corner 1 1 b

        b2 =
            corner 1 -1 b
    in
    [ ( a1, a2, b2 ), ( a1, b2, b1 ) ]


pavingTriangles : ( ShapePoint, List MapPoint ) -> ( ShapePoint, List MapPoint ) -> ( ShapePoint, List MapPoint ) -> List ( MapPoint, MapPoint, MapPoint )
pavingTriangles ( p, pImages ) ( q, qImages ) ( r, rImages ) =
    List.filterMap
        (\a ->
            case ( closestMatch (distance p.position q.position) a qImages, closestMatch (distance p.position r.position) a rImages ) of
                ( Just b, Just c ) ->
                    if mapDistance b c <= maxStretch * distance q.position r.position + sameImage then
                        Just ( a, b, c )

                    else
                        Nothing

                _ ->
                    Nothing
        )
        pImages


toMesh : Float -> List ( MapPoint, MapPoint, MapPoint ) -> WebGL.Mesh { position : Vec2 }
toMesh radius triangles =
    let
        vertex p =
            { position = Vec2.vec2 (p.x / radius) (p.y / radius) }
    in
    triangles |> List.map (\( a, b, c ) -> ( vertex a, vertex b, vertex c )) |> WebGL.triangles


shapeVS : Shader { position : Vec2 } { color : Vec3 } {}
shapeVS =
    [glsl|
        attribute vec2 position;
        void main () {
            gl_Position = vec4(position, 0.0, 1.0);
        }
    |]


shapeFS : Shader {} { color : Vec3 } {}
shapeFS =
    [glsl|
        precision mediump float;
        uniform vec3 color;
        void main () {
            gl_FragColor = vec4(color, 1.0);
        }
    |]


mapDistance : MapPoint -> MapPoint -> Float
mapDistance a b =
    sqrt ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)


distance : Vec -> Vec -> Float
distance a b =
    sqrt ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)


sub : Vec -> Vec -> Vec
sub a b =
    { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }


dot : Vec -> Vec -> Float
dot a b =
    a.x * b.x + a.y * b.y + a.z * b.z


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
