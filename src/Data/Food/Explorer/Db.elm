module Data.Food.Explorer.Db exposing
    ( Db
    , buildFromJson
    , empty
    , isEmpty
    )

import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Impact as Impact
import Json.Decode as Decode


type alias Db =
    { impacts : List Impact.Definition

    ---- Processes are straightforward imports of public/data/food/processes/explorer.json
    , processes : List Process

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
    , processes = []
    , products = Product.emptyProducts
    }


isEmpty : Db -> Bool
isEmpty db =
    db == empty


buildFromJson : List Impact.Definition -> String -> String -> Result String Db
buildFromJson impacts processesJson productsJson =
    processesJson
        |> Decode.decodeString (Process.decodeList impacts)
        |> Result.andThen
            (\processes ->
                Decode.decodeString (Product.decodeProducts processes) productsJson
                    |> Result.map
                        (\products ->
                            Db impacts processes products
                        )
            )
        |> Result.mapError Decode.errorToString
