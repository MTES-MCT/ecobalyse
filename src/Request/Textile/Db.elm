module Request.Textile.Db exposing (loadDb)

import Data.Country as Country exposing (Country)
import Data.Impact as Impact
import Data.Session exposing (Session)
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
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


buildFromWebData :
    List Impact.Definition
    -> List Process
    -> WebData (List Country)
    -> WebData (List Material)
    -> WebData (List Product)
    -> WebData Distances
    -> WebData Db
buildFromWebData impacts processes countries materials products transports =
    RemoteData.succeed (Db impacts processes)
        |> RemoteData.andMap countries
        |> RemoteData.andMap materials
        |> RemoteData.andMap products
        |> RemoteData.andMap transports


loadDependentData : List Impact.Definition -> List Process -> Task () (WebData Db)
loadDependentData impacts processes =
    let
        -- see https://github.com/alex-tan/task-extra/blob/1.1.0/src/Task/Extra.elm#L579-L581
        andMap =
            Task.map2 (|>)
    in
    Task.succeed (buildFromWebData impacts processes)
        |> andMap (getJson (Country.decodeList processes) "countries.json")
        |> andMap (getJson (Material.decodeList processes) "materials.json")
        |> andMap (getJson (Product.decodeList processes) "products.json")
        |> andMap (getJson Transport.decodeDistances "transports.json")


handleProcessesLoaded : List Impact.Definition -> WebData (List Process) -> Task () (WebData Db)
handleProcessesLoaded impacts processesData =
    case processesData of
        RemoteData.Success processes ->
            loadDependentData impacts processes

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


handleImpactsLoaded : WebData (List Impact.Definition) -> Task () (WebData Db)
handleImpactsLoaded impactsData =
    case impactsData of
        RemoteData.Success impacts ->
            getJson (Process.decodeList impacts) "processes.json"
                |> Task.andThen (handleProcessesLoaded impacts)

        RemoteData.Failure error ->
            Task.succeed (RemoteData.Failure error)

        RemoteData.NotAsked ->
            Task.succeed RemoteData.NotAsked

        RemoteData.Loading ->
            Task.succeed RemoteData.Loading


loadDb : Session -> (WebData Db -> msg) -> Cmd msg
loadDb _ event =
    getJson Impact.decodeList "impacts.json"
        |> Task.andThen handleImpactsLoaded
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
