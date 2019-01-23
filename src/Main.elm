module Main exposing (main)

import Browser
import Browser.Events as DOMEvents
import Browser.Navigation as Nav
import Css as C
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Url


type Msg
    = AddTask
    | HandleKeyStroke KeyPress
    | NoOp


type alias Model =
    { tasks : List Task }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    ( { tasks = [] }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask ->
            ( { model
                | tasks =
                    { title = ""
                    , description = ""
                    , status = ""
                    }
                        :: model.tasks
              }
            , Cmd.none
            )

        HandleKeyStroke key ->
            case key of
                AppendNewLine ->
                    update AddTask model

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Tasks"
    , body =
        [ toUnstyled <|
            div
                [ css
                    [ C.displayFlex
                    , C.width <| C.pct 100
                    , C.height <| C.pct 100
                    , C.justifyContent C.center
                    ]
                ]
                [ taskList model ]
        ]
    }



-- TASK LIST


taskList : Model -> Html Msg
taskList model =
    div []
        (model.tasks
            |> List.map (task model)
        )


task : Model -> Task -> Html Msg
task model t =
    div
        [ css
            [ C.border3 (C.px 2) C.solid (C.hex "5e5e5e")
            , C.width <| C.px 150
            , C.height <| C.px 48
            ]
        ]
        [ text t.title ]


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    NoOp


onUrlChange : Url.Url -> Msg
onUrlChange url =
    NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown HandleKeyStroke ]


type KeyPress
    = Down
    | AppendNewLine
    | PrependNewLine
    | NoOpKey


type alias KeyEvent =
    { key : String }


keyPress : Decoder KeyPress
keyPress =
    Decode.map KeyEvent
        (Decode.field "key" Decode.string)
        |> Decode.map
            (\event ->
                case event.key of
                    "j" ->
                        Down

                    "o" ->
                        AppendNewLine

                    "O" ->
                        PrependNewLine

                    _ ->
                        NoOpKey
            )


onKeyDown : (KeyPress -> Msg) -> Sub Msg
onKeyDown tagger =
    DOMEvents.onKeyDown (Decode.map tagger keyPress)


main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


type alias Task =
    { title : String
    , description : String
    , status : String
    }
