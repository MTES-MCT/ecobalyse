module Request.Db exposing (..)

import Data.Country as Country exposing (Country2)
import Data.Db exposing (Db)
import Data.Material as Material
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
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


getCountriesTask : Session -> Task () (WebData (List Country2))
getCountriesTask _ =
    Http.getTaskWithConfig taskConfig "data/countries.json" Country.decodeList2


getProductsTask : Session -> Task () (WebData (List Product))
getProductsTask _ =
    Http.getTaskWithConfig taskConfig "data/products.json" Product.decodeList


buildDb : WebData (List Process) -> WebData (List Country2) -> WebData (List Product) -> WebData Db
buildDb =
    RemoteData.map3
        (\processes countries products ->
            { processes = processes
            , countries = countries
            , materials = Material.fromProcesses processes
            , products = products
            }
        )


getDb : Session -> Task () (WebData Db)
getDb session =
    Task.map3 buildDb
        (getProcessesTask session)
        (getCountriesTask session)
        (getProductsTask session)


loadDb : Session -> (WebData Db -> msg) -> Cmd msg
loadDb session event =
    getDb session
        |> Task.attempt
            (\result ->
                case result of
                    Ok wd ->
                        event wd

                    Err _ ->
                        -- Note: this `Task () (WebData Db)` situation can never happen
                        -- This is a limitation from the types returned by RemoteData.Http tasks
                        event RemoteData.NotAsked
            )
