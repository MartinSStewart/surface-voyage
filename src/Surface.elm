module Surface exposing
    ( Surface, build, Error(..), errorToString
    , FlatSpec, FlatEdge(..), FeatureSpec, ProfileSegment(..), Sweep(..)
    , FlatCoordinate, FeatureCoordinate, ProfileCoordinate
    , SurfacePoint, nearestSurfacePoint, nearestPoint, worldPosition, normal, worldDirection, pointTowards, rotateBy
    , Path, move, pathEnd, pathSegments
    , pieceCount
    , Complex, Mobius, Placement, Window, flattenAround, chartCoordinate, nearestPiece, placeOnMap
    )

{-| A closed surface made of flat regions and features.

A flat region is a polygon on a plane whose edges are straight lines or circular arcs.

A feature is a surface of revolution: a profile made of lines and circular arcs, drawn in the
(rho, z) half-plane (rho = distance from the axis), spun around the z axis of a frame, either all the
way round or part way.

Pieces are joined along their edges. `build` finds which edges meet by comparing their geometry, so
the pieces only need to be positioned correctly.

Conventions:

  - A flat's sketch plane normal (x cross y) points out of the solid. Its boundary loops keep the
    region on their left: the outer loop goes counterclockwise, holes go clockwise.
  - A feature's profile is walked so that the outside of the solid is on its right in the
    (rho, z) half-plane. For example a fillet whose profile goes up the z axis at a fixed rho faces
    away from the axis.

@docs Surface, build, Error, errorToString
@docs FlatSpec, FlatEdge, FeatureSpec, ProfileSegment, Sweep
@docs FlatCoordinate, FeatureCoordinate, ProfileCoordinate
@docs SurfacePoint, nearestSurfacePoint, nearestPoint, worldPosition, normal, worldDirection, pointTowards, rotateBy
@docs Path, move, pathEnd, pathSegments
@docs pieceCount
@docs Complex, Mobius, Placement, Window, flattenAround, chartCoordinate, nearestPiece, placeOnMap

-}

import Angle exposing (Angle)
import Array exposing (Array)
import Direction3d exposing (Direction3d)
import Frame3d exposing (Frame3d)
import Length exposing (Length, Meters)
import LineSegment3d exposing (LineSegment3d)
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import SketchPlane3d exposing (SketchPlane3d)



---- AUTHORING TYPES ----


type FlatCoordinate
    = FlatCoordinate Never


type FeatureCoordinate
    = FeatureCoordinate Never


type ProfileCoordinate
    = ProfileCoordinate Never


type alias FlatSpec coordinates =
    { plane : SketchPlane3d Meters coordinates { defines : FlatCoordinate }
    , boundary : List (List FlatEdge)
    }


{-| `Straight start` runs from `start` to the start of the next edge in the loop. `Arc` runs from
`start` around `center` by `sweptAngle` (positive is counterclockwise). A loop that is a single
full circle is one `Arc` with a swept angle of plus or minus 360 degrees.
-}
type FlatEdge
    = Straight (Point2d Meters FlatCoordinate)
    | Arc { start : Point2d Meters FlatCoordinate, center : Point2d Meters FlatCoordinate, sweptAngle : Angle }


type alias FeatureSpec coordinates =
    { frame : Frame3d Meters coordinates { defines : FeatureCoordinate }
    , profile : { start : Point2d Meters ProfileCoordinate, segments : List ProfileSegment }
    , sweep : Sweep
    }


{-| A `Circle` goes the short way round `center` from the previous point to `end`.
-}
type ProfileSegment
    = Line { end : Point2d Meters ProfileCoordinate }
    | Circle { end : Point2d Meters ProfileCoordinate, center : Point2d Meters ProfileCoordinate }


type Sweep
    = FullTurn
    | PartTurn { from : Angle, to : Angle }



---- INTERNAL TYPES ----


type alias Vec =
    { x : Float, y : Float, z : Float }


type Surface coordinates
    = Surface
        { pieces : Array Piece

        -- For each piece, for each of its edges, the piece and edge on the other side
        , seams : Array (Array (Maybe ( Int, Int )))
        }


type Piece
    = FlatPiece Flat
    | FeaturePiece Feature


type alias Flat =
    { origin : Vec
    , u : Vec
    , v : Vec
    , n : Vec
    , edges : Array Edge2d
    }


type Edge2d
    = SegmentEdge { ax : Float, ay : Float, bx : Float, by : Float }
    | ArcEdge { cx : Float, cy : Float, r : Float, a0 : Float, swept : Float }


type alias Feature =
    { origin : Vec
    , ex : Vec
    , ey : Vec
    , ez : Vec
    , segments : List ProfileSeg
    , length : Float

    -- Nothing means a full turn
    , sweep : Maybe { from : Float, to : Float }

    -- +1 or -1: whether n cross e_s points along e_theta or against it
    , chirality : Float
    }


{-| A profile segment parameterised by arc length `s`, starting at `s0`.
-}
type ProfileSeg
    = LineSeg { s0 : Float, len : Float, r0 : Float, h0 : Float, dr : Float, dh : Float }
    | ArcSeg { s0 : Float, len : Float, cr : Float, ch : Float, radius : Float, a0 : Float, dir : Float }


{-| On a flat, (a, b) are the coordinates in its sketch plane. On a feature, a is the angle around
the axis and b is the arc length along the profile. The heading is measured counterclockwise
(seen from outside) from the first tangent direction (the sketch plane's x axis on a flat, the
direction of increasing arc length on a feature).
-}
type SurfacePoint
    = SurfacePoint SurfacePoint_


type alias SurfacePoint_ =
    { piece : Int, a : Float, b : Float, heading : Float }


type Path coordinates
    = Path
        { end : SurfacePoint
        , segments : List ( LineSegment3d Meters coordinates, Direction3d coordinates )
        }


type Error
    = UnmatchedEdge String
    | EdgeSharedBy3OrMorePieces String
    | DegenerateFlatEdge
    | DegenerateProfile


errorToString : Error -> String
errorToString error =
    case error of
        UnmatchedEdge description ->
            "No piece meets " ++ description

        EdgeSharedBy3OrMorePieces description ->
            "More than one piece meets " ++ description

        DegenerateFlatEdge ->
            "A flat has a zero length edge"

        DegenerateProfile ->
            "A feature profile has a zero length segment"



---- VECTOR HELPERS ----


vec : Float -> Float -> Float -> Vec
vec x y z =
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
    if l - 0 == 0 then
        a

    else
        scale (1 / l) a


{-| a \* p + b \* q
-}
combine : Float -> Vec -> Float -> Vec -> Vec
combine a p b q =
    { x = a * p.x + b * q.x, y = a * p.y + b * q.y, z = a * p.z + b * q.z }


fromPoint : Point3d Meters coordinates -> Vec
fromPoint point =
    Point3d.toMeters point


toPoint : Vec -> Point3d Meters coordinates
toPoint v =
    Point3d.fromMeters v


fromDirection : Direction3d coordinates -> Vec
fromDirection direction =
    Direction3d.unwrap direction


toDirection : Vec -> Direction3d coordinates
toDirection v =
    Direction3d.unsafe v


{-| Angle wrapped into [0, 2pi).
-}
wrapAngle : Float -> Float
wrapAngle angle =
    let
        turns =
            toFloat (floor (angle / (2 * pi)))
    in
    angle - turns * 2 * pi


tolerance : Float
tolerance =
    1.0e-4



---- BUILDING ----


build : List (FlatSpec coordinates) -> List (FeatureSpec coordinates) -> Result Error (Surface coordinates)
build flatSpecs featureSpecs =
    case ( combineResults (List.map buildFlat flatSpecs), combineResults (List.map buildFeature featureSpecs) ) of
        ( Ok flats, Ok features ) ->
            let
                pieces =
                    List.map FlatPiece flats ++ List.map FeaturePiece features |> Array.fromList
            in
            findSeams pieces |> Result.map (\seams -> Surface { pieces = pieces, seams = seams })

        ( Err error, _ ) ->
            Err error

        ( _, Err error ) ->
            Err error


combineResults : List (Result e a) -> Result e (List a)
combineResults results =
    List.foldr (\result acc -> Result.map2 (::) result acc) (Ok []) results


buildFlat : FlatSpec coordinates -> Result Error Flat
buildFlat spec =
    let
        origin =
            SketchPlane3d.originPoint spec.plane |> fromPoint

        u =
            SketchPlane3d.xDirection spec.plane |> fromDirection

        v =
            SketchPlane3d.yDirection spec.plane |> fromDirection

        edges =
            List.concatMap buildLoop spec.boundary
    in
    if List.any edgeIsDegenerate edges then
        Err DegenerateFlatEdge

    else
        Ok { origin = origin, u = u, v = v, n = cross u v, edges = Array.fromList edges }


