module Underground exposing
    ( contains
    , deep
    , encodeLight
    , entrance
    , features
    , flats
    , light
    , mapPavings
    , mapWalls
    , soilColor
    , tessellationStep
    )

{-| Rooms and round tunnels hidden inside the slab. The only way in is a round hole in the top face
(`entrance`), which drops straight down into the first room's ceiling.

It's made the same way as the rest of the world (see `World`): each room is a box with rounded
edges and corners like the slab, but turned inside out, so its walls, floor and ceiling face into
it. The tunnels are round pipes, rounded out onto the walls of the rooms they join like the big hole
is onto the top and bottom, and they can bend (a quarter of a torus). As everywhere else on the
surface, the player can walk all the way round a tunnel and up a room's walls onto its ceiling.

Everything is kept gently curved, as on tight curves the camera swings about and walking gets jumpy.
That's why the rooms are big and the slab is thicker than it used to be.

Pieces only join along whole edges, so a tunnel is made of two halves, split along its top and
bottom: that's where a bend's two halves (the inner and outer side of the torus) meet too, and the
openings in the walls are two half circles.

Sunlight comes in at the entrance and dies away the further you walk from it (`light`), so the
first room is dim and the rest are dark, apart from what the player's own glow lights up (see
`View`). Finding the way is left to the minimap, which shows the floors and the floor of each tunnel
(`mapWalls`, `mapPavings`).

-}

import Angle
import Dict exposing (Dict)
import Direction3d exposing (Direction3d)
import Frame3d
import Length exposing (Meters)
import Math.Vector3 as Vec3 exposing (Vec3)
import Point2d
import Point3d exposing (Point3d)
import SketchPlane3d
import Surface exposing (FeatureSpec, FlatEdge(..), FlatSpec, ProfileSegment(..), Sweep(..))
import Vector2d


type alias Vec =
    { x : Float, y : Float, z : Float }


type alias Flat2 =
    { x : Float, z : Float }



---- SIZES ----


{-| Where the top face of the slab is (see `World`).
-}
groundLevel : Float
groundLevel =
    0.598373


{-| The rooms' floors and ceilings. The slab's bottom is at -1.25, so this leaves 20 cm of earth
under the floors and 45 cm over the ceilings, for the shaft down from the entrance.
-}
floorLevel : Float
floorLevel =
    -1.05


ceilingLevel : Float
ceilingLevel =
    floorLevel + 1.2


{-| How round the inside edges and corners of the rooms are.
-}
roomFillet : Float
roomFillet =
    0.15


{-| How wide the tunnels are inside, and how round their ends are where they open onto a room. The
opening (radius plus fillet) has to fit on a wall between its fillets, which is why the rooms are
so big.
-}
tunnelRadius : Float
tunnelRadius =
    0.18


tunnelFillet : Float
tunnelFillet =
    0.25


tunnelRim : Float
tunnelRim =
    tunnelRadius + tunnelFillet


{-| How far a tunnel's middle line is from the axis it turns round where it bends.
-}
bendRadius : Float
bendRadius =
    0.3


{-| The tunnels go through the middle of the walls.
-}
tunnelLevel : Float
tunnelLevel =
    (floorLevel + ceilingLevel) / 2


shaftRadius : Float
shaftRadius =
    0.15


shaftFillet : Float
shaftFillet =
    0.2



---- THE LAYOUT ----


type alias Room =
    { name : String
    , center : Flat2

    -- How wide the room is along x and z
    , width : Float
    , depth : Float
    }


{-| The rooms, seen from above with x to the right and z up:

    A ---------- F ~~~~
    |            |     ~~ D
     ~~          |        |
       |         |        |
       B ------- C ------ E

A is under the entrance, E is the bigger room at the end, and the tunnels drawn with ~ bend twice.
They go round the big hole, which is between C, F and D.

-}
rooms : List Room
rooms =
    [ { name = "A", center = { x = -2.4, z = 1.0 }, width = 1.2, depth = 1.2 }
    , { name = "B", center = { x = -1.8, z = -1.5 }, width = 1.2, depth = 1.2 }
    , { name = "C", center = { x = 0, z = -1.5 }, width = 1.2, depth = 1.2 }
    , { name = "F", center = { x = 0, z = 1.0 }, width = 1.2, depth = 1.2 }
    , { name = "D", center = { x = 3.3, z = 0.3 }, width = 1.2, depth = 1.2 }
    , { name = "E", center = { x = 3.3, z = -1.5 }, width = 1.4, depth = 1.2 }
    ]


