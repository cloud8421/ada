module Main exposing (main)

import Browser exposing (Document)
import Bulma as Bulma
import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, type_, value)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Http as Http
import Json.Decode as JD
import Json.Encode as JE
import Map exposing (..)
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


type alias UserId =
    Int


type alias User =
    { id : UserId
    , name : String
    , email : String
    }


type alias Users =
    Dict.Dict UserId User


type alias LocationId =
    Int


type alias Location =
    { id : LocationId
    , name : String
    , active : Bool
    , coords : Coords
    }


type alias Locations =
    Dict.Dict LocationId Location



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


type alias WorfklowName =
    String


type alias Workflow =
    { name : WorfklowName
    , humanName : String
    , requirements : List WorkflowRequirement
    }


type alias Workflows =
    Dict.Dict WorfklowName Workflow



-- SCHEDULED TASKS


type alias ScheduledTaskId =
    Int


type alias ScheduledTask =
    { id : ScheduledTaskId
    , frequency : Frequency
    , workflowName : String
    , workflowHumanName : String
    , params : List WorkflowParam
    }


type alias ScheduledTasks =
    Dict.Dict ScheduledTaskId ScheduledTask



-- UTIL


groupById : List { a | id : comparable } -> Dict.Dict comparable { a | id : comparable }
groupById items =
    List.map (\i -> ( i.id, i )) items
        |> Dict.fromList


groupByName : List { a | name : comparable } -> Dict.Dict comparable { a | name : comparable }
groupByName items =
    List.map (\i -> ( i.name, i )) items
        |> Dict.fromList



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
        |> Cmd.map (RemoteData.map groupById)
        |> Cmd.map UsersResponse


createUser : UserParams -> Cmd Msg
createUser userParams =
    let
        encoded =
            JE.object
                [ ( "name", JE.string userParams.name )
                , ( "email", JE.string userParams.email )
                ]
    in
    Http.post "/users" (Http.jsonBody encoded) decodeUser
        |> RemoteData.sendRequest
        |> Cmd.map CreateUserResponse


updateUser : User -> Cmd Msg
updateUser user =
    let
        encoded =
            JE.object
                [ ( "name", JE.string user.name )
                , ( "email", JE.string user.email )
                ]

        url =
            "/users/" ++ String.fromInt user.id
    in
    putNoContent url (Http.jsonBody encoded)
        |> RemoteData.sendRequest
        |> Cmd.map UpdateUserResponse


deleteUser : UserId -> Cmd Msg
deleteUser userId =
    let
        url =
            "/users/" ++ String.fromInt userId
    in
    delete url
        |> RemoteData.sendRequest
        |> Cmd.map (DeleteUserResponse userId)



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


decodeLocations : JD.Decoder (List Location)
decodeLocations =
    JD.list decodeLocation


getLocations : Cmd Msg
getLocations =
    Http.get "/locations" decodeLocations
        |> RemoteData.sendRequest
        |> Cmd.map (RemoteData.map groupById)
        |> Cmd.map LocationsResponse


activateLocation : Int -> Cmd Msg
activateLocation locationId =
    putNoBodyNoContent ("/locations/" ++ String.fromInt locationId ++ "/activate")
        |> RemoteData.sendRequest
        |> Cmd.map ActivateLocationResponse


createLocation : LocationParams -> Cmd Msg
createLocation locationParams =
    let
        ( lat, lng ) =
            locationParams.coords

        encoded =
            JE.object
                [ ( "name", JE.string locationParams.name )
                , ( "lat", JE.float lat )
                , ( "lng", JE.float lng )
                ]
    in
    Http.post "/locations" (Http.jsonBody encoded) decodeLocation
        |> RemoteData.sendRequest
        |> Cmd.map CreateLocationResponse


updateLocation : Location -> Cmd Msg
updateLocation location =
    let
        ( lat, lng ) =
            location.coords

        encoded =
            JE.object
                [ ( "name", JE.string location.name )
                , ( "lat", JE.float lat )
                , ( "lng", JE.float lng )
                ]

        url =
            "/locations/" ++ String.fromInt location.id
    in
    putNoContent url (Http.jsonBody encoded)
        |> RemoteData.sendRequest
        |> Cmd.map UpdateLocationResponse


