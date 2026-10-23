module ShortestPath exposing (Path, between, follow)

{-| The shortest way along the surface from a point to another: a geodesic, found by aiming walks
(see `Surface.move`) until one ends at the other point.

A walk is aimed by how far it turns from the way the start point faces and how far it goes. Each try
is corrected with how its end moves when the turn and the distance change a little (Newton's method).
That finds a geodesic close to where it starts from, which isn't always the shortest (the surface has
a hole, so there are geodesics either side of it), so `between` starts from several directions and
keeps the shortest.

-}

import Angle
import Direction3d
import Length exposing (Meters)
import LineSegment3d
import Point3d exposing (Point3d)
import Surface exposing (Surface, SurfacePoint)


type alias Vec =
    { x : Float, y : Float, z : Float }


{-| A geodesic from a start point: how far it turns from the way the start point faces (counterclockwise
seen from outside, in radians), how long it is (in meters), and the points along it in 3D.
-}
type alias Path =
    { turn : Float
    , length : Float
    , points : List ( Float, Float, Float )
    }


{-| The shortest path from `start` to the point on the surface closest to `target`. Nothing when they're
too close together to tell which way it goes. A path found before (for a target close to this one)
saves time, as nothing longer than it needs looking at.
-}
between : Surface coordinates -> SurfacePoint -> Point3d Meters coordinates -> Maybe Path -> Maybe Path
between surface start target_ before =
    case ( Surface.worldPosition start surface, Surface.worldDirection surface start, Surface.normal surface start ) of
        ( Just startPosition, Just forward, Just up ) ->
            let
                from =
                    Point3d.toMeters startPosition

                target =
                    onSurface surface target_
            in
            if distance from target < minimumLength then
                Nothing

            else
                search surface start { from = from, target = target, forward = Direction3d.unwrap forward, up = Direction3d.unwrap up } before

        _ ->
            Nothing


search : Surface coordinates -> SurfacePoint -> { from : Vec, target : Vec, forward : Vec, up : Vec } -> Maybe Path -> Maybe Path
search surface start { from, target, forward, up } before =
    let
        chord =
            distance from target

        -- Straight at the target, seen from the start
        towards =
            let
                v =
                    sub target from

                along =
                    sub v (scale (dot v up) up)
            in
            atan2 (dot (cross forward along) up) (dot forward along)

        aim longest aim_ =
            aimAt surface start target longest maxTries { turn = aim_.turn, length = max minimumLength aim_.length }

        -- The shortest of what's found going straight at the target and from the path found before
        straight =
            [ aim maxLength { turn = towards, length = chord }
            , Maybe.andThen (\path -> aim maxLength { turn = path.turn, length = path.length }) before
            ]
                |> List.filterMap identity
                |> shortest

        farthest =
            case straight of
                Just path ->
                    path.length + 0.01

                Nothing ->
                    min maxLength (max (3 * chord) (chord + 2))

        -- How close each of a fan of walks comes to the target, and how far along it does
        fan =
            List.range 0 (fanRays - 1)
                |> List.map
                    (\i ->
                        let
                            turn =
                                towards + 2 * pi * toFloat i / toFloat fanRays
                        in
                        Surface.move surface (Angle.radians turn) (Length.meters farthest) start
                            |> Maybe.map (closestApproach from target >> (\closest -> { turn = turn, length = closest.along, miss = closest.miss }))
                            |> Maybe.withDefault { turn = turn, length = farthest, miss = 1 / 0 }
                    )

        -- Walks that come closer than their neighbours are near different geodesics
        aims =
            List.map3
                (\previous ray next ->
                    if ray.miss <= previous.miss && ray.miss <= next.miss then
                        Just ray

                    else
                        Nothing
                )
                (List.drop (fanRays - 1) fan ++ List.take (fanRays - 1) fan)
                fan
                (List.drop 1 fan ++ List.take 1 fan)
                |> List.filterMap identity
                -- Walks that only get further away don't lead anywhere
                |> List.filter (\ray -> ray.length > minimumLength)
    in
    aims
        -- Seeing how close they come and how far along, these won't be shorter
        |> List.filter (\ray -> ray.length - ray.miss < farthest)
        |> List.filterMap (aim farthest)
        |> (++) (List.filterMap identity [ straight ])
        |> shortest


shortest : List Path -> Maybe Path
shortest paths =
    List.foldl
        (\found best ->
            case best of
                Just shortestSoFar ->
                    if found.length < shortestSoFar.length - 1.0e-6 then
                        Just found

                    else
                        best

                Nothing ->
                    Just found
        )
        Nothing
        paths


{-| Find the geodesic near one found before, after the target has moved a little. Cheaper than
`between`, but it keeps to the same side of the hole even when the other side becomes shorter.
-}
follow : Surface coordinates -> SurfacePoint -> Point3d Meters coordinates -> Path -> Maybe Path
follow surface start target previous =
    aimAt surface start (onSurface surface target) maxLength maxTries { turn = previous.turn, length = previous.length }
        |> Maybe.andThen
            (\path ->
                if path.length > minimumLength then
                    Just path

                else
                    Nothing
            )


onSurface : Surface coordinates -> Point3d Meters coordinates -> Vec
onSurface surface point =
    Surface.nearestPoint point surface |> Maybe.map .position |> Maybe.withDefault point |> Point3d.toMeters


{-| How many walks fan out from the start in `between`.
-}
fanRays : Int
fanRays =
    24


{-| The longest path looked for, in meters. It's further than any two points on the world are apart.
-}
maxLength : Float
maxLength =
    12


