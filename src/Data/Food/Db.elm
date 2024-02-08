module Data.Food.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Impact.Definition exposing (Definitions)
import Json.Decode as Decode
import Json.Decode.Extra as DE


type alias Db =
    { processes : List Process
    , ingredients : List Ingredient
    , wellKnown : Process.WellKnown
    }


buildFromJson : Definitions -> String -> String -> Result String Db
buildFromJson definitions processesJson ingredientsJson =
    processesJson
        |> Decode.decodeString (Process.decodeList definitions)
        |> Result.andThen
            (\processes ->
                ingredientsJson
                    |> Decode.decodeString
                        (Ingredient.decodeIngredients processes
                            |> Decode.andThen
                                (\ingredients ->
                                    Process.loadWellKnown processes
                                        |> Result.map (Db processes ingredients)
                                        |> DE.fromResult
                                )
                        )
            )
        |> Result.mapError Decode.errorToString
