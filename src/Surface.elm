module Surface exposing
    ( Surface, build, Error(..), errorToString
    , FlatSpec, FlatEdge(..), FeatureSpec, ProfileSegment(..), Sweep(..)
    , FlatCoordinate, FeatureCoordinate, ProfileCoordinate
    , SurfacePoint, nearestSurfacePoint, nearestPoint, worldPosition, normal, worldDirection, pointTowards, rotateBy
    , encodeSurfacePoint, surfacePointDecoder
    , Path, move, pathEnd, pathSegments
    , pieceCount
    , MeshVertex, tessellate
    , Complex, Layout, Placement, Window, FanRay, FanSample, mapAround, fanSpacing, chartCoordinate, nearestPiece, placeOnMap
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
@docs encodeSurfacePoint, surfacePointDecoder
@docs Path, move, pathEnd, pathSegments
@docs pieceCount
@docs MeshVertex, tessellate
@docs Complex, Layout, Placement, Window, FanRay, FanSample, mapAround, fanSpacing, chartCoordinate, nearestPiece, placeOnMap

-}

import Angle exposing (Angle)
import Array exposing (Array)
import Direction3d exposing (Direction3d)
import Frame3d exposing (Frame3d)
import Json.Decode
import Json.Encode
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

        -- For each piece, a box it's inside
        , boxes : Array Box
        }


type alias Box =
    { min : Vec, max : Vec }


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


encodeSurfacePoint : SurfacePoint -> Json.Encode.Value
encodeSurfacePoint (SurfacePoint point) =
    Json.Encode.object
        [ ( "piece", Json.Encode.int point.piece )
        , ( "a", Json.Encode.float point.a )
        , ( "b", Json.Encode.float point.b )
        , ( "heading", Json.Encode.float point.heading )
        ]


surfacePointDecoder : Json.Decode.Decoder SurfacePoint
surfacePointDecoder =
    Json.Decode.map4 (\piece a b heading -> SurfacePoint { piece = piece, a = a, b = b, heading = heading })
        (Json.Decode.field "piece" Json.Decode.int)
        (Json.Decode.field "a" Json.Decode.float)
        (Json.Decode.field "b" Json.Decode.float)
        (Json.Decode.field "heading" Json.Decode.float)


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


{-| `max`, `min` and `clamp` for numbers. Elm compiles a comparison to JavaScript's own only when it
can tell from the code that both sides are numbers (one is a sum or a difference, say), and
otherwise to a much slower one that works for anything comparable, so the comparisons in code that
runs often are written as differences against 0.
-}
maxFloat : Float -> Float -> Float
maxFloat a b =
    if a - b > 0 then
        a

    else
        b


minFloat : Float -> Float -> Float
minFloat a b =
    if a - b < 0 then
        a

    else
        b


clampFloat : Float -> Float -> Float -> Float
clampFloat low high x =
    if x - low < 0 then
        low

    else if x - high > 0 then
        high

    else
        x


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
            findSeams pieces |> Result.map (\seams -> Surface { pieces = pieces, seams = seams, boxes = Array.map boxAround pieces })

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
                    if abs (profileAt feature feature.length).r - tolerance < 0 then
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
            if s - (segS0 first + segLength first) < 0 then
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
                    clampFloat 0 len (s - s0)
            in
            { r = r0 + t * dr, h = h0 + t * dh, dr = dr, dh = dh }

        ArcSeg { s0, len, cr, ch, radius, a0, dir } ->
            let
                angle =
                    a0 + dir * clampFloat 0 len (s - s0) / radius
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
            wrapAngle (theta - from) - (to - from) <= 1.0e-9

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
    wrapAngle (dir * (angle - a0)) - abs swept <= 1.0e-9


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

        closest piece index =
            let
                ( a, b ) =
                    projectOntoPiece piece p

                position =
                    piecePoint piece a b
            in
            ( { piece = index, a = a, b = b, position = position }, lengthOf (sub position p) )
    in
    Array.foldl
        (\piece ( index, best ) ->
            ( index + 1
            , case best of
                Just ( _, bestDistance ) ->
                    -- Pieces whose boxes are further away than the best so far can't be closer
                    if (Array.get index surface.boxes |> Maybe.map (boxDistance p)) |> Maybe.withDefault 0 |> (\d -> d - bestDistance >= 0) then
                        best

                    else
                        let
                            ( found, distance ) =
                                closest piece index
                        in
                        if distance - bestDistance < 0 then
                            Just ( found, distance )

                        else
                            best

                Nothing ->
                    Just (closest piece index)
            )
        )
        ( 0, Nothing )
        surface.pieces
        |> Tuple.second
        |> Maybe.map Tuple.first


{-| A box around a piece, from its mesh with a little to spare for where the mesh cuts across curves.
-}
boxAround : Piece -> Box
boxAround piece =
    let
        corners =
            (case piece of
                FlatPiece flat ->
                    tessellateFlat boxStepAngle flat

                FeaturePiece feature ->
                    tessellateFeature boxStepAngle feature
            )
                |> List.concatMap (\( a, b, c ) -> [ a.position, b.position, c.position ])

        spare =
            0.01

        bound pick get =
            List.map get corners |> List.foldl pick (get (List.head corners |> Maybe.withDefault (vec 0 0 0)))
    in
    { min = vec (bound minFloat .x - spare) (bound minFloat .y - spare) (bound minFloat .z - spare)
    , max = vec (bound maxFloat .x + spare) (bound maxFloat .y + spare) (bound maxFloat .z + spare)
    }


{-| Fine enough that a mesh made with it is within `boxAround`'s spare of the piece for the world's
pieces, which have radii of a meter or less.
-}
boxStepAngle : Float
boxStepAngle =
    pi / 24


boxDistance : Vec -> Box -> Float
boxDistance p box =
    let
        outside low high x =
            maxFloat 0 (maxFloat (low - x) (x - high))
    in
    lengthOf (vec (outside box.min.x box.max.x p.x) (outside box.min.y box.max.y p.y) (outside box.min.z box.max.z p.z))


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

        start =
            flatPoint flat point.a point.b
    in
    case flatExit flat point.a point.b dx dy of
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


