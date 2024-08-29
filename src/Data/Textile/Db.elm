module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Impact as Impact
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as Query exposing (Query)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode


type alias Db =
    { processes : List Process
    , examples : List (Example Query)
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> String -> Result String Db
buildFromJson exampleProductsJson materialsJson productsJson processesJson =
    processesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Result.map4 (Db processes)
                    (exampleProductsJson |> Example.decodeListFromJsonString Query.decode)
                    (Decode.decodeString (Material.decodeList processes) materialsJson |> Result.mapError Decode.errorToString)
                    (Decode.decodeString (Product.decodeList processes) productsJson |> Result.mapError Decode.errorToString)
                    (WellKnown.load processes)
            )
