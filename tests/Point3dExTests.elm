module Point3dExTests exposing (..)

import Angle
import Axis3d
import Basics.Extra exposing (flip)
import Direction2d
import Direction3d
import Expect
import Fuzz
import Length exposing (Meters)
import LineSegment3d
import Point2d
import Point3d
import Point3dEx
import Quantity
import Test exposing (Test, describe, fuzz, fuzz2, fuzz3, only, test)
import Triangle3d exposing (Triangle3d)


all : Test
all =
    describe "A Test Suite"
        [ describe "nearestPointOnTriangle"
            [ fuzz2 fuzzPoint3d fuzzPoint3d "Handle point-like triangle" <|
                \point trianglePos ->
                    Point3dEx.nearestPointOnTriangle (pointLikeTriangle trianglePos) point |> pointEqualWithin trianglePos
            , fuzz3 fuzzPoint3d fuzzPoint3d fuzzPoint3d "Handle line-like triangle 0" <|
                \point triangleStart triangleEnd ->
                    let
                        expected =
                            Point3dEx.nearestPointOnLineSegment (LineSegment3d.from triangleStart triangleEnd) point

                        actual =
                            Point3dEx.nearestPointOnTriangle (lineLikeTriangle0 triangleStart triangleEnd) point
                    in
                    pointEqualWithin expected actual
            , fuzz3 fuzzPoint3d fuzzPoint3d fuzzPoint3d "Handle line-like triangle 1" <|
                \point triangleStart triangleEnd ->
                    let
                        expected =
                            Point3dEx.nearestPointOnLineSegment (LineSegment3d.from triangleStart triangleEnd) point

                        actual =
                            Point3dEx.nearestPointOnTriangle (lineLikeTriangle1 triangleStart triangleEnd) point
                    in
                    pointEqualWithin expected actual
            , fuzz3 fuzzPoint3d fuzzPoint3d fuzzPoint3d "Handle line-like triangle 2" <|
                \point triangleStart triangleEnd ->
                    let
                        expected =
                            Point3dEx.nearestPointOnLineSegment (LineSegment3d.from triangleStart triangleEnd) point

                        actual =
                            Point3dEx.nearestPointOnTriangle (lineLikeTriangle2 triangleStart triangleEnd) point
                    in
                    pointEqualWithin expected actual
            , test "Handle line-like triangle" <|
                \_ ->
                    let
                        start =
                            Point3d.meters 0 0 0

                        end =
                            Point3d.meters 1 0 0

                        point =
                            Point3d.meters 0 0 0

                        actual =
                            Point3dEx.nearestPointOnTriangle (lineLikeTriangle0 start end) point
                    in
                    Expect.equal (Point3d.meters 0 0 0) actual
            , test "Handle point outside of triangle 0" <|
                \_ ->
                    let
                        triangle =
                            Triangle3d.from
                                (Point3d.meters 1 0 0)
                                (Point3d.meters 0 1 0)
                                (Point3d.meters 1 1 0)
                    in
                    Point3dEx.nearestPointOnTriangle triangle (Point3d.meters 1.1 -0.1 1) |> pointEqualWithin (Point3d.meters 1 0 0)
            , test "Handle point outside of triangle 1" <|
                \_ ->
                    let
                        triangle =
                            Triangle3d.from
                                (Point3d.meters 1 0 0)
                                (Point3d.meters 0 1 0)
                                (Point3d.meters 1 1 0)
                    in
                    Point3dEx.nearestPointOnTriangle triangle (Point3d.meters 1.1 1.1 1) |> pointEqualWithin (Point3d.meters 1 1 0)
            , test "Handle point outside of triangle 2" <|
                \_ ->
                    let
                        triangle =
                            Triangle3d.from
                                (Point3d.meters 1 0 0)
                                (Point3d.meters 0 1 0)
                                (Point3d.meters 1 1 0)
                    in
                    Point3dEx.nearestPointOnTriangle triangle (Point3d.meters -0.1 1.1 1) |> pointEqualWithin (Point3d.meters 0 1 0)

            --, fuzz2 fuzzNonDegenerateTriangle fuzzSt "Handle point over triangle" <|
            --    \triangle ( s, t ) ->
            --        let
            --            ( t0, t1, t2 ) =
            --                Triangle3d.vertices triangle
            --
            --            expected =
            --                LineSegment3d.from t0 t1
            --                    |> flip LineSegment3d.interpolate s
            --                    |> LineSegment3d.from t2
            --                    |> flip LineSegment3d.interpolate t
            --
            --            point =
            --                Point3d.translateIn (Triangle3d.normalDirection triangle |> Maybe.withDefault Direction3d.x)
            --                    (Length.meters 2.34)
            --                    expected
            --        in
            --        Point3dEx.nearestPointOnTriangle triangle point |> pointEqualWithin expected
            ]
        , describe "nearestPointOnLineSegment"
            [ test "Test 0" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 0 0 0) (Point3d.meters 1 0 0))
                        (Point3d.meters 0.5 1 0)
                        |> pointEqualWithin (Point3d.meters 0.5 0 0)
            , test "Test 1" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 1 0 1) (Point3d.meters 5 0 5))
                        (Point3d.meters 1.5 1 1.5)
                        |> pointEqualWithin (Point3d.meters 1.5 0 1.5)
            , test "Clamps to start point" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 1 0 1) (Point3d.meters 5 0 5))
                        (Point3d.meters 0.5 1 0.5)
                        |> pointEqualWithin (Point3d.meters 1 0 1)
            , test "Clamps to end point" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 1 0 1) (Point3d.meters 5 0 5))
                        (Point3d.meters 5.5 1 5.5)
                        |> pointEqualWithin (Point3d.meters 5 0 5)
            , fuzz2 fuzzPoint3d fuzzPoint3d "Handle point-like line" <|
                \point linePoint ->
                    Point3dEx.nearestPointOnLineSegment (LineSegment3d.from linePoint linePoint) point
                        |> pointEqualWithin linePoint
            ]
        ]


