module Main exposing (main)

import Browser exposing (Document)
import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, src)
import Html.Events exposing (onClick)
import Http as Http
import Json.Decode as JD
import Json.Encode as JE
import Platform.Cmd as Cmd
import Platform.Sub as Sub
import RemoteData exposing (..)


-- RESOURCE TYPES


type alias Lat =
    Float


type alias Lng =
    Float


type alias Coords =
    ( Lat, Lng )


type alias User =
    { id : Int
    , name : String
    , email : String
    }


type alias Location =
    { id : Int
    , name : String
    , active : Bool
    , coords : Coords
    }



-- SCHEDULE


type alias Hour =
    Int


type alias Minute =
    Int


type alias Second =
    Int


type Frequency
    = Daily Hour Minute
    | Hourly Minute Second
    | UnsupportedFrequency



-- WORKFLOWS


type WorkflowParam
    = UserId Int
    | LocationId Int
    | NewsTag String
    | UnsupportedParam


type WorkflowRequirement
    = RequiresUserId
    | RequiresLocationId
    | RequiresNewsTag
    | UnsupportedRequirement


type alias Workflow =
    { name : String
    , humanName : String
    , requirements : List WorkflowRequirement
    }



-- SCHEDULED TASKS


type alias ScheduledTask =
    { id : Int
    , frequency : Frequency
    , workflowName : String
    , workflowHumanName : String
    , params : List WorkflowParam
    }



-- API - USERS


decodeUser : JD.Decoder User
decodeUser =
    JD.map3 User
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
        (JD.field "email" JD.string)


decodeUsers : JD.Decoder (List User)
decodeUsers =
    JD.list decodeUser


getUsers : Cmd Msg
getUsers =
    Http.get "/users" decodeUsers
        |> RemoteData.sendRequest
        |> Cmd.map UsersResponse



-- API - LOCATIONS


decodeCoords : JD.Decoder Coords
decodeCoords =
    JD.map2 Tuple.pair
        (JD.field "lat" JD.float)
        (JD.field "lng" JD.float)


decodeLocation : JD.Decoder Location
decodeLocation =
    JD.map4 Location
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
        (JD.field "active" JD.bool)
        decodeCoords



-- (JD.field "lat" JD.float)
-- (JD.field "lng" JD.float)


decodeLocations : JD.Decoder (List Location)
decodeLocations =
    JD.list decodeLocation


getLocations : Cmd Msg
getLocations =
    Http.get "/locations" decodeLocations
        |> RemoteData.sendRequest
        |> Cmd.map LocationsResponse



-- API - WORKFLOWS


requirementDecoder : JD.Decoder WorkflowRequirement
requirementDecoder =
    let
        toRequirement reqName =
            case reqName of
                "tag" ->
                    JD.succeed RequiresNewsTag

                "user_id" ->
                    JD.succeed RequiresUserId

                "location_id" ->
                    JD.succeed RequiresLocationId

                otherwise ->
                    JD.succeed UnsupportedRequirement
    in
    JD.string
        |> JD.andThen toRequirement


decodeWorkflow : JD.Decoder Workflow
decodeWorkflow =
    JD.map3 Workflow
        (JD.field "name" JD.string)
        (JD.field "human_name" JD.string)
        (JD.field "requirements" (JD.list requirementDecoder))


decodeWorkflows : JD.Decoder (List Workflow)
decodeWorkflows =
    JD.list decodeWorkflow


getWorkflows : Cmd Msg
getWorkflows =
    Http.get "/workflows" decodeWorkflows
        |> RemoteData.sendRequest
        |> Cmd.map WorkflowsResponse



-- API - SCHEDULED TASKS


frequencyDecoder : JD.Decoder Frequency
frequencyDecoder =
    let
        byFrequencyType freqType =
            case freqType of
                "daily" ->
                    JD.map2 Daily
                        (JD.field "hour" JD.int)
                        (JD.field "minute" JD.int)

                "hourly" ->
                    JD.map2 Hourly
                        (JD.field "minute" JD.int)
                        (JD.field "second" JD.int)

                other ->
                    JD.succeed UnsupportedFrequency
    in
    JD.field "type" JD.string
        |> JD.andThen byFrequencyType


workflowParamDecoder : JD.Decoder WorkflowParam
workflowParamDecoder =
    let
        toParam name =
            case name of
                "user_id" ->
                    JD.map UserId
                        (JD.field "value" JD.int)

                "location_id" ->
                    JD.map LocationId
                        (JD.field "value" JD.int)

                "tag" ->
                    JD.map NewsTag
                        (JD.field "value" JD.string)

                other ->
                    JD.succeed UnsupportedParam
    in
    JD.field "name" JD.string
        |> JD.andThen toParam


decodeScheduledTask : JD.Decoder ScheduledTask
decodeScheduledTask =
    JD.map5 ScheduledTask
        (JD.field "id" JD.int)
        (JD.field "frequency" frequencyDecoder)
        (JD.field "workflow_name" JD.string)
        (JD.field "workflow_human_name" JD.string)
        (JD.field "params" (JD.list workflowParamDecoder))


