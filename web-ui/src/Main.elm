module Main exposing (main)

import Browser exposing (Document)
import Bulma.Columns as BC
import Bulma.Components as BCP
import Bulma.Elements as BE
import Bulma.Extra as BX
import Bulma.Form as BF
import Bulma.Layout as BL
import Bulma.Modifiers as BM
import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, type_, value)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Http as Http
import Json.Decode as JD
import Json.Encode as JE
import Platform.Cmd as Cmd
import Platform.Sub as Sub
import RemoteData exposing (..)
import Url.Builder as Builder



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



-- WORKFLOWS


type Param
    = UserId Int
    | LocationId Int
    | NewsTag String
    | IntervalInHours Int


type Requirement
    = RequiresUserId
    | RequiresLocationId
    | RequiresNewsTag
    | RequiresIntervalInHours


type alias WorfklowName =
    String


type alias Workflow =
    { name : WorfklowName
    , humanName : String
    , requirements : List Requirement
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
    , transport : String
    , params : List Param
    }


type alias ScheduledTasks =
    Dict.Dict ScheduledTaskId ScheduledTask



-- Brightness


type alias Brightness =
    Int



-- Maps


type alias GoogleMapsApiKey =
    String


type alias Map =
    { apiKey : GoogleMapsApiKey
    , coords : ( Float, Float )
    , markerText : String
    , width : Int
    , height : Int
    }



-- UTIL


groupById : List { a | id : comparable } -> Dict.Dict comparable { a | id : comparable }
groupById items =
    List.map (\i -> ( i.id, i )) items
        |> Dict.fromList


groupByName : List { a | name : comparable } -> Dict.Dict comparable { a | name : comparable }
groupByName items =
    List.map (\i -> ( i.name, i )) items
        |> Dict.fromList


findById : WebData (Dict.Dict Int v) -> Int -> Maybe v
findById collection id =
    case collection of
        Success items ->
            Dict.get id items

        otherwise ->
            Nothing


requirementsAsLabels : List Requirement -> List String
requirementsAsLabels requirements =
    let
        asLabel requirement =
            case requirement of
                RequiresUserId ->
                    "User"

                RequiresLocationId ->
                    "Location"

                RequiresNewsTag ->
                    "News tag"

                RequiresIntervalInHours ->
                    "Interval (in hours)"
    in
    List.map asLabel requirements


incBrightness : Int -> Brightness -> Brightness
incBrightness increment brightness =
    if brightness + increment >= 255 then
        255

    else
        brightness + increment


decBrightness : Int -> Brightness -> Brightness
decBrightness decrement brightness =
    if brightness - decrement <= 1 then
        1

    else
        brightness - decrement



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


requirementDecoder : JD.Decoder Requirement
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

                "interval_in_hours" ->
                    JD.succeed RequiresIntervalInHours

                otherwise ->
                    JD.fail "Unsupported requirement"
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
                    JD.fail "Unsupported frequency"
    in
    JD.field "type" JD.string
        |> JD.andThen byFrequencyType


workflowParamDecoder : JD.Decoder Param
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

                "interval_in_hours" ->
                    JD.map IntervalInHours
                        (JD.field "value" JD.int)

                other ->
                    JD.fail "Unsupported Param"
    in
    JD.field "name" JD.string
        |> JD.andThen toParam


decodeScheduledTask : JD.Decoder ScheduledTask
decodeScheduledTask =
    JD.map6 ScheduledTask
        (JD.field "id" JD.int)
        (JD.field "frequency" frequencyDecoder)
        (JD.field "workflow_name" JD.string)
        (JD.field "workflow_human_name" JD.string)
        (JD.field "transport" JD.string)
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


runScheduledTask : Int -> Cmd Msg
runScheduledTask taskId =
    putNoBodyNoContent ("/scheduled_tasks/" ++ String.fromInt taskId ++ "/run")
        |> RemoteData.sendRequest
        |> Cmd.map RunScheduledTaskResponse


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



-- API - BRIGHTNESS


