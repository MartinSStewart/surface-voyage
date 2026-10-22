module WallCollision exposing (Walls, blocksBelow, fromShapes, move, none)

{-| Walls stop the player, who slides along them instead of walking through.

The player is a circle `playerRadius` across on the surface. After each step, if they're closer to a
wall than that (plus half the wall's thickness), they're pushed straight back out, along the
surface. Moving into a wall at an angle, what's left of the step is the part along the wall, so they
slide.

-}

import Angle
import Direction3d
import Length
import Point3d
import Shapes
import Surface exposing (Surface, SurfacePoint)


type alias Vec =
    { x : Float, y : Float, z : Float }


{-| The walls' center lines, as short segments on the surface.
-}
type Walls
    = Walls (List { a : Vec, b : Vec })


{-| How far from a wall's center line the player's center is kept, in meters: half the wall's
thickness (`WorldMesh.wallThickness`) and the player's radius.
-}
clearance : Float
clearance =
    0.0125 + 0.04


{-| Walls only stop the player below this height above the surface, in meters: higher up (on a roof,
or near the top of the stairs) they can step over them.
-}
blocksBelow : Float
blocksBelow =
    0.05


{-| How often to put a point along the walls, in meters, so that the segments between them follow
the surface.
-}
step : Float
step =
    0.04


none : Walls
none =
    Walls []


fromShapes : Surface coordinates -> List (List ( Float, Float, Float )) -> Walls
fromShapes surface walls =
    let
        snap p =
            Surface.nearestPoint (Point3d.meters p.x p.y p.z) surface
                |> Maybe.map (.position >> Point3d.toMeters)
                |> Maybe.withDefault p

        segments points =
            List.map2 (\a b -> { a = a, b = b }) points (List.drop 1 points)
    in
    walls
        |> List.concatMap
            (\wall ->
                List.map (\( x, y, z ) -> { x = x, y = y, z = z }) wall
                    |> Shapes.alongWall step
                    |> List.map snap
                    |> segments
            )
        |> Walls


{-| Walk like `Surface.move`, but kept out of the walls. If that can't be done (squeezed between
walls), the player stays where they were.
-}
move : Surface coordinates -> Walls -> Angle.Angle -> Length.Length -> SurfacePoint -> SurfacePoint
move surface walls angle distance start =
    case Surface.move surface angle distance start of
        Just path ->
            let
                end =
                    pushOut surface walls 4 (Surface.pathEnd path)
            in
            if deepest surface walls end |> Maybe.map .depth |> Maybe.withDefault 0 |> (\depth -> depth > 1.0e-4 + (deepest surface walls start |> Maybe.map .depth |> Maybe.withDefault 0)) then
                start

            else
                end

        Nothing ->
            start


{-| Push the player out of the wall they're furthest into, a few times over for corners.
-}
pushOut : Surface coordinates -> Walls -> Int -> SurfacePoint -> SurfacePoint
pushOut surface walls tries point =
    if tries <= 0 then
        point

    else
        case ( deepest surface walls point, Surface.worldDirection surface point, Surface.normal surface point ) of
            ( Just found, Just forward_, Just normal_ ) ->
                let
                    forward =
                        Direction3d.unwrap forward_

                    up =
                        Direction3d.unwrap normal_

                    -- Counterclockwise from forward, seen from outside
                    left =
                        cross up forward

                    away =
                        let
                            v =
                                sub found.position found.closest

                            alongSurface =
                                sub v (scale (dot v up) up)
                        in
                        if dot alongSurface alongSurface > 1.0e-12 then
                            alongSurface

                        else
                            cross up (sub found.segment.b found.segment.a)
                in
                case Surface.move surface (Angle.radians (atan2 (dot away left) (dot away forward))) (Length.meters (found.depth + 1.0e-5)) point of
                    Just path ->
                        pushOut surface walls (tries - 1) (Surface.pathEnd path)

                    Nothing ->
                        point

            _ ->
                point


{-| The wall the player is furthest into, if any: how far, the closest point on its center line, and
where the player is.
-}
deepest : Surface coordinates -> Walls -> SurfacePoint -> Maybe { depth : Float, closest : Vec, position : Vec, segment : { a : Vec, b : Vec } }
deepest surface (Walls segments) point =
    case Surface.worldPosition point surface of
        Just position_ ->
            let
                position =
                    Point3d.toMeters position_
            in
            List.foldl
                (\segment best ->
                    let
                        closest =
                            closestOnSegment segment position

                        d =
                            sub position closest

                        depth =
                            clearance - sqrt (dot d d)
                    in
                    if depth > 0 && depth > (Maybe.map .depth best |> Maybe.withDefault 0) then
                        Just { depth = depth, closest = closest, position = position, segment = segment }

                    else
                        best
                )
                Nothing
                segments

        Nothing ->
            Nothing


closestOnSegment : { a : Vec, b : Vec } -> Vec -> Vec
closestOnSegment { a, b } p =
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
    { x = a.x + t * ab.x, y = a.y + t * ab.y, z = a.z + t * ab.z }


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
