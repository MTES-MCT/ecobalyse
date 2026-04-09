module Request.Contrib exposing
    ( ExampleContribData
    , ExampleContribResponse
    , createExampleContrib
    )

import Data.Component as Component
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Request.BackendHttp as BackendHttp exposing (WebData)


type alias ExampleContribData =
    { description : String
    , name : String
    , query : Component.Query
    , scope : Scope
    }


type alias ExampleContribResponse =
    { branchName : String
    , pullRequestUrl : String
    }


createExampleContrib :
    Session
    -> ExampleContribData
    -> (WebData ExampleContribResponse -> msg)
    -> Cmd msg
createExampleContrib session contribData event =
    BackendHttp.post session
        "contrib/examples"
        event
        decodeExampleContribResponse
        (encodeExampleContribData contribData)


decodeExampleContribResponse : Decoder ExampleContribResponse
decodeExampleContribResponse =
    Decode.map2 ExampleContribResponse
        (Decode.field "branchName" Decode.string)
        (Decode.field "pullRequestUrl" Decode.string)


encodeExampleContribData : ExampleContribData -> Encode.Value
encodeExampleContribData contribData =
    Encode.object
        [ ( "description", Encode.string contribData.description )
        , ( "name", Encode.string contribData.name )
        , ( "query", Component.encodeQuery contribData.query )
        , ( "scope", contribData.scope |> Scope.toString |> Encode.string )
        ]
