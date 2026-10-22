module Shapes exposing (Paving, ShapePoint, Shapes, empty, foldWithin, prepare)

{-| Shapes drawn on the surface: walls as lines and paving (paths and floors) as filled areas.

To go on the minimap, which bends around the hole and the corners, each shape is broken into points
close enough together that straight lines between them on the map follow the surface.

-}

import Array exposing (Array)
import Dict exposing (Dict)
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

        xTo =
            min (grid.nx - 1) (cellOf box.max.x - grid.x0)

        ( yFrom, yTo ) =
            ( max 0 (cellOf box.min.y - grid.y0), min (grid.ny - 1) (cellOf box.max.y - grid.y0) )

        ( zFrom, zTo ) =
            ( max 0 (cellOf box.min.z - grid.z0), min (grid.nz - 1) (cellOf box.max.z - grid.z0) )

        go x y z acc =
            if x > xTo then
                acc

            else if y > yTo then
                go (x + 1) yFrom zFrom acc

            else if z > zTo then
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
    go (max 0 (cellOf box.min.x - grid.x0)) yFrom zFrom initial


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
        snap p =
            case Surface.nearestPoint (Point3d.meters p.x p.y p.z) surface of
                Just { position } ->
                    Point3d.toMeters position

                Nothing ->
                    p

        onPiece p =
            let
                point =
                    Point3d.meters p.x p.y p.z
            in
            Surface.nearestPiece point surface
                |> Maybe.map
                    (\piece ->
                        { piece = piece
                        , chart = Surface.chartCoordinate surface piece point
                        , position = p
                        }
                    )

        ( points, triangles ) =
            pavings
                |> List.foldl
                    (\paving ( pointsSoFar, trianglesSoFar ) ->
                        let
                            offset =
                                Array.length pointsSoFar

                            withCorners =
                                Array.append pointsSoFar (Array.fromList (List.map (fromTuple >> snap) paving.points))
                        in
                        paving.triangles
                            |> List.foldl
                                (\( i, j, k ) state -> split snap ( i + offset, j + offset, k + offset ) state)
                                { points = withCorners, midpoints = Dict.empty, triangles = trianglesSoFar }
                            |> (\state -> ( state.points, state.triangles ))
                    )
                    ( Array.empty, [] )

        ( allPoints, wallIndices ) =
            List.foldl
                (\wall ( pointsSoFar, wallsSoFar ) ->
                    let
                        added =
                            List.map fromTuple wall |> alongWall |> List.map snap
                    in
                    ( Array.append pointsSoFar (Array.fromList added)
                    , List.range (Array.length pointsSoFar) (Array.length pointsSoFar + List.length added - 1) :: wallsSoFar
                    )
                )
                ( points, [] )
                walls

        shapePoints =
            Array.map (\p -> onPiece p |> Maybe.withDefault { piece = -1, chart = { re = 0, im = 0 }, position = p }) allPoints
    in
    { points = shapePoints
    , walls = wallIndices
    , pavingTriangles = triangles
    , grid = gridOf shapePoints
    }


fromTuple : ( Float, Float, Float ) -> Vec
fromTuple ( x, y, z ) =
    { x = x, y = y, z = z }


{-| The points of a wall with more added between them, so none are more than `wallStep` apart.
-}
alongWall : List Vec -> List Vec
alongWall points =
    case points of
        first :: second :: rest ->
            let
                steps =
                    max 1 (ceiling (distance first second / wallStep))
            in
            List.map (\i -> lerp (toFloat i / toFloat steps) first second) (List.range 0 (steps - 1))
                ++ alongWall (second :: rest)

        _ ->
            points


type alias SplitState =
    { points : Array Vec
    , midpoints : Dict ( Int, Int ) Int
    , triangles : List ( Int, Int, Int )
    }


{-| Halve a triangle across its longest edge until its edges are short enough. Neighbouring triangles
share the points added on their shared edges.
-}
split : (Vec -> Vec) -> ( Int, Int, Int ) -> SplitState -> SplitState
split snap ( i, j, k ) state =
    let
        at index =
            Array.get index state.points |> Maybe.withDefault { x = 0, y = 0, z = 0 }

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
                                | points = Array.push (snap (lerp 0.5 (at a) (at b))) state.points
                                , midpoints = Dict.insert key index state.midpoints
                              }
                            )
            in
            withMidpoint |> split snap ( a, m, c ) |> split snap ( m, b, c )
    in
    if max dij (max djk dki) <= pavingEdge then
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
