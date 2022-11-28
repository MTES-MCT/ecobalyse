module Data.Food.Ingredient exposing
    ( Ingredient
    , decodeIngredients
    , empty
    , findByID
    )

import Data.Food.IngredientID as IngredientID exposing (ID)
import Data.Food.Process as Process exposing (Process)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe


type alias Ingredient =
    { id : ID
    , name : String
    , default : Process
    , variants : Variants
    }


empty : Ingredient
empty =
    { id = IngredientID.fromString ""
    , name = ""
    , default = Process.empty
    , variants = { organic = Nothing }
    }


type alias Variants =
    { organic : Maybe Process
    }


decodeIngredients : List Process -> Decoder (List Ingredient)
decodeIngredients processes =
    processes
        |> List.map (\process -> ( Process.codeToString process.code, process ))
        |> Dict.fromList
        |> decodeIngredient
        |> Decode.list


decodeIngredient : Dict String Process -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "id" IngredientID.decode
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
            (DE.fromResult
                << (\processCode ->
                        Dict.get processCode processes
                            |> Result.fromMaybe ("Procédé introuvable par code : " ++ processCode)
                   )
            )


findByID : List Ingredient -> ID -> Result String Ingredient
findByID ingredients id =
    ingredients
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Ingrédient introuvable par nom : " ++ IngredientID.toString id)
