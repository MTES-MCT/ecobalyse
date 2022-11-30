module Data.Food.Builder.Db exposing
    ( Db
    , buildFromJson
    , empty
    , isEmpty
    )

import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact
import Json.Decode as Decode


type alias Db =
    { impacts : List Impact.Definition

    ---- builder Processes are straightforward imports of public/data/food/processes/builder.json
    , processes : List Process

    ---- Ingredients are imported from public/data/food/ingredients.json
    , ingredients : List Ingredient
    }


empty : Db
empty =
    { impacts = []
    , processes = []
    , ingredients = []
    }


isEmpty : Db -> Bool
isEmpty db =
    db == empty


buildFromJson : List Impact.Definition -> String -> String -> Result String Db
buildFromJson impacts builderProcessesJson ingredientsJson =
    builderProcessesJson
        |> Decode.decodeString (Process.decodeList impacts)
        |> Result.andThen
            (\processes ->
                ingredientsJson
                    |> Decode.decodeString (Ingredient.decodeIngredients processes)
                    |> Result.map (Db impacts processes)
            )
        |> Result.mapError Decode.errorToString
