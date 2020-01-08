--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- This Source Code Form is subject to the terms of the Mozilla Public        --
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,  --
-- you can obtain one at http://mozilla.org/MPL/2.0/.                         --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


module Vector2i exposing
    ( zero
    , unitless
    , meters, pixels
    , xy
    , fromTuple, toTuple, fromRecord, toRecord
    , fromMeters, toMeters, fromPixels, toPixels, fromUnitless, toUnitless
    , xComponent, yComponent, length, direction
    , lexicographicComparison
    , plus, minus, dot, cross
    , reverse, normalize, scaleBy
    , unsafe, unwrap
    , Vector2i, toVector2d
    )

{-| A `Vector2d` represents a quantity such as a displacement or velocity in 2D,
and is defined by its X and Y components. This module contains a variety of
vector-related functionality, such as

  - Adding or subtracting vectors
  - Finding the lengths of vectors
  - Rotating vectors
  - Converting vectors between different coordinate systems

Note that unlike in many other geometry packages where vectors are used as a
general-purpose data type, `elm-geometry` has separate data types for vectors,
directions and points. In most code it is actually more common to use `Point2d`
and `Direction2d` than `Vector2d`, and much code can avoid working directly with
`Vector2d` values at all!

@docs Vector2d


# Constants

@docs zero

Although there are no predefined constants for the vectors with components
(1,0) and (0,1), in most cases you will actually want their `Direction2d`
versions [`Direction2d.x`](Direction2d#x) and [`Direction2d.y`](Direction2d#y).


# Literals

@docs unitless

The remaining functions all construct a `Vector2d` from X and Y components given
in specific units. Functions like `Vector2d.xy` are more useful in generic code,
but these functions are useful for quickly creating hardcoded constant values,
e.g.

    vector =
        Vector2d.meters 2 3

@docs meters, pixels, millimeters, centimeters, inches, feet


# Constructors

@docs xy, xyIn, rTheta, rThetaIn, from, withLength, perpendicularTo, interpolateFrom


# Interop

These functions are useful for interoperability with other Elm code that uses
plain `Float` tuples or records to represent vectors.

@docs fromTuple, toTuple, fromRecord, toRecord


## Zero-copy conversions

These functions allow zero-overhead conversion of vectors to and from records
with `x` and `y` `Float` fields, useful for efficient interop with other code
that represents vectors as plain records.

@docs fromMeters, toMeters, fromPixels, toPixels, fromUnitless, toUnitless


# Rates of change

@docs per, for


# Properties

@docs xComponent, yComponent, componentIn, length, direction


# Comparison

@docs equalWithin, lexicographicComparison


# Arithmetic

@docs plus, minus, dot, cross


# Transformations

Note that for `mirrorAcross` and `projectOnto`, only the direction of the axis
affects the result, since vectors are position-independent. Think of
mirroring/projecting a vector across/onto an axis as moving the vector so its
tail is on the axis, then mirroring/projecting its tip across/onto the axis.

@docs reverse, normalize, scaleBy, rotateBy, rotateClockwise, rotateCounterclockwise, mirrorAcross, projectionIn, projectOnto


# Unit conversions

@docs at, at_


# Coordinate conversions

Like other transformations, coordinate conversions of vectors depend only on the
orientations of the relevant frames, not the positions of their origin points.

For the examples, assume the following frame has been defined:

    rotatedFrame =
        Frame2d.atOrigin
            |> Frame2d.rotateBy (Angle.degrees 30)

@docs relativeTo, placeIn


# Advanced

These functions are unsafe because they require you to track units manually. In
general you should prefer other functions instead, but these functions may be
useful when writing generic/library code.

@docs unsafe, unwrap

-}

import Direction2d exposing (Direction2d)
import Length exposing (Meters)
import Pixels exposing (Pixels)
import Quantity exposing (Product, Quantity(..), Rate, Squared, Unitless)
import Vector2d exposing (Vector2d)


{-| -}
type Vector2i units coordinates
    = Vector2i { x : Int, y : Int }


{-| Construct a vector from its raw X and Y components as `Float` values. The
values must be in whatever units the resulting point is considered to use
(usually meters or pixels). You should generally use something safer such as
[`meters`](#meters), [`fromPixels`](#fromPixels), [`xy`](#xy),
[`fromRecord`](#fromRecord) etc.
-}
unsafe : { x : Int, y : Int } -> Vector2i units coordinates
unsafe components =
    Vector2i components


{-| Extract a vector's raw X and Y components as `Float` values. These values
will be in whatever units the vector has (usually meters or pixels). You should
generally use something safer such as [`toMeters`](#toMeters),
[`toRecord`](#toRecord), [`xComponent`](#xComponent) etc.
-}
unwrap : Vector2i units coordinates -> { x : Int, y : Int }
unwrap (Vector2i components) =
    components


{-| The vector with components (0,0).
-}
zero : Vector2i units coordinates
zero =
    Vector2i { x = 0, y = 0 }


{-| -}
meters : Int -> Int -> Vector2i Meters coordinates
meters x y =
    Vector2i { x = x, y = y }


{-| -}
pixels : Int -> Int -> Vector2i Pixels coordinates
pixels x y =
    Vector2i { x = x, y = y }


{-| Construct a unitless `Vector2d` value from its X and Y components. See also
[`fromUnitless`](#fromUnitless).
-}
unitless : Int -> Int -> Vector2i Unitless coordinates
unitless x y =
    Vector2i { x = x, y = y }


{-| Construct a vector from its X and Y components.

    vector =
        Vector2d.xy (Length.meters 2) (Length.meters 3)

-}
xy : Quantity Int units -> Quantity Int units -> Vector2i units coordinates
xy (Quantity x) (Quantity y) =
    Vector2i { x = x, y = y }



--{-| Construct a vector from the first given point to the second.
--
--    startPoint =
--        Point2d.meters 1 1
--
--    endPoint =
--        Point2d.meters 4 5
--
--    Vector2d.from startPoint endPoint
--    --> Vector2d.meters 3 4
--
---}
--from : Point2d units coordinates -> Point2d units coordinates -> Vector2d units coordinates
--from (Types.Point2d p1) (Types.Point2d p2) =
--    Types.Vector2d
--        { x = p2.x - p1.x
--        , y = p2.y - p1.y
--        }
--{-| Construct a vector perpendicular to the given vector, by rotating the given
--vector 90 degrees counterclockwise. The constructed vector will have the same
--length as the given vector. Alias for `Vector2d.rotateCounterclockwise`.
--
--    Vector2d.perpendicularTo (Vector2d.meters 1 0)
--    --> Vector2d.meters 0 1
--
--    Vector2d.perpendicularTo (Vector2d.meters 0 2)
--    --> Vector2d.meters -2 0
--
--    Vector2d.perpendicularTo (Vector2d.meters 3 1)
--    --> Vector2d.meters -1 3
--
--    Vector2d.perpendicularTo Vector2d.zero
--    --> Vector2d.zero
--
---}
--perpendicularTo : Vector2i units coordinates -> Vector2i units coordinates
--perpendicularTo givenVector =
--    rotateCounterclockwise givenVector


{-| Construct a `Vector2d` from a tuple of `Float` values, by specifying what units those values are
in.

    Vector2d.fromTuple Length.meters ( 2, 3 )
    --> Vector2d.meters 2 3

-}
fromTuple : (Int -> Quantity Int units) -> ( Int, Int ) -> Vector2i units coordinates
fromTuple toQuantity ( x, y ) =
    xy (toQuantity x) (toQuantity y)


{-| Convert a `Vector2d` to a tuple of `Float` values, by specifying what units you want the result
to be in.

    vector =
        Vector2d.feet 2 3

    Vector2d.toTuple Length.inInches vector
    --> ( 24, 36 )

-}
toTuple : (Quantity Int units -> Int) -> Vector2i units coordinates -> ( Int, Int )
toTuple fromQuantity vector =
    ( fromQuantity (xComponent vector)
    , fromQuantity (yComponent vector)
    )


{-| Construct a `Vector2d` from a record with `Float` fields, by specifying what units those fields
are in.

    Vector2d.fromRecord Length.inches { x = 24, y = 36 }
    --> Vector2d.feet 2 3

-}
fromRecord : (Int -> Quantity Int units) -> { x : Int, y : Int } -> Vector2i units coordinates
fromRecord toQuantity { x, y } =
    xy (toQuantity x) (toQuantity y)


{-| Convert a `Vector2d` to a record with `Float` fields, by specifying what units you want the
result to be in.

    vector =
        Vector2d.meters 2 3

    Vector2d.toRecord Length.inCentimeters vector
    --> { x = 200, y = 300 }

-}
toRecord : (Quantity Int units -> Int) -> Vector2i units coordinates -> { x : Int, y : Int }
toRecord fromQuantity vector =
    { x = fromQuantity (xComponent vector)
    , y = fromQuantity (yComponent vector)
    }


{-| -}
fromMeters : { x : Int, y : Int } -> Vector2i Meters coordinates
fromMeters components =
    Vector2i components


{-| -}
toMeters : Vector2i Meters coordinates -> { x : Int, y : Int }
toMeters (Vector2i components) =
    components


{-| -}
fromPixels : { x : Int, y : Int } -> Vector2i Pixels coordinates
fromPixels components =
    Vector2i components


{-| -}
toPixels : Vector2i Pixels coordinates -> { x : Int, y : Int }
toPixels (Vector2i components) =
    components


{-| -}
fromUnitless : { x : Int, y : Int } -> Vector2i Unitless coordinates
fromUnitless coordinates =
    Vector2i coordinates


{-| -}
toUnitless : Vector2i Unitless coordinates -> { x : Int, y : Int }
toUnitless (Vector2i coordinates) =
    coordinates


{-| Get the X component of a vector.

    Vector2d.xComponent (Vector2d.meters 2 3)
    --> Length.meters 2

-}
xComponent : Vector2i units coordinates -> Quantity Int units
xComponent (Vector2i v) =
    Quantity v.x


{-| Get the Y component of a vector.

    Vector2d.yComponent (Vector2d.meters 2 3)
    --> Length.meters 3

-}
yComponent : Vector2i units coordinates -> Quantity Int units
yComponent (Vector2i v) =
    Quantity v.y


{-| Compare two `Vector2d` values lexicographically: first by X component, then
by Y. Can be used to provide a sort order for `Vector2d` values.
-}
lexicographicComparison : Vector2i units coordinates -> Vector2i units coordinates -> Order
lexicographicComparison (Vector2i v1) (Vector2i v2) =
    if v1.x /= v2.x then
        compare v1.x v2.x

    else
        compare v1.y v2.y


{-| Get the length (magnitude) of a vector.

    Vector2d.length (Vector2d.meters 3 4)
    --> Length.meters 5

-}
length : Vector2i units coordinates -> Quantity Float units
length v =
    toVector2d v |> Vector2d.length


toVector2d : Vector2i units coordinates -> Vector2d units coordinates
toVector2d v =
    let
        { x, y } =
            unwrap v
    in
    Vector2d.unsafe { x = toFloat x, y = toFloat y }


{-| Attempt to find the direction of a vector. In the case of a zero vector,
return `Nothing`.

    Vector2d.direction (Vector2d.meters 3 3)
    --> Just (Direction2d.degrees 45)

    Vector2d.direction Vector2d.zero
    --> Nothing

-}
direction : Vector2i units coordinates -> Maybe (Direction2d coordinates)
direction v =
    toVector2d v |> Vector2d.direction


{-| Normalize a vector to have a length of one. Zero vectors are left as-is.

    vector =
        Vector2d.meters 3 4

    Vector2d.normalize vector
    --> Vector2d.meters 0.6 0.8

    Vector2d.normalize Vector2d.zero
    --> Vector2d.zero

**Warning**: `Vector2d.direction` is safer since it forces you to explicitly
consider the case where the given vector is zero. `Vector2d.normalize` is
primarily useful for cases like generating WebGL meshes, where defaulting to a
zero vector for degenerate cases is acceptable, and the overhead of something
like

    Vector2d.direction vector
        |> Maybe.map Direction2d.toVector
        |> Maybe.withDefault Vector2d.zero

(which is functionally equivalent to `Vector2d.normalize vector`) is too high.

-}
normalize : Vector2i units coordinates -> Vector2d Unitless coordinates
normalize v =
    toVector2d v |> Vector2d.normalize


{-| Find the sum of two vectors.

    firstVector =
        Vector2d.meters 1 2

    secondVector =
        Vector2d.meters 3 4

    firstVector |> Vector2d.plus secondVector
    --> Vector2d.meters 4 6

-}
plus : Vector2i units coordinates -> Vector2i units coordinates -> Vector2i units coordinates
plus (Vector2i v2) (Vector2i v1) =
    Vector2i
        { x = v1.x + v2.x
        , y = v1.y + v2.y
        }


{-| Find the difference between two vectors (the second vector minus the first).

    firstVector =
        Vector2d.meters 5 6

    secondVector =
        Vector2d.meters 1 3

    firstVector |> Vector2d.minus secondVector
    --> Vector2d.meters 4 3

Note the argument order: `v1 - v2` would be written as

    v1 |> Vector2d.minus v2

which is the same as

    Vector2d.minus v2 v1

but the _opposite_ of

    Vector2d.minus v1 v2

-}
minus : Vector2i units coordinates -> Vector2i units coordinates -> Vector2i units coordinates
minus (Vector2i v2) (Vector2i v1) =
    Vector2i
        { x = v1.x - v2.x
        , y = v1.y - v2.y
        }


{-| Find the dot product of two vectors.

    firstVector =
        Vector2d.meters 1 2

    secondVector =
        Vector2d.meters 3 4

    firstVector |> Vector2d.dot secondVector
    --> Area.squareMeters 11

-}
dot : Vector2i units2 coordinates -> Vector2i units1 coordinates -> Quantity Int (Product units1 units2)
dot (Vector2i v2) (Vector2i v1) =
    Quantity (v1.x * v2.x + v1.y * v2.y)


{-| Find the scalar 'cross product' of two vectors in 2D. This is useful in many
of the same ways as the 3D cross product:

  - Its length is equal to the product of the lengths of the two given vectors
    and the sine of the angle between them, so it can be used as a metric to
    determine if two vectors are nearly parallel.
  - The sign of the result indicates the direction of rotation from the first
    vector to the second (positive indicates a counterclockwise rotation and
    negative indicates a clockwise rotation), similar to how the direction of
    the 3D cross product indicates the direction of rotation.

Note the argument order: `v1 x v2` would be written as

    v1 |> Vector2d.cross v2

which is the same as

    Vector2d.cross v2 v1

but the _opposite_ of

    Vector2d.cross v1 v2

Some examples:

    firstVector =
        Vector2d.feet 2 0

    secondVector =
        Vector2d.feet 0 3

    firstVector |> Vector2d.cross secondVector
    --> Area.squareFeet 6

    secondVector |> Vector2d.cross firstVector
    --> Area.squareFeet -6

    firstVector |> Vector2d.cross firstVector
    --> Area.squareFeet 0

-}
cross : Vector2i units2 coordinates -> Vector2i units1 coordinates -> Quantity Int (Product units1 units2)
cross (Vector2i v2) (Vector2i v1) =
    Quantity (v1.x * v2.y - v1.y * v2.x)


{-| Reverse the direction of a vector, negating its components.

    Vector2d.reverse (Vector2d.meters -1 2)
    --> Vector2d.meters 1 -2

(This could have been called `negate`, but `reverse` is more consistent with
the naming used in other modules.)

-}
reverse : Vector2i units coordinates -> Vector2i units coordinates
reverse (Vector2i v) =
    Vector2i
        { x = -v.x
        , y = -v.y
        }


{-| Scale the length of a vector by a given scale.

    Vector2d.scaleBy 3 (Vector2d.meters 1 2)
    --> Vector2d.meters 3 6

(This could have been called `multiply` or `times`, but `scaleBy` was chosen as
a more geometrically meaningful name and to be consistent with the `scaleAbout`
name used in other modules.)

-}
scaleBy : Int -> Vector2i units coordinates -> Vector2i units coordinates
scaleBy k (Vector2i v) =
    Vector2i
        { x = k * v.x
        , y = k * v.y
        }