deleteLocation : LocationId -> Cmd Msg
deleteLocation locationId =
    let
        url =
            "/locations/" ++ String.fromInt locationId
    in
    delete url
        |> RemoteData.sendRequest
        |> Cmd.map (DeleteLocationResponse locationId)



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
        |> Cmd.map (RemoteData.map groupByName)
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
        |> Cmd.map (RemoteData.map groupById)
        |> Cmd.map ScheduledTasksResponse


executeScheduledTask : Int -> Cmd Msg
executeScheduledTask taskId =
    putNoBodyNoContent ("/scheduled_tasks/" ++ String.fromInt taskId ++ "/execute")
        |> RemoteData.sendRequest
        |> Cmd.map ExecuteScheduledTaskResponse


putNoBodyNoContent : String -> Http.Request ()
putNoBodyNoContent url =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody (JE.string "")
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }


putNoContent : String -> Http.Body -> Http.Request ()
putNoContent url httpBody =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = httpBody
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }


delete : String -> Http.Request ()
delete url =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.jsonBody (JE.string "")
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }



-- VIEWS


webDataTable : WebData items -> (items -> Html Msg) -> Html Msg
webDataTable webData successContent =
    case webData of
        NotAsked ->
            h2 [] [ text "Resource not loaded" ]

        Loading ->
            h2 [] [ text "Resource loading" ]

        Success items ->
            successContent items

        Failure _ ->
            h2 [] [ text "Resource failed to load" ]


usersSection : WebData Users -> Html Msg
usersSection users =
    let
        userRow user =
            tr []
                [ td [] [ text <| String.fromInt user.id ]
                , td [] [ text user.name ]
                , td [] [ text user.email ]
                , td []
                    [ div [ class "field has-addons" ]
                        [ Bulma.actionButton Bulma.Edit (OpenEditingModalEditUser user)
                        , Bulma.dangerActionButton Bulma.Delete (DeleteUser user.id)
                        ]
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "ID", "Name", "Email", "Actions" ]
                , tbody [] (List.map userRow (Dict.values items))
                ]
    in
    Bulma.blockWithNew "Users" OpenEditingModalNewUser (webDataTable users contentArea)


gMap : Location -> String -> Int -> Int -> Html Msg
gMap location gmapsApiKey width height =
    let
        map =
            { apiKey = gmapsApiKey
            , coords = location.coords
            , markerText = String.left 1 location.name
            , width = width
            , height = height
            }
    in
    img [ src (Map.toGmapsUrl map) ] []


locationsSection : WebData Locations -> String -> Html Msg
locationsSection locations gmapsApiKey =
    let
        coordsLabel ( lat, lng ) =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        activeTag active =
            if active then
                Bulma.tag "active"
            else
                Bulma.lightTag "inactive"

        locationRow location =
            let
                disabledAttr =
                    if location.active then
                        [ attribute "disabled" "disabled" ]
                    else
                        []
            in
            tr []
                [ td [] [ text <| String.fromInt location.id ]
                , td [] [ text location.name ]
                , td [] [ activeTag location.active ]
                , td [] [ gMap location gmapsApiKey 300 120 ]
                , td []
                    [ div [ class "field has-addons" ]
                        [ p [ class "control" ]
                            [ a
                                ([ class "button is-primary"
                                 , onClick (ActivateLocation location.id)
                                 ]
                                    ++ disabledAttr
                                )
                                [ Bulma.iconButton Bulma.Activate ]
                            ]
                        , Bulma.actionButton Bulma.Edit (OpenEditingModalEditLocation location)
                        , Bulma.dangerActionButton Bulma.Delete (DeleteLocation location.id)
                        ]
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "ID", "Name", "Status", "Coordinates", "Actions" ]
                , tbody [] (List.map locationRow (Dict.values items))
                ]
    in
    Bulma.blockWithNew "Locations" OpenEditingModalNewLocation (webDataTable locations contentArea)


requirementTag : WorkflowRequirement -> Html Msg
requirementTag requirement =
    case requirement of
        RequiresUserId ->
            Bulma.tag "User"

        RequiresLocationId ->
            Bulma.tag "Location"

        RequiresNewsTag ->
            Bulma.tag "News tag"

        UnsupportedRequirement ->
            Bulma.dangerTag "Not supported"


