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


apiBaseUrl : String
apiBaseUrl =
    -- FIXME: should be configurable
    "https://ecobalyse-data-pr65.osc-fr1.scalingo.io/api"


deleteComponent : Session -> (WebData String -> msg) -> Component -> Cmd msg
deleteComponent _ event component =
    -- FIXME: use session token to secure access?
    Http.deleteWithConfig { defaultConfig | headers = [] }
        (apiBaseUrl ++ "/components/" ++ Component.idToString component.id)
        event
        (Component.encode component)


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents _ event =
    -- FIXME: use session token to secure access?
    Component.decodeList Scope.all
        |> Http.getWithConfig { defaultConfig | headers = [] }
            (apiBaseUrl ++ "/components")
            event


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent _ event component =
    -- FIXME: use session token to secure access?
    Http.patchWithConfig { defaultConfig | headers = [] }
        (apiBaseUrl ++ "/components/" ++ Component.idToString component.id)
        event
        (Component.decode Scope.all)
        (Component.encode component)
