module World exposing (features, flats, surface)

{-| The game world as flats and features: a slab with rounded edges and corners, and a round hole
through the middle.

The numbers match the Blender model in ObjData so the textured mesh lines up with the surface. The
box and its 0.199 m fillets are exact. The hole is fitted to the mesh: a 0.475 m waist with 0.304 m
fillets rounding out to a 0.780 m rim.

-}

import Angle
import Axis3d
import Direction3d exposing (Direction3d)
import Frame3d
import Length exposing (Meters)
import Point2d
import Point3d
import SketchPlane3d
import Surface exposing (FeatureSpec, FlatEdge(..), FlatSpec, ProfileSegment(..), Sweep(..))
import Vector2d


filletRadius : Float
filletRadius =
    0.198579


{-| The outer box.
-}
box : { min : { x : Float, y : Float, z : Float }, max : { x : Float, y : Float, z : Float } }
box =
    { min = { x = -3.343595, y = -0.401627, z = -2.452917 }
    , max = { x = 4.236575, y = 0.598373, z = 1.992144 }
    }


hole : { x : Float, z : Float, waist : Float, filletRadius : Float }
hole =
    { x = 1.156, z = -0.2058, waist = 0.47524, filletRadius = 0.30432 }


holeRim : Float
holeRim =
    hole.waist + hole.filletRadius


type Axis
    = X
    | Y
    | Z


unit : Axis -> Float -> Direction3d coordinates
unit axis sign =
    case axis of
        X ->
            Direction3d.unsafe { x = sign, y = 0, z = 0 }

        Y ->
            Direction3d.unsafe { x = 0, y = sign, z = 0 }

        Z ->
            Direction3d.unsafe { x = 0, y = 0, z = sign }


{-| The box shrunk by the fillet radius: where the fillets' axes and the corners' centres sit.
-}
inner : Axis -> Float -> Float
inner axis sign =
    let
        get v =
            case axis of
                X ->
                    v.x

                Y ->
                    v.y

                Z ->
                    v.z
    in
    if sign > 0 then
        get box.max - filletRadius

    else
        get box.min + filletRadius


outer : Axis -> Float -> Float
outer axis sign =
    inner axis sign + sign * filletRadius


point : List ( Axis, Float ) -> Point3d.Point3d Meters coordinates
point coordinates =
    let
        get axis =
            coordinates |> List.filter (\( a, _ ) -> a == axis) |> List.head |> Maybe.map Tuple.second |> Maybe.withDefault 0
    in
    Point3d.meters (get X) (get Y) (get Z)


{-| The two other axes in an order that makes a right handed frame with `axis`.
-}
otherAxes : Axis -> ( Axis, Axis )
otherAxes axis =
    case axis of
        X ->
            ( Y, Z )

        Y ->
            ( Z, X )

        Z ->
            ( X, Y )


{-| One face of the box. Its sketch plane faces out of the box and its boundary is the face
without the fillets, counterclockwise.
-}
boxFace : Axis -> Float -> FlatSpec coordinates
boxFace axis sign =
    let
        ( a, b ) =
            if sign > 0 then
                otherAxes axis

            else
                otherAxes axis |> (\( first, second ) -> ( second, first ))

        rectangle =
            [ ( -1, -1 ), ( 1, -1 ), ( 1, 1 ), ( -1, 1 ) ]
                |> List.map (\( sa, sb ) -> Point2d.meters (inner a sa) (inner b sb) |> Straight)

        holeLoop =
            if axis == Y then
                let
                    center =
                        if sign > 0 then
                            -- a = Z, b = X
                            Point2d.meters hole.z hole.x

                        else
                            Point2d.meters hole.x hole.z
                in
                -- Clockwise, so the flat is on its left
                [ [ Arc
                        { start = center |> Point2d.translateBy (Vector2d.meters holeRim 0)
                        , center = center
                        , sweptAngle = Angle.degrees -360
                        }
                  ]
                ]

            else
                []
    in
    { plane =
        SketchPlane3d.unsafe
            { originPoint = point [ ( axis, outer axis sign ) ]
            , xDirection = unit a 1
            , yDirection = unit b 1
            }
    , boundary = rectangle :: holeLoop
    }