buildLoop : List FlatEdge -> List Edge2d
buildLoop loop =
    let
        startOf edge =
            case edge of
                Straight start ->
                    start

                Arc { start } ->
                    start

        nextStarts =
            List.drop 1 loop ++ List.take 1 loop |> List.map startOf
    in
    List.map2
        (\edge next ->
            case edge of
                Straight start ->
                    let
                        a =
                            Point2d.toMeters start

                        b =
                            Point2d.toMeters next
                    in
                    SegmentEdge { ax = a.x, ay = a.y, bx = b.x, by = b.y }

                Arc { start, center, sweptAngle } ->
                    let
                        s =
                            Point2d.toMeters start

                        c =
                            Point2d.toMeters center
                    in
                    ArcEdge
                        { cx = c.x
                        , cy = c.y
                        , r = sqrt ((s.x - c.x) ^ 2 + (s.y - c.y) ^ 2)
                        , a0 = atan2 (s.y - c.y) (s.x - c.x)
                        , swept = Angle.inRadians sweptAngle
                        }
        )
        loop
        nextStarts


edgeIsDegenerate : Edge2d -> Bool
edgeIsDegenerate edge =
    case edge of
        SegmentEdge { ax, ay, bx, by } ->
            sqrt ((bx - ax) ^ 2 + (by - ay) ^ 2) < tolerance

        ArcEdge { r, swept } ->
            abs (r * swept) < tolerance


buildFeature : FeatureSpec coordinates -> Result Error Feature
buildFeature spec =
    let
        ex =
            Frame3d.xDirection spec.frame |> fromDirection

        ey =
            Frame3d.yDirection spec.frame |> fromDirection

        ez =
            Frame3d.zDirection spec.frame |> fromDirection

        start =
            Point2d.toMeters spec.profile.start

        ( segments, length ) =
            List.foldl
                (\segment ( acc, s0, point ) ->
                    case segment of
                        Line { end } ->
                            let
                                e =
                                    Point2d.toMeters end

                                len =
                                    sqrt ((e.x - point.x) ^ 2 + (e.y - point.y) ^ 2)
                            in
                            ( LineSeg
                                { s0 = s0
                                , len = len
                                , r0 = point.x
                                , h0 = point.y
                                , dr = (e.x - point.x) / len
                                , dh = (e.y - point.y) / len
                                }
                                :: acc
                            , s0 + len
                            , e
                            )

                        Circle { end, center } ->
                            let
                                e =
                                    Point2d.toMeters end

                                c =
                                    Point2d.toMeters center

                                radius =
                                    sqrt ((point.x - c.x) ^ 2 + (point.y - c.y) ^ 2)

                                a0 =
                                    atan2 (point.y - c.y) (point.x - c.x)

                                a1 =
                                    atan2 (e.y - c.y) (e.x - c.x)

                                -- The short way round, in [-pi, pi)
                                delta =
                                    wrapAngle (a1 - a0 + pi) - pi

                                len =
                                    abs delta * radius
                            in
                            ( ArcSeg
                                { s0 = s0
                                , len = len
                                , cr = c.x
                                , ch = c.y
                                , radius = radius
                                , a0 = a0
                                , dir =
                                    if delta < 0 then
                                        -1

                                    else
                                        1
                                }
                                :: acc
                            , s0 + len
                            , e
                            )
                )
                ( [], 0, start )
                spec.profile.segments
                |> (\( acc, total, _ ) -> ( List.reverse acc, total ))

        feature =
            { origin = Frame3d.originPoint spec.frame |> fromPoint
            , ex = ex
            , ey = ey
            , ez = ez
            , segments = segments
            , length = length
            , sweep =
                case spec.sweep of
                    FullTurn ->
                        Nothing

                    PartTurn { from, to } ->
                        Just { from = Angle.inRadians from, to = Angle.inRadians to }
            , chirality = 1
            }

        -- Measure the chirality halfway along the profile
        basis =
            featureBasis feature (sweepStart feature) (length / 2)
    in
    if List.isEmpty segments || List.any (\segment -> segLength segment < tolerance) segments then
        Err DegenerateProfile

    else
        Ok
            { feature
                | chirality =
                    if dot (cross basis.n basis.es) basis.etheta < 0 then
                        -1

                    else
                        1
            }


segLength : ProfileSeg -> Float
segLength segment =
    case segment of
        LineSeg { len } ->
            len

        ArcSeg { len } ->
            len


sweepStart : Feature -> Float
sweepStart feature =
    case feature.sweep of
        Just { from } ->
            from

        Nothing ->
            0


{-| Number of edges a piece has. Flats: one per boundary edge. Features: profile start, profile end,
sweep start, sweep end (the last two only for a part turn).
-}
edgeCount : Piece -> Int
edgeCount piece =
    case piece of
        FlatPiece flat ->
            Array.length flat.edges

        FeaturePiece feature ->
            case feature.sweep of
                Just _ ->
                    4

                Nothing ->
                    2


{-| A point on an edge, t from 0 to 1. Nothing for an edge that has shrunk to a point (a profile
that starts or ends on the axis).
-}
edgeSample : Piece -> Int -> Float -> Maybe Vec
edgeSample piece edgeIndex t =
    case piece of
        FlatPiece flat ->
            case Array.get edgeIndex flat.edges of
                Just (SegmentEdge { ax, ay, bx, by }) ->
                    flatPoint flat (ax + t * (bx - ax)) (ay + t * (by - ay)) |> Just

                Just (ArcEdge { cx, cy, r, a0, swept }) ->
                    let
                        angle =
                            a0 + t * swept
                    in
                    flatPoint flat (cx + r * cos angle) (cy + r * sin angle) |> Just

                Nothing ->
                    Nothing

        FeaturePiece feature ->
            let
                ( from, to ) =
                    sweepRange feature
            in
            case edgeIndex of
                0 ->
                    if abs (profileAt feature 0).r < tolerance then
                        Nothing

                    else
                        featurePoint feature (from + t * (to - from)) 0 |> Just

                1 ->
                    if abs (profileAt feature feature.length).r < tolerance then
                        Nothing

                    else
                        featurePoint feature (from + t * (to - from)) feature.length |> Just

                2 ->
                    featurePoint feature from (t * feature.length) |> Just

                3 ->
                    featurePoint feature to (t * feature.length) |> Just

                _ ->
                    Nothing


sweepRange : Feature -> ( Float, Float )
sweepRange feature =
    case feature.sweep of
        Just { from, to } ->
            ( from, to )

        Nothing ->
            ( 0, 2 * pi )


findSeams : Array Piece -> Result Error (Array (Array (Maybe ( Int, Int ))))
findSeams pieces =
    let
        allEdges : List ( Int, Int )
        allEdges =
            Array.toIndexedList pieces
                |> List.concatMap (\( index, piece ) -> List.range 0 (edgeCount piece - 1) |> List.map (Tuple.pair index))

        samples ( pieceIndex, edgeIndex ) =
            case Array.get pieceIndex pieces of
                Just piece ->
                    [ 0, 0.25, 0.5, 0.75, 1 ] |> List.map (edgeSample piece edgeIndex) |> combineMaybes

                Nothing ->
                    Nothing

        edgeSamples : List ( ( Int, Int ), List Vec )
        edgeSamples =
            List.filterMap (\edge -> samples edge |> Maybe.map (Tuple.pair edge)) allEdges

        liesOn ( pieceIndex, edgeIndex ) points =
            case Array.get pieceIndex pieces of
                Just piece ->
                    List.all
                        (\point ->
                            let
                                located =
                                    locateOnEdge piece edgeIndex point
                            in
                            lengthOf (sub (piecePoint piece located.a located.b) point) < tolerance
                        )
                        points

                Nothing ->
                    False

        matchesFor ( edge, points ) =
            List.filter
                (\( otherEdge, otherPoints ) ->
                    Tuple.first otherEdge /= Tuple.first edge && liesOn otherEdge points && liesOn edge otherPoints
                )
                edgeSamples
                |> List.map Tuple.first

        describe ( pieceIndex, edgeIndex ) =
            "edge " ++ String.fromInt edgeIndex ++ " of piece " ++ String.fromInt pieceIndex
    in
    List.foldl
        (\(( edge, _ ) as edgeAndSamples) result ->
            case result of
                Ok seams ->
                    case matchesFor edgeAndSamples of
                        [ other ] ->
                            Ok (setSeam edge other seams)

                        [] ->
                            Err (UnmatchedEdge (describe edge))

                        _ ->
                            Err (EdgeSharedBy3OrMorePieces (describe edge))

                Err _ ->
                    result
        )
        (Ok (Array.map (\piece -> Array.repeat (edgeCount piece) Nothing) pieces))
        edgeSamples


setSeam : ( Int, Int ) -> ( Int, Int ) -> Array (Array (Maybe ( Int, Int ))) -> Array (Array (Maybe ( Int, Int )))
setSeam ( pieceIndex, edgeIndex ) other seams =
    case Array.get pieceIndex seams of
        Just edges ->
            Array.set pieceIndex (Array.set edgeIndex (Just other) edges) seams

        Nothing ->
            seams


combineMaybes : List (Maybe a) -> Maybe (List a)
combineMaybes maybes =
    List.foldr (\maybe acc -> Maybe.map2 (::) maybe acc) (Just []) maybes


pieceCount : Surface coordinates -> Int
pieceCount (Surface surface) =
    Array.length surface.pieces



---- GEOMETRY OF A PIECE ----


flatPoint : Flat -> Float -> Float -> Vec
flatPoint flat a b =
    add flat.origin (combine a flat.u b flat.v)