setBrightness : Brightness -> Cmd Msg
setBrightness brightness =
    let
        encoded =
            JE.object
                [ ( "brightness", JE.int brightness ) ]
    in
    putNoContent "/display/brightness" (Http.jsonBody encoded)
        |> RemoteData.sendRequest
        |> Cmd.map SetBrightnessResponse



-- VIEWS


webDataTable : WebData items -> (items -> Html Msg) -> Html Msg
webDataTable webData successContent =
    case webData of
        NotAsked ->
            BX.infoNotificaton "Resource not loaded"

        Loading ->
            BX.infoNotificaton "Resource loading"

        Failure _ ->
            BX.dangerNotification "Resource failed to load"

        Success items ->
            successContent items


usersSection : WebData Users -> Html Msg
usersSection users =
    let
        columnNames =
            [ "ID", "Name", "Email", "Actions" ]

        tableRow user =
            BE.tableRow False
                []
                [ BE.tableCell [] [ text <| String.fromInt user.id ]
                , BE.tableCell [] [ text user.name ]
                , BE.tableCell [] [ text user.email ]
                , BE.tableCell []
                    [ BF.field [ class "has-addons" ]
                        [ BX.editButton [ onClick (OpenEditingModalEditUser user) ]
                        , BX.deleteButton [ onClick (DeleteUser user.id) ]
                        ]
                    ]
                ]

        usersTable items =
            BX.dataTable
                [ BX.tableHeadFromColumnNames columnNames
                , BX.tableBodyFromItems tableRow (Dict.values items)
                ]
    in
    webDataTable users usersTable


workflowsSection : WebData Workflows -> Html Msg
workflowsSection workflows =
    let
        columnNames =
            [ "Name", "Requirements" ]

        toTags requirements =
            requirements
                |> requirementsAsLabels
                |> List.map BX.infoTag

        tableRow workflow =
            BE.tableRow False
                []
                [ BE.tableCell [] [ text workflow.humanName ]
                , BE.tableCell []
                    [ BE.tags []
                        (toTags workflow.requirements)
                    ]
                ]

        workflowsTable items =
            BX.dataTable
                [ BX.tableHeadFromColumnNames columnNames
                , BX.tableBodyFromItems tableRow (Dict.values items)
                ]
    in
    webDataTable workflows workflowsTable


mapToUrl : Map -> String
mapToUrl map =
    let
        ( lat, lng ) =
            map.coords

        coordsPair =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        size =
            String.fromInt map.width ++ "x" ++ String.fromInt map.height

        markers =
            "color:blue|label:" ++ map.markerText ++ "|" ++ coordsPair
    in
    Builder.crossOrigin
        "https://maps.googleapis.com"
        [ "maps", "api", "staticmap" ]
        [ Builder.string "center" coordsPair
        , Builder.int "zoom" 13
        , Builder.string "size" size
        , Builder.string "maptype" "roadmap"
        , Builder.string "markers" markers
        , Builder.string "key" map.apiKey
        ]


gMap : Location -> GoogleMapsApiKey -> Int -> Int -> Html Msg
gMap location googleMapsApiKey width height =
    let
        map : Map
        map =
            { apiKey = googleMapsApiKey
            , coords = location.coords
            , markerText = String.left 1 location.name
            , width = width
            , height = height
            }
    in
    img [ src (mapToUrl map) ] []


