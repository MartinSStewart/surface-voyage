module SurfaceMesh.Path exposing (Path, edgeNormals, endPoint, worldPath)

import Basics.Extra exposing (flip)
import Direction3d exposing (Direction3d)
import LineSegment3d exposing (LineSegment3d)
import List.Nonempty as Nonempty
import Polyline3d exposing (Polyline3d)
import SurfaceMesh.SurfacePoint as SurfacePoint exposing (SurfacePoint)
import SurfaceMesh.Types as Types


type alias Path units coordinates =
    Types.Path units coordinates


endPoint : Path units coordinates -> SurfacePoint units
endPoint (Types.Path path) =
    path |> Nonempty.head |> Tuple.second


edgeNormals :
    Types.Mesh units coordinates
    -> Path units coordinates
    -> Maybe (List ( LineSegment3d units coordinates, Direction3d coordinates ))
edgeNormals mesh (Types.Path path) =
    let
        ( _, head ) =
            Nonempty.head path

        rest =
            Nonempty.tail path |> List.map Tuple.first

        list =
            path
                |> Nonempty.toList
                |> List.filterMap
                    (\( start, end ) ->
                        case
                            ( SurfacePoint.getNormal mesh start
                            , SurfacePoint.worldPosition start mesh
                            , SurfacePoint.worldPosition end mesh
                            )
                        of
                            ( Just normal, Just start_, Just end_ ) ->
                                Just ( LineSegment3d.from start_ end_, normal )

                            _ ->
                                Nothing
                    )
    in
    if Nonempty.length path == List.length list then
        list |> List.reverse |> Just

    else
        Nothing


worldPath : Types.Mesh units coordinates -> Path units coordinates -> Maybe (Polyline3d units coordinates)
worldPath mesh (Types.Path path) =
    let
        ( _, head ) =
            Nonempty.head path

        rest =
            Nonempty.tail path |> List.map Tuple.first

        list =
            head :: rest |> List.filterMap (flip SurfacePoint.worldPosition mesh)
    in
    if Nonempty.length path == List.length list then
        list |> List.reverse |> Polyline3d.fromVertices |> Just

    else
        Nothing