{-| Position and unit tangent of the profile at arc length s (clamped to the profile).
-}
profileAt : Feature -> Float -> { r : Float, h : Float, dr : Float, dh : Float }
profileAt feature s =
    profileAtHelper feature.segments s


profileAtHelper : List ProfileSeg -> Float -> { r : Float, h : Float, dr : Float, dh : Float }
profileAtHelper segments s =
    case segments of
        [] ->
            { r = 0, h = 0, dr = 0, dh = 1 }

        [ last ] ->
            segmentAt last s

        first :: rest ->
            if s < segS0 first + segLength first then
                segmentAt first s

            else
                profileAtHelper rest s


segS0 : ProfileSeg -> Float
segS0 segment =
    case segment of
        LineSeg { s0 } ->
            s0

        ArcSeg { s0 } ->
            s0


segmentAt : ProfileSeg -> Float -> { r : Float, h : Float, dr : Float, dh : Float }
segmentAt segment s =
    case segment of
        LineSeg { s0, len, r0, h0, dr, dh } ->
            let
                t =
                    clamp 0 len (s - s0)
            in
            { r = r0 + t * dr, h = h0 + t * dh, dr = dr, dh = dh }

        ArcSeg { s0, len, cr, ch, radius, a0, dir } ->
            let
                angle =
                    a0 + dir * clamp 0 len (s - s0) / radius
            in
            { r = cr + radius * cos angle
            , h = ch + radius * sin angle
            , dr = -dir * sin angle
            , dh = dir * cos angle
            }


featurePoint : Feature -> Float -> Float -> Vec
featurePoint feature theta s =
    let
        p =
            profileAt feature s

        radial =
            combine (cos theta) feature.ex (sin theta) feature.ey
    in
    add feature.origin (combine p.r radial p.h feature.ez)


type alias Basis =
    { p : Vec, es : Vec, etheta : Vec, n : Vec }


featureBasis : Feature -> Float -> Float -> Basis
featureBasis feature theta s =
    let
        p =
            profileAt feature s

        radial =
            combine (cos theta) feature.ex (sin theta) feature.ey
    in
    { p = add feature.origin (combine p.r radial p.h feature.ez)
    , es = combine p.dr radial p.dh feature.ez
    , etheta = combine -(sin theta) feature.ex (cos theta) feature.ey

    -- The profile tangent turned clockwise in the (rho, z) half-plane
    , n = combine p.dh radial -p.dr feature.ez
    }


piecePoint : Piece -> Float -> Float -> Vec
piecePoint piece a b =
    case piece of
        FlatPiece flat ->
            flatPoint flat a b

        FeaturePiece feature ->
            featurePoint feature a b


{-| Position, two unit tangents and the outward normal, with du cross dv = n.
-}
type alias TangentFrame =
    { p : Vec, du : Vec, dv : Vec, n : Vec }


tangentFrame : Piece -> Float -> Float -> TangentFrame
tangentFrame piece a b =
    case piece of
        FlatPiece flat ->
            { p = flatPoint flat a b, du = flat.u, dv = flat.v, n = flat.n }

        FeaturePiece feature ->
            let
                basis =
                    featureBasis feature a b
            in
            { p = basis.p, du = basis.es, dv = scale feature.chirality basis.etheta, n = basis.n }


headingToVec : TangentFrame -> Float -> Vec
headingToVec frame heading =
    combine (cos heading) frame.du (sin heading) frame.dv


vecToHeading : TangentFrame -> Vec -> Float
vecToHeading frame direction =
    atan2 (dot direction frame.dv) (dot direction frame.du)



---- PROJECTION ----


{-| The closest profile point to (r, h): its arc length and squared distance.
-}
closestOnProfile : Feature -> Float -> Float -> Float
closestOnProfile feature r h =
    List.foldl
        (\segment ( bestS, bestDistance ) ->
            let
                s =
                    closestOnSegment segment r h

                p =
                    segmentAt segment s

                distance =
                    (p.r - r) ^ 2 + (p.h - h) ^ 2
            in
            if distance < bestDistance then
                ( s, distance )

            else
                ( bestS, bestDistance )
        )
        ( 0, 1 / 0 )
        feature.segments
        |> Tuple.first


closestOnSegment : ProfileSeg -> Float -> Float -> Float
closestOnSegment segment r h =
    case segment of
        LineSeg { s0, len, r0, h0, dr, dh } ->
            s0 + clamp 0 len ((r - r0) * dr + (h - h0) * dh)

        ArcSeg { s0, len, cr, ch, radius, a0, dir } ->
            let
                swept =
                    len / radius

                -- Angle from the arc start in the arc's direction, in [0, 2pi)
                relative =
                    wrapAngle (dir * (atan2 (h - ch) (r - cr) - a0))
            in
            if relative <= swept then
                s0 + relative * radius

            else if relative - swept < 2 * pi - relative then
                s0 + len

            else
                s0


{-| Angle of a point around a feature's axis, kept inside the sweep.
-}
clampTheta : Feature -> Float -> Float
clampTheta feature theta =
    case feature.sweep of
        Just { from, to } ->
            let
                relative =
                    wrapAngle (theta - from)
            in
            if relative <= to - from then
                from + relative

            else if relative - (to - from) < 2 * pi - relative then
                to

            else
                from

        Nothing ->
            wrapAngle theta


insideSweep : Feature -> Float -> Bool
insideSweep feature theta =
    case feature.sweep of
        Just { from, to } ->
            wrapAngle (theta - from) <= to - from + 1.0e-9

        Nothing ->
            True


projectOntoFeature : Feature -> Vec -> ( Float, Float )
projectOntoFeature feature point =
    let
        local =
            sub point feature.origin

        x =
            dot local feature.ex

        y =
            dot local feature.ey

        theta =
            clampTheta feature (atan2 y x)

        r =
            x * cos theta + y * sin theta
    in
    ( theta, closestOnProfile feature r (dot local feature.ez) )


projectOntoFlat : Flat -> Vec -> ( Float, Float )
projectOntoFlat flat point =
    let
        local =
            sub point flat.origin

        a =
            dot local flat.u

        b =
            dot local flat.v
    in
    if insideFlat flat a b then
        ( a, b )

    else
        Array.foldl
            (\edge ( best, bestDistance ) ->
                let
                    ( ca, cb ) =
                        closestOnEdge2d edge a b

                    distance =
                        (ca - a) ^ 2 + (cb - b) ^ 2
                in
                if distance < bestDistance then
                    ( ( ca, cb ), distance )

                else
                    ( best, bestDistance )
            )
            ( ( a, b ), 1 / 0 )
            flat.edges
            |> Tuple.first


closestOnEdge2d : Edge2d -> Float -> Float -> ( Float, Float )
closestOnEdge2d edge a b =
    case edge of
        SegmentEdge { ax, ay, bx, by } ->
            let
                dx =
                    bx - ax

                dy =
                    by - ay

                t =
                    clamp 0 1 (((a - ax) * dx + (b - ay) * dy) / (dx * dx + dy * dy))
            in
            ( ax + t * dx, ay + t * dy )

        ArcEdge { cx, cy, r, a0, swept } ->
            let
                angle =
                    arcClampAngle a0 swept (atan2 (b - cy) (a - cx))
            in
            ( cx + r * cos angle, cy + r * sin angle )


{-| The angle on the arc closest to `angle`.
-}
arcClampAngle : Float -> Float -> Float -> Float
arcClampAngle a0 swept angle =
    let
        dir =
            if swept < 0 then
                -1

            else
                1

        relative =
            wrapAngle (dir * (angle - a0))
    in
    if relative <= abs swept then
        a0 + dir * relative

    else if relative - abs swept < 2 * pi - relative then
        a0 + swept

    else
        a0


{-| Even-odd test with a ray along +a.
-}
insideFlat : Flat -> Float -> Float -> Bool
insideFlat flat a b =
    Array.foldl (\edge count -> count + rayCrossings edge a b) 0 flat.edges
        |> modBy 2
        |> (==) 1


rayCrossings : Edge2d -> Float -> Float -> Int
rayCrossings edge a b =
    case edge of
        SegmentEdge { ax, ay, bx, by } ->
            if (ay > b) /= (by > b) && a < ax + (b - ay) / (by - ay) * (bx - ax) then
                1

            else
                0

        ArcEdge { cx, cy, r, a0, swept } ->
            let
                dy =
                    b - cy
            in
            if abs dy >= r then
                0

            else
                let
                    dx =
                        sqrt (r * r - dy * dy)

                    count x =
                        if x > a && onArc a0 swept (atan2 dy (x - cx)) then
                            1

                        else
                            0
                in
                count (cx + dx) + count (cx - dx)


onArc : Float -> Float -> Float -> Bool
onArc a0 swept angle =
    let
        dir =
            if swept < 0 then
                -1

            else
                1
    in
    wrapAngle (dir * (angle - a0)) <= abs swept + 1.0e-9


projectOntoPiece : Piece -> Vec -> ( Float, Float )
projectOntoPiece piece point =
    case piece of
        FlatPiece flat ->
            projectOntoFlat flat point

        FeaturePiece feature ->
            projectOntoFeature feature point


