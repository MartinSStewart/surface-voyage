module Buildings exposing (Roof, Stairs, Vec, heightAfter, roofs, stairs, underRoof)

{-| Things the player can climb: flat roofs and the stairs up to them. Like the walls, they're drawn
flat on the surface in perspective (see `WorldMesh` and `View.wallVS`), and the player's height above
the surface only changes how things are drawn: they still walk on the surface.
-}


type alias Vec =
    { x : Float, y : Float, z : Float }


{-| A flat roof over a house: its corners on the surface, counterclockwise seen from outside, and how
high it is.
-}
type alias Roof =
    { corners : List Vec
    , height : Float
    }


{-| A flight of `steps` steps going up from `bottom` to `top` (both on the surface), `width` wide,
`height` high at the top.
-}
type alias Stairs =
    { bottom : Vec
    , top : Vec
    , width : Float
    , height : Float
    , steps : Int
    }


{-| The top of the slab, where the houses are.
-}
top : Float
top =
    0.598373


{-| As high as the walls (`WorldMesh.wallHeight`), so the roof sits on them.
-}
roofHeight : Float
roofHeight =
    0.08


roofs : List Roof
roofs =
    [ -- The house by the start, to the outside of its walls
      { corners =
            [ { x = 1.975, y = top, z = -0.94 }
            , { x = 2.75, y = top, z = -0.94 }
            , { x = 2.75, y = top, z = -1.72 }
            , { x = 1.975, y = top, z = -1.72 }
            ]
      , height = roofHeight
      }
    ]


stairs : List Stairs
stairs =
    [ -- Up the side of the house by the start that faces the path
      { bottom = { x = 1.79, y = top, z = -1.15 }
      , top = { x = 1.975, y = top, z = -1.15 }
      , width = 0.1
      , height = roofHeight
      , steps = 4
      }
    ]


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
the surface.
-}
heightAfter : Float -> Float -> Vec -> Float
heightAfter seconds height position =
    let
        onStairs =
            List.filterMap (stairsHeight position) stairs
                |> List.filter (\h -> abs (h - height) <= maxStepUp)
                |> List.maximum

        onRoof =
            roofs
                |> List.filter (\roof -> height >= roof.height - maxStepUp && insideRoof position roof)
                |> List.map .height
                |> List.maximum

        target =
            Maybe.withDefault 0 (maxMaybe onStairs onRoof)
    in
    if target >= height then
        target

    else
        max target (height - fallSpeed * seconds)


{-| Whether a point is under a roof without the player being up on it (or higher).
-}
underRoof : Float -> Vec -> Bool
underRoof height position =
    List.any (\roof -> height < roof.height - maxStepUp && insideRoof position roof) roofs


maxMaybe : Maybe Float -> Maybe Float -> Maybe Float
maxMaybe a b =
    case ( a, b ) of
        ( Just a_, Just b_ ) ->
            Just (max a_ b_)

        ( Just _, Nothing ) ->
            a

        _ ->
            b


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
    if t >= 0 && t <= 1 && sqrt (dot across across) <= flight.width / 2 then
        Just (t * flight.height)

    else
        Nothing


{-| Whether a point is over a roof: inside its corners, seen along its normal.
-}
insideRoof : Vec -> Roof -> Bool
insideRoof position roof =
    case roof.corners of
        a :: b :: c :: _ ->
            let
                normal =
                    cross (sub b a) (sub c a)

                edges =
                    List.map2 Tuple.pair roof.corners (List.drop 1 roof.corners ++ List.take 1 roof.corners)
            in
            List.all (\( p, q ) -> dot (cross (sub q p) (sub position p)) normal >= 0) edges

        _ ->
            False


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
