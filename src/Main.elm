module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events
import Element
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Keyboard exposing (Key)
import WebGL
import WebGLView



---- MODEL ----


type alias Model =
    { keys : List Key
    , previousKeys : List Key
    , windowSize : ( Int, Int )
    }


type alias Flags =
    { windowWidth : Int
    , windowHeight : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { keys = []
      , previousKeys = []
      , windowSize = ( flags.windowWidth, flags.windowHeight )
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model |> addCmdNone

        KeyMsg keyMsg ->
            let
                newKeys =
                    Keyboard.update keyMsg model.keys
            in
            { model | keys = newKeys, previousKeys = model.keys }
                |> addCmdNone

        WindowResize width height ->
            { model | windowSize = ( width, height ) } |> addCmdNone


addCmdNone : a -> ( a, Cmd msg )
addCmdNone a =
    ( a, Cmd.none )


addCmd : Cmd msg -> a -> ( a, Cmd msg )
addCmd cmd a =
    ( a, cmd )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [] <|
        Element.html <|
            WebGLView.view model.windowSize


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map KeyMsg Keyboard.subscriptions
        , Browser.Events.onResize WindowResize
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
