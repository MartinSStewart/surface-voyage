module Buildings exposing
    ( Buildings
    , Roof
    , Stairs
    , Vec
    , Wall
    , append
    , default
    , heightAfter
    , insideRoof
    , maxStepUp
    , none
    , roofNormal
    , standingHeight
    , storey
    , underRoof
    )

{-| Things the player can climb: flat roofs and the stairs up to them, and the walls they stand on.
Like the walls, they're drawn flat on the surface in perspective (see `WorldMesh` and `View.wallVS`),
and the player's height above the surface only changes how things are drawn: they still walk on the
surface.

Buildings go up in storeys, each as high as a wall: walls on the ground, a roof on them, walls on
that roof, and so on.

-}


type alias Vec =
    { x : Float, y : Float, z : Float }


type alias Buildings =
    { roofs : List Roof
    , stairs : List Stairs
    }


{-| A wall along a line of points on the surface, standing `bottom` above it (on a roof, say).
-}
type alias Wall =
    { points : List ( Float, Float, Float )
    , bottom : Float
    }


{-| A flat roof: its corners on the surface, counterclockwise seen from outside, and how high it is.
The player can walk on it inside its corners. It's drawn `overhang` further out than that, so that
a roof with its corners on the middle of walls covers them.
-}
type alias Roof =
    { corners : List Vec
    , height : Float
    , overhang : Float
    }


{-| A flight of `steps` steps going up from `bottom` to `top` (both on the surface), `width` wide,
from `elevation` above the surface at the bottom to `elevation + height` at the top.
-}
type alias Stairs =
    { bottom : Vec
    , top : Vec
    , width : Float
    , height : Float
    , steps : Int
    , elevation : Float
    }


{-| How high a storey is: as high as the walls (`WorldMesh.wallHeight`), so a roof sits on them.
-}
storey : Float
storey =
    0.08


none : Buildings
none =
    { roofs = [], stairs = [] }


append : Buildings -> Buildings -> Buildings
append a b =
    { roofs = a.roofs ++ b.roofs, stairs = a.stairs ++ b.stairs }


{-| The top of the slab, where the houses are.
-}
top : Float
top =
    0.598373


{-| The buildings of the world made in code: the house by the start.
-}
default : Buildings
default =
    { roofs =
        [ -- The house by the start, to the outside of its walls
          { corners =
                [ { x = 1.975, y = top, z = -0.94 }
                , { x = 2.75, y = top, z = -0.94 }
                , { x = 2.75, y = top, z = -1.72 }
                , { x = 1.975, y = top, z = -1.72 }
                ]
          , height = storey
          , overhang = 0
          }
        ]
    , stairs =
        [ -- Up the side of the house by the start that faces the path
          { bottom = { x = 1.79, y = top, z = -1.15 }
          , top = { x = 1.975, y = top, z = -1.15 }
          , width = 0.1
          , height = storey
          , steps = 4
          , elevation = 0
          }
        ]
    }


{-| The highest the player can step up at once, in meters.
-}
maxStepUp : Float
maxStepUp =
    0.03


{-| How fast the player drops off a roof or the side of the stairs, in meters per second.
-}
fallSpeed : Float
fallSpeed =
    0.6


{-| How high the player is above the surface after `seconds`, from how high they were and where they
are now. On the stairs they're as high as the stairs where they are, if they came along them rather
than stepping on from the side. On a roof they stay up once they're up. Anywhere else they drop to
what's under them.
-}
heightAfter : Buildings -> Float -> Float -> Vec -> Float
heightAfter buildings seconds height position =
    let
        target =
            standingHeight buildings height position
    in
    if target >= height then
        target

    else
        max target (height - fallSpeed * seconds)


{-| How high what the player would stand on is, if they were `height` up at `position`: the stairs or
roof they're on, or the ground.
-}
standingHeight : Buildings -> Float -> Vec -> Float
standingHeight buildings height position =
    let
        onStairs =
            List.filterMap (stairsHeight position) buildings.stairs
                |> List.filter (\h -> abs (h - height) <= maxStepUp)
                |> List.maximum

        onRoof =
            buildings.roofs
                |> List.filter (\roof -> height >= roof.height - maxStepUp && insideRoof position roof)
                |> List.map .height
                |> List.maximum
    in
    Maybe.withDefault 0 (maxMaybe onStairs onRoof)


