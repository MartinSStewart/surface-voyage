module InterpolativeTests exposing (..)

import Expect
import Fuzz
import Point2d
import Point3d
import Quantity
import SurfaceMesh.Interpolative as Interpolative
import SurfaceMesh.TriangleEdge as TriangleEdge
import Test exposing (Test, fuzz, fuzz2, fuzz3, only, test)
import Triangle2d



--interpolativeRoundTrip : Test
--interpolativeRoundTrip =
--    fuzz2 fuzzTriangle fuzzInterpolative "Round trip toPoint2d and fromPoint2d" <|
--        \triangle interpolative ->
--            let
--                expected =
--                    Interpolative.toPoint2d triangle interpolative
--            in
--            expected |> Interpolative.fromPoint2d triangle |> Interpolative.toPoint2d triangle |> pointEqualWithin expected


test0 : Test
test0 =
    test "fromPoint2d test 0" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 1) (Point2d.meters 1 1) Point2d.origin

                point =
                    Point2d.origin
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 0 0)


test1 : Test
test1 =
    test "fromPoint2d test 1" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 1) (Point2d.meters 1 1) Point2d.origin

                point =
                    Point2d.meters 0.5 0.5
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 1 0.5)


test2 : Test
test2 =
    test "fromPoint2d test 2" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 1) (Point2d.meters 1 1) Point2d.origin

                point =
                    Point2d.meters 0.25 0.5
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 0.5 0.5)


test3 : Test
test3 =
    test "fromPoint2d line-like triangle test 0" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 1) (Point2d.meters 0 1) Point2d.origin

                point =
                    Point2d.meters 0 0.5
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 0 0.5)


test4 : Test
test4 =
    test "fromPoint2d line-like triangle test 1" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from Point2d.origin (Point2d.meters 0 1) Point2d.origin

                point =
                    Point2d.meters 0 0.5
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 0.5 0)


test5 : Test
test5 =
    test "fromPoint2d point-like triangle" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from Point2d.origin Point2d.origin Point2d.origin

                point =
                    Point2d.meters 0 0
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 0 0)


test6 : Test
test6 =
    test "fromPoint2d with reversed winding order" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 1) (Point2d.meters -1 1) Point2d.origin

                point =
                    Point2d.meters -0.25 0.5
            in
            Interpolative.fromPoint2d triangle point |> Interpolative.toPoint2d triangle |> pointEqualWithin point


test7 : Test
test7 =
    test "fromPoint2d outside of triangle" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 1) (Point2d.meters -1 1) Point2d.origin

                point =
                    Point2d.meters 0.1 0.5
            in
            Interpolative.fromPoint2d triangle point |> Expect.equal (Interpolative.from 0 0.5)


test8 : Test
test8 =
    test "fromTriangleSide test 0" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from Point2d.origin (Point2d.meters 0 1) (Point2d.meters 1 1)

                expected =
                    Point2d.meters 0.5 0.5
            in
            Interpolative.fromTriangleSide 0.5 TriangleEdge.EdgeTwo |> Interpolative.toPoint2d triangle |> pointEqualWithin expected


test9 : Test
test9 =
    test "fromTriangleSide test 1" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from Point2d.origin (Point2d.meters 1 1) (Point2d.meters 1 0)

                expected =
                    Point2d.meters 0.5 0.5
            in
            Interpolative.fromTriangleSide 0.5 TriangleEdge.EdgeZero |> Interpolative.toPoint2d triangle |> pointEqualWithin expected


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
    Fuzz.map3 Triangle2d.from
        fuzzPoint2d
        fuzzPoint2d
        fuzzPoint2d


equalWithin expected actual =
    (abs (expected - actual) < 0.01)
        || (abs (expected - actual) < (abs expected * 0.01))


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
