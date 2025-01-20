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
    , ingredients : List Ingredient
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> List Process -> Result String Db
buildFromJson exampleProductsJson ingredientsJson processes =
    Ok Db
        |> RE.andMap
            (exampleProductsJson
                |> Example.decodeListFromJsonString Query.decode
            )
        |> RE.andMap
            (ingredientsJson
                |> Decode.decodeString (Ingredient.decodeIngredients processes)
                |> Result.mapError Decode.errorToString
            )
        |> RE.andMap (WellKnown.load processes)
