module Data.Food.Ingredient exposing
    ( Ingredient
    , decodeIngredients
    )

import Data.Food.Process as Process exposing (Process)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe


type alias Ingredient =
    { name : String
    , default : Process
    , variants : Variants
    }


type alias Variants =
    { organic : Maybe Process
    }


decodeIngredients : List Process -> Decoder (List Ingredient)
decodeIngredients processes =
    let
        processesDict =
            processes
                |> List.map (\process -> ( Process.codeToString process.code, process ))
                |> Dict.fromList
    in
    Decode.list (decodeIngredient processesDict)


decodeIngredient : Dict String Process -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "name" Decode.string
        |> Pipe.required "default" (linkProcess processes)
        |> Pipe.required "variants" (decodeVariants processes)


decodeVariants : Dict String Process -> Decoder Variants
decodeVariants processes =
    Decode.succeed Variants
        |> Pipe.optional "organic" (Decode.maybe (linkProcess processes)) Nothing


linkProcess : Dict String Process -> Decoder Process
linkProcess processes =
    Decode.string
        |> Decode.andThen
            ((\processCode ->
                Dict.get processCode processes
                    |> Result.fromMaybe ("Procédé introuvable par code : " ++ processCode)
             )
                >> DE.fromResult
            )
