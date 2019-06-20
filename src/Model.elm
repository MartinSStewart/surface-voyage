module Model exposing (Mesh, Triangle)

import Dict exposing (Dict)
import LineSegment3d exposing (LineSegment3d)
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import SketchPlane3d exposing (SketchPlane3d)
import Triangle3d exposing (Triangle3d)
import Vector2d exposing (Vector2d)


adjacentTriangles : Mesh -> Dict ( TriangleId, TriangleEdge ) TriangleId
adjacentTriangles mesh =
    Debug.todo ""
