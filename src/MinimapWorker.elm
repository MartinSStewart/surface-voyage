port module MinimapWorker exposing (main)

{-| Works out what the minimap shows, in a web worker so that the game doesn't stutter while it does.
The game sends where the player is to `drawMinimap` and gets the drawing back from `minimapDrawn`
(see elm-pkg-js/minimap-worker.js).

This isn't part of the Lamdera app, so it's compiled on its own:

    lamdera make src / MinimapWorker.elm --optimize --output=public/minimap-worker-elm.js

-}

import Json.Decode
import Json.Encode
import MeshData
import Minimap
import Surface


port drawMinimap : (Json.Decode.Value -> msg) -> Sub msg


port minimapDrawn : Json.Encode.Value -> Cmd msg


type Msg
    = DrawMinimap Json.Decode.Value


main : Program () () Msg
main =
    Platform.worker
        { init = \() -> ( (), Cmd.none )
        , update = update
        , subscriptions = \() -> drawMinimap DrawMinimap
        }


update : Msg -> () -> ( (), Cmd Msg )
update (DrawMinimap value) () =
    case ( Json.Decode.decodeValue Surface.surfacePointDecoder value, MeshData.surface ) of
        ( Ok point, Ok surface ) ->
            ( ()
            , Json.Encode.object
                [ ( "point", Surface.encodeSurfacePoint point )
                , ( "drawing", Minimap.drawingAround surface MeshData.mapShapes point |> Minimap.encodeDrawing )
                ]
                |> minimapDrawn
            )

        _ ->
            ( (), Cmd.none )
