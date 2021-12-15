module Data.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)


type alias Db =
    { processes : List Process
    , countries : List Country
    , materials : List Material
    , products : List Product
    , transports : Distances
    , impacts : Impacts
    }


empty : Db
empty =
    { processes = []
    , materials = []
    , countries = []
    , products = []
    , transports = Transport.emptyDistances
    , impacts = Impact.emptyImpacts
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decode json
        |> Result.mapError Decode.errorToString


decode : Decoder Db
decode =
    Decode.field "processes" Process.decodeList
        |> Decode.andThen
            (\processes ->
                Decode.map6 Db
                    (Decode.succeed processes)
                    (Decode.field "countries" (Country.decodeList processes))
                    (Decode.field "materials" (Material.decodeList processes))
                    (Decode.field "products" (Product.decodeList processes))
                    (Decode.field "transports" Transport.decodeDistances)
                    (Decode.field "impacts" Impact.decodeImpacts)
            )
