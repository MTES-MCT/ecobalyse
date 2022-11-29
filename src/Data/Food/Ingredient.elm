module Data.Food.Ingredient exposing
    ( Id
    , Ingredient
    , decodeIngredients
    , empty
    , encodeId
    , findByID
    , idFromString
    , idToString
    )

import Data.Food.Process as Process exposing (Process)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type alias Ingredient =
    { id : Id
    , name : String
    , default : Process
    , variants : Variants
    }


type Id
    = Id String


decodeId : Decode.Decoder Id
decodeId =
    Decode.string
        |> Decode.map idFromString


encodeId : Id -> Encode.Value
encodeId (Id str) =
    Encode.string str


idFromString : String -> Id
idFromString str =
    Id str


idToString : Id -> String
idToString (Id str) =
    str


empty : Ingredient
empty =
    { id = idFromString ""
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
        |> Pipe.required "id" decodeId
        |> Pipe.required "name" Decode.string
        |> Pipe.required "default" (linkProcess processes)
        |> Pipe.required "variants" (decodeVariants processes)


decodeVariants : Dict String Process -> Decoder Variants
decodeVariants processes =
    Decode.succeed Variants
        |> Pipe.optional "organic" (Decode.maybe (linkProcess processes)) Nothing


findByID : Id -> List Ingredient -> Result String Ingredient
findByID id ingredients =
    ingredients
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Ingrédient introuvable par id : " ++ idToString id)


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
