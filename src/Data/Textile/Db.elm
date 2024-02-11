module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process, WellKnown)
import Data.Textile.Product as Product exposing (Product)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type alias Db =
    { processes : List Process
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : Definitions -> String -> Result String Db
buildFromJson definitions json =
    Decode.decodeString (decode definitions) json
        |> Result.mapError Decode.errorToString


decode : Definitions -> Decoder Db
decode definitions =
    Decode.field "processes" (Process.decodeList definitions)
        |> Decode.andThen
            (\processes ->
                Decode.map2 (Db processes)
                    (Decode.field "materials" (Material.decodeList processes))
                    (Decode.field "products" (Product.decodeList processes))
                    |> Decode.andThen
                        (\partiallyLoaded ->
                            Process.loadWellKnown processes
                                |> Result.map partiallyLoaded
                                |> DE.fromResult
                        )
            )