{-| The room the shaft from the entrance comes down into.
-}
firstRoom : String
firstRoom =
    "A"


type Side
    = East
    | West
    | North
    | South


{-| A tunnel from the middle of one side of a room to the middle of a side of another, through
`corners`, where it bends a quarter turn. Each stretch between them goes along x or z, and is long
enough for the bends and the rounded ends.
-}
type alias TunnelSpec =
    { from : ( String, Side ), to : ( String, Side ), corners : List Flat2 }


tunnelSpecs : List TunnelSpec
tunnelSpecs =
    [ { from = ( "A", East ), to = ( "F", West ), corners = [] }
    , { from = ( "A", South ), to = ( "B", North ), corners = [ { x = -2.4, z = -0.26 }, { x = -1.8, z = -0.26 } ] }
    , { from = ( "B", East ), to = ( "C", West ), corners = [] }
    , { from = ( "F", South ), to = ( "C", North ), corners = [] }
    , { from = ( "F", East ), to = ( "D", West ), corners = [ { x = 1.9, z = 1.0 }, { x = 1.9, z = 0.3 } ] }
    , { from = ( "D", South ), to = ( "E", North ), corners = [] }
    , { from = ( "C", East ), to = ( "E", West ), corners = [] }
    ]


roomNamed : String -> Maybe Room
roomNamed name =
    List.filter (\room -> room.name == name) rooms |> List.head


type alias Box =
    { min : Vec, max : Vec }


roomBox : Room -> Box
roomBox room =
    { min = { x = room.center.x - room.width / 2, y = floorLevel, z = room.center.z - room.depth / 2 }
    , max = { x = room.center.x + room.width / 2, y = ceilingLevel, z = room.center.z + room.depth / 2 }
    }


{-| Where a side's middle is, and which way is out of the room through it.
-}
sideOf : Room -> Side -> { point : Flat2, out : Flat2 }
sideOf room side =
    case side of
        East ->
            { point = { x = room.center.x + room.width / 2, z = room.center.z }, out = { x = 1, z = 0 } }

        West ->
            { point = { x = room.center.x - room.width / 2, z = room.center.z }, out = { x = -1, z = 0 } }

        North ->
            { point = { x = room.center.x, z = room.center.z + room.depth / 2 }, out = { x = 0, z = 1 } }

        South ->
            { point = { x = room.center.x, z = room.center.z - room.depth / 2 }, out = { x = 0, z = -1 } }


{-| A tunnel worked out: the rooms at its ends, and its middle line from the wall of the first to the
wall of the second, through its corners.
-}
type alias Tunnel =
    { from : Room
    , fromSide : Side
    , to : Room
    , toSide : Side
    , points : List Flat2
    }


allTunnels : List Tunnel
allTunnels =
    tunnelSpecs
        |> List.filterMap
            (\spec ->
                Maybe.map2
                    (\from to ->
                        { from = from
                        , fromSide = Tuple.second spec.from
                        , to = to
                        , toSide = Tuple.second spec.to
                        , points = (sideOf from (Tuple.second spec.from)).point :: spec.corners ++ [ (sideOf to (Tuple.second spec.to)).point ]
                        }
                    )
                    (roomNamed (Tuple.first spec.from))
                    (roomNamed (Tuple.first spec.to))
            )


{-| Where the entrance is on the top face, and how far out its rim is.
-}
entrance : { x : Float, z : Float, rim : Float }
entrance =
    let
        center =
            roomNamed firstRoom |> Maybe.map .center |> Maybe.withDefault { x = 0, z = 0 }
    in
    { x = center.x, z = center.z, rim = shaftRadius + shaftFillet }



---- 2D AND 3D HELPERS ----


sub2 : Flat2 -> Flat2 -> Flat2
sub2 a b =
    { x = a.x - b.x, z = a.z - b.z }


add2 : Flat2 -> Flat2 -> Flat2
add2 a b =
    { x = a.x + b.x, z = a.z + b.z }


scale2 : Float -> Flat2 -> Flat2
scale2 k a =
    { x = k * a.x, z = k * a.z }


length2 : Flat2 -> Float
length2 a =
    sqrt (a.x * a.x + a.z * a.z)


normalize2 : Flat2 -> Flat2
normalize2 a =
    let
        l =
            length2 a
    in
    if l > 0 then
        scale2 (1 / l) a

    else
        a


{-| A horizontal direction, from x and z.
-}
horizontal : Flat2 -> Direction3d coordinates
horizontal d =
    Direction3d.unsafe { x = d.x, y = 0, z = d.z }


