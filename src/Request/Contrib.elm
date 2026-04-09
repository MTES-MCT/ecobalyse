module Request.Contrib exposing
    ( ContribData
    , ContribResponse
    , create
    )

import Data.Component as Component
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Request.BackendHttp as BackendHttp exposing (WebData)


type alias ContribData =
    { description : String
    , name : String
    , query : Component.Query
    , scope : Scope
    }


type alias ContribResponse =
    { branchName : String
    , pullRequestUrl : String
    }


create : Session -> ContribData -> (WebData ContribResponse -> msg) -> Cmd msg
create session contribData event =
    BackendHttp.post session
        "contrib/examples"
        event
        decodeContribResponse
        (encodeContribData contribData)


decodeContribResponse : Decoder ContribResponse
decodeContribResponse =
    Decode.map2 ContribResponse
        (Decode.field "branchName" Decode.string)
        (Decode.field "pullRequestUrl" Decode.string)


encodeContribData : ContribData -> Encode.Value
encodeContribData contribData =
    Encode.object
        [ ( "description", Encode.string contribData.description )
        , ( "name", Encode.string contribData.name )
        , ( "query", Component.encodeQuery contribData.query )
        , ( "scope", contribData.scope |> Scope.toString |> Encode.string )
        ]
