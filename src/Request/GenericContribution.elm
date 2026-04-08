module Request.GenericContribution exposing
    ( ContributionResponse
    , create
    )

import Data.Component as Component
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Request.BackendHttp as BackendHttp exposing (WebData)


type alias ContributionData =
    { description : String
    , name : String
    , query : Component.Query
    , scope : Scope
    }


type alias ContributionResponse =
    { branchName : String
    , pullRequestUrl : String
    }


decodeContributionResponse : Decoder ContributionResponse
decodeContributionResponse =
    Decode.map2 ContributionResponse
        (Decode.field "branchName" Decode.string)
        (Decode.field "pullRequestUrl" Decode.string)


create : Session -> ContributionData -> (WebData ContributionResponse -> msg) -> Cmd msg
create session contributionData event =
    BackendHttp.post session
        "generic/examples/contributions"
        event
        decodeContributionResponse
        (encodeContributionData contributionData)


encodeContributionData : ContributionData -> Encode.Value
encodeContributionData contributionData =
    Encode.object
        [ ( "description", Encode.string contributionData.description )
        , ( "name", Encode.string contributionData.name )
        , ( "query", Component.encodeQuery contributionData.query )
        , ( "scope", contributionData.scope |> Scope.toString |> Encode.string )
        ]
