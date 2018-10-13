module Main exposing (main)

import Browser exposing (Document)
import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (class)
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
    , requirements : List WorkflowRequirement
    }



-- SCHEDULED TASKS


type alias ScheduledTask =
    { id : Int
    , frequency : Frequency
    , workflowName : String
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
    JD.map3 Location
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
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
    JD.map2 Workflow
        (JD.field "name" JD.string)
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
    JD.map4 ScheduledTask
        (JD.field "id" JD.int)
        (JD.field "frequency" frequencyDecoder)
        (JD.field "workflow_name" JD.string)
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


titleBar : Html Msg
titleBar =
    section [ class "hero is-dark" ]
        [ div [ class "hero-body" ]
            [ div [ class "container" ]
                [ h1 [ class "title" ]
                    [ text "Ada Control Center" ]
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
                    [ a [ class "button is-link" ] [ text "Edit" ]
                    , a [ class "button is-danger" ] [ text "Delete" ]
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
    section [ class "section" ]
        [ div [ class "container is-fluid" ]
            [ contentArea ]
        ]


locationsSection : WebData (List Location) -> Html Msg
locationsSection locations =
    let
        coordsLabel ( lat, lng ) =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        locationRow location =
            tr []
                [ td [] [ text <| String.fromInt location.id ]
                , td [] [ text location.name ]
                , td [] [ text <| coordsLabel location.coords ]
                , td
                    [ class "actions" ]
                    [ a [ class "button is-link" ] [ text "Edit" ]
                    , a [ class "button is-danger" ] [ text "Delete" ]
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
                                , th [] [ text "Coordinates" ]
                                , th [] [ text "Actions" ]
                                ]
                            ]
                        , tbody [] (List.map locationRow items)
                        ]

                Failure reason ->
                    h2 [] [ text "Some error" ]
    in
    section [ class "section column" ]
        [ div [ class "container is-fluid" ]
            [ contentArea ]
        ]


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
                [ td [] [ text workflow.name ]
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
    section [ class "section column is-one-quarter" ]
        [ div [ class "container is-fluid" ]
            [ contentArea ]
        ]


scheduledTasksSection : WebData (List ScheduledTask) -> Html Msg
scheduledTasksSection scheduledTasks =
    let
        frequencyLabel frequency =
            case frequency of
                Daily hour minute ->
                    "Daily at " ++ String.fromInt hour ++ ":" ++ String.fromInt minute

                Hourly minute second ->
                    "Hourly at " ++ String.fromInt minute ++ ":" ++ String.fromInt second

                UnsupportedFrequency ->
                    "Frequency not supported"

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
            tr []
                [ td [] [ text <| String.fromInt scheduledTask.id ]
                , td [] [ text scheduledTask.workflowName ]
                , td [] [ text <| paramsLabel scheduledTask.params ]
                , td [] [ text <| frequencyLabel scheduledTask.frequency ]
                , td
                    [ class "actions" ]
                    [ a
                        [ class "button is-primary"
                        , onClick (ExecuteScheduledTask scheduledTask.id)
                        ]
                        [ text "Run" ]
                    , a [ class "button is-link" ] [ text "Edit" ]
                    , a [ class "button is-danger" ] [ text "Delete" ]
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
    section [ class "section column is-three-quarters" ]
        [ div [ class "container is-fluid" ]
            [ contentArea ]
        ]


body : Model -> List (Html Msg)
body model =
    [ div []
        [ titleBar
        , div [ class "columns" ]
            [ usersSection model.users
            , locationsSection model.locations
            ]
        , div [ class "columns" ]
            [ workflowsSection model.workflows
            , scheduledTasksSection model.scheduledTasks
            ]
        ]
    ]



-- APPLICATION WIRING


type alias Flags =
    Int


type Msg
    = NoOp
    | ExecuteScheduledTask Int
    | UsersResponse (WebData (List User))
    | LocationsResponse (WebData (List Location))
    | WorkflowsResponse (WebData (List Workflow))
    | ScheduledTasksResponse (WebData (List ScheduledTask))
    | ExecuteScheduledTaskResponse (WebData ())


type alias Model =
    { count : Int
    , users : WebData (List User)
    , locations : WebData (List Location)
    , workflows : WebData (List Workflow)
    , scheduledTasks : WebData (List ScheduledTask)
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
init initialCount =
    ( { count = initialCount
      , users = NotAsked
      , locations = NotAsked
      , workflows = NotAsked
      , scheduledTasks = NotAsked
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
            ( model, executeScheduledTask taskId )

        UsersResponse response ->
            ( { model | users = response }, Cmd.none )

        LocationsResponse response ->
            ( { model | locations = response }, Cmd.none )

        WorkflowsResponse response ->
            ( { model | workflows = response }, Cmd.none )

        ScheduledTasksResponse response ->
            ( { model | scheduledTasks = response }, Cmd.none )

        ExecuteScheduledTaskResponse _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
