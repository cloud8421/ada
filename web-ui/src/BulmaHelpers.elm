module BulmaHelpers
    exposing
        ( Icon(..)
        , actionButton
        , block
        , blockWithNew
        , cancelButton
        , dangerActionButton
        , dangerTag
        , emailInput
        , iconButton
        , lightTag
        , saveButton
        , tableHead
        , tag
        , tagWithAddon
        , tags
        , tagsWithAddons
        , textInput
        , titleBar
        )

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


tagWithAddon : String -> String -> List (Html msg)
tagWithAddon name value =
    [ span [ class "tag is-primary" ]
        [ text name ]
    , span [ class "tag" ] [ text value ]
    ]


tagsWithAddons : List ( String, String ) -> Html msg
tagsWithAddons pairs =
    div [ class "control" ]
        [ div [ class "tags has-addons" ] (List.concatMap (\( n, v ) -> tagWithAddon n v) pairs)
        ]


tag : String -> Html msg
tag name =
    span [ class "tag is-primary" ]
        [ text name ]


tags : List String -> Html msg
tags names =
    div [ class "control" ]
        [ div [ class "tags" ]
            (List.map tag names)
        ]


lightTag : String -> Html msg
lightTag name =
    span [ class "tag is-light" ]
        [ text name ]


lightTags : List String -> Html msg
lightTags names =
    div [ class "control" ]
        [ div [ class "tags" ]
            (List.map lightTag names)
        ]


dangerTag : String -> Html msg
dangerTag name =
    span [ class "tag is-danger" ]
        [ text name ]


dangerTags : List String -> Html msg
dangerTags names =
    div [ class "control" ]
        [ div [ class "tags" ]
            (List.map dangerTag names)
        ]


tableHead : List String -> Html msg
tableHead columnNames =
    let
        cell columnName =
            th [] [ text columnName ]
    in
    thead [] [ tr [] (List.map cell columnNames) ]


textInput : List (Attribute msg) -> Html msg
textInput attributes =
    let
        defaultAttributes =
            [ class "input"
            , type_ "text"
            ]
    in
    input (defaultAttributes ++ attributes) []


emailInput : List (Attribute msg) -> Html msg
emailInput attributes =
    let
        defaultAttributes =
            [ class "input"
            , type_ "text"
            ]
    in
    input (defaultAttributes ++ attributes) []


saveButton : List (Attribute msg) -> Html msg
saveButton attributes =
    let
        defaultAttributes =
            [ class "button is-link"
            , type_ "button"
            , value "Save"
            ]
    in
    input (defaultAttributes ++ attributes) []


cancelButton : List (Attribute msg) -> Html msg
cancelButton attributes =
    let
        defaultAttributes =
            [ class "button is-text"
            , type_ "button"
            , value "Cancel"
            ]
    in
    input (defaultAttributes ++ attributes) []
