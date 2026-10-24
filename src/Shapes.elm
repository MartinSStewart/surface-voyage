module Shapes exposing (Paving, ShapePoint, Shapes, alongWall, empty, foldWithin, isClosed, pathPaving, pathWidth, prepare, sections, splitPavings)

{-| Shapes drawn on the surface: walls as lines and paving (paths and floors) as filled areas.

To go on the minimap, which bends around the hole and the corners, each shape is broken into points
close enough together that straight lines between them on the map follow the surface.

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Direction3d
import Point3d
import Surface exposing (Surface)


{-| A filled area: its corners, and its triangles as indices into them.
-}
type alias Paving =
    { points : List ( Float, Float, Float )
    , triangles : List ( Int, Int, Int )
    }


{-| A point of a shape on the surface: the piece it's on, its chart coordinate there (see
`Surface.chartCoordinate`), and where it is.
-}
type alias ShapePoint =
    { piece : Int
    , chart : Surface.Complex
    , position : Vec
    }


type alias Vec =
    { x : Float, y : Float, z : Float }


{-| Shapes moved onto the surface, with points added along the walls and the paving split into small
triangles. Walls and triangles are indices into `points`, which can be looked up by where they are
with `foldWithin`.
-}
type alias Shapes =
    { points : Array ShapePoint
    , walls : List (List Int)
    , pavingTriangles : List ( Int, Int, Int )
    , grid : Grid
    }


{-| Which points are in each cube `cellSize` meters across, over the cubes from (x0, y0, z0) on, nx
by ny by nz of them, x slowest.
-}
type alias Grid =
    { x0 : Int, y0 : Int, z0 : Int, nx : Int, ny : Int, nz : Int, cells : Array (List Int) }


empty : Shapes
empty =
    { points = Array.empty, walls = [], pavingTriangles = [], grid = { x0 = 0, y0 = 0, z0 = 0, nx = 0, ny = 0, nz = 0, cells = Array.empty } }


{-| Points are looked up by which cube of this size, in meters, they're in.
-}
cellSize : Float
cellSize =
    0.2


cellOf : Float -> Int
cellOf coordinate =
    floor (coordinate / cellSize)


{-| Go through the points in the cubes that a box reaches into, and maybe a few more.
-}
foldWithin : { min : Vec, max : Vec } -> (Int -> acc -> acc) -> acc -> Shapes -> acc
foldWithin box step initial shapes =
    let
        grid =
            shapes.grid

        -- Comparisons are written as differences so that they're JavaScript's own (see
        -- `Minimap.maxFloat`)
        clampCell first count i =
            if i - first < 0 then
                0

            else if i - first - count >= 0 then
                count - 1

            else
                i - first

        xTo =
            clampCell grid.x0 grid.nx (cellOf box.max.x)

        ( yFrom, yTo ) =
            ( clampCell grid.y0 grid.ny (cellOf box.min.y), clampCell grid.y0 grid.ny (cellOf box.max.y) )

        ( zFrom, zTo ) =
            ( clampCell grid.z0 grid.nz (cellOf box.min.z), clampCell grid.z0 grid.nz (cellOf box.max.z) )

        go x y z acc =
            if x - xTo > 0 then
                acc

            else if y - yTo > 0 then
                go (x + 1) yFrom zFrom acc

            else if z - zTo > 0 then
                go x (y + 1) zFrom acc

            else
                go x
                    y
                    (z + 1)
                    (case Array.get ((x * grid.ny + y) * grid.nz + z) grid.cells of
                        Just inCell ->
                            List.foldl step acc inCell

                        Nothing ->
                            acc
                    )
    in
    go (clampCell grid.x0 grid.nx (cellOf box.min.x)) yFrom zFrom initial


gridOf : Array ShapePoint -> Grid
gridOf points =
    let
        cells =
            Array.toList points |> List.map (\p -> ( cellOf p.position.x, cellOf p.position.y, cellOf p.position.z ))

        bounds get =
            ( List.map get cells |> List.minimum |> Maybe.withDefault 0, List.map get cells |> List.maximum |> Maybe.withDefault -1 )

        ( ( x0, x1 ), ( y0, y1 ), ( z0, z1 ) ) =
            ( bounds (\( x, _, _ ) -> x), bounds (\( _, y, _ ) -> y), bounds (\( _, _, z ) -> z) )

        ( nx, ny, nz ) =
            ( x1 - x0 + 1, y1 - y0 + 1, z1 - z0 + 1 )
    in
    { x0 = x0
    , y0 = y0
    , z0 = z0
    , nx = nx
    , ny = ny
    , nz = nz
    , cells =
        List.foldl
            (\( x, y, z ) ( index, grid ) ->
                let
                    at =
                        ((x - x0) * ny + (y - y0)) * nz + (z - z0)
                in
                ( index + 1, Array.set at (index :: (Array.get at grid |> Maybe.withDefault [])) grid )
            )
            ( 0, Array.repeat (nx * ny * nz) [] )
            cells
            |> Tuple.second
    }


