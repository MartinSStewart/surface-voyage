module SurfaceMesh.SurfacePoint exposing (SurfacePoint, directionFromWorldDirection, getNormal, localPosition, pointTowards, rotateBy, triangleId, worldDirection, worldPosition)

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


rotateBy : Angle -> Types.SurfacePoint units -> Types.SurfacePoint units
rotateBy angle (Types.SurfacePoint surfacePoint) =
    Types.SurfacePoint { surfacePoint | direction = Direction2d.rotateBy angle surfacePoint.direction }


setDirection_ : Direction2d Types.SurfaceCoordinate -> Types.SurfacePoint units -> Types.SurfacePoint units
setDirection_ direction (Types.SurfacePoint surfacePoint) =
    Types.SurfacePoint { surfacePoint | direction = direction }


pointTowards : Point3d units coordinates -> Types.Mesh units coordinates -> Types.SurfacePoint units -> Types.SurfacePoint units
pointTowards point mesh surfacePoint =
    case Types.getTriangleData (triangleId surfacePoint) mesh of
        Just triangleData ->
            let
                a =
                    localPosition surfacePoint |> Interpolative.toPoint2d triangleData.triangle2d
            in
            case Point3d.projectInto triangleData.sketchPlane point |> Direction2d.from a of
                Just newDirection ->
                    setDirection_ newDirection surfacePoint

                Nothing ->
                    surfacePoint

        _ ->
            surfacePoint


worldPosition : Types.SurfacePoint unit -> Types.Mesh unit coordinates -> Maybe (Point3d unit coordinates)
worldPosition (Types.SurfacePoint surfacePoint) mesh =
    case Types.getTriangleData surfacePoint.triangleId mesh of
        Just triangleData ->
            Interpolative.toPoint3d (TriangleData.worldTriangle triangleData) surfacePoint.position |> Just

        Nothing ->
            Nothing


directionFromWorldDirection : Direction3d coordinates -> Types.Mesh units coordinates -> Types.SurfacePoint units -> Types.SurfacePoint units
directionFromWorldDirection direction mesh surfacePoint =
    case Types.getTriangleData (triangleId surfacePoint) mesh of
        Just triangleData ->
            case Direction3d.projectInto triangleData.sketchPlane direction of
                Just newDirection ->
                    setDirection_ newDirection surfacePoint

                Nothing ->
                    surfacePoint

        _ ->
            surfacePoint


worldDirection : Types.Mesh units coordinates -> Types.SurfacePoint units -> Maybe (Direction3d coordinates)
worldDirection mesh ((Types.SurfacePoint { direction }) as surfacePoint) =
    case Types.getTriangleData (triangleId surfacePoint) mesh of
        Just triangleData ->
            Direction3d.on triangleData.sketchPlane direction |> Just

        _ ->
            Nothing


getNormal : Types.Mesh units coordinates -> Types.SurfacePoint units -> Maybe (Direction3d coordinates)
getNormal mesh ((Types.SurfacePoint { faceSide }) as surfacePoint) =
    case Types.getTriangleData (triangleId surfacePoint) mesh of
        Just triangleData ->
            case faceSide of
                Types.Front ->
                    SketchPlane3d.normalDirection triangleData.sketchPlane |> Just

                Types.Back ->
                    SketchPlane3d.normalDirection triangleData.sketchPlane |> Direction3d.reverse |> Just

        _ ->
            Nothing


triangleId : Types.SurfacePoint units -> Types.TriangleId
triangleId (Types.SurfacePoint surfacePoint) =
    surfacePoint.triangleId


localPosition : Types.SurfacePoint units -> Interpolative
localPosition (Types.SurfacePoint surfacePoint) =
    surfacePoint.position
