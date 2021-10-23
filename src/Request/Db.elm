module Request.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.Db as Db exposing (Db)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import Data.Transport as Transport exposing (Distances)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultTaskConfig)
import Task exposing (Task)


taskConfig : Http.TaskConfig
taskConfig =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultTaskConfig | headers = [] }


getProcessesTask : Session -> Task () (WebData (List Process))
getProcessesTask _ =
    Http.getTaskWithConfig taskConfig "data/processes.json" Process.decodeList


getCountriesTask : Session -> Task () (WebData (List Country))
getCountriesTask _ =
    Http.getTaskWithConfig taskConfig "data/countries.json" Country.decodeList


getProductsTask : Session -> Task () (WebData (List Product))
getProductsTask _ =
    Http.getTaskWithConfig taskConfig "data/products.json" Product.decodeList


getTransportsTask : Session -> Task () (WebData Distances)
getTransportsTask _ =
    Http.getTaskWithConfig taskConfig "data/transports.json" Transport.decodeDistances


getDb : Session -> Task () (WebData Db)
getDb session =
    -- Loading order:
    -- 1. processes (so we get materials)
    -- 2. countries (so we can populate country processes)
    -- 3. products
    -- 4. TODO transports
    Task.map4 Db.build
        (getProcessesTask session)
        (getCountriesTask session)
        (getProductsTask session)
        (getTransportsTask session)


loadDb : Session -> (WebData Db -> msg) -> Cmd msg
loadDb session event =
    getDb session
        |> Task.attempt
            (\result ->
                case result of
                    Ok wd ->
                        event wd

                    Err _ ->
                        -- Note: this `Task () (WebData Db)` error situation can never happen
                        -- This is a limitation from the types returned by RemoteData.Http tasks
                        event RemoteData.NotAsked
            )
