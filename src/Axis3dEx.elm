module Axis3dEx exposing (..)

import Axis3d exposing (Axis3d)
import Point2d exposing (Point2d)
import Point3d
import SketchPlane3d exposing (SketchPlane3d)


{-| Try to find the unique intersection point of an axis with a sketch plane. If the axis does not intersect the sketch plane, or if it is coplanar with it (lying perfectly in the sketch plane), returns Nothing.
-}
intersectionWithSketchPlane : SketchPlane3d units coordinates { defines : coordinates2d } -> Axis3d units coordinates -> Maybe (Point2d units coordinates2d)
intersectionWithSketchPlane sketchPlane axis3d =
    Axis3d.intersectionWithPlane (SketchPlane3d.toPlane sketchPlane) axis3d |> Maybe.map (Point3d.projectInto sketchPlane)
