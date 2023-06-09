module Request.Textile.Db exposing (loadDb)

import Data.Country as Country exposing (Country)
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Http
import RemoteData exposing (WebData)
import Request.Common exposing (getJson)
import Task exposing (Task)


buildFromWebData :
    List Process
    -> WebData (List Country)
    -> WebData (List Material)
    -> WebData (List Product)
    -> WebData Distances
    -> WebData Db
buildFromWebData processes countries materials products transports =
    RemoteData.succeed (Db processes)
        |> RemoteData.andMap countries
        |> RemoteData.andMap materials
        |> RemoteData.andMap products
        |> RemoteData.andMap transports
        |> RemoteData.andThen
            (\partiallyLoaded ->
                Process.loadWellKnown processes
                    |> Result.map partiallyLoaded
                    |> RemoteData.fromResult
                    |> RemoteData.mapError Http.BadBody
            )


loadDependentData : List Process -> Task () (WebData Db)
loadDependentData processes =
    let
        -- see https://github.com/alex-tan/task-extra/blob/1.1.0/src/Task/Extra.elm#L579-L581
        andMap =
            Task.map2 (|>)
    in
    Task.succeed (buildFromWebData processes)
        |> andMap (getJson (Country.decodeList processes) "countries.json")
        |> andMap (getJson (Material.decodeList processes) "materials.json")
        |> andMap (getJson (Product.decodeList processes) "products.json")
        |> andMap (getJson Transport.decodeDistances "transports.json")


handleProcessesLoaded : WebData (List Process) -> Task () (WebData Db)
handleProcessesLoaded processesData =
    case processesData of
        RemoteData.Success processes ->
            loadDependentData processes

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadDb : (WebData Db -> msg) -> Cmd msg
loadDb event =
    getJson Process.decodeList "processes.json"
        |> Task.andThen handleProcessesLoaded
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
