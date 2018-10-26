module Bulma exposing (Icon(..), actionButton, block, blockWithNew, dangerActionButton, iconButton, lightTag, tableHead, tag, tagWithAddons, titleBar)

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
    section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [ div [ class "container" ]
                [ h1 [ class "title" ]
                    [ text title ]
                ]
            ]
        ]


dangerActionButton : Icon -> msg -> Html msg
dangerActionButton icon msg =
    p [ class "control" ]
        [ a
            [ class "button is-danger"
            , onClick msg
            ]
            [ iconButton icon ]
        ]


actionButton : Icon -> msg -> Html msg
actionButton icon msg =
    p [ class "control" ]
        [ a
            [ class "button is-link"
            , onClick msg
            ]
            [ iconButton icon ]
        ]


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
    span [ class "icon" ]
        [ i [ class ("fas " ++ iconClass) ]
            []
        ]


block : String -> Html msg -> Html msg
block blockTitle contents =
    section [ class "section column is-6" ]
        [ div [ class "panel" ]
            [ div [ class "panel-heading" ]
                [ text blockTitle
                ]
            , div [ class "panel-block" ]
                [ contents
                ]
            ]
        ]


blockWithNew : String -> msg -> Html msg -> Html msg
blockWithNew blockTitle newMsg contents =
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
            [ span [ class "tag is-primary" ]
                [ text name ]
            , span [ class "tag" ] [ text value ]
            ]
        ]


tag : String -> Html msg
tag name =
    div [ class "control" ]
        [ div [ class "tags" ]
            [ span [ class "tag is-primary" ]
                [ text name ]
            ]
        ]


lightTag : String -> Html msg
lightTag name =
    div [ class "control" ]
        [ div [ class "tags" ]
            [ span [ class "tag is-light" ]
                [ text name ]
            ]
        ]


tableHead : List String -> Html msg
tableHead columnNames =
    let
        cell columnName =
            th [] [ text columnName ]
    in
    thead [] [ tr [] (List.map cell columnNames) ]
