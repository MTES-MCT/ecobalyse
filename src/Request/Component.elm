module Request.Component exposing
    ( createComponent
    , deleteComponent
    , getComponents
    , patchComponent
    )

import Data.Component as Component exposing (Component)
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultConfig)


createComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
createComponent { backendApiUrl } event component =
    -- FIXME: use session token to secure access?
    Http.postWithConfig defaultConfig
        (endpoint backendApiUrl "")
        event
        Component.decode
        (Component.encode component)


deleteComponent : Session -> (WebData String -> msg) -> Component -> Cmd msg
deleteComponent { backendApiUrl } event component =
    -- FIXME: use session token to secure access?
    Http.deleteWithConfig defaultConfig
        (endpoint backendApiUrl <| Component.idToString component.id)
        event
        (Component.encode component)


endpoint : String -> String -> String
endpoint backendApiUrl path =
    String.join "/" [ backendApiUrl, "api/components", path ]


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents { backendApiUrl } event =
    -- FIXME: use session token to secure access?
    Http.getWithConfig defaultConfig
        (endpoint backendApiUrl "")
        event
        Component.decodeList


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent { backendApiUrl } event component =
    -- FIXME: use session token to secure access?
    Http.patchWithConfig defaultConfig
        (endpoint backendApiUrl <| Component.idToString component.id)
        event
        Component.decode
        (Component.encode component)
