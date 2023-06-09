module Request.Food.BuilderDb exposing (loadDb)

import Data.Food.Builder.Db exposing (Db)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)
import Request.Common exposing (getJson)
import Task exposing (Task)


handleProcessesLoaded : Session -> WebData (List Process) -> Task () (WebData Db)
handleProcessesLoaded session processesData =
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
            Task.succeed
                (Process.loadWellKnown processes
                    |> Result.map (Db session.db.countries session.db.transports processes ingredients)
                    |> RemoteData.fromResult
                    |> RemoteData.mapError Http.BadBody
                )

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadDb : Session -> (WebData Db -> msg) -> Cmd msg
loadDb session event =
    getJson Process.decodeList "food/processes/builder.json"
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
