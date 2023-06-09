module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Country as Country exposing (Country)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type alias Db =
    { processes : List Process
    , countries : List Country
    , materials : List Material
    , products : List Product
    , transports : Distances
    , wellKnown : Process.WellKnown
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
                Decode.map4 (Db processes)
                    (Decode.field "countries" (Country.decodeList processes))
                    (Decode.field "materials" (Material.decodeList processes))
                    (Decode.field "products" (Product.decodeList processes))
                    (Decode.field "transports" Transport.decodeDistances)
                    |> Decode.andThen
                        (\partiallyLoaded ->
                            Process.loadWellKnown processes
                                |> Result.map partiallyLoaded
                                |> DE.fromResult
                        )
            )
