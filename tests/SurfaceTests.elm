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
        , describe "Flattening for the minimap"
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
            , test "Pieces meet without a gap at the rim of the hole" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                start =
                                    standAt surface ( 1.156, top, 1.5 ) ( 1.156, top, 0 )

                                rimZ =
                                    -0.2058 + 0.47524 + 0.30432
                            in
                            mapPosition surface start ( 1.156, top, rimZ + 1.0e-6 ) ()
                                |> complexWithin 1.0e-5 (mapPosition surface start ( 1.156, top - 1.0e-9, rimZ - 1.0e-6 ) ())
                        )
            , test "Standing on a rounded corner keeps the faces around it full size" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                start =
                                    standAt surface ( 4.044, 0.5966, -2.2798 ) ( 4.044, 0.5966, 0 )
                            in
                            case mapPosition surface start ( 4.0, top, -1.2798 ) () of
                                Just w ->
                                    sqrt (w.re ^ 2 + w.im ^ 2) |> Expect.within (Expect.Absolute 0.05) 1

                                Nothing ->
                                    Expect.fail "Not on the map"
                        )
            , test "The map doesn't jump when stepping into the hole" <|
                \_ ->
                    withSurface
                        (\surface ->
                            let
                                rimZ =
                                    -0.2058 + 0.47524 + 0.30432

                                outside =
                                    standAt surface ( 1.156, top, rimZ + 1.0e-4 ) ( 1.156, top, 0 )

                                inside =
                                    standAt surface ( 1.156, top - 1.0e-7, rimZ - 1.0e-4 ) ( 1.156, top, 0 )
                            in
                            mapPosition surface outside ( 0, top, 1 ) ()
                                |> complexWithin 1.0e-3 (mapPosition surface inside ( 0, top, 1 ) ())
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
mapPosition surface maybeStart ( x, y, z ) () =
    let
        point =
            Point3d.meters x y z
    in
    Maybe.map2
        (\start piece ->
            Surface.flattenAround 3 start surface
                |> List.filter (\placement -> placement.piece == piece)
                |> List.head
                |> Maybe.map (\placement -> Surface.placeOnMap placement (Surface.chartCoordinate surface piece point))
        )
        maybeStart
        (Surface.nearestPiece point surface)
        |> Maybe.andThen identity


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
