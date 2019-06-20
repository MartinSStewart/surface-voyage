module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Keyboard exposing (Key)



---- MODEL ----


type alias Model =
    { keys : List Key
    , previousKeys : List Key
    }


init : ( Model, Cmd Msg )
init =
    ( { keys = []
      , previousKeys = []
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.Msg


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


addCmdNone : a -> ( a, Cmd msg )
addCmdNone a =
    ( a, Cmd.none )


addCmd : Cmd msg -> a -> ( a, Cmd msg )
addCmd cmd a =
    ( a, cmd )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [] []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map KeyMsg Keyboard.subscriptions
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