{-| Local coordinates of the point on an edge closest to `point`.
-}
locateOnEdge : Piece -> Int -> Vec -> { a : Float, b : Float }
locateOnEdge piece edgeIndex point =
    case piece of
        FlatPiece flat ->
            let
                local =
                    sub point flat.origin
            in
            case Array.get edgeIndex flat.edges of
                Just edge ->
                    let
                        ( a, b ) =
                            closestOnEdge2d edge (dot local flat.u) (dot local flat.v)
                    in
                    { a = a, b = b }

                Nothing ->
                    { a = 0, b = 0 }

        FeaturePiece feature ->
            let
                local =
                    sub point feature.origin

                x =
                    dot local feature.ex

                y =
                    dot local feature.ey

                ( from, to ) =
                    sweepRange feature

                profileParam theta =
                    closestOnProfile feature (x * cos theta + y * sin theta) (dot local feature.ez)
            in
            case edgeIndex of
                0 ->
                    { a = clampTheta feature (atan2 y x), b = 0 }

                1 ->
                    { a = clampTheta feature (atan2 y x), b = feature.length }

                2 ->
                    { a = from, b = profileParam from }

                _ ->
                    { a = to, b = profileParam to }


{-| Unit tangent along an edge and the unit direction pointing from the edge into the piece, at
local coordinates (a, b) on that edge.
-}
edgeFrame : Piece -> Int -> Float -> Float -> { tangent : Vec, inward : Vec }
edgeFrame piece edgeIndex a b =
    case piece of
        FlatPiece flat ->
            let
                ( tx, ty ) =
                    case Array.get edgeIndex flat.edges of
                        Just edge ->
                            edgeTangent2d edge a b

                        Nothing ->
                            ( 1, 0 )

                tangent =
                    combine tx flat.u ty flat.v
            in
            -- Interior is on the left of the edge
            { tangent = tangent, inward = cross flat.n tangent }

        FeaturePiece feature ->
            let
                basis =
                    featureBasis feature a b
            in
            case edgeIndex of
                0 ->
                    { tangent = basis.etheta, inward = basis.es }

                1 ->
                    { tangent = basis.etheta, inward = scale -1 basis.es }

                2 ->
                    { tangent = basis.es, inward = basis.etheta }

                _ ->
                    { tangent = basis.es, inward = scale -1 basis.etheta }


edgeTangent2d : Edge2d -> Float -> Float -> ( Float, Float )
edgeTangent2d edge a b =
    case edge of
        SegmentEdge { ax, ay, bx, by } ->
            let
                l =
                    sqrt ((bx - ax) ^ 2 + (by - ay) ^ 2)
            in
            ( (bx - ax) / l, (by - ay) / l )

        ArcEdge { cx, cy, swept } ->
            let
                angle =
                    atan2 (b - cy) (a - cx)

                dir =
                    if swept < 0 then
                        -1

                    else
                        1
            in
            ( -dir * sin angle, dir * cos angle )



---- QUERIES ----


getPiece : Int -> Surface coordinates -> Maybe Piece
getPiece index (Surface surface) =
    Array.get index surface.pieces


nearest : Point3d Meters coordinates -> Surface coordinates -> Maybe { piece : Int, a : Float, b : Float, position : Vec }
nearest point (Surface surface) =
    let
        p =
            fromPoint point
    in
    Array.foldl
        (\piece ( index, best ) ->
            let
                ( a, b ) =
                    projectOntoPiece piece p

                position =
                    piecePoint piece a b

                distance =
                    lengthOf (sub position p)
            in
            ( index + 1
            , case best of
                Just ( _, bestDistance ) ->
                    if distance < bestDistance then
                        Just ( { piece = index, a = a, b = b, position = position }, distance )

                    else
                        best

                Nothing ->
                    Just ( { piece = index, a = a, b = b, position = position }, distance )
            )
        )
        ( 0, Nothing )
        surface.pieces
        |> Tuple.second
        |> Maybe.map Tuple.first


{-| The surface point closest to a point in space, facing along the first tangent direction.
-}
nearestExcluding : Int -> Vec -> Array Piece -> Maybe { piece : Int, a : Float, b : Float }
nearestExcluding excluded p pieces =
    Array.foldl
        (\piece ( index, best ) ->
            if index == excluded then
                ( index + 1, best )

            else
                let
                    ( a, b ) =
                        projectOntoPiece piece p

                    distance =
                        lengthOf (sub (piecePoint piece a b) p)
                in
                ( index + 1
                , case best of
                    Just ( _, bestDistance ) ->
                        if distance < bestDistance then
                            Just ( { piece = index, a = a, b = b }, distance )

                        else
                            best

                    Nothing ->
                        Just ( { piece = index, a = a, b = b }, distance )
                )
        )
        ( 0, Nothing )
        pieces
        |> Tuple.second
        |> Maybe.map Tuple.first


nearestSurfacePoint : Point3d Meters coordinates -> Surface coordinates -> Maybe SurfacePoint
nearestSurfacePoint point surface =
    nearest point surface |> Maybe.map (\{ piece, a, b } -> SurfacePoint { piece = piece, a = a, b = b, heading = 0 })


{-| The closest point on the surface and the surface normal there.
-}
nearestPoint : Point3d Meters coordinates -> Surface coordinates -> Maybe { position : Point3d Meters coordinates, normal : Direction3d coordinates }
nearestPoint point surface =
    nearest point surface
        |> Maybe.andThen
            (\{ piece, a, b } ->
                getPiece piece surface
                    |> Maybe.map
                        (\piece_ ->
                            let
                                frame =
                                    tangentFrame piece_ a b
                            in
                            { position = toPoint frame.p, normal = toDirection frame.n }
                        )
            )


withFrame : (TangentFrame -> a) -> SurfacePoint -> Surface coordinates -> Maybe a
withFrame func (SurfacePoint point) surface =
    getPiece point.piece surface |> Maybe.map (\piece -> tangentFrame piece point.a point.b |> func)


worldPosition : SurfacePoint -> Surface coordinates -> Maybe (Point3d Meters coordinates)
worldPosition =
    withFrame (.p >> toPoint)


normal : Surface coordinates -> SurfacePoint -> Maybe (Direction3d coordinates)
normal surface point =
    withFrame (.n >> toDirection) point surface


worldDirection : Surface coordinates -> SurfacePoint -> Maybe (Direction3d coordinates)
worldDirection surface ((SurfacePoint { heading }) as point) =
    withFrame (\frame -> headingToVec frame heading |> toDirection) point surface


rotateBy : Angle -> SurfacePoint -> SurfacePoint
rotateBy angle (SurfacePoint point) =
    SurfacePoint { point | heading = point.heading + Angle.inRadians angle }


{-| Turn to face a point in space (projected onto the tangent plane).
-}
pointTowards : Point3d Meters coordinates -> Surface coordinates -> SurfacePoint -> SurfacePoint
pointTowards target surface ((SurfacePoint point) as surfacePoint) =
    case withFrame identity surfacePoint surface of
        Just frame ->
            let
                offset =
                    sub (fromPoint target) frame.p

                along =
                    sub offset (scale (dot offset frame.n) frame.n)
            in
            if lengthOf along < 1.0e-12 then
                surfacePoint

            else
                SurfacePoint { point | heading = vecToHeading frame along }

        Nothing ->
            surfacePoint



---- WALKING ----


pathEnd : Path coordinates -> SurfacePoint
pathEnd (Path path) =
    path.end


{-| The straight pieces of a path in 3D with the surface normal at their start, from the start of the
path to its end.
-}
pathSegments : Path coordinates -> List ( LineSegment3d Meters coordinates, Direction3d coordinates )
pathSegments (Path path) =
    List.reverse path.segments


{-| Walk along a geodesic, turned by `rotationOffset` from the current heading. The heading at the end
of the path is updated as the walker turns with the surface, but does not include `rotationOffset`.
Stops early at an edge with nothing on the other side.
-}
move : Surface coordinates -> Angle -> Length -> SurfacePoint -> Maybe (Path coordinates)
move surface rotationOffset distance (SurfacePoint point) =
    case getPiece point.piece surface of
        Just _ ->
            let
                offset =
                    Angle.inRadians rotationOffset

                ( end, segments ) =
                    walk surface 0 { point | heading = point.heading + offset } (Length.inMeters distance) []
            in
            Path { end = SurfacePoint { end | heading = end.heading - offset }, segments = segments } |> Just

        Nothing ->
            Nothing


maxSeamCrossings : Int
maxSeamCrossings =
    200


type alias Segments coordinates =
    List ( LineSegment3d Meters coordinates, Direction3d coordinates )


type Exit
    = Arrived SurfacePoint_
    | LeftThrough Int SurfacePoint_ Float
      -- Left through a corner point, onto whichever piece the direction points into
    | LeftThroughPoint Vec Vec Float