{-| A tunnel's middle line as straight stretches and bends: each stretch is cut short by the bend
radius at the corners, and each bend turns from one stretch's direction to the next's.
-}
type alias Stretch =
    { start : Flat2, end : Flat2, roundedStart : Bool, roundedEnd : Bool }


type alias Bend =
    { corner : Flat2, incoming : Flat2, outgoing : Flat2 }


stretchesAndBends : Tunnel -> { stretches : List Stretch, bends : List Bend }
stretchesAndBends tunnel =
    let
        points =
            tunnel.points

        legs =
            List.map2 Tuple.pair points (List.drop 1 points)

        legCount =
            List.length legs

        directions =
            List.map (\( a, b ) -> normalize2 (sub2 b a)) legs

        stretches =
            List.indexedMap
                (\i ( ( a, b ), d ) ->
                    { start =
                        if i == 0 then
                            a

                        else
                            add2 a (scale2 bendRadius d)
                    , end =
                        if i == legCount - 1 then
                            b

                        else
                            sub2 b (scale2 bendRadius d)
                    , roundedStart = i == 0
                    , roundedEnd = i == legCount - 1
                    }
                )
                (List.map2 Tuple.pair legs directions)

        bends =
            List.map3 (\corner incoming outgoing -> { corner = corner, incoming = incoming, outgoing = outgoing })
                (List.drop 1 points |> List.take (legCount - 1))
                directions
                (List.drop 1 directions)
    in
    { stretches = stretches, bends = bends }



---- PIECES ----


type Axis
    = X
    | Y
    | Z


get : Axis -> Vec -> Float
get axis v =
    case axis of
        X ->
            v.x

        Y ->
            v.y

        Z ->
            v.z


unit : Axis -> Float -> Direction3d coordinates
unit axis sign =
    case axis of
        X ->
            Direction3d.unsafe { x = sign, y = 0, z = 0 }

        Y ->
            Direction3d.unsafe { x = 0, y = sign, z = 0 }

        Z ->
            Direction3d.unsafe { x = 0, y = 0, z = sign }


{-| The two other axes in an order that makes a right handed frame with `axis`.
-}
otherAxes : Axis -> ( Axis, Axis )
otherAxes axis =
    case axis of
        X ->
            ( Y, Z )

        Y ->
            ( Z, X )

        Z ->
            ( X, Y )


pointFrom : List ( Axis, Float ) -> Point3d Meters coordinates
pointFrom coordinates =
    let
        coordinate axis =
            coordinates |> List.filter (\( a, _ ) -> a == axis) |> List.head |> Maybe.map Tuple.second |> Maybe.withDefault 0
    in
    Point3d.meters (coordinate X) (coordinate Y) (coordinate Z)


{-| A box's side on `sign`'s end of `axis`, and the box shrunk by the fillet radius.
-}
outer : Box -> Axis -> Float -> Float
outer box axis sign =
    if sign > 0 then
        get axis box.max

    else
        get axis box.min


inner : Box -> Axis -> Float -> Float
inner box axis sign =
    outer box axis sign - sign * roomFillet


sideAxis : Side -> ( Axis, Float )
sideAxis side =
    case side of
        East ->
            ( X, 1 )

        West ->
            ( X, -1 )

        North ->
            ( Z, 1 )

        South ->
            ( Z, -1 )


{-| Round holes in a room's walls or ceiling: on which side, where (in world coordinates), how big,
and whether it's two half circles (for a tunnel) or one whole one (for the shaft).
-}
type alias Opening =
    { axis : Axis, sign : Float, center : Vec, radius : Float, halves : Bool }


openingsOf : Room -> List Opening
openingsOf room =
    let
        box =
            roomBox room

        opening side =
            let
                ( axis, sign ) =
                    sideAxis side

                point =
                    (sideOf room side).point
            in
            { axis = axis, sign = sign, center = { x = point.x, y = tunnelLevel, z = point.z }, radius = tunnelRim, halves = True }

        tunnelOpenings =
            allTunnels
                |> List.concatMap
                    (\tunnel ->
                        (if tunnel.from.name == room.name then
                            [ opening tunnel.fromSide ]

                         else
                            []
                        )
                            ++ (if tunnel.to.name == room.name then
                                    [ opening tunnel.toSide ]

                                else
                                    []
                               )
                    )

        shaftOpening =
            if room.name == firstRoom then
                [ { axis = Y, sign = 1, center = { x = entrance.x, y = box.max.y, z = entrance.z }, radius = entrance.rim, halves = False } ]

            else
                []
    in
    tunnelOpenings ++ shaftOpening


