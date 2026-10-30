module Details exposing (Detail, Obstacles, Patches, clearOf, meshes, obstacles, patches, scatter)

{-| Small things lying about on the ground so it doesn't look bare: pebbles, rocks, tufts of grass
and flowers.

Where they go is random, but always the same for the same surface: each triangle of the surface (see
`Surface.tessellate`) picks its own from a seed made from where it is. They're thicker on the ground
in some places than others, and some places are rockier, following smooth noise over the world. Each
one stands on the surface along its normal, so they follow it round curves.

They're drawn flat on the surface like the walls (see `View.wallVS`), and kept off paving, paths,
walls and stairs (see `obstacles`). Making their meshes takes a while, so they're made in patches
(see `Patches`), and only the patches something is placed on are made again.

-}

import Array
import Bitwise
import Buildings exposing (Stairs, Wall)
import Dict exposing (Dict)
import Direction3d
import Math.Vector3 as Vec3 exposing (Vec3)
import Point3d
import Random exposing (Generator)
import Shapes exposing (Paving)
import Surface exposing (Surface)
import WebGL
import WorldMesh exposing (WallVertex)


type alias Vec =
    { x : Float, y : Float, z : Float }


type Kind
    = Pebble
    | Rock
    | Tuft
    | Flower


{-| Something lying on the surface at `position`, standing along `normal`. `size` is how far it
reaches out from there, in meters, and `seed` picks its shape.
-}
type alias Detail =
    { position : Vec
    , normal : Vec
    , kind : Kind
    , size : Float
    , seed : Int
    }



---- WHERE THEY GO ----


{-| The surface is split into triangles at least this often round its curves to scatter things on.
Things sit on the triangles rather than the surface, but they're less than a millimeter apart.
-}
step : Float
step =
    pi / 24


{-| The most things there are on a square meter, where the ground is thickest with them.
-}
mostPerSquareMeter : Float
mostPerSquareMeter =
    90


{-| How far apart, in meters, places that are thick with things or rocky are.
-}
thicknessScale : Float
thicknessScale =
    0.9


rockinessScale : Float
rockinessScale =
    0.6


{-| Things scattered over the whole surface.
-}
scatter : Surface coordinates -> List Detail
scatter surface =
    Surface.tessellate step surface |> List.concatMap onTriangle


onTriangle : ( Surface.MeshVertex, Surface.MeshVertex, Surface.MeshVertex ) -> List Detail
onTriangle ( a, b, c ) =
    let
        ab =
            sub b.position a.position

        ac =
            sub c.position a.position

        expected =
            lengthOf (cross ab ac) / 2 * mostPerSquareMeter

        centre =
            scale (1 / 3) (add a.position (add b.position c.position))

        count =
            Random.float 0 1
                |> Random.map
                    (\r ->
                        if r < expected - toFloat (floor expected) then
                            floor expected + 1

                        else
                            floor expected
                    )
    in
    Random.step
        (count |> Random.andThen (\n -> Random.list n (candidate a b c)))
        (Random.initialSeed (hashPoint 10000 centre 0))
        |> Tuple.first
        |> List.filterMap identity


