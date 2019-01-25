module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events as DOMEvents
import Browser.Navigation as Nav
import Css as C
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Task
import Url


testTasks =
    [ { title = "Pick Up Meds"
      }
    , { title = "JIRA-2584"
      }
    , { title = "Workout" }
    ]


type Msg
    = AddTask
    | UpdateTaskTitle Int String
    | HandleKeyStroke KeyPress
    | NoOp


type alias Model =
    { activeTask : Int
    , mode : Mode
    , tasks : List Task
    }


type Mode
    = Insert
    | Normal


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    ( { activeTask = 0
      , mode = Normal
      , tasks = testTasks
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask ->
            ( { model
                | mode = Insert
                , tasks =
                    { title = ""
                    }
                        :: model.tasks
              }
            , Cmd.none
            )

        UpdateTaskTitle index title ->
            ( { model
                | tasks =
                    model.tasks
                        |> List.indexedMap
                            (\i t ->
                                if i == index then
                                    { t | title = title }

                                else
                                    t
                            )
              }
            , Cmd.none
            )

        HandleKeyStroke key ->
            case key of
                AppendNewLine ->
                    update AddTask model

                Down ->
                    ( { model | activeTask = model.activeTask + 1 }
                    , Cmd.none
                    )

                InsertMode ->
                    ( { model | mode = Insert }
                    , Dom.focus "active-task"
                        |> Task.attempt (\_ -> NoOp)
                    )

                NormalMode ->
                    ( { model | mode = Normal }
                    , Cmd.none
                    )

                Up ->
                    ( { model | activeTask = model.activeTask - 1 }
                    , Cmd.none
                    )

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
            |> List.indexedMap (task model)
        )


task : Model -> Int -> Task -> Html Msg
task model index t =
    let
        isActive =
            index == model.activeTask
    in
    div
        [ css
            [ C.width <| C.px 150
            , C.height <| C.px 48
            , if isActive then
                C.border3 (C.px 3) C.solid (C.hex "00b38a")

              else
                C.border3 (C.px 2) C.solid (C.hex "5e5e5e")
            ]
        ]
        [ if isActive && model.mode == Insert then
            input
                [ value t.title
                , id "active-task"
                , onInput (UpdateTaskTitle index)
                ]
                []

          else
            text t.title
        ]


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    NoOp


onUrlChange : Url.Url -> Msg
onUrlChange url =
    NoOp



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown model HandleKeyStroke ]



-- SHORTCUTS


type KeyPress
    = Down
    | Up
    | InsertMode
    | NormalMode
    | AppendNewLine
    | PrependNewLine
    | NoOpKey


type alias KeyEvent =
    { key : String }


keyPress : Model -> Decoder KeyPress
keyPress model =
    Decode.map KeyEvent
        (Decode.field "key" Decode.string)
        |> Decode.map
            (\event ->
                if model.mode == Normal then
                    case event.key of
                        "k" ->
                            Up

                        "j" ->
                            Down

                        "o" ->
                            AppendNewLine

                        "O" ->
                            PrependNewLine

                        "i" ->
                            InsertMode

                        _ ->
                            NoOpKey

                else
                    case event.key of
                        "Escape" ->
                            NormalMode

                        _ ->
                            NoOpKey
            )


onKeyDown : Model -> (KeyPress -> Msg) -> Sub Msg
onKeyDown model tagger =
    DOMEvents.onKeyDown (Decode.map tagger (keyPress model))


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
    }
