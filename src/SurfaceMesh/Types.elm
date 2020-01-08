module SurfaceMesh.Types exposing (..)

import Array exposing (Array)
import Direction2d exposing (Direction2d)
import Point3d exposing (Point3d)
import SketchPlane3d exposing (SketchPlane3d)
import SurfaceMesh.Interpolative exposing (Interpolative)
import SurfaceMesh.Triangle exposing (Triangle)
import SurfaceMesh.TriangleEdge exposing (TriangleEdge)
import Triangle2d exposing (Triangle2d)


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias TriangleData units coordinates =
    { indices : Triangle VertexId
    , sketchPlane : SketchPlane3d units coordinates { defines : SurfaceCoordinate }
    , triangle2d : Triangle2d units SurfaceCoordinate
    , adjacent : Triangle (Maybe AdjacentTriangle)
    }


type alias AdjacentTriangle =
    { adjacentId : TriangleId, adjacentEdge : TriangleEdge }


type alias Mesh_ units coordinates =
    { triangles : Array (TriangleData units coordinates)
    , vertices : Array (Point3d units coordinates)
    }


type alias VertexId_ =
    Int


type TriangleId
    = TriangleId Int


type VertexId
    = VertexId Int


type alias EdgeIndex_ =
    Int


type alias TriangleId_ =
    Int


type alias SurfaceMarkerId_ =
    Int


type SurfacePoint units
    = SurfacePoint SurfacePoint_


type alias SurfacePoint_ =
    { triangleId : TriangleId
    , position : Interpolative
    , direction : Direction2d SurfaceCoordinate
    , faceSide : SurfaceSide
    }


type SurfaceSide
    = Front
    | Back


type SurfaceCoordinate
    = SurfaceCoordinate Never


getTriangleData : TriangleId -> Mesh units coordinates -> Maybe (TriangleData units coordinates)
getTriangleData (TriangleId triangleId) (Mesh mesh) =
    Array.get triangleId mesh.triangles
