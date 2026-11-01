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

{-| A maze of rooms and round tunnels hidden inside the slab, under the empty grass west of the
hole. The only way in is a small round hole in the top face (`entrance`), which drops straight
down into the first room's ceiling.

It's made the same way as the rest of the world (see `World`): each room is a box with rounded
edges and corners like the slab, but turned inside out, so its walls, floor and ceiling face into
it. The tunnels are like the big hole: a round pipe with its ends rounded out onto the walls of the
rooms it joins. As everywhere else on the surface, the player can walk all the way round a tunnel and
up a room's walls onto its ceiling.

Sunlight comes in at the entrance and dies away the further you walk from it (`light`), so the
rooms near it are dim and the rest are dark, apart from what the player's own glow lights up (see
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



---- THE MAZE ----


{-| Where the top face of the slab is (see `World`).
-}
groundLevel : Float
groundLevel =
    0.598373


{-| The rooms' floors and ceilings: the slab is a meter thick, so this leaves 12 cm of earth under
the floors and 18 cm over the ceilings.
-}
floorLevel : Float
floorLevel =
    -0.28


ceilingLevel : Float
ceilingLevel =
    floorLevel + 0.7


{-| How round the inside edges and corners of the rooms are. Everything underground is kept fairly
gently curved, as on tight curves the camera swings round and walking gets jumpy.
-}
roomFillet : Float
roomFillet =
    0.1


{-| How wide the tunnels are inside, and how round their ends are where they open onto a room. The
opening (radius plus fillet) has to fit on a wall between its fillets.
-}
tunnelRadius : Float
tunnelRadius =
    0.15


tunnelFillet : Float
tunnelFillet =
    0.08


{-| The tunnels go through the middle of the walls.
-}
tunnelLevel : Float
tunnelLevel =
    (floorLevel + ceilingLevel) / 2


{-| The shaft down from the entrance is a bit narrower than the tunnels, and has to be short, as
there's not much earth over the ceilings.
-}
shaftRadius : Float
shaftRadius =
    0.1


shaftFillet : Float
shaftFillet =
    0.08


{-| Rooms sit on a grid of cells this far apart, in 5 columns and 3 rows.
-}
spacing : Float
spacing =
    1.3


cellCenter : ( Int, Int ) -> { x : Float, z : Float }
cellCenter ( column, row ) =
    { x = -2.6 + spacing * toFloat column, z = -1.75 + spacing * toFloat row }


type alias Room =
    { cell : ( Int, Int )

    -- How wide the room is along x and z
    , width : Float
    , depth : Float
    }


{-| The cells with rooms in. The big hole goes through (3, 1), so the rooms round it make a ring.

    row 2:  A  E  B  C  D       E is under the entrance
    row 1:  F  G  H  O  I       O is the big hole
    row 0:  J  K  L  M  P       P is the big room at the end

-}
rooms : List Room
rooms =
    [ ( 0, 2 ), ( 1, 2 ), ( 2, 2 ), ( 3, 2 ), ( 4, 2 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 4, 1 ), ( 0, 0 ), ( 1, 0 ), ( 2, 0 ), ( 3, 0 ) ]
        |> List.map (\cell -> { cell = cell, width = 0.8, depth = 0.8 })
        |> (::) { cell = ( 4, 0 ), width = 1, depth = 0.95 }


{-| The room the shaft from the entrance comes down into.
-}
firstRoom : ( Int, Int )
firstRoom =
    ( 1, 2 )


{-| Which rooms the tunnels join. Each goes straight along x or z through the middle of the walls.
The way on from the entrance goes back west first. There's one loop, round the big hole (H B C D I P
M L), and dead ends at J and K.
-}
tunnels : List ( ( Int, Int ), ( Int, Int ) )
tunnels =
    [ ( ( 0, 2 ), ( 1, 2 ) )
    , ( ( 0, 1 ), ( 0, 2 ) )
    , ( ( 0, 0 ), ( 0, 1 ) )
    , ( ( 0, 1 ), ( 1, 1 ) )
    , ( ( 1, 0 ), ( 1, 1 ) )
    , ( ( 1, 1 ), ( 2, 1 ) )
    , ( ( 2, 1 ), ( 2, 2 ) )
    , ( ( 2, 2 ), ( 3, 2 ) )
    , ( ( 3, 2 ), ( 4, 2 ) )
    , ( ( 4, 1 ), ( 4, 2 ) )
    , ( ( 4, 0 ), ( 4, 1 ) )
    , ( ( 2, 0 ), ( 2, 1 ) )
    , ( ( 2, 0 ), ( 3, 0 ) )
    , ( ( 3, 0 ), ( 4, 0 ) )
    ]


