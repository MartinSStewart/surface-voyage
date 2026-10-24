module WorldMesh exposing (WallVertex, mesh, pathMesh, playerMesh, roofMesh, stairsColor, wallColor, wallMesh, wallThickness)

{-| What the world looks like: the surface with the paving laid on it, and the walls (see
`WorldShapes`).

The walls are made as blocks standing on the surface, but they're drawn flat on it, as their
perspective image seen from an eye above the player (see `View.wallVS`). So each corner of a wall
also knows the point on the surface it stands on and the surface's normal there.

-}

import Array
import Buildings exposing (Roof, Stairs, Wall)
import Direction3d
import Math.Vector3 as Vec3 exposing (Vec3)
import MeshBuilder exposing (Vertex)
import Point3d
import Shapes exposing (Paving)
import Surface exposing (Surface)
import WebGL


type alias Vec =
    { x : Float, y : Float, z : Float }


{-| A point on the surface and the surface's outward normal there.
-}
type alias OnSurface =
    { position : Vec, normal : Vec }


type alias Triangle =
    ( Vertex, Vertex, Vertex )


{-| A corner of a wall: where it is as part of a block standing on the surface, the point it stands
on (`base`), and the surface's outward normal there (`up`).
-}
type alias WallVertex =
    { position : Vec3
    , normal : Vec3
    , color : Vec3
    , base : Vec3
    , up : Vec3
    }


grassColor : Vec3
grassColor =
    Vec3.vec3 (144 / 255) (187 / 255) (146 / 255)


pavingColor : Vec3
pavingColor =
    Vec3.vec3 (187 / 255) (157 / 255) (72 / 255)


wallColor : Vec3
wallColor =
    Vec3.vec3 0.22 0.2 0.18


roofColor : Vec3
roofColor =
    Vec3.vec3 0.62 0.3 0.24


stairsColor : Vec3
stairsColor =
    Vec3.vec3 0.55 0.52 0.48


dirtColor : Vec3
dirtColor =
    Vec3.vec3 (140 / 255) (100 / 255) (62 / 255)


{-| Dirt paths are drawn this much higher than the paving, so they show on top of it.
-}
dirtHeight : Float
dirtHeight =
    0.0035


{-| The surface is drawn with a point at least every this many radians round its curves. It divides
a quarter turn, so the pieces' edges line up (see `Surface.tessellate`).
-}
surfaceStep : Float
surfaceStep =
    pi / 48


{-| How far above the surface paving is drawn, in meters, so that it shows over it.
-}
pavingHeight : Float
pavingHeight =
    0.003


{-| Paving triangles are split until no edge is longer than this, in meters, where the surface curves,
so that they follow it.
-}
pavingEdge : Float
pavingEdge =
    0.04


{-| Whether a paving edge needs splitting: it's long, and the surface turns between its ends.
-}
pavingEdgeTooLong : OnSurface -> OnSurface -> Bool
pavingEdgeTooLong p q =
    let
        d =
            sub p.position q.position
    in
    (d.x * d.x + d.y * d.y + d.z * d.z) - pavingEdge * pavingEdge > 0 && dot p.normal q.normal - 0.99999 < 0


wallHeight : Float
wallHeight =
    0.08


wallThickness : Float
wallThickness =
    0.025


{-| Walls get a point at least this often, in meters, so that they follow the surface round curves.
-}
wallStep : Float
wallStep =
    0.04


snap : Surface coordinates -> Vec -> OnSurface
snap surface p =
    case Surface.nearestPoint (Point3d.meters p.x p.y p.z) surface of
        Just nearest ->
            { position = Point3d.toMeters nearest.position, normal = Direction3d.unwrap nearest.normal }

        Nothing ->
            { position = p, normal = { x = 0, y = 1, z = 0 } }


{-| The surface and the paving.
-}
mesh : Surface coordinates -> List Paving -> WebGL.Mesh Vertex
mesh surface pavings =
    surfaceTriangles surface
        ++ pavingTriangles (snap surface) pavings
        |> WebGL.triangles


{-| Walls and stairs, in the colors given (lighter ones for things being placed).
-}
wallMesh : Surface coordinates -> { walls : Vec3, stairs : Vec3 } -> List Wall -> List Stairs -> WebGL.Mesh WallVertex
wallMesh surface colors walls stairs =
    List.concatMap (\wall -> List.map (\( x, y, z ) -> { x = x, y = y, z = z }) wall.points |> wallTriangles (snap surface) colors.walls wall.bottom) walls
        ++ List.concatMap (stairsTriangles (snap surface) colors.stairs) stairs
        |> WebGL.triangles