{-| Walls get a point at least this often, in meters.
-}
wallStep : Float
wallStep =
    0.1


{-| Paving triangles are split until no edge is longer than this, in meters.
-}
pavingEdge : Float
pavingEdge =
    0.2


prepare : Surface coordinates -> List (List ( Float, Float, Float )) -> List Paving -> Shapes
prepare surface walls pavings =
    let
        ( points, triangles ) =
            splitPavings (\p q -> distance p q - pavingEdge > 0) (snap surface) identity pavings

        shapePoints =
            Array.map (onPiece surface) points
    in
    { points = shapePoints
    , walls = []
    , pavingTriangles = triangles
    , grid = gridOf shapePoints
    }
        |> addWalls surface walls


{-| Add walls to shapes.
-}
addWalls : Surface coordinates -> List (List ( Float, Float, Float )) -> Shapes -> Shapes
addWalls surface walls shapes =
    let
        ( allPoints, wallIndices ) =
            List.foldl
                (\wall ( pointsSoFar, wallsSoFar ) ->
                    let
                        added =
                            List.map fromTuple wall |> alongWall wallStep |> List.map (snap surface >> onPiece surface)
                    in
                    ( Array.append pointsSoFar (Array.fromList added)
                    , List.range (Array.length pointsSoFar) (Array.length pointsSoFar + List.length added - 1) :: wallsSoFar
                    )
                )
                ( shapes.points, shapes.walls )
                walls
    in
    { shapes | points = allPoints, walls = wallIndices, grid = gridOf allPoints }


snap : Surface coordinates -> Vec -> Vec
snap surface p =
    case Surface.nearestPoint (Point3d.meters p.x p.y p.z) surface of
        Just { position } ->
            Point3d.toMeters position

        Nothing ->
            p


onPiece : Surface coordinates -> Vec -> ShapePoint
onPiece surface p =
    let
        point =
            Point3d.meters p.x p.y p.z
    in
    case Surface.nearestPiece point surface of
        Just piece ->
            { piece = piece
            , chart = Surface.chartCoordinate surface piece point
            , position = p
            }

        Nothing ->
            { piece = -1, chart = { re = 0, im = 0 }, position = p }


fromTuple : ( Float, Float, Float ) -> Vec
fromTuple ( x, y, z ) =
    { x = x, y = y, z = z }


{-| The points of a wall with more added between them, so none are more than `step` meters apart.
-}
alongWall : Float -> List Vec -> List Vec
alongWall step points =
    case points of
        first :: second :: rest ->
            let
                steps =
                    max 1 (ceiling (distance first second / step))
            in
            List.map (\i -> lerp (toFloat i / toFloat steps) first second) (List.range 0 (steps - 1))
                ++ alongWall step (second :: rest)

        _ ->
            points


{-| Whether a line of points comes back round to where it started, like the walls round a room.
-}
isClosed : List Vec -> Bool
isClosed points =
    case ( points, List.reverse points ) of
        ( first :: _ :: _ :: _, last :: _ ) ->
            distance first last < 1.0e-4

        _ ->
            False


{-| Points along a line (from `alongWall`) on the surface, and the way across the line at each of them,
to its right going along it. Where the line turns a corner, the way across is mitred: it points
along the corner's bisector and is longer, so that something drawn `w` either side of the line is `w`
thick everywhere. A closed line (see `isClosed`) is mitred where its ends meet too.
-}
sections : (Vec -> { position : Vec, normal : Vec }) -> List Vec -> List { position : Vec, normal : Vec, along : Vec, right : Vec }
sections onSurface points =
    let
        closed =
            isClosed points

        onLine =
            (if closed then
                List.take (List.length points - 1) points

             else
                points
            )
                |> List.map onSurface
                |> Array.fromList

        count =
            Array.length onLine

        at i =
            Array.get
                (if closed then
                    modBy count i

                 else
                    clamp 0 (count - 1) i
                )
                onLine
                |> Maybe.withDefault { position = { x = 0, y = 0, z = 0 }, normal = { x = 0, y = 1, z = 0 } }

        section i =
            let
                p =
                    at i

                towards j =
                    normalize (sub (at j).position p.position)

                -- Going in and out of the point, so the ends of an open line just go one way
                ( into, out ) =
                    if not closed && i == 0 then
                        ( towards 1, towards 1 )

                    else if not closed && i == count - 1 then
                        ( scale -1 (towards (i - 1)), scale -1 (towards (i - 1)) )

                    else
                        ( scale -1 (towards (i - 1)), towards (i + 1) )

                rightOf d =
                    normalize (cross d p.normal)

                bisector =
                    normalize (add (rightOf into) (rightOf out))

                -- How much longer the way across is at a corner, kept from going far out at sharp ones
                mitre =
                    1 / clampFloat 0.35 1 (dot bisector (rightOf into))
            in
            { position = p.position
            , normal = p.normal
            , along = normalize (add into out)
            , right = scale mitre bisector
            }
    in
    List.range 0 (count - 1)
        |> List.map section
        |> (\all ->
                if closed then
                    all ++ List.take 1 all

                else
                    all
           )


