module SurfaceMesh.TriangleData exposing (TriangleData, triangleDataGetTriangle3d)

import SurfaceMesh.Types
import Triangle3d exposing (Triangle3d)


type alias TriangleData units coordinates =
    SurfaceMesh.Types.TriangleData units coordinates


triangleDataGetTriangle3d : TriangleData units coordinates -> Triangle3d units coordinates
triangleDataGetTriangle3d { sketchPlane, triangle2d } =
    Triangle3d.on sketchPlane triangle2d
