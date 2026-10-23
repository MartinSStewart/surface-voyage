port module MinimapWorker exposing (main)

{-| Works out what the minimap shows, in a web worker so that the game doesn't stutter while it does.
The game sends where the player is to `drawMinimap` and gets the drawing back from `minimapDrawn`
(see elm-pkg-js/minimap-worker.js). When the player has placed walls since, it sends those too.

This isn't part of the Lamdera app, so it's compiled on its own:

    lamdera make src / MinimapWorker.elm --optimize --output=public/minimap-worker-elm.js

-}

import Json.Decode
import Json.Encode
import MeshData
import Minimap
import Shapes exposing (Shapes)
import Surface


port drawMinimap : (Json.Decode.Value -> msg) -> Sub msg


port minimapDrawn : Json.Encode.Value -> Cmd msg


type Msg
    = DrawMinimap Json.Decode.Value


main : Program () Shapes Msg
main =
    Platform.worker
        { init = \() -> ( MeshData.mapShapes, Cmd.none )
        , update = update
        , subscriptions = \_ -> drawMinimap DrawMinimap
        }


update : Msg -> Shapes -> ( Shapes, Cmd Msg )
update (DrawMinimap value) shapes =
    case
        ( Json.Decode.decodeValue
            (Json.Decode.map2 Tuple.pair
                (Json.Decode.field "point" Surface.surfacePointDecoder)
                (Json.Decode.maybe (Json.Decode.field "placedWalls" placedWallsDecoder))
            )
            value
        , MeshData.surface
        )
    of
        ( Ok ( point, placedWalls ), Ok surface ) ->
            let
                withPlaced =
                    case placedWalls of
                        Just walls ->
                            Shapes.addWalls surface walls shapes

                        Nothing ->
                            shapes
            in
            ( withPlaced
            , Json.Encode.object
                [ ( "point", Surface.encodeSurfacePoint point )
                , ( "drawing", Minimap.drawingAround surface withPlaced point |> Minimap.encodeDrawing )
                ]
                |> minimapDrawn
            )

        _ ->
            ( shapes, Cmd.none )


{-| Walls as lists of points, each point a list of x, y and z in meters.
-}
placedWallsDecoder : Json.Decode.Decoder (List (List ( Float, Float, Float )))
placedWallsDecoder =
    Json.Decode.list
        (Json.Decode.list
            (Json.Decode.map3 (\x y z -> ( x, y, z ))
                (Json.Decode.index 0 Json.Decode.float)
                (Json.Decode.index 1 Json.Decode.float)
                (Json.Decode.index 2 Json.Decode.float)
            )
        )
