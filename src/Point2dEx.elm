module Point2dEx exposing (..)

import Point2d exposing (Point2d)
import Quantity
import Triangle2d exposing (Triangle2d)


insideTriangle : Triangle2d u c -> Point2d u c -> Bool
insideTriangle triangle point =
    let
        -- Code translated from https://stackoverflow.com/a/2049593
        ( t0, t1, t2 ) =
            Triangle2d.vertices triangle

        d1 =
            pointSign point t0 t1

        d2 =
            pointSign point t1 t2

        d3 =
            pointSign point t2 t0

        hasNeg =
            d1 < 0 || d2 < 0 || d3 < 0

        hasPos =
            d1 > 0 || d2 > 0 || d3 > 0
    in
    not (hasNeg && hasPos)


rawQuantity (Quantity.Quantity quantity) =
    quantity


pointSign p1 p2 p3 =
    let
        ( p1x, p1y ) =
            Point2d.toTuple rawQuantity p1

        ( p2x, p2y ) =
            Point2d.toTuple rawQuantity p2

        ( p3x, p3y ) =
            Point2d.toTuple rawQuantity p3
    in
    (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y)