decodeScheduledTasks : JD.Decoder (List ScheduledTask)
decodeScheduledTasks =
    JD.list decodeScheduledTask


getScheduledTasks : Cmd Msg
getScheduledTasks =
    Http.get "/scheduled_tasks" decodeScheduledTasks
        |> RemoteData.sendRequest
        |> Cmd.map ScheduledTasksResponse


executeScheduledTask : Int -> Cmd Msg
executeScheduledTask taskId =
    emptyPut ("/scheduled_tasks/" ++ String.fromInt taskId ++ "/execute")
        |> RemoteData.sendRequest
        |> Cmd.map ExecuteScheduledTaskResponse


emptyPut : String -> Http.Request ()
emptyPut url =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody (JE.string "")
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }



-- VIEWS


type Icon
    = Edit
    | Delete
    | Run


iconButton : Icon -> Html Msg
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
    in
    span [ class "icon is-small" ]
        [ i [ class ("fas " ++ iconClass) ]
            []
        ]


block : String -> Html Msg -> Html Msg
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


titleBar : Html Msg
titleBar =
    nav [ attribute "aria-label" "main navigation", class "navbar", attribute "role" "navigation" ]
        [ div [ class "navbar-brand" ]
            [ h1 [ class "navbar-item subtitle" ]
                [ text "Ada Control Center"
                ]
            ]
        ]


usersSection : WebData (List User) -> Html Msg
usersSection users =
    let
        userRow user =
            tr []
                [ td [] [ text <| String.fromInt user.id ]
                , td [] [ text user.name ]
                , td [] [ text user.email ]
                , td
                    [ class "actions" ]
                    [ a [ class "button is-small is-link" ] [ iconButton Edit ]
                    , a [ class "button is-small is-danger" ] [ iconButton Delete ]
                    ]
                ]

        contentArea =
            case users of
                NotAsked ->
                    h2 [] [ text "Users not loaded" ]

                Loading ->
                    h2 [] [ text "Users loading" ]

                Success items ->
                    table [ class "table is-fullwidth" ]
                        [ thead []
                            [ tr []
                                [ th [] [ text "ID" ]
                                , th [] [ text "Name" ]
                                , th [] [ text "Email" ]
                                , th [] [ text "Actions" ]
                                ]
                            ]
                        , tbody [] (List.map userRow items)
                        ]

                Failure reason ->
                    h2 [] [ text "Some error" ]
    in
    block "Users" contentArea


gMap : Coords -> String -> Html Msg
gMap ( lat, lng ) gmapsApiKey =
    let
        pair =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        mapSrc =
            "https://maps.googleapis.com/maps/api/staticmap?"
                ++ "center="
                ++ pair
                ++ "&"
                ++ "zoom=13&size=300x120&maptype=roadmap&"
                ++ "markers=color:blue%7Clabel:S%7C"
                ++ pair
                ++ "&key="
                ++ gmapsApiKey
    in
    img [ src mapSrc ] []


locationsSection : WebData (List Location) -> String -> Html Msg
locationsSection locations gmapsApiKey =
    let
        coordsLabel ( lat, lng ) =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        activeLabel active =
            if active then
                "active"
            else
                "inactive"

        locationRow location =
            tr []
                [ td [] [ text <| String.fromInt location.id ]
                , td [] [ text location.name ]
                , td [] [ text <| activeLabel location.active ]
                , td [] [ gMap location.coords gmapsApiKey ]
                , td
                    [ class "actions" ]
                    [ a [ class "button is-small is-link" ] [ iconButton Edit ]
                    , a [ class "button is-small is-danger" ] [ iconButton Delete ]
                    ]
                ]

        contentArea =
            case locations of
                NotAsked ->
                    h2 [] [ text "locations not loaded" ]

                Loading ->
                    h2 [] [ text "locations loading" ]

                Success items ->
                    table [ class "table is-fullwidth" ]
                        [ thead []
                            [ tr []
                                [ th [] [ text "ID" ]
                                , th [] [ text "Name" ]
                                , th [] [ text "Status" ]
                                , th [] [ text "Coordinates" ]
                                , th [] [ text "Actions" ]
                                ]
                            ]
                        , tbody [] (List.map locationRow items)
                        ]

                Failure reason ->
                    h2 [] [ text "Some error" ]
    in
    block "Locations" contentArea


workflowsSection : WebData (List Workflow) -> Html Msg
workflowsSection workflows =
    let
        requirementDesc requirement =
            case requirement of
                RequiresUserId ->
                    "user id"

                RequiresLocationId ->
                    "location id"

                RequiresNewsTag ->
                    "news tag"

                UnsupportedRequirement ->
                    "not supported"

        requirementsLabel requirements =
            requirements
                |> List.map requirementDesc
                |> String.join ", "

        workflowRow workflow =
            tr []
                [ td [] [ text workflow.humanName ]
                , td [] [ text <| requirementsLabel workflow.requirements ]
                ]

        contentArea =
            case workflows of
                NotAsked ->
                    h2 [] [ text "workflows not loaded" ]

                Loading ->
                    h2 [] [ text "workflows loading" ]

                Success items ->
                    table [ class "table is-fullwidth" ]
                        [ thead []
                            [ tr []
                                [ th [] [ text "Name" ]
                                , th [] [ text "Requirements" ]
                                ]
                            ]
                        , tbody [] (List.map workflowRow items)
                        ]

                Failure reason ->
                    h2 [] [ text "Some error" ]
    in
    block "Workflows" contentArea


