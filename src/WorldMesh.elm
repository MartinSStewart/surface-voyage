module WorldMesh exposing (mesh)

{-| What the world looks like: the surface, with the paving laid on it and the walls standing on it
(see `WorldShapes`).
-}

import Array
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


grassColor : Vec3
grassColor =
    Vec3.vec3 (144 / 255) (187 / 255) (146 / 255)


pavingColor : Vec3
pavingColor =
    Vec3.vec3 (187 / 255) (157 / 255) (72 / 255)


wallColor : Vec3
wallColor =
    Vec3.vec3 0.22 0.2 0.18


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


{-| Walls start this far below the surface, so that they don't float over it where it curves away.
-}
wallDepth : Float
wallDepth =
    0.01


mesh : Surface coordinates -> List (List ( Float, Float, Float )) -> List Paving -> WebGL.Mesh Vertex
mesh surface walls pavings =
    let
        onSurface p =
            case Surface.nearestPoint (Point3d.meters p.x p.y p.z) surface of
                Just nearest ->
                    { position = Point3d.toMeters nearest.position, normal = Direction3d.unwrap nearest.normal }

                Nothing ->
                    { position = p, normal = { x = 0, y = 1, z = 0 } }
    in
    surfaceTriangles surface
        ++ pavingTriangles onSurface pavings
        ++ List.concatMap (\wall -> List.map (\( x, y, z ) -> { x = x, y = y, z = z }) wall |> wallTriangles onSurface) walls
        |> WebGL.triangles


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
wallTriangles : (Vec -> OnSurface) -> List Vec -> List Triangle
wallTriangles onSurface points =
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
            , bottomLeft = corner -1 -wallDepth
            , bottomRight = corner 1 -wallDepth
            , topLeft = corner -1 wallHeight
            , topRight = corner 1 wallHeight
            }

        sections =
            List.range 0 (count - 1) |> List.map section

        quad normal a b c d =
            [ facing (Vec3.fromRecord normal) (vertex wallColor a normal) (vertex wallColor b normal) (vertex wallColor c normal)
            , facing (Vec3.fromRecord normal) (vertex wallColor a normal) (vertex wallColor c normal) (vertex wallColor d normal)
            ]

        between s t =
            quad s.right s.bottomRight t.bottomRight t.topRight s.topRight
                ++ quad (scale -1 s.right) s.bottomLeft s.topLeft t.topLeft t.bottomLeft
                ++ quad s.up s.topLeft s.topRight t.topRight t.topLeft

        sides =
            List.map2 between sections (List.drop 1 sections) |> List.concat

        end s outward =
            quad outward s.bottomLeft s.bottomRight s.topRight s.topLeft
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
