module MeshData exposing (ScreenCoordinate, WorldCoordinate, mapShapes, surface, webGlMesh)

import MeshBuilder exposing (Vertex)
import Shapes exposing (Shapes)
import Surface exposing (Surface)
import WebGL
import World
import WorldMesh
import WorldShapes


type WorldCoordinate
    = WorldCoordinate Never


type ScreenCoordinate
    = ScreenCoordinate Never


surface : Result Surface.Error (Surface WorldCoordinate)
surface =
    World.surface


{-| The world as it's drawn.
-}
webGlMesh : WebGL.Mesh Vertex
webGlMesh =
    case surface of
        Ok surface_ ->
            WorldMesh.mesh surface_ WorldShapes.walls WorldShapes.pavings

        Err _ ->
            WebGL.triangles []


{-| The shapes drawn on the minimap, moved onto the surface.
-}
mapShapes : Shapes
mapShapes =
    case surface of
        Ok surface_ ->
            Shapes.prepare surface_ WorldShapes.walls WorldShapes.pavings

        Err _ ->
            Shapes.empty
