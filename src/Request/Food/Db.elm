module Request.Food.Db exposing (loadDb)

import Data.Food.Db exposing (Db)
import Data.Food.Process as Process exposing (Processes)
import Data.Food.Product as Product exposing (Products)
import Data.Impact as Impact
import Data.Session exposing (Session)
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultTaskConfig)
import Task exposing (Task)


taskConfig : Http.TaskConfig
taskConfig =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultTaskConfig | headers = [] }


getJson : Decoder a -> String -> Task () (WebData a)
getJson decoder file =
    Http.getTaskWithConfig taskConfig ("data/" ++ file) decoder


handleProductsLoaded : List Impact.Definition -> Processes -> WebData Products -> Task () (WebData Db)
handleProductsLoaded impacts processes productsData =
    case productsData of
        RemoteData.Success products ->
            Task.succeed (RemoteData.succeed (Db impacts processes products))

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleProcessesLoaded : List Impact.Definition -> WebData Processes -> Task () (WebData Db)
handleProcessesLoaded impacts processesData =
    case processesData of
        RemoteData.Success processes ->
            getJson (Product.decodeProducts processes) "food/products.json"
                |> Task.andThen (handleProductsLoaded impacts processes)

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadDb : Session -> (WebData Db -> msg) -> Cmd msg
loadDb { db } event =
    getJson (Process.decodeProcesses db.impacts) "food/processes.json"
        |> Task.andThen (handleProcessesLoaded db.impacts)
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
