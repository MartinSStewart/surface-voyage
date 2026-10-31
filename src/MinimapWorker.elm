port module MinimapWorker exposing (main)

{-| Works out what the minimap shows, in a web worker so that the game doesn't stutter while it does.
The game sends where the player is to `drawMinimap` and gets the drawing back from `minimapDrawn`
(see elm-pkg-js/minimap-worker.js). When the player has placed or taken away walls or paths since, it
sends all the ones placed too (see `LevelEditor`). When
a world is imported from a STEP file, it sends the file, and the minimap shows that world from then on.
When the level's ground is made of grid pieces and changes, it sends the pieces (see `GridLevel`), or
null to go back to the world made in code.

This isn't part of the Lamdera app, so it's compiled on its own:

    lamdera make src / MinimapWorker.elm --optimize --output=public/minimap-worker-elm.js

-}

import GridLevel
import Json.Decode
import Json.Encode
import MeshData exposing (WorldCoordinate)
import Minimap
import Shapes exposing (Shapes)
import StepImport
import Surface exposing (Surface)
import WorldShapes


port drawMinimap : (Json.Decode.Value -> msg) -> Sub msg


port minimapDrawn : Json.Encode.Value -> Cmd msg


type Msg
    = DrawMinimap Json.Decode.Value


{-| The surface, the shapes the world comes with (none for an imported one), and those with what the
player has placed.
-}
type alias Model =
    { surface : Maybe (Surface WorldCoordinate)
    , own : { walls : List (List ( Float, Float, Float )), pavings : List Shapes.Paving }
    , shapes : Shapes
    }


main : Program () Model Msg
main =
    Platform.worker
        { init =
            \() ->
                ( init, Cmd.none )
        , update = update
        , subscriptions = \_ -> drawMinimap DrawMinimap
        }


{-| The world made in code.
-}
init : Model
init =
    { surface = Result.toMaybe MeshData.surface
    , own = { walls = WorldShapes.walls, pavings = WorldShapes.pavings }
    , shapes = MeshData.mapShapes
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update (DrawMinimap value) model_ =
    case Json.Decode.decodeValue importDecoder value of
        Ok ( text, scale ) ->
            -- The same import as the game's, so the surface is the same too
            ( { surface = StepImport.surface scale text |> Result.toMaybe, own = { walls = [], pavings = [] }, shapes = Shapes.empty }, Cmd.none )

        Err _ ->
            let
                model =
                    case Json.Decode.decodeValue (Json.Decode.field "ground" (Json.Decode.nullable GridLevel.decoder)) value of
                        Ok (Just ground) ->
                            let
                                surface =
                                    GridLevel.surface ground |> Result.toMaybe

                                -- Where the ground ends shows like a wall
                                edges =
                                    GridLevel.openEdges ground
                                        |> List.map (GridLevel.edgeSamples >> List.map (\{ position } -> ( position.x, position.y, position.z )))
                            in
                            { surface = surface
                            , own = { walls = edges, pavings = [] }
                            , shapes = Maybe.map (\surface_ -> Shapes.prepare surface_ edges []) surface |> Maybe.withDefault Shapes.empty
                            }

                        Ok Nothing ->
                            init

                        Err _ ->
                            model_
            in
            case
                ( Json.Decode.decodeValue
                    (Json.Decode.map2 Tuple.pair
                        (Json.Decode.field "point" Surface.surfacePointDecoder)
                        (Json.Decode.maybe (Json.Decode.field "placed" placedDecoder))
                    )
                    value
                , model.surface
                )
            of
                ( Ok ( point, placed ), Just surface ) ->
                    let
                        withPlaced =
                            case placed of
                                Just { walls, paths } ->
                                    Shapes.prepare surface
                                        (model.own.walls ++ walls)
                                        (model.own.pavings ++ List.map (Shapes.pathPaving surface Shapes.pathWidth) paths)

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


{-| The walls and paths placed, each a list of points.
-}
placedDecoder : Json.Decode.Decoder { walls : List (List ( Float, Float, Float )), paths : List (List ( Float, Float, Float )) }
placedDecoder =
    Json.Decode.map2 (\walls paths -> { walls = walls, paths = paths })
        (Json.Decode.field "walls" linesDecoder)
        (Json.Decode.field "paths" linesDecoder)


{-| Lines as lists of points, each point a list of x, y and z in meters.
-}
linesDecoder : Json.Decode.Decoder (List (List ( Float, Float, Float )))
linesDecoder =
    Json.Decode.list
        (Json.Decode.list
            (Json.Decode.map3 (\x y z -> ( x, y, z ))
                (Json.Decode.index 0 Json.Decode.float)
                (Json.Decode.index 1 Json.Decode.float)
                (Json.Decode.index 2 Json.Decode.float)
            )
        )
