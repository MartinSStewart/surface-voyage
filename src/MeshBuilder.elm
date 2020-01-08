module MeshBuilder exposing (MeshPart(..), Vertex, circle, colorToVec4, cube, line, map, splitFacesCube, square, square2, toVerticesAndIndices, toWebGlMesh)

import Array exposing (Array)
import Basics.Extra exposing (flip)
import Color exposing (Color)
import LineSegment2d exposing (LineSegment2d)
import ListHelper as List
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import Mesh
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Quantity
import Triangle exposing (Triangle)
import Vector2d exposing (Vector2d)
import Vector3d exposing (Vector3d)
import WebGL exposing (Mesh)


type MeshPart a
    = TriangleFan a a a (List a)
    | Triangles (List ( a, a, a ))
    | TriangleStrip Bool a a a (List a)
    | VerticesAndIndices (List a) (List ( Int, Int, Int ))
    | Compound (List (MeshPart a))


triangleStrip first second third rest =
    TriangleStrip False first second third rest


type alias Vertex =
    { color : Vec4
    , position : Vec3
    , normal : Vec3
    }


map : (a -> b) -> MeshPart a -> MeshPart b
map mapFunc meshPart =
    case meshPart of
        TriangleFan first second third rest ->
            TriangleFan (mapFunc first) (mapFunc second) (mapFunc third) (List.map mapFunc rest)

        Triangles list ->
            Triangles
                (List.map
                    (\( first, second, third ) -> ( mapFunc first, mapFunc second, mapFunc third ))
                    list
                )

        TriangleStrip flipped first second third rest ->
            TriangleStrip flipped (mapFunc first) (mapFunc second) (mapFunc third) (List.map mapFunc rest)

        VerticesAndIndices vertices indices ->
            VerticesAndIndices (List.map mapFunc vertices) indices

        Compound list ->
            List.map (map mapFunc) list |> Compound


flipFaces : MeshPart a -> MeshPart a
flipFaces meshPart =
    case meshPart of
        TriangleFan first second third rest ->
            case List.reverse (second :: third :: rest) of
                newSecond :: newThird :: newRest ->
                    TriangleFan first newSecond newThird newRest

                _ ->
                    TriangleFan first third second []

        Triangles list ->
            List.map (\( a, b, c ) -> ( c, b, a )) list |> Triangles

        TriangleStrip flipped first second third rest ->
            TriangleStrip (not flipped) first second third rest

        VerticesAndIndices vertices indices ->
            VerticesAndIndices
                vertices
                (List.map (\( a, b, c ) -> ( c, b, a )) indices)

        Compound list ->
            List.map flipFaces list |> Compound


toWebGlMesh : MeshPart a -> Mesh a
toWebGlMesh meshPart =
    toMesh_ Array.empty [] [ meshPart ]
        |> (\( vertices, indices ) -> WebGL.indexedTriangles (Array.toList vertices) indices)


addTriangle vertices indices first second third =
    let
        newVertices =
            [ first, second, third ] |> Array.fromList |> Array.append vertices

        vertexCount =
            Array.length vertices

        newIndices =
            ( vertexCount, vertexCount + 1, vertexCount + 2 ) :: indices
    in
    ( newVertices, newIndices )


toVerticesAndIndices : MeshPart a -> ( Array a, List (Triangle Int) )
toVerticesAndIndices meshPart =
    toMesh_ Array.empty [] [ meshPart ]


toMesh_ : Array a -> List (Triangle Int) -> List (MeshPart a) -> ( Array a, List (Triangle Int) )
toMesh_ vertices indices meshPartsLeft =
    case meshPartsLeft of
        head :: rest ->
            case head of
                TriangleFan first second third rest_ ->
                    let
                        ( newVertices, newIndices ) =
                            addTriangle vertices indices first second third

                        vertexCount =
                            Array.length newVertices

                        restIndices =
                            List.range 0 (List.length rest_ - 1)
                                |> List.map
                                    (\index ->
                                        ( vertexCount - 3
                                        , vertexCount + index - 1
                                        , vertexCount + index
                                        )
                                    )
                                |> flip (++) newIndices

                        restVertices =
                            rest_ |> Array.fromList |> Array.append newVertices
                    in
                    toMesh_ restVertices restIndices rest

                Triangles triplets ->
                    let
                        newVertices =
                            List.concatMap (\( v0, v1, v2 ) -> [ v0, v1, v2 ]) triplets
                                |> Array.fromList
                                |> Array.append vertices

                        vertexCount =
                            Array.length vertices

                        newIndices =
                            List.range 0 (List.length triplets)
                                |> List.map
                                    (\index ->
                                        ( vertexCount + index * 3
                                        , vertexCount + index * 3 + 1
                                        , vertexCount + index * 3 + 2
                                        )
                                    )
                                |> (++) indices
                    in
                    toMesh_ newVertices newIndices rest

                TriangleStrip flipped first second third rest_ ->
                    let
                        ( newVertices, newIndices ) =
                            if flipped then
                                addTriangle vertices indices third second first

                            else
                                addTriangle vertices indices first second third

                        vertexCount =
                            Array.length newVertices

                        restIndices =
                            List.range 0 (List.length rest_ - 1)
                                |> List.map
                                    (\index ->
                                        let
                                            isEven =
                                                modBy 2 index == 0
                                        in
                                        if isEven /= flipped then
                                            ( vertexCount + index
                                            , vertexCount + index - 1
                                            , vertexCount + index - 2
                                            )

                                        else
                                            ( vertexCount + index - 2
                                            , vertexCount + index - 1
                                            , vertexCount + index
                                            )
                                    )
                                |> flip (++) newIndices

                        restVertices =
                            rest_ |> Array.fromList |> Array.append newVertices
                    in
                    toMesh_ restVertices restIndices rest

                VerticesAndIndices vertices_ indices_ ->
                    let
                        vertexCount =
                            Array.length vertices

                        newVertices =
                            vertices_ |> Array.fromList |> Array.append vertices

                        newIndices =
                            indices
                                ++ List.map
                                    (\( a, b, c ) -> ( a + vertexCount, b + vertexCount, c + vertexCount ))
                                    indices_
                    in
                    toMesh_ newVertices newIndices rest

                Compound list ->
                    toMesh_ vertices indices (list ++ rest)

        [] ->
            ( vertices, indices )