workflowsSection : WebData Workflows -> Html Msg
workflowsSection workflows =
    let
        workflowRow workflow =
            tr []
                [ td [] [ text workflow.humanName ]
                , td []
                    [ div [ class "field is-grouped is-grouped-multiline" ]
                        [ div
                            [ class "tags" ]
                            (List.map requirementTag workflow.requirements)
                        ]
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "Name", "Requirements" ]
                , tbody [] (List.map workflowRow (Dict.values items))
                ]
    in
    Bulma.block "Workflows" (webDataTable workflows contentArea)


timePad : Int -> String
timePad value =
    value
        |> String.fromInt
        |> String.padLeft 2 '0'


formatFrequency : Frequency -> String
formatFrequency frequency =
    case frequency of
        Daily hour minute ->
            "Every day at " ++ timePad hour ++ ":" ++ timePad minute

        Hourly minute second ->
            "Every hour at " ++ timePad minute ++ ":" ++ timePad second

        UnsupportedFrequency ->
            "Frequency not supported"


find : WebData (Dict.Dict Int v) -> Int -> Maybe v
find collection id =
    case collection of
        Success items ->
            Dict.get id items

        otherwise ->
            Nothing


scheduledTasksSection : Model -> Html Msg
scheduledTasksSection model =
    let
        toPair param =
            case param of
                UserId id ->
                    find model.users id
                        |> Maybe.map .name
                        |> Maybe.withDefault "Not available"
                        |> Tuple.pair "User"

                LocationId id ->
                    find model.locations id
                        |> Maybe.map .name
                        |> Maybe.withDefault "Not available"
                        |> Tuple.pair "Location"

                NewsTag tag ->
                    Tuple.pair "News tag" tag

                UnsupportedParam ->
                    Tuple.pair "Unsupported" ":("

        paramTags params =
            Bulma.tagsWithAddons (List.map toPair params)

        scheduledTaskRow scheduledTask =
            let
                isRunning =
                    model.runningTask == Just scheduledTask.id

                runClassList =
                    [ ( "button", True )
                    , ( "is-primary", True )
                    , ( "is-loading", isRunning )
                    ]
            in
            tr []
                [ td [] [ text <| String.fromInt scheduledTask.id ]
                , td [] [ text scheduledTask.workflowHumanName ]
                , td []
                    [ div [ class "field is-grouped is-grouped-multiline" ]
                        [ paramTags scheduledTask.params ]
                    ]
                , td [] [ text <| formatFrequency scheduledTask.frequency ]
                , td []
                    [ div [ class "field has-addons" ]
                        [ p [ class "control" ]
                            [ a
                                [ classList runClassList
                                , onClick (ExecuteScheduledTask scheduledTask.id)
                                ]
                                [ Bulma.iconButton Bulma.Run ]
                            ]
                        , Bulma.actionButton Bulma.Edit (OpenEditingModalEditScheduledTask scheduledTask)
                        , p [ class "control" ]
                            [ a [ class "button is-danger" ] [ Bulma.iconButton Bulma.Delete ]
                            ]
                        ]
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "ID", "Workflow Name", "Params", "Frequency", "Actions" ]
                , tbody [] (List.map scheduledTaskRow (Dict.values items))
                ]
    in
    Bulma.blockWithNew "Scheduled Tasks" OpenEditingModalNewScheduledTask (webDataTable model.scheduledTasks contentArea)


userEditingForm : String -> { a | name : String, email : String } -> Html Msg
userEditingForm title resource =
    form []
        [ h1 [ class "title" ] [ text title ]
        , div [ class "field" ]
            [ label [ class "label" ]
                [ text "Name" ]
            , div [ class "control" ]
                [ input
                    [ class "input"
                    , placeholder "User name"
                    , type_ "text"
                    , value resource.name
                    , onInput UpdateUserName
                    ]
                    []
                ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ]
                [ text "Email" ]
            , div [ class "control has-icons-left has-icons-right" ]
                [ input
                    [ class "input"
                    , placeholder "Email input"
                    , type_ "email"
                    , value resource.email
                    , onInput UpdateUserEmail
                    ]
                    []
                , span [ class "icon is-small is-left" ]
                    [ i [ class "fas fa-envelope" ]
                        []
                    ]
                ]
            ]
        , div
            [ class "field is-grouped" ]
            [ div [ class "control" ]
                [ input
                    [ class "button is-link"
                    , type_ "button"
                    , value "Submit"
                    , onClick SaveUser
                    ]
                    []
                ]
            , div
                [ class "control"
                ]
                [ input
                    [ class "button is-text"
                    , type_ "button"
                    , value "Cancel"
                    , onClick CloseEditingModal
                    ]
                    []
                ]
            ]
        ]