{-| A roof, in `roofColor` or another color. Roofs are drawn over everything else that's flat, as
nothing under a roof shows.
-}
roofMesh : Surface coordinates -> Maybe Vec3 -> Roof -> WebGL.Mesh WallVertex
roofMesh surface color roof =
    block (snap surface) (Maybe.withDefault roofColor color) { sides = False } 0 roof.height (overhung roof)
        |> WebGL.triangles


{-| A roof's corners moved out by its overhang, keeping its edges parallel.
-}
overhung : Roof -> List Vec
overhung roof =
    if roof.overhang == 0 then
        roof.corners

    else
        let
            normal =
                Buildings.roofNormal roof.corners

            count =
                List.length roof.corners

            corners =
                Array.fromList roof.corners

            at i =
                Array.get (modBy count i) corners |> Maybe.withDefault { x = 0, y = 0, z = 0 }

            -- Out from the edge from corner i to i + 1
            outOf i =
                cross (sub (at (i + 1)) (at i)) normal |> normalize
        in
        List.range 0 (count - 1)
            |> List.map
                (\i ->
                    let
                        a =
                            outOf (i - 1)

                        b =
                            outOf i
                    in
                    along (roof.overhang / max 0.3 (1 + dot a b)) (add a b) (at i)
                )


{-| Dirt paths along lines of points, or lighter while one is being placed.
-}
pathMesh : Surface coordinates -> { preview : Bool } -> List (List ( Float, Float, Float )) -> WebGL.Mesh Vertex
pathMesh surface { preview } paths =
    let
        color =
            if preview then
                Vec3.add (Vec3.scale 0.5 dirtColor) (Vec3.vec3 0.45 0.45 0.45)

            else
                dirtColor

        ( points, triangles ) =
            List.map (Shapes.pathPaving surface Shapes.pathWidth) paths
                |> Shapes.splitPavings pavingEdgeTooLong (snap surface) .position

        at index =
            Array.get index points
                |> Maybe.map (\p -> vertex color (along dirtHeight p.normal p.position) p.normal)
    in
    List.filterMap
        (\( i, j, k ) ->
            Maybe.map3 (\a b c -> facing (Vec3.add a.normal (Vec3.add b.normal c.normal)) a b c) (at i) (at j) (at k)
        )
        triangles
        |> WebGL.triangles


{-| The player, drawn flat like the walls: a body with a nose on the front to show which way they're
facing. It's made where the player would stand at the origin, facing y with z up, and moved to where
they are when drawn (see `View.wallVS`).
-}
playerMesh : WebGL.Mesh WallVertex
playerMesh =
    let
        onGround p =
            { position = { p | z = 0 }, normal = { x = 0, y = 0, z = 1 } }

        body =
            List.range 0 (playerSides - 1)
                |> List.map
                    (\i ->
                        let
                            angle =
                                2 * pi * toFloat i / toFloat playerSides
                        in
                        { x = playerRadius * cos angle, y = playerRadius * sin angle, z = 0 }
                    )

        nose =
            [ { x = -0.012, y = 0.015, z = 0 }
            , { x = 0.012, y = 0.015, z = 0 }
            , { x = 0.012, y = 0.045, z = 0 }
            , { x = -0.012, y = 0.045, z = 0 }
            ]
    in
    block onGround noseColor { sides = True } 0 0.06 nose
        ++ block onGround playerColor { sides = True } 0 playerHeight body
        |> WebGL.triangles


playerColor : Vec3
playerColor =
    Vec3.vec3 0.85 0.1 0.1


noseColor : Vec3
noseColor =
    Vec3.vec3 0.95 0.75 0.3


{-| In meters. The player's body fits in the 4 cm walls keep them from (see `WallCollision.clearance`),
their nose just about.
-}
playerRadius : Float
playerRadius =
    0.03


playerHeight : Float
playerHeight =
    0.09


playerSides : Int
playerSides =
    12


{-| Each step is a block, as high as the step, from the step's front to the next step.
-}
stairsTriangles : (Vec -> OnSurface) -> Vec3 -> Stairs -> List ( WallVertex, WallVertex, WallVertex )
stairsTriangles onSurface color flight =
    let
        run =
            sub flight.top flight.bottom

        across =
            cross run (onSurface flight.bottom).normal |> normalize |> scale (flight.width / 2)

        at t side =
            flight.bottom |> along t run |> along side across

        step i =
            let
                t0 =
                    toFloat (i - 1) / toFloat flight.steps

                t1 =
                    toFloat i / toFloat flight.steps
            in
            [ at t0 -1, at t1 -1, at t1 1, at t0 1 ]
                |> block onSurface color { sides = True } flight.elevation (flight.elevation + flight.height * t1)
    in
    List.range 1 flight.steps |> List.concatMap step


