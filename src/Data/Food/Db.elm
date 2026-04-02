module Data.Food.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Query as Query exposing (Query)
import Data.Food.WellKnown as WellKnown exposing (WellKnown)
import Data.Process exposing (Process)
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { examples : List (Example Query)
    , foodOriginDistances : Ingredient.FoodOriginDistances
    , ingredients : List Ingredient
    , wellKnown : WellKnown
    }



-- Note: transportFoodJson is a new parameter for food-specific transport distances.
-- The Db fields are applied positionally in type alias order:
--   examples          ← exampleProductsJson
--   foodOriginDistances ← transportFoodJson
--   ingredients       ← ingredientsJson
--   wellKnown         ← WellKnown.load


buildFromJson : String -> String -> String -> List Process -> Result String Db
buildFromJson exampleProductsJson ingredientsJson transportFoodJson processes =
    Ok Db
        |> RE.andMap
            (exampleProductsJson
                |> Example.decodeListFromJsonString Query.decode
            )
        |> RE.andMap
            (transportFoodJson
                |> Decode.decodeString Ingredient.decodeFoodOriginDistances
                |> Result.mapError Decode.errorToString
            )
        |> RE.andMap
            (ingredientsJson
                |> Decode.decodeString (Ingredient.decodeIngredients processes)
                |> Result.mapError Decode.errorToString
            )
        |> RE.andMap (WellKnown.load processes)