{-| The edge a straight path from (px, py) heading (dx, dy) leaves a flat through, and how far
along.
-}
flatExit : Flat -> Float -> Float -> Float -> Float -> Maybe ( Int, Float )
flatExit flat px py dx dy =
    Array.foldl
        (\edge ( index, best ) ->
            ( index + 1
            , case rayExit edge px py dx dy of
                Just t ->
                    case best of
                        Just ( _, bestT ) ->
                            if t - bestT < 0 then
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
                if t + 1.0e-9 > 0 && u + 1.0e-9 >= 0 && u <= 1 + 1.0e-9 then
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
                        if t + 1.0e-9 > 0 && dx * inwardX + dy * inwardY < 0 && onArc a0 swept (atan2 hy hx) then
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
            maxFloat 1.0e-6 p.r
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
                clampFloat 0 1 ((bound - start) / (end - start))

        profileViolations =
            if after.s < 0 then
                [ ( 0, fraction before.s after.s 0 ) ]

            else if after.s - feature.length > 0 then
                [ ( 1, fraction before.s after.s feature.length ) ]

            else
                []

        sweepViolations =
            case feature.sweep of
                Just { from, to } ->
                    if after.theta - from < 0 then
                        [ ( 2, fraction before.theta after.theta from ) ]

                    else if after.theta - to > 0 then
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
                    if f - bestF < 0 then
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
            state.s - tolerance < 0

        atEnd =
            state.s - (feature.length - tolerance) > 0

        p =
            profileAt feature state.s
    in
    if abs p.r - tolerance < 0 && (atStart || atEnd) then
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
            refineFraction feature edgeIndex h state (clampFloat 0 1 (fraction - value / (speed * h))) (iterations - 1)


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
                if edgeIndex <= 1 && abs (profileAt feature clamped.s).r - tolerance < 0 then
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



---- MESH ----


{-| A corner of a triangle in a mesh of the surface: where it is and the surface's outward normal there.
-}
type alias MeshVertex =
    { position : Vec, normal : Vec }


{-| Triangles covering the surface, for drawing it. Curves are split into steps of at most
`maxStepAngle` radians. Pieces that meet are split the same way where they meet, so there are no
cracks between them as long as their curved edges start and end at whole steps (which is the case when
`maxStepAngle` divides a quarter turn and edges start and end at quarter turns, as in `World`).
Triangles go counterclockwise seen from outside.
-}
tessellate : Float -> Surface coordinates -> List ( MeshVertex, MeshVertex, MeshVertex )
tessellate maxStepAngle (Surface { pieces }) =
    Array.foldr
        (\piece acc ->
            case piece of
                FlatPiece flat ->
                    tessellateFlat maxStepAngle flat ++ acc

                FeaturePiece feature ->
                    tessellateFeature maxStepAngle feature ++ acc
        )
        []
        pieces


{-| How many equal steps to split an angle into so that none are bigger than `maxStepAngle`.
-}
stepsFor : Float -> Float -> Int
stepsFor maxStepAngle angle =
    max 1 (ceiling (abs angle / maxStepAngle - 1.0e-9))


tessellateFeature : Float -> Feature -> List ( MeshVertex, MeshVertex, MeshVertex )
tessellateFeature maxStepAngle feature =
    let
        ( from, to ) =
            sweepRange feature

        thetaSteps =
            stepsFor maxStepAngle (to - from)

        thetas =
            List.range 0 thetaSteps |> List.map (\i -> from + (to - from) * toFloat i / toFloat thetaSteps)

        -- Lines along the profile don't bend, so they need no points in between
        profileSamples =
            List.concatMap
                (\segment ->
                    case segment of
                        LineSeg { s0 } ->
                            [ s0 ]

                        ArcSeg { s0, len, radius } ->
                            let
                                steps =
                                    stepsFor maxStepAngle (len / radius)
                            in
                            List.range 0 (steps - 1) |> List.map (\j -> s0 + len * toFloat j / toFloat steps)
                )
                feature.segments
                ++ [ feature.length ]

        vertexAt theta s =
            let
                basis =
                    featureBasis feature theta s
            in
            { position = basis.p, normal = basis.n }

        rows =
            List.map (\s -> List.map (\theta -> vertexAt theta s) thetas) profileSamples

        between rowA rowB acc =
            case ( rowA, rowB ) of
                ( a0 :: ((a1 :: _) as restA), b0 :: ((b1 :: _) as restB) ) ->
                    between restA restB (meshTriangle a0 a1 b1 (meshTriangle a0 b1 b0 acc))

                _ ->
                    acc

        allBetween remaining acc =
            case remaining of
                rowA :: ((rowB :: _) as rest) ->
                    allBetween rest (between rowA rowB acc)

                _ ->
                    acc
    in
    allBetween rows []


{-| Add a triangle turned to go counterclockwise seen from outside, unless it has no area (as where
a profile meets the axis).
-}
meshTriangle : MeshVertex -> MeshVertex -> MeshVertex -> List ( MeshVertex, MeshVertex, MeshVertex ) -> List ( MeshVertex, MeshVertex, MeshVertex )
meshTriangle a b c acc =
    let
        facing =
            cross (sub b.position a.position) (sub c.position a.position)

        outward =
            dot facing (add a.normal (add b.normal c.normal))
    in
    if lengthOf facing - 1.0e-12 < 0 then
        acc

    else if outward > 0 then
        ( a, b, c ) :: acc

    else
        ( a, c, b ) :: acc


type alias Point2 =
    { x : Float, y : Float }


tessellateFlat : Float -> Flat -> List ( MeshVertex, MeshVertex, MeshVertex )
tessellateFlat maxStepAngle flat =
    let
        vertex p =
            { position = flatPoint flat p.x p.y, normal = flat.n }
    in
    case flatLoops maxStepAngle flat of
        outer :: holes ->
            withHoles outer holes
                |> earClip
                |> List.foldl (\( a, b, c ) acc -> meshTriangle (vertex a) (vertex b) (vertex c) acc) []

        [] ->
            []


{-| A flat's boundary loops as points, outer loop first. Arcs get a point every step.
-}
flatLoops : Float -> Flat -> List (List Point2)
flatLoops maxStepAngle flat =
    let
        endOf edge =
            case edge of
                SegmentEdge { bx, by } ->
                    { x = bx, y = by }

                ArcEdge { cx, cy, r, a0, swept } ->
                    { x = cx + r * cos (a0 + swept), y = cy + r * sin (a0 + swept) }

        startOf edge =
            case edge of
                SegmentEdge { ax, ay } ->
                    { x = ax, y = ay }

                ArcEdge { cx, cy, r, a0 } ->
                    { x = cx + r * cos a0, y = cy + r * sin a0 }

        pointsOf edge =
            case edge of
                SegmentEdge { ax, ay } ->
                    [ { x = ax, y = ay } ]

                ArcEdge { cx, cy, r, a0, swept } ->
                    let
                        steps =
                            stepsFor maxStepAngle swept
                    in
                    List.range 0 (steps - 1)
                        |> List.map
                            (\i ->
                                let
                                    angle =
                                        a0 + swept * toFloat i / toFloat steps
                                in
                                { x = cx + r * cos angle, y = cy + r * sin angle }
                            )

        -- The edges of all the loops follow each other, and a loop ends where it started
        go edges loopStart current loops =
            case edges of
                edge :: rest ->
                    let
                        start =
                            Maybe.withDefault (startOf edge) loopStart

                        withEdge =
                            current ++ pointsOf edge
                    in
                    if distance2 (endOf edge) start - tolerance < 0 then
                        go rest Nothing [] (withEdge :: loops)

                    else
                        go rest (Just start) withEdge loops

                [] ->
                    if List.isEmpty current then
                        List.reverse loops

                    else
                        List.reverse (current :: loops)
    in
    go (Array.toList flat.edges) Nothing [] []


distance2 : Point2 -> Point2 -> Float
distance2 p q =
    sqrt ((p.x - q.x) ^ 2 + (p.y - q.y) ^ 2)


{-| Twice the signed area of a triangle: positive when counterclockwise.
-}
turn : Point2 -> Point2 -> Point2 -> Float
turn a b c =
    (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)


{-| One loop going round a counterclockwise outer loop and its clockwise holes, by cutting from each
hole to a point of the outer loop it can see.
-}
withHoles : List Point2 -> List (List Point2) -> List Point2
withHoles outer holes =
    let
        rightmost hole =
            List.foldl (\p best -> maxFloat best p.x) (-1 / 0) hole

        edgesOf loop =
            List.map2 Tuple.pair loop (List.drop 1 loop ++ List.take 1 loop)

        crosses p q ( a, b ) =
            let
                touches =
                    distance2 a p < 1.0e-9 || distance2 a q < 1.0e-9 || distance2 b p < 1.0e-9 || distance2 b q < 1.0e-9
            in
            not touches
                && (turn p q a * turn p q b < 0)
                && (turn a b p * turn a b q < 0)

        addHole hole ( loop, otherHoles ) =
            let
                remaining =
                    List.filter ((/=) hole) otherHoles

                mostRight =
                    List.foldl
                        (\( i, p ) ( bestI, bestP ) ->
                            if p.x - bestP.x > 0 then
                                ( i, p )

                            else
                                ( bestI, bestP )
                        )
                        ( 0, List.head hole |> Maybe.withDefault { x = 0, y = 0 } )
                        (List.indexedMap Tuple.pair hole)

                ( holeIndex, m ) =
                    mostRight

                blockers =
                    edgesOf loop ++ List.concatMap edgesOf (hole :: remaining)

                bridge =
                    List.indexedMap Tuple.pair loop
                        |> List.sortBy (\( _, p ) -> distance2 p m)
                        |> List.filter (\( _, p ) -> not (List.any (crosses p m) blockers))
                        |> List.head
            in
            case bridge of
                Just ( loopIndex, p ) ->
                    ( List.take (loopIndex + 1) loop
                        ++ List.drop holeIndex hole
                        ++ List.take (holeIndex + 1) hole
                        ++ p
                        :: List.drop (loopIndex + 1) loop
                    , remaining
                    )

                Nothing ->
                    ( loop, remaining )
    in
    holes
        |> List.sortBy (\hole -> -(rightmost hole))
        |> (\sorted -> List.foldl addHole ( outer, sorted ) sorted)
        |> Tuple.first


{-| Triangles filling a counterclockwise loop, by cutting off corners with nothing else in them.
-}
earClip : List Point2 -> List ( Point2, Point2, Point2 )
earClip loop =
    earClipHelper (Array.fromList loop) 0 0 []


earClipHelper : Array Point2 -> Int -> Int -> List ( Point2, Point2, Point2 ) -> List ( Point2, Point2, Point2 )
earClipHelper points index failures acc =
    let
        count =
            Array.length points

        at i =
            Array.get (modBy count i) points |> Maybe.withDefault { x = 0, y = 0 }
    in
    if count < 3 then
        acc

    else if failures > count then
        -- Nothing left can be cut off cleanly (the loop is broken), so leave the rest out
        acc

    else
        let
            a =
                at (index - 1)

            b =
                at index

            c =
                at (index + 1)

            same p q =
                distance2 p q < 1.0e-9

            inside p =
                not (same p a || same p b || same p c)
                    && turn a b p
                    >= 0
                    && turn b c p
                    >= 0
                    && turn c a p
                    >= 0

            isEar =
                turn a b c > 1.0e-12 && not (Array.foldl (\p found -> found || inside p) False points)

            removeAt i =
                Array.append (Array.slice 0 i points) (Array.slice (i + 1) count points)
        in
        if isEar then
            earClipHelper (removeAt (modBy count index)) (modBy (count - 1) (modBy count index)) 0 (( a, b, c ) :: acc)

        else if turn a b c > -1.0e-12 && turn a b c < 1.0e-12 && same a c then
            -- A spike where the cut to a hole doubles back
            earClipHelper (removeAt (modBy count index)) (modBy (count - 1) (modBy count index)) 0 acc

        else
            earClipHelper points (modBy count (index + 1)) (failures + 1) acc



---- MAP ----


type alias Complex =
    { re : Float, im : Float }


{-| The surface around a walker laid out on a flat map, in meters, with the walker at the origin
facing +y. Distances from the walker are kept: a point that is d meters' walk from the walker (along
the straight path setting off towards it) is d meters from the origin, in the direction the walker
would set off in. Angles away from the walker are not kept.

Flats and part-turn cylinders (such as the rounded edges of a box) unroll without stretching, so
the straight paths across them stay straight, and they are drawn whole as `placements`. Paths that
reach a curved piece (the hole, a rounded corner) bend, so everything they reach from there on is
filled in by `fan`: groups of paths traced from the walker, each with a point every `fanSpacing`
meters. Draw the fan underneath the placements.

-}
type alias Layout =
    { placements : List Placement
    , fan : List (List FanRay)
    }


{-| Where a flat or cylinder piece goes on the map: chart coordinate z (see `chartCoordinate`) goes
to `scale * z + offset`.

Only part of a placed piece is reached by straight paths through the pieces on the way to it: the
part within its `window` (the directions from the middle of the map within `halfWidth` radians of
`center`, all of them if that's pi or more) and, if the piece has a round hole, not behind the hole
(`hole` is the hole's circle on the map). Leave out the rest. `distance` is how far from the middle
of the map the piece starts.

-}
type alias Placement =
    { piece : Int
    , scale : Complex
    , offset : Complex
    , distance : Float
    , window : Window
    , hole : Maybe { center : Complex, radius : Float }
    }


type alias Window =
    { center : Float, halfWidth : Float }


{-| A path traced from the walker, setting off at `angle` on the map (counterclockwise from +x, so
pi / 2 is straight ahead). `samples` are the points on it `fanSpacing` meters apart, starting
`firstSample` points along. Points before that are on flats and cylinders, which the placements
already cover.
-}
type alias FanRay =
    { angle : Float
    , firstSample : Int
    , samples : List FanSample
    }


{-| A point on a fan path: which piece it's on, its chart coordinate there, and where it is.
-}
type alias FanSample =
    { piece : Int
    , chart : Complex
    , position : Vec
    }


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


{-| 0 if a piece's chart coordinate is used as it is, otherwise the exponent k used as exp (k z).
Full turns go through exp so they wrap round into a ring, and a pole is sent to 0 so it lands on a
point rather than at infinity.
-}
pieceExponent : Piece -> Float
pieceExponent piece =
    case piece of
        FlatPiece _ ->
            0

        FeaturePiece feature ->
            if abs (profileAt feature feature.length).r - tolerance < 0 then
                -1

            else if abs (profileAt feature 0).r - tolerance < 0 || feature.sweep == Nothing then
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
                    total + segmentSigma segment (clampFloat 0 (segLength segment) (s - s0))
                )
                0
                feature.segments

        -- Beyond the ends of the profile, carry on at the end's rate
        beyond =
            if s < 0 then
                s / maxFloat minimumRadius (profileAt feature 0).r

            else if s - feature.length > 0 then
                (s - feature.length) / maxFloat minimumRadius (profileAt feature feature.length).r

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
                t / maxFloat minimumRadius r0

            else
                (logBase e (maxFloat minimumRadius (r0 + t * dr)) - logBase e (maxFloat minimumRadius r0)) / dr

        ArcSeg { cr, radius, a0, dir, len } ->
            -- r = cr + radius * cos angle and ds = dir * radius * d(angle)
            let
                antiderivative angle =
                    if abs (cr - radius) < 1.0e-9 then
                        tan (angle / 2)

                    else if cr - radius > 0 then
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
            dir * (antiderivative (a0 + dir * clampFloat 0 len t / radius) - antiderivative a0)


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


{-| The chart coordinate of a full turn goes round and round, and the pole of a rounded corner is off
at infinity, so their chart coordinates are put through exp (see `pieceExponent`). The result
covers each piece once, without seams.
-}
mapChart : Piece -> Float -> Float -> Complex
mapChart piece a b =
    let
        chart =
            localChart piece a b

        exponent =
            pieceExponent piece
    in
    if exponent == 0 then
        chart

    else
        cexp (cscale exponent chart)


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


{-| Chart coordinate (through exp where the piece needs it, see `mapChart`) of the point of a
piece's surface nearest to `point`, without clamping to the piece's edges, so a triangle that pokes
a little over an edge keeps its shape.
-}
chartCoordinate : Surface coordinates -> Int -> Point3d Meters coordinates -> Complex
chartCoordinate surface pieceIndex point =
    case getPiece pieceIndex surface of
        Just piece ->
            let
                local =
                    localCoordinatesUnclamped piece (fromPoint point)
            in
            mapChart piece local.a local.b

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
    cadd (cmul placement.scale chart) placement.offset


{-| Whether a piece unrolls flat without stretching: a flat, or part of a cylinder.
-}
isRigid : Piece -> Bool
isRigid piece =
    case piece of
        FlatPiece _ ->
            True

        FeaturePiece feature ->
            feature.sweep
                /= Nothing
                && List.all
                    (\segment ->
                        case segment of
                            LineSeg { dr } ->
                                abs dr < 1.0e-9

                            ArcSeg _ ->
                                False
                    )
                    feature.segments


{-| Meters between the points of a fan path.
-}
fanSpacing : Float
fanSpacing =
    0.15


{-| See `Layout`.
-}
mapAround : Float -> SurfacePoint -> Surface coordinates -> Layout
mapAround radius (SurfacePoint walker) (Surface { pieces, seams }) =
    case Array.get walker.piece pieces of
        Just piece ->
            let
                ( placements, curved ) =
                    if isRigid piece then
                        let
                            chart =
                                localChart piece walker.a walker.b

                            -- Meters per unit of chart coordinate
                            rho =
                                case piece of
                                    FlatPiece _ ->
                                        1

                                    FeaturePiece feature ->
                                        (profileAt feature walker.b).r

                            -- Walking forward should move up the map at one meter per meter
                            scale_ =
                                cmul { re = 0, im = rho } { re = cos walker.heading, im = -(sin walker.heading) }

                            start =
                                { piece = walker.piece
                                , scale = scale_
                                , offset = cmul scale_ chart |> cscale -1
                                , distance = 0
                                , window = fullWindow
                                , hole = holeOnMap piece { scale = scale_, offset = cmul scale_ chart |> cscale -1 }
                                }
                        in
                        flattenHelper radius pieces seams [ { placement = start, enteredThrough = -1, route = [ walker.piece ] } ] [ start ] []

                    else
                        ( [], [ fullWindow ] )
            in
            { placements = placements
            , fan = traceFan { pieces = pieces, seams = seams, rigid = Array.map isRigid pieces, count = ceiling (radius / fanSpacing) } walker curved
            }

        Nothing ->
            { placements = [], fan = [] }


maxPlacements : Int
maxPlacements =
    64


{-| Breadth first by distance from the walker. Each queued placement remembers the edge it was
entered through and the pieces on the way to it. Only flats and cylinders are placed. The
directions in which a straight path runs into anything else are collected, for the fan to fill in.
-}
flattenHelper :
    Float
    -> Array Piece
    -> Array (Array (Maybe ( Int, Int )))
    -> List { placement : Placement, enteredThrough : Int, route : List Int }
    -> List Placement
    -> List Window
    -> ( List Placement, List Window )
flattenHelper radius pieces seams queue placed curved =
    case List.sortBy (.placement >> .distance) queue of
        [] ->
            ( List.reverse placed, curved )

        { placement, enteredThrough, route } :: rest ->
            case Array.get placement.piece pieces of
                Just parentPiece ->
                    let
                        edgeOnMap edgeIndex =
                            edgeFractions parentPiece edgeIndex
                                |> List.filterMap (edgeSample parentPiece edgeIndex)
                                |> List.map
                                    (\p ->
                                        let
                                            located =
                                                locateOnEdge parentPiece edgeIndex p
                                        in
                                        placeOnMap placement (localChart parentPiece located.a located.b)
                                    )

                        -- A straight path that crosses a hole in this piece goes down the hole instead
                        shadows =
                            holeEdges parentPiece |> List.map (\edgeIndex -> ( edgeIndex, windowOf (edgeOnMap edgeIndex) ))

                        ( newQueue, newPlaced, newCurved ) =
                            List.range 0 (edgeCount parentPiece - 1)
                                |> List.foldl
                                    (\edgeIndex (( queueAcc, placedAcc, curvedAcc ) as unchanged) ->
                                        case
                                            Array.get placement.piece seams
                                                |> Maybe.andThen (Array.get edgeIndex)
                                                |> Maybe.andThen identity
                                        of
                                            Just ( childIndex, childEdge ) ->
                                                let
                                                    points =
                                                        edgeOnMap edgeIndex

                                                    distance =
                                                        List.map2 distanceToSegment points (List.drop 1 points) |> List.foldl min (1 / 0)

                                                    visible =
                                                        shadows
                                                            |> List.filter (\( holeEdge, _ ) -> holeEdge /= edgeIndex)
                                                            |> List.foldl
                                                                (\( _, shadow ) windows -> List.concatMap (subtractWindow shadow) windows)
                                                                [ intersectWindows placement.window (windowOf points) ]
                                                            |> List.filter (\window -> window.halfWidth > 1.0e-6)
                                                in
                                                if edgeIndex == enteredThrough || distance >= radius then
                                                    unchanged

                                                else
                                                    case Array.get childIndex pieces of
                                                        Just childPiece ->
                                                            if not (isRigid childPiece) then
                                                                ( queueAcc, placedAcc, visible ++ curvedAcc )

                                                            else if List.member childIndex route then
                                                                unchanged

                                                            else
                                                                List.foldl
                                                                    (\window ( q, p, c ) ->
                                                                        case placeChild placement parentPiece edgeIndex childIndex childEdge childPiece (max distance placement.distance) window of
                                                                            Just child ->
                                                                                if List.length p < maxPlacements && isNewPlacement child p then
                                                                                    ( { placement = child, enteredThrough = childEdge, route = childIndex :: route } :: q
                                                                                    , child :: p
                                                                                    , c
                                                                                    )

                                                                                else
                                                                                    ( q, p, c )

                                                                            Nothing ->
                                                                                ( q, p, c )
                                                                    )
                                                                    unchanged
                                                                    visible

                                                        Nothing ->
                                                            unchanged

                                            Nothing ->
                                                unchanged
                                    )
                                    ( rest, placed, curved )
                    in
                    flattenHelper radius pieces seams newQueue newPlaced newCurved

                Nothing ->
                    flattenHelper radius pieces seams rest placed curved


{-| How far the origin is from the segment from p to q.
-}
distanceToSegment : Complex -> Complex -> Float
distanceToSegment p q =
    let
        d =
            csub q p

        lengthSquared =
            d.re * d.re + d.im * d.im

        t =
            if lengthSquared < 1.0e-18 then
                0

            else
                clamp 0 1 -((p.re * d.re + p.im * d.im) / lengthSquared)
    in
    cabs (cadd p (cscale t d))


{-| Where along an edge to sample it, enough to find the directions it covers from anywhere.
-}
edgeFractions : Piece -> Int -> List Float
edgeFractions piece edgeIndex =
    let
        count =
            case piece of
                FlatPiece flat ->
                    case Array.get edgeIndex flat.edges of
                        Just (ArcEdge _) ->
                            64

                        _ ->
                            1

                FeaturePiece _ ->
                    -- The edges of a cylinder are straight in its chart
                    1
    in
    List.range 0 count |> List.map (\i -> toFloat i / toFloat count)


{-| The edges of a flat that are round holes in it.
-}
holeEdges : Piece -> List Int
holeEdges piece =
    case piece of
        FlatPiece flat ->
            Array.toIndexedList flat.edges
                |> List.filterMap
                    (\( index, edge ) ->
                        case edge of
                            ArcEdge { swept } ->
                                if swept < -2 * pi + 1.0e-6 then
                                    Just index

                                else
                                    Nothing

                            SegmentEdge _ ->
                                Nothing
                    )

        FeaturePiece _ ->
            []


{-| The first round hole in a piece, on the map.
-}
holeOnMap : Piece -> { a | scale : Complex, offset : Complex } -> Maybe { center : Complex, radius : Float }
holeOnMap piece placement =
    case piece of
        FlatPiece flat ->
            holeEdges piece
                |> List.head
                |> Maybe.andThen (\index -> Array.get index flat.edges)
                |> Maybe.andThen
                    (\edge ->
                        case edge of
                            ArcEdge { cx, cy, r } ->
                                Just
                                    { center = cadd (cmul placement.scale { re = cx, im = cy }) placement.offset
                                    , radius = r * cabs placement.scale
                                    }

                            SegmentEdge _ ->
                                Nothing
                    )

        FeaturePiece _ ->
            Nothing


isNewPlacement : Placement -> List Placement -> Bool
isNewPlacement child placed =
    List.all
        (\other ->
            other.piece
                /= child.piece
                || cabs (csub other.scale child.scale)
                > 1.0e-6
                || cabs (csub other.offset child.offset)
                > 1.0e-6
                || abs (wrapAngle (other.window.center - child.window.center + pi) - pi)
                > 1.0e-6
                || abs (min pi other.window.halfWidth - min pi child.window.halfWidth)
                > 1.0e-6
        )
        placed


{-| A flat or cylinder piece placed so that it meets its parent along their shared edge. Both are
unrolled without stretching, so this only needs a turn and a shift.
-}
placeChild : Placement -> Piece -> Int -> Int -> Int -> Piece -> Float -> Window -> Maybe Placement
placeChild parent parentPiece edgeIndex childIndex childEdge childPiece distance window =
    let
        childChart p =
            let
                located =
                    locateOnEdge childPiece childEdge p
            in
            localChart childPiece located.a located.b

        parentOutput p =
            let
                located =
                    locateOnEdge parentPiece edgeIndex p
            in
            placeOnMap parent (localChart parentPiece located.a located.b)
    in
    case List.filterMap (edgeSample parentPiece edgeIndex) [ 0.1, 0.9 ] of
        [ p1, p2 ] ->
            let
                z1 =
                    childChart p1

                z2 =
                    childChart p2

                w1 =
                    parentOutput p1

                w2 =
                    parentOutput p2
            in
            if cabs (csub z2 z1) > 1.0e-9 then
                let
                    scale_ =
                        cdiv (csub w2 w1) (csub z2 z1)

                    offset =
                        csub w1 (cmul scale_ z1)
                in
                Just
                    { piece = childIndex
                    , scale = scale_
                    , offset = offset
                    , distance = distance
                    , window = window
                    , hole = holeOnMap childPiece { scale = scale_, offset = offset }
                    }

            else
                Nothing

        _ ->
            Nothing


{-| The directions in `window` but not in `cut`: none, one or two windows.
-}
subtractWindow : Window -> Window -> List Window
subtractWindow cut window =
    if cut.halfWidth >= pi then
        []

    else if window.halfWidth >= pi then
        [ { center = cut.center + pi, halfWidth = pi - cut.halfWidth } ]

    else
        let
            offset =
                wrapAngle (cut.center - window.center + pi) - pi

            remove ( low, high ) intervals =
                intervals
                    |> List.concatMap
                        (\( from, to ) ->
                            if high <= from || low >= to then
                                [ ( from, to ) ]

                            else
                                List.filter (\( f, t ) -> t > f) [ ( from, low ), ( high, to ) ]
                        )
        in
        [ -1, 0, 1 ]
            |> List.foldl
                (\turns intervals -> remove ( offset - cut.halfWidth + turns * 2 * pi, offset + cut.halfWidth + turns * 2 * pi ) intervals)
                [ ( -window.halfWidth, window.halfWidth ) ]
            |> List.map (\( from, to ) -> { center = window.center + (from + to) / 2, halfWidth = (to - from) / 2 })



---- FAN ----


type alias TraceContext =
    { pieces : Array Piece
    , seams : Array (Array (Maybe ( Int, Int )))
    , rigid : Array Bool
    , count : Int
    }


{-| How much wider than the curved directions the fan is, so it overlaps the placements a little.
-}
fanMargin : Float
fanMargin =
    0.02


{-| Angle between neighbouring fan paths before they're refined.
-}
fanAngle : Float
fanAngle =
    0.08


{-| Neighbouring fan paths further apart than this get another path between them.
-}
fanGap : Float
fanGap =
    0.5


{-| How many times the gap between two neighbouring paths can be halved.
-}
maxFanRefinement : Int
maxFanRefinement =
    3


{-| Trace paths from the walker over the given directions, adding paths where neighbouring ones
spread apart.
-}
traceFan : TraceContext -> SurfacePoint_ -> List Window -> List (List FanRay)
traceFan context walker windows =
    let
        traceAt angle =
            let
                trace =
                    traceStep context 0 { walker | heading = walker.heading + angle - pi / 2 } 0 0 { samples = [], firstCurved = 1 / 0 }
            in
            { angle = angle, samples = List.reverse trace.samples, firstCurved = trace.firstCurved }

        refine depth left right =
            if depth > 0 && spread left.samples right.samples > fanGap then
                let
                    middle =
                        traceAt ((left.angle + right.angle) / 2)
                in
                refine (depth - 1) left middle ++ refine (depth - 1) middle right

            else
                [ right ]

        traceGroup ( from, to ) =
            let
                steps =
                    max 2 (ceiling ((to - from) / fanAngle))

                rays =
                    List.range 0 steps |> List.map (\i -> traceAt (from + (to - from) * toFloat i / toFloat steps))
            in
            case rays of
                first :: others ->
                    first
                        :: (List.map2 (refine maxFanRefinement) rays others |> List.concat)
                        |> finishGroup

                [] ->
                    []
    in
    mergeWindows windows |> List.map traceGroup


{-| How far apart two paths get.
-}
spread : List FanSample -> List FanSample -> Float
spread first second =
    List.map2 (\p q -> lengthOf (sub p.position q.position)) first second |> List.foldl max 0


{-| Each path keeps its points from a little before it (or a neighbour) first reaches a curved
piece.
-}
finishGroup : List { angle : Float, samples : List FanSample, firstCurved : Float } -> List FanRay
finishGroup rays =
    let
        firsts =
            List.map
                (\ray ->
                    if isInfinite ray.firstCurved then
                        1000000

                    else
                        max 0 (floor (ray.firstCurved / fanSpacing) - 2)
                )
                rays

        neighbourMin =
            List.map3 (\previous current next -> min previous (min current next))
                (List.take 1 firsts ++ firsts)
                firsts
                (List.drop 1 firsts ++ List.drop (List.length firsts - 1) firsts)
    in
    List.map2
        (\ray first ->
            { angle = ray.angle
            , firstSample = first
            , samples = List.drop first ray.samples
            }
        )
        rays
        neighbourMin


{-| The directions in any of the windows, widened by `fanMargin`, as angle ranges sorted round the
circle. A range may run past 2 pi.
-}
mergeWindows : List Window -> List ( Float, Float )
mergeWindows windows =
    let
        sorted =
            windows
                |> List.map
                    (\window ->
                        let
                            from =
                                wrapAngle (window.center - window.halfWidth - fanMargin)
                        in
                        ( from, from + 2 * (window.halfWidth + fanMargin) )
                    )
                |> List.sortBy Tuple.first

        -- Last first
        merged =
            List.foldl
                (\( from, to ) acc ->
                    case acc of
                        ( lastFrom, lastTo ) :: others ->
                            if from <= lastTo then
                                ( lastFrom, max to lastTo ) :: others

                            else
                                ( from, to ) :: acc

                        [] ->
                            [ ( from, to ) ]
                )
                []
                sorted

        wrapped =
            -- The last range may wrap round into the first
            case ( merged, List.reverse merged ) of
                ( ( lastFrom, lastTo ) :: _, ( firstFrom, firstTo ) :: _ ) ->
                    if List.length merged > 1 && lastTo >= firstFrom + 2 * pi then
                        (List.reverse merged |> List.drop 1 |> List.take (List.length merged - 2)) ++ [ ( lastFrom, max lastTo (firstTo + 2 * pi) ) ]

                    else
                        List.reverse merged

                _ ->
                    []
    in
    if List.any (\( from, to ) -> to - from >= 2 * pi) wrapped then
        [ ( 0, 2 * pi ) ]

    else
        wrapped


type alias Trace =
    { samples : List FanSample
    , firstCurved : Float
    }


sampleAt : Piece -> Int -> Float -> Float -> FanSample
sampleAt piece pieceIndex a b =
    { piece = pieceIndex, chart = mapChart piece a b, position = piecePoint piece a b }


{-| Follow a geodesic, recording a point every `fanSpacing` meters, `context.count` of them after
the start.
-}
traceStep : TraceContext -> Int -> SurfacePoint_ -> Float -> Int -> Trace -> Trace
traceStep context crossings point travelled index trace =
    if index - context.count > 0 || crossings - maxSeamCrossings > 0 then
        trace

    else
        case Array.get point.piece context.pieces of
            Just piece ->
                let
                    newTrace =
                        if travelled - trace.firstCurved < 0 && Array.get point.piece context.rigid /= Just True then
                            { trace | firstCurved = travelled }

                        else
                            trace
                in
                case piece of
                    FlatPiece flat ->
                        let
                            dx =
                                cos point.heading

                            dy =
                                sin point.heading

                            exit =
                                flatExit flat point.a point.b dx dy

                            until =
                                minFloat (toFloat context.count * fanSpacing)
                                    (case exit of
                                        Just ( _, t ) ->
                                            travelled + t

                                        Nothing ->
                                            1 / 0
                                    )

                            emit i samples =
                                let
                                    t =
                                        toFloat i * fanSpacing - travelled
                                in
                                if toFloat i * fanSpacing - until <= 1.0e-9 then
                                    emit (i + 1) (sampleAt piece point.piece (point.a + t * dx) (point.b + t * dy) :: samples)

                                else
                                    ( i, samples )

                            ( nextIndex, samples_ ) =
                                emit index newTrace.samples
                        in
                        case exit of
                            Just ( edgeIndex, t ) ->
                                crossTrace context crossings point.piece edgeIndex { point | a = point.a + t * dx, b = point.b + t * dy } (travelled + t) nextIndex { newTrace | samples = samples_ }

                            Nothing ->
                                { newTrace | samples = samples_ }

                    FeaturePiece feature ->
                        let
                            state =
                                { theta = point.a, s = point.b, phi = point.heading }
                        in
                        case featureShape feature of
                            Cylinder radius ->
                                traceCylinder context crossings point.piece piece feature radius state travelled index newTrace

                            Sphere center radius ->
                                if (profileAt feature state.s).r - tolerance < 0 then
                                    traceFeature context crossings point.piece piece feature state travelled index newTrace

                                else
                                    traceSphere context crossings point.piece piece feature center radius state travelled index newTrace

                            Revolved ->
                                traceFeature context crossings point.piece piece feature state travelled index newTrace

            Nothing ->
                trace


crossTrace : TraceContext -> Int -> Int -> Int -> SurfacePoint_ -> Float -> Int -> Trace -> Trace
crossTrace context crossings pieceIndex edgeIndex edgePoint travelled index trace =
    case
        ( Array.get pieceIndex context.pieces
        , Array.get pieceIndex context.seams |> Maybe.andThen (Array.get edgeIndex) |> Maybe.andThen identity
        )
    of
        ( Just piece, Just ( otherIndex, otherEdge ) ) ->
            case Array.get otherIndex context.pieces of
                Just other ->
                    traceStep context (crossings + 1) (crossSeam piece edgeIndex edgePoint other otherIndex otherEdge) travelled index trace

                Nothing ->
                    trace

        _ ->
            trace


traceFeature : TraceContext -> Int -> Int -> Piece -> Feature -> FeatureState -> Float -> Int -> Trace -> Trace
traceFeature context crossings pieceIndex piece feature state_ travelled index trace =
    if index - context.count > 0 then
        trace

    else
        case leavePole feature state_ of
            Err direction ->
                case nearestExcluding pieceIndex (add (featurePoint feature state_.theta state_.s) (scale 1.0e-7 direction)) context.pieces of
                    Just next ->
                        case Array.get next.piece context.pieces of
                            Just nextPiece ->
                                traceStep
                                    context
                                    (crossings + 1)
                                    { piece = next.piece
                                    , a = next.a
                                    , b = next.b
                                    , heading = vecToHeading (tangentFrame nextPiece next.a next.b) direction
                                    }
                                    travelled
                                    index
                                    trace

                            Nothing ->
                                trace

                    Nothing ->
                        trace

            Ok state ->
                let
                    target =
                        toFloat index * fanSpacing
                in
                if target - travelled <= 1.0e-9 then
                    traceFeature context crossings pieceIndex piece feature state travelled (index + 1) { trace | samples = sampleAt piece pieceIndex state.theta state.s :: trace.samples }

                else
                    let
                        h =
                            minFloat (target - travelled) (maxFloat 1.0e-4 (0.25 * (profileAt feature state.s).r))

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
                            in
                            if edgeIndex <= 1 && abs (profileAt feature clamped.s).r - tolerance < 0 then
                                traceFeature context crossings pieceIndex piece feature clamped (travelled + h * fraction) index trace

                            else
                                crossTrace context crossings pieceIndex edgeIndex { piece = pieceIndex, a = clamped.theta, b = clamped.s, heading = clamped.phi } (travelled + h * fraction) index trace

                        Nothing ->
                            traceFeature
                                context
                                crossings
                                pieceIndex
                                piece
                                feature
                                (case feature.sweep of
                                    Just _ ->
                                        next

                                    Nothing ->
                                        { next | theta = wrapAngle next.theta }
                                )
                                (travelled + h)
                                index
                                trace


{-| Cylinders and spheres have geodesics in closed form: straight lines in (arc length, r \* theta)
on a cylinder, great circles on a sphere.
-}
type FeatureShape
    = Cylinder Float
    | Sphere Vec Float
    | Revolved


featureShape : Feature -> FeatureShape
featureShape feature =
    case feature.segments of
        [ LineSeg { r0, dr } ] ->
            if abs dr < 1.0e-9 then
                Cylinder r0

            else
                Revolved

        [ ArcSeg { cr, ch, radius } ] ->
            -- A sphere cut down to a wedge no wider than half a turn is convex, so a great circle leaves
            -- it the first time it crosses one of its edges' planes
            if abs cr < 1.0e-9 && (Tuple.second (sweepRange feature) - sweepStart feature) <= pi + 1.0e-9 then
                Sphere (add feature.origin (scale ch feature.ez)) radius

            else
                Revolved

        _ ->
            Revolved


{-| Emit the points of a path that are due before `until`. `at t` is the point `t` meters past
`travelled`.
-}
emitSamples : TraceContext -> Float -> Float -> (Float -> FanSample) -> Int -> List FanSample -> ( Int, List FanSample )
emitSamples context travelled until at index samples =
    if index - context.count <= 0 && toFloat index * fanSpacing - until <= 1.0e-9 then
        emitSamples context travelled until at (index + 1) (at (toFloat index * fanSpacing - travelled) :: samples)

    else
        ( index, samples )


traceCylinder : TraceContext -> Int -> Int -> Piece -> Feature -> Float -> FeatureState -> Float -> Int -> Trace -> Trace
traceCylinder context crossings pieceIndex piece feature radius state travelled index trace =
    let
        ds =
            cos state.phi

        dTheta =
            feature.chirality * sin state.phi / radius

        exits =
            [ if ds + 1.0e-12 < 0 then
                Just ( 0, -state.s / ds )

              else
                Nothing
            , if ds > 1.0e-12 then
                Just ( 1, (feature.length - state.s) / ds )

              else
                Nothing
            ]
                ++ (case feature.sweep of
                        Just { from, to } ->
                            [ if dTheta + 1.0e-12 < 0 then
                                Just ( 2, (from - state.theta) / dTheta )

                              else
                                Nothing
                            , if dTheta > 1.0e-12 then
                                Just ( 3, (to - state.theta) / dTheta )

                              else
                                Nothing
                            ]

                        Nothing ->
                            []
                   )
                |> List.filterMap identity
                |> List.sortBy Tuple.second
                |> List.head

        until =
            minFloat (toFloat context.count * fanSpacing)
                (case exits of
                    Just ( _, t ) ->
                        travelled + maxFloat 0 t

                    Nothing ->
                        1 / 0
                )

        ( nextIndex, samples ) =
            emitSamples context travelled until (\t -> sampleAt piece pieceIndex (state.theta + t * dTheta) (state.s + t * ds)) index trace.samples
    in
    case exits of
        Just ( edgeIndex, t_ ) ->
            let
                t =
                    maxFloat 0 t_

                ( a, b ) =
                    case edgeIndex of
                        0 ->
                            ( state.theta + t * dTheta, 0 )

                        1 ->
                            ( state.theta + t * dTheta, feature.length )

                        2 ->
                            ( sweepStart feature, state.s + t * ds )

                        _ ->
                            ( Tuple.second (sweepRange feature), state.s + t * ds )
            in
            crossTrace context crossings pieceIndex edgeIndex { piece = pieceIndex, a = a, b = b, heading = state.phi } (travelled + t) nextIndex { trace | samples = samples }

        Nothing ->
            { trace | samples = samples }


traceSphere : TraceContext -> Int -> Int -> Piece -> Feature -> Vec -> Float -> FeatureState -> Float -> Int -> Trace -> Trace
traceSphere context crossings pieceIndex piece feature center radius state travelled index trace =
    let
        basis =
            featureBasis feature state.theta state.s

        e1 =
            scale (1 / radius) (sub basis.p center)

        e2 =
            combine (cos state.phi) basis.es (sin state.phi * feature.chirality) basis.etheta

        at angle =
            add center (combine (radius * cos angle) e1 (radius * sin angle) e2)

        offset =
            sub center feature.origin

        -- The first angle along the great circle at which the point's height along n reaches k
        crossing n k =
            let
                ca =
                    radius * dot e1 n

                cb =
                    radius * dot e2 n

                m =
                    sqrt (ca * ca + cb * cb)

                k_ =
                    k - dot offset n
            in
            if m < 1.0e-12 || abs k_ >= m then
                Nothing

            else
                let
                    delta =
                        atan2 cb ca

                    spread_ =
                        acos (k_ / m)

                    firstPositive angle =
                        wrapAngle (angle - 1.0e-6) + 1.0e-6
                in
                Just (minFloat (firstPositive (delta - spread_)) (firstPositive (delta + spread_)))

        profileEdge edgeIndex s =
            let
                end =
                    profileAt feature s
            in
            if abs end.r < tolerance then
                Nothing

            else
                crossing feature.ez end.h |> Maybe.map (\angle -> ( edgeIndex, angle ))

        sweepEdge edgeIndex theta =
            crossing (combine -(sin theta) feature.ex (cos theta) feature.ey) 0 |> Maybe.map (\angle -> ( edgeIndex, angle ))

        exit =
            [ profileEdge 0 0, profileEdge 1 feature.length ]
                ++ (case feature.sweep of
                        Just { from, to } ->
                            [ sweepEdge 2 from, sweepEdge 3 to ]

                        Nothing ->
                            []
                   )
                |> List.filterMap identity
                |> List.sortBy Tuple.second
                |> List.head

        until =
            minFloat (toFloat context.count * fanSpacing)
                (case exit of
                    Just ( _, angle ) ->
                        travelled + radius * angle

                    Nothing ->
                        1 / 0
                )

        ( nextIndex, samples ) =
            emitSamples context
                travelled
                until
                (\t ->
                    let
                        position =
                            at (t / radius)

                        local =
                            localCoordinatesUnclamped piece position
                    in
                    { piece = pieceIndex, chart = mapChart piece local.a local.b, position = position }
                )
                index
                trace.samples
    in
    case exit of
        Just ( edgeIndex, angle ) ->
            let
                local =
                    localCoordinatesUnclamped piece (at angle)

                ( a, b ) =
                    case edgeIndex of
                        0 ->
                            ( clampTheta feature local.a, 0 )

                        1 ->
                            ( clampTheta feature local.a, feature.length )

                        2 ->
                            ( sweepStart feature, clamp 0 feature.length local.b )

                        _ ->
                            ( Tuple.second (sweepRange feature), clamp 0 feature.length local.b )
            in
            crossTrace
                context
                crossings
                pieceIndex
                edgeIndex
                { piece = pieceIndex
                , a = a
                , b = b
                , heading = vecToHeading (tangentFrame piece a b) (combine -(sin angle) e1 (cos angle) e2)
                }
                (travelled + radius * angle)
                nextIndex
                { trace | samples = samples }

        Nothing ->
            { trace | samples = samples }