locationEditingForm : String -> { a | name : String, coords : Coords } -> String -> Html Msg
locationEditingForm title resource gmapsApiKey =
    let
        latString =
            resource.coords |> Tuple.first |> String.fromFloat

        lngString =
            resource.coords |> Tuple.second |> String.fromFloat

        targetValueFloat =
            JD.at [ "target", "valueAsNumber" ] JD.float

        onInputFloat tagger =
            on "input" (JD.map tagger targetValueFloat)

        editArea =
            form []
                [ h1 [ class "title" ] [ text title ]
                , div [ class "field" ]
                    [ label [ class "label" ]
                        [ text "Name" ]
                    , div [ class "control" ]
                        [ input
                            [ class "input"
                            , placeholder "Location name"
                            , type_ "text"
                            , value resource.name
                            , onInput UpdateLocationName
                            ]
                            []
                        ]
                    ]
                , div [ class "field" ]
                    [ label [ class "label" ]
                        [ text "Lat" ]
                    , div [ class "control has-icons-left has-icons-right" ]
                        [ input
                            [ class "input"
                            , placeholder "lat"
                            , type_ "number"
                            , attribute "min" "-90"
                            , attribute "max" "90"
                            , attribute "step" "0.0001"
                            , value latString
                            , onInputFloat (\v -> UpdateLocationCoords ( v, Tuple.second resource.coords ))
                            ]
                            []
                        , span [ class "icon is-small is-left" ]
                            [ i [ class "fas fa-map" ]
                                []
                            ]
                        ]
                    ]
                , div [ class "field" ]
                    [ label [ class "label" ]
                        [ text "Lng" ]
                    , div [ class "control has-icons-left has-icons-right" ]
                        [ input
                            [ class "input"
                            , placeholder "lng"
                            , type_ "number"
                            , attribute "min" "-180"
                            , attribute "max" "180"
                            , attribute "step" "0.0001"
                            , value lngString
                            , onInputFloat (\v -> UpdateLocationCoords ( Tuple.first resource.coords, v ))
                            ]
                            []
                        , span [ class "icon is-small is-left" ]
                            [ i [ class "fas fa-map" ]
                                []
                            ]
                        ]
                    ]
                , div
                    [ class "field is-grouped" ]
                    [ div [ class "control" ]
                        [ input
                            [ class "button is-link"
                            , type_ "button"
                            , value "Submit"
                            , onClick SaveLocation
                            ]
                            []
                        ]
                    , div
                        [ class "control"
                        ]
                        [ input
                            [ class "button is-text"
                            , type_ "button"
                            , value "Cancel"
                            , onClick CloseEditingModal
                            ]
                            []
                        ]
                    ]
                ]

        previewMap =
            { apiKey = gmapsApiKey
            , coords = resource.coords
            , markerText = String.left 1 resource.name
            , width = 287
            , height = 287
            }
    in
    div [ class "columns" ]
        [ div [ class "column" ]
            [ editArea
            ]
        , div
            [ class "column" ]
            [ h2 [ class "subtitle" ] [ text "Preview" ]
            , img [ src (Map.toGmapsUrl previewMap) ] []
            ]
        ]


