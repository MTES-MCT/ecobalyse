module Data.Food.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Query as Query exposing (Query)
import Data.Food.WellKnown as WellKnown exposing (WellKnown)
import Data.Impact as Impact
import Data.Process as Process exposing (Process)
import Data.Scope as Scope
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { examples : List (Example Query)
    , ingredients : List Ingredient
    , processes : List Process
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> Result String Db
buildFromJson exampleProductsJson foodProcessesJson ingredientsJson =
    foodProcessesJson
        |> Decode.decodeString (Process.decodeList [ Scope.Food ] Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
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
                    |> RE.andMap (Ok processes)
                    |> RE.andMap (WellKnown.load processes)
            )
