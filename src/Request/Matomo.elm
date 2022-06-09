module Request.Matomo exposing (getApiStats, getWebStats)

import Data.Matomo as Matomo
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)


getStats : Session -> String -> String -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getStats _ jsonKey qs event =
    Http.get
        { url = "https://stats.data.gouv.fr/" ++ qs
        , expect =
            Matomo.decodeStats jsonKey
                |> Http.expectJson (RemoteData.fromResult >> event)
        }


getApiStats : Session -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getApiStats session =
    getStats session "nb_conversions" "?module=API&method=Goals.get&format=json&idSite=196&idGoal=1&period=day&date=last30"


getWebStats : Session -> (WebData (List Matomo.Stat) -> msg) -> Cmd msg
getWebStats session =
    getStats session "nb_visits" "?module=API&method=VisitsSummary.get&format=json&idSite=196&period=day&date=last30"