{-| A quarter cylinder along the box edge parallel to `along`, on the side given by the signs of the
other two axes.
-}
edgeFillet : Axis -> Float -> Float -> FeatureSpec coordinates
edgeFillet along signA signB =
    let
        ( a, b ) =
            otherAxes along

        -- z = x cross y = sign of the product times `along`
        zSign =
            signA * signB
    in
    { frame =
        Frame3d.unsafe
            { originPoint = point [ ( a, inner a signA ), ( b, inner b signB ) ]
            , xDirection = unit a signA
            , yDirection = unit b signB
            , zDirection = unit along zSign
            }
    , profile =
        -- Up the frame's z axis at the fillet radius, so the outside faces away from the axis
        { start = Point2d.meters filletRadius (zSign * inner along -zSign)
        , segments = [ Line { end = Point2d.meters filletRadius (zSign * inner along zSign) } ]
        }
    , sweep = PartTurn { from = Angle.degrees 0, to = Angle.degrees 90 }
    }


{-| An eighth of a sphere at a box corner, spun around the vertical axis.
-}
corner : Float -> Float -> Float -> FeatureSpec coordinates
corner signX signY signZ =
    let
        -- Pick the horizontal axes so x cross y = signY * up
        ( xDirection, yDirection ) =
            if signX * signY * signZ < 0 then
                ( unit X signX, unit Z signZ )

            else
                ( unit Z signZ, unit X signX )
    in
    { frame =
        Frame3d.unsafe
            { originPoint = point [ ( X, inner X signX ), ( Y, inner Y signY ), ( Z, inner Z signZ ) ]
            , xDirection = xDirection
            , yDirection = yDirection
            , zDirection = unit Y signY
            }
    , profile =
        -- From the equator up to the pole
        { start = Point2d.meters filletRadius 0
        , segments = [ Circle { end = Point2d.meters 0 filletRadius, center = Point2d.origin } ]
        }
    , sweep = PartTurn { from = Angle.degrees 0, to = Angle.degrees 90 }
    }


holeFeature : FeatureSpec coordinates
holeFeature =
    let
        top =
            box.max.y

        bottom =
            box.min.y
    in
    { frame =
        Frame3d.unsafe
            { originPoint = Point3d.meters hole.x 0 hole.z
            , xDirection = Direction3d.x
            , yDirection = Direction3d.negativeZ
            , zDirection = Direction3d.y
            }
    , profile =
        -- From the top rim, down through the waist, to the bottom rim
        { start = Point2d.meters holeRim top
        , segments =
            [ Circle { end = Point2d.meters hole.waist (top - hole.filletRadius), center = Point2d.meters holeRim (top - hole.filletRadius) }
            , Line { end = Point2d.meters hole.waist (bottom + hole.filletRadius) }
            , Circle { end = Point2d.meters holeRim bottom, center = Point2d.meters holeRim (bottom + hole.filletRadius) }
            ]
        }
    , sweep = FullTurn
    }


signs : List Float
signs =
    [ -1, 1 ]


flats : List (FlatSpec coordinates)
flats =
    [ X, Y, Z ] |> List.concatMap (\axis -> List.map (boxFace axis) signs)


features : List (FeatureSpec coordinates)
features =
    holeFeature
        :: ([ X, Y, Z ] |> List.concatMap (\along -> signs |> List.concatMap (\signA -> List.map (edgeFillet along signA) signs)))
        ++ (signs |> List.concatMap (\signX -> signs |> List.concatMap (\signY -> List.map (corner signX signY) signs)))


surface : Result Surface.Error (Surface.Surface coordinates)
surface =
    Surface.build flats features