fuzzSt =
    Fuzz.map2 Tuple.pair
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)


fuzzPoint3d =
    fuzzPoint3dRange -100000 100000


fuzzPoint3dRange low high =
    Fuzz.map3 Point3d.meters
        (Fuzz.floatRange low high)
        (Fuzz.floatRange low high)
        (Fuzz.floatRange low high)


fuzzNonDegenerateTriangle : Fuzz.Fuzzer (Triangle3d Meters coordinates)
fuzzNonDegenerateTriangle =
    Fuzz.map5
        (\t0 dir length dir2 ( length2Scale, triangleRotation ) ->
            let
                t1_ =
                    Point2d.translateIn dir length Point2d.origin

                t2_ =
                    Point2d.translateIn dir2 (Quantity.multiplyBy length2Scale length) t1_

                t1 =
                    Point3d.xyz (Point2d.xCoordinate t1_) (Point2d.xCoordinate t1_) Quantity.zero

                t2 =
                    Point3d.xyz (Point2d.xCoordinate t2_) (Point2d.xCoordinate t2_) Quantity.zero
            in
            Triangle3d.from t0 t1 t2 |> Triangle3d.rotateAround Axis3d.x triangleRotation
        )
        fuzzPoint3d
        (Fuzz.floatRange 0 360 |> Fuzz.map (Angle.degrees >> Direction2d.fromAngle))
        (Fuzz.floatRange 1 100 |> Fuzz.map Length.meters)
        (Fuzz.floatRange 15 345 |> Fuzz.map (Angle.degrees >> Direction2d.fromAngle))
        (Fuzz.map2 Tuple.pair
            (Fuzz.floatRange 0.1 10)
            (Fuzz.floatRange 0 360 |> Fuzz.map Angle.degrees)
        )


equalWithin expected actual =
    (abs (expected - actual) < 0.001)
        || (abs (expected - actual) < (abs expected * 0.001))


pointEqualWithin expected actual =
    let
        ( ex, ey, ez ) =
            Point3d.toTuple rawQuantity expected

        ( ax, ay, az ) =
            Point3d.toTuple rawQuantity actual
    in
    if equalWithin ex ax && equalWithin ey ay && equalWithin ez az then
        Expect.pass

    else
        Expect.fail ("Expected: " ++ pointToString expected ++ "    Actual: " ++ pointToString actual)


pointToString point =
    let
        ( x, y, z ) =
            Point3d.toTuple rawQuantity point
    in
    "(" ++ String.fromFloat x ++ ", " ++ String.fromFloat y ++ ", " ++ String.fromFloat z ++ ")"


rawQuantity (Quantity.Quantity quantity) =
    quantity


pointLikeTriangle point =
    Triangle3d.from point point point


lineLikeTriangle0 point0 point1 =
    Triangle3d.from point0 point1 point1


lineLikeTriangle1 point0 point1 =
    Triangle3d.from point1 point0 point1


lineLikeTriangle2 point0 point1 =
    Triangle3d.from point1 point1 point0
