module Request.Food.Db exposing (loadDb)

import Data.Food.Db exposing (Db)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Impact as Impact
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import Request.Common exposing (getJson)
import Task exposing (Task)


handleIngredientsLoaded : List Impact.Definition -> List Process -> Products -> WebData (List Ingredient) -> Task () (WebData Db)
handleIngredientsLoaded impacts processes products ingredientsData =
    case ingredientsData of
        RemoteData.Success ingredients ->
            Task.succeed (RemoteData.succeed (Db impacts processes products ingredients))

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleProductsLoaded : List Impact.Definition -> List Process -> WebData Products -> Task () (WebData Db)
handleProductsLoaded impacts processes productsData =
    case productsData of
        RemoteData.Success products ->
            getJson (Ingredient.decodeIngredients processes) "food/ingredients.json"
                |> Task.andThen (handleIngredientsLoaded impacts processes products)

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleProcessesLoaded : List Impact.Definition -> WebData (List Process) -> Task () (WebData Db)
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
    getJson (Process.decodeList db.impacts) "food/processes.json"
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