{-| A block over the surface: a top `height` above its corners, and sides down to `bottom` above them.
-}
block : (Vec -> OnSurface) -> Vec3 -> { sides : Bool } -> Float -> Float -> List Vec -> List ( WallVertex, WallVertex, WallVertex )
block onSurface color { sides } bottom height corners =
    let
        bases =
            List.map onSurface corners

        corner base =
            { base = base, low = along bottom base.normal base.position, top = along height base.normal base.position }

        withTops =
            List.map corner bases

        blockVertex normal position c =
            { position = Vec3.fromRecord position
            , normal = Vec3.fromRecord normal
            , color = color
            , base = Vec3.fromRecord c.base.position
            , up = Vec3.fromRecord c.base.normal
            }

        topTriangles =
            case withTops of
                first :: _ ->
                    let
                        tops =
                            Array.fromList withTops

                        topVertex i =
                            Array.get i tops |> Maybe.map (\c -> blockVertex first.base.normal c.top c)
                    in
                    triangulate first.base.normal corners
                        |> List.filterMap
                            (\( i, j, k ) ->
                                Maybe.map3 (wallFacing (Vec3.fromRecord first.base.normal)) (topVertex i) (topVertex j) (topVertex k)
                            )

                [] ->
                    []

        center =
            List.foldl (\c acc -> along (1 / toFloat (List.length withTops)) c.base.position acc) { x = 0, y = 0, z = 0 } withTops

        side ( c, d ) =
            let
                outward =
                    cross (sub d.base.position c.base.position) c.base.normal |> normalize

                facingOut =
                    if dot outward (sub c.base.position center) < 0 then
                        scale -1 outward

                    else
                        outward
            in
            [ wallFacing (Vec3.fromRecord facingOut) (blockVertex facingOut c.low c) (blockVertex facingOut d.low d) (blockVertex facingOut d.top d)
            , wallFacing (Vec3.fromRecord facingOut) (blockVertex facingOut c.low c) (blockVertex facingOut d.top d) (blockVertex facingOut c.top c)
            ]

        sideTriangles =
            if sides then
                List.map2 Tuple.pair withTops (List.drop 1 withTops ++ List.take 1 withTops) |> List.concatMap side

            else
                []
    in
    topTriangles ++ sideTriangles


vertex : Vec3 -> Vec -> Vec -> Vertex
vertex color position normal =
    { position = Vec3.fromRecord position, normal = Vec3.fromRecord normal, color = color }


surfaceTriangles : Surface coordinates -> List Triangle
surfaceTriangles surface =
    Surface.tessellate surfaceStep surface
        |> List.map
            (\( a, b, c ) ->
                ( vertex grassColor a.position a.normal
                , vertex grassColor b.position b.normal
                , vertex grassColor c.position c.normal
                )
            )


pavingTriangles : (Vec -> OnSurface) -> List Paving -> List Triangle
pavingTriangles onSurface pavings =
    let
        ( points, triangles ) =
            Shapes.splitPavings pavingEdgeTooLong onSurface .position pavings

        at index =
            Array.get index points
                |> Maybe.map (\p -> vertex pavingColor (along pavingHeight p.normal p.position) p.normal)
    in
    List.filterMap
        (\( i, j, k ) ->
            Maybe.map3 (\a b c -> facing (Vec3.add a.normal (Vec3.add b.normal c.normal)) a b c) (at i) (at j) (at k)
        )
        triangles