roomAt : ( Int, Int ) -> Maybe Room
roomAt cell =
    List.filter (\room -> room.cell == cell) rooms |> List.head


type alias Box =
    { min : Vec, max : Vec }


roomBox : Room -> Box
roomBox room =
    let
        center =
            cellCenter room.cell
    in
    { min = { x = center.x - room.width / 2, y = floorLevel, z = center.z - room.depth / 2 }
    , max = { x = center.x + room.width / 2, y = ceilingLevel, z = center.z + room.depth / 2 }
    }


{-| A tunnel from the room with the smaller x or z to the other: along which axis, where its middle
line is across that axis, and where it starts and ends along it (the walls of the two rooms).
-}
type alias Tunnel =
    { from : ( Int, Int )
    , to : ( Int, Int )
    , axis : Axis
    , across : { x : Float, z : Float }
    , start : Float
    , end : Float
    }


tunnelFor : ( ( Int, Int ), ( Int, Int ) ) -> Maybe Tunnel
tunnelFor ( first, second ) =
    case ( roomAt first, roomAt second ) of
        ( Just a, Just b ) ->
            let
                ( near, far ) =
                    if Tuple.first a.cell + Tuple.second a.cell < Tuple.first b.cell + Tuple.second b.cell then
                        ( a, b )

                    else
                        ( b, a )

                nearBox =
                    roomBox near

                farBox =
                    roomBox far

                center =
                    cellCenter near.cell
            in
            if Tuple.second near.cell == Tuple.second far.cell then
                Just { from = near.cell, to = far.cell, axis = X, across = center, start = nearBox.max.x, end = farBox.min.x }

            else
                Just { from = near.cell, to = far.cell, axis = Z, across = center, start = nearBox.max.z, end = farBox.min.z }

        _ ->
            Nothing


allTunnels : List Tunnel
allTunnels =
    List.filterMap tunnelFor tunnels


{-| Where the entrance is on the top face, and how far out its rim is.
-}
entrance : { x : Float, z : Float, rim : Float }
entrance =
    let
        center =
            cellCenter firstRoom
    in
    { x = center.x, z = center.z, rim = shaftRadius + shaftFillet }



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


{-| Round holes in a room's walls, floor or ceiling: on which side, where (in world coordinates)
and how big.
-}
type alias Opening =
    { axis : Axis, sign : Float, center : Vec, radius : Float }


openingsOf : Room -> List Opening
openingsOf room =
    let
        box =
            roomBox room

        tunnelOpenings =
            allTunnels
                |> List.filterMap
                    (\tunnel ->
                        let
                            center along =
                                case tunnel.axis of
                                    X ->
                                        { x = along, y = tunnelLevel, z = tunnel.across.z }

                                    _ ->
                                        { x = tunnel.across.x, y = tunnelLevel, z = along }
                        in
                        if tunnel.from == room.cell then
                            Just { axis = tunnel.axis, sign = 1, center = center tunnel.start, radius = tunnelRadius + tunnelFillet }

                        else if tunnel.to == room.cell then
                            Just { axis = tunnel.axis, sign = -1, center = center tunnel.end, radius = tunnelRadius + tunnelFillet }

                        else
                            Nothing
                    )

        shaftOpening =
            if room.cell == firstRoom then
                [ { axis = Y, sign = 1, center = { x = entrance.x, y = box.max.y, z = entrance.z }, radius = shaftRadius + shaftFillet } ]

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
                        in
                        -- Clockwise, so the flat is on its left
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
roomFillet_ : Room -> Axis -> Float -> Float -> FeatureSpec coordinates
roomFillet_ room along signA signB =
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