{-| Something at a random point on a triangle, if the ground there is thick enough with things.
-}
candidate : Surface.MeshVertex -> Surface.MeshVertex -> Surface.MeshVertex -> Generator (Maybe Detail)
candidate a b c =
    Random.map4
        (\( u0, v0 ) keep pick ( sizing, seed ) ->
            let
                ( u, v ) =
                    if u0 + v0 > 1 then
                        ( 1 - u0, 1 - v0 )

                    else
                        ( u0, v0 )

                w =
                    1 - u - v

                position =
                    add (scale w a.position) (add (scale u b.position) (scale v c.position))

                normal =
                    add (scale w a.normal) (add (scale u b.normal) (scale v c.normal)) |> normalize

                thickness =
                    smoothNoise 1 thicknessScale position

                rocky =
                    smoothNoise 2 rockinessScale position ^ 2

                kind =
                    if pick < 0.12 + 0.45 * rocky then
                        Pebble

                    else if pick < 0.15 + 0.65 * rocky then
                        Rock

                    else if pick > 0.91 + 0.09 * rocky then
                        Flower

                    else
                        Tuft

                size =
                    case kind of
                        Pebble ->
                            0.007 + 0.009 * sizing

                        Rock ->
                            0.018 + 0.03 * sizing * sizing

                        Tuft ->
                            0.022 + 0.018 * sizing

                        Flower ->
                            0.028 + 0.014 * sizing
            in
            if keep < 0.1 + 0.9 * thickness * thickness then
                Just { position = position, normal = normal, kind = kind, size = size, seed = seed }

            else
                Nothing
        )
        (Random.pair (Random.float 0 1) (Random.float 0 1))
        (Random.float 0 1)
        (Random.float 0 1)
        (Random.pair (Random.float 0 1) (Random.int 0 Random.maxInt))


{-| A whole number for a point, rounded to `1 / perMeter` meters, different for each `salt`.
-}
hashPoint : Float -> Vec -> Int -> Int
hashPoint perMeter p salt =
    hash (round (p.x * perMeter)) (round (p.y * perMeter)) (round (p.z * perMeter)) salt


hash : Int -> Int -> Int -> Int -> Int
hash i j k salt =
    -- The products stay well inside what JavaScript numbers hold exactly, and xor wraps them to 32 bits
    Bitwise.xor (Bitwise.xor (i * 73856093) (j * 19349663)) (Bitwise.xor (k * 83492791) (salt * 2654435761))


{-| Smooth random values from 0 to 1 over space, changing about every `spacing` meters.
-}
smoothNoise : Int -> Float -> Vec -> Float
smoothNoise salt spacing p =
    let
        x =
            p.x / spacing

        y =
            p.y / spacing

        z =
            p.z / spacing

        i =
            floor x

        j =
            floor y

        k =
            floor z

        ease t =
            t * t * (3 - 2 * t)

        fx =
            ease (x - toFloat i)

        fy =
            ease (y - toFloat j)

        fz =
            ease (z - toFloat k)

        at di dj dk =
            Random.step (Random.float 0 1) (Random.initialSeed (hash (i + di) (j + dj) (k + dk) salt)) |> Tuple.first

        mix t p0 p1 =
            p0 + (p1 - p0) * t

        alongX dj dk =
            mix fx (at 0 dj dk) (at 1 dj dk)
    in
    mix fz
        (mix fy (alongX 0 0) (alongX 1 0))
        (mix fy (alongX 0 1) (alongX 1 1))



---- KEEPING THEM OFF THINGS ----


{-| Something things are kept away from: a line (a wall) or a triangle (of paving, a path or stairs),
and how close things may come to it.
-}
type Obstacle
    = Line Vec Vec Float
    | Area Vec Vec Vec Float


{-| Obstacles sorted into the cells of a grid they're near, so each thing only checks the ones close
to it.
-}
type Obstacles
    = Obstacles (Dict ( Int, Int, Int ) (List Obstacle))


cellSize : Float
cellSize =
    0.2


cellOf : Vec -> ( Int, Int, Int )
cellOf p =
    ( floor (p.x / cellSize), floor (p.y / cellSize), floor (p.z / cellSize) )


{-| Things reach out at most this far, in meters.
-}
largestSize : Float
largestSize =
    0.05


{-| Things are kept this far from walls and stairs (beyond how far they reach out) and from paving
and paths.
-}
wallGap : Float
wallGap =
    WorldMesh.wallThickness / 2 + 0.008


pavingGap : Float
pavingGap =
    0.006


{-| What things are kept off: the walls standing on the surface, paving, paths, and stairs starting
on the surface.
-}
obstacles :
    Surface coordinates
    -> { walls : List Wall, pavings : List Paving, paths : List (List ( Float, Float, Float )), stairs : List Stairs }
    -> Obstacles
