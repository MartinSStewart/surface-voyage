module Point3dEx exposing (nearestPointOnLineSegment, nearestPointOnTriangle)

{-| Finds the nearest point within a triangle.
-}

import LineSegment3d exposing (LineSegment3d)
import Point3d exposing (Point3d)
import Quantity
import Triangle3d exposing (Triangle3d)
import Vector3d


rawQuantity (Quantity.Quantity quantity) =
    quantity


changeUnits : Vector3d.Vector3d unit0 coordinate0 -> Vector3d.Vector3d unit1 coordinate1
changeUnits v =
    Vector3d.toTuple rawQuantity v |> Vector3d.fromTuple Quantity.Quantity


nearestPointOnLineSegment : LineSegment3d units coordinates -> Point3d units coordinates -> Point3d units coordinates
nearestPointOnLineSegment line point =
    let
        lineNormalized =
            LineSegment3d.vector line |> Vector3d.normalize |> changeUnits

        lineStart =
            LineSegment3d.startPoint line

        v =
            Vector3d.from lineStart point

        lineLength =
            LineSegment3d.length line |> rawQuantity

        d =
            Vector3d.dot v lineNormalized |> rawQuantity |> clamp 0 lineLength
    in
    Point3d.translateBy (Vector3d.scaleBy d lineNormalized) lineStart


{-| Find the nearest point on the surface of a triangle.
-}
nearestPointOnTriangle : Triangle3d units coordinates -> Point3d units coordinates -> Point3d units coordinates
nearestPointOnTriangle triangle point =
    let
        --Code translated from https://www.gamedev.net/forums/topic/552906-closest-point-on-triangle/
        ( t0, t1, t2 ) =
            Triangle3d.vertices triangle

        edge0 =
            Vector3d.from t0 t1

        edge1 =
            Vector3d.from t0 t2

        v0 =
            Vector3d.from point t0

        a =
            Vector3d.dot edge0 edge0 |> rawQuantity

        b =
            Vector3d.dot edge0 edge1 |> rawQuantity

        c =
            Vector3d.dot edge1 edge1 |> rawQuantity

        d =
            Vector3d.dot edge0 v0 |> rawQuantity

        e =
            Vector3d.dot edge1 v0 |> rawQuantity

        det =
            a * c - b * b

        s =
            b * e - c * d

        t =
            b * d - a * e

        offset ( s_, t_ ) =
            let
                offset_ =
                    Vector3d.scaleBy s_ edge0 |> Vector3d.plus (Vector3d.scaleBy t_ edge1)
            in
            Point3d.translateBy offset_ t0
    in
    if s + t < det then
        if s < 0 then
            if t < 0 then
                if d < 0 then
                    offset ( clamp 0 1 (-d / a), 0 )

                else
                    offset ( 0, clamp 0 1 (-e / c) )

            else
                offset ( 0, clamp 0 1 (-e / c) )

        else if t < 0 then
            offset ( clamp 0 1 (-d / a), 0 )

        else
            let
                invDet =
                    1 / det
            in
            offset ( s * invDet, t * invDet )

    else if s < 0 then
        let
            tmp0 =
                b + d

            tmp1 =
                c + e
        in
        if tmp1 > tmp0 then
            let
                numer =
                    tmp1 - tmp0

                denom =
                    a - 2 * b + c

                temp =
                    clamp 0 1 (numer / denom)
            in
            offset ( temp, 1 - temp )

        else
            offset ( 0, clamp 0 1 (-e / c) )

    else if t < 0 then
        if a + d > b + e then
            let
                numer =
                    c + e - b - d

                denom =
                    a - 2 * b + c

                temp =
                    clamp 0 1 (numer / denom)
            in
            offset ( temp, 1 - temp )

        else
            offset ( clamp 0 1 (-e / c), 0 )

    else
        let
            division =
                (c + e - b - d) / (a - 2 * b + c)

            temp =
                clamp 0 1 division
        in
        if isInfinite division || isNaN division then
            -- Handle degenerate case with a hack
            if Point3d.distanceFrom t0 t1 |> Quantity.greaterThan (Point3d.distanceFrom t0 t2) then
                nearestPointOnLineSegment (LineSegment3d.from t0 t1) point

            else
                nearestPointOnLineSegment (LineSegment3d.from t0 t2) point

        else
            offset ( temp, 1 - temp )
