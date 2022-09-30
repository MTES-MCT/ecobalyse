module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , empty
    )

import Data.Food.Product as Product exposing (Processes, Products)
import Data.Impact as Impact
import Json.Decode as Decode


type alias Db =
    { impacts : List Impact.Definition

    ---- Processes are straightforward imports of public/data/food/processes.json
    , processes : Processes

    ---- Products are imported from public/data/food/products.json with several layers:
    ---- Product
    ----    Step (consumer, packaging, ...)
    ----        Category (material, processing, waste treatment, ...)
    ----            Ingredient (amount, process -- from the processes db --)
    , products : Products
    }


empty : Db
empty =
    { impacts = []
    , processes = Product.emptyProcesses
    , products = Product.emptyProducts
    }


buildFromJson : List Impact.Definition -> String -> String -> Result String Db
buildFromJson impacts processesJson productsJson =
    Decode.decodeString (Product.decodeProcesses impacts) processesJson
        |> Result.andThen
            (\processes ->
                Decode.decodeString (Product.decodeProducts processes) productsJson
                    |> Result.map
                        (\products ->
                            Db impacts processes products
                        )
            )
        |> Result.mapError Decode.errorToString
