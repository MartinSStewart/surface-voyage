module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Lamdera
import Main
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    let
        ( game, cmd ) =
            Main.init
    in
    ( { key = key
      , game = game
      }
    , Cmd.map GameMsg cmd
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        GameMsg gameMsg ->
            let
                ( game, cmd ) =
                    Main.update gameMsg model.game
            in
            ( { model | game = game }, Cmd.map GameMsg cmd )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


subscriptions : Model -> Sub FrontendMsg
subscriptions model =
    Main.subscriptions model.game |> Sub.map GameMsg


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "Surface Voyage"
    , body = [ Main.view model.game |> Html.map GameMsg ]
    }
