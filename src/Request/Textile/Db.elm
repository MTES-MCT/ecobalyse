module Request.Textile.Db exposing (loadDb)

import Data.Country as Country exposing (Country)
import Data.Food.Process as FoodProcess
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Http
import RemoteData exposing (WebData)
import Request.Common exposing (getJson)
import Task exposing (Task)


buildFromWebData :
    Definitions
    -> List Process
    -> WebData (List Country)
    -> WebData (List Material)
    -> WebData (List Product)
    -> WebData Distances
    -> WebData (List FoodProcess.Process)
    -> WebData TextileDb.Db
buildFromWebData definitions processes countries materials products transports foodProcesses =
    RemoteData.succeed (TextileDb.Db definitions processes)
        |> RemoteData.andMap countries
        |> RemoteData.andMap materials
        |> RemoteData.andMap products
        |> RemoteData.andMap transports
        |> RemoteData.andMap foodProcesses
        |> RemoteData.andThen
            (\partiallyLoaded ->
                Process.loadWellKnown processes
                    |> Result.map partiallyLoaded
                    |> RemoteData.fromResult
                    |> RemoteData.mapError Http.BadBody
            )


loadDependentData : Definitions -> List Process -> Task () (WebData TextileDb.Db)
loadDependentData definitions processes =
    let
        -- see https://github.com/alex-tan/task-extra/blob/1.1.0/src/Task/Extra.elm#L579-L581
        andMap =
            Task.map2 (|>)
    in
    Task.succeed (buildFromWebData definitions processes)
        |> andMap (getJson (Country.decodeList processes) "countries.json")
        |> andMap (getJson (Material.decodeList processes) "textile/materials.json")
        |> andMap (getJson (Product.decodeList processes) "textile/products.json")
        |> andMap (getJson Transport.decodeDistances "transports.json")
        |> andMap (getJson (FoodProcess.decodeList definitions) "food/processes.json")


handleProcessesLoaded : Definitions -> WebData (List Process) -> Task () (WebData TextileDb.Db)
handleProcessesLoaded definitions processesData =
    case processesData of
        RemoteData.Success processes ->
            loadDependentData definitions processes

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleImpactsLoaded : WebData Definitions -> Task () (WebData TextileDb.Db)
handleImpactsLoaded definitionsData =
    case definitionsData of
        RemoteData.Success definitions ->
            getJson (Process.decodeList definitions) "textile/processes.json"
                |> Task.andThen (handleProcessesLoaded definitions)

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadDb : (WebData TextileDb.Db -> msg) -> Cmd msg
loadDb event =
    getJson Definition.decode "impacts.json"
        |> Task.andThen handleImpactsLoaded
        |> Task.attempt
            (\result ->
                case result of
                    Ok wd ->
                        event wd

                    Err _ ->
                        -- Note: this `Task () (WebData TextileDb.Db)` error situation can never happen
                        -- This is a limitation from the types returned by RemoteData.Http tasks
                        event RemoteData.NotAsked
            )
