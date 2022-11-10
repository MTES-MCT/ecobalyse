module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , empty
    , isEmpty
    )

import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Impact as Impact
import Json.Decode as Decode


type alias Db =
    { impacts : List Impact.Definition

    ---- Processes are straightforward imports of public/data/food/processes.json
    , processes : List Process

    ---- Products are imported from public/data/food/products.json with several layers:
    ---- Product
    ----    Step (consumer, packaging, ...)
    ----        Category (material, processing, waste treatment, ...)
    ----            Ingredient (amount, process -- from the processes db --)
    , products : Products

    ---- Ingredients are imported from public/data/food/ingredients.json
    , ingredients : List Ingredient
    }


empty : Db
empty =
    { impacts = []
    , processes = []
    , products = Product.emptyProducts
    , ingredients = []
    }


isEmpty : Db -> Bool
isEmpty db =
    db == empty


buildFromJson : List Impact.Definition -> String -> String -> String -> Result String Db
buildFromJson impacts processesJson productsJson ingredientsJson =
    processesJson
        |> Decode.decodeString (Process.decodeList impacts)
        |> Result.andThen
            (\processes ->
                Decode.decodeString (Product.decodeProducts processes) productsJson
                    |> Result.andThen
                        (\products ->
                            Decode.decodeString (Ingredient.decodeIngredients processes) ingredientsJson
                                |> Result.map
                                    (\ingredients ->
                                        Db impacts processes products ingredients
                                    )
                        )
            )
        |> Result.mapError Decode.errorToString
