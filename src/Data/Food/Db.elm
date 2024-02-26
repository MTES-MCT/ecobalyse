module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , updateIngredientsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.WellKnown as WellKnown exposing (WellKnown)
import Data.Impact.Definition exposing (Definitions)
import Json.Decode as Decode
import Json.Decode.Extra as DE


type alias Db =
    { processes : List Process
    , ingredients : List Ingredient
    , wellKnown : WellKnown
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
                                    WellKnown.load processes
                                        |> Result.map (Db processes ingredients)
                                        |> DE.fromResult
                                )
                        )
            )
        |> Result.mapError Decode.errorToString


updateIngredientsFromNewProcesses : List Process -> List Ingredient -> List Ingredient
updateIngredientsFromNewProcesses processes =
    List.map
        (\ingredient ->
            processes
                |> Process.findByIdentifier (Process.codeFromString ingredient.default.id_)
                |> Result.map (\default -> { ingredient | default = default })
                |> Result.withDefault ingredient
        )


updateWellKnownFromNewProcesses : List Process -> WellKnown -> WellKnown
updateWellKnownFromNewProcesses processes =
    WellKnown.map
        (\({ id_ } as process) ->
            processes
                |> Process.findByIdentifier (Process.codeFromString id_)
                |> Result.withDefault process
        )
