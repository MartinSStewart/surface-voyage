module MeshData exposing (ScreenCoordinate, WorldCoordinate, mapShapes, roofMeshes, surface, wallCollision, wallMesh, webGlMesh)

import Buildings
import MeshBuilder exposing (Vertex)
import Shapes exposing (Shapes)
import Surface exposing (Surface)
import WallCollision
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


{-| The surface and the paving.
-}
webGlMesh : WebGL.Mesh Vertex
webGlMesh =
    case surface of
        Ok surface_ ->
            WorldMesh.mesh surface_ WorldShapes.pavings

        Err _ ->
            WebGL.triangles []


{-| The walls, for stopping the player.
-}
wallCollision : WallCollision.Walls
wallCollision =
    case surface of
        Ok surface_ ->
            WallCollision.fromShapes surface_ WorldShapes.walls

        Err _ ->
            WallCollision.none


{-| The roofs, each drawn flat on the surface (see `WorldMesh`).
-}
roofMeshes : List ( Buildings.Roof, WebGL.Mesh WorldMesh.WallVertex )
roofMeshes =
    case surface of
        Ok surface_ ->
            List.map (\roof -> ( roof, WorldMesh.roofMesh surface_ Nothing roof )) Buildings.default.roofs

        Err _ ->
            []


{-| The walls and stairs, drawn flat on the surface (see `WorldMesh`).
-}
wallMesh : WebGL.Mesh WorldMesh.WallVertex
wallMesh =
    case surface of
        Ok surface_ ->
            WorldMesh.wallMesh surface_
                { walls = WorldMesh.wallColor, stairs = WorldMesh.stairsColor }
                (List.map (\points -> { points = points, bottom = 0 }) WorldShapes.walls)
                Buildings.default.stairs

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