locationsSection : WebData Locations -> GoogleMapsApiKey -> Html Msg
locationsSection locations googleMapsApiKey =
    let
        columnNames =
            [ "ID", "Name", "Active", "Map", "Actions" ]

        coordsLabel ( lat, lng ) =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        activeTag active =
            if active then
                BX.infoTag "active"

            else
                BX.lightTag "inactive"

        tableRow location =
            BE.tableRow False
                []
                [ BE.tableCell [] [ text <| String.fromInt location.id ]
                , BE.tableCell [] [ text location.name ]
                , BE.tableCell [] [ activeTag location.active ]
                , BE.tableCell [] [ gMap location googleMapsApiKey 300 120 ]
                , BE.tableCell []
                    [ BF.field [ class "has-addons" ]
                        [ BX.checkButton location.active [ onClick (ActivateLocation location.id) ]
                        , BX.editButton [ onClick (OpenEditingModalEditLocation location) ]
                        , BX.deleteButton [ onClick (DeleteLocation location.id) ]
                        ]
                    ]
                ]

        locationsTable items =
            BX.dataTable
                [ BX.tableHeadFromColumnNames columnNames
                , BX.tableBodyFromItems tableRow (Dict.values items)
                ]
    in
    webDataTable locations locationsTable


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


paramTags params model =
    let
        toPair param =
            case param of
                UserId id ->
                    findById model.users id
                        |> Maybe.map .name
                        |> Maybe.withDefault "Not available"
                        |> Tuple.pair "User"

                LocationId id ->
                    findById model.locations id
                        |> Maybe.map .name
                        |> Maybe.withDefault "Not available"
                        |> Tuple.pair "Location"

                NewsTag tag ->
                    Tuple.pair "News tag" tag

                IntervalInHours interval ->
                    Tuple.pair "Interval (in hours)" (String.fromInt interval)

        toTag ( name, value ) =
            [ BX.infoTag name
            , BX.lightTag value
            ]

        tagPairs =
            List.map (\p -> p |> toPair |> toTag) params

        tagContainer tagPair =
            BF.control BF.controlModifiers [] [ BE.multitag [] tagPair ]
    in
    List.map tagContainer tagPairs


scheduledTasksSection : Model -> Html Msg
scheduledTasksSection model =
    let
        columnNames =
            [ "ID", "Workflow name", "Transport", "Params", "Frequency", "Actions" ]

        tableRow scheduledTask =
            let
                isRunning =
                    model.runningTask == Just scheduledTask.id
            in
            BE.tableRow False
                []
                [ BE.tableCell [] [ text <| String.fromInt scheduledTask.id ]
                , BE.tableCell [] [ text scheduledTask.workflowHumanName ]
                , BE.tableCell [] [ text scheduledTask.transport ]
                , BE.tableCell []
                    [ BF.multilineFields [] (paramTags scheduledTask.params model) ]
                , BE.tableCell [] [ text <| formatFrequency scheduledTask.frequency ]
                , BE.tableCell []
                    [ BF.field [ class "has-addons" ]
                        [ BX.runButton isRunning [ onClick (RunScheduledTask scheduledTask.id) ]
                        , BX.editButton [ onClick (OpenEditingModalEditScheduledTask scheduledTask) ]
                        , BX.deleteButton [ onClick NoOp ]
                        ]
                    ]
                ]

        scheduledTasksTable items =
            BX.dataTable
                [ BX.tableHeadFromColumnNames columnNames
                , BX.tableBodyFromItems tableRow (Dict.values items)
                ]
    in
    webDataTable model.scheduledTasks scheduledTasksTable


type alias UserResource a =
    { a
        | name : String
        , email : String
    }


userResourceForm : String -> UserResource a -> Html Msg
userResourceForm title resource =
    div []
        [ h1 [ class "title" ] [ text title ]
        , BF.field []
            [ BF.controlLabel [] [ text "Name" ]
            , BX.textInput
                [ placeholder "e.g. Ada"
                , value resource.name
                , onInput UpdateUserName
                ]
            ]
        , BF.field []
            [ BF.controlLabel [] [ text "Email" ]
            , BX.emailInput
                [ placeholder "e.g. ada@example.com"
                , value resource.email
                , onInput UpdateUserEmail
                ]
            ]
        , BF.field [ class "is-grouped" ]
            [ BX.saveButton [ onClick SaveFromModalForm ]
            , BX.cancelButton [ onClick CloseEditingModal ]
            ]
        ]


type alias LocationResource a =
    { a
        | name : String
        , coords : Coords
    }


