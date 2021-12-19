module Data.Impact exposing (..)

import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity(..))


type Trigram
    = Trigram String


type alias Impact =
    { trigram : Trigram
    , label : String
    , unit : String
    }


default : Impact
default =
    { trigram = defaultTrigram
    , label = "Changement climatique"
    , unit = "kgCO₂e"
    }


defaultTrigram : Trigram
defaultTrigram =
    trg "cch"


get : Trigram -> List Impact -> Result String Impact
get trigram =
    List.filter (.trigram >> (==) trigram)
        >> List.head
        >> Result.fromMaybe ("Impact " ++ toString trigram ++ " invalide")


decodeList : Decoder (List Impact)
decodeList =
    let
        decodeDictValue =
            Decode.map2 (\label unit -> { label = label, unit = unit })
                (Decode.field "label_fr" Decode.string)
                (Decode.field "short_unit" Decode.string)

        toImpact ( key, { label, unit } ) =
            Impact (trg key) label unit
    in
    Decode.dict decodeDictValue
        |> Decode.andThen (Dict.toList >> List.map toImpact >> Decode.succeed)


decodeTrigram : Decoder Trigram
decodeTrigram =
    Decode.map Trigram Decode.string


encodeImpact : Impact -> Encode.Value
encodeImpact v =
    Encode.object
        [ ( "trigram", encodeTrigram v.trigram )
        , ( "label", Encode.string v.label )
        , ( "unit", Encode.string v.unit )
        ]


encodeTrigram : Trigram -> Encode.Value
encodeTrigram =
    toString >> Encode.string


toString : Trigram -> String
toString (Trigram string) =
    string


trg : String -> Trigram
trg =
    Trigram
