module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html.Styled exposing (..)
import Url


tasks =
    [ { title = "One"
      , description = ""
      , status = ""
      }
    , { title = "Two"
      , description = ""
      , status = ""
      }
    ]


type Msg
    = NoOp


type alias Model =
    { noop : String }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    ( { noop = "" }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Tasks"
    , body =
        [ toUnstyled <|
            div []
                [ text "app" ]
        ]
    }


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    NoOp


onUrlChange : Url.Url -> Msg
onUrlChange url =
    NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


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
