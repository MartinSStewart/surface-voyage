module SurfaceTests exposing (suite)

import Angle
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Length
import Point3d exposing (Point3d)
import Surface exposing (Surface)
import Test exposing (Test, describe, fuzz3, test)
import World


type WorldCoordinate
    = WorldCoordinate Never


withSurface : (Surface WorldCoordinate -> Expectation) -> Expectation
withSurface func =
    case World.surface of
        Ok surface ->
            func surface

        Err error ->
            Expect.fail (Surface.errorToString error)


pointsWithin : Float -> Point3d Length.Meters c -> Point3d Length.Meters c -> Expectation
pointsWithin tolerance expected actual =
    if Point3d.distanceFrom expected actual |> Length.inMeters |> (\d -> d < tolerance) then
        Expect.pass

    else
        Expect.fail (Debug.toString actual ++ " is not within " ++ String.fromFloat tolerance ++ " of " ++ Debug.toString expected)


{-| Stand at `start` facing `towards`, walk `distance`, and return where you end up.
-}
walk : Surface WorldCoordinate -> Point3d Length.Meters WorldCoordinate -> Point3d Length.Meters WorldCoordinate -> Float -> Maybe (Point3d Length.Meters WorldCoordinate)
walk surface start towards distance =
    Surface.nearestSurfacePoint start surface
        |> Maybe.map (Surface.pointTowards towards surface)
        |> Maybe.andThen (Surface.move surface (Angle.degrees 0) (Length.meters distance))
        |> Maybe.andThen (\path -> Surface.worldPosition (Surface.pathEnd path) surface)


top : Float
top =
    0.598373


bottom : Float
bottom =
    -0.401627