{-| One side of a room, facing into it, with the room's openings on that side cut out.
-}
roomFace : Room -> Axis -> Float -> FlatSpec coordinates
roomFace room axis sign =
    let
        box =
            roomBox room

        -- So that a cross b points into the room, against `sign`
        ( a, b ) =
            if sign > 0 then
                otherAxes axis |> (\( first, second ) -> ( second, first ))

            else
                otherAxes axis

        rectangle =
            [ ( -1, -1 ), ( 1, -1 ), ( 1, 1 ), ( -1, 1 ) ]
                |> List.map (\( sa, sb ) -> Point2d.meters (inner box a sa) (inner box b sb) |> Straight)

        holes =
            openingsOf room
                |> List.filter (\opening -> opening.axis == axis && opening.sign == sign)
                |> List.map
                    (\opening ->
                        let
                            center =
                                Point2d.meters (get a opening.center) (get b opening.center)

                            -- Which way is up in the sketch plane
                            up =
                                if a == Y then
                                    Vector2d.meters opening.radius 0

                                else
                                    Vector2d.meters 0 opening.radius
                        in
                        -- Clockwise, so the flat is on its left
                        if opening.halves then
                            -- From the top round to the bottom, then back up, where the halves of
                            -- the tunnel meet
                            [ Arc { start = center |> Point2d.translateBy up, center = center, sweptAngle = Angle.degrees -180 }
                            , Arc { start = center |> Point2d.translateBy (Vector2d.reverse up), center = center, sweptAngle = Angle.degrees -180 }
                            ]

                        else
                            [ Arc
                                { start = center |> Point2d.translateBy (Vector2d.meters opening.radius 0)
                                , center = center
                                , sweptAngle = Angle.degrees -360
                                }
                            ]
                    )
    in
    { plane =
        SketchPlane3d.unsafe
            { originPoint = pointFrom [ ( axis, outer box axis sign ) ]
            , xDirection = unit a 1
            , yDirection = unit b 1
            }
    , boundary = rectangle :: holes
    }


{-| A quarter cylinder along a room's edge parallel to `along`, curving from one side to the other.
Like the slab's (see `World`), but its profile runs the other way so it faces in towards its axis.
-}
roomEdge : Room -> Axis -> Float -> Float -> FeatureSpec coordinates
roomEdge room along signA signB =
    let
        box =
            roomBox room

        ( a, b ) =
            otherAxes along

        zSign =
            signA * signB
    in
    { frame =
        Frame3d.unsafe
            { originPoint = pointFrom [ ( a, inner box a signA ), ( b, inner box b signB ) ]
            , xDirection = unit a signA
            , yDirection = unit b signB
            , zDirection = unit along zSign
            }
    , profile =
        { start = Point2d.meters roomFillet (zSign * inner box along zSign)
        , segments = [ Line { end = Point2d.meters roomFillet (zSign * inner box along -zSign) } ]
        }
    , sweep = PartTurn { from = Angle.degrees 0, to = Angle.degrees 90 }
    }


{-| An eighth of a sphere in a room's corner, facing in towards its centre: its profile runs from
the pole down to the equator.
-}
roomCorner : Room -> Float -> Float -> Float -> FeatureSpec coordinates
roomCorner room signX signY signZ =
    let
        box =
            roomBox room

        ( xDirection, yDirection ) =
            if signX * signY * signZ < 0 then
                ( unit X signX, unit Z signZ )

            else
                ( unit Z signZ, unit X signX )
    in
    { frame =
        Frame3d.unsafe
            { originPoint = pointFrom [ ( X, inner box X signX ), ( Y, inner box Y signY ), ( Z, inner box Z signZ ) ]
            , xDirection = xDirection
            , yDirection = yDirection
            , zDirection = unit Y signY
            }
    , profile =
        { start = Point2d.meters 0 roomFillet
        , segments = [ Circle { end = Point2d.meters roomFillet 0, center = Point2d.origin } ]
        }
    , sweep = PartTurn { from = Angle.degrees 0, to = Angle.degrees 90 }
    }