obstacles surface { walls, pavings, paths, stairs } =
    let
        lines points =
            List.map2 (\p q -> Line p q wallGap) points (List.drop 1 points)

        areas gap paving =
            let
                points =
                    paving.points |> List.map fromTuple |> Array.fromList
            in
            List.filterMap
                (\( i, j, k ) ->
                    Maybe.map3 (\p q r -> Area p q r gap) (Array.get i points) (Array.get j points) (Array.get k points)
                )
                paving.triangles

        flight stairs_ =
            let
                up =
                    Surface.nearestPoint (Point3d.fromMeters stairs_.bottom) surface
                        |> Maybe.map (.normal >> Direction3d.unwrap)
                        |> Maybe.withDefault { x = 0, y = 1, z = 0 }

                across =
                    cross (sub stairs_.top stairs_.bottom) up |> normalize |> scale (stairs_.width / 2)

                corners =
                    [ sub stairs_.bottom across, add stairs_.bottom across, add stairs_.top across, sub stairs_.top across ]
            in
            case corners of
                [ p, q, r, s ] ->
                    [ Area p q r wallGap, Area p r s wallGap ]

                _ ->
                    []
    in
    (List.filter (\wall -> wall.bottom < 0.01) walls |> List.concatMap (.points >> List.map fromTuple >> lines))
        ++ List.concatMap (areas pavingGap) pavings
        ++ List.concatMap (Shapes.pathPaving surface Shapes.pathWidth >> areas pavingGap) paths
        ++ (List.filter (\stairs_ -> stairs_.elevation < 0.01) stairs |> List.concatMap flight)
        |> List.foldl addObstacle Dict.empty
        |> Obstacles


addObstacle : Obstacle -> Dict ( Int, Int, Int ) (List Obstacle) -> Dict ( Int, Int, Int ) (List Obstacle)
addObstacle obstacle cells =
    let
        ( points, gap ) =
            case obstacle of
                Line p q gap_ ->
                    ( [ p, q ], gap_ )

                Area p q r gap_ ->
                    ( [ p, q, r ], gap_ )

        reach =
            gap + largestSize

        lowest f =
            List.map f points |> List.minimum |> Maybe.withDefault 0 |> (\v -> floor ((v - reach) / cellSize))

        highest f =
            List.map f points |> List.maximum |> Maybe.withDefault 0 |> (\v -> floor ((v + reach) / cellSize))

        range f =
            List.range (lowest f) (highest f)
    in
    List.foldl
        (\i acc ->
            List.foldl
                (\j acc2 ->
                    List.foldl
                        (\k acc3 -> Dict.update ( i, j, k ) (\list -> Just (obstacle :: Maybe.withDefault [] list)) acc3)
                        acc2
                        (range .z)
                )
                acc
                (range .y)
        )
        cells
        (range .x)


{-| The things that aren't on or too close to any of the obstacles.
-}
clearOf : Obstacles -> List Detail -> List Detail
clearOf (Obstacles cells) details =
    if Dict.isEmpty cells then
        details

    else
        List.filter
            (\detail ->
                case Dict.get (cellOf detail.position) cells of
                    Just near ->
                        not (List.any (blocks detail) near)

                    Nothing ->
                        True
            )
            details


blocks : Detail -> Obstacle -> Bool
blocks detail obstacle =
    let
        p =
            detail.position
    in
    case obstacle of
        Line a b gap ->
            distanceToSegment p a b - (gap + detail.size) < 0

        Area a b c gap ->
            let
                reach =
                    gap + detail.size
            in
            inside p a b c
                || (distanceToSegment p a b - reach < 0)
                || (distanceToSegment p b c - reach < 0)
                || (distanceToSegment p c a - reach < 0)


