module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events
import Color
import Direction2d
import Duration exposing (Duration)
import Element
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html exposing (Html)
import Keyboard exposing (Key)
import KeyboardHelper as Keyboard
import Length exposing (Meters)
import List.Nonempty
import Math.Vector3 as Vec3
import Math.Vector4 as Vec4
import Mesh exposing (SurfacePoint)
import MeshBuilder
import Point2d
import Point3d
import Quantity
import Vector2d
import View



---- MODEL ----


type alias Model =
    { keys : List Key
    , previousKeys : List Key
    , windowSize : ( Int, Int )
    , surfacePoint : SurfacePoint Meters
    , time : Duration
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
            Mesh.nearestSurfacePoint (Point3d.meters 0.2 0.2 1) surfaceCube
      , time = Quantity.zero
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.Msg
    | WindowResize Int Int
    | AnimationFrameDelta Duration


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model |> addCmdNone

        KeyMsg keyMsg ->
            keyMsgUpdate keyMsg model

        WindowResize width height ->
            { model | windowSize = ( width, height ) } |> addCmdNone

        AnimationFrameDelta delta ->
            { model | time = Quantity.plus model.time delta } |> step |> addCmdNone


keyMsgUpdate keyMsg model =
    let
        newKeys =
            Keyboard.update keyMsg model.keys
    in
    { model | keys = newKeys, previousKeys = model.keys }
        |> addCmdNone


step : Model -> Model
step model =
    { model
        | surfacePoint =
            case Keyboard.arrowDown model |> Vector2d.direction of
                Just direction ->
                    Mesh.move
                        surfaceCube
                        (Direction2d.angleFrom Direction2d.y direction)
                        (Length.meters 0.01)
                        model.surfacePoint

                Nothing ->
                    model.surfacePoint
    }


addCmdNone : a -> ( a, Cmd msg )
addCmdNone a =
    ( a, Cmd.none )


addCmd : Cmd msg -> a -> ( a, Cmd msg )
addCmd cmd a =
    ( a, cmd )


baseCube =
    MeshBuilder.cube


colorToVec4 color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    Vec4.vec4 (red * alpha) (green * alpha) (blue * alpha) alpha


cubeColors =
    List.Nonempty.Nonempty (Color.rgb 0.9 0.1 0.1)
        [ Color.rgb 0.1 0.9 0.1
        , Color.rgb 0.1 0.1 0.9
        , Color.rgb 0.9 0.9 0.1
        , Color.rgb 0.9 0.1 0.9
        , Color.rgb 0.1 0.9 0.9
        ]


renderCube =
    MeshBuilder.splitFacesCube
        |> MeshBuilder.map
            (\{ position, cubeFaceIndex } ->
                { color = cubeColors |> List.Nonempty.get cubeFaceIndex |> colorToVec4
                , position = position |> Point3d.toVec3
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


twoTriangleMesh =
    MeshBuilder.square
        |> MeshBuilder.map
            (\point ->
                Point3d.xyz
                    (Point2d.xCoordinate point)
                    (Point2d.yCoordinate point)
                    Quantity.zero
            )


twoTriangleSurface : Mesh.Mesh Meters coordinates
twoTriangleSurface =
    let
        ( verts, indices ) =
            MeshBuilder.toVerticesAndIndices twoTriangleMesh
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
            View.view model model.windowSize renderCube (Mesh.surfacePointToWorld model.surfacePoint surfaceCube)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map KeyMsg Keyboard.subscriptions
        , Browser.Events.onResize WindowResize
        , Browser.Events.onAnimationFrameDelta (Duration.milliseconds >> AnimationFrameDelta)
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
