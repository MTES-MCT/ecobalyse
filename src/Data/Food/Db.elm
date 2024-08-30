module Data.Food.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Query as Query exposing (Query)
import Data.Food.WellKnown as WellKnown exposing (WellKnown)
import Data.Impact as Impact
import Json.Decode as Decode


type alias Db =
    { processes : List Process
    , examples : List (Example Query)
    , ingredients : List Ingredient
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> Result String Db
buildFromJson exampleProductsJson foodProcessesJson ingredientsJson =
    foodProcessesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Result.map3 (Db processes)
                    (exampleProductsJson |> Example.decodeListFromJsonString Query.decode)
                    (ingredientsJson |> Decode.decodeString (Ingredient.decodeIngredients processes) |> Result.mapError Decode.errorToString)
                    (WellKnown.load processes)
            )
