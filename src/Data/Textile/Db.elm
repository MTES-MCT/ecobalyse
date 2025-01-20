module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Process exposing (Process)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as Query exposing (Query)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { examples : List (Example Query)
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> List Process -> Result String Db
buildFromJson exampleProductsJson textileMaterialsJson productsJson processes =
    Ok Db
        |> RE.andMap
            (exampleProductsJson
                |> Example.decodeListFromJsonString Query.decode
            )
        |> RE.andMap
            (textileMaterialsJson
                |> Decode.decodeString (Material.decodeList processes)
                |> Result.mapError Decode.errorToString
            )
        |> RE.andMap
            (productsJson
                |> Decode.decodeString (Product.decodeList processes)
                |> Result.mapError Decode.errorToString
            )
        |> RE.andMap (WellKnown.load processes)
