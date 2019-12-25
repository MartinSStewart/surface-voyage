module Point2dExTests exposing (..)

import Angle
import Basics.Extra exposing (flip)
import Direction2d
import Expect
import Fuzz
import Length exposing (Meters)
import LineSegment2d
import Point2d
import Point2dEx
import Quantity
import Test exposing (Test, fuzz, fuzz2, test)
import Triangle2d exposing (Triangle2d)


fuzzPointInside : Test
fuzzPointInside =
    fuzz2 fuzzNonDegenerateTriangle fuzzStInsideTriangle "Handle point inside triangle" <|
        \triangle ( s, t ) ->
            let
                ( t0, t1, t2 ) =
                    Triangle2d.vertices triangle

                point =
                    LineSegment2d.from t0 t1
                        |> flip LineSegment2d.interpolate s
                        |> LineSegment2d.from t2
                        |> flip LineSegment2d.interpolate t
            in
            Point2dEx.insideTriangle triangle point |> Expect.equal True


pointOutsideTest1 : Test
pointOutsideTest1 =
    test "Point is outside triangle" <|
        \_ ->
            let
                triangle =
                    Triangle2d.from (Point2d.meters 0 0) (Point2d.meters 1 0) (Point2d.meters 1 1)

                point =
                    Point2d.meters 0 1
            in
            Point2dEx.insideTriangle triangle point |> Expect.equal False


pointOutsideTest2 : Test
pointOutsideTest2 =
    fuzz2 fuzzNonDegenerateTriangle fuzzStOutsideTriangle "Random points outside triangle" <|
        \triangle ( s, t ) ->
            let
                ( t0, t1, t2 ) =
                    Triangle2d.vertices triangle

                point =
                    LineSegment2d.from t0 t1
                        |> flip LineSegment2d.interpolate s
                        |> LineSegment2d.from t2
                        |> flip LineSegment2d.interpolate t
            in
            Point2dEx.insideTriangle triangle point |> Expect.equal False


fuzzPoint2d =
    fuzzPoint2dRange -1000 1000


fuzzPoint2dRange low high =
    Fuzz.map2 Point2d.meters
        (Fuzz.floatRange low high)
        (Fuzz.floatRange low high)


fuzzStInsideTriangle =
    Fuzz.map2 Tuple.pair
        (Fuzz.floatRange 0.01 0.99)
        (Fuzz.floatRange 0.01 0.99)


fuzzStOutsideTriangle =
    Fuzz.map2 Tuple.pair
        (Fuzz.floatRange 1.01 3)
        (Fuzz.floatRange 1.01 3)


fuzzNonDegenerateTriangle : Fuzz.Fuzzer (Triangle2d Meters coordinates)
fuzzNonDegenerateTriangle =
    Fuzz.map5
        (\t0 dir length dir2 length2Scale ->
            let
                t1 =
                    Point2d.translateIn dir length Point2d.origin

                t2 =
                    Point2d.translateIn dir2 (Quantity.multiplyBy length2Scale length) t1
            in
            Triangle2d.from t0 t1 t2
        )
        fuzzPoint2d
        (Fuzz.floatRange 0 360 |> Fuzz.map (Angle.degrees >> Direction2d.fromAngle))
        (Fuzz.floatRange 1 100 |> Fuzz.map Length.meters)
        (Fuzz.floatRange 15 345 |> Fuzz.map (Angle.degrees >> Direction2d.fromAngle))
        (Fuzz.floatRange 0.1 10)