locationResourceForm : String -> LocationResource a -> GoogleMapsApiKey -> Html Msg
locationResourceForm title resource googleMapsApiKey =
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
            div []
                [ BF.field []
                    [ BF.controlLabel [] [ text "Name" ]
                    , BX.textInput
                        [ placeholder "e.g. Home"
                        , value resource.name
                        , onInput UpdateLocationName
                        ]
                    ]
                , BF.field []
                    [ BF.controlLabel [] [ text "Lat" ]
                    , BX.coordInput
                        [ placeholder "e.g. 51.0100"
                        , attribute "min" "-90"
                        , attribute "max" "90"
                        , attribute "step" "0.0001"
                        , value latString
                        , onInputFloat (\v -> UpdateLocationCoords ( v, Tuple.second resource.coords ))
                        ]
                    ]
                , BF.field []
                    [ BF.controlLabel [] [ text "Lng" ]
                    , BX.coordInput
                        [ placeholder "e.g. -0.11"
                        , attribute "min" "-180"
                        , attribute "max" "180"
                        , attribute "step" "0.0001"
                        , value lngString
                        , onInputFloat (\v -> UpdateLocationCoords ( Tuple.first resource.coords, v ))
                        ]
                    ]
                , BF.field [ class "is-grouped" ]
                    [ BX.saveButton [ onClick SaveFromModalForm ]
                    , BX.cancelButton [ onClick CloseEditingModal ]
                    ]
                ]

        previewMap : Map
        previewMap =
            { apiKey = googleMapsApiKey
            , coords = resource.coords
            , markerText = String.left 1 resource.name
            , width = 287
            , height = 287
            }
    in
    BX.fullColumns
        [ BX.halfColumn
            [ h1 [ class "title" ] [ text title ]
            , editArea
            ]
        , BX.halfColumn
            [ h2 [ class "subtitle" ] [ text "Preview" ]
            , img [ src (mapToUrl previewMap) ] []
            ]
        ]


type alias ScheduledTaskResource a =
    { a
        | workflowName : String
        , frequency : Frequency
        , params : List Param
    }


scheduledTaskResourceForm : String -> ScheduledTaskResource a -> Model -> Html Msg
scheduledTaskResourceForm title resource model =
    let
        workflowMetas =
            case model.workflows of
                Success items ->
                    items
                        |> Dict.values
                        |> List.map (\i -> ( i.humanName, i.name ))

                otherwise ->
                    []

        workflowMetasWithDefaultOption =
            [ ( "Choose workflow", "choose-workflow" ) ] ++ workflowMetas

        workflowRequirements =
            case model.workflows of
                Success items ->
                    items
                        |> Dict.get resource.workflowName
                        |> Maybe.map .requirements

                otherwise ->
                    Nothing

        toTags requirements =
            requirements
                |> requirementsAsLabels
                |> List.map BX.infoTag

        requirementsDescription =
            case workflowRequirements of
                Just items ->
                    [ p [] [ text "Requires" ]
                    , BE.tags [] (toTags items)
                    ]

                Nothing ->
                    [ p [] [ text "Choose a workflow to see its requirements" ] ]

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
                    BX.timeInput
                        [ value (timePad hour ++ ":" ++ timePad minute)
                        , onInputTime UpdateScheduledTaskFrequency
                        ]

                Hourly minute _ ->
                    BX.minuteInput
                        [ value (String.fromInt minute)
                        , onInputTime UpdateScheduledTaskFrequency
                        ]
    in
    div []
        [ h1 [ class "title" ] [ text title ]
        , BX.fullColumns
            [ BX.halfColumn
                [ BF.field []
                    [ BF.controlLabel [] [ text "Workflow Name" ]
                    , BX.select
                        [ onChange UpdateScheduledTaskWorkflowName ]
                        (List.map (workflowOption resource.workflowName) workflowMetasWithDefaultOption)
                    , BF.controlHelp BM.Default [] requirementsDescription
                    ]
                , BF.field []
                    [ BF.controlLabel [] [ text "Params" ]
                    , BF.multilineFields [] (paramTags resource.params model)
                    ]
                ]
            , BX.halfColumn
                [ BF.controlLabel [] [ text "Frequency" ]
                , BF.field [ class "has-addons" ]
                    [ BX.select
                        [ onChange ResetScheduledTaskFrequency ]
                        [ option [ value "daily" ] [ text "Daily" ]
                        , option [ value "hourly" ] [ text "Hourly" ]
                        ]
                    , frequencyInput resource.frequency
                    ]
                ]
            ]
        , BF.field [ class "is-grouped" ]
            [ BX.saveButton [ onClick SaveFromModalForm ]
            , BX.cancelButton [ onClick CloseEditingModal ]
            ]
        ]