distanceToSegment : Vec -> Vec -> Vec -> Float
distanceToSegment p a b =
    let
        ab =
            sub b a

        lengthSquared =
            dot ab ab

        t =
            if lengthSquared > 0 then
                clamp 0 1 (dot (sub p a) ab / lengthSquared)

            else
                0
    in
    lengthOf (sub p (add a (scale t ab)))


{-| Whether a point is over or under a triangle, and close to it.
-}
inside : Vec -> Vec -> Vec -> Vec -> Bool
inside p a b c =
    let
        v0 =
            sub b a

        v1 =
            sub c a

        v2 =
            sub p a

        d00 =
            dot v0 v0

        d01 =
            dot v0 v1

        d11 =
            dot v1 v1

        d20 =
            dot v2 v0

        d21 =
            dot v2 v1

        denominator =
            d00 * d11 - d01 * d01

        u =
            (d11 * d20 - d01 * d21) / denominator

        v =
            (d00 * d21 - d01 * d20) / denominator

        n =
            cross v0 v1 |> normalize
    in
    denominator > 0 && u >= 0 && v >= 0 && u + v <= 1 && abs (dot v2 n) - 0.03 < 0



---- WHAT THEY LOOK LIKE ----


{-| Things grouped by where they are, each group with its mesh made already.
-}
type Patches
    = Patches (List { details : List Detail, mesh : WebGL.Mesh WallVertex })


patchSize : Float
patchSize =
    1.5


patches : List Detail -> Patches
patches details =
    List.foldl
        (\detail ->
            let
                p =
                    detail.position
            in
            Dict.update ( floor (p.x / patchSize), floor (p.y / patchSize), floor (p.z / patchSize) )
                (\list -> Just (detail :: Maybe.withDefault [] list))
        )
        Dict.empty
        details
        |> Dict.values
        |> List.map (\inPatch -> { details = inPatch, mesh = mesh inPatch })
        |> Patches


{-| The meshes of the things not on or too close to any of the obstacles.
-}
meshes : Obstacles -> Patches -> List (WebGL.Mesh WallVertex)
meshes obstacles_ (Patches list) =
    List.map
        (\patch ->
            let
                clear =
                    clearOf obstacles_ patch.details
            in
            if List.length clear == List.length patch.details then
                patch.mesh

            else
                mesh clear
        )
        list


mesh : List Detail -> WebGL.Mesh WallVertex
mesh details =
    List.concatMap triangles details |> WebGL.triangles


{-| Where a thing is, in its own coordinates: x and y along the surface, z up from it.
-}
type alias Frame =
    { origin : Vec, x : Vec, y : Vec, z : Vec }


type alias Triangle =
    ( WallVertex, WallVertex, WallVertex )


triangles : Detail -> List Triangle
triangles detail =
    let
        seed0 =
            Random.initialSeed detail.seed

        ( turn, seed1 ) =
            Random.step (Random.float 0 (2 * pi)) seed0

        n =
            detail.normal

        -- Any direction along the surface, turned by `turn`
        side =
            if abs n.x < 0.9 then
                cross n { x = 1, y = 0, z = 0 } |> normalize

            else
                cross n { x = 0, y = 1, z = 0 } |> normalize

        x =
            add (scale (cos turn) side) (scale (sin turn) (cross n side))

        frame =
            { origin = detail.position, x = x, y = cross n x, z = n }

        shape =
            case detail.kind of
                Pebble ->
                    stone { sides = 5, height = 0.45, shoulder = 0.75 } detail.size

                Rock ->
                    stone { sides = 7, height = 0.65, shoulder = 0.7 } detail.size

                Tuft ->
                    tuft detail.size

                Flower ->
                    flower detail.size
    in
    Random.step shape seed1 |> Tuple.first |> List.map (toWorld frame)


{-| A triangle in a thing's own coordinates, with a color for each corner.
-}
type alias LocalTriangle =
    { points : ( Vec, Vec, Vec ), colors : ( Vec3, Vec3, Vec3 ) }


