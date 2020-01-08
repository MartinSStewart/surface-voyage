module SurfaceMesh.TriangleData exposing (TriangleData, worldTriangle)

import SurfaceMesh.Types
import Triangle3d exposing (Triangle3d)


type alias TriangleData units coordinates =
    SurfaceMesh.Types.TriangleData units coordinates


worldTriangle : TriangleData units coordinates -> Triangle3d units coordinates
worldTriangle { sketchPlane, triangle2d } =
    Triangle3d.on sketchPlane triangle2d