suite : Test
suite =
    describe "Surface"
        [ test "The world builds with every edge joined" <|
            \_ -> withSurface (Surface.pieceCount >> Expect.equal 27)
        , test "Walking once round the slab comes back to the start" <|
            \_ ->
                withSurface
                    (\surface ->
                        let
                            r =
                                0.198579

                            perimeter =
                                2 * ((4.236575 - r) - (-3.343595 + r) + (top - r) - (bottom + r)) + 2 * pi * r
                        in
                        case walk surface (Point3d.meters -1 top 1.5) (Point3d.meters 0 top 1.5) perimeter of
                            Just end ->
                                pointsWithin 1.0e-6 (Point3d.meters -1 top 1.5) end

                            Nothing ->
                                Expect.fail "Couldn't walk"
                    )
        , test "Walking straight into the hole comes out underneath" <|
            \_ ->
                withSurface
                    (\surface ->
                        let
                            rim =
                                0.47524 + 0.30432

                            -- To the rim, over the top fillet, down the wall, over the bottom fillet, then 0.5 m on
                            distance =
                                (1 - rim) + pi * 0.30432 + (top - bottom - 2 * 0.30432) + 0.5
                        in
                        case walk surface (Point3d.meters 1.156 top (-0.2058 + 1)) (Point3d.meters 1.156 top -0.2058) distance of
                            Just end ->
                                pointsWithin 1.0e-6 (Point3d.meters 1.156 bottom (-0.2058 + rim + 0.5)) end

                            Nothing ->
                                Expect.fail "Couldn't walk"
                    )
        , fuzz3 pointNearWorld angle (Fuzz.floatRange 0 3) "Walking there and back again returns to the start" <|
            \start heading distance ->
                withSurface
                    (\surface ->
                        case Surface.nearestSurfacePoint start surface |> Maybe.map (Surface.rotateBy heading) of
                            Just surfacePoint ->
                                case Surface.move surface (Angle.degrees 0) (Length.meters distance) surfacePoint of
                                    Just there ->
                                        case Surface.move surface (Angle.degrees 180) (Length.meters distance) (Surface.pathEnd there) of
                                            Just back ->
                                                Maybe.map2 (pointsWithin 1.0e-3)
                                                    (Surface.worldPosition surfacePoint surface)
                                                    (Surface.worldPosition (Surface.pathEnd back) surface)
                                                    |> Maybe.withDefault (Expect.fail "No position")

                                            Nothing ->
                                                Expect.fail "Couldn't walk back"

                                    Nothing ->
                                        Expect.fail "Couldn't walk there"

                            Nothing ->
                                Expect.fail "No surface point"
                    )
        , describe "Laying the surface out for the minimap"
            [ test "The player is in the middle of the map, facing up, at one meter per meter" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                start =
                                    standAt surface ( -1.5, top, 1 ) ( -1.5, top, 0 )
                            in
                            Expect.all
                                [ mapPosition surface start ( -1.5, top, 1 ) >> complexWithin 1.0e-9 (Just { re = 0, im = 0 })
                                , mapPosition surface start ( -1.5, top, 0 ) >> complexWithin 1.0e-9 (Just { re = 0, im = 1 })
                                , mapPosition surface start ( -2.5, top, 1 ) >> complexWithin 1.0e-9 (Just { re = -1, im = 0 })
                                ]
                                ()
                        )
            , test "Pieces meet without a gap where a face joins a rounded edge" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                start =
                                    standAt surface ( -1.5, top, 1 ) ( -1.5, top, 0 )

                                edgeZ =
                                    1.992144 - 0.198579
                            in
                            mapPosition surface start ( -1, top, edgeZ - 1.0e-6 ) ()
                                |> complexWithin 1.0e-5 (mapPosition surface start ( -1, top - 1.0e-9, edgeZ + 1.0e-6 ) ())
                        )
            , test "Faces and rounded edges are where walking straight takes you" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                checks =
                                    [ ( ( -1.5, top, 1 ), ( -1.5, top, 0 ) )
                                    , ( ( 3.9, top, 0.5 ), ( 5, top, 0.5 ) )
                                    , ( ( 3.9, top, 1.7 ), ( 5, top, 2 ) )
                                    , ( ( 4.2, 0.55, 0.5 ), ( 4.2, 0.55, 0 ) )
                                    , ( ( 4.3, 0.1, 0.5 ), ( 4.3, 1, 0.5 ) )
                                    , ( ( 1.156, top, 1.0 ), ( 1.156, top, 0 ) )
                                    , ( ( 1.156, bottom, 1.2 ), ( 1.156, bottom, 0 ) )
                                    ]
                                        |> List.concatMap
                                            (\( at, towards ) ->
                                                case standAt surface at towards of
                                                    Just start ->
                                                        let
                                                            layout =
                                                                Surface.mapAround 3 start surface
                                                        in
                                                        List.range 0 11
                                                            |> List.concatMap
                                                                (\k ->
                                                                    [ 0.7, 1.6, 2.7 ]
                                                                        |> List.filterMap
                                                                            (\distance ->
                                                                                let
                                                                                    direction =
                                                                                        toFloat k * pi / 6 + 0.1
                                                                                in
                                                                                if inFan layout direction then
                                                                                    Nothing

                                                                                else
                                                                                    Just (walkMatchesMap surface start layout direction distance)
                                                                            )
                                                                )

                                                    Nothing ->
                                                        [ Err "No start" ]
                                            )

                                failures =
                                    List.filterMap
                                        (\check ->
                                            case check of
                                                Ok () ->
                                                    Nothing

                                                Err message ->
                                                    Just message
                                        )
                                        checks
                            in
                            if List.length checks < 120 then
                                Expect.fail ("Only " ++ String.fromInt (List.length checks) ++ " walks were checked")

                            else
                                Expect.equal [] failures
                        )
            , -- The fan takes bigger steps than walking does, and paths through the hole spread errors out.
              -- A centimeter is a third of a pixel on the minimap.
              test "Points on the fan are where walking straight takes you" <|
                \_ ->
                    withSurface
                        (\surface ->
                            [ ( ( 1.156, top, 1.5 ), ( 1.156, top, 0 ) )
                            , ( ( 1.156, 0.1, 0.27 ), ( 1.156, -1, 0.27 ) )
                            , ( ( 4.2, 0.55, 1.95 ), ( 4.2, 0.55, 0 ) )
                            , ( ( 3.9, top, 1.7 ), ( 5, top, 2 ) )
                            ]
                                |> List.concatMap
                                    (\( at, towards ) ->
                                        case standAt surface at towards of
                                            Just start ->
                                                Surface.mapAround 3 start surface
                                                    |> .fan
                                                    |> List.concat
                                                    |> everyNth 7
                                                    |> List.concatMap
                                                        (\ray ->
                                                            ray.samples
                                                                |> List.indexedMap (\i sample -> ( ray.firstSample + i, sample ))
                                                                |> everyNth 4
                                                                |> List.map
                                                                    (\( index, sample ) () ->
                                                                        case
                                                                            Surface.move surface (Angle.radians (ray.angle - pi / 2)) (Length.meters (toFloat index * Surface.fanSpacing)) start
                                                                                |> Maybe.andThen (\path -> Surface.worldPosition (Surface.pathEnd path) surface)
                                                                        of
                                                                            Just end ->
                                                                                pointsWithin 0.01 end (Point3d.fromMeters sample.position)

                                                                            Nothing ->
                                                                                Expect.fail "Couldn't walk there"
                                                                    )
                                                        )

                                            Nothing ->
                                                [ \() -> Expect.fail "No start" ]
                                    )
                                |> (\checks -> Expect.all checks ())
                        )
            , test "Nothing is shown straight behind the hole" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                start =
                                    standAt surface ( 1.156, top, 1.5 ) ( 1.156, top, 0 )

                                shown point =
                                    Maybe.map2
                                        (\start_ piece ->
                                            Surface.mapAround 3 start_ surface
                                                |> .placements
                                                |> List.filter (\placement -> placement.piece == piece)
                                                |> List.any (\placement -> isShown placement (Surface.placeOnMap placement (Surface.chartCoordinate surface piece (pointFrom point))))
                                        )
                                        start
                                        (Surface.nearestPiece (pointFrom point) surface)
                            in
                            Expect.all
                                [ \() -> shown ( 1.156, top, -1.2 ) |> Expect.equal (Just False)
                                , \() -> shown ( -0.4, top, -0.6 ) |> Expect.equal (Just True)
                                ]
                                ()
                        )
            ]
        , Test.fuzz pointNearWorld "The nearest surface point is its own nearest surface point" <|
            \point ->
                withSurface
                    (\surface ->
                        case Surface.nearestSurfacePoint point surface |> Maybe.andThen (\p -> Surface.worldPosition p surface) of
                            Just onSurface ->
                                case Surface.nearestSurfacePoint onSurface surface |> Maybe.andThen (\p -> Surface.worldPosition p surface) of
                                    Just again ->
                                        pointsWithin 1.0e-9 onSurface again

                                    Nothing ->
                                        Expect.fail "No position"

                            Nothing ->
                                Expect.fail "No position"
                    )
        ]


