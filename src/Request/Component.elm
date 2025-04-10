module Request.Component exposing
    ( deleteComponent
    , getComponents
    , patchComponent
    )

import Data.Component as Component exposing (Component)
import Data.Scope as Scope
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultConfig)


deleteComponent : Session -> (WebData String -> msg) -> Component -> Cmd msg
deleteComponent { backendApiUrl } event component =
    -- FIXME: use session token to secure access?
    Http.deleteWithConfig { defaultConfig | headers = [] }
        (backendApiUrl ++ "/api/components/" ++ Component.idToString component.id)
        event
        (Component.encode component)


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents { backendApiUrl } event =
    -- FIXME: use session token to secure access?
    Component.decodeList Scope.all
        |> Http.getWithConfig { defaultConfig | headers = [] }
            (backendApiUrl ++ "/api/components")
            event


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent { backendApiUrl } event component =
    -- FIXME: use session token to secure access?
    Http.patchWithConfig { defaultConfig | headers = [] }
        (backendApiUrl ++ "/api/components/" ++ Component.idToString component.id)
        event
        (Component.decode Scope.all)
        (Component.encode component)