{-| A wall standing `bottom` above the surface along a line of points: two sides, a top and two ends
(none if it goes round in a loop). It's mitred where it turns corners, so it's as thick all along.
-}
wallTriangles : (Vec -> OnSurface) -> Vec3 -> Float -> List Vec -> List ( WallVertex, WallVertex, WallVertex )
wallTriangles onSurface color bottom points =
    let
        onWall =
            Shapes.alongWall wallStep points

        -- Across the wall at a point, to its right going along it
        section p =
            let
                corner side up =
                    p.position
                        |> along (side * wallThickness / 2) p.right
                        |> along up p.normal
            in
            { right = normalize p.right
            , up = p.normal
            , along = p.along
            , base = p
            , bottomLeft = corner -1 bottom
            , bottomRight = corner 1 bottom
            , topLeft = corner -1 (bottom + wallHeight)
            , topRight = corner 1 (bottom + wallHeight)
            }

        sections =
            Shapes.sections onSurface onWall |> List.map section

        wallVertex normal ( position, s ) =
            { position = Vec3.fromRecord position
            , normal = Vec3.fromRecord normal
            , color = color
            , base = Vec3.fromRecord s.base.position
            , up = Vec3.fromRecord s.base.normal
            }

        -- Corners are ( position, the section they're in )
        quad normal a b c d =
            [ wallFacing (Vec3.fromRecord normal) (wallVertex normal a) (wallVertex normal b) (wallVertex normal c)
            , wallFacing (Vec3.fromRecord normal) (wallVertex normal a) (wallVertex normal c) (wallVertex normal d)
            ]

        between s t =
            quad s.right ( s.bottomRight, s ) ( t.bottomRight, t ) ( t.topRight, t ) ( s.topRight, s )
                ++ quad (scale -1 s.right) ( s.bottomLeft, s ) ( s.topLeft, s ) ( t.topLeft, t ) ( t.bottomLeft, t )
                ++ quad s.up ( s.topLeft, s ) ( s.topRight, s ) ( t.topRight, t ) ( t.topLeft, t )

        sides =
            List.map2 between sections (List.drop 1 sections) |> List.concat

        end s outward =
            quad outward ( s.bottomLeft, s ) ( s.bottomRight, s ) ( s.topRight, s ) ( s.topLeft, s )
    in
    case ( sections, List.reverse sections ) of
        ( first :: _ :: _, last :: _ ) ->
            if Shapes.isClosed onWall then
                sides

            else
                sides ++ end first (scale -1 first.along) ++ end last last.along

        _ ->
            []


{-| Triangles covering a polygon (convex or not), as indices into its corners, by cutting off ears:
corners whose triangle with their neighbours is inside the polygon and has no other corner in it.
`normal` is roughly the way the polygon faces.
-}
triangulate : Vec -> List Vec -> List ( Int, Int, Int )
triangulate normal corners =
    let
        u =
            case corners of
                a :: b :: _ ->
                    let
                        d =
                            sub b a
                    in
                    normalize (sub d (scale (dot d normal) normal))

                _ ->
                    { x = 1, y = 0, z = 0 }

        v =
            cross normal u

        flat =
            List.indexedMap (\i p -> { i = i, x = dot p u, y = dot p v }) corners

        area =
            List.map2 (\a b -> a.x * b.y - b.x * a.y) flat (List.drop 1 flat ++ List.take 1 flat) |> List.sum

        counterclockwise =
            if area < 0 then
                List.reverse flat

            else
                flat

        turn a b c =
            (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

        inside a b c p =
            turn a b p >= 0 && turn b c p >= 0 && turn c a p >= 0

        clip remaining tries acc =
            case remaining of
                a :: b :: c :: rest ->
                    if List.isEmpty rest then
                        ( a.i, b.i, c.i ) :: acc

                    else if tries <= 0 then
                        -- Not a simple polygon: fan out what's left
                        List.map2 (\p q -> ( a.i, p.i, q.i )) (b :: c :: rest) (c :: rest) ++ acc

                    else if turn a b c > 0 && not (List.any (inside a b c) rest) then
                        clip (a :: c :: rest) (List.length rest + 2) (( a.i, b.i, c.i ) :: acc)

                    else
                        clip (b :: c :: rest ++ [ a ]) (tries - 1) acc

                _ ->
                    acc
    in
    clip counterclockwise (List.length corners) []


{-| A triangle turned to go counterclockwise seen from the side `normal` points to, so that it isn't
culled.
-}
facing : Vec3 -> Vertex -> Vertex -> Vertex -> Triangle
facing normal a b c =
    if Vec3.dot (Vec3.cross (Vec3.sub b.position a.position) (Vec3.sub c.position a.position)) normal >= 0 then
        ( a, b, c )

    else
        ( a, c, b )


wallFacing : Vec3 -> WallVertex -> WallVertex -> WallVertex -> ( WallVertex, WallVertex, WallVertex )
wallFacing normal a b c =
    if Vec3.dot (Vec3.cross (Vec3.sub b.position a.position) (Vec3.sub c.position a.position)) normal >= 0 then
        ( a, b, c )

    else
        ( a, c, b )


add : Vec -> Vec -> Vec
add a b =
    { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }


along : Float -> Vec -> Vec -> Vec
along distance direction p =
    { x = p.x + distance * direction.x, y = p.y + distance * direction.y, z = p.z + distance * direction.z }


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


normalize : Vec -> Vec
normalize a =
    let
        length =
            sqrt (a.x * a.x + a.y * a.y + a.z * a.z)
    in
    if length > 0 then
        scale (1 / length) a

    else
        a
