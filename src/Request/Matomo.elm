module Request.Matomo exposing (getApiStats, getWebStats)

import Data.Matomo as Matomo
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)


getStats : String -> String -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getStats jsonKey qs event =
    Http.get
        { url = "https://stats.beta.gouv.fr/" ++ qs
        , expect =
            Matomo.decodeStats jsonKey
                |> Http.expectJson (RemoteData.fromResult >> event)
        }


getApiStats : Session -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getApiStats { matomoSiteId } =
    "?module=API&method=Goals.get&format=json&idGoal=1&period=day&date=last30&idSite="
        ++ matomoSiteId
        |> getStats "nb_conversions"


getWebStats : Session -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getWebStats { matomoSiteId } =
    "?module=API&method=VisitsSummary.get&format=json&period=day&date=last30&idSite="
        ++ matomoSiteId
        |> getStats "nb_visits"
