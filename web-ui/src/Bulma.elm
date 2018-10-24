module Bulma exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Icon
    = Edit
    | Delete
    | Run
    | Activate


iconButton : Icon -> Html msg
iconButton icon =
    let
        iconClass =
            case icon of
                Edit ->
                    "fa-edit"

                Delete ->
                    "fa-trash"

                Run ->
                    "fa-play"

                Activate ->
                    "fa-check"
    in
    span [ class "icon is-small" ]
        [ i [ class ("fas " ++ iconClass) ]
            []
        ]


block : String -> msg -> Html msg -> Html msg
block blockTitle newMsg contents =
    section [ class "section column is-6" ]
        [ div [ class "panel" ]
            [ div [ class "panel-heading" ]
                [ text blockTitle
                ]
            , div [ class "panel-block" ]
                [ contents
                ]
            , div [ class "panel-block" ]
                [ button
                    [ class "button is-link"
                    , onClick newMsg
                    ]
                    [ text "Add New" ]
                ]
            ]
        ]
