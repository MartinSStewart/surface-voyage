module KeyboardHelper exposing
    ( Action(..)
    , KeyboardState
    , actionPressed
    , arrowDown
    , buttonPressed
    , isDown
    , isPressed
    , isReleased
    )

import Keyboard exposing (Key(..))
import Keyboard.Arrows
import Quantity
import Toop exposing (..)
import Vector2d exposing (Vector2d)


type alias KeyboardState r =
    { r
        | previousKeys : List Key
        , keys : List Key
    }


buttonPressed : KeyboardState a -> Bool
buttonPressed model =
    isPressed model Keyboard.Spacebar || isPressed model Keyboard.Enter


isPressed : KeyboardState a -> Key -> Bool
isPressed model key =
    List.any ((==) key) model.keys && (List.any ((==) key) model.previousKeys |> not)


isDown : KeyboardState a -> Key -> Bool
isDown model key =
    List.any ((==) key) model.keys


isReleased : KeyboardState a -> Key -> Bool
isReleased model key =
    List.any ((==) key) model.previousKeys


arrowDown : KeyboardState a -> Vector2d units coordinates
arrowDown model =
    let
        { x, y } =
            Keyboard.Arrows.arrows model.keys
    in
    Vector2d.fromTuple Quantity.Quantity ( toFloat x, toFloat y )


type Action
    = UndoAction
    | RedoAction
    | CopyAction
    | PasteAction


actionPressed : KeyboardState a -> Maybe Action
actionPressed keyboardState =
    case
        T7
            (isDown keyboardState Keyboard.Control)
            (isDown keyboardState Keyboard.Shift)
            (isDown keyboardState Keyboard.Alt)
            (isPressed keyboardState (Character "Z"))
            (isPressed keyboardState (Character "Y"))
            (isPressed keyboardState (Character "C"))
            (isPressed keyboardState (Character "V"))
    of
        -- Ctrl + Z
        T7 True False False True False False False ->
            Just UndoAction

        -- Ctrl + Y
        T7 True False False False True False False ->
            Just RedoAction

        -- Ctrl + Shift + Z
        T7 True True False True False False False ->
            Just RedoAction

        -- Ctrl + C
        T7 True False False False False True False ->
            Just CopyAction

        -- Ctrl + V
        T7 True False False False False False True ->
            Just PasteAction

        _ ->
            Nothing