circle : Int -> MeshPart (Point2d u c)
circle detail =
    let
        tau =
            pi * 2

        getPoint index =
            Point2d.xy
                (Quantity.Quantity (sin (tau * index / toFloat detail)))
                (Quantity.Quantity (cos (tau * index / toFloat detail)))
    in
    TriangleFan 0 1 2 (List.range 3 (detail - 1))
        |> map (toFloat >> getPoint)


square : MeshPart (Point2d u c)
square =
    TriangleFan ( 0, 0 ) ( 0, 1 ) ( 1, 1 ) [ ( 1, 0 ) ]
        |> map (\( x, y ) -> Point2d.xy (Quantity.Quantity x) (Quantity.Quantity y))


square2 : MeshPart (Point2d u c)
square2 =
    TriangleFan ( 0, 0 ) ( 1, 0 ) ( 0, 1 ) []
        |> map (\( x, y ) -> Point2d.xy (Quantity.Quantity x) (Quantity.Quantity y))


line : Float -> LineSegment2d u c -> MeshPart (Point2d u c)
line thickness lineSegment =
    let
        start =
            LineSegment2d.startPoint lineSegment

        end =
            LineSegment2d.endPoint lineSegment

        v0 =
            Vector2d.from start end
                |> Vector2d.perpendicularTo
                |> Vector2d.normalize
                |> Vector2d.unwrap
                |> (\{ x, y } -> Vector2d.xy (Quantity.Quantity x) (Quantity.Quantity y))
                |> Vector2d.scaleBy thickness

        v1 =
            Vector2d.reverse v0
    in
    TriangleFan
        (Point2d.translateBy v1 start)
        (Point2d.translateBy v0 start)
        (Point2d.translateBy v0 end)
        [ Point2d.translateBy v1 end ]


lineStrip : Float -> Int -> List (Point2d u c) -> MeshPart (Point2d u c)
lineStrip thickness detail points =
    let
        bends =
            points
                |> List.drop 1
                |> List.dropLast
                |> List.map
                    (\position ->
                        circle detail
                            |> map (Point2d.scaleAbout Point2d.origin thickness)
                            |> map (Point2d.translateBy (Vector2d.from Point2d.origin position))
                    )
    in
    List.pairwise points
        |> List.map (LineSegment2d.fromEndpoints >> line thickness)
        |> (++) bends
        |> Compound


splitFacesCube : MeshPart { position : Point3d u c, cubeFaceIndex : Int }
splitFacesCube =
    [ TriangleFan ( 0, 0, 0 ) ( 0, 1, 0 ) ( 1, 1, 0 ) [ ( 1, 0, 0 ) ] -- Bottom
    , TriangleFan ( 0, 0, 1 ) ( 1, 0, 1 ) ( 1, 1, 1 ) [ ( 0, 1, 1 ) ] -- Top
    , TriangleFan ( 0, 0, 0 ) ( 1, 0, 0 ) ( 1, 0, 1 ) [ ( 0, 0, 1 ) ] -- Back
    , TriangleFan ( 0, 1, 0 ) ( 0, 1, 1 ) ( 1, 1, 1 ) [ ( 1, 1, 0 ) ] -- Front
    , TriangleFan ( 0, 0, 0 ) ( 0, 0, 1 ) ( 0, 1, 1 ) [ ( 0, 1, 0 ) ] -- Left
    , TriangleFan ( 1, 0, 0 ) ( 1, 1, 0 ) ( 1, 1, 1 ) [ ( 1, 0, 1 ) ] -- Right
    ]
        |> List.indexedMap Tuple.pair
        |> List.map
            (\( index, triangleFan ) ->
                map (\p -> { position = Point3d.fromTuple Quantity.Quantity p, cubeFaceIndex = index }) triangleFan
            )
        |> Compound


cube : MeshPart (Point3d u c)
cube =
    VerticesAndIndices
        [ --Bottom
          ( 0, 0, 0 )
        , ( 1, 0, 0 )
        , ( 0, 1, 0 )
        , ( 1, 1, 0 )

        -- Top
        , ( 0, 0, 1 )
        , ( 1, 0, 1 )
        , ( 0, 1, 1 )
        , ( 1, 1, 1 )
        ]
        [ -- Bottom
          ( 0, 2, 1 )
        , ( 3, 1, 2 )

        -- Top
        , ( 6, 4, 5 )
        , ( 5, 7, 6 )

        --Front
        , ( 7, 3, 2 )
        , ( 7, 2, 6 )

        --Back
        , ( 5, 0, 1 )
        , ( 5, 4, 0 )

        --Right
        , ( 0, 6, 2 )
        , ( 4, 6, 0 )

        --Left
        , ( 1, 3, 5 )
        , ( 3, 7, 5 )
        ]
        |> map (Point3d.fromTuple Quantity.Quantity)


colorToVec4 color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Vec4.vec4 (red * alpha) (green * alpha) (blue * alpha) alpha