editingModalForm : Model -> Html Msg
editingModalForm model =
    case model.modalForm of
        Closed ->
            text "Nothing to see here"

        Open (NewUser userParams) ->
            userResourceForm "New User" userParams

        Open (EditUser user) ->
            userResourceForm "Edit User" user

        Open (NewLocation locationParams) ->
            locationResourceForm "New Location" locationParams model.googleMapsApiKey

        Open (EditLocation location) ->
            locationResourceForm "Edit Location" location model.googleMapsApiKey

        Open (NewScheduledTask scheduleTaskParams) ->
            scheduledTaskResourceForm "New Scheduled Task" scheduleTaskParams model

        Open (EditScheduledTask scheduledTask) ->
            scheduledTaskResourceForm "Edit Scheduled Task" scheduledTask model


editingModal : Model -> Html Msg
editingModal model =
    BCP.modal
        (model.modalForm /= Closed)
        []
        [ BCP.modalBackground [] []
        , BCP.modalCard []
            [ BCP.modalCardBody []
                [ editingModalForm model
                ]
            ]
        , BCP.easyModalClose BM.Large [] CloseEditingModal
        ]


titleBar : Brightness -> Bool -> Html Msg
titleBar brightness isTopBarMenuOpen =
    BX.titleBar isTopBarMenuOpen
        ToggleTopBarMenu
        [ BCP.navbarItemLink False
            [ onClick (SetBrightness (incBrightness 20 brightness)) ]
            [ span [ class "icon" ]
                [ BX.sunIcon
                , b [] [ text "+" ]
                ]
            ]
        , BCP.navbarItemLink False
            [ onClick (SetBrightness (decBrightness 20 brightness)) ]
            [ span [ class "icon" ]
                [ BX.sunIcon
                , b [] [ text "-" ]
                ]
            ]
        ]


body : Model -> List (Html Msg)
body model =
    [ main_ []
        [ titleBar model.brightness model.isTopBarMenuOpen
        , BL.section BL.NotSpaced
            []
            [ BX.fullColumns
                [ BX.halfColumn
                    [ BX.sectionPanel "Scheduled Tasks"
                        [ scheduledTasksSection model ]
                        (Just OpenEditingModalNewScheduledTask)
                    ]
                , BX.halfColumn
                    [ BX.sectionPanel "Locations"
                        [ locationsSection model.locations model.googleMapsApiKey ]
                        (Just OpenEditingModalNewLocation)
                    ]
                ]
            , BX.fullColumns
                [ BX.halfColumn
                    [ BX.sectionPanel "Workflows"
                        [ workflowsSection model.workflows ]
                        Nothing
                    ]
                , BX.halfColumn
                    [ BX.sectionPanel "Users"
                        [ usersSection model.users ]
                        (Just OpenEditingModalNewUser)
                    ]
                ]
            , editingModal model
            ]
        ]
    ]



-- EDITING


type alias ScheduledTaskParams =
    { frequency : Frequency
    , workflowName : String
    , params : List Param
    }


type alias LocationParams =
    { name : String
    , coords : Coords
    }


type alias UserParams =
    { name : String
    , email : String
    }


type ResourceForm
    = NewScheduledTask ScheduledTaskParams
    | EditScheduledTask ScheduledTask
    | NewUser UserParams
    | EditUser User
    | NewLocation LocationParams
    | EditLocation Location


