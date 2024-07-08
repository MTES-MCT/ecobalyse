module Request.Auth exposing (processes, user)

import Data.User as User exposing (User)
import Http
import Static.Db as Db
import Static.Json exposing (RawJsonProcesses)


processes : String -> (Result Http.Error RawJsonProcesses -> msg) -> Cmd msg
processes token event =
    Http.request
        { method = "GET"
        , url = "processes/processes.json"
        , headers = [ Http.header "token" token ]
        , body = Http.emptyBody
        , expect = Http.expectJson event Db.decodeRawJsonProcesses
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
