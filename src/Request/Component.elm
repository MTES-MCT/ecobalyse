module Request.Component exposing (getComponents)

-- import Data.Example as Example exposing (Example)

import Data.Component as Component exposing (Component)
import Data.Scope as Scope
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultConfig)


apiBaseUrl : String
apiBaseUrl =
    -- FIXME: should be configurable
    "https://ecobalyse-data-pr65.osc-fr1.scalingo.io/api"


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents _ event =
    -- FIXME: use session to secure access?
    Component.decodeList Scope.all
        |> Http.getWithConfig { defaultConfig | headers = [] } (apiBaseUrl ++ "/components") event