type ModalForm
    = Closed
    | Open ResourceForm


saveFromResourceForm : ResourceForm -> Cmd Msg
saveFromResourceForm resourceForm =
    case resourceForm of
        NewLocation locationParams ->
            createLocation locationParams

        EditLocation location ->
            updateLocation location

        NewUser userParams ->
            createUser userParams

        EditUser user ->
            updateUser user

        otherwise ->
            Cmd.none


saveFromModalForm : ModalForm -> Cmd Msg
saveFromModalForm modalForm =
    case modalForm of
        Open resourceForm ->
            saveFromResourceForm resourceForm

        Closed ->
            Cmd.none



-- APPLICATION WIRING


type Msg
    = NoOp
    | RunScheduledTask Int
    | ActivateLocation Int
    | UsersResponse (WebData Users)
    | LocationsResponse (WebData Locations)
    | WorkflowsResponse (WebData Workflows)
    | ScheduledTasksResponse (WebData ScheduledTasks)
    | RunScheduledTaskResponse (WebData ())
    | ActivateLocationResponse (WebData ())
    | ToggleTopBarMenu
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
    | SaveFromModalForm
    | DeleteUser UserId
    | DeleteLocation LocationId
    | SetBrightness Brightness
    | CreateUserResponse (WebData User)
    | UpdateUserResponse (WebData ())
    | DeleteUserResponse UserId (WebData ())
    | DeleteLocationResponse LocationId (WebData ())
    | CreateLocationResponse (WebData Location)
    | UpdateLocationResponse (WebData ())
    | SetBrightnessResponse (WebData ())


type alias Model =
    { googleMapsApiKey : GoogleMapsApiKey
    , isTopBarMenuOpen : Bool
    , users : WebData Users
    , locations : WebData Locations
    , workflows : WebData Workflows
    , scheduledTasks : WebData ScheduledTasks
    , brightness : Brightness
    , runningTask : Maybe Int
    , modalForm : ModalForm
    }


