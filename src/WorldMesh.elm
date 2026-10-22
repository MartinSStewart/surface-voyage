module WorldMesh exposing (WallVertex, mesh, roofMesh, wallMesh)

{-| What the world looks like: the surface with the paving laid on it, and the walls (see
`WorldShapes`).

The walls are made as blocks standing on the surface, but they're drawn flat on it, as their
perspective image seen from an eye above the player (see `View.wallVS`). So each corner of a wall
also knows the point on the surface it stands on and the surface's normal there.

-}

import Array
import Buildings
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


{-| How far walls may be drawn from where they stand on curved parts of the surface, as how far
from its tangent plane the surface may get there, in meters.
-}
wallImageTolerance : Float
wallImageTolerance =
    0.002


type alias Triangle =
    ( Vertex, Vertex, Vertex )


{-| A corner of a wall: where it is as part of a block standing on the surface, the point it stands
on (`base`), the surface's outward normal there (`up`), and how far from `base` it can be drawn
while staying on the surface (see `Surface.flatReach`).
-}
type alias WallVertex =
    { position : Vec3
    , normal : Vec3
    , color : Vec3
    , base : Vec3
    , up : Vec3
    , reach : Float
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


{-| The walls and the stairs.
-}
wallMesh : Surface coordinates -> List (List ( Float, Float, Float )) -> WebGL.Mesh WallVertex
wallMesh surface walls =
    let
        reach p =
            Surface.flatReach wallImageTolerance (Point3d.fromMeters p) surface
    in
    List.concatMap (\wall -> List.map (\( x, y, z ) -> { x = x, y = y, z = z }) wall |> wallTriangles (snap surface) reach) walls
        ++ List.concatMap (stairsTriangles (snap surface) reach) Buildings.stairs
        |> WebGL.triangles


{-| The roofs. They're drawn over everything else that's flat, as nothing under a roof shows.
-}
roofMesh : Surface coordinates -> WebGL.Mesh WallVertex
roofMesh surface =
    let
        reach p =
            Surface.flatReach wallImageTolerance (Point3d.fromMeters p) surface
    in
    Buildings.roofs
        |> List.concatMap (\roof -> block (snap surface) reach roofColor { sides = False } roof.height roof.corners)
        |> WebGL.triangles


{-| Each step is a block, as high as the step, from the step's front to the next step.
-}
stairsTriangles : (Vec -> OnSurface) -> (Vec -> Float) -> Buildings.Stairs -> List ( WallVertex, WallVertex, WallVertex )
stairsTriangles onSurface reach flight =
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
                |> block onSurface reach stairsColor { sides = True } (flight.height * t1)
    in
    List.range 1 flight.steps |> List.concatMap step


{-| A block standing on the surface: a top `height` above its corners, and sides down to them.
-}
block : (Vec -> OnSurface) -> (Vec -> Float) -> Vec3 -> { sides : Bool } -> Float -> List Vec -> List ( WallVertex, WallVertex, WallVertex )
block onSurface reach color { sides } height corners =
    let
        bases =
            List.map onSurface corners

        corner base =
            { base = base, reach = reach base.position, top = along height base.normal base.position }

        withTops =
            List.map corner bases

        blockVertex normal position c =
            { position = Vec3.fromRecord position
            , normal = Vec3.fromRecord normal
            , color = color
            , base = Vec3.fromRecord c.base.position
            , up = Vec3.fromRecord c.base.normal
            , reach = c.reach
            }

        topTriangles =
            case withTops of
                first :: rest ->
                    List.map2
                        (\b c ->
                            wallFacing (Vec3.fromRecord first.base.normal)
                                (blockVertex first.base.normal first.top first)
                                (blockVertex first.base.normal b.top b)
                                (blockVertex first.base.normal c.top c)
                        )
                        rest
                        (List.drop 1 rest)

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
            [ wallFacing (Vec3.fromRecord facingOut) (blockVertex facingOut c.base.position c) (blockVertex facingOut d.base.position d) (blockVertex facingOut d.top d)
            , wallFacing (Vec3.fromRecord facingOut) (blockVertex facingOut c.base.position c) (blockVertex facingOut d.top d) (blockVertex facingOut c.top c)
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


{-| A wall standing on the surface along a line of points: two sides, a top and two ends.
-}
wallTriangles : (Vec -> OnSurface) -> (Vec -> Float) -> List Vec -> List ( WallVertex, WallVertex, WallVertex )
wallTriangles onSurface reach points =
    let
        onWall =
            Shapes.alongWall wallStep points |> List.map onSurface |> Array.fromList

        count =
            Array.length onWall

        at i =
            Array.get (clamp 0 (count - 1) i) onWall |> Maybe.withDefault { position = { x = 0, y = 0, z = 0 }, normal = { x = 0, y = 1, z = 0 } }

        -- Across the wall at a point, to its right going along it
        section i =
            let
                p =
                    at i

                along_ =
                    normalize (sub (at (i + 1)).position (at (i - 1)).position)

                right =
                    normalize (cross along_ p.normal)

                corner side up =
                    p.position
                        |> along (side * wallThickness / 2) right
                        |> along up p.normal
            in
            { right = right
            , up = p.normal
            , along = along_
            , base = p
            , reach = reach p.position
            , bottomLeft = corner -1 0
            , bottomRight = corner 1 0
            , topLeft = corner -1 wallHeight
            , topRight = corner 1 wallHeight
            }

        sections =
            List.range 0 (count - 1) |> List.map section

        wallVertex normal ( position, s ) =
            { position = Vec3.fromRecord position
            , normal = Vec3.fromRecord normal
            , color = wallColor
            , base = Vec3.fromRecord s.base.position
            , up = Vec3.fromRecord s.base.normal
            , reach = s.reach
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
            sides ++ end first (scale -1 first.along) ++ end last last.along

        _ ->
            []


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
