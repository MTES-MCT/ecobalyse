module Data.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)


type alias Db =
    { countries : List Country
    , materials : List Material
    , processes : List Process
    , products : List Product
    , transports : Distances
    }


empty : Db
empty =
    { countries = []
    , materials = []
    , processes = []
    , products = []
    , transports = Transport.emptyDistances
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decode json
        |> Result.mapError Decode.errorToString


decode : Decoder Db
decode =
    Decode.map5 Db
        (Decode.field "countries" Country.decodeList)
        (Decode.field "materials" Material.decodeList)
        (Decode.field "processes" Process.decodeList)
        (Decode.field "products" Product.decodeList)
        (Decode.field "transports" Transport.decodeDistances)
