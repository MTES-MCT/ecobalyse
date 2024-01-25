module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , updateIngredientsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Food.ExampleProduct exposing (ExampleProduct)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode
import Json.Decode.Extra as DE


type alias Db =
    { exampleProducts : List ExampleProduct
    , processes : List Process
    , ingredients : List Ingredient
    , wellKnown : WellKnown
    }


buildFromJson : List ExampleProduct -> String -> String -> Result String Db
buildFromJson exampleProducts foodProcessesJson ingredientsJson =
    foodProcessesJson
        |> Decode.decodeString Process.decodeList
        |> Result.andThen
            (\processes ->
                ingredientsJson
                    |> Decode.decodeString
                        (Ingredient.decodeIngredients processes
                            |> Decode.andThen
                                (\ingredients ->
                                    WellKnown.load processes
                                        |> Result.map (Db exampleProducts processes ingredients)
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
