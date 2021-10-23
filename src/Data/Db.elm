module Data.Db exposing (..)

import Data.Country as Country exposing (Country2)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)


type alias Db =
    { countries : List Country2
    , materials : List Material
    , processes : List Process
    , products : List Product
    , transports : Distances
    }


type alias BaseData =
    { countries : List Country2
    , processes : List Process
    , products : List Product
    , transports : Distances
    }


empty : Db
empty =
    buildFromBaseData
        { countries = []
        , processes = []
        , products = []
        , transports = Transport.emptyDistances
        }


build : WebData (List Process) -> WebData (List Country2) -> WebData (List Product) -> WebData Distances -> WebData Db
build processesData countriesData productsData transportsData =
    countriesData
        |> RemoteData.map BaseData
        |> RemoteData.andMap processesData
        |> RemoteData.andMap productsData
        |> RemoteData.andMap transportsData
        |> RemoteData.map buildFromBaseData


buildFromBaseData : BaseData -> Db
buildFromBaseData { countries, processes, products, transports } =
    { processes = processes
    , countries = countries
    , materials = Material.fromProcesses processes
    , products = products
    , transports = transports
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decodeBaseData json
        |> Result.mapError Decode.errorToString
        |> Result.map buildFromBaseData


decodeBaseData : Decoder BaseData
decodeBaseData =
    Decode.map4 BaseData
        (Decode.field "countries" Country.decodeList2)
        (Decode.field "processes" Process.decodeList)
        (Decode.field "products" Product.decodeList)
        (Decode.field "transports" Transport.decodeDistances)
