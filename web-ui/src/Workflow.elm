module Workflow exposing (..)


type Param
    = UserId Int
    | LocationId Int
    | NewsTag String


type Requirement
    = RequiresUserId
    | RequiresLocationId
    | RequiresNewsTag


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
    in
    List.map asLabel requirements
