module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , empty
    , isBuilderEmpty
    )

import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Impact as Impact
import Json.Decode as Decode


type alias Db =
    { impacts : List Impact.Definition

    ---- EXPLORER
    ---- Processes are straightforward imports of public/data/food/processes/explorer.json
    , processes : List Process

    ---- Products are imported from public/data/food/products.json with several layers:
    ---- Product
    ----    Step (consumer, packaging, ...)
    ----        Category (material, processing, waste treatment, ...)
    ----            Ingredient (amount, process -- from the processes db --)
    , products : Products

    ---- BUILDER
    ---- builder Processes are straightforward imports of public/data/food/processes/builder.json
    , builderProcesses : List Process

    ---- Ingredients are imported from public/data/food/ingredients.json
    , ingredients : List Ingredient
    }


empty : Db
empty =
    { impacts = []
    , processes = []
    , products = Product.emptyProducts
    , builderProcesses = []
    , ingredients = []
    }


isBuilderEmpty : Db -> Bool
isBuilderEmpty db =
    db.builderProcesses == [] || db.ingredients == []


buildFromJson : List Impact.Definition -> String -> String -> String -> String -> Result String Db
buildFromJson impacts processesJson productsJson builderProcessesJson ingredientsJson =
    processesJson
        |> Decode.decodeString (Process.decodeList impacts)
        |> Result.andThen
            (\processes ->
                Decode.decodeString (Product.decodeProducts processes) productsJson
                    |> Result.andThen
                        (\products ->
                            builderProcessesJson
                                |> Decode.decodeString (Process.decodeList impacts)
                                |> Result.andThen
                                    (\builderProcesses ->
                                        Decode.decodeString (Ingredient.decodeIngredients builderProcesses) ingredientsJson
                                            |> Result.map
                                                (\ingredients ->
                                                    Db impacts processes products builderProcesses ingredients
                                                )
                                    )
                        )
            )
        |> Result.mapError Decode.errorToString