standAt : Surface WorldCoordinate -> ( Float, Float, Float ) -> ( Float, Float, Float ) -> Maybe Surface.SurfacePoint
standAt surface ( x, y, z ) ( tx, ty, tz ) =
    Surface.nearestSurfacePoint (Point3d.meters x y z) surface
        |> Maybe.map (Surface.pointTowards (Point3d.meters tx ty tz) surface)


{-| Where a point goes on the map, using the copy of its piece placed first.
-}
mapPosition : Surface WorldCoordinate -> Maybe Surface.SurfacePoint -> ( Float, Float, Float ) -> () -> Maybe Surface.Complex
mapPosition surface maybeStart point () =
    Maybe.map2
        (\start piece ->
            Surface.mapAround 3 start surface
                |> .placements
                |> List.filter (\placement -> placement.piece == piece)
                |> List.head
                |> Maybe.map (\placement -> Surface.placeOnMap placement (Surface.chartCoordinate surface piece (pointFrom point)))
        )
        maybeStart
        (Surface.nearestPiece (pointFrom point) surface)
        |> Maybe.andThen identity


pointFrom : ( Float, Float, Float ) -> Point3d Length.Meters WorldCoordinate
pointFrom ( x, y, z ) =
    Point3d.meters x y z


{-| Whether a placement shows the point at `w` on the map, as the minimap's shader decides it.
-}
isShown : Surface.Placement -> Surface.Complex -> Bool
isShown placement w =
    let
        offset =
            atan2 w.im w.re - placement.window.center |> (\a -> a - 2 * pi * toFloat (round (a / (2 * pi))))

        inWindow =
            placement.window.halfWidth >= pi || abs offset <= placement.window.halfWidth + 1.0e-6

        behindHole =
            case placement.hole of
                Just hole ->
                    let
                        t =
                            clamp 0 1 ((hole.center.re * w.re + hole.center.im * w.im) / (w.re * w.re + w.im * w.im))
                    in
                    sqrt ((t * w.re - hole.center.re) ^ 2 + (t * w.im - hole.center.im) ^ 2) < hole.radius

                Nothing ->
                    False
    in
    inWindow && not behindHole


