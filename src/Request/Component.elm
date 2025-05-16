module Request.Component exposing
    ( createComponent
    , deleteComponent
    , getComponents
    , patchComponent
    )

import Data.Component as Component exposing (Component)
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Request.BackendHttp as BackendHttp exposing (WebData)


createComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
createComponent session event component =
    BackendHttp.post session
        "components"
        event
        (Component.decode Scope.all)
        (Component.encode component)


deleteComponent : Session -> (WebData () -> msg) -> Component -> Cmd msg
deleteComponent session event component =
    -- FIXME: need to encode component in json body as previously?
    BackendHttp.delete session ("components/" ++ Component.idToString component.id) event


getComponents : Session -> List Scope -> (WebData (List Component) -> msg) -> Cmd msg
getComponents session scopes event =
    BackendHttp.get session "components" event (Component.decodeList scopes)


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent session event component =
    BackendHttp.patch session
        ("components/" ++ Component.idToString component.id)
        event
        (Component.decode Scope.all)
        (Component.encode component)