{-| Whether a point is under a roof without the player being up on it (or higher).
-}
underRoof : Float -> Vec -> Roof -> Bool
underRoof height position roof =
    height < roof.height - maxStepUp && insideRoof position roof


maxMaybe : Maybe Float -> Maybe Float -> Maybe Float
maxMaybe a b =
    case ( a, b ) of
        ( Just a_, Just b_ ) ->
            Just (max a_ b_)

        ( Just _, Nothing ) ->
            a

        _ ->
            b


{-| How far past the top of the stairs the player is still on them, in meters, so that they can step
onto a roof that starts a little way off.
-}
topLanding : Float
topLanding =
    0.03


{-| How high the stairs are at a point, if it's on them: going smoothly from the bottom to the top.
-}
stairsHeight : Vec -> Stairs -> Maybe Float
stairsHeight position flight =
    let
        along =
            sub flight.top flight.bottom

        length =
            sqrt (dot along along)

        offset =
            sub position flight.bottom

        t =
            dot offset along / (length * length)

        across =
            sub offset (scale t along)
    in
    if length > 0 && t >= 0 && t <= 1 + topLanding / length && sqrt (dot across across) <= flight.width / 2 then
        Just (flight.elevation + min 1 t * flight.height)

    else
        Nothing


{-| The way a roof faces: the normal of the plane its corners are closest to, pointing the way they go
counterclockwise round.
-}
roofNormal : List Vec -> Vec
roofNormal corners =
    -- Newell's method, which works for any polygon, convex or not
    List.map2
        (\a b ->
            { x = (a.y - b.y) * (a.z + b.z)
            , y = (a.z - b.z) * (a.x + b.x)
            , z = (a.x - b.x) * (a.y + b.y)
            }
        )
        corners
        (List.drop 1 corners ++ List.take 1 corners)
        |> List.foldl add { x = 0, y = 0, z = 0 }
        |> normalize


{-| Whether a point is over a roof: inside its corners, seen along its normal. On an edge counts as
inside, so the player can stand right on the edge, over the wall under it.
-}
insideRoof : Vec -> Roof -> Bool
insideRoof position roof =
    case roof.corners of
        first :: _ :: _ :: _ ->
            let
                normal =
                    roofNormal roof.corners

                -- Two directions in the roof's plane
                u =
                    normalize (sub (List.drop 1 roof.corners |> List.head |> Maybe.withDefault first) first)

                v =
                    cross normal u

                flat p =
                    ( dot (sub p first) u, dot (sub p first) v )

                ( px, py ) =
                    flat position

                edges =
                    List.map2 Tuple.pair roof.corners (List.drop 1 roof.corners ++ List.take 1 roof.corners)
                        |> List.map (\( a, b ) -> ( flat a, flat b ))

                onEdge ( ( ax, ay ), ( bx, by ) ) =
                    let
                        dx =
                            bx - ax

                        dy =
                            by - ay

                        lengthSquared =
                            dx * dx + dy * dy

                        t =
                            if lengthSquared > 0 then
                                clamp 0 1 (((px - ax) * dx + (py - ay) * dy) / lengthSquared)

                            else
                                0

                        ex =
                            ax + t * dx - px

                        ey =
                            ay + t * dy - py
                    in
                    ex * ex + ey * ey < edgeTolerance * edgeTolerance

                crosses ( ( ax, ay ), ( bx, by ) ) =
                    (ay > py) /= (by > py) && px < ax + (py - ay) * (bx - ax) / (by - ay)
            in
            List.any onEdge edges || (List.filter crosses edges |> List.length |> modBy 2) == 1

        _ ->
            False


{-| How close to a roof's edge counts as on it, in meters.
-}
edgeTolerance : Float
edgeTolerance =
    0.001


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


normalize : Vec -> Vec
normalize a =
    let
        length =
            sqrt (dot a a)
    in
    if length > 0 then
        scale (1 / length) a

    else
        a
