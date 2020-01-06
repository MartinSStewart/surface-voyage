module Interpolative exposing (Interpolative, from, fromPoint2d, fromTriangleSide, toPoint2d, toPoint3d)

import Angle exposing (Angle)
import Basics.Extra exposing (flip)
import Direction2d
import LineSegment2d
import LineSegment3d
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Quantity
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)
import TriangleEdge exposing (TriangleEdge(..))


type Interpolative
    = Interpolative
        { -- How far to interpolate along the first edge of a triangle
          t0 : Float

        -- How far to interpolate along the edge defined by the last vertex of the triangle and the point from t0
        , t1 : Float
        }


from : Float -> Float -> Interpolative
from t0 t1 =
    Interpolative
        { t0 = clamp 0.01 0.99 t0
        , t1 = clamp 0.01 0.99 t1
        }


fromTriangleSide : Float -> TriangleEdge -> Interpolative
fromTriangleSide t triangleEdge =
    case triangleEdge of
        EdgeZero ->
            from t 1

        EdgeOne ->
            from 1 t

        EdgeTwo ->
            from 0 t


fromPoint2d : Triangle2d units coordinates -> Point2d units coordinates -> Interpolative
fromPoint2d triangle point =
    let
        ( v0, v1, v2 ) =
            Triangle2d.vertices triangle

        maybeV2ToV0 =
            Direction2d.from v2 v0

        maybeV2ToPoint =
            Direction2d.from v2 point

        maybeV0ToV1 =
            Direction2d.from v0 v1
    in
    case ( maybeV2ToV0, maybeV2ToPoint, maybeV0ToV1 ) of
        ( _, Nothing, _ ) ->
            from 0 0

        ( Just v2ToV0, Just v2ToPoint, Just v0ToV1 ) ->
            let
                v0ToV2Length =
                    Point2d.distanceFrom v0 v2

                v0ToV1Length =
                    Point2d.distanceFrom v0 v1

                pointAngle : Angle
                pointAngle =
                    Direction2d.angleFrom v2ToPoint v2ToV0

                v0Angle : Angle
                v0Angle =
                    Direction2d.angleFrom (Direction2d.reverse v2ToV0) v0ToV1

                pointV1Angle : Angle
                pointV1Angle =
                    Quantity.sum [ pointAngle, v0Angle, Angle.radians -pi ] |> Quantity.negate

                cDivByC =
                    Quantity.divideBy (Angle.sin pointV1Angle) v0ToV2Length

                b =
                    Quantity.multiplyBy (Angle.sin pointAngle) cDivByC

                t0 =
                    Quantity.ratio b v0ToV1Length

                t0Point =
                    LineSegment2d.interpolate (LineSegment2d.from v0 v1) t0

                t0PointToV2Line =
                    LineSegment2d.from t0Point v2

                t1 =
                    Quantity.ratio
                        (LineSegment2d.from v2 point |> LineSegment2d.length)
                        (LineSegment2d.length t0PointToV2Line)
            in
            from t0 t1

        ( Just _, Just _, Nothing ) ->
            let
                t0PointToV2Line =
                    LineSegment2d.from v0 v2

                t1 =
                    Quantity.ratio
                        (LineSegment2d.from v2 point |> LineSegment2d.length)
                        (LineSegment2d.length t0PointToV2Line)
            in
            from 0 t1

        ( Nothing, Just _, Just _ ) ->
            let
                t0PointToV2Line =
                    LineSegment2d.from v0 v1

                t0 =
                    Quantity.ratio
                        (LineSegment2d.from v0 point |> LineSegment2d.length)
                        (LineSegment2d.length t0PointToV2Line)
            in
            from t0 0

        ( Nothing, Just _, Nothing ) ->
            from 0 0


toPoint2d : Triangle2d units coordinates -> Interpolative -> Point2d units coordinates
toPoint2d triangle (Interpolative { t0, t1 }) =
    let
        ( v0, v1, v2 ) =
            Triangle2d.vertices triangle
    in
    LineSegment2d.from v0 v1
        |> flip LineSegment2d.interpolate t0
        |> LineSegment2d.from v2
        |> flip LineSegment2d.interpolate t1


toPoint3d : Triangle3d units coordinates -> Interpolative -> Point3d units coordinates
toPoint3d triangle (Interpolative { t0, t1 }) =
    let
        ( v0, v1, v2 ) =
            Triangle3d.vertices triangle
    in
    LineSegment3d.from v0 v1
        |> flip LineSegment3d.interpolate t0
        |> LineSegment3d.from v2
        |> flip LineSegment3d.interpolate t1
