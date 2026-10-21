module OBJ exposing (Settings, defaultSettings, parseObjStringWith)

{-| Vendored from declension/elm-obj-loader 1.0.0 with the HTTP loading functions removed,
since that package depends on elm/http 1.x which conflicts with lamdera/core.

@docs Settings, defaultSettings, parseObjStringWith

-}

import OBJ.Assembler exposing (compile)
import OBJ.Parser exposing (parse)
import OBJ.Types exposing (..)


{-| withTangents : If true, vertex tangents will be calculated for meshes with texture coordinates.
This is needed if you want to do tangent space normal mapping.
-}
type alias Settings =
    { withTangents : Bool }


{-| -}
defaultSettings : Settings
defaultSettings =
    { withTangents = False }


{-| Parse the contents of an .obj file.
-}
parseObjStringWith : Settings -> String -> Result String ObjFile
parseObjStringWith config input =
    parse input
        |> Result.map (compile config)