scheduledTaskEditingForm title resource workflows =
    let
        workflowMetas =
            case workflows of
                Success items ->
                    items
                        |> Dict.values
                        |> List.map (\i -> ( i.humanName, i.name ))

                otherwise ->
                    []

        workflowMetasWithDefaultOption =
            [ ( "Choose workflow", "choose-workflow" ) ] ++ workflowMetas

        workflowRequirements =
            case workflows of
                Success items ->
                    items
                        |> Dict.get resource.workflowName
                        |> Maybe.map .requirements

                otherwise ->
                    Nothing

        requirementsDescription =
            case workflowRequirements of
                Just items ->
                    [ p [ class "help" ] [ text "Requires" ]
                    , div [ class "tags" ]
                        (List.map requirementTag items)
                    ]

                Nothing ->
                    [ p [ class "help" ] [ text "Choose a workflow to see its requirements" ] ]

        workflowOption selectedWorkflowName ( humanName, name ) =
            let
                optionAttrs =
                    if name == selectedWorkflowName then
                        [ attribute "selected" "selected" ]
                    else
                        []
            in
            option ([ value name ] ++ optionAttrs) [ text humanName ]

        onChange tagger =
            on "change" (JD.map tagger targetValue)

        parseHour timeString =
            case String.split ":" timeString of
                [ hourString, _ ] ->
                    case String.toInt hourString of
                        Just hour ->
                            JD.succeed hour

                        Nothing ->
                            JD.fail "Invalid hour string"

                otherwise ->
                    JD.fail "Invalid time string"

        parseMinute timeString =
            case String.split ":" timeString of
                [ _, minuteString ] ->
                    case String.toInt minuteString of
                        Just minute ->
                            JD.succeed minute

                        Nothing ->
                            JD.fail "Invalid minute string"

                otherwise ->
                    JD.fail "Invalid time string"

        targetValueAsFrequency =
            JD.oneOf
                [ JD.map2 Daily
                    (targetValue |> JD.andThen parseHour)
                    (targetValue |> JD.andThen parseMinute)
                , JD.map2 Hourly
                    (JD.at [ "target", "valueAsNumber" ] JD.int)
                    (JD.succeed 0)
                ]

        onInputTime tagger =
            on "input" (JD.map tagger targetValueAsFrequency)

        frequencyInput frequency =
            case frequency of
                Daily hour minute ->
                    input
                        [ type_ "time"
                        , class "input"
                        , value (timePad hour ++ ":" ++ timePad minute)
                        , onInputTime UpdateScheduledTaskFrequency
                        ]
                        []

                Hourly minute _ ->
                    input
                        [ type_ "number"
                        , class "input"
                        , value (String.fromInt minute)
                        , onInputTime UpdateScheduledTaskFrequency
                        ]
                        []

                UnsupportedFrequency ->
                    p [] [ text "Unsupported frequency value" ]
    in
    form []
        [ h1 [ class "title" ] [ text title ]
        , div
            [ class "columns" ]
            [ div [ class "column" ]
                [ div [ class "field" ]
                    [ label [ class "label" ]
                        [ text "Workflow Name" ]
                    , div [ class "control" ]
                        [ div [ class "select" ]
                            [ select [ onChange UpdateScheduledTaskWorkflowName ]
                                (List.map (workflowOption resource.workflowName) workflowMetasWithDefaultOption)
                            ]
                        ]
                    , div [ class "control" ] requirementsDescription
                    ]
                ]
            , div [ class "column" ]
                [ div [ class "field" ]
                    [ label [ class "label" ]
                        [ text "Frequency" ]
                    ]
                , div [ class "field has-addons" ]
                    [ p [ class "control" ]
                        [ span [ class "select" ]
                            [ select [ onChange ResetScheduledTaskFrequency ]
                                [ option [ value "daily" ] [ text "Daily" ]
                                , option [ value "hourly" ] [ text "Hourly" ]
                                ]
                            ]
                        ]
                    , p [ class "control" ]
                        [ frequencyInput resource.frequency ]
                    ]
                ]
            ]
        , div
            [ class "field is-grouped" ]
            [ div [ class "control" ]
                [ input
                    [ class "button is-link"
                    , type_ "button"
                    , value "Submit"
                    , onClick SaveScheduledTask
                    ]
                    []
                ]
            , div
                [ class "control"
                ]
                [ input
                    [ class "button is-text"
                    , type_ "button"
                    , value "Cancel"
                    , onClick CloseEditingModal
                    ]
                    []
                ]
            ]
        ]


editingModalForm : Model -> Html Msg
editingModalForm model =
    case model.editForm of
        Closed ->
            text "Nothing to see here"

        NewUser userParams ->
            userEditingForm "New User" userParams

        EditUser user ->
            userEditingForm "Edit User" user

        NewLocation locationParams ->
            locationEditingForm "New Location" locationParams model.gmapsApiKey

        EditLocation location ->
            locationEditingForm "Edit Location" location model.gmapsApiKey

        NewScheduledTask scheduleTaskParams ->
            scheduledTaskEditingForm "New Scheduled Task" scheduleTaskParams model.workflows

        EditScheduledTask scheduledTask ->
            scheduledTaskEditingForm "Edit Scheduled Task" scheduledTask model.workflows


