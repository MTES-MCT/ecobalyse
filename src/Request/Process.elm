module Request.Process exposing (getProcesses)

import Data.Impact as Impact
import Data.Process as Process exposing (Process)
import Data.Session exposing (Session)
import Request.BackendHttp as BackendHttp exposing (WebData)


getProcesses : Session -> (WebData (List Process) -> msg) -> Cmd msg
getProcesses session event =
    BackendHttp.get session "processes" event (Process.decodeList Impact.decodeImpacts)
