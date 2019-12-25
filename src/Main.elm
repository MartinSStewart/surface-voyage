module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events
import Element
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Keyboard exposing (Key)
import Length exposing (Meters)
import Math.Vector3 as Vec3
import Math.Vector4 as Vec4
import Mesh exposing (SurfacePoint)
import MeshBuilder
import Point3d
import Vector3d
import WebGL
import WebGLView



---- MODEL ----


type alias Model =
    { keys : List Key
    , previousKeys : List Key
    , windowSize : ( Int, Int )
    , surfacePoint : SurfacePoint Meters
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
      , surfacePoint =
            Mesh.nearestSurfacePoint (Point3d.meters 2 0 0) surfaceCube
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
            keyMsgUpdate keyMsg model

        WindowResize width height ->
            { model | windowSize = ( width, height ) } |> addCmdNone


keyMsgUpdate keyMsg model =
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


baseCube =
    MeshBuilder.cube
        |> MeshBuilder.map
            (Point3d.translateBy
                (Vector3d.meters
                    -0.5
                    -0.5
                    -0.5
                )
            )


renderCube =
    baseCube
        |> MeshBuilder.map
            (\a ->
                { color = Vec4.vec4 0.5 0.5 0.5 1
                , position = Point3d.toVec3 a
                , normal = Vec3.vec3 0 0 1
                }
            )
        |> MeshBuilder.toWebGlMesh


surfaceCube =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices baseCube
    in
    case Mesh.fromVerticesAndIndices verts indices of
        Ok mesh ->
            mesh

        Err error ->
            error |> Debug.toString |> Debug.todo



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout [] <|
        Element.html <|
            WebGLView.view model.windowSize renderCube


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