editingModal : Model -> Html Msg
editingModal model =
    let
        modalClasses =
            [ ( "modal", True ), ( "is-active", model.editForm /= Closed ) ]
    in
    div [ classList modalClasses ]
        [ div [ class "modal-background" ]
            []
        , div [ class "modal-content" ]
            [ div [ class "box" ] [ editingModalForm model ]
            ]
        , button
            [ onClick CloseEditingModal
            , attribute "aria-label" "close"
            , class "modal-close is-large"
            ]
            []
        ]


body : Model -> List (Html Msg)
body model =
    [ div []
        [ Bulma.titleBar "Ada Control Center"
        , div [ class "columns" ]
            [ scheduledTasksSection model
            , locationsSection model.locations model.gmapsApiKey
            ]
        , div [ class "columns" ]
            [ workflowsSection model.workflows
            , usersSection model.users
            ]
        , editingModal model
        ]
    ]



-- EDITING


type alias ScheduledTaskParams =
    { frequency : Frequency
    , workflowName : String
    , params : List WorkflowParam
    }


type alias LocationParams =
    { name : String
    , coords : Coords
    }


type alias UserParams =
    { name : String
    , email : String
    }


type EditForm
    = Closed
    | NewScheduledTask ScheduledTaskParams
    | EditScheduledTask ScheduledTask
    | NewUser UserParams
    | EditUser User
    | NewLocation LocationParams
    | EditLocation Location


saveUser : EditForm -> Cmd Msg
saveUser editForm =
    case editForm of
        NewUser userParams ->
            createUser userParams

        EditUser user ->
            updateUser user

        otherwise ->
            Cmd.none


saveLocation : EditForm -> Cmd Msg
saveLocation editForm =
    case editForm of
        NewLocation locationParams ->
            createLocation locationParams

        EditLocation location ->
            updateLocation location

        otherwise ->
            Cmd.none


saveScheduledTask : EditForm -> Cmd Msg
saveScheduledTask editForm =
    Cmd.none



-- APPLICATION WIRING


type alias Flags =
    String


type Msg
    = NoOp
    | ExecuteScheduledTask Int
    | ActivateLocation Int
    | UsersResponse (WebData Users)
    | LocationsResponse (WebData Locations)
    | WorkflowsResponse (WebData Workflows)
    | ScheduledTasksResponse (WebData ScheduledTasks)
    | ExecuteScheduledTaskResponse (WebData ())
    | ActivateLocationResponse (WebData ())
    | CloseEditingModal
    | OpenEditingModalNewUser
    | OpenEditingModalEditUser User
    | OpenEditingModalNewLocation
    | OpenEditingModalEditLocation Location
    | OpenEditingModalNewScheduledTask
    | OpenEditingModalEditScheduledTask ScheduledTask
    | UpdateUserName String
    | UpdateUserEmail String
    | UpdateLocationName String
    | UpdateLocationCoords Coords
    | UpdateScheduledTaskWorkflowName String
    | UpdateScheduledTaskFrequency Frequency
    | ResetScheduledTaskFrequency String
    | SaveUser
    | SaveLocation
    | SaveScheduledTask
    | DeleteUser UserId
    | DeleteLocation LocationId
    | CreateUserResponse (WebData User)
    | UpdateUserResponse (WebData ())
    | DeleteUserResponse UserId (WebData ())
    | DeleteLocationResponse LocationId (WebData ())
    | CreateLocationResponse (WebData Location)
    | UpdateLocationResponse (WebData ())


