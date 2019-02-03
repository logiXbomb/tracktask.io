port module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events as DOMEvents
import Browser.Navigation as Nav
import Css as C
import Css.Global exposing (global, selector)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)
import List.Extra as LE
import Task
import Url


icon : String -> Html Msg
icon str =
    i [ class "material-icons" ]
        [ text str ]


type IOError
    = ItFailed


type Status
    = Done
    | ToDo



-- MSG


type Msg
    = AddTask
    | UpdateTaskList TaskListResponse
    | UpdateTaskTitle String String
    | HandleKeyStroke KeyPress
    | NoOp



-- MODEL


type alias Model =
    { activeTask : String
    , mode : Mode
    , tasks : List Task
    , navKey : Nav.Key
    , pendingKey : Maybe KeyPress
    }


type Mode
    = Insert
    | Normal



-- INIT


type alias Flags =
    { tasks : List Task
    , activeTask : String
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { activeTask = flags.activeTask
      , mode = Normal
      , tasks = flags.tasks
      , navKey = key
      , pendingKey = Nothing
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTask ->
            ( model
            , addTask ()
            )

        UpdateTaskList rsp ->
            ( { model
                | tasks = rsp.taskList
                , activeTask = rsp.activeTask
              }
            , Dom.focus "active-task"
                |> Task.attempt (\_ -> NoOp)
            )

        UpdateTaskTitle index title ->
            ( { model
                | tasks =
                    model.tasks
                        |> List.map
                            (\t ->
                                if t.id == index then
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

                Up ->
                    case model.pendingKey of
                        Just pk ->
                            ( { model | pendingKey = Nothing }
                            , moveTaskUp model.activeTask
                            )

                        Nothing ->
                            ( { model
                                | activeTask = prevTask model
                              }
                            , Cmd.none
                            )

                InsertMode ->
                    ( { model | mode = Insert }
                    , Dom.focus "active-task"
                        |> Task.attempt (\_ -> NoOp)
                    )

                NormalMode ->
                    ( { model | mode = Normal }
                    , saveTaskList model.tasks
                    )

                PendKey k ->
                    let
                        pendingKey =
                            case k of
                                "m" ->
                                    Just Down

                                "s" ->
                                    Just WaitingStatus

                                _ ->
                                    Nothing
                    in
                    ( { model
                        | pendingKey = pendingKey
                      }
                    , Cmd.none
                    )

                Down ->
                    case model.pendingKey of
                        Just pk ->
                            ( { model | pendingKey = Nothing }
                            , moveTaskDown model.activeTask
                            )

                        Nothing ->
                            ( { model
                                | activeTask = nextTask model
                              }
                            , Cmd.none
                            )

                SetStatus k ->
                    case k of
                        Done ->
                            ( { model | pendingKey = Nothing }
                            , setStatus
                                { activeTask = model.activeTask
                                , status = "done"
                                }
                            )

                        ToDo ->
                            ( { model | pendingKey = Nothing }
                            , setStatus
                                { activeTask = model.activeTask
                                , status = "todo"
                                }
                            )

                NoOpKey ->
                    ( { model | pendingKey = Nothing }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


prevTask : Model -> String
prevTask model =
    let
        index =
            model.tasks
                |> LE.findIndex
                    (\t ->
                        t.id == model.activeTask
                    )
    in
    case index of
        Just idx ->
            model.tasks
                |> LE.getAt (idx - 1)
                |> (\foundTask ->
                        case foundTask of
                            Just t ->
                                t.id

                            Nothing ->
                                model.activeTask
                   )

        Nothing ->
            model.activeTask


nextTask : Model -> String
nextTask model =
    let
        index =
            model.tasks
                |> LE.findIndex
                    (\t ->
                        t.id == model.activeTask
                    )
    in
    case index of
        Just idx ->
            model.tasks
                |> LE.getAt (idx + 1)
                |> (\foundTask ->
                        case foundTask of
                            Just t ->
                                t.id

                            Nothing ->
                                model.activeTask
                   )

        Nothing ->
            model.activeTask



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Tasks"
    , body =
        [ toUnstyled <|
            div
                [ css
                    [ C.displayFlex
                    , C.flexDirection C.column
                    , C.width <| C.pct 100
                    , C.height <| C.pct 100
                    , C.alignItems C.center
                    ]
                ]
                [ h1 []
                    [ text "Track Task" ]
                , taskList model
                , global
                    [ selector "html, body"
                        [ C.margin C.zero
                        , C.padding C.zero
                        , C.fontFamilies
                            [ "Roboto"
                            ]
                        ]
                    , selector "*"
                        [ C.boxSizing C.borderBox ]
                    ]
                ]
        ]
    }



-- TASK LIST


taskList : Model -> Html Msg
taskList model =
    div
        [ css
            [ C.width <| C.pct 100
            ]
        ]
        (model.tasks
            |> List.map (task model)
        )


editTaskStyles =
    css
        [ C.outline C.none
        , C.border C.zero
        ]


task : Model -> Task -> Html Msg
task model t =
    let
        isActive =
            t.id == model.activeTask
    in
    div
        [ css
            [ C.margin2 (C.px 5) (C.px 5)
            , C.displayFlex
            , C.alignItems C.center
            , C.padding <| C.px 16
            , if isActive then
                C.border3 (C.px 2) C.solid (C.hex "00b38a")

              else
                C.border3 (C.px 2) C.solid (C.hex "5e5e5e")
            ]
        ]
        [ if t.status == "done" then
            icon "check_box"

          else
            icon "check_box_outline_blank"
        , div
            [ css
                [ C.marginLeft <| C.px 32
                ]
            ]
            [ if isActive && model.mode == Insert then
                input
                    [ value t.title
                    , id "active-task"
                    , onInput (UpdateTaskTitle t.id)
                    , editTaskStyles
                    ]
                    []

              else
                text t.title
            ]
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
        [ onKeyDown model HandleKeyStroke
        , updateTaskList UpdateTaskList
        ]



-- SHORTCUTS


type KeyPress
    = Down
    | Up
    | InsertMode
    | NormalMode
    | AppendNewLine
    | PendKey String
    | PrependNewLine
    | SetStatus Status
    | WaitingStatus
    | NoOpKey


type alias KeyEvent =
    { key : String }


keyPress : Model -> Decoder KeyPress
keyPress model =
    Decode.map KeyEvent
        (Decode.field "key" Decode.string)
        |> Decode.map
            (\event ->
                if model.pendingKey == Just WaitingStatus then
                    case event.key of
                        "d" ->
                            SetStatus Done

                        "t" ->
                            SetStatus ToDo

                        _ ->
                            NoOpKey

                else if model.mode == Normal then
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

                        "m" ->
                            PendKey "m"

                        "s" ->
                            PendKey "s"

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



-- TASK


type alias Task =
    { id : String
    , title : String
    , status : String
    }


port addTask : () -> Cmd msg


type alias TaskListResponse =
    { activeTask : String
    , taskList : List Task
    }


port updateTaskList : (TaskListResponse -> msg) -> Sub msg


port saveTaskList : List Task -> Cmd msg


port moveTaskUp : String -> Cmd msg


port moveTaskDown : String -> Cmd msg


type alias StatusMessage =
    { activeTask : String
    , status : String
    }


port setStatus : StatusMessage -> Cmd msg
