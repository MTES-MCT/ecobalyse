module Request.Auth exposing (processes, user)

import Data.User as User exposing (User)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Static.Db exposing (AllProcessesJson)


decodeAllProcessesJson : Decoder AllProcessesJson
decodeAllProcessesJson =
    Decode.succeed AllProcessesJson
        |> JDP.required "textileProcesses" Decode.string
        |> JDP.required "foodProcesses" Decode.string


processes : String -> (Result Http.Error AllProcessesJson -> msg) -> Cmd msg
processes token event =
    Http.request
        { method = "GET"
        , url = "processes/processes.json"
        , headers = [ Http.header "token" token ]
        , body = Http.emptyBody
        , expect = Http.expectJson event decodeAllProcessesJson
        , timeout = Nothing
        , tracker = Nothing
        }


user : (Result Http.Error User -> msg) -> Cmd msg
user event =
    Http.riskyRequest
        { method = "GET"
        , headers = []
        , url = "/accounts/profile/"
        , body = Http.emptyBody
        , expect = Http.expectJson event User.decode
        , timeout = Nothing
        , tracker = Nothing
        }
