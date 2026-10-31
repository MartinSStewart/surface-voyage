module LevelEditor exposing
    ( Placed
    , Tool(..)
    , addWall
    , buildings
    , elevationAt
    , empty
    , roofCorner
    , snapEnd
    , stairsTop
    , stepsFor
    , toolHint
    , toolName
    , tools
    , wallsAt
    )

{-| Making levels in the game: placing walls, stairs, dirt paths and roofs where the player walks,
and on a level made of grid pieces, more ground (see `GridLevel`).

Walls and paths go along the shortest way on the surface between the points the player picks (see
`ShortestPath`). A wall end close enough to the end of another wall at the same height is moved onto
it, and the two are joined into one wall, so the corner between them is mitred. Roof corners go onto
the corners of the walls under them, or onto the walls, if they're close. Stairs go up a storey (see
`Buildings.storey`), and their top goes onto the edge of a roof there if it's close.

-}

import Buildings exposing (Buildings, Roof, Stairs, Vec, Wall)
import GridLevel


type Tool
    = WallTool
    | StairsTool
    | PathTool
    | RoofTool
    | GroundTool GridLevel.Piece


tools : List Tool
tools =
    [ WallTool, StairsTool, PathTool, RoofTool ] ++ List.map GroundTool GridLevel.pieces


toolName : Tool -> String
toolName tool =
    case tool of
        WallTool ->
            "Wall"

        StairsTool ->
            "Stairs"

        PathTool ->
            "Dirt path"

        RoofTool ->
            "Roof"

        GroundTool piece ->
            GridLevel.pieceName piece


{-| What to do with a tool, before and while placing something with it.
-}
toolHint : Tool -> { placing : Bool } -> String
toolHint tool { placing } =
    case ( tool, placing ) of
        ( WallTool, False ) ->
            "Press Space to start a wall where you're standing"

        ( WallTool, True ) ->
            "Space turns a corner, Enter ends the wall where you are. Ends close to other walls' ends join them"

        ( StairsTool, False ) ->
            "Press Space where the bottom of the stairs goes"

        ( StairsTool, True ) ->
            "Press Enter where the top goes, a storey up"

        ( PathTool, False ) ->
            "Press Space to start a path where you're standing"

        ( PathTool, True ) ->
            "Space turns a corner, Enter ends the path where you are"

        ( RoofTool, False ) ->
            "Press Space at the first corner of the roof. Corners go onto walls close by"

        ( RoofTool, True ) ->
            "Space adds a corner where you are, Enter adds the last one and puts the roof on"

        ( GroundTool _, _ ) ->
            "Space puts the piece on the highlighted edge, the open edge nearest you. Q puts it along the whole side"


{-| Everything the player has placed, oldest first.
-}
type alias Placed =
    { walls : List Wall
    , stairs : List Stairs
    , paths : List (List ( Float, Float, Float ))
    , roofs : List Roof
    }


empty : Placed
empty =
    { walls = [], stairs = [], paths = [], roofs = [] }


buildings : Placed -> Buildings
buildings placed =
    { roofs = placed.roofs, stairs = placed.stairs }


{-| The storey nearest a height: things are placed at the bottom of the storey the player is in.
-}
elevationAt : Float -> Float
elevationAt height =
    Buildings.storey * toFloat (round (height / Buildings.storey))


{-| The walls standing at an elevation.
-}
wallsAt : Float -> List Wall -> List Wall
wallsAt elevation walls =
    List.filter (\wall -> sameLevel wall.bottom elevation) walls


sameLevel : Float -> Float -> Bool
sameLevel a b =
    abs (a - b) < 0.01


{-| How close a wall's end has to be to another's to join it, in meters.
-}
joinDistance : Float
joinDistance =
    0.06


{-| How close a roof's corner has to be to a wall to go onto it, in meters.
-}
snapDistance : Float
snapDistance =
    0.08


{-| How close the top of stairs has to be to the edge of a roof to go onto it, in meters. Further than
roof corners go, as stairs that stop short of the roof can't be climbed onto it.
-}
stairsReach : Float
stairsReach =
    0.15


{-| Where the end of a wall or path at `position` goes: onto the nearest end of `lines` within
`joinDistance`, or where it is.
-}
snapEnd : List (List ( Float, Float, Float )) -> Vec -> Vec
snapEnd lines position =
    lines
        |> List.concatMap (\line -> List.take 1 line ++ List.take 1 (List.reverse line))
        |> List.map fromTuple
        |> nearestWithin joinDistance position
        |> Maybe.withDefault position


