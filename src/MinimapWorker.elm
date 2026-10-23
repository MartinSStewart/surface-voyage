port module MinimapWorker exposing (main)

{-| Works out what the minimap shows, in a web worker so that the game doesn't stutter while it does.
The game sends where the player is to `drawMinimap` and gets the drawing back from `minimapDrawn`
(see elm-pkg-js/minimap-worker.js). When the player has placed walls since, it sends those too. When
a world is imported from a STEP file, it sends the file, and the minimap shows that world from then on.

This isn't part of the Lamdera app, so it's compiled on its own:

    lamdera make src / MinimapWorker.elm --optimize --output=public/minimap-worker-elm.js

-}

import Json.Decode
import Json.Encode
import MeshData exposing (WorldCoordinate)
import Minimap
import Shapes exposing (Shapes)
import StepImport
import Surface exposing (Surface)


port drawMinimap : (Json.Decode.Value -> msg) -> Sub msg


port minimapDrawn : Json.Encode.Value -> Cmd msg


type Msg
    = DrawMinimap Json.Decode.Value


type alias Model =
    { surface : Maybe (Surface WorldCoordinate), shapes : Shapes }


main : Program () Model Msg
main =
    Platform.worker
        { init = \() -> ( { surface = Result.toMaybe MeshData.surface, shapes = MeshData.mapShapes }, Cmd.none )
        , update = update
        , subscriptions = \_ -> drawMinimap DrawMinimap
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update (DrawMinimap value) model =
    case Json.Decode.decodeValue importDecoder value of
        Ok ( text, scale ) ->
            -- The same import as the game's, so the surface is the same too
            ( { surface = StepImport.surface scale text |> Result.toMaybe, shapes = Shapes.empty }, Cmd.none )

        Err _ ->
            case
                ( Json.Decode.decodeValue
                    (Json.Decode.map2 Tuple.pair
                        (Json.Decode.field "point" Surface.surfacePointDecoder)
                        (Json.Decode.maybe (Json.Decode.field "placedWalls" placedWallsDecoder))
                    )
                    value
                , model.surface
                )
            of
                ( Ok ( point, placedWalls ), Just surface ) ->
                    let
                        withPlaced =
                            case placedWalls of
                                Just walls ->
                                    Shapes.addWalls surface walls model.shapes

                                Nothing ->
                                    model.shapes
                    in
                    ( { model | shapes = withPlaced }
                    , Json.Encode.object
                        [ ( "point", Surface.encodeSurfacePoint point )
                        , ( "drawing", Minimap.drawingAround surface withPlaced point |> Minimap.encodeDrawing )
                        ]
                        |> minimapDrawn
                    )

                _ ->
                    ( model, Cmd.none )


importDecoder : Json.Decode.Decoder ( String, Float )
importDecoder =
    Json.Decode.map2 Tuple.pair
        (Json.Decode.field "step" Json.Decode.string)
        (Json.Decode.field "scale" Json.Decode.float)


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