type alias Model =
    { gmapsApiKey : String
    , users : WebData Users
    , locations : WebData Locations
    , workflows : WebData Workflows
    , scheduledTasks : WebData ScheduledTasks
    , runningTask : Maybe Int
    , editForm : EditForm
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
      , editForm = Closed
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

        ActivateLocation locationId ->
            ( model, activateLocation locationId )

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

        ActivateLocationResponse _ ->
            ( model, getLocations )

        CloseEditingModal ->
            ( { model | editForm = Closed }, Cmd.none )

        OpenEditingModalNewUser ->
            ( { model | editForm = NewUser { name = "e.g. Ada", email = "e.g. ada@example.com" } }, Cmd.none )

        OpenEditingModalEditUser user ->
            ( { model | editForm = EditUser user }, Cmd.none )

        OpenEditingModalNewLocation ->
            ( { model | editForm = NewLocation { name = "e.g. Home", coords = ( 0, 0 ) } }, Cmd.none )

        OpenEditingModalEditLocation location ->
            ( { model | editForm = EditLocation location }, Cmd.none )

        OpenEditingModalNewScheduledTask ->
            ( { model
                | editForm =
                    NewScheduledTask
                        { frequency = Daily 9 0
                        , workflowName = "Choose name"
                        , params = []
                        }
              }
            , Cmd.none
            )

        OpenEditingModalEditScheduledTask scheduledTask ->
            ( { model | editForm = EditScheduledTask scheduledTask }, Cmd.none )

        UpdateUserName newName ->
            let
                newEditForm =
                    case model.editForm of
                        NewUser userParams ->
                            NewUser { userParams | name = newName }

                        EditUser user ->
                            EditUser { user | name = newName }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        UpdateUserEmail newEmail ->
            let
                newEditForm =
                    case model.editForm of
                        NewUser userParams ->
                            NewUser { userParams | email = newEmail }

                        EditUser user ->
                            EditUser { user | email = newEmail }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        UpdateLocationName newName ->
            let
                newEditForm =
                    case model.editForm of
                        NewLocation locationParams ->
                            NewLocation { locationParams | name = newName }

                        EditLocation location ->
                            EditLocation { location | name = newName }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        UpdateLocationCoords newCoords ->
            let
                newEditForm =
                    case model.editForm of
                        NewLocation locationParams ->
                            NewLocation { locationParams | coords = newCoords }

                        EditLocation location ->
                            EditLocation { location | coords = newCoords }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        UpdateScheduledTaskWorkflowName newWorkflowName ->
            let
                newEditForm =
                    case model.editForm of
                        NewScheduledTask scheduleTaskParams ->
                            NewScheduledTask { scheduleTaskParams | workflowName = newWorkflowName }

                        EditScheduledTask scheduledTask ->
                            EditScheduledTask { scheduledTask | workflowName = newWorkflowName }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        UpdateScheduledTaskFrequency newFrequency ->
            let
                newEditForm =
                    case model.editForm of
                        NewScheduledTask scheduleTaskParams ->
                            NewScheduledTask { scheduleTaskParams | frequency = newFrequency }

                        EditScheduledTask scheduledTask ->
                            EditScheduledTask { scheduledTask | frequency = newFrequency }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        ResetScheduledTaskFrequency typeString ->
            let
                newFrequency =
                    case typeString of
                        "daily" ->
                            Daily 9 0

                        "hourly" ->
                            Hourly 30 0

                        otherwise ->
                            UnsupportedFrequency

                newEditForm =
                    case model.editForm of
                        NewScheduledTask scheduleTaskParams ->
                            NewScheduledTask { scheduleTaskParams | frequency = newFrequency }

                        EditScheduledTask scheduledTask ->
                            EditScheduledTask { scheduledTask | frequency = newFrequency }

                        otherwise ->
                            model.editForm
            in
            ( { model | editForm = newEditForm }, Cmd.none )

        SaveUser ->
            ( model, saveUser model.editForm )

        SaveLocation ->
            ( model, saveLocation model.editForm )

        SaveScheduledTask ->
            ( model, saveScheduledTask model.editForm )

        DeleteUser userId ->
            ( model, deleteUser userId )

        DeleteLocation locationId ->
            ( model, deleteLocation locationId )

        CreateUserResponse response ->
            case response of
                Success user ->
                    ( { model
                        | users = RemoteData.map (Dict.insert user.id user) model.users
                        , editForm = Closed
                      }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        UpdateUserResponse _ ->
            case model.editForm of
                EditUser user ->
                    ( { model
                        | users = RemoteData.map (Dict.insert user.id user) model.users
                        , editForm = Closed
                      }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        DeleteUserResponse userId response ->
            case response of
                Success () ->
                    ( { model | users = RemoteData.map (Dict.remove userId) model.users }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        CreateLocationResponse response ->
            case response of
                Success location ->
                    ( { model
                        | locations = RemoteData.map (Dict.insert location.id location) model.locations
                        , editForm = Closed
                      }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        UpdateLocationResponse _ ->
            case model.editForm of
                EditLocation location ->
                    ( { model
                        | locations = RemoteData.map (Dict.insert location.id location) model.locations
                        , editForm = Closed
                      }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        DeleteLocationResponse locationId response ->
            case response of
                Success () ->
                    ( { model | locations = RemoteData.map (Dict.remove locationId) model.locations }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