{-| A dirt path along a line of points, `width` wide, as paving.
-}
pathPaving : Surface coordinates -> Float -> List ( Float, Float, Float ) -> Paving
pathPaving surface width points =
    let
        onSurface p =
            case Surface.nearestPoint (Point3d.meters p.x p.y p.z) surface of
                Just nearest ->
                    { position = Point3d.toMeters nearest.position, normal = Direction3d.unwrap nearest.normal }

                Nothing ->
                    { position = p, normal = { x = 0, y = 1, z = 0 } }

        across =
            List.map fromTuple points
                |> alongWall pathStep
                |> sections onSurface

        toTuple v =
            ( v.x, v.y, v.z )

        sides s =
            [ toTuple (add s.position (scale (-width / 2) s.right)), toTuple (add s.position (scale (width / 2) s.right)) ]
    in
    { points = List.concatMap sides across
    , triangles =
        List.range 0 (List.length across - 2)
            |> List.concatMap (\i -> [ ( 2 * i, 2 * i + 1, 2 * i + 2 ), ( 2 * i + 1, 2 * i + 3, 2 * i + 2 ) ])
    }


{-| How wide dirt paths are, in meters.
-}
pathWidth : Float
pathWidth =
    0.07


{-| Paths get a point at least this often, in meters, so they follow the surface round curves.
-}
pathStep : Float
pathStep =
    0.04


{-| All the pavings' corners and triangles, with the triangles split until no edge is `tooLong`
(which should be true of edges longer than some length).
`toPoint` makes a point from where it is (moving it onto the surface, say) and `position` says where
a point is.
-}
splitPavings : (point -> point -> Bool) -> (Vec -> point) -> (point -> Vec) -> List Paving -> ( Array point, List ( Int, Int, Int ) )
splitPavings tooLong toPoint position pavings =
    pavings
        |> List.foldl
            (\paving ( pointsSoFar, trianglesSoFar ) ->
                let
                    offset =
                        Array.length pointsSoFar

                    withCorners =
                        Array.append pointsSoFar (Array.fromList (List.map (fromTuple >> toPoint) paving.points))
                in
                paving.triangles
                    |> List.foldl
                        (\( i, j, k ) state -> split tooLong toPoint position ( i + offset, j + offset, k + offset ) state)
                        { points = withCorners, midpoints = Dict.empty, triangles = trianglesSoFar }
                    |> (\state -> ( state.points, state.triangles ))
            )
            ( Array.empty, [] )


type alias SplitState point =
    { points : Array point
    , midpoints : Dict ( Int, Int ) Int
    , triangles : List ( Int, Int, Int )
    }


{-| Halve a triangle across its longest edge until none of its edges are too long. Halving the
longest edge each time, rather than one that's too long, makes sure this ends. Neighbouring triangles
share the points added on edges they both split.
-}
split : (point -> point -> Bool) -> (Vec -> point) -> (point -> Vec) -> ( Int, Int, Int ) -> SplitState point -> SplitState point
split tooLong toPoint position ( i, j, k ) state =
    let
        point index =
            Array.get index state.points

        at index =
            point index |> Maybe.map position |> Maybe.withDefault { x = 0, y = 0, z = 0 }

        isTooLong a b =
            Maybe.map2 tooLong (point a) (point b) |> Maybe.withDefault False

        dij =
            distance (at i) (at j)

        djk =
            distance (at j) (at k)

        dki =
            distance (at k) (at i)

        halve a b c =
            -- Split edge a-b, c is the opposite corner
            let
                key =
                    ( min a b, max a b )

                ( m, withMidpoint ) =
                    case Dict.get key state.midpoints of
                        Just existing ->
                            ( existing, state )

                        Nothing ->
                            let
                                index =
                                    Array.length state.points
                            in
                            ( index
                            , { state
                                | points = Array.push (toPoint (lerp 0.5 (at a) (at b))) state.points
                                , midpoints = Dict.insert key index state.midpoints
                              }
                            )
            in
            withMidpoint |> split tooLong toPoint position ( a, m, c ) |> split tooLong toPoint position ( m, b, c )
    in
    if not (isTooLong i j || isTooLong j k || isTooLong k i) then
        { state | triangles = ( i, j, k ) :: state.triangles }

    else if dij >= djk && dij >= dki then
        halve i j k

    else if djk >= dki then
        halve j k i

    else
        halve k i j


lerp : Float -> Vec -> Vec -> Vec
lerp t a b =
    { x = a.x + t * (b.x - a.x), y = a.y + t * (b.y - a.y), z = a.z + t * (b.z - a.z) }


distance : Vec -> Vec -> Float
distance a b =
    sqrt ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)


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


clampFloat : Float -> Float -> Float -> Float
clampFloat low high x =
    if x - low < 0 then
        low

    else if x - high > 0 then
        high

    else
        x
