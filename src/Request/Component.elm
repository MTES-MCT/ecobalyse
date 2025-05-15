module Request.Component exposing
    ( createComponent
    , deleteComponent
    , getComponents
    , patchComponent
    )

import Data.Component as Component exposing (Component)
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Http
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultConfig)


authHeaders : Maybe Session.Auth2 -> Http.Config
authHeaders maybeAuth2 =
    { defaultConfig
        | headers =
            case maybeAuth2 of
                Just { accessTokenData } ->
                    [ Http.header "Authorization" <| "Bearer " ++ accessTokenData.accessToken ]

                Nothing ->
                    []
    }


createComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
createComponent { backendApiUrl, store } event component =
    Http.postWithConfig (authHeaders store.auth2)
        (endpoint backendApiUrl "")
        event
        (Component.decode Scope.all)
        (Component.encode component)


deleteComponent : Session -> (WebData String -> msg) -> Component -> Cmd msg
deleteComponent { backendApiUrl, store } event component =
    Http.deleteWithConfig (authHeaders store.auth2)
        (endpoint backendApiUrl <| Component.idToString component.id)
        event
        (Component.encode component)


endpoint : String -> String -> String
endpoint backendApiUrl path =
    String.join "/" [ backendApiUrl, "api/components", path ]


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents { backendApiUrl } event =
    Http.getWithConfig defaultConfig
        (endpoint backendApiUrl "")
        event
        (Component.decodeList Scope.all)


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent { backendApiUrl, store } event component =
    Http.patchWithConfig (authHeaders store.auth2)
        (endpoint backendApiUrl <| Component.idToString component.id)
        event
        (Component.decode Scope.all)
        (Component.encode component)