{-| A round pipe from the plane `top` (facing up its frame's z axis) to the plane `bottom` (facing
down it), rounded out onto both, like the big hole (see `World`).
-}
pipe : { frame : Frame3d.Frame3d Meters coordinates { defines : Surface.FeatureCoordinate }, top : Float, bottom : Float, radius : Float, fillet : Float } -> FeatureSpec coordinates
pipe { frame, top, bottom, radius, fillet } =
    let
        rim =
            radius + fillet
    in
    { frame = frame
    , profile =
        { start = Point2d.meters rim top
        , segments =
            [ Circle { end = Point2d.meters radius (top - fillet), center = Point2d.meters rim (top - fillet) }
            , Line { end = Point2d.meters radius (bottom + fillet) }
            , Circle { end = Point2d.meters rim bottom, center = Point2d.meters rim (bottom + fillet) }
            ]
        }
    , sweep = FullTurn
    }


{-| A tunnel's pipe. Its frame's z axis points from the room it ends at back to the one it starts
from, as the end room's wall faces back along the tunnel.
-}
tunnelPipe : Tunnel -> FeatureSpec coordinates
tunnelPipe tunnel =
    let
        frame =
            case tunnel.axis of
                X ->
                    Frame3d.unsafe
                        { originPoint = Point3d.meters 0 tunnelLevel tunnel.across.z
                        , xDirection = Direction3d.y
                        , yDirection = Direction3d.z
                        , zDirection = Direction3d.x
                        }

                _ ->
                    Frame3d.unsafe
                        { originPoint = Point3d.meters tunnel.across.x tunnelLevel 0
                        , xDirection = Direction3d.x
                        , yDirection = Direction3d.y
                        , zDirection = Direction3d.z
                        }
    in
    pipe { frame = frame, top = tunnel.end, bottom = tunnel.start, radius = tunnelRadius, fillet = tunnelFillet }


