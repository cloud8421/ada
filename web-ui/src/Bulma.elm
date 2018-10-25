module Bulma exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Icon
    = Edit
    | Delete
    | Run
    | Activate


titleBar : String -> Html msg
titleBar title =
    nav [ attribute "aria-label" "main navigation", class "navbar", attribute "role" "navigation" ]
        [ div [ class "navbar-brand" ]
            [ h1 [ class "navbar-item subtitle" ]
                [ text title ]
            ]
        ]


dangerActionButton : Icon -> msg -> Html msg
dangerActionButton icon msg =
    a
        [ class "button is-small is-danger"
        , onClick msg
        ]
        [ iconButton icon ]


actionButton : Icon -> msg -> Html msg
actionButton icon msg =
    a
        [ class "button is-small is-link"
        , onClick msg
        ]
        [ iconButton icon ]


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


tagWithAddons : String -> String -> Html msg
tagWithAddons name value =
    div [ class "control" ]
        [ div [ class "tags has-addons" ]
            [ span [ class "tag" ]
                [ text name ]
            , span [ class "tag" ] [ text value ]
            ]
        ]


tag : String -> Html msg
tag name =
    div [ class "control" ]
        [ div [ class "tags" ]
            [ span [ class "tag" ]
                [ text name ]
            ]
        ]


tableHead : List String -> Html msg
tableHead columnNames =
    thead []
        [ tr [] (List.map (\cn -> th [] [ text cn ]) columnNames) ]
