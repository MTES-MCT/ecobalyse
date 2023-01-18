module Data.Food.Ingredient exposing
    ( Id
    , Ingredient
    , decodeId
    , decodeIngredients
    , encodeId
    , findByID
    , getDefaultOriginTransport
    , idFromString
    , idToString
    )

import Data.Food.Origin as Origin exposing (Origin)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact
import Data.Transport as Transport exposing (Transport)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Length


type alias Ingredient =
    { id : Id
    , name : String
    , default : Process
    , defaultOrigin : Origin
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
        |> Pipe.required "default_origin" Origin.decode
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


getDefaultOriginTransport : List Impact.Definition -> Origin -> Transport
getDefaultOriginTransport defs origin =
    let
        default =
            Transport.default (Impact.impactsFromDefinitons defs)
    in
    case origin of
        Origin.France ->
            default

        Origin.EuropeAndMaghreb ->
            { default | road = Length.kilometers 2500 }

        Origin.OutOfEuropeAndMaghreb ->
            { default | road = Length.kilometers 2500, sea = Length.kilometers 18000 }


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
