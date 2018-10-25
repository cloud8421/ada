module Main exposing (main)

import Browser exposing (Document)
import Bulma as Bulma
import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput)
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


type alias Workflow =
    { name : String
    , humanName : String
    , requirements : List WorkflowRequirement
    }



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


collectionToDict : List { a | id : comparable } -> Dict.Dict comparable { a | id : comparable }
collectionToDict items =
    List.map (\i -> ( i.id, i )) items
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
        |> Cmd.map (RemoteData.map collectionToDict)
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
        |> Cmd.map (RemoteData.map collectionToDict)
        |> Cmd.map LocationsResponse


activateLocation : Int -> Cmd Msg
activateLocation locationId =
    putNoBodyNoContent ("/locations/" ++ String.fromInt locationId ++ "/activate")
        |> RemoteData.sendRequest
        |> Cmd.map ActivateLocationResponse



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
        |> Cmd.map (RemoteData.map collectionToDict)
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
                , td
                    [ class "actions" ]
                    [ Bulma.actionButton Bulma.Edit (OpenEditingModalEditUser user)
                    , Bulma.dangerActionButton Bulma.Delete (DeleteUser user.id)
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "ID", "Name", "Email", "Actions" ]
                , tbody [] (List.map userRow (Dict.values items))
                ]
    in
    Bulma.block "Users" OpenEditingModalNewUser (webDataTable users contentArea)


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


locationsSection : WebData Locations -> String -> Html Msg
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
                , td [] [ text <| activeLabel location.active ]
                , td [] [ gMap location.coords gmapsApiKey ]
                , td
                    [ class "actions" ]
                    [ a
                        ([ class "button is-small is-primary"
                         , onClick (ActivateLocation location.id)
                         ]
                            ++ disabledAttr
                        )
                        [ Bulma.iconButton Bulma.Activate ]
                    , a [ class "button is-small is-link" ] [ Bulma.iconButton Bulma.Edit ]
                    , a [ class "button is-small is-danger" ] [ Bulma.iconButton Bulma.Delete ]
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "ID", "Name", "Status", "Coordinates", "Actions" ]
                , tbody [] (List.map locationRow (Dict.values items))
                ]
    in
    Bulma.block "Locations" OpenEditingModalNewUser (webDataTable locations contentArea)


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

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "Name", "Requirements" ]
                , tbody [] (List.map workflowRow items)
                ]
    in
    Bulma.block "Workflows" OpenEditingModalNewUser (webDataTable workflows contentArea)


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


scheduledTasksSection : WebData ScheduledTasks -> Maybe Int -> Html Msg
scheduledTasksSection scheduledTasks runningTask =
    let
        formatParam param =
            case param of
                UserId id ->
                    Bulma.tagWithAddons "user" (String.fromInt id)

                LocationId id ->
                    Bulma.tagWithAddons "location" (String.fromInt id)

                NewsTag tag ->
                    Bulma.tagWithAddons "news tag" tag

                UnsupportedParam ->
                    Bulma.tag "unsupported"

        scheduledTaskRow scheduledTask =
            let
                runClassList =
                    [ ( "button is-small", True ), ( "is-primary", True ), ( "is-loading", runningTask == Just scheduledTask.id ) ]
            in
            tr []
                [ td [] [ text <| String.fromInt scheduledTask.id ]
                , td [] [ text scheduledTask.workflowHumanName ]
                , td [ class "field is-grouped is-grouped-multiline" ]
                    [ div [ class "field is-grouped is-grouped-multiline" ]
                        (List.map formatParam scheduledTask.params)
                    ]
                , td [] [ text <| formatFrequency scheduledTask.frequency ]
                , td
                    [ class "actions" ]
                    [ a
                        [ classList runClassList
                        , onClick (ExecuteScheduledTask scheduledTask.id)
                        ]
                        [ Bulma.iconButton Bulma.Run ]
                    , a [ class "button is-small is-link" ] [ Bulma.iconButton Bulma.Edit ]
                    , a [ class "button is-small is-danger" ] [ Bulma.iconButton Bulma.Delete ]
                    ]
                ]

        contentArea items =
            table [ class "table is-fullwidth" ]
                [ Bulma.tableHead [ "ID", "Workflow Name", "Params", "Frequency", "Actions" ]
                , tbody [] (List.map scheduledTaskRow (Dict.values items))
                ]
    in
    Bulma.block "Scheduled Tasks" OpenEditingModalNewUser (webDataTable scheduledTasks contentArea)


editingModalForm : EditForm -> Html Msg
editingModalForm editForm =
    let
        userForm title resource =
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
    in
    case editForm of
        Closed ->
            text "Nothing to see here"

        NewUser userParams ->
            userForm "New User" userParams

        EditUser user ->
            userForm "Edit User" user

        otherwise ->
            div [] [ text "Not implemented yet" ]


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
            [ div [ class "box" ]
                [ editingModalForm model.editForm
                ]
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
            [ scheduledTasksSection model.scheduledTasks model.runningTask
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
    , location : Coords
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



-- APPLICATION WIRING


type alias Flags =
    String


type Msg
    = NoOp
    | ExecuteScheduledTask Int
    | ActivateLocation Int
    | UsersResponse (WebData Users)
    | LocationsResponse (WebData Locations)
    | WorkflowsResponse (WebData (List Workflow))
    | ScheduledTasksResponse (WebData ScheduledTasks)
    | ExecuteScheduledTaskResponse (WebData ())
    | ActivateLocationResponse (WebData ())
    | CloseEditingModal
    | OpenEditingModalNewUser
    | OpenEditingModalEditUser User
    | UpdateUserName String
    | UpdateUserEmail String
    | SaveUser
    | DeleteUser UserId
    | CreateUserResponse (WebData User)
    | UpdateUserResponse (WebData ())
    | DeleteUserResponse UserId (WebData ())


type alias Model =
    { gmapsApiKey : String
    , users : WebData Users
    , locations : WebData Locations
    , workflows : WebData (List Workflow)
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

        SaveUser ->
            ( model, saveUser model.editForm )

        DeleteUser userId ->
            ( model, deleteUser userId )

        CreateUserResponse _ ->
            ( { model | editForm = Closed }, getUsers )

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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