{-| Points closer than this, in meters, have no path between them.
-}
minimumLength : Float
minimumLength =
    0.005


{-| A path counts as arriving when it ends this close to the target, in meters.
-}
arrivedWithin : Float
arrivedWithin =
    1.0e-4


maxTries : Int
maxTries =
    16


{-| How much the turn is changed to see how the end of a walk moves, in radians.
-}
nudge : Float
nudge =
    1.0e-4


type alias Walk coordinates =
    { aim : { turn : Float, length : Float }
    , path : Surface.Path coordinates
    , end : Vec
    , forward : Vec
    , miss : Float
    }


walk : Surface coordinates -> SurfacePoint -> Vec -> { turn : Float, length : Float } -> Maybe (Walk coordinates)
walk surface start target aim =
    Surface.move surface (Angle.radians aim.turn) (Length.meters aim.length) start
        |> Maybe.andThen
            (\path ->
                let
                    -- Facing the way the walk went
                    end =
                        Surface.pathEnd path |> Surface.rotateBy (Angle.radians aim.turn)
                in
                Maybe.map2
                    (\position forward ->
                        let
                            endVec =
                                Point3d.toMeters position
                        in
                        { aim = aim, path = path, end = endVec, forward = Direction3d.unwrap forward, miss = distance endVec target }
                    )
                    (Surface.worldPosition end surface)
                    (Surface.worldDirection surface end)
            )


{-| Correct the aim until the walk ends at the target, or give up after `tries` or once the walk is
longer than `longest`.
-}
aimAt : Surface coordinates -> SurfacePoint -> Vec -> Float -> Int -> { turn : Float, length : Float } -> Maybe Path
aimAt surface start target longest tries aim =
    walk surface start target aim |> Maybe.andThen (aimAtHelper surface start target longest tries)


aimAtHelper : Surface coordinates -> SurfacePoint -> Vec -> Float -> Int -> Walk coordinates -> Maybe Path
aimAtHelper surface start target longest tries current =
    if current.aim.length > longest then
        Nothing

    else if current.miss < arrivedWithin then
        Just
            { turn = current.aim.turn
            , length = current.aim.length
            , points =
                case Surface.pathSegments current.path of
                    (( first, _ ) :: _) as segments ->
                        Point3d.toTuple Length.inMeters (Tuple.first (lineEnds first))
                            :: List.map (\( segment, _ ) -> Point3d.toTuple Length.inMeters (Tuple.second (lineEnds segment))) segments

                    [] ->
                        []
            }

    else if tries <= 0 then
        Nothing

    else
        case walk surface start target { turn = current.aim.turn + nudge, length = current.aim.length } of
            Just nudged ->
                let
                    -- How the end moves as the length and the turn change
                    alongLength =
                        current.forward

                    alongTurn =
                        scale (1 / nudge) (sub nudged.end current.end)

                    miss =
                        sub target current.end

                    -- Least squares: miss = dLength * alongLength + dTurn * alongTurn
                    a11 =
                        dot alongLength alongLength

                    a12 =
                        dot alongLength alongTurn

                    a22 =
                        dot alongTurn alongTurn

                    b1 =
                        dot alongLength miss

                    b2 =
                        dot alongTurn miss

                    determinant =
                        a11 * a22 - a12 * a12

                    dLength =
                        (a22 * b1 - a12 * b2) / determinant

                    dTurn =
                        (a11 * b2 - a12 * b1) / determinant

                    -- Big corrections are less likely to be right, so they're cut down
                    shrink =
                        min 1 (min (maxTurnStep / abs dTurn) (maxLengthStep / abs dLength))

                    tryStep fraction triesLeft =
                        let
                            next =
                                { turn = current.aim.turn + fraction * dTurn
                                , length = max minimumLength (current.aim.length + fraction * dLength)
                                }
                        in
                        case walk surface start target next of
                            Just better ->
                                if better.miss < current.miss || triesLeft <= 0 then
                                    Just better

                                else
                                    tryStep (fraction / 2) (triesLeft - 1)

                            Nothing ->
                                Nothing
                in
                if determinant < 1.0e-12 then
                    Nothing

                else
                    tryStep shrink 4 |> Maybe.andThen (aimAtHelper surface start target longest (tries - 1))

            Nothing ->
                Nothing


maxTurnStep : Float
maxTurnStep =
    0.5


maxLengthStep : Float
maxLengthStep =
    1


{-| The point of a walk closest to the target: how far it is from it, and how far along the walk.
-}
closestApproach : Vec -> Vec -> Surface.Path coordinates -> { miss : Float, along : Float }
closestApproach from target path =
    Surface.pathSegments path
        |> List.foldl
            (\( segment, _ ) ( walked, best ) ->
                let
                    ( a, b ) =
                        lineEnds segment |> Tuple.mapBoth Point3d.toMeters Point3d.toMeters

                    ab =
                        sub b a

                    length =
                        sqrt (dot ab ab)

                    t =
                        if length > 0 then
                            clamp 0 1 (dot (sub target a) ab / (length * length))

                        else
                            0

                    miss =
                        distance target (add a (scale t ab))
                in
                ( walked + length
                , if miss < best.miss then
                    { miss = miss, along = walked + t * length }

                  else
                    best
                )
            )
            ( 0, { miss = distance from target, along = 0 } )
        |> Tuple.second


lineEnds segment =
    ( LineSegment3d.startPoint segment, LineSegment3d.endPoint segment )


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


distance : Vec -> Vec -> Float
distance a b =
    sqrt (dot (sub a b) (sub a b))