{-| A straight stretch of tunnel, as its two halves. Its frame's z axis points back along it, so its
start faces the way the wall of the room it starts at does (like the big hole's top, see `World`),
and its x axis points up, so the halves split along its top and bottom.
-}
stretchPieces : Stretch -> List (FeatureSpec coordinates)
stretchPieces stretch =
    let
        along =
            sub2 stretch.end stretch.start

        length =
            length2 along

        back =
            normalize2 along |> scale2 -1

        -- z cross x, so that x cross y = z
        side =
            { x = -back.z, z = back.x }

        frame =
            Frame3d.unsafe
                { originPoint = Point3d.meters stretch.start.x tunnelLevel stretch.start.z
                , xDirection = Direction3d.y
                , yDirection = horizontal side
                , zDirection = horizontal back
                }

        r =
            tunnelRadius

        f =
            tunnelFillet

        ( start, startSegments ) =
            if stretch.roundedStart then
                ( Point2d.meters tunnelRim 0, [ Circle { end = Point2d.meters r -f, center = Point2d.meters tunnelRim -f } ] )

            else
                ( Point2d.meters r 0, [] )

        endSegments =
            if stretch.roundedEnd then
                [ Line { end = Point2d.meters r (-length + f) }
                , Circle { end = Point2d.meters tunnelRim -length, center = Point2d.meters tunnelRim (-length + f) }
                ]

            else
                [ Line { end = Point2d.meters r -length } ]

        half from to =
            { frame = frame
            , profile = { start = start, segments = startSegments ++ endSegments }
            , sweep = PartTurn { from = Angle.degrees from, to = Angle.degrees to }
            }
    in
    [ half 0 180, half 180 360 ]


{-| A bend, as the inner and outer halves of a quarter of a torus round a vertical axis. The bend's
frame's x axis points from that axis to where the bend starts and its y axis to where it ends, so
it sweeps from 0 to 90 degrees. Its profile goes clockwise round the tunnel's middle line, so the
tunnel's inside is on its right and the surface faces into it.
-}
bendPieces : Bend -> List (FeatureSpec coordinates)
bendPieces bend =
    let
        -- Where the axis is: in from the corner on the inside of the turn
        axis =
            add2 bend.corner (scale2 bendRadius (sub2 bend.outgoing bend.incoming))

        x =
            scale2 -1 bend.outgoing

        y =
            bend.incoming

        -- x cross y is up or down
        upSign =
            if x.z * y.x - x.x * y.z > 0 then
                1

            else
                -1

        frame =
            Frame3d.unsafe
                { originPoint = Point3d.meters axis.x 0 axis.z
                , xDirection = horizontal x
                , yDirection = horizontal y
                , zDirection = Direction3d.unsafe { x = 0, y = upSign, z = 0 }
                }

        h =
            upSign * tunnelLevel

        rr =
            bendRadius

        r =
            tunnelRadius

        center =
            Point2d.meters rr h

        quarterTurn =
            PartTurn { from = Angle.degrees 0, to = Angle.degrees 90 }
    in
    [ -- Over the top, round the outside and down to the bottom
      { frame = frame
      , profile =
            { start = Point2d.meters rr (h + r)
            , segments =
                [ Circle { end = Point2d.meters (rr + r) h, center = center }
                , Circle { end = Point2d.meters rr (h - r), center = center }
                ]
            }
      , sweep = quarterTurn
      }
    , -- And back up round the inside
      { frame = frame
      , profile =
            { start = Point2d.meters rr (h - r)
            , segments =
                [ Circle { end = Point2d.meters (rr - r) h, center = center }
                , Circle { end = Point2d.meters rr (h + r), center = center }
                ]
            }
      , sweep = quarterTurn
      }
    ]


tunnelPieces : Tunnel -> List (FeatureSpec coordinates)
tunnelPieces tunnel =
    let
        { stretches, bends } =
            stretchesAndBends tunnel
    in
    (stretches
        |> List.filter (\stretch -> length2 (sub2 stretch.end stretch.start) > 1.0e-6)
        |> List.concatMap stretchPieces
    )
        ++ List.concatMap bendPieces bends


{-| The shaft from the entrance on the top face down into the first room's ceiling: a round pipe
rounded out onto both, like the big hole (see `World`).
-}
shaft : FeatureSpec coordinates
shaft =
    let
        top =
            groundLevel

        bottom =
            ceilingLevel

        rim =
            entrance.rim
    in
    { frame =
        Frame3d.unsafe
            { originPoint = Point3d.meters entrance.x 0 entrance.z
            , xDirection = Direction3d.z
            , yDirection = Direction3d.x
            , zDirection = Direction3d.y
            }
    , profile =
        { start = Point2d.meters rim top
        , segments =
            [ Circle { end = Point2d.meters shaftRadius (top - shaftFillet), center = Point2d.meters rim (top - shaftFillet) }
            , Line { end = Point2d.meters shaftRadius (bottom + shaftFillet) }
            , Circle { end = Point2d.meters rim bottom, center = Point2d.meters rim (bottom + shaftFillet) }
            ]
        }
    , sweep = FullTurn
    }


signs : List Float
signs =
    [ -1, 1 ]


flats : List (FlatSpec coordinates)
flats =
    rooms |> List.concatMap (\room -> [ X, Y, Z ] |> List.concatMap (\axis -> List.map (roomFace room axis) signs))


features : List (FeatureSpec coordinates)
features =
    shaft
        :: List.concatMap tunnelPieces allTunnels
        ++ (rooms
                |> List.concatMap
                    (\room ->
                        ([ X, Y, Z ] |> List.concatMap (\along -> signs |> List.concatMap (\signA -> List.map (roomEdge room along signA) signs)))
                            ++ (signs |> List.concatMap (\signX -> signs |> List.concatMap (\signY -> List.map (roomCorner room signX signY) signs)))
                    )
           )



---- LIGHT ----


{-| How long a tunnel's middle line is, from wall to wall, going round the corners.
-}
polylineLength : List Flat2 -> Float
polylineLength points =
    List.map2 (\a b -> length2 (sub2 b a)) points (List.drop 1 points) |> List.sum


{-| How far it is to walk from one room's middle to the other's through a tunnel.
-}
tunnelLength : Tunnel -> Float
tunnelLength tunnel =
    tunnel.from.width / 2 + polylineLength tunnel.points + tunnel.to.width / 2


{-| How far it is to walk from the entrance to the middle of each room, going through the middles
of the rooms on the way.
-}
roomDistances : Dict String Float
roomDistances =
    let
        links =
            allTunnels
                |> List.concatMap
                    (\tunnel ->
                        let
                            length =
                                tunnelLength tunnel
                        in
                        [ ( tunnel.from.name, ( tunnel.to.name, length ) ), ( tunnel.to.name, ( tunnel.from.name, length ) ) ]
                    )

        relax distances =
            List.foldl
                (\( from, ( to, length ) ) acc ->
                    case Dict.get from acc of
                        Just d ->
                            case Dict.get to acc of
                                Just existing ->
                                    if d + length < existing then
                                        Dict.insert to (d + length) acc

                                    else
                                        acc

                                Nothing ->
                                    Dict.insert to (d + length) acc

                        Nothing ->
                            acc
                )
                distances
                links

        -- Down the shaft, then to the middle of the room
        start =
            Dict.singleton firstRoom (groundLevel - tunnelLevel)
    in
    List.foldl (\_ acc -> relax acc) start rooms


{-| A little more than the rooms and tunnels, so points on them are inside for sure.
-}
margin : Float
margin =
    0.02


{-| The nearest point on a line through `points` to `p`: how far it is, and how far along the line.
-}
nearestOnPolyline : List Flat2 -> Flat2 -> { distance : Float, along : Float }
nearestOnPolyline points p =
    List.map2 Tuple.pair points (List.drop 1 points)
        |> List.foldl
            (\( a, b ) ( best, sofar ) ->
                let
                    ab =
                        sub2 b a

                    l =
                        length2 ab

                    t =
                        if l > 0 then
                            clamp 0 1 (((p.x - a.x) * ab.x + (p.z - a.z) * ab.z) / (l * l))

                        else
                            0

                    q =
                        add2 a (scale2 t ab)

                    d =
                        length2 (sub2 p q)

                    candidate =
                        { distance = d, along = sofar + t * l }
                in
                ( if d < best.distance then
                    candidate

                  else
                    best
                , sofar + l
                )
            )
            ( { distance = 1 / 0, along = 0 }, 0 )
        |> Tuple.first


{-| How far a point in a room or tunnel is to walk to from the entrance, or Nothing if it isn't in
one. In a room, it's how far to the middle of the room and from there to the point; in a tunnel,
the shorter of that from either end; in the shaft, how far down it is.
-}
distanceFromEntrance : Vec -> Maybe Float
distanceFromEntrance p =
    let
        flat =
            { x = p.x, z = p.z }

        inRoom =
            rooms
                |> List.filterMap
                    (\room ->
                        let
                            box =
                                roomBox room
                        in
                        if
                            (p.x > box.min.x - margin && p.x < box.max.x + margin)
                                && (p.y > box.min.y - margin && p.y < box.max.y + margin)
                                && (p.z > box.min.z - margin && p.z < box.max.z + margin)
                        then
                            Dict.get room.name roomDistances
                                |> Maybe.map (\d -> d + length2 (sub2 flat room.center) + abs (p.y - tunnelLevel))

                        else
                            Nothing
                    )

        inTunnel =
            allTunnels
                |> List.filterMap
                    (\tunnel ->
                        let
                            nearest =
                                nearestOnPolyline tunnel.points flat

                            across =
                                sqrt (nearest.distance ^ 2 + (p.y - tunnelLevel) ^ 2)

                            length =
                                polylineLength tunnel.points
                        in
                        if across < tunnelRim + margin then
                            Maybe.map2
                                (\dFrom dTo ->
                                    min (dFrom + tunnel.from.width / 2 + nearest.along)
                                        (dTo + tunnel.to.width / 2 + length - nearest.along)
                                )
                                (Dict.get tunnel.from.name roomDistances)
                                (Dict.get tunnel.to.name roomDistances)

                        else
                            Nothing
                    )

        inShaft =
            if
                (p.y > ceilingLevel - margin && p.y < groundLevel - 0.001)
                    && ((p.x - entrance.x) ^ 2 + (p.z - entrance.z) ^ 2 < (entrance.rim + margin) ^ 2)
            then
                [ groundLevel - p.y ]

            else
                []
    in
    List.minimum (inRoom ++ inTunnel ++ inShaft)


contains : Vec -> Bool
contains p =
    distanceFromEntrance p /= Nothing


{-| Whether a point is underground and past the rounded top of the shaft, where the camera starts
looking at the shaft's walls from the side rather than down into it from above the grass.
-}
deep : Vec -> Bool
deep p =
    p.y < groundLevel - shaftFillet && contains p


{-| How much sunlight gets to a point underground, from 1 at the entrance to nothing a couple of
rooms in, or Nothing if the point isn't underground.
-}
light : Vec -> Maybe Float
light p =
    distanceFromEntrance p |> Maybe.map (\d -> e ^ -((d / 2.2) ^ 2))


{-| Meshes only carry a position, normal and color for each corner, so how much sunlight gets to an
underground corner is told to the shaders through the length of its normal (they only use its
direction for anything else): 1 above ground, and from 2 (full sunlight) to 10 (none) underground.
See `View.worldFS`.
-}
encodeLight : Vec -> Vec3 -> Vec3
encodeLight position normal =
    case light position of
        Just sunlight ->
            Vec3.scale (2 + 8 * (1 - sunlight)) (Vec3.normalize normal)

        Nothing ->
            normal


{-| The color of the earth the rooms and tunnels are dug out of, mottled a little from place to
place, darker on the ceilings.
-}
soilColor : Vec -> Vec -> Vec3
soilColor position normal =
    let
        mottle =
            (sin (position.x * 37.1 + position.y * 11.3) * sin (position.z * 29.7 - position.y * 23.9) + sin (position.x * 91.7 - position.z * 83.3) * 0.5) * 0.08

        ceiling =
            if normal.y < -0.5 then
                0.75

            else
                1
    in
    Vec3.vec3 (0.4 + mottle) (0.3 + mottle * 0.8) (0.21 + mottle * 0.5) |> Vec3.scale ceiling



---- DRAWING ----


{-| How finely to split the curves of the piece of surface inside `box` to draw it (see
`Surface.tessellateBy`), given how finely the rest is. The rooms and tunnels are mostly dark, so
they're split more coarsely. All their curves meet only each other, except the shaft
meets the grass round the entrance and the ceiling of the room under it, so those stay fine.
-}
tessellationStep : Float -> { min : Vec, max : Vec } -> Float
tessellationStep fine box =
    let
        center =
            { x = (box.min.x + box.max.x) / 2, y = (box.min.y + box.max.y) / 2, z = (box.min.z + box.max.z) / 2 }

        byEntrance =
            box.min.y > ceilingLevel - 0.001 && abs (center.x - entrance.x) < 0.5 && abs (center.z - entrance.z) < 0.5
    in
    if contains center && not byEntrance then
        max fine (pi / 16)

    else
        fine



---- MINIMAP ----


{-| Lines along the bottom of each tunnel, and round the openings in the rooms' walls, for the
minimap (see `Shapes`).
-}
mapWalls : List (List ( Float, Float, Float ))
mapWalls =
    let
        bottom =
            tunnelLevel - tunnelRadius

        tunnelLines =
            allTunnels
                |> List.map
                    (\tunnel ->
                        let
                            { stretches, bends } =
                                stretchesAndBends tunnel

                            -- Points along the middle line, with arcs round the bends
                            stretchPoints stretch =
                                let
                                    l =
                                        length2 (sub2 stretch.end stretch.start)

                                    count =
                                        max 1 (ceiling (l / 0.03))
                                in
                                List.range 0 count |> List.map (\i -> add2 stretch.start (scale2 (toFloat i / toFloat count) (sub2 stretch.end stretch.start)))

                            bendPoints bend =
                                let
                                    axis =
                                        add2 bend.corner (scale2 bendRadius (sub2 bend.outgoing bend.incoming))
                                in
                                List.range 1 11
                                    |> List.map
                                        (\i ->
                                            let
                                                a =
                                                    pi / 2 * toFloat i / 12
                                            in
                                            add2 axis (add2 (scale2 (-bendRadius * cos a) bend.outgoing) (scale2 (bendRadius * sin a) bend.incoming))
                                        )

                            middle =
                                List.map2 (\stretch bendPoints_ -> stretchPoints stretch ++ bendPoints_)
                                    stretches
                                    (List.map bendPoints bends ++ [ [] ])
                                    |> List.concat

                            distances =
                                List.foldl
                                    (\point ( acc, previous ) ->
                                        case ( acc, previous ) of
                                            ( d :: _, Just q ) ->
                                                ( (d + length2 (sub2 point q)) :: acc, Just point )

                                            _ ->
                                                ( [ 0 ], Just point )
                                    )
                                    ( [], Nothing )
                                    middle
                                    |> Tuple.first
                                    |> List.reverse

                            total =
                                List.maximum distances |> Maybe.withDefault 0

                            -- How far the bottom is from the middle line, rounded out at the ends
                            radiusAt u =
                                let
                                    fromEnd =
                                        min u (total - u)
                                in
                                if fromEnd < tunnelFillet then
                                    tunnelRim - sqrt (max 0 (tunnelFillet ^ 2 - (tunnelFillet - fromEnd) ^ 2))

                                else
                                    tunnelRadius
                        in
                        List.map2 (\point u -> ( point.x, tunnelLevel - radiusAt u, point.z )) middle distances
                    )

        openingLines =
            rooms
                |> List.concatMap
                    (\room ->
                        openingsOf room
                            |> List.map
                                (\opening ->
                                    let
                                        ( a, b ) =
                                            otherAxes opening.axis

                                        point angle =
                                            let
                                                offset axis amount v =
                                                    case axis of
                                                        X ->
                                                            { v | x = v.x + amount }

                                                        Y ->
                                                            { v | y = v.y + amount }

                                                        Z ->
                                                            { v | z = v.z + amount }

                                                q =
                                                    opening.center |> offset a (opening.radius * cos angle) |> offset b (opening.radius * sin angle)
                                            in
                                            ( q.x, q.y, q.z )
                                    in
                                    List.range 0 32 |> List.map (\i -> point (2 * pi * toFloat i / 32))
                                )
                    )
    in
    tunnelLines ++ openingLines


{-| The rooms' floors, filled in on the minimap, in small squares so that each corner can be put on
the map on its own (see `Minimap`).
-}
mapPavings : List { points : List ( Float, Float, Float ), triangles : List ( Int, Int, Int ) }
mapPavings =
    rooms
        |> List.map
            (\room ->
                let
                    box =
                        roomBox room

                    y =
                        floorLevel

                    inset =
                        roomFillet

                    columns =
                        ceiling ((room.width - 2 * inset) / 0.05)

                    rows =
                        ceiling ((room.depth - 2 * inset) / 0.05)

                    index i j =
                        j * (columns + 1) + i
                in
                { points =
                    List.range 0 rows
                        |> List.concatMap
                            (\j ->
                                List.range 0 columns
                                    |> List.map
                                        (\i ->
                                            ( box.min.x + inset + (room.width - 2 * inset) * toFloat i / toFloat columns
                                            , y
                                            , box.min.z + inset + (room.depth - 2 * inset) * toFloat j / toFloat rows
                                            )
                                        )
                            )
                , triangles =
                    List.range 0 (rows - 1)
                        |> List.concatMap
                            (\j ->
                                List.range 0 (columns - 1)
                                    |> List.concatMap
                                        (\i ->
                                            [ ( index i j, index (i + 1) j, index (i + 1) (j + 1) )
                                            , ( index i j, index (i + 1) (j + 1), index i (j + 1) )
                                            ]
                                        )
                            )
                }
            )
