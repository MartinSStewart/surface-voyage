module InterpolativeTests exposing (..)

import Expect
import Fuzz
import Interpolative
import Point2d
import Point3d
import Quantity
import Test exposing (Test, fuzz, fuzz2, fuzz3)
import Triangle2d


interpolativeRoundTrip : Test
interpolativeRoundTrip =
    fuzz2 fuzzTriangle fuzzInterpolative "Round trip toPoint2d and fromPoint2d" <|
        \triangle interpolative ->
            let
                expected =
                    Interpolative.toPoint2d triangle interpolative
            in
            expected |> Interpolative.fromPoint2d triangle |> Interpolative.toPoint2d triangle |> pointEqualWithin expected


fuzzInterpolative =
    Fuzz.map2 Interpolative.from
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)


fuzzPoint2d =
    fuzzPoint2dRange -1000 1000


fuzzPoint2dRange low high =
    Fuzz.map2 Point2d.meters
        (Fuzz.floatRange low high)
        (Fuzz.floatRange low high)


fuzzTriangle =
    fuzz3 Triangle2d.from
        fuzzPoint2d
        fuzzPoint2d
        fuzzPoint2d


equalWithin expected actual =
    (abs (expected - actual) < 0.001)
        || (abs (expected - actual) < (abs expected * 0.001))


pointEqualWithin expected actual =
    let
        ( ex, ey ) =
            Point2d.toTuple rawQuantity expected

        ( ax, ay ) =
            Point2d.toTuple rawQuantity actual
    in
    if equalWithin ex ax && equalWithin ey ay then
        Expect.pass

    else
        Expect.fail ("Expected: " ++ pointToString expected ++ "    Actual: " ++ pointToString actual)


pointToString point =
    let
        ( x, y ) =
            Point2d.toTuple rawQuantity point
    in
    "(" ++ String.fromFloat x ++ ", " ++ String.fromFloat y ++ ")"


rawQuantity (Quantity.Quantity quantity) =
    quantity
