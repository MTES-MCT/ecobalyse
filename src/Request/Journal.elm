module Request.Journal exposing (getForComponent)

import Data.Component as Component
import Data.JournalEntry as JournalEntry exposing (JournalEntry)
import Data.Session exposing (Session)
import Json.Decode as Decode
import Request.BackendHttp as BackendHttp exposing (WebData)


getForComponent : Session -> (WebData (List (JournalEntry String)) -> msg) -> Component.Id -> Cmd msg
getForComponent session event componentId =
    BackendHttp.get session
        (String.join "/" [ "journal", "component", Component.idToString componentId ])
        event
        (Decode.list (JournalEntry.decodeEntry Decode.string))
