port module MinimapPort exposing (drawMinimap, minimapDrawn)

{-| Talking to the web worker that works out what the minimap shows (see `MinimapWorker` and
elm-pkg-js/minimap-worker.js).
-}

import Json.Decode
import Json.Encode


port drawMinimap : Json.Encode.Value -> Cmd msg


port minimapDrawn : (Json.Decode.Value -> msg) -> Sub msg