walk : Surface coordinates -> Int -> SurfacePoint_ -> Float -> Segments coordinates -> ( SurfacePoint_, Segments coordinates )
walk ((Surface surface) as surface_) crossings point remaining segments =
    case Array.get point.piece surface.pieces of
        Just piece ->
            let
                ( exit, newSegments ) =
                    case piece of
                        FlatPiece flat ->
                            walkFlat flat point remaining segments

                        FeaturePiece feature ->
                            walkFeature feature point remaining segments
            in
            case exit of
                Arrived end ->
                    ( end, newSegments )

                LeftThroughPoint position direction remaining_ ->
                    case
                        ( nearestExcluding point.piece (add position (scale 1.0e-7 direction)) surface.pieces
                        , crossings < maxSeamCrossings
                        )
                    of
                        ( Just next, True ) ->
                            case Array.get next.piece surface.pieces of
                                Just nextPiece ->
                                    walk
                                        surface_
                                        (crossings + 1)
                                        { piece = next.piece
                                        , a = next.a
                                        , b = next.b
                                        , heading = vecToHeading (tangentFrame nextPiece next.a next.b) direction
                                        }
                                        remaining_
                                        newSegments

                                Nothing ->
                                    ( point, newSegments )

                        _ ->
                            ( point, newSegments )

                LeftThrough edgeIndex edgePoint remaining_ ->
                    case
                        ( Array.get point.piece surface.seams |> Maybe.andThen (Array.get edgeIndex) |> Maybe.andThen identity
                        , crossings < maxSeamCrossings
                        )
                    of
                        ( Just ( otherPiece, otherEdge ), True ) ->
                            case Array.get otherPiece surface.pieces of
                                Just other ->
                                    walk
                                        surface_
                                        (crossings + 1)
                                        (crossSeam piece edgeIndex edgePoint other otherPiece otherEdge)
                                        remaining_
                                        newSegments

                                Nothing ->
                                    ( edgePoint, newSegments )

                        _ ->
                            ( edgePoint, newSegments )

        Nothing ->
            ( point, segments )


{-| Move a walker from an edge of one piece onto the matching edge of the next piece. The angle
between the walker's direction and the edge is kept, so this also works across a crease.
-}
crossSeam : Piece -> Int -> SurfacePoint_ -> Piece -> Int -> Int -> SurfacePoint_
crossSeam piece edgeIndex point other otherIndex otherEdge =
    let
        frame =
            tangentFrame piece point.a point.b

        direction =
            headingToVec frame point.heading

        located =
            locateOnEdge other otherEdge frame.p

        otherFrame =
            tangentFrame other located.a located.b

        { tangent, inward } =
            edgeFrame other otherEdge located.a located.b

        along =
            dot direction tangent

        across =
            sqrt (max 1.0e-12 (1 - along * along))
    in
    { piece = otherIndex
    , a = located.a
    , b = located.b
    , heading = vecToHeading otherFrame (combine along tangent across inward)
    }


segmentFrom : Vec -> Vec -> Vec -> Segments coordinates -> Segments coordinates
segmentFrom start end n segments =
    ( LineSegment3d.from (toPoint start) (toPoint end), toDirection n ) :: segments


walkFlat : Flat -> SurfacePoint_ -> Float -> Segments coordinates -> ( Exit, Segments coordinates )
walkFlat flat point remaining segments =
    let
        dx =
            cos point.heading

        dy =
            sin point.heading

        exit =
            Array.foldl
                (\edge ( index, best ) ->
                    ( index + 1
                    , case rayExit edge point.a point.b dx dy of
                        Just t ->
                            case best of
                                Just ( _, bestT ) ->
                                    if t < bestT then
                                        Just ( index, t )

                                    else
                                        best

                                Nothing ->
                                    Just ( index, t )

                        Nothing ->
                            best
                    )
                )
                ( 0, Nothing )
                flat.edges
                |> Tuple.second

        start =
            flatPoint flat point.a point.b
    in
    case exit of
        Just ( edgeIndex, t ) ->
            if t < remaining then
                let
                    end =
                        { point | a = point.a + t * dx, b = point.b + t * dy }
                in
                ( LeftThrough edgeIndex end (remaining - t)
                , segmentFrom start (flatPoint flat end.a end.b) flat.n segments
                )

            else
                arriveOnFlat flat point remaining dx dy start segments

        Nothing ->
            arriveOnFlat flat point remaining dx dy start segments


arriveOnFlat : Flat -> SurfacePoint_ -> Float -> Float -> Float -> Vec -> Segments coordinates -> ( Exit, Segments coordinates )
arriveOnFlat flat point remaining dx dy start segments =
    let
        end =
            { point | a = point.a + remaining * dx, b = point.b + remaining * dy }
    in
    ( Arrived end, segmentFrom start (flatPoint flat end.a end.b) flat.n segments )


{-| Distance along a ray to where it leaves the flat through this edge. Hits where the ray is
entering (such as the edge it just came in through) are ignored.
-}
rayExit : Edge2d -> Float -> Float -> Float -> Float -> Maybe Float
rayExit edge px py dx dy =
    case edge of
        SegmentEdge { ax, ay, bx, by } ->
            let
                ex =
                    bx - ax

                ey =
                    by - ay

                denominator =
                    dx * ey - dy * ex
            in
            -- Leaving means moving to the right of the edge: d cross e > 0
            if denominator <= 1.0e-12 then
                Nothing

            else
                let
                    t =
                        ((ax - px) * ey - (ay - py) * ex) / denominator

                    u =
                        ((ax - px) * dy - (ay - py) * dx) / denominator
                in
                if t > -1.0e-9 && u >= -1.0e-9 && u <= 1 + 1.0e-9 then
                    Just (max 0 t)

                else
                    Nothing

        ArcEdge { cx, cy, r, a0, swept } ->
            let
                ox =
                    px - cx

                oy =
                    py - cy

                b =
                    ox * dx + oy * dy

                c =
                    ox * ox + oy * oy - r * r

                discriminant =
                    b * b - c

                dir =
                    if swept < 0 then
                        -1

                    else
                        1
            in
            if discriminant < 0 then
                Nothing

            else
                let
                    root =
                        sqrt discriminant

                    check t =
                        let
                            hx =
                                ox + t * dx

                            hy =
                                oy + t * dy

                            -- Left of the arc's direction of travel points into the flat
                            inwardX =
                                -dir * hx

                            inwardY =
                                -dir * hy
                        in
                        if t > -1.0e-9 && dx * inwardX + dy * inwardY < 0 && onArc a0 swept (atan2 hy hx) then
                            Just (max 0 t)

                        else
                            Nothing
                in
                case ( check (-b - root), check (-b + root) ) of
                    ( Just t0, Just t1 ) ->
                        Just (min t0 t1)

                    ( Just t0, Nothing ) ->
                        Just t0

                    ( Nothing, maybeT1 ) ->
                        maybeT1


{-| Largest step along a feature, in meters.
-}
maxStep : Float
maxStep =
    0.02


type alias FeatureState =
    { theta : Float, s : Float, phi : Float }


{-| Geodesic equations on a surface of revolution, with unit speed:
ds/dt = cos phi, dtheta/dt = chirality \* sin phi / r, dphi/dt = -sin phi \* (dr/ds) / r.
They keep Clairaut's quantity r \* sin phi constant.
-}
derivative : Feature -> FeatureState -> FeatureState
derivative feature state =
    let
        p =
            profileAt feature state.s

        r =
            max 1.0e-6 p.r
    in
    { theta = feature.chirality * sin state.phi / r
    , s = cos state.phi
    , phi = -(sin state.phi) * p.dr / r
    }


rk4 : Feature -> Float -> FeatureState -> FeatureState
rk4 feature h state =
    let
        offset k f =
            { theta = state.theta + f * k.theta, s = state.s + f * k.s, phi = state.phi + f * k.phi }

        k1 =
            derivative feature state

        k2 =
            derivative feature (offset k1 (h / 2))

        k3 =
            derivative feature (offset k2 (h / 2))

        k4 =
            derivative feature (offset k3 h)
    in
    { theta = state.theta + h / 6 * (k1.theta + 2 * k2.theta + 2 * k3.theta + k4.theta)
    , s = state.s + h / 6 * (k1.s + 2 * k2.s + 2 * k3.s + k4.s)
    , phi = state.phi + h / 6 * (k1.phi + 2 * k2.phi + 2 * k3.phi + k4.phi)
    }


{-| How far past its bounds a state is, as the fraction of the step from `before` to `after` at
which it first left them, and the edge it left through.
-}
firstViolation : Feature -> FeatureState -> FeatureState -> Maybe ( Int, Float )
firstViolation feature before after =
    let
        fraction start end bound =
            if end - start - 0 == 0 then
                0

            else
                clamp 0 1 ((bound - start) / (end - start))

        profileViolations =
            if after.s < 0 then
                [ ( 0, fraction before.s after.s 0 ) ]

            else if after.s > feature.length then
                [ ( 1, fraction before.s after.s feature.length ) ]

            else
                []

        sweepViolations =
            case feature.sweep of
                Just { from, to } ->
                    if after.theta < from then
                        [ ( 2, fraction before.theta after.theta from ) ]

                    else if after.theta > to then
                        [ ( 3, fraction before.theta after.theta to ) ]

                    else
                        []

                Nothing ->
                    []
    in
    List.foldl
        (\( edge, f ) best ->
            case best of
                Just ( _, bestF ) ->
                    if f < bestF then
                        Just ( edge, f )

                    else
                        best

                Nothing ->
                    Just ( edge, f )
        )
        Nothing
        (profileViolations ++ sweepViolations)