{-| The shaft from the entrance on the top face down into the first room's ceiling.
-}
shaft : FeatureSpec coordinates
shaft =
    pipe
        { frame =
            Frame3d.unsafe
                { originPoint = Point3d.meters entrance.x 0 entrance.z
                , xDirection = Direction3d.z
                , yDirection = Direction3d.x
                , zDirection = Direction3d.y
                }
        , top = groundLevel
        , bottom = ceilingLevel
        , radius = shaftRadius
        , fillet = shaftFillet
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
        :: List.map tunnelPipe allTunnels
        ++ (rooms
                |> List.concatMap
                    (\room ->
                        ([ X, Y, Z ] |> List.concatMap (\along -> signs |> List.concatMap (\signA -> List.map (roomFillet_ room along signA) signs)))
                            ++ (signs |> List.concatMap (\signX -> signs |> List.concatMap (\signY -> List.map (roomCorner room signX signY) signs)))
                    )
           )



---- LIGHT ----


{-| How far it is to walk from the entrance to the middle of each room, going through the middles
of the rooms on the way.
-}
roomDistances : Dict ( Int, Int ) Float
roomDistances =
    let
        links =
            allTunnels
                |> List.concatMap
                    (\tunnel ->
                        let
                            a =
                                cellCenter tunnel.from

                            b =
                                cellCenter tunnel.to

                            length =
                                abs (a.x - b.x) + abs (a.z - b.z)
                        in
                        [ ( tunnel.from, ( tunnel.to, length ) ), ( tunnel.to, ( tunnel.from, length ) ) ]
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
    0.01


{-| How far a point in a room or tunnel is to walk to from the entrance, or Nothing if it isn't in
one. In a room, it's how far to the middle of the room and from there to the point; in a tunnel,
the shorter of that from either end; in the shaft, how far down it is.
-}
distanceFromEntrance : Vec -> Maybe Float
distanceFromEntrance p =
    let
        inRoom =
            rooms
                |> List.filterMap
                    (\room ->
                        let
                            box =
                                roomBox room

                            center =
                                cellCenter room.cell
                        in
                        if
                            (p.x > box.min.x - margin && p.x < box.max.x + margin)
                                && (p.y > box.min.y - margin && p.y < box.max.y + margin)
                                && (p.z > box.min.z - margin && p.z < box.max.z + margin)
                        then
                            Dict.get room.cell roomDistances
                                |> Maybe.map (\d -> d + sqrt ((p.x - center.x) ^ 2 + (p.z - center.z) ^ 2) + abs (p.y - tunnelLevel))

                        else
                            Nothing
                    )

        inTunnel =
            allTunnels
                |> List.filterMap
                    (\tunnel ->
                        let
                            ( along, a, b ) =
                                case tunnel.axis of
                                    X ->
                                        ( p.x, p.y - tunnelLevel, p.z - tunnel.across.z )

                                    _ ->
                                        ( p.z, p.y - tunnelLevel, p.x - tunnel.across.x )

                            fromStart =
                                cellCenter tunnel.from
                                    |> (\c ->
                                            abs
                                                (along
                                                    - (if tunnel.axis == X then
                                                        c.x

                                                       else
                                                        c.z
                                                      )
                                                )
                                       )

                            fromEnd =
                                cellCenter tunnel.to
                                    |> (\c ->
                                            abs
                                                (along
                                                    - (if tunnel.axis == X then
                                                        c.x

                                                       else
                                                        c.z
                                                      )
                                                )
                                       )
                        in
                        if along > tunnel.start - margin && along < tunnel.end + margin && a * a + b * b < (tunnelRadius + tunnelFillet + margin) ^ 2 then
                            Maybe.map2 (\dFrom dTo -> min (dFrom + fromStart) (dTo + fromEnd))
                                (Dict.get tunnel.from roomDistances)
                                (Dict.get tunnel.to roomDistances)

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
    distanceFromEntrance p |> Maybe.map (\d -> e ^ -((d / 1.6) ^ 2))


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
`Surface.tessellateBy`), given how finely the rest is. The rooms and tunnels are small and mostly
dark, so they're split much more coarsely. All their curves meet only each other, except the shaft
meets the grass round the entrance and the ceiling of the room under it, so those stay fine.
-}
tessellationStep : Float -> { min : Vec, max : Vec } -> Float
tessellationStep fine box =
    let
        center =
            { x = (box.min.x + box.max.x) / 2, y = (box.min.y + box.max.y) / 2, z = (box.min.z + box.max.z) / 2 }

        byEntrance =
            box.min.y > ceilingLevel - 0.001 && abs (center.x - entrance.x) < 0.3 && abs (center.z - entrance.z) < 0.3
    in
    if contains center && not byEntrance then
        max fine (pi / 16)

    else
        fine



---- MINIMAP ----


{-| Lines along the bottom of each tunnel and the shaft, and round the openings in the rooms'
walls, for the minimap (see `Shapes`).
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
                            -- From the rim of one opening to the other's
                            from =
                                tunnel.start

                            to =
                                tunnel.end

                            count =
                                ceiling ((to - from) / 0.03)

                            -- Where the bottom of the tunnel is along it, rounded out at the ends
                            heightAt along =
                                let
                                    outFrom =
                                        tunnel.start - along

                                    outTo =
                                        along - tunnel.end

                                    rise out =
                                        if out > 0 then
                                            -- On the room's wall below the opening
                                            bottom - tunnelFillet

                                        else if out > -tunnelFillet then
                                            bottom - tunnelFillet + sqrt (max 0 (tunnelFillet ^ 2 - (out + tunnelFillet) ^ 2))

                                        else
                                            bottom
                                in
                                min (rise outFrom) (rise outTo)
                        in
                        List.range 0 count
                            |> List.map
                                (\i ->
                                    let
                                        along =
                                            from + (to - from) * toFloat i / toFloat count
                                    in
                                    case tunnel.axis of
                                        X ->
                                            ( along, heightAt along, tunnel.across.z )

                                        _ ->
                                            ( tunnel.across.x, heightAt along, along )
                                )
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
                                                p =
                                                    opening.center

                                                offset axis amount v =
                                                    case axis of
                                                        X ->
                                                            { v | x = v.x + amount }

                                                        Y ->
                                                            { v | y = v.y + amount }

                                                        Z ->
                                                            { v | z = v.z + amount }

                                                q =
                                                    p |> offset a (opening.radius * cos angle) |> offset b (opening.radius * sin angle)
                                            in
                                            ( q.x, q.y, q.z )
                                    in
                                    List.range 0 24 |> List.map (\i -> point (2 * pi * toFloat i / 24))
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
                        ceiling ((room.width - 2 * inset) / 0.04)

                    rows =
                        ceiling ((room.depth - 2 * inset) / 0.04)

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
