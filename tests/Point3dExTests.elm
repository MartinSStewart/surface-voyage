module Point3dExTests exposing (..)

import Expect
import Fuzz
import LineSegment3d
import Point3d
import Point3dEx
import Quantity
import Set
import Test exposing (Test, describe, fuzz2, fuzz3, only, test)
import Triangle3d


all : Test
all =
    describe "A Test Suite"
        [ describe "nearestPointOnTriangle"
            [ fuzz2 fuzzPoint3d fuzzPoint3d "Handle point-like triangle" <|
                \point trianglePos ->
                    Point3dEx.nearestPointOnTriangle (pointLikeTriangle trianglePos) point |> equalWithin trianglePos
            , only <|
                fuzz3 fuzzPoint3d fuzzPoint3d fuzzPoint3d "Handle line-like triangle 0" <|
                    \point triangleStart triangleEnd ->
                        let
                            expected =
                                Point3dEx.nearestPointOnLineSegment (LineSegment3d.from triangleStart triangleEnd) point

                            actual =
                                Point3dEx.nearestPointOnTriangle (lineLikeTriangle0 triangleStart triangleEnd) point
                        in
                        equalWithin expected actual
            , fuzz3 fuzzPoint3d fuzzPoint3d fuzzPoint3d "Handle line-like triangle 1" <|
                \point triangleStart triangleEnd ->
                    let
                        expected =
                            Point3dEx.nearestPointOnLineSegment (LineSegment3d.from triangleStart triangleEnd) point

                        actual =
                            Point3dEx.nearestPointOnTriangle (lineLikeTriangle1 triangleStart triangleEnd) point
                    in
                    equalWithin expected actual
            , fuzz3 fuzzPoint3d fuzzPoint3d fuzzPoint3d "Handle line-like triangle 2" <|
                \point triangleStart triangleEnd ->
                    let
                        expected =
                            Point3dEx.nearestPointOnLineSegment (LineSegment3d.from triangleStart triangleEnd) point

                        actual =
                            Point3dEx.nearestPointOnTriangle (lineLikeTriangle2 triangleStart triangleEnd) point
                    in
                    equalWithin expected actual
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
            , test "Handle point outside of triangle" <|
                \_ ->
                    let
                        triangle =
                            Triangle3d.from
                                (Point3d.meters 1 0 0)
                                (Point3d.meters 0 1 0)
                                (Point3d.meters 1 1 0)
                    in
                    Point3dEx.nearestPointOnTriangle triangle (Point3d.meters 1.1 -0.1 1) |> equalWithin (Point3d.meters 1 0 0)
            , test "Handle point over triangle" <|
                \_ ->
                    let
                        triangle =
                            Triangle3d.from
                                (Point3d.meters 1 0 0)
                                (Point3d.meters 0 1 0)
                                (Point3d.meters 1 1 0)
                    in
                    Point3dEx.nearestPointOnTriangle triangle (Point3d.meters 0.5 0.6 1) |> equalWithin (Point3d.meters 0.5 0.6 0)
            ]
        , describe "nearestPointOnLineSegment"
            [ test "Test 0" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 0 0 0) (Point3d.meters 1 0 0))
                        (Point3d.meters 0.5 1 0)
                        |> equalWithin (Point3d.meters 0.5 0 0)
            , test "Test 1" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 1 0 1) (Point3d.meters 5 0 5))
                        (Point3d.meters 1.5 1 1.5)
                        |> equalWithin (Point3d.meters 1.5 0 1.5)
            , test "Clamps to start point" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 1 0 1) (Point3d.meters 5 0 5))
                        (Point3d.meters 0.5 1 0.5)
                        |> equalWithin (Point3d.meters 1 0 1)
            , test "Clamps to end point" <|
                \_ ->
                    Point3dEx.nearestPointOnLineSegment
                        (LineSegment3d.from (Point3d.meters 1 0 1) (Point3d.meters 5 0 5))
                        (Point3d.meters 5.5 1 5.5)
                        |> equalWithin (Point3d.meters 5 0 5)
            ]
        ]


fuzzPoint3d =
    Fuzz.map3 Point3d.meters
        Fuzz.float
        Fuzz.float
        Fuzz.float


equalWithin expected actual =
    if Point3d.distanceFrom expected actual |> rawQuantity |> (<) 0.001 then
        Expect.fail ("Expected: " ++ pointToString expected ++ "    Actual: " ++ pointToString actual)

    else
        Expect.pass


pointToString point =
    let
        ( x, y, z ) =
            Point3d.toTuple rawQuantity point
    in
    "(" ++ String.fromFloat x ++ ", " ++ String.fromFloat y ++ ", " ++ String.fromFloat z ++ ")"



--Expect.all
--        [ \( ( x0, _, _ ), ( x1, _, _ ) ) -> abs (x0 - x1) |> Expect.within (Expect.Absolute 0.001) 0
--        , \( ( _, y0, _ ), ( _, y1, _ ) ) -> abs (y0 - y1) |> Expect.within (Expect.Absolute 0.001) 0
--        , \( ( _, _, z0 ), ( _, _, z1 ) ) -> abs (z0 - z1) |> Expect.within (Expect.Absolute 0.001) 0
--        ]
--        ( Point3d.toTuple rawQuantity point0, Point3d.toTuple rawQuantity point1 )


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