formatFrequency : Frequency -> String
formatFrequency frequency =
    let
        pad value =
            value
                |> String.fromInt
                |> String.padLeft 2 '0'
    in
    case frequency of
        Daily hour minute ->
            "Every day at " ++ pad hour ++ ":" ++ pad minute

        Hourly minute second ->
            "Every hour at " ++ pad minute ++ ":" ++ pad second

        UnsupportedFrequency ->
            "Frequency not supported"


scheduledTasksSection : WebData (List ScheduledTask) -> Maybe Int -> Html Msg
scheduledTasksSection scheduledTasks runningTask =
    let
        paramDesc param =
            case param of
                UserId id ->
                    "User " ++ String.fromInt id

                LocationId id ->
                    "Location " ++ String.fromInt id

                NewsTag tag ->
                    "News tag " ++ tag

                UnsupportedParam ->
                    "Unsupported param"

        paramsLabel params =
            params
                |> List.map paramDesc
                |> String.join ", "

        scheduledTaskRow scheduledTask =
            let
                runClassList =
                    [ ( "button is-small", True ), ( "is-primary", True ), ( "is-loading", runningTask == Just scheduledTask.id ) ]
            in
            tr []
                [ td [] [ text <| String.fromInt scheduledTask.id ]
                , td [] [ text scheduledTask.workflowHumanName ]
                , td [] [ text <| paramsLabel scheduledTask.params ]
                , td [] [ text <| formatFrequency scheduledTask.frequency ]
                , td
                    [ class "actions" ]
                    [ a
                        [ classList runClassList
                        , onClick (ExecuteScheduledTask scheduledTask.id)
                        ]
                        [ iconButton Run ]
                    , a [ class "button is-small is-link" ] [ iconButton Edit ]
                    , a [ class "button is-small is-danger" ] [ iconButton Delete ]
                    ]
                ]

        contentArea =
            case scheduledTasks of
                NotAsked ->
                    h2 [] [ text "scheduledTasks not loaded" ]

                Loading ->
                    h2 [] [ text "scheduledTasks loading" ]

                Success items ->
                    table [ class "table is-fullwidth" ]
                        [ thead []
                            [ tr []
                                [ th [] [ text "ID" ]
                                , th [] [ text "Workflow Name" ]
                                , th [] [ text "Params" ]
                                , th [] [ text "Frequency" ]
                                , th [] [ text "Actions" ]
                                ]
                            ]
                        , tbody [] (List.map scheduledTaskRow items)
                        ]

                Failure reason ->
                    h2 [] [ text "Some error" ]
    in
    block "Scheduled Tasks" contentArea


body : Model -> List (Html Msg)
body model =
    [ div []
        [ titleBar
        , div [ class "columns" ]
            [ usersSection model.users
            , locationsSection model.locations model.gmapsApiKey
            ]
        , div [ class "columns" ]
            [ workflowsSection model.workflows
            , scheduledTasksSection model.scheduledTasks model.runningTask
            ]
        ]
    ]



-- APPLICATION WIRING


type alias Flags =
    String


type Msg
    = NoOp
    | ExecuteScheduledTask Int
    | UsersResponse (WebData (List User))
    | LocationsResponse (WebData (List Location))
    | WorkflowsResponse (WebData (List Workflow))
    | ScheduledTasksResponse (WebData (List ScheduledTask))
    | ExecuteScheduledTaskResponse (WebData ())


type alias Model =
    { gmapsApiKey : String
    , users : WebData (List User)
    , locations : WebData (List Location)
    , workflows : WebData (List Workflow)
    , scheduledTasks : WebData (List ScheduledTask)
    , runningTask : Maybe Int
    }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init gmapsApiKey =
    ( { gmapsApiKey = gmapsApiKey
      , users = NotAsked
      , locations = NotAsked
      , workflows = NotAsked
      , scheduledTasks = NotAsked
      , runningTask = Nothing
      }
    , Cmd.batch [ getUsers, getLocations, getWorkflows, getScheduledTasks ]
    )


view : Model -> Document Msg
view model =
    { title = "Ada"
    , body = body model
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ExecuteScheduledTask taskId ->
            ( { model | runningTask = Just taskId }, executeScheduledTask taskId )

        UsersResponse response ->
            ( { model | users = response }, Cmd.none )

        LocationsResponse response ->
            ( { model | locations = response }, Cmd.none )

        WorkflowsResponse response ->
            ( { model | workflows = response }, Cmd.none )

        ScheduledTasksResponse response ->
            ( { model | scheduledTasks = response }, Cmd.none )

        ExecuteScheduledTaskResponse _ ->
            ( { model | runningTask = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
