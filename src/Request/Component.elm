module Request.Component exposing
    ( createComponent
    , deleteComponent
    , getComponent
    , getComponents
    , getJournal
    , patchComponent
    )

import Data.Component as Component exposing (Component)
import Data.JournalEntry exposing (JournalEntry)
import Data.Session exposing (Session)
import Request.BackendHttp as BackendHttp exposing (WebData)
import Request.Journal as JournalHttp


createComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
createComponent session event component =
    BackendHttp.post session
        "components"
        event
        Component.decode
        (Component.encode component)


deleteComponent : Session -> (WebData () -> msg) -> Component -> Cmd msg
deleteComponent session event component =
    case component.id of
        Just id ->
            BackendHttp.delete session ("components/" ++ Component.idToString id) event

        Nothing ->
            -- FIXME: actually, an error should be returned here
            Cmd.none


getComponent : Session -> (WebData Component -> msg) -> Component.Id -> Cmd msg
getComponent session event componentId =
    BackendHttp.get session
        (String.join "/" [ "components", Component.idToString componentId ])
        event
        Component.decode


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents session event =
    BackendHttp.get session "components" event Component.decodeList


getJournal : Session -> (WebData (List (JournalEntry String)) -> msg) -> Component.Id -> Cmd msg
getJournal =
    JournalHttp.getForComponent


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent session event component =
    case component.id of
        Just id ->
            BackendHttp.patch session
                ("components/" ++ Component.idToString id)
                event
                Component.decode
                (Component.encode component)

        Nothing ->
            -- FIXME: actually, an error should be returned here
            Cmd.none
