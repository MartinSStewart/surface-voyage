module GridLevel exposing
    ( Level, Edge, Piece(..), Cell
    , cellSize, start, startPosition
    , pieces, pieceName, pieceHint
    , openEdges, nearestEdge, wholeSide, edgeSamples
    , attach, fits, add, surface, cellsSurface
    , encode, decoder
    )

{-| Levels made in the game from pieces that line up with a grid.

Everything is measured in whole grid cells (`cellSize` meters), so pieces always line up exactly.
A level starts as a flat rectangle. Its edges are open: the surface ends there. A piece is put on an
open edge and carries on smoothly from the surface there, so it never needs turning or lining up:

  - a square carries straight on,
  - a bend curves up or down, as a quarter of a cylinder (or, on a curved edge, of a torus or a
    sphere),
  - a turn swings the edge round a quarter turn: on a flat that makes a curved strip of flat, and on
    the open end of a bend it takes the bend round a corner (a torus, or a sphere when it's sharp).

Pieces are kept as cells: flat cells (polygons whose edges are straight or quarter circles) and
round cells (a quarter turn of a line or quarter circle round an axis). The flat cells in each plane
are merged into one flat when the level becomes a `Surface`. Their edges are kept a cell long, so
they meet the round cells' edges exactly.

@docs Level, Edge, Piece, Cell
@docs cellSize, start, startPosition
@docs pieces, pieceName, pieceHint
@docs openEdges, nearestEdge, wholeSide, edgeSamples
@docs attach, fits, add, surface, cellsSurface
@docs encode, decoder

-}

import Angle
import Dict exposing (Dict)
import Direction3d exposing (Direction3d)
import Frame3d
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import SketchPlane3d
import Length exposing (Meters)
import Surface exposing (FeatureSpec, FlatSpec, ProfileSegment(..), Surface, Sweep(..))



---- TYPES ----


{-| The size of a grid cell, in meters.
-}
cellSize : Float
cellSize =
    0.2


{-| A point or direction on the grid, in cells.
-}
type alias IVec =
    { x : Int, y : Int, z : Int }


{-| An edge of a cell: a straight line from one grid point to the next, or a quarter circle round a
grid point, from `center + radius * from` to `center + radius * to` (`from` and `to` are at right
angles, along the grid).
-}
type Curve
    = Segment IVec IVec
    | Arc { center : IVec, radius : Int, from : IVec, to : IVec }


{-| A direction at each point of a curve: the same all along it, or out from (1) or in towards (-1)
the centre of an arc.
-}
type Across
    = Along IVec
    | Radial Int


{-| An edge of the surface, with the way out of the piece it's on (where a piece put on it goes) and
the surface's normal along it.
-}
type alias Edge =
    { curve : Curve, out : Across, normal : Across }


{-| A flat cell is a loop going counterclockwise round its normal. A round cell is a quarter turn
of its profile round its axis, from `x` to `axis × x`.
-}
type Cell
    = FlatCell { normal : IVec, loop : List Curve }
    | RoundCell Revolution


type alias Revolution =
    { center : IVec, axis : IVec, x : IVec, profile : Profile }


{-| A profile in the (distance from the axis, height along it) half-plane. Arcs are quarter
circles.
-}
type Profile
    = ProfileLine ( Int, Int ) ( Int, Int )
    | ProfileArc { from : ( Int, Int ), to : ( Int, Int ), center : ( Int, Int ) }


{-| The cells, oldest first.
-}
type alias Level =
    { cells : List Cell }


type Piece
    = SmallSquare
    | LargeSquare
    | InsideCurve
    | OutsideCurve
    | SmallBend
    | LargeBend
    | SharpTurn
    | WideTurn


pieces : List Piece
pieces =
    [ SmallSquare, LargeSquare, InsideCurve, OutsideCurve, SmallBend, LargeBend, SharpTurn, WideTurn ]


pieceName : Piece -> String
pieceName piece =
    case piece of
        SmallSquare ->
            "Small square"

        LargeSquare ->
            "Large square"

        InsideCurve ->
            "Inside curve"

        OutsideCurve ->
            "Outside curve"

        SmallBend ->
            "Small bend"

        LargeBend ->
            "Large bend"

        SharpTurn ->
            "Sharp corner"

        WideTurn ->
            "Wide corner"


{-| What the R key changes for a piece.
-}
pieceHint : Piece -> Bool -> String
pieceHint piece flipped =
    let
        either a b =
            if flipped then
                b

            else
                a
    in
    case piece of
        SmallSquare ->
            "A cell of flat ground"

        LargeSquare ->
            "4 by 4 cells of flat ground. R flips which way along the edge it goes"

        SmallBend ->
            "Bends " ++ either "up" "down" ++ " (R) with a radius of a cell"

        LargeBend ->
            "Bends " ++ either "up" "down" ++ " (R) with a radius of 3 cells"

        InsideCurve ->
            "Flat ground inside a quarter circle, 4 cells across (or the whole side with Q). R flips which way along the edge it goes. On a curved edge it fills in the inside of the curve"

        OutsideCurve ->
            "Flat ground outside a quarter circle, filling the square round it, 4 cells across (or the whole side with Q). R flips which way along the edge it goes. On a curved edge it fills in the outside of the curve"

        SharpTurn ->
            "Takes the open end of a bend round a sharp corner, one way or the other (R)"

        WideTurn ->
            "Takes the open end of a bend round a corner 2 cells wide, one way or the other (R)"



---- GRID VECTORS ----


ivec : Int -> Int -> Int -> IVec
ivec x y z =
    { x = x, y = y, z = z }


vadd : IVec -> IVec -> IVec
vadd a b =
    { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }


vsub : IVec -> IVec -> IVec
vsub a b =
    { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }


vscale : Int -> IVec -> IVec
vscale k a =
    { x = k * a.x, y = k * a.y, z = k * a.z }


vneg : IVec -> IVec
vneg =
    vscale -1


vdot : IVec -> IVec -> Int
vdot a b =
    a.x * b.x + a.y * b.y + a.z * b.z


vcross : IVec -> IVec -> IVec
vcross a b =
    { x = a.y * b.z - a.z * b.y
    , y = a.z * b.x - a.x * b.z
    , z = a.x * b.y - a.y * b.x
    }


vkey : IVec -> List Int
vkey v =
    [ v.x, v.y, v.z ]


{-| A direction along the grid with the signs of a vector that points along it.
-}
unitOf : IVec -> IVec
unitOf v =
    { x = sign v.x, y = sign v.y, z = sign v.z }


sign : Int -> Int
sign n =
    if n > 0 then
        1

    else if n < 0 then
        -1

    else
        0


axes : List IVec
axes =
    [ ivec 1 0 0, ivec 0 1 0, ivec 0 0 1 ]



---- CURVES ----


curveStart : Curve -> IVec
curveStart curve =
    case curve of
        Segment a _ ->
            a

        Arc arc ->
            vadd arc.center (vscale arc.radius arc.from)


curveEnd : Curve -> IVec
curveEnd curve =
    case curve of
        Segment _ b ->
            b

        Arc arc ->
            vadd arc.center (vscale arc.radius arc.to)


reverseCurve : Curve -> Curve
reverseCurve curve =
    case curve of
        Segment a b ->
            Segment b a

        Arc arc ->
            Arc { arc | from = arc.to, to = arc.from }


{-| The same for a curve whichever way round it goes.
-}
curveKey : Curve -> List Int
curveKey curve =
    case curve of
        Segment a b ->
            0 :: (List.sort [ vkey a, vkey b ] |> List.concat)

        Arc arc ->
            1 :: vkey arc.center ++ [ arc.radius ] ++ (List.sort [ vkey arc.from, vkey arc.to ] |> List.concat)


directedKey : Curve -> List Int
directedKey curve =
    case curve of
        Segment a b ->
            0 :: vkey a ++ vkey b

        Arc arc ->
            1 :: vkey arc.center ++ [ arc.radius ] ++ vkey arc.from ++ vkey arc.to



---- CELLS ----


{-| A square with corners `p`, `p + s`, `p + s + o` and `p + o`, facing `normal`.
-}
squareCell : IVec -> IVec -> IVec -> IVec -> Cell
squareCell normal p s o =
    let
        q1 =
            vadd p s

        q2 =
            vadd q1 o

        q3 =
            vadd p o
    in
    flatCell normal [ Segment p q1, Segment q1 q2, Segment q2 q3, Segment q3 p ]


{-| A quarter of a ring round `center`, from `from` to `to`, between two radii (the inner one can be
0, which makes it a quarter of a disc).
-}
ringCell : IVec -> IVec -> IVec -> IVec -> Int -> Int -> Cell
ringCell normal center from to inner outer =
    let
        at r dir =
            vadd center (vscale r dir)
    in
    flatCell normal
        (Arc { center = center, radius = outer, from = from, to = to }
            :: Segment (at outer to) (at inner to)
            :: (if inner > 0 then
                    [ Arc { center = center, radius = inner, from = to, to = from } ]

                else
                    []
               )
            ++ [ Segment (at inner from) (at outer from) ]
        )


{-| A flat cell from a loop, turned round if it goes clockwise round the normal.
-}
flatCell : IVec -> List Curve -> Cell
flatCell normal longLoop =
    let
        -- Straight edges a cell long, so they meet other cells' edges whole
        loop =
            List.concatMap
                (\curve ->
                    case curve of
                        Segment a b ->
                            let
                                step =
                                    unitOf (vsub b a)

                                count =
                                    vdot (vsub b a) step
                            in
                            List.range 0 (count - 1) |> List.map (\i -> Segment (vadd a (vscale i step)) (vadd a (vscale (i + 1) step)))

                        Arc _ ->
                            [ curve ]
                )
                longLoop
    in
    if signedArea normal loop >= 0 then
        FlatCell { normal = normal, loop = loop }

    else
        FlatCell { normal = normal, loop = List.reverse loop |> List.map reverseCurve }


{-| Twice the area a loop goes round, counterclockwise round the normal being positive. Arcs count
as the triangle from their centre plus the quarter circle beyond their chord.
-}
signedArea : IVec -> List Curve -> Float
signedArea normal loop =
    let
        ( u, v ) =
            planeAxes normal

        coords p =
            ( toFloat (vdot p u), toFloat (vdot p v) )

        shoelace a b =
            let
                ( ax, ay ) =
                    coords a

                ( bx, by ) =
                    coords b
            in
            ax * by - bx * ay
    in
    List.foldl
        (\curve acc ->
            case curve of
                Segment a b ->
                    acc + shoelace a b

                Arc arc ->
                    let
                        turning =
                            toFloat (vdot (vcross arc.from arc.to) normal)

                        r =
                            toFloat arc.radius
                    in
                    acc
                        + shoelace (curveStart curve) (curveEnd curve)
                        + turning
                        * (pi / 2 - 1)
                        * r
                        * r
        )
        0
        loop


{-| Two directions along the plane with that normal, with u × v = normal.
-}
planeAxes : IVec -> ( IVec, IVec )
planeAxes normal =
    let
        u =
            List.filter (\a -> vdot a normal == 0) axes |> List.head |> Maybe.withDefault (ivec 1 0 0)
    in
    ( u, vcross normal u )


{-| The way out of a flat cell through an edge of its loop.
-}
flatOut : IVec -> Curve -> Across
flatOut normal curve =
    case curve of
        Segment a b ->
            Along (vcross (vsub b a) normal)

        Arc arc ->
            -- Counterclockwise round the normal means the cell is inside the arc
            if vcross arc.from arc.to == normal then
                Radial 1

            else
                Radial -1


cellEdges : Cell -> List Edge
cellEdges cell =
    case cell of
        FlatCell { normal, loop } ->
            List.map (\curve -> { curve = curve, out = flatOut normal curve, normal = Along normal }) loop

        RoundCell revolution ->
            revolutionEdges revolution



---- ROUND CELLS ----


profileEnds : Profile -> ( ( Int, Int ), ( Int, Int ) )
profileEnds profile =
    case profile of
        ProfileLine p q ->
            ( p, q )

        ProfileArc { from, to } ->
            ( from, to )


sub2 : ( Int, Int ) -> ( Int, Int ) -> ( Int, Int )
sub2 ( a, b ) ( c, d ) =
    ( a - c, b - d )


unit2 : ( Int, Int ) -> ( Int, Int )
unit2 ( a, b ) =
    ( sign a, sign b )


neg2 : ( Int, Int ) -> ( Int, Int )
neg2 ( a, b ) =
    ( -a, -b )


{-| The profile's direction at its start and at its end.
-}
profileTangents : Profile -> ( ( Int, Int ), ( Int, Int ) )
profileTangents profile =
    case profile of
        ProfileLine p q ->
            ( unit2 (sub2 q p), unit2 (sub2 q p) )

        ProfileArc { from, to, center } ->
            -- A quarter circle starts off towards where it ends up, seen from its centre
            ( unit2 (sub2 to center), unit2 (sub2 center from) )


reverseProfile : Profile -> Profile
reverseProfile profile =
    case profile of
        ProfileLine p q ->
            ProfileLine q p

        ProfileArc arc ->
            ProfileArc { arc | from = arc.to, to = arc.from }


{-| The profile's direction turned clockwise: the outward normal (see `Surface`).
-}
rightNormal : ( Int, Int ) -> ( Int, Int )
rightNormal ( r, z ) =
    ( z, -r )


{-| Turn the profile round if the surface's normal at its start doesn't point the way given.
-}
orient : ( Int, Int ) -> Revolution -> Revolution
orient ( nr, nz ) revolution =
    let
        ( r, z ) =
            profileTangents revolution.profile |> Tuple.first |> rightNormal
    in
    if r * nr + z * nz < 0 then
        { revolution | profile = reverseProfile revolution.profile }

    else
        revolution


{-| A point of a profile turned to point `radial` from the axis.
-}
profilePoint : Revolution -> IVec -> ( Int, Int ) -> IVec
profilePoint revolution radial ( rho, h ) =
    vadd revolution.center (vadd (vscale h revolution.axis) (vscale rho radial))


profileDirection : Revolution -> IVec -> ( Int, Int ) -> IVec
profileDirection revolution radial ( r, h ) =
    vadd (vscale r radial) (vscale h revolution.axis)


{-| A direction in the profile's half-plane as a direction across one of the circles round the
axis.
-}
acrossCircle : Revolution -> ( Int, Int ) -> Across
acrossCircle revolution ( r, h ) =
    if h == 0 then
        Radial r

    else
        Along (vscale h revolution.axis)


revolutionEdges : Revolution -> List Edge
revolutionEdges revolution =
    let
        y =
            vcross revolution.axis revolution.x

        ( p0, p1 ) =
            profileEnds revolution.profile

        ( t0, t1 ) =
            profileTangents revolution.profile

        circle ( rho, h ) =
            Arc { center = vadd revolution.center (vscale h revolution.axis), radius = rho, from = revolution.x, to = y }

        ends =
            (if Tuple.first p0 > 0 then
                [ { curve = circle p0, out = acrossCircle revolution (neg2 t0), normal = acrossCircle revolution (rightNormal t0) } ]

             else
                []
            )
                ++ (if Tuple.first p1 > 0 then
                        [ { curve = circle p1, out = acrossCircle revolution t1, normal = acrossCircle revolution (rightNormal t1) } ]

                    else
                        []
                   )

        side radial out =
            { curve =
                case revolution.profile of
                    ProfileLine p q ->
                        Segment (profilePoint revolution radial p) (profilePoint revolution radial q)

                    ProfileArc { from, to, center } ->
                        Arc
                            { center = profilePoint revolution radial center
                            , radius = abs (Tuple.first (sub2 from center)) + abs (Tuple.second (sub2 from center))
                            , from = profileDirection revolution radial (unit2 (sub2 from center))
                            , to = profileDirection revolution radial (unit2 (sub2 to center))
                            }
            , out = Along out
            , normal =
                case revolution.profile of
                    ProfileLine _ _ ->
                        Along (profileDirection revolution radial (rightNormal t0))

                    ProfileArc { from, to, center } ->
                        let
                            ( ar, ah ) =
                                sub2 from center

                            ( br, bh ) =
                                sub2 to center
                        in
                        -- Counterclockwise in the half-plane, the outside is away from the centre
                        Radial (sign (ar * bh - ah * br))
            }
    in
    ends ++ [ side revolution.x (vneg y), side y (vneg revolution.x) ]



---- PUTTING PIECES ON ----


{-| The cells a piece makes, put on some edges: one edge, or a whole straight side (see
`wholeSide`). Nothing if it can't go there.
-}
attach : Piece -> Bool -> List Edge -> Maybe (List Cell)
attach piece flipped edges =
    let
        side =
            if flipped then
                -1

            else
                1

        each f =
            List.map f edges |> combine |> Maybe.map List.concat
    in
    case piece of
        SmallSquare ->
            each (extend 1)

        LargeSquare ->
            case edges of
                [ edge ] ->
                    case edge.curve of
                        Segment _ _ ->
                            largeSquare flipped edge

                        Arc _ ->
                            extend 4 edge

                _ ->
                    each (extend 4)

        SmallBend ->
            each (bend 1 side)

        LargeBend ->
            each (bend 3 side)

        InsideCurve ->
            curvePiece True flipped edges

        OutsideCurve ->
            curvePiece False flipped edges

        SharpTurn ->
            turn 0 flipped edges

        WideTurn ->
            turn 2 flipped edges


combine : List (Maybe a) -> Maybe (List a)
combine =
    List.foldr (Maybe.map2 (::)) (Just [])


{-| Straight on from an edge, `depth` cells.
-}
extend : Int -> Edge -> Maybe (List Cell)
extend depth edge =
    case ( edge.curve, edge.out, edge.normal ) of
        ( Segment a b, Along o, Along n ) ->
            List.range 0 (depth - 1) |> List.map (\i -> squareCell n (vadd a (vscale i o)) (vsub b a) o) |> Just

        ( Arc arc, Radial out, Along n ) ->
            -- Out across a flat round the arc's centre: quarter rings
            List.range 0 (depth - 1)
                |> List.filterMap
                    (\i ->
                        let
                            r0 =
                                arc.radius + out * i

                            r1 =
                                arc.radius + out * (i + 1)
                        in
                        if min r0 r1 < 0 then
                            Nothing

                        else
                            Just (ringCell n arc.center arc.from arc.to (min r0 r1) (max r0 r1))
                    )
                |> nonEmpty

        ( Arc arc, Along d, Radial normal ) ->
            -- Along the arc's axis: quarters of a cylinder
            let
                axis =
                    vcross arc.from arc.to

                dz =
                    vdot d axis
            in
            List.range 0 (depth - 1)
                |> List.map
                    (\i ->
                        { center = arc.center, axis = axis, x = arc.from, profile = ProfileLine ( arc.radius, i * dz ) ( arc.radius, (i + 1) * dz ) }
                            |> orient ( normal, 0 )
                            |> RoundCell
                    )
                |> Just

        _ ->
            Nothing


nonEmpty : List a -> Maybe (List a)
nonEmpty list =
    if List.isEmpty list then
        Nothing

    else
        Just list


largeSquare : Bool -> Edge -> Maybe (List Cell)
largeSquare flipped edge =
    case ( edge.curve, edge.out, edge.normal ) of
        ( Segment a b, Along o, Along n ) ->
            let
                ( base, s ) =
                    if flipped then
                        ( b, vsub a b )

                    else
                        ( a, vsub b a )
            in
            List.range 0 3
                |> List.concatMap (\j -> List.range 0 3 |> List.map (\i -> squareCell n (vadd base (vadd (vscale j s) (vscale i o))) s o))
                |> Just

        _ ->
            Nothing


{-| A quarter turn bend of radius `r`, up (towards the normal, side 1) or down (side -1).
-}
bend : Int -> Int -> Edge -> Maybe (List Cell)
bend r side edge =
    case ( edge.curve, edge.out, edge.normal ) of
        ( Segment a b, Along o, Along n ) ->
            let
                t =
                    vsub b a

                x =
                    vscale -side n

                ( axis, height ) =
                    if vcross t x == o then
                        ( t, 1 )

                    else
                        ( vneg t, -1 )
            in
            { center = vadd a (vscale (side * r) n), axis = axis, x = x, profile = ProfileLine ( r, 0 ) ( r, height ) }
                |> orient ( -side, 0 )
                |> RoundCell
                |> List.singleton
                |> Just

        ( Arc arc, Along d, Radial normal ) ->
            -- Along the arc's axis, curving out from it or in towards it
            let
                axis =
                    vcross arc.from arc.to

                dz =
                    vdot d axis

                q =
                    side * normal

                end =
                    arc.radius + q * r
            in
            if end < 0 then
                Nothing

            else
                { center = arc.center
                , axis = axis
                , x = arc.from
                , profile = ProfileArc { from = ( arc.radius, 0 ), center = ( end, 0 ), to = ( end, dz * r ) }
                }
                    |> orient ( normal, 0 )
                    |> RoundCell
                    |> List.singleton
                    |> Just

        ( Arc arc, Radial out, Along n ) ->
            -- Across a flat round the arc's centre, curving up or down out of it
            let
                axis =
                    vcross arc.from arc.to

                h =
                    side * vdot n axis

                end =
                    arc.radius + out * r
            in
            if end <= 0 then
                Nothing

            else
                { center = arc.center
                , axis = axis
                , x = arc.from
                , profile = ProfileArc { from = ( arc.radius, 0 ), center = ( arc.radius, h * r ), to = ( end, h * r ) }
                }
                    |> orient ( 0, vdot n axis )
                    |> RoundCell
                    |> List.singleton
                    |> Just

        _ ->
            Nothing


{-| The open end of a bend swung a quarter turn round an axis `offset` cells past one end of its arc
(the other end when flipped), taking the bend round a corner.
-}
turn : Int -> Bool -> List Edge -> Maybe (List Cell)
turn offset flipped edges =
    case edges of
        [] ->
            Nothing

        first :: _ ->
            case ( first.curve, first.out, first.normal ) of
                ( Arc arc, Along d, Radial normal ) ->
                    -- The end of a bend: swing its arc round an axis along one of the arc's ends
                    let
                        ( w, other ) =
                            if flipped then
                                ( arc.to, arc.from )

                            else
                                ( arc.from, arc.to )

                        s =
                            vdot d (vcross w other)

                        axis =
                            vscale s w
                    in
                    { center = vsub arc.center (vscale offset other)
                    , axis = axis
                    , x = other
                    , profile = ProfileArc { from = ( offset, s * arc.radius ), center = ( offset, 0 ), to = ( offset + arc.radius, 0 ) }
                    }
                        |> orient ( 0, normal * s )
                        |> RoundCell
                        |> List.singleton
                        |> Just

                _ ->
                    Nothing


{-| Flat ground with a quarter circle edge: inside the circle (a quarter of a disc) or outside it
(the rest of the square round it). On straight edges it's 4 cells across, from the start of the
edge (the end when flipped), or as wide as all the edges. On a curved edge of flat ground it fills
in the curve, inwards or outwards, whichever way the edge faces.
-}
curvePiece : Bool -> Bool -> List Edge -> Maybe (List Cell)
curvePiece inside flipped edges =
    case edges of
        first :: _ ->
            case ( first.curve, first.out, first.normal ) of
                ( Segment _ _, Along o, Along n ) ->
                    let
                        segments =
                            alignedSegments edges
                    in
                    case ( List.head segments, List.reverse segments |> List.head ) of
                        ( Just ( a, b ), Just ( _, last ) ) ->
                            let
                                t =
                                    vsub b a

                                size =
                                    if List.length segments > 1 then
                                        List.length segments

                                    else
                                        4

                                ( p0, along ) =
                                    if flipped then
                                        ( last, vneg t )

                                    else
                                        ( a, t )

                                p1 =
                                    vadd p0 (vscale size along)
                            in
                            if inside then
                                Just [ ringCell n p0 along o 0 size ]

                            else
                                Just
                                    [ flatCell n
                                        [ Segment p0 p1
                                        , Segment p1 (vadd p1 (vscale size o))
                                        , Arc { center = vadd p0 (vscale size o), radius = size, from = along, to = vneg o }
                                        ]
                                    ]

                        _ ->
                            Nothing

                ( Arc arc, Radial out, Along n ) ->
                    let
                        at k dir =
                            vadd arc.center (vscale k dir)

                        corner =
                            vadd (at arc.radius arc.from) (vscale arc.radius arc.to)
                    in
                    if inside && out < 0 then
                        Just [ ringCell n arc.center arc.from arc.to 0 arc.radius ]

                    else if not inside && out > 0 then
                        Just
                            [ flatCell n
                                [ Segment (at arc.radius arc.to) corner
                                , Segment corner (at arc.radius arc.from)
                                , Arc arc
                                ]
                            ]

                    else
                        Nothing

                _ ->
                    Nothing

        [] ->
            Nothing


{-| Straight edges in a row, as their ends, all going the same way as the first.
-}
alignedSegments : List Edge -> List ( IVec, IVec )
alignedSegments edges =
    let
        ends =
            List.filterMap
                (\edge ->
                    case edge.curve of
                        Segment a b ->
                            Just ( a, b )

                        Arc _ ->
                            Nothing
                )
                edges
    in
    case ends of
        ( a, b ) :: _ ->
            let
                t =
                    vsub b a
            in
            List.map
                (\( p, q ) ->
                    if vsub q p == t then
                        ( p, q )

                    else
                        ( q, p )
                )
                ends
                |> List.sortBy (\( p, _ ) -> vdot p t)

        [] ->
            []



---- LEVELS ----


{-| A flat rectangle, 24 by 16 cells, facing up.
-}
start : Level
start =
    let
        width =
            24

        depth =
            16

        corners =
            [ ivec 0 0 0, ivec 0 0 depth, ivec width 0 depth, ivec width 0 0 ]

        sideCells from to =
            let
                step =
                    unitOf (vsub to from)

                count =
                    abs (vdot (vsub to from) step)
            in
            List.range 0 (count - 1) |> List.map (\i -> Segment (vadd from (vscale i step)) (vadd from (vscale (i + 1) step)))

        loop =
            List.map2 sideCells corners (List.drop 1 corners ++ List.take 1 corners) |> List.concat
    in
    { cells = [ flatCell (ivec 0 1 0) loop ] }


{-| Where to put the player on the level `start` makes: the middle, facing away from the front.
-}
startPosition : { position : Point3d Meters coordinates, facing : Point3d Meters coordinates }
startPosition =
    { position = Point3d.meters (12 * cellSize) 0 (8 * cellSize)
    , facing = Point3d.meters (12 * cellSize) 0 (7 * cellSize)
    }


{-| The edges no other cell meets.
-}
openEdges : Level -> List Edge
openEdges level =
    let
        edges =
            List.concatMap cellEdges level.cells

        counts =
            edgeCounts level.cells
    in
    List.filter (\edge -> Dict.get (curveKey edge.curve) counts == Just 1) edges


edgeCounts : List Cell -> Dict (List Int) Int
edgeCounts cells =
    List.foldl
        (\edge -> Dict.update (curveKey edge.curve) (\count -> Just (Maybe.withDefault 0 count + 1)))
        Dict.empty
        (List.concatMap cellEdges cells)


{-| The open edge nearest a point, in meters.
-}
nearestEdge : List Edge -> { x : Float, y : Float, z : Float } -> Maybe Edge
nearestEdge edges point =
    edges
        |> List.map (\edge -> ( distanceTo point edge.curve, edge ))
        |> List.sortBy Tuple.first
        |> List.head
        |> Maybe.map Tuple.second


{-| The open straight edges in a row with this one along the same side (just this one if it's
curved).
-}
wholeSide : List Edge -> Edge -> List Edge
wholeSide edges edge =
    case edge.curve of
        Segment a b ->
            let
                t =
                    vsub b a

                sameSide other =
                    other.out == edge.out && other.normal == edge.normal

                byKey =
                    edges
                        |> List.filter sameSide
                        |> List.map (\other -> ( curveKey other.curve, other ))
                        |> Dict.fromList

                follow p step acc =
                    case Dict.get (curveKey (Segment p (vadd p step))) byKey of
                        Just next ->
                            follow (vadd p step) step (next :: acc)

                        Nothing ->
                            acc
            in
            List.reverse (follow a (vneg t) []) ++ [ edge ] ++ List.reverse (follow b t [])

        Arc _ ->
            [ edge ]


{-| Points along an edge, in meters, with the surface's normal there and the way into the surface.
-}
edgeSamples : Edge -> List { position : { x : Float, y : Float, z : Float }, normal : { x : Float, y : Float, z : Float }, inward : { x : Float, y : Float, z : Float } }
edgeSamples edge =
    let
        steps =
            case edge.curve of
                Segment _ _ ->
                    1

                Arc arc ->
                    4 * arc.radius + 4

        across value point center =
            case value of
                Along v ->
                    toVec v

                Radial s ->
                    let
                        d =
                            fsub point center

                        l =
                            sqrt (fdot d d)
                    in
                    if l < 1.0e-9 then
                        { x = 0, y = 0, z = 0 }

                    else
                        fscale (toFloat s / l) d
    in
    List.range 0 steps
        |> List.map
            (\i ->
                let
                    t =
                        toFloat i / toFloat steps

                    ( point, center ) =
                        case edge.curve of
                            Segment a b ->
                                ( fadd (toVec a) (fscale t (fsub (toVec b) (toVec a))), toVec a )

                            Arc arc ->
                                ( arcPoint arc (t * pi / 2), toVec arc.center )
                in
                { position = fscale cellSize point
                , normal = across edge.normal point center
                , inward = across edge.out point center |> fscale -1
                }
            )



---- FLOAT GEOMETRY ----


type alias Vec =
    { x : Float, y : Float, z : Float }


toVec : IVec -> Vec
toVec v =
    { x = toFloat v.x, y = toFloat v.y, z = toFloat v.z }


fadd : Vec -> Vec -> Vec
fadd a b =
    { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }


fsub : Vec -> Vec -> Vec
fsub a b =
    { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }


fscale : Float -> Vec -> Vec
fscale k a =
    { x = k * a.x, y = k * a.y, z = k * a.z }


fdot : Vec -> Vec -> Float
fdot a b =
    a.x * b.x + a.y * b.y + a.z * b.z


arcPoint : { center : IVec, radius : Int, from : IVec, to : IVec } -> Float -> Vec
arcPoint arc angle =
    fadd (toVec arc.center) (fscale (toFloat arc.radius) (fadd (fscale (cos angle) (toVec arc.from)) (fscale (sin angle) (toVec arc.to))))


{-| How far a point (in meters) is from a curve.
-}
distanceTo : Vec -> Curve -> Float
distanceTo pointInMeters curve =
    let
        p =
            fscale (1 / cellSize) pointInMeters

        closest =
            case curve of
                Segment a b ->
                    let
                        d =
                            fsub (toVec b) (toVec a)

                        t =
                            clamp 0 1 (fdot (fsub p (toVec a)) d / fdot d d)
                    in
                    fadd (toVec a) (fscale t d)

                Arc arc ->
                    let
                        local =
                            fsub p (toVec arc.center)
                    in
                    arcPoint arc (clamp 0 (pi / 2) (atan2 (fdot local (toVec arc.to)) (fdot local (toVec arc.from))))

        d_ =
            fsub p closest
    in
    sqrt (fdot d_ d_) * cellSize


{-| A point inside a cell, in cells: two cells that overlap exactly have the same one.
-}
spot : Cell -> Vec
spot cell =
    case cell of
        FlatCell { normal, loop } ->
            let
                -- Arcs with the cell inside them, and arcs with the cell outside them
                arcs side =
                    List.filterMap
                        (\curve ->
                            case curve of
                                Arc arc ->
                                    if flatOut normal curve == Radial side then
                                        Just arc

                                    else
                                        Nothing

                                Segment _ _ ->
                                    Nothing
                        )
                        loop

                largest list =
                    List.sortBy (.radius >> negate) list |> List.head

                onDiagonal arc distance =
                    fadd (toVec arc.center) (fscale (distance / sqrt 2) (fadd (toVec arc.from) (toVec arc.to)))
            in
            case ( largest (arcs 1), largest (arcs -1) ) of
                ( Just outer, inner ) ->
                    -- A quarter of a ring or disc
                    onDiagonal outer (toFloat (outer.radius + (Maybe.map .radius inner |> Maybe.withDefault 0)) / 2)

                ( Nothing, Just inner ) ->
                    -- A square outside a quarter circle: between the circle and the square's corner
                    onDiagonal inner (toFloat inner.radius * (1 + sqrt 2) / 2)

                ( Nothing, Nothing ) ->
                    let
                        corners =
                            List.map (curveStart >> toVec) loop
                    in
                    List.foldl fadd { x = 0, y = 0, z = 0 } corners |> fscale (1 / toFloat (max 1 (List.length corners)))

        RoundCell revolution ->
            let
                y =
                    vcross revolution.axis revolution.x |> toVec

                radial =
                    fscale (1 / sqrt 2) (fadd (toVec revolution.x) y)

                ( rho, h ) =
                    case revolution.profile of
                        ProfileLine ( r0, h0 ) ( r1, h1 ) ->
                            ( toFloat (r0 + r1) / 2, toFloat (h0 + h1) / 2 )

                        ProfileArc { from, to, center } ->
                            let
                                ( cr, ch ) =
                                    center
                            in
                            ( toFloat cr + toFloat (Tuple.first from - cr + Tuple.first to - cr) / sqrt 2
                            , toFloat ch + toFloat (Tuple.second from - ch + Tuple.second to - ch) / sqrt 2
                            )
            in
            fadd (toVec revolution.center) (fadd (fscale h (toVec revolution.axis)) (fscale rho radial))


spotKey : Vec -> List Int
spotKey v =
    [ round (v.x * 1000), round (v.y * 1000), round (v.z * 1000) ]


{-| The plane a flat cell is in, whichever way it faces.
-}
planeKey : IVec -> List Curve -> List Int
planeKey normal loop =
    let
        n =
            vscale (sign (normal.x + normal.y + normal.z)) normal
    in
    vkey n ++ [ List.head loop |> Maybe.map (curveStart >> vdot n) |> Maybe.withDefault 0 ]


{-| Whether a point (in cells) on a flat cell's plane is inside it. Arcs are taken as 8 straight
lines.
-}
insideFlat : IVec -> List Curve -> Vec -> Bool
insideFlat normal loop point =
    let
        ( u, v ) =
            planeAxes normal

        coords p =
            ( fdot p (toVec u), fdot p (toVec v) )

        ( px, py ) =
            coords point

        corners =
            List.concatMap
                (\curve ->
                    case curve of
                        Segment a _ ->
                            [ coords (toVec a) ]

                        Arc arc ->
                            List.range 0 7 |> List.map (\i -> coords (arcPoint arc (toFloat i * pi / 16)))
                )
                loop

        crosses ( ax, ay ) ( bx, by ) =
            ((ay > py) /= (by > py)) && (px < ax + (py - ay) * (bx - ax) / (by - ay))
    in
    List.map2 crosses corners (List.drop 1 corners ++ List.take 1 corners)
        |> List.filter identity
        |> List.length
        |> modBy 2
        |> (==) 1


{-| Add cells to a level, if they fit: they don't overlap anything already there, and no edge ends
up with more than two cells along it.
-}
add : List Cell -> Level -> Result String Level
add cells level =
    fits cells level
        |> Result.andThen
            (\() ->
                case cellsSurface (level.cells ++ cells) of
                    Ok _ ->
                        Ok { cells = level.cells ++ cells }

                    Err error ->
                        Err (Surface.errorToString error)
            )


{-| The quick checks `add` makes, without making the surface: whether cells overlap anything already
there, or would make an edge with more than two cells along it.
-}
fits : List Cell -> Level -> Result String ()
fits cells level =
    let
        newKeys =
            List.concatMap cellEdges cells |> List.map (.curve >> curveKey)

        counts =
            edgeCounts (level.cells ++ cells)

        spots =
            List.map (spot >> spotKey) level.cells

        flatsIn cellList =
            List.filterMap
                (\cell ->
                    case cell of
                        FlatCell flat ->
                            Just ( planeKey flat.normal flat.loop, flat, spot cell )

                        RoundCell _ ->
                            Nothing
                )
                cellList

        overlapsFlat =
            List.any
                (\( plane, flat, point ) ->
                    List.any
                        (\( otherPlane, other, otherPoint ) ->
                            plane == otherPlane && (insideFlat other.normal other.loop point || insideFlat flat.normal flat.loop otherPoint)
                        )
                        (flatsIn level.cells)
                )
                (flatsIn cells)
    in
    if List.any (\cell -> List.member (spotKey (spot cell)) spots) cells || overlapsFlat then
        Err "It would overlap ground that's already there"

    else if List.any (\key -> Dict.get key counts |> Maybe.withDefault 0 |> (<) 2) newKeys then
        Err "It would meet ground that's already joined there"

    else
        Ok ()



---- TO A SURFACE ----


surface : Level -> Result Surface.Error (Surface coordinates)
surface level =
    cellsSurface level.cells


{-| The surface some cells make, in as few pieces as can be: the flat cells in a plane that are
joined up make one flat, and cells of the same cylinder in a row make one cylinder. Pieces only meet
whole edge to whole edge (see `Surface.build`), so a row of cylinder cells is only merged as far as
what's along each of its sides stays the same, and a flat's edges are only merged as far as what's
on the other side stays the same.
-}
cellsSurface : List Cell -> Result Surface.Error (Surface coordinates)
cellsSurface cells =
    let
        indexed =
            List.indexedMap Tuple.pair cells

        -- The cells along each edge
        owners : Dict (List Int) (List Int)
        owners =
            List.foldl
                (\( id, cell ) acc ->
                    List.foldl
                        (\edge -> Dict.update (curveKey edge.curve) (\others -> Just (id :: Maybe.withDefault [] others)))
                        acc
                        (cellEdges cell)
                )
                Dict.empty
                indexed

        components : List { normal : IVec, members : List Int, boundary : List Curve }
        components =
            indexed
                |> List.filterMap
                    (\( id, cell ) ->
                        case cell of
                            FlatCell flat ->
                                Just ( id, flat )

                            RoundCell _ ->
                                Nothing
                    )
                |> List.foldl
                    (\( id, flat ) ->
                        Dict.update (vkey flat.normal ++ [ List.head flat.loop |> Maybe.map (curveStart >> vdot flat.normal) |> Maybe.withDefault 0 ])
                            (\others -> Just (( id, flat ) :: Maybe.withDefault [] others))
                    )
                    Dict.empty
                |> Dict.values
                |> List.concatMap flatComponents

        cylinders : List Cylinder
        cylinders =
            List.filterMap (\( id, cell ) -> cylinderOf id cell) indexed

        initialLabels : Dict Int (List Int)
        initialLabels =
            List.indexedMap (\index component -> List.map (\id -> ( id, [ 0, index ] )) component.members) components
                |> List.concat
                |> (++) (List.map (\cylinder -> ( cylinder.id, 1 :: cylinder.group )) cylinders)
                |> Dict.fromList

        labelOf labels id =
            Dict.get id labels |> Maybe.withDefault [ 2, id ]

        -- What's on the other side of an edge of something labelled `own`: open is [ -1 ]
        across labels own curve =
            Dict.get (curveKey curve) owners
                |> Maybe.withDefault []
                |> List.map (labelOf labels)
                |> List.filter ((/=) own)
                |> List.head
                |> Maybe.withDefault [ -1 ]

        runsWith labels =
            cylinders
                |> List.foldl (\cylinder -> Dict.update cylinder.group (\others -> Just (cylinder :: Maybe.withDefault [] others))) Dict.empty
                |> Dict.values
                |> List.concatMap
                    (\group ->
                        List.sortBy .from group
                            |> List.foldl
                                (\cylinder runs ->
                                    let
                                        sides =
                                            List.map (across labels (labelOf labels cylinder.id)) cylinder.sides
                                    in
                                    case runs of
                                        ( run, runSides ) :: rest ->
                                            case run of
                                                last :: _ ->
                                                    if last.to == cylinder.from && runSides == sides then
                                                        ( cylinder :: run, runSides ) :: rest

                                                    else
                                                        ( [ cylinder ], sides ) :: runs

                                                [] ->
                                                    ( [ cylinder ], sides ) :: rest

                                        [] ->
                                            [ ( [ cylinder ], sides ) ]
                                )
                                []
                            |> List.map (Tuple.first >> List.reverse)
                    )

        settle labels count =
            let
                runs =
                    runsWith labels

                newLabels =
                    List.concatMap
                        (\run ->
                            case run of
                                first :: _ ->
                                    List.map (\cylinder -> ( cylinder.id, 1 :: cylinder.group ++ [ first.from ] )) run

                                [] ->
                                    []
                        )
                        runs
                        |> List.foldl (\( id, label ) -> Dict.insert id label) labels
            in
            if newLabels == labels || count <= 0 then
                ( labels, runs )

            else
                settle newLabels (count - 1)

        ( finalLabels, finalRuns ) =
            settle initialLabels 20

        otherRound =
            List.filterMap
                (\( id, cell ) ->
                    case ( cell, Dict.get id finalLabels ) of
                        ( RoundCell revolution, Nothing ) ->
                            Just revolution

                        _ ->
                            Nothing
                )
                indexed
    in
    Surface.buildOpen
        (List.indexedMap
            (\index component ->
                loops component.boundary
                    |> List.map (mergeAlong (across finalLabels [ 0, index ]))
                    |> flatSpec component.normal
            )
            components
        )
        (List.map featureSpec (List.filterMap mergeRun finalRuns ++ otherRound))


{-| A cell that's part of a cylinder, with the cylinder's axis, which quarter it is and which way it
faces (its `group`), how far along its axis it goes, and its sides.
-}
type alias Cylinder =
    { id : Int, revolution : Revolution, group : List Int, from : Int, to : Int, sides : List Curve }


cylinderOf : Int -> Cell -> Maybe Cylinder
cylinderOf id cell =
    case cell of
        RoundCell revolution ->
            case revolution.profile of
                ProfileLine ( r0, z0 ) ( r1, z1 ) ->
                    if r0 == r1 && r0 > 0 then
                        let
                            along =
                                vdot revolution.center revolution.axis

                            onAxis =
                                vsub revolution.center (vscale along revolution.axis)
                        in
                        Just
                            { id = id
                            , revolution = { revolution | center = onAxis }
                            , group = vkey onAxis ++ vkey revolution.axis ++ vkey revolution.x ++ [ r0, sign (z1 - z0) ]
                            , from = along + min z0 z1
                            , to = along + max z0 z1
                            , sides = revolutionEdges revolution |> List.reverse |> List.take 2 |> List.map .curve
                            }

                    else
                        Nothing

                ProfileArc _ ->
                    Nothing

        FlatCell _ ->
            Nothing


{-| One cylinder for a row of cells of it.
-}
mergeRun : List Cylinder -> Maybe Revolution
mergeRun run =
    case ( run, List.reverse run ) of
        ( first :: _, last :: _ ) ->
            case first.revolution.profile of
                ProfileLine ( r, z0 ) ( _, z1 ) ->
                    let
                        revolution =
                            first.revolution
                    in
                    Just
                        { revolution
                            | profile =
                                if z1 > z0 then
                                    ProfileLine ( r, first.from ) ( r, last.to )

                                else
                                    ProfileLine ( r, last.to ) ( r, first.from )
                        }

                ProfileArc _ ->
                    Nothing

        _ ->
            Nothing


{-| A loop with the straight edges in a line joined, as long as what's on the other side of them is
the same.
-}
mergeAlong : (Curve -> List Int) -> List Curve -> List Curve
mergeAlong otherSide loop =
    let
        inLine a b =
            case ( a, b ) of
                ( Segment a0 a1, Segment b0 b1 ) ->
                    a1 == b0 && unitOf (vsub a1 a0) == unitOf (vsub b1 b0)

                _ ->
                    False

        joins a b =
            inLine a b && otherSide a == otherSide b

        -- Start where two edges don't join, so a line isn't split where the loop starts
        rotated =
            case
                List.map2 Tuple.pair (List.drop (List.length loop - 1) loop ++ List.take (List.length loop - 1) loop) loop
                    |> List.indexedMap Tuple.pair
                    |> List.filter (\( _, ( previous, curve ) ) -> not (joins previous curve))
                    |> List.head
            of
                Just ( index, _ ) ->
                    List.drop index loop ++ List.take index loop

                Nothing ->
                    loop
    in
    -- Each edge so far with what's on the other side of the unit edges it was joined from
    List.foldl
        (\curve acc ->
            case acc of
                ( Segment a0 a1, side ) :: rest ->
                    if inLine (Segment a0 a1) curve && side == otherSide curve then
                        case curve of
                            Segment _ b1 ->
                                ( Segment a0 b1, side ) :: rest

                            Arc _ ->
                                ( curve, otherSide curve ) :: acc

                    else
                        ( curve, otherSide curve ) :: acc

                _ ->
                    ( curve, otherSide curve ) :: acc
        )
        []
        rotated
        |> List.map Tuple.first
        |> List.reverse


{-| Flat cells in a plane, facing the same way, in groups that are joined up, each with the edges
round the outside of the group.
-}
flatComponents : List ( Int, { normal : IVec, loop : List Curve } ) -> List { normal : IVec, members : List Int, boundary : List Curve }
flatComponents flats =
    case flats of
        [] ->
            []

        ( _, first ) :: _ ->
            let
                normal =
                    first.normal

                cellsAlong : Dict (List Int) (List Int)
                cellsAlong =
                    List.foldl
                        (\( index, flat ) acc ->
                            List.foldl
                                (\curve -> Dict.update (curveKey curve) (\others -> Just (index :: Maybe.withDefault [] others)))
                                acc
                                flat.loop
                        )
                        Dict.empty
                        flats

                neighbours flat =
                    List.concatMap (\curve -> Dict.get (curveKey curve) cellsAlong |> Maybe.withDefault []) flat.loop

                flatArray =
                    Dict.fromList flats

                group : List Int -> Dict Int () -> List Int -> ( List Int, Dict Int () )
                group queue seen acc =
                    case queue of
                        index :: rest ->
                            if Dict.member index seen then
                                group rest seen acc

                            else
                                group
                                    ((Dict.get index flatArray |> Maybe.map neighbours |> Maybe.withDefault []) ++ rest)
                                    (Dict.insert index () seen)
                                    (index :: acc)

                        [] ->
                            ( acc, seen )

                groups : List Int -> Dict Int () -> List (List Int) -> List (List Int)
                groups remaining seen acc =
                    case remaining of
                        index :: rest ->
                            if Dict.member index seen then
                                groups rest seen acc

                            else
                                let
                                    ( members, newSeen ) =
                                        group [ index ] seen []
                                in
                                groups rest newSeen (members :: acc)

                        [] ->
                            acc

                boundary members =
                    members
                        |> List.filterMap (\index -> Dict.get index flatArray)
                        |> List.concatMap .loop
                        |> List.filter (\curve -> Dict.get (curveKey curve) cellsAlong |> Maybe.map List.length |> (==) (Just 1))
            in
            groups (List.map Tuple.first flats) Dict.empty []
                |> List.map (\members -> { normal = normal, members = members, boundary = boundary members })


{-| Edges joined up end to start into loops.
-}
loops : List Curve -> List (List Curve)
loops curves =
    let
        byStart =
            List.foldl
                (\curve -> Dict.update (vkey (curveStart curve)) (\others -> Just (curve :: Maybe.withDefault [] others)))
                Dict.empty
                curves

        take point dict =
            case Dict.get (vkey point) dict of
                Just (curve :: rest) ->
                    Just
                        ( curve
                        , if List.isEmpty rest then
                            Dict.remove (vkey point) dict

                          else
                            Dict.insert (vkey point) rest dict
                        )

                _ ->
                    Nothing

        follow loopStart dict acc =
            case acc of
                last :: _ ->
                    if curveEnd last == loopStart then
                        ( List.reverse acc, dict )

                    else
                        case take (curveEnd last) dict of
                            Just ( next, rest ) ->
                                follow loopStart rest (next :: acc)

                            Nothing ->
                                ( List.reverse acc, dict )

                [] ->
                    ( [], dict )

        all dict acc =
            case Dict.values dict |> List.concat |> List.head of
                Just curve ->
                    case take (curveStart curve) dict of
                        Just ( first, rest ) ->
                            let
                                ( loop, remaining ) =
                                    follow (curveStart first) rest [ first ]
                            in
                            all remaining (loop :: acc)

                        Nothing ->
                            acc

                Nothing ->
                    acc
    in
    all byStart []


meters : IVec -> Point3d Meters coordinates
meters v =
    Point3d.meters (toFloat v.x * cellSize) (toFloat v.y * cellSize) (toFloat v.z * cellSize)


direction : IVec -> Direction3d coordinates
direction v =
    Direction3d.unsafe { x = toFloat v.x, y = toFloat v.y, z = toFloat v.z }


flatSpec : IVec -> List (List Curve) -> FlatSpec coordinates
flatSpec normal boundary =
    let
        ( u, v ) =
            planeAxes normal

        offset =
            List.head boundary |> Maybe.andThen List.head |> Maybe.map (curveStart >> vdot normal) |> Maybe.withDefault 0

        origin =
            vscale offset normal

        inPlane p =
            Point2d.meters (toFloat (vdot (vsub p origin) u) * cellSize) (toFloat (vdot (vsub p origin) v) * cellSize)

        edge curve =
            case curve of
                Segment a _ ->
                    Surface.Straight (inPlane a)

                Arc arc ->
                    Surface.Arc
                        { start = inPlane (curveStart curve)
                        , center = inPlane arc.center
                        , sweptAngle =
                            if vcross arc.from arc.to == normal then
                                Angle.degrees 90

                            else
                                Angle.degrees -90
                        }
    in
    { plane =
        SketchPlane3d.unsafe
            { originPoint = meters origin
            , xDirection = direction u
            , yDirection = direction v
            }
    , boundary = List.map (List.map edge) boundary
    }


featureSpec : Revolution -> FeatureSpec coordinates
featureSpec revolution =
    let
        inHalfPlane ( rho, h ) =
            Point2d.meters (toFloat rho * cellSize) (toFloat h * cellSize)
    in
    { frame =
        Frame3d.unsafe
            { originPoint = meters revolution.center
            , xDirection = direction revolution.x
            , yDirection = direction (vcross revolution.axis revolution.x)
            , zDirection = direction revolution.axis
            }
    , profile =
        case revolution.profile of
            ProfileLine p q ->
                { start = inHalfPlane p, segments = [ Line { end = inHalfPlane q } ] }

            ProfileArc { from, to, center } ->
                { start = inHalfPlane from, segments = [ Circle { end = inHalfPlane to, center = inHalfPlane center } ] }
    , sweep = PartTurn { from = Angle.degrees 0, to = Angle.degrees 90 }
    }



---- SAVING ----


encode : Level -> Encode.Value
encode level =
    let
        ints =
            Encode.list Encode.int

        curve c =
            case c of
                Segment a b ->
                    ints (vkey a ++ vkey b)

                Arc arc ->
                    ints (vkey arc.center ++ [ arc.radius ] ++ vkey arc.from ++ vkey arc.to)

        pair ( a, b ) =
            [ a, b ]

        cell c =
            case c of
                FlatCell { normal, loop } ->
                    Encode.object [ ( "normal", ints (vkey normal) ), ( "loop", Encode.list curve loop ) ]

                RoundCell revolution ->
                    Encode.object
                        [ ( "center", ints (vkey revolution.center) )
                        , ( "axis", ints (vkey revolution.axis) )
                        , ( "x", ints (vkey revolution.x) )
                        , ( "profile"
                          , case revolution.profile of
                                ProfileLine p q ->
                                    ints (pair p ++ pair q)

                                ProfileArc { from, to, center } ->
                                    ints (pair from ++ pair to ++ pair center)
                          )
                        ]
    in
    Encode.object [ ( "cells", Encode.list cell level.cells ) ]


decoder : Decoder Level
decoder =
    let
        toIVec list =
            case list of
                [ x, y, z ] ->
                    Decode.succeed (ivec x y z)

                _ ->
                    Decode.fail "Expected 3 numbers"

        ivecDecoder =
            Decode.list Decode.int |> Decode.andThen toIVec

        curve =
            Decode.list Decode.int
                |> Decode.andThen
                    (\list ->
                        case list of
                            [ ax, ay, az, bx, by, bz ] ->
                                Decode.succeed (Segment (ivec ax ay az) (ivec bx by bz))

                            [ cx, cy, cz, r, fx, fy, fz, tx, ty, tz ] ->
                                Decode.succeed (Arc { center = ivec cx cy cz, radius = r, from = ivec fx fy fz, to = ivec tx ty tz })

                            _ ->
                                Decode.fail "Not an edge"
                    )

        profile =
            Decode.list Decode.int
                |> Decode.andThen
                    (\list ->
                        case list of
                            [ a, b, c, d ] ->
                                Decode.succeed (ProfileLine ( a, b ) ( c, d ))

                            [ a, b, c, d, e, f ] ->
                                Decode.succeed (ProfileArc { from = ( a, b ), to = ( c, d ), center = ( e, f ) })

                            _ ->
                                Decode.fail "Not a profile"
                    )

        cell =
            Decode.oneOf
                [ Decode.map2 (\normal loop -> FlatCell { normal = normal, loop = loop })
                    (Decode.field "normal" ivecDecoder)
                    (Decode.field "loop" (Decode.list curve))
                , Decode.map4 (\center axis x p -> RoundCell { center = center, axis = axis, x = x, profile = p })
                    (Decode.field "center" ivecDecoder)
                    (Decode.field "axis" ivecDecoder)
                    (Decode.field "x" ivecDecoder)
                    (Decode.field "profile" profile)
                ]
    in
    Decode.map (\cells -> { cells = cells }) (Decode.field "cells" (Decode.list cell))
