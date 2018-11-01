module Workflow exposing (..)


type Param
    = UserId Int
    | LocationId Int
    | NewsTag String


type Requirement
    = RequiresUserId
    | RequiresLocationId
    | RequiresNewsTag