{-| At a pole (where the profile touches the axis) the angle around the axis says nothing about
where the walker is, and every geodesic through it is a meridian. Pick the meridian that continues the
walker's direction.
-}
leavePole : Feature -> FeatureState -> Result Vec FeatureState
leavePole feature state =
    let
        atStart =
            state.s < tolerance

        atEnd =
            state.s > feature.length - tolerance

        p =
            profileAt feature state.s
    in
    if abs p.r < tolerance && (atStart || atEnd) then
        let
            basis =
                featureBasis feature state.theta state.s

            direction =
                combine (cos state.phi) basis.es (sin state.phi * feature.chirality) basis.etheta

            -- Moving away from the pole is along +e_s at the start of the profile and -e_s at the end,
            -- and e_s there is dr times the radial direction
            outwardSign =
                if atStart then
                    p.dr

                else
                    -p.dr

            theta =
                atan2 (dot direction feature.ey) (dot direction feature.ex)
                    + (if outwardSign < 0 then
                        pi

                       else
                        0
                      )
        in
        if insideSweep feature theta then
            Ok
                { theta = clampTheta feature theta
                , s = state.s
                , phi =
                    if atStart then
                        0

                    else
                        pi
                }

        else
            -- The meridian that carries on is not part of this piece
            Err direction

    else
        Ok state


{-| Newton's method on the fraction of a step at which the walker reaches an edge.
-}
refineFraction : Feature -> Int -> Float -> FeatureState -> Float -> Int -> Float
refineFraction feature edgeIndex h state fraction iterations =
    if iterations <= 0 then
        fraction

    else
        let
            partial =
                rk4 feature (h * fraction) state

            rate =
                derivative feature partial

            ( value, speed ) =
                case edgeIndex of
                    0 ->
                        ( partial.s, rate.s )

                    1 ->
                        ( partial.s - feature.length, rate.s )

                    2 ->
                        ( partial.theta - sweepStart feature, rate.theta )

                    _ ->
                        ( partial.theta - Tuple.second (sweepRange feature), rate.theta )
        in
        if abs (speed * h) < 1.0e-12 then
            fraction

        else
            refineFraction feature edgeIndex h state (clamp 0 1 (fraction - value / (speed * h))) (iterations - 1)


walkFeature : Feature -> SurfacePoint_ -> Float -> Segments coordinates -> ( Exit, Segments coordinates )
walkFeature feature point remaining segments =
    walkFeatureHelper feature point.piece { theta = point.a, s = point.b, phi = point.heading } remaining segments


walkFeatureHelper : Feature -> Int -> FeatureState -> Float -> Segments coordinates -> ( Exit, Segments coordinates )
walkFeatureHelper feature pieceIndex state_ remaining segments =
    case leavePole feature state_ of
        Ok state ->
            walkFeatureStep feature pieceIndex state remaining segments

        Err direction ->
            ( LeftThroughPoint (featurePoint feature state_.theta state_.s) direction remaining, segments )


walkFeatureStep : Feature -> Int -> FeatureState -> Float -> Segments coordinates -> ( Exit, Segments coordinates )
walkFeatureStep feature pieceIndex state remaining segments =
    let
        toPoint_ s =
            { piece = pieceIndex, a = s.theta, b = s.s, heading = s.phi }

        start =
            featureBasis feature state.theta state.s
    in
    if remaining <= 0 then
        ( Arrived (toPoint_ state), segments )

    else
        let
            h =
                min remaining (min maxStep (max 1.0e-4 (0.25 * (profileAt feature state.s).r)))

            next =
                rk4 feature h state
        in
        case firstViolation feature state next of
            Just ( edgeIndex, roughFraction ) ->
                let
                    fraction =
                        refineFraction feature edgeIndex h state roughFraction 3

                    partial =
                        rk4 feature (h * fraction) state

                    clamped =
                        case edgeIndex of
                            0 ->
                                { partial | s = 0 }

                            1 ->
                                { partial | s = feature.length }

                            2 ->
                                { partial | theta = sweepStart feature }

                            _ ->
                                { partial | theta = Tuple.second (sweepRange feature) }

                    end =
                        featurePoint feature clamped.theta clamped.s

                    newSegments =
                        segmentFrom start.p end start.n segments
                in
                if edgeIndex <= 1 && abs (profileAt feature clamped.s).r < tolerance then
                    -- The profile touches the axis here, so this edge is just a point: carry on over it
                    walkFeatureHelper feature pieceIndex clamped (remaining - h * fraction) newSegments

                else
                    ( LeftThrough edgeIndex (toPoint_ clamped) (remaining - h * fraction), newSegments )

            Nothing ->
                let
                    wrapped =
                        case feature.sweep of
                            Just _ ->
                                next

                            Nothing ->
                                { next | theta = wrapAngle next.theta }
                in
                walkFeatureHelper
                    feature
                    pieceIndex
                    wrapped
                    (remaining - h)
                    (segmentFrom start.p (featurePoint feature wrapped.theta wrapped.s) start.n segments)



---- FLATTENING ----


type alias Complex =
    { re : Float, im : Float }


{-| A Möbius transformation, z -> (a z + b) / (c z + d).
-}
type alias Mobius =
    { a : Complex, b : Complex, c : Complex, d : Complex }


