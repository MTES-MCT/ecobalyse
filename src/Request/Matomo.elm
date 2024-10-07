module Request.Matomo exposing (getApiStats, getWebStats)

import Data.Matomo as Matomo
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)


getStats : String -> String -> String -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getStats host jsonKey qs event =
    Http.get
        { expect =
            Matomo.decodeStats jsonKey
                |> Http.expectJson (RemoteData.fromResult >> event)
        , url = "https://" ++ host ++ "/" ++ qs
        }


getApiStats : Session -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getApiStats { matomo } =
    "?module=API&method=Goals.get&format=json&idGoal=1&period=day&date=last30&idSite="
        ++ matomo.siteId
        |> getStats matomo.host "nb_conversions"


getWebStats : Session -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getWebStats { matomo } =
    "?module=API&method=VisitsSummary.get&format=json&period=day&date=last30&idSite="
        ++ matomo.siteId
        |> getStats matomo.host "nb_visits"