main : Program GoogleMapsApiKey Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : GoogleMapsApiKey -> ( Model, Cmd Msg )
init googleMapsApiKey =
    ( { googleMapsApiKey = googleMapsApiKey
      , isTopBarMenuOpen = False
      , users = NotAsked
      , locations = NotAsked
      , workflows = NotAsked
      , scheduledTasks = NotAsked
      , brightness = 1
      , runningTask = Nothing
      , modalForm = Closed
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

        RunScheduledTask taskId ->
            ( { model | runningTask = Just taskId }, runScheduledTask taskId )

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

        RunScheduledTaskResponse _ ->
            ( { model | runningTask = Nothing }, Cmd.none )

        ActivateLocationResponse _ ->
            ( model, getLocations )

        ToggleTopBarMenu ->
            ( { model | isTopBarMenuOpen = not model.isTopBarMenuOpen }, Cmd.none )

        CloseEditingModal ->
            ( { model | modalForm = Closed }, Cmd.none )

        OpenEditingModalNewUser ->
            let
                newUserForm =
                    NewUser { name = "e.g. Ada", email = "e.g. ada@example.com" }
            in
            ( { model | modalForm = Open newUserForm }, Cmd.none )

        OpenEditingModalEditUser user ->
            ( { model | modalForm = Open (EditUser user) }, Cmd.none )

        OpenEditingModalNewLocation ->
            let
                newLocationForm =
                    NewLocation { name = "e.g. Home", coords = ( 0, 0 ) }
            in
            ( { model | modalForm = Open newLocationForm }, Cmd.none )

        OpenEditingModalEditLocation location ->
            ( { model | modalForm = Open (EditLocation location) }, Cmd.none )

        OpenEditingModalNewScheduledTask ->
            let
                newScheduledTaskForm =
                    NewScheduledTask
                        { frequency = Daily 9 0
                        , workflowName = "Choose name"
                        , params = []
                        }
            in
            ( { model | modalForm = Open newScheduledTaskForm }, Cmd.none )

        OpenEditingModalEditScheduledTask scheduledTask ->
            ( { model | modalForm = Open (EditScheduledTask scheduledTask) }, Cmd.none )

        UpdateUserName newName ->
            let
                newEditForm =
                    case model.modalForm of
                        Open (NewUser userParams) ->
                            Open (NewUser { userParams | name = newName })

                        Open (EditUser user) ->
                            Open (EditUser { user | name = newName })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        UpdateUserEmail newEmail ->
            let
                newEditForm =
                    case model.modalForm of
                        Open (NewUser userParams) ->
                            Open (NewUser { userParams | email = newEmail })

                        Open (EditUser user) ->
                            Open (EditUser { user | email = newEmail })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        UpdateLocationName newName ->
            let
                newEditForm =
                    case model.modalForm of
                        Open (NewLocation locationParams) ->
                            Open (NewLocation { locationParams | name = newName })

                        Open (EditLocation location) ->
                            Open (EditLocation { location | name = newName })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        UpdateLocationCoords newCoords ->
            let
                newEditForm =
                    case model.modalForm of
                        Open (NewLocation locationParams) ->
                            Open (NewLocation { locationParams | coords = newCoords })

                        Open (EditLocation location) ->
                            Open (EditLocation { location | coords = newCoords })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        UpdateScheduledTaskWorkflowName newWorkflowName ->
            let
                newEditForm =
                    case model.modalForm of
                        Open (NewScheduledTask scheduleTaskParams) ->
                            Open (NewScheduledTask { scheduleTaskParams | workflowName = newWorkflowName })

                        Open (EditScheduledTask scheduledTask) ->
                            Open (EditScheduledTask { scheduledTask | workflowName = newWorkflowName })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        UpdateScheduledTaskFrequency newFrequency ->
            let
                newEditForm =
                    case model.modalForm of
                        Open (NewScheduledTask scheduleTaskParams) ->
                            Open (NewScheduledTask { scheduleTaskParams | frequency = newFrequency })

                        Open (EditScheduledTask scheduledTask) ->
                            Open (EditScheduledTask { scheduledTask | frequency = newFrequency })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        ResetScheduledTaskFrequency typeString ->
            let
                newFrequency =
                    case typeString of
                        "daily" ->
                            Daily 9 0

                        "hourly" ->
                            Hourly 30 0

                        otherwise ->
                            Daily 9 0

                newEditForm =
                    case model.modalForm of
                        Open (NewScheduledTask scheduleTaskParams) ->
                            Open (NewScheduledTask { scheduleTaskParams | frequency = newFrequency })

                        Open (EditScheduledTask scheduledTask) ->
                            Open (EditScheduledTask { scheduledTask | frequency = newFrequency })

                        otherwise ->
                            model.modalForm
            in
            ( { model | modalForm = newEditForm }, Cmd.none )

        SaveFromModalForm ->
            ( model, saveFromModalForm model.modalForm )

        DeleteUser userId ->
            ( model, deleteUser userId )

        DeleteLocation locationId ->
            ( model, deleteLocation locationId )

        SetBrightness brightness ->
            ( { model | brightness = brightness }, setBrightness brightness )

        CreateUserResponse response ->
            case response of
                Success user ->
                    ( { model
                        | users = RemoteData.map (Dict.insert user.id user) model.users
                        , modalForm = Closed
                      }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        UpdateUserResponse _ ->
            case model.modalForm of
                Open (EditUser user) ->
                    ( { model
                        | users = RemoteData.map (Dict.insert user.id user) model.users
                        , modalForm = Closed
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
                        , modalForm = Closed
                      }
                    , Cmd.none
                    )

                otherwise ->
                    ( model, Cmd.none )

        UpdateLocationResponse _ ->
            case model.modalForm of
                Open (EditLocation location) ->
                    ( { model
                        | locations = RemoteData.map (Dict.insert location.id location) model.locations
                        , modalForm = Closed
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

        SetBrightnessResponse _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