toWorld : Frame -> LocalTriangle -> Triangle
toWorld frame { points, colors } =
    let
        ( a, b, c ) =
            points

        ( ca, cb, cc ) =
            colors

        world p =
            frame.origin |> add (scale p.x frame.x) |> add (scale p.y frame.y) |> add (scale p.z frame.z)

        ( wa, wb, wc ) =
            ( world a, world b, world c )

        normal =
            cross (sub wb wa) (sub wc wa) |> normalize |> Vec3.fromRecord

        vertex position color =
            { position = Vec3.fromRecord position
            , normal = normal
            , color = color
            , base = Vec3.fromRecord frame.origin
            , up = Vec3.fromRecord frame.z
            }
    in
    ( vertex wa ca, vertex wb cb, vertex wc cc )


plain : Vec3 -> Vec -> Vec -> Vec -> LocalTriangle
plain color a b c =
    { points = ( a, b, c ), colors = ( color, color, color ) }


{-| Both sides of a thin thing, like a blade of grass.
-}
twoSided : LocalTriangle -> List LocalTriangle
twoSided triangle =
    let
        ( a, b, c ) =
            triangle.points

        ( ca, cb, cc ) =
            triangle.colors
    in
    [ triangle, { points = ( a, c, b ), colors = ( ca, cc, cb ) } ]


{-| A lumpy stone: a ring of corners on the ground, a smaller ring higher up, and a top.
-}
stone : { sides : Int, height : Float, shoulder : Float } -> Float -> Generator (List LocalTriangle)
stone { sides, height, shoulder } radius =
    Random.map4
        (\grey warmth ( lows, highs ) ( topX, topY, tall ) ->
            let
                ring rs z twist =
                    List.indexedMap
                        (\i r ->
                            let
                                angle =
                                    (toFloat i + twist) * 2 * pi / toFloat sides
                            in
                            { x = r * cos angle, y = r * sin angle, z = z }
                        )
                        rs
                        |> Array.fromList

                h =
                    radius * height * tall

                low =
                    ring (List.map (\r -> r * radius) lows) -0.001 0

                high =
                    ring (List.map (\r -> r * radius * shoulder) highs) (h * 0.6) 0.5

                top =
                    { x = topX * radius, y = topY * radius, z = h }

                at points i =
                    Array.get (modBy sides i) points |> Maybe.withDefault top

                color lightness =
                    Vec3.vec3 (grey * lightness + warmth) (grey * lightness + warmth * 0.5) (grey * lightness - warmth * 0.3)
            in
            List.range 0 (sides - 1)
                |> List.concatMap
                    (\i ->
                        [ plain (color 0.8) (at low i) (at low (i + 1)) (at high i)
                        , plain (color 0.9) (at high i) (at low (i + 1)) (at high (i + 1))
                        , plain (color 1.05) (at high i) (at high (i + 1)) top
                        ]
                    )
        )
        (Random.float 0.48 0.7)
        (Random.float -0.03 0.06)
        (Random.pair (Random.list sides (Random.float 0.75 1.1)) (Random.list sides (Random.float 0.8 1.15)))
        (Random.map3 (\a b c -> ( a, b, c )) (Random.float -0.15 0.15) (Random.float -0.15 0.15) (Random.float 0.75 1.25))


