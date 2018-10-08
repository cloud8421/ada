module Main exposing (main)

import Browser exposing (Document)
import Html exposing (h1, text)
import Platform.Cmd as Cmd
import Platform.Sub as Sub


type alias Flags =
    Int


type Msg
    = NoOp


type alias Model =
    { count : Int }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init initialCount =
    ( { count = initialCount }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Ada"
    , body =
        [ h1 [] [ text "Management UI" ]
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
