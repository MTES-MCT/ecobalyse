module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , updateIngredientsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Food.ExampleProduct as FoodExampleProduct exposing (ExampleProduct)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode


type alias Db =
    { processes : List Process
    , exampleProducts : List ExampleProduct
    , ingredients : List Ingredient
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> Result String Db
buildFromJson exampleProductsJson foodProcessesJson ingredientsJson =
    foodProcessesJson
        |> Decode.decodeString Process.decodeList
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Result.map3 (Db processes)
                    (exampleProductsJson |> FoodExampleProduct.decodeListFromJsonString)
                    (ingredientsJson |> Decode.decodeString (Ingredient.decodeIngredients processes) |> Result.mapError Decode.errorToString)
                    (WellKnown.load processes)
            )


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
