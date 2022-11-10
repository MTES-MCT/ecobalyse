module Data.Food.Ingredient exposing
    ( Ingredient
    , decodeIngredients
    )

import Data.Food.Process exposing (Process)
import Json.Decode as Decode


type alias Ingredient =
    { name : String
    , conventional : Process
    , organic : Maybe Process
    }


decodeIngredients : List Process -> Decode.Decoder (List Ingredient)
decodeIngredients _ =
    -- FIXME: implement the decoder
    Decode.succeed []