{-| Where one piece goes on a flat map. Each point of the piece has a chart coordinate (see
`chartCoordinate`). If `exponent` is 0 the map position is `mobius chart`, otherwise it is
`mobius (exp (exponent * chart))`. Either way the map is conformal: shapes are kept and only the
scale changes from place to place.

A piece can be placed more than once: a rounded corner doesn't flatten out, so going round it one
way or the other puts what's behind it in two slightly different places. Each placement has a
`window`, the directions from the middle of the map in which it was seen through the edge it was
reached by (within `halfWidth` radians of `center`, everything if that's pi or more). Where copies
overlap, draw the one whose window the point is in, and after that the one with the smallest
`distance` (how far from the middle of the map the piece was first reached). That cuts the map along
a line from the player through the corner, like an unfolded box.

-}
type alias Placement =
    { piece : Int
    , exponent : Float
    , mobius : Mobius
    , distance : Float
    , window : Window
    }


type alias Window =
    { center : Float, halfWidth : Float }


fullWindow : Window
fullWindow =
    { center = 0, halfWidth = pi }


{-| The directions in both windows. If they overlap on both sides, only the overlap nearest the
first window's middle is kept. If they don't overlap, an empty window where they come closest.
-}
intersectWindows : Window -> Window -> Window
intersectWindows first second =
    if first.halfWidth >= pi then
        second

    else if second.halfWidth >= pi then
        first

    else
        let
            offset =
                wrapAngle (second.center - first.center + pi) - pi

            from =
                max -first.halfWidth (offset - second.halfWidth)

            to =
                min first.halfWidth (offset + second.halfWidth)
        in
        { center = first.center + (from + to) / 2, halfWidth = max 0 ((to - from) / 2) }


{-| The directions from the middle of the map that a line of points covers.
-}
windowOf : List Complex -> Window
windowOf points =
    case points |> List.filter (\p -> cabs p > 1.0e-9) |> List.map (\p -> atan2 p.im p.re) of
        first :: rest ->
            let
                ( _, low, high ) =
                    List.foldl
                        (\angle ( previous, lowSoFar, highSoFar ) ->
                            let
                                unwrapped =
                                    previous + wrapAngle (angle - previous + pi) - pi
                            in
                            ( unwrapped, min lowSoFar unwrapped, max highSoFar unwrapped )
                        )
                        ( first, first, first )
                        rest
            in
            if high - low >= 2 * pi - 1.0e-3 then
                fullWindow

            else
                { center = (low + high) / 2, halfWidth = (high - low) / 2 }

        [] ->
            fullWindow


cadd : Complex -> Complex -> Complex
cadd p q =
    { re = p.re + q.re, im = p.im + q.im }


csub : Complex -> Complex -> Complex
csub p q =
    { re = p.re - q.re, im = p.im - q.im }


cmul : Complex -> Complex -> Complex
cmul p q =
    { re = p.re * q.re - p.im * q.im, im = p.re * q.im + p.im * q.re }


cdiv : Complex -> Complex -> Complex
cdiv p q =
    let
        denominator =
            q.re * q.re + q.im * q.im
    in
    { re = (p.re * q.re + p.im * q.im) / denominator, im = (p.im * q.re - p.re * q.im) / denominator }


cexp : Complex -> Complex
cexp p =
    let
        magnitude =
            e ^ p.re
    in
    { re = magnitude * cos p.im, im = magnitude * sin p.im }


cabs : Complex -> Float
cabs p =
    sqrt (p.re * p.re + p.im * p.im)


cscale : Float -> Complex -> Complex
cscale s p =
    { re = s * p.re, im = s * p.im }


applyMobius : Mobius -> Complex -> Complex
applyMobius m z =
    cdiv (cadd (cmul m.a z) m.b) (cadd (cmul m.c z) m.d)


composeMobius : Mobius -> Mobius -> Mobius
composeMobius outer inner =
    { a = cadd (cmul outer.a inner.a) (cmul outer.b inner.c)
    , b = cadd (cmul outer.a inner.b) (cmul outer.b inner.d)
    , c = cadd (cmul outer.c inner.a) (cmul outer.d inner.c)
    , d = cadd (cmul outer.c inner.b) (cmul outer.d inner.d)
    }


{-| The Möbius transformation sending p1, p2, p3 to 0, 1 and infinity.
-}
toZeroOneInfinity : Complex -> Complex -> Complex -> Mobius
toZeroOneInfinity p1 p2 p3 =
    { a = csub p2 p3
    , b = cmul (csub p2 p3) p1 |> cscale -1
    , c = csub p2 p1
    , d = cmul (csub p2 p1) p3 |> cscale -1
    }


inverseMobius : Mobius -> Mobius
inverseMobius m =
    { a = m.d, b = cscale -1 m.b, c = cscale -1 m.c, d = m.a }


normalizeMobius : Mobius -> Mobius
normalizeMobius m =
    let
        largest =
            List.foldl max 0 [ cabs m.a, cabs m.b, cabs m.c, cabs m.d ]
    in
    if largest > 0 then
        { a = cscale (1 / largest) m.a, b = cscale (1 / largest) m.b, c = cscale (1 / largest) m.c, d = cscale (1 / largest) m.d }

    else
        m


{-| The Möbius transformation sending each `from` point to the matching `to` point.
-}
fitMobius : ( Complex, Complex, Complex ) -> ( Complex, Complex, Complex ) -> Mobius
fitMobius ( f1, f2, f3 ) ( t1, t2, t3 ) =
    composeMobius (inverseMobius (toZeroOneInfinity t1 t2 t3)) (toZeroOneInfinity f1 f2 f3) |> normalizeMobius


{-| Whether a piece closes up to a point on its axis, like a rounded corner.
-}
hasPole : Piece -> Bool
hasPole piece =
    case piece of
        FlatPiece _ ->
            False

        FeaturePiece feature ->
            abs (profileAt feature 0).r < tolerance || abs (profileAt feature feature.length).r < tolerance


{-| 0 if a piece's chart goes straight onto the map, otherwise the exponent k used as exp (k z).
Flats and part-turn features without a pole are drawn directly. Full turns are drawn through exp so
they wrap round into a ring, and a pole is sent to 0 so it lands on a point rather than at infinity.
-}
pieceExponent : Piece -> Float
pieceExponent piece =
    case piece of
        FlatPiece _ ->
            0

        FeaturePiece feature ->
            if abs (profileAt feature feature.length).r < tolerance then
                -1

            else if abs (profileAt feature 0).r < tolerance || feature.sweep == Nothing then
                1

            else
                0


{-| The smallest distance from the axis used when flattening, so poles stay finite.
-}
minimumRadius : Float
minimumRadius =
    1.0e-3


{-| Integral of ds / r along the profile from 0 to s. Together with the angle round the axis this
gives conformal coordinates on a surface of revolution.
-}
sigmaAt : Feature -> Float -> Float
sigmaAt feature s =
    let
        inside =
            List.foldl
                (\segment total ->
                    let
                        s0 =
                            segS0 segment
                    in
                    total + segmentSigma segment (clamp 0 (segLength segment) (s - s0))
                )
                0
                feature.segments

        -- Beyond the ends of the profile, carry on at the end's rate
        beyond =
            if s < 0 then
                s / max minimumRadius (profileAt feature 0).r

            else if s > feature.length then
                (s - feature.length) / max minimumRadius (profileAt feature feature.length).r

            else
                0
    in
    inside + beyond


{-| Integral of ds / r along one profile segment, from its start to t along it. Worked out exactly
since 1 / r blows up next to a pole.
-}
segmentSigma : ProfileSeg -> Float -> Float
segmentSigma segment t =
    case segment of
        LineSeg { r0, dr } ->
            if abs dr < 1.0e-9 then
                t / max minimumRadius r0

            else
                (logBase e (max minimumRadius (r0 + t * dr)) - logBase e (max minimumRadius r0)) / dr

        ArcSeg { cr, radius, a0, dir, len } ->
            -- r = cr + radius * cos angle and ds = dir * radius * d(angle)
            let
                antiderivative angle =
                    if abs (cr - radius) < 1.0e-9 then
                        tan (angle / 2)

                    else if cr > radius then
                        let
                            root =
                                sqrt (cr * cr - radius * radius)
                        in
                        2 * radius / root * atan2 (sqrt ((cr - radius) / (cr + radius)) * sin (angle / 2)) (cos (angle / 2))

                    else
                        -- The arc reaches the axis, where the integral goes to infinity
                        let
                            root =
                                sqrt (radius * radius - cr * cr)

                            x =
                                sqrt ((radius - cr) / (radius + cr)) * tan (angle / 2) |> clamp (-1 + 1.0e-9) (1 - 1.0e-9)
                        in
                        radius / root * logBase e ((1 + x) / (1 - x))
            in
            dir * (antiderivative (a0 + dir * clamp 0 len t / radius) - antiderivative a0)


{-| Chart coordinate of local coordinates (a, b) on a piece: (a, b) itself on a flat, and
(sigma, chirality \* theta) on a feature.
-}
localChart : Piece -> Float -> Float -> Complex
localChart piece a b =
    case piece of
        FlatPiece _ ->
            { re = a, im = b }

        FeaturePiece feature ->
            { re = sigmaAt feature b, im = feature.chirality * a }


{-| Profile arc length of the point (r, h), carrying on past the ends of the profile in a straight
line.
-}
profileParamUnclamped : Feature -> Float -> Float -> Float
profileParamUnclamped feature r h =
    let
        s =
            closestOnProfile feature r h

        along end =
            let
                p =
                    profileAt feature end
            in
            end + (r - p.r) * p.dr + (h - p.h) * p.dh
    in
    if s <= 1.0e-9 then
        min 0 (along 0)

    else if s >= feature.length - 1.0e-9 then
        max feature.length (along feature.length)

    else
        s


{-| Chart coordinate of the point of a piece's surface nearest to `point`, without clamping to the
piece's edges, so a triangle that pokes a little over an edge keeps its shape.
-}
chartCoordinate : Surface coordinates -> Int -> Point3d Meters coordinates -> Complex
chartCoordinate surface pieceIndex point =
    case getPiece pieceIndex surface of
        Just piece ->
            let
                local =
                    localCoordinatesUnclamped piece (fromPoint point)
            in
            localChart piece local.a local.b

        Nothing ->
            { re = 0, im = 0 }


{-| Local coordinates of the point of a piece's surface nearest to `point`, carrying on past the
piece's edges.
-}
localCoordinatesUnclamped : Piece -> Vec -> { a : Float, b : Float }
localCoordinatesUnclamped piece point =
    case piece of
        FlatPiece flat ->
            let
                local =
                    sub point flat.origin
            in
            { a = dot local flat.u, b = dot local flat.v }

        FeaturePiece feature ->
            let
                local =
                    sub point feature.origin

                x =
                    dot local feature.ex

                y =
                    dot local feature.ey

                rawTheta =
                    atan2 y x

                theta =
                    case feature.sweep of
                        Just { from, to } ->
                            let
                                middle =
                                    (from + to) / 2
                            in
                            middle + wrapAngle (rawTheta - middle + pi) - pi

                        Nothing ->
                            rawTheta
            in
            { a = theta, b = profileParamUnclamped feature (x * cos theta + y * sin theta) (dot local feature.ez) }


{-| Index of the piece nearest to a point.
-}
nearestPiece : Point3d Meters coordinates -> Surface coordinates -> Maybe Int
nearestPiece point surface =
    nearest point surface |> Maybe.map .piece


placeOnMap : Placement -> Complex -> Complex
placeOnMap placement chart =
    applyMobius placement.mobius
        (if placement.exponent == 0 then
            chart

         else
            cexp (cscale placement.exponent chart)
        )


{-| A rounded corner only fits its neighbours closely, so laying the map out from one would put
everything else a little out of place (and things far out a lot out of place). Instead, a walker
on a corner is laid out from the nearest piece that isn't one, as if that piece carried on under
their feet.
-}
startOn : Array Piece -> SurfacePoint_ -> Piece -> ( SurfacePoint_, Piece )
startOn pieces walker piece =
    if hasPole piece then
        let
            frame =
                tangentFrame piece walker.a walker.b

            direction =
                headingToVec frame walker.heading

            closest =
                Array.foldl
                    (\candidate ( index, best ) ->
                        let
                            ( a, b ) =
                                projectOntoPiece candidate frame.p

                            distance =
                                lengthOf (sub (piecePoint candidate a b) frame.p)
                        in
                        ( index + 1
                        , if hasPole candidate then
                            best

                          else
                            case best of
                                Just ( _, _, bestDistance ) ->
                                    if distance < bestDistance then
                                        Just ( index, candidate, distance )

                                    else
                                        best

                                Nothing ->
                                    Just ( index, candidate, distance )
                        )
                    )
                    ( 0, Nothing )
                    pieces
                    |> Tuple.second
        in
        case closest of
            Just ( index, candidate, _ ) ->
                let
                    local =
                        localCoordinatesUnclamped candidate frame.p

                    ( a, b ) =
                        projectOntoPiece candidate frame.p
                in
                ( { piece = index
                  , a = local.a
                  , b = local.b
                  , heading = vecToHeading (tangentFrame candidate a b) direction
                  }
                , candidate
                )

            Nothing ->
                ( walker, piece )

    else
        ( walker, piece )


{-| Lay the surface around a walker out flat, in meters, with the walker at the origin facing +y.

Starting from the walker's piece, each neighbour is placed so that it meets its parent along their
shared edge, nearest first, out to `radius`. Where a seam joins two charts by a Möbius
transformation (a flat and a fillet along a straight edge, a flat and the hole along its rim) the
pieces meet exactly. A rounded corner only fits its neighbours closely, so the map doesn't carry on
through corners: what's behind one is reached round the sides instead.

-}
flattenAround : Float -> SurfacePoint -> Surface coordinates -> List Placement
flattenAround radius (SurfacePoint walker) (Surface { pieces, seams }) =
    case Array.get walker.piece pieces |> Maybe.map (\piece -> startOn pieces walker piece) of
        Just ( point, piece ) ->
            let
                exponent =
                    pieceExponent piece

                chart =
                    localChart piece point.a point.b

                q =
                    if exponent == 0 then
                        chart

                    else
                        cexp (cscale exponent chart)

                -- d(map input)/d(chart)
                dq =
                    if exponent == 0 then
                        { re = 1, im = 0 }

                    else
                        cscale exponent q

                -- d(chart)/d(distance walked along the heading)
                rho =
                    case piece of
                        FlatPiece _ ->
                            1

                        FeaturePiece feature ->
                            max minimumRadius (profileAt feature point.b).r

                dChart =
                    cscale (1 / rho) { re = cos point.heading, im = sin point.heading }

                -- Walking forward should move up the map at one meter per meter
                scaleAndTurn =
                    cdiv { re = 0, im = 1 } (cmul dq dChart)

                -- A ring like the hole can be laid out with either end outside and the other end turned
                -- inside out: inversion 0 lays out q and 1 lays out 1 / q, both scaled to match at the
                -- walker. Near an end, keep that end the right way out so the map doesn't change when
                -- stepping onto the ring, and in between move smoothly from one to the other.
                inversion =
                    case piece of
                        FeaturePiece feature ->
                            if exponent == 0 || hasPole piece then
                                0

                            else
                                let
                                    depth =
                                        (sigmaAt feature point.b - sigmaAt feature 0) / (sigmaAt feature feature.length - sigmaAt feature 0)

                                    eased =
                                        clamp 0 1 ((depth - inversionStart) / (1 - 2 * inversionStart)) |> (\t -> t * t * (3 - 2 * t))
                                in
                                if exponent > 0 then
                                    1 - eased

                                else
                                    eased

                        FlatPiece _ ->
                            0

                start =
                    { piece = point.piece
                    , exponent = exponent
                    , mobius =
                        { a = scaleAndTurn
                        , b = cmul scaleAndTurn q |> cscale -1
                        , c = cdiv { re = inversion, im = 0 } q
                        , d = { re = 1 - inversion, im = 0 }
                        }
                    , distance = 0
                    , window = fullWindow
                    }
            in
            flattenHelper radius pieces seams [ { placement = start, enteredThrough = -1, route = [ point.piece ] } ] [ start ]

        Nothing ->
            []


{-| How far through a ring (as a fraction of its conformal length) the map starts turning the
other end the right way out.
-}
inversionStart : Float
inversionStart =
    0.2


maxPlacements : Int
maxPlacements =
    48


maxPlacementsPerPiece : Int
maxPlacementsPerPiece =
    6


{-| Breadth first by distance from the walker. Each queued placement remembers the edge it was
entered through and the pieces on the way to it. A piece is never placed twice along one route,
which stops routes from circling a corner forever.
-}
flattenHelper :
    Float
    -> Array Piece
    -> Array (Array (Maybe ( Int, Int )))
    -> List { placement : Placement, enteredThrough : Int, route : List Int }
    -> List Placement
    -> List Placement
flattenHelper radius pieces seams queue placed =
    case List.sortBy (.placement >> .distance) queue of
        [] ->
            List.reverse placed

        { placement, enteredThrough, route } :: rest ->
            case Array.get placement.piece pieces of
                Just parentPiece ->
                    if hasPole parentPiece && List.length route > 1 then
                        -- A rounded corner can't be fitted exactly to its neighbours, so the map
                        -- doesn't carry on through one. What's behind it is reached the other way,
                        -- through the edges either side, which do fit exactly.
                        flattenHelper radius pieces seams rest placed

                    else
                        let
                            ( newQueue, newPlaced ) =
                                List.range 0 (edgeCount parentPiece - 1)
                                    |> List.foldl
                                        (\edgeIndex ( queueAcc, placedAcc ) ->
                                            case
                                                Array.get placement.piece seams
                                                    |> Maybe.andThen (Array.get edgeIndex)
                                                    |> Maybe.andThen identity
                                            of
                                                Just ( childIndex, childEdge ) ->
                                                    if edgeIndex == enteredThrough || List.member childIndex route || List.length placedAcc >= maxPlacements then
                                                        ( queueAcc, placedAcc )

                                                    else
                                                        case Array.get childIndex pieces |> Maybe.andThen (placeChild radius placement parentPiece edgeIndex childIndex childEdge) of
                                                            Just child ->
                                                                if isNewPlacement child placedAcc then
                                                                    ( { placement = child, enteredThrough = childEdge, route = childIndex :: route } :: queueAcc
                                                                    , child :: placedAcc
                                                                    )

                                                                else
                                                                    ( queueAcc, placedAcc )

                                                            Nothing ->
                                                                ( queueAcc, placedAcc )

                                                Nothing ->
                                                    ( queueAcc, placedAcc )
                                        )
                                        ( rest, placed )
                        in
                        flattenHelper radius pieces seams newQueue newPlaced

                Nothing ->
                    flattenHelper radius pieces seams rest placed


isNewPlacement : Placement -> List Placement -> Bool
isNewPlacement child placed =
    let
        samePiece =
            List.filter (\p -> p.piece == child.piece) placed

        probe placement =
            [ { re = 0.1, im = 0.2 }, { re = -0.3, im = 0.05 } ] |> List.map (placeOnMap placement)

        childProbe =
            probe child
    in
    List.length samePiece
        < maxPlacementsPerPiece
        && List.all
            (\other ->
                (List.map2 (\p q -> cabs (csub p q)) (probe other) childProbe
                    |> List.any (\d -> d > 1.0e-3 || isNaN d)
                )
                    || abs (wrapAngle (other.window.center - child.window.center + pi) - pi)
                    > 1.0e-3
                    || abs (min pi other.window.halfWidth - min pi child.window.halfWidth)
                    > 1.0e-3
            )
            samePiece


placeChild : Float -> Placement -> Piece -> Int -> Int -> Int -> Piece -> Maybe Placement
placeChild radius parent parentPiece edgeIndex childIndex childEdge childPiece =
    let
        exponent =
            pieceExponent childPiece

        childInput p =
            let
                located =
                    locateOnEdge childPiece childEdge p

                chart =
                    localChart childPiece located.a located.b
            in
            if exponent == 0 then
                chart

            else
                cexp (cscale exponent chart)

        parentOutput p =
            let
                located =
                    locateOnEdge parentPiece edgeIndex p
            in
            placeOnMap parent (localChart parentPiece located.a located.b)

        -- Where the shared edge is on the map
        edgeOnMap =
            List.range 0 8
                |> List.filterMap (\i -> edgeSample parentPiece edgeIndex (toFloat i / 8))
                |> List.map parentOutput

        distance =
            List.foldl (\w nearestSoFar -> min (cabs w) nearestSoFar) (1 / 0) edgeOnMap

        visible =
            intersectWindows parent.window (windowOf edgeOnMap)

        -- Pieces whose shared edge is less than a couple of pixels across aren't worth drawing (this
        -- stops the copies of the world seen through the hole from nesting forever)
        extent =
            case edgeOnMap of
                first :: _ ->
                    List.foldl (\w largest -> max (cabs (csub w first)) largest) 0 edgeOnMap

                [] ->
                    0
    in
    case List.filterMap (edgeSample parentPiece edgeIndex) [ 0.15, 0.5, 0.85 ] of
        [ p1, p2, p3 ] ->
            let
                (( f1, f2, f3 ) as from) =
                    ( childInput p1, childInput p2, childInput p3 )

                separated =
                    cabs (csub f1 f2) > 1.0e-9 && cabs (csub f2 f3) > 1.0e-9 && cabs (csub f1 f3) > 1.0e-9
            in
            if separated && distance < radius && extent > radius * 0.02 then
                Just
                    { piece = childIndex
                    , exponent = exponent
                    , mobius = fitMobius from ( parentOutput p1, parentOutput p2, parentOutput p3 )
                    , distance = max distance parent.distance
                    , window = visible
                    }

            else
                Nothing

        _ ->
            Nothing
