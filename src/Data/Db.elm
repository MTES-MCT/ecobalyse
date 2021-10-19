module Data.Db exposing (..)

import Data.Country as Country exposing (Country2)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)


type alias Db =
    { countries : List Country2
    , materials : List Material
    , processes : List Process
    , products : List Product
    }


type alias BaseData =
    { countries : List Country2
    , processes : List Process
    , products : List Product
    }


empty : Db
empty =
    buildFromBaseData
        { countries = []
        , processes = []
        , products = []
        }


build : WebData (List Process) -> WebData (List Country2) -> WebData (List Product) -> WebData Db
build =
    RemoteData.map3
        (\processes countries products ->
            buildFromBaseData
                { countries = countries
                , processes = processes
                , products = products
                }
        )


buildFromBaseData : BaseData -> Db
buildFromBaseData { countries, processes, products } =
    { processes = processes
    , countries = countries
    , materials = Material.fromProcesses processes
    , products = products
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decodeBaseData json
        |> Result.mapError Decode.errorToString
        |> Result.map buildFromBaseData


decodeBaseData : Decoder BaseData
decodeBaseData =
    Decode.map3 BaseData
        (Decode.field "countries" Country.decodeList2)
        (Decode.field "processes" Process.decodeList)
        (Decode.field "products" Product.decodeList)
