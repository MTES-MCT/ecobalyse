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
    , conventional : Process
    , labels : Labels
    }


type alias Labels =
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
        |> Pipe.required "conventional" (linkProcess processes)
        |> Pipe.required "labels" (decodeLabels processes)


decodeLabels : Dict String Process -> Decoder Labels
decodeLabels processes =
    Decode.succeed Labels
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
