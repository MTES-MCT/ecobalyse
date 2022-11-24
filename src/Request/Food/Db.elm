module Request.Food.Db exposing (loadBuilderDb, loadExplorerDb)

import Data.Food.Db exposing (Db)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import Request.Common exposing (getJson)
import Task exposing (Task)



---- Explorer


handleProductsLoaded : Session -> List Process -> WebData Products -> Task () (WebData Db)
handleProductsLoaded session processes productsData =
    case productsData of
        RemoteData.Success products ->
            let
                foodDb =
                    session.foodDb
            in
            Task.succeed
                (RemoteData.succeed
                    { foodDb
                        | processes = processes
                        , products = products
                        , impacts = session.db.impacts
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


loadExplorerDb : Session -> (WebData Db -> msg) -> Cmd msg
loadExplorerDb session event =
    getJson (Process.decodeList session.db.impacts) "food/processes.json"
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



---- Builder


handleBuilderProcessesLoaded : Session -> WebData (List Process) -> Task () (WebData Db)
handleBuilderProcessesLoaded session processesData =
    case processesData of
        RemoteData.Success processes ->
            getJson (Ingredient.decodeIngredients processes) "food/ingredients.json"
                |> Task.andThen (handleIngredientsLoaded session processes)

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleIngredientsLoaded : Session -> List Process -> WebData (List Ingredient) -> Task () (WebData Db)
handleIngredientsLoaded session processes ingredientsData =
    case ingredientsData of
        RemoteData.Success ingredients ->
            let
                foodDb =
                    session.foodDb
            in
            Task.succeed
                (RemoteData.succeed
                    { foodDb
                        | builderProcesses = processes
                        , ingredients = ingredients
                        , impacts = session.db.impacts
                    }
                )

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadBuilderDb : Session -> (WebData Db -> msg) -> Cmd msg
loadBuilderDb session event =
    getJson (Process.decodeList session.db.impacts) "food/builder_processes.json"
        |> Task.andThen (handleBuilderProcessesLoaded session)
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
