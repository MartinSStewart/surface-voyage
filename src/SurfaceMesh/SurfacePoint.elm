module SurfaceMesh.SurfacePoint exposing (..)

import Angle exposing (Angle)
import Direction2d exposing (Direction2d)
import Direction3d exposing (Direction3d)
import Point3d exposing (Point3d)
import SketchPlane3d
import SurfaceMesh.Interpolative as Interpolative exposing (Interpolative)
import SurfaceMesh.TriangleData as TriangleData
import SurfaceMesh.Types as Types


type alias SurfacePoint units =
    Types.SurfacePoint units


surfacePointRotateBy : Angle -> Types.SurfacePoint units -> Types.SurfacePoint units
surfacePointRotateBy angle (Types.SurfacePoint surfacePoint) =
    Types.SurfacePoint { surfacePoint | direction = Direction2d.rotateBy angle surfacePoint.direction }


surfacePointSetDirection : Direction2d Types.SurfaceCoordinate -> Types.SurfacePoint units -> Types.SurfacePoint units
surfacePointSetDirection direction (Types.SurfacePoint surfacePoint) =
    Types.SurfacePoint { surfacePoint | direction = direction }


setSurfacePointDirectionTowards : Point3d units coordinates -> Types.Mesh units coordinates -> Types.SurfacePoint units -> Types.SurfacePoint units
setSurfacePointDirectionTowards point mesh surfacePoint =
    case Types.getTriangleData (surfacePointTriangleId surfacePoint) mesh of
        Just triangleData ->
            let
                a =
                    surfacePointPosition surfacePoint |> Interpolative.toPoint2d triangleData.triangle2d
            in
            case Point3d.projectInto triangleData.sketchPlane point |> Direction2d.from a of
                Just newDirection ->
                    surfacePointSetDirection newDirection surfacePoint

                Nothing ->
                    surfacePoint

        _ ->
            surfacePoint


surfacePointToWorld : Types.SurfacePoint unit -> Types.Mesh unit coordinates -> Maybe (Point3d unit coordinates)
surfacePointToWorld (Types.SurfacePoint surfacePoint) mesh =
    case Types.getTriangleData surfacePoint.triangleId mesh of
        Just triangleData ->
            Interpolative.toPoint3d (TriangleData.triangleDataGetTriangle3d triangleData) surfacePoint.position |> Just

        Nothing ->
            Nothing


setSurfacePointDirection : Direction3d coordinates -> Types.Mesh units coordinates -> Types.SurfacePoint units -> Types.SurfacePoint units
setSurfacePointDirection direction mesh surfacePoint =
    case Types.getTriangleData (surfacePointTriangleId surfacePoint) mesh of
        Just triangleData ->
            case Direction3d.projectInto triangleData.sketchPlane direction of
                Just newDirection ->
                    surfacePointSetDirection newDirection surfacePoint

                Nothing ->
                    surfacePoint

        _ ->
            surfacePoint


getSurfacePointDirection : Types.Mesh units coordinates -> Types.SurfacePoint units -> Maybe (Direction3d coordinates)
getSurfacePointDirection mesh ((Types.SurfacePoint { direction }) as surfacePoint) =
    case Types.getTriangleData (surfacePointTriangleId surfacePoint) mesh of
        Just triangleData ->
            Direction3d.on triangleData.sketchPlane direction |> Just

        _ ->
            Nothing


getSurfacePointNormal : Types.Mesh units coordinates -> Types.SurfacePoint units -> Maybe (Direction3d coordinates)
getSurfacePointNormal mesh ((Types.SurfacePoint { faceSide }) as surfacePoint) =
    case Types.getTriangleData (surfacePointTriangleId surfacePoint) mesh of
        Just triangleData ->
            case faceSide of
                Types.Front ->
                    SketchPlane3d.normalDirection triangleData.sketchPlane |> Just

                Types.Back ->
                    SketchPlane3d.normalDirection triangleData.sketchPlane |> Direction3d.reverse |> Just

        _ ->
            Nothing


surfacePointTriangleId : Types.SurfacePoint units -> Types.TriangleId
surfacePointTriangleId (Types.SurfacePoint surfacePoint) =
    surfacePoint.triangleId


surfacePointPosition : Types.SurfacePoint units -> Interpolative
surfacePointPosition (Types.SurfacePoint surfacePoint) =
    surfacePoint.position
