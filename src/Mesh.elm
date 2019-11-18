module Mesh exposing (Mesh, Triangle, TriangleEdge(..), TriangleId, VertexId, getTriangle, getTriangleEdge)

import Dict exposing (Dict)
import LineSegment3d exposing (LineSegment3d)
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import SketchPlane3d exposing (SketchPlane3d)
import Triangle3d exposing (Triangle3d)
import Vector2d exposing (Vector2d)


type Mesh units coordinates
    = Mesh (Mesh_ units coordinates)


type alias Mesh_ units coordinates =
    { triangles : Dict TriangleId (Triangle VertexId)
    , vertices : Dict VertexId (Point3d units coordinates)
    , surfaceMarkers : Dict SurfaceMarkerId (SurfaceMarker units coordinates)
    , idCounter : Int
    }


type alias VertexId =
    Int


type alias TriangleId =
    Int


type alias SurfaceMarkerId =
    Int


type alias Triangle a =
    { v0 : a
    , v1 : a
    , v2 : a
    }


type TriangleEdge
    = SideOne
    | SideTwo
    | SideThree


getTriangleEdge : TriangleEdge -> Triangle3d units coordinates -> LineSegment3d units coordinates
getTriangleEdge triangleEdge triangle =
    let
        ( first, second, third ) =
            Triangle3d.edges triangle
    in
    case triangleEdge of
        SideOne ->
            first

        SideTwo ->
            second

        SideThree ->
            third


getTriangle : Mesh units coordinates -> TriangleId -> Maybe (Triangle3d units coordinates)
getTriangle (Mesh mesh) triangleId =
    Dict.get triangleId mesh.triangles
        |> Maybe.andThen
            (\{ v0, v1, v2 } ->
                Maybe.map3
                    (\v0_ v1_ v2_ -> Triangle3d.fromVertices ( v0_, v1_, v2_ ))
                    (Dict.get v0 mesh.vertices)
                    (Dict.get v1 mesh.vertices)
                    (Dict.get v2 mesh.vertices)
            )


type alias AdjacentTriangle =
    { triangleId : TriangleId, flipped : Bool }


adjacentTriangle : Mesh units coordinates -> TriangleId -> TriangleEdge -> Maybe AdjacentTriangle
adjacentTriangle mesh triangleId =
    Debug.todo ""


type SurfaceMarker units coordinates
    = SurfaceMarker (SurfaceMarker_ units coordinates)


type alias SurfaceMarker_ units coordinates =
    { triangleId : TriangleId
    , position : Point2d units coordinates
    , side : SurfaceSide
    }


type SurfaceSide
    = Front
    | Back


addSurfaceMarker :
    SurfaceMarker units coordinates
    -> Mesh units coordinates
    -> ( SurfaceMarkerId, Mesh units coordinates )
addSurfaceMarker marker (Mesh mesh) =
    { mesh
        | surfaceMarkers = Dict.insert mesh.idCounter marker mesh.surfaceMarkers
        , idCounter = mesh.idCounter + 1
    }
        |> Mesh
        |> Tuple.pair mesh.idCounter


removeSurfaceMarker : SurfaceMarkerId -> Mesh units coordinates -> Mesh units coordinates
removeSurfaceMarker markerId (Mesh mesh) =
    { mesh
        | surfaceMarkers = Dict.remove markerId mesh.surfaceMarkers
    }
        |> Mesh


type MeshSurfaceCoordinates
    = MeshSurfaceCoordinates Never


getSketchPlane :
    Mesh units coordinates
    -> SurfaceMarker units coordinates
    -> Maybe (SketchPlane3d units coordinates { defines : MeshSurfaceCoordinates })
getSketchPlane mesh (SurfaceMarker marker) =
    getTriangle mesh marker.triangleId
        |> Maybe.andThen
            (\triangle ->
                let
                    ( first, second, third ) =
                        Triangle3d.vertices triangle
                in
                SketchPlane3d.throughPoints first second third
            )


move :
    Mesh units coordinates
    -> Vector2d units coordinates
    -> SurfaceMarker units coordinates
    -> SurfaceMarker units coordinates
move mesh movement position =
    case getSketchPlane mesh position of
        Just triangle ->
            let
                a =
                    5
            in
            Debug.todo ""

        Nothing ->
            position