{-| Add a wall, joining it to walls at the same height whose ends it starts or ends on (see `snapEnd`),
where no other wall ends too.
-}
addWall : Wall -> List Wall -> List Wall
addWall new walls =
    let
        endsAt p wall =
            sameLevel wall.bottom new.bottom
                && (List.head wall.points == Just p || List.head (List.reverse wall.points) == Just p)

        closed wall =
            List.length wall.points > 2 && List.head wall.points == List.head (List.reverse wall.points)

        joinAt p ( wall, others ) =
            case ( List.filter (endsAt p) others, closed wall ) of
                ( [ other ], False ) ->
                    if closed other then
                        ( wall, others )

                    else
                        ( { wall | points = endingAt p wall.points ++ List.drop 1 (List.reverse (endingAt p other.points)) }
                        , List.filter ((/=) other) others
                        )

                _ ->
                    ( wall, others )

        ( joined, rest ) =
            case ( List.head new.points, List.head (List.reverse new.points) ) of
                ( Just first, Just last ) ->
                    ( new, walls ) |> joinAt first |> joinAt last

                _ ->
                    ( new, walls )
    in
    rest ++ [ joined ]


{-| A line turned round if need be so that it ends at `p` (one of its ends).
-}
endingAt : ( Float, Float, Float ) -> List ( Float, Float, Float ) -> List ( Float, Float, Float )
endingAt p points =
    if List.head (List.reverse points) == Just p then
        points

    else
        List.reverse points


{-| Where a roof corner at `position` goes, for a roof on the walls at `elevation`: onto the nearest
corner or end of those walls within `snapDistance`, or else the nearest point on them, or where it is.
-}
roofCorner : List Wall -> Float -> Vec -> Vec
roofCorner walls elevation position =
    let
        lines =
            wallsAt elevation walls |> List.map (.points >> List.map fromTuple)
    in
    case nearestWithin snapDistance position (List.concatMap corners lines) of
        Just corner ->
            corner

        Nothing ->
            lines
                |> List.concatMap segments
                |> List.map (closestOnSegment position)
                |> nearestWithin snapDistance position
                |> Maybe.withDefault position


{-| The ends of a line of points, and the points where it turns more than 30 degrees.
-}
corners : List Vec -> List Vec
corners points =
    let
        turns =
            List.map3
                (\a b c ->
                    if dot (normalize (sub b a)) (normalize (sub c b)) < cos (degrees 30) then
                        Just b

                    else
                        Nothing
                )
                points
                (List.drop 1 points)
                (List.drop 2 points)
                |> List.filterMap identity
    in
    List.take 1 points ++ turns ++ List.take 1 (List.reverse points)


{-| Where the top of stairs going up from `elevation` goes: onto the nearest edge of a roof a storey up,
within `stairsReach`, or where it is.
-}
stairsTop : List Roof -> Float -> Vec -> Vec
stairsTop roofs elevation position =
    roofs
        |> List.filter (\roof -> sameLevel roof.height (elevation + Buildings.storey))
        |> List.concatMap (\roof -> segments (roof.corners ++ List.take 1 roof.corners))
        |> List.map (closestOnSegment position)
        |> nearestWithin stairsReach position
        |> Maybe.withDefault position


{-| How many steps stairs this long get, about as deep as the ones by the start.
-}
stepsFor : Float -> Int
stepsFor length =
    max 2 (round (length / 0.046))


nearestWithin : Float -> Vec -> List Vec -> Maybe Vec
nearestWithin limit position candidates =
    candidates
        |> List.map (\p -> ( distance p position, p ))
        |> List.filter (\( d, _ ) -> d <= limit)
        |> List.sortBy Tuple.first
        |> List.head
        |> Maybe.map Tuple.second


segments : List Vec -> List ( Vec, Vec )
segments points =
    List.map2 Tuple.pair points (List.drop 1 points)


closestOnSegment : Vec -> ( Vec, Vec ) -> Vec
closestOnSegment p ( a, b ) =
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


fromTuple : ( Float, Float, Float ) -> Vec
fromTuple ( x, y, z ) =
    { x = x, y = y, z = z }


distance : Vec -> Vec -> Float
distance a b =
    sqrt (dot (sub a b) (sub a b))


sub : Vec -> Vec -> Vec
sub a b =
    { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }


dot : Vec -> Vec -> Float
dot a b =
    a.x * b.x + a.y * b.y + a.z * b.z


normalize : Vec -> Vec
normalize a =
    let
        length =
            sqrt (dot a a)
    in
    if length > 0 then
        { x = a.x / length, y = a.y / length, z = a.z / length }

    else
        a