{-| Whether the fan covers a direction on the map.
-}
inFan : Surface.Layout -> Float -> Bool
inFan layout direction =
    List.any
        (\rays ->
            case ( List.head rays, List.reverse rays |> List.head ) of
                ( Just first, Just last ) ->
                    let
                        relative =
                            direction - first.angle - 2 * pi * toFloat (floor ((direction - first.angle) / (2 * pi)))
                    in
                    relative <= last.angle - first.angle

                _ ->
                    False
        )
        layout.fan


{-| Walk straight from `start`, setting off at `direction` on the map, and check that a placement of
the piece you end up on shows it `distance` from the middle in that direction.
-}
walkMatchesMap : Surface WorldCoordinate -> Surface.SurfacePoint -> Surface.Layout -> Float -> Float -> Result String ()
walkMatchesMap surface start layout direction distance =
    let
        expected =
            { re = distance * cos direction, im = distance * sin direction }

        end =
            Surface.move surface (Angle.radians (direction - pi / 2)) (Length.meters distance) start
                |> Maybe.andThen (\path -> Surface.worldPosition (Surface.pathEnd path) surface)
    in
    case Maybe.map2 Tuple.pair end (Maybe.andThen (\p -> Surface.nearestPiece p surface) end) of
        Just ( point, piece ) ->
            let
                matches =
                    layout.placements
                        |> List.filter (\placement -> placement.piece == piece && isShown placement expected)
                        |> List.map (\placement -> Surface.placeOnMap placement (Surface.chartCoordinate surface piece point))
                        |> List.filter (\w -> sqrt ((w.re - expected.re) ^ 2 + (w.im - expected.im) ^ 2) < 2.0e-3)
            in
            if List.isEmpty matches then
                Err ("Walking " ++ String.fromFloat distance ++ " m at " ++ String.fromFloat direction ++ " ends on piece " ++ String.fromInt piece ++ ", which isn't shown there")

            else
                Ok ()

        Nothing ->
            Err "Couldn't walk there"


everyNth : Int -> List a -> List a
everyNth n list =
    List.indexedMap Tuple.pair list |> List.filter (\( i, _ ) -> modBy n i == 0) |> List.map Tuple.second


complexWithin : Float -> Maybe Surface.Complex -> Maybe Surface.Complex -> Expectation
complexWithin tolerance maybeExpected maybeActual =
    case ( maybeExpected, maybeActual ) of
        ( Just expected, Just actual ) ->
            if sqrt ((expected.re - actual.re) ^ 2 + (expected.im - actual.im) ^ 2) < tolerance then
                Expect.pass

            else
                Expect.fail (Debug.toString actual ++ " is not within " ++ String.fromFloat tolerance ++ " of " ++ Debug.toString expected)

        _ ->
            Expect.fail "Not on the map"


pointNearWorld : Fuzzer (Point3d Length.Meters WorldCoordinate)
pointNearWorld =
    Fuzz.map3 Point3d.meters (Fuzz.floatRange -4 5) (Fuzz.floatRange -1 1.2) (Fuzz.floatRange -3 2.5)


angle : Fuzzer Angle.Angle
angle =
    Fuzz.map Angle.radians (Fuzz.floatRange -pi pi)
