module Bulma.Extra exposing (..)

import Bulma.Columns exposing (..)
import Bulma.Components exposing (..)
import Bulma.Elements exposing (..)
import Bulma.Form exposing (..)
import Bulma.Layout exposing (..)
import Bulma.Modifiers exposing (..)
import Html exposing (Attribute, Html, a, i, span, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (..)


topNavBar : List (Html msg) -> Html msg
topNavBar menuLinks =
    let
        robotIcon =
            icon Large [] [ i [ class "fas fa-robot fa-3x" ] [] ]

        topNavbarBurger =
            navbarBurger False
                []
                [ span [] []
                , span [] []
                , span [] []
                ]
    in
    navbar navbarModifiers
        []
        [ navbarBrand []
            topNavbarBurger
            [ navbarItem False [ class "logo" ] [ robotIcon ]
            ]
        , navbarMenu True
            []
            [ navbarEnd [] menuLinks ]
        ]


titleBar : List (Html msg) -> Html msg
titleBar menuLinks =
    hero { heroModifiers | color = Primary }
        []
        [ heroHead [] [ topNavBar menuLinks ] ]


sunIcon : Html msg
sunIcon =
    icon Large [] [ i [ class "fas fa-sun" ] [] ]


tableHeadFromColumnNames : List String -> TablePartition msg
tableHeadFromColumnNames columnNames =
    let
        headCells =
            List.map (\t -> tableCellHead [] [ text t ]) columnNames
    in
    tableHead []
        [ tableRow False [] headCells ]


tableBodyFromItems : (a -> TableRow msg) -> List a -> TablePartition msg
tableBodyFromItems rowFn items =
    tableBody [] (List.map rowFn items)


checkButton : Bool -> List (Attribute msg) -> Html msg
checkButton isActive attributes =
    controlButton
        { buttonModifiers
            | color = Primary
            , size = Small
            , disabled = isActive
            , iconLeft = Just ( Small, [], i [ class "fas fa-check" ] [] )
        }
        []
        attributes
        []


editButton : List (Attribute msg) -> Html msg
editButton attributes =
    controlButton
        { buttonModifiers
            | color = Default
            , size = Small
            , iconLeft = Just ( Small, [], i [ class "fas fa-edit" ] [] )
        }
        []
        attributes
        []


deleteButton : List (Attribute msg) -> Html msg
deleteButton attributes =
    controlButton
        { buttonModifiers
            | color = Danger
            , size = Small
            , iconLeft = Just ( Small, [], i [ class "fas fa-trash" ] [] )
        }
        []
        attributes
        []


newButton : String -> List (Attribute msg) -> Html msg
newButton name attributes =
    button
        { buttonModifiers
            | color = Primary
        }
        attributes
        [ text name ]


runButton : Bool -> List (Attribute msg) -> Html msg
runButton isRunning attributes =
    controlButton
        { buttonModifiers
            | color = Primary
            , size = Small
            , state =
                if isRunning then
                    Loading
                else
                    Active
            , iconLeft = Just ( Small, [], i [ class "fas fa-play" ] [] )
        }
        []
        attributes
        []


saveButton : List (Attribute msg) -> Html msg
saveButton attributes =
    controlButton
        { buttonModifiers
            | color = Primary
        }
        []
        attributes
        [ text "Save" ]


cancelButton : List (Attribute msg) -> Html msg
cancelButton attributes =
    controlButton
        { buttonModifiers
            | color = Primary
            , inverted = True
        }
        []
        attributes
        [ text "Cancel" ]


fullColumns : List (Html msg) -> Html msg
fullColumns =
    columns columnsModifiers []


halfColumn : List (Html msg) -> Html msg
halfColumn =
    column columnModifiers []


dataTable : List (Html msg) -> Html msg
dataTable =
    table
        { tableModifiers
            | striped = True
            , hoverable = True
            , fullWidth = True
        }
        []


infoNotificaton : String -> Html msg
infoNotificaton message =
    notification Info [] [ text message ]


dangerNotification : String -> Html msg
dangerNotification message =
    notification Danger [] [ text message ]


infoTag : String -> Html msg
infoTag =
    easyTag { tagModifiers | color = Primary } []


lightTag : String -> Html msg
lightTag =
    easyTag { tagModifiers | color = Light } []


sectionPanel : String -> List (Html msg) -> Maybe msg -> Html msg
sectionPanel name contents maybeNewMsg =
    let
        basePartitions =
            [ panelHeading [] [ text name ]
            , panelBlock False [] contents
            ]

        newPartition =
            case maybeNewMsg of
                Just newMsg ->
                    [ panelLink False
                        []
                        [ newButton "Add new" [ onClick newMsg ]
                        ]
                    ]

                Nothing ->
                    []
    in
    panel [] (basePartitions ++ newPartition)


textInput : List (Attribute msg) -> Control msg
textInput attributes =
    controlText controlInputModifiers [] attributes []


emailInput : List (Attribute msg) -> Control msg
emailInput attributes =
    let
        emailInputModifiers =
            { controlInputModifiers
                | iconLeft = Just ( Small, [], i [ class "fas fa-envelope" ] [] )
            }
    in
    controlEmail emailInputModifiers [] attributes []


coordInput : List (Attribute msg) -> Control msg
coordInput attributes =
    let
        numberInputModifiers =
            { controlInputModifiers
                | iconLeft = Just ( Small, [], i [ class "fas fa-map" ] [] )
            }

        mergedAttributes =
            attributes ++ [ type_ "number" ]
    in
    controlInput numberInputModifiers [] mergedAttributes []


timeInput : List (Attribute msg) -> Control msg
timeInput attributes =
    let
        timeInputModifiers =
            { controlInputModifiers
                | iconLeft = Just ( Small, [], i [ class "fas fa-clock" ] [] )
            }
    in
    controlInput timeInputModifiers [] (type_ "time" :: attributes) []


minuteInput : List (Attribute msg) -> Control msg
minuteInput attributes =
    let
        minuteInputModifiers =
            { controlInputModifiers
                | iconLeft = Just ( Small, [], i [ class "fas fa-clock" ] [] )
            }
    in
    controlInput minuteInputModifiers [] (type_ "number" :: attributes) []


select : List (Attribute msg) -> List (Option msg) -> Control msg
select attributes options =
    controlSelect controlSelectModifiers
        []
        attributes
        options