{-| Blades of grass leaning out from the middle.
-}
blades : { count : Int, radius : Float, height : Float } -> Generator (List LocalTriangle)
blades { count, radius, height } =
    Random.map2
        (\( r, g, b ) bladeShapes ->
            List.indexedMap
                (\i ( jitter, tall, lean ) ->
                    let
                        angle =
                            (toFloat i + jitter) * 2 * pi / toFloat count

                        out =
                            { x = cos angle, y = sin angle, z = 0 }

                        across =
                            { x = -out.y, y = out.x, z = 0 }

                        width =
                            0.0028

                        h =
                            height * tall

                        tip =
                            add (scale (radius * lean) out) { x = 0, y = 0, z = h }

                        base =
                            Vec3.vec3 (r * 0.7) (g * 0.75) (b * 0.7)

                        top =
                            Vec3.vec3 (r * 1.15) (g * 1.12) (b * 1.05)
                    in
                    { points = ( scale -width across, scale width across, tip ), colors = ( base, base, top ) }
                        |> twoSided
                )
                bladeShapes
                |> List.concat
        )
        (Random.map3 (\r g b -> ( r, g, b )) (Random.float 0.3 0.45) (Random.float 0.5 0.66) (Random.float 0.22 0.32))
        (Random.list count (Random.map3 (\a b c -> ( a, b, c )) (Random.float -0.35 0.35) (Random.float 0.6 1.1) (Random.float 0.8 1.2)))


tuft : Float -> Generator (List LocalTriangle)
tuft radius =
    Random.int 6 10 |> Random.andThen (\count -> blades { count = count, radius = radius, height = radius * 0.6 })


{-| A few leaves and a stem with a flower on top.
-}
flower : Float -> Generator (List LocalTriangle)
flower radius =
    Random.map4
        (\leaves petalColor ( leanX, leanY ) petalTurn ->
            let
                stemHeight =
                    radius * 1.3

                head =
                    { x = leanX * radius, y = leanY * radius, z = stemHeight }

                stemColor =
                    Vec3.vec3 0.3 0.5 0.24

                stem =
                    plain stemColor { x = -0.0012, y = 0, z = 0 } { x = 0.0012, y = 0, z = 0 } head |> twoSided

                petalRadius =
                    radius * 0.55

                petal i =
                    let
                        angle =
                            (toFloat i + petalTurn) * 2 * pi / 5

                        around a r z =
                            { x = head.x + r * cos a, y = head.y + r * sin a, z = head.z + z }
                    in
                    [ plain petalColor head (around (angle - 0.45) petalRadius 0) (around angle (petalRadius * 1.15) 0)
                    , plain petalColor head (around angle (petalRadius * 1.15) 0) (around (angle + 0.45) petalRadius 0)
                    , plain (Vec3.vec3 0.95 0.78 0.2)
                        (around angle (petalRadius * 0.3) 0.0005)
                        (around (angle + 2 * pi / 5) (petalRadius * 0.3) 0.0005)
                        { head | z = head.z + 0.0005 }
                    ]
            in
            leaves ++ stem ++ List.concatMap petal (List.range 0 4)
        )
        (blades { count = 3, radius = radius * 0.7, height = radius })
        (Random.uniform (Vec3.vec3 0.97 0.97 0.93)
            [ Vec3.vec3 0.98 0.85 0.25
            , Vec3.vec3 0.92 0.55 0.7
            , Vec3.vec3 0.62 0.55 0.9
            , Vec3.vec3 0.9 0.35 0.3
            ]
        )
        (Random.pair (Random.float -0.3 0.3) (Random.float -0.3 0.3))
        (Random.float 0 1)



---- VECTORS ----


fromTuple : ( Float, Float, Float ) -> Vec
fromTuple ( x, y, z ) =
    { x = x, y = y, z = z }


add : Vec -> Vec -> Vec
add a b =
    { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }


sub : Vec -> Vec -> Vec
sub a b =
    { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }


scale : Float -> Vec -> Vec
scale s a =
    { x = s * a.x, y = s * a.y, z = s * a.z }


dot : Vec -> Vec -> Float
dot a b =
    a.x * b.x + a.y * b.y + a.z * b.z


cross : Vec -> Vec -> Vec
cross a b =
    { x = a.y * b.z - a.z * b.y
    , y = a.z * b.x - a.x * b.z
    , z = a.x * b.y - a.y * b.x
    }


lengthOf : Vec -> Float
lengthOf a =
    sqrt (dot a a)


normalize : Vec -> Vec
normalize a =
    let
        l =
            lengthOf a
    in
    if l > 0 then
        scale (1 / l) a

    else
        a
