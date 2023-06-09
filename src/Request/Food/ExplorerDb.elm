module Request.Food.ExplorerDb exposing (loadDb)

import Data.Food.Explorer.Db exposing (Db)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import Request.Common exposing (getJson)
import Task exposing (Task)


handleProductsLoaded : Session -> List Process -> WebData Products -> Task () (WebData Db)
handleProductsLoaded session processes productsData =
    case productsData of
        RemoteData.Success products ->
            let
                explorerDb =
                    session.explorerDb
            in
            Task.succeed
                (RemoteData.succeed
                    { explorerDb
                        | countries = session.db.countries
                        , transports = session.db.transports
                        , processes = processes
                        , products = products
                    }
                )

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleProcessesLoaded : Session -> WebData (List Process) -> Task () (WebData Db)
handleProcessesLoaded session processesData =
    case processesData of
        RemoteData.Success processes ->
            getJson (Product.decodeProducts processes) "food/products.json"
                |> Task.andThen (handleProductsLoaded session processes)

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadDb : Session -> (WebData Db -> msg) -> Cmd msg
loadDb session event =
    getJson Process.decodeList "food/processes/explorer.json"
        |> Task.andThen (handleProcessesLoaded session)
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
