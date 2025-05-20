module Request.ApiToken exposing
    ( create
    , list
    )

import Data.ApiToken as ApiToken exposing (CreatedToken, Token)
import Data.Session exposing (Session)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.BackendHttp as BackendHttp exposing (WebData)


create : Session -> (WebData Token -> msg) -> Cmd msg
create session event =
    BackendHttp.post session
        "tokens"
        event
        (Decode.at [ "token" ] ApiToken.decodeToken)
        Encode.null


list : Session -> (WebData (List CreatedToken) -> msg) -> Cmd msg
list session event =
    BackendHttp.get session
        "tokens"
        event
        (Decode.list ApiToken.decodeCreatedToken)
