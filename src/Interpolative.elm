module Interpolative exposing (Interpolative, from, fromPoint2d, toPoint2d, toPoint3d)

import Basics.Extra exposing (flip)
import LineSegment2d
import LineSegment3d
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Triangle2d exposing (Triangle2d)
import Triangle3d exposing (Triangle3d)


type Interpolative units coordinates
    = Interpolative
        { -- How far to interpolate along the first edge of a triangle
          t0 : Float

        -- How far to interpolate along the edge defined by the last vertex of the triangle and the point from t0
        , t1 : Float
        }


from : Float -> Float -> Interpolative units coordinates
from t0 t1 =
    Interpolative
        { t0 = clamp 0 1 t0
        , t1 = clamp 0 1 t1
        }


fromPoint2d : Triangle2d units coordinates -> Point2d units coordinates -> Interpolative units coordinates
fromPoint2d triangle point =
    Debug.todo ""


toPoint2d : Triangle2d units coordinates -> Interpolative units coordinates -> Point2d units coordinates
toPoint2d triangle (Interpolative { t0, t1 }) =
    let
        ( v0, v1, v2 ) =
            Triangle2d.vertices triangle
    in
    LineSegment2d.from v0 v1
        |> flip LineSegment2d.interpolate t0
        |> LineSegment2d.from v2
        |> flip LineSegment2d.interpolate t1


toPoint3d : Triangle3d units coordinates -> Interpolative units coordinates -> Point3d units coordinates
toPoint3d triangle (Interpolative { t0, t1 }) =
    let
        ( v0, v1, v2 ) =
            Triangle3d.vertices triangle
    in
    LineSegment3d.from v0 v1
        |> flip LineSegment3d.interpolate t0
        |> LineSegment3d.from v2
        |> flip LineSegment3d.interpolate t1
