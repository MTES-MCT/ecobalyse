module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as TextileProcess
import Data.Textile.Product as Product exposing (Product)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type alias Db =
    { processes : List TextileProcess.Process
    , materials : List Material
    , products : List Product
    , wellKnown : TextileProcess.WellKnown
    }


buildFromJson : Definitions -> String -> Result String Db
buildFromJson definitions json =
    Decode.decodeString (decode definitions) json
        |> Result.mapError Decode.errorToString


decode : Definitions -> Decoder Db
decode definitions =
    Decode.field "processes" (TextileProcess.decodeList definitions)
        |> Decode.andThen
            (\processes ->
                Decode.map2 (Db processes)
                    (Decode.field "materials" (Material.decodeList processes))
                    (Decode.field "products" (Product.decodeList processes))
                    |> Decode.andThen
                        (\partiallyLoaded ->
                            TextileProcess.loadWellKnown processes
                                |> Result.map partiallyLoaded
                                |> DE.fromResult
                        )
            )
