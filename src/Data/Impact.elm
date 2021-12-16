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
    { trigram = Trigram "cch"
    , label = "Changement climatique"
    , unit = "kg éq. CO2"
    }


defaultTrigram : Trigram
defaultTrigram =
    trigramFromString "cch"


get : Trigram -> List Impact -> Result String Impact
get trigram =
    List.filter (.trigram >> (==) trigram)
        >> List.head
        >> Result.fromMaybe ("Impact " ++ trigramToString trigram ++ " invalide")


decodeList : Decoder (List Impact)
decodeList =
    let
        decodeDictValue =
            Decode.map2 (\label unit -> { label = label, unit = unit })
                (Decode.field "label_fr" Decode.string)
                (Decode.field "unit_fr" Decode.string)

        toImpact ( key, { label, unit } ) =
            Impact (trigramFromString key) label unit
    in
    Decode.dict decodeDictValue
        |> Decode.andThen (Dict.toList >> List.map toImpact >> Decode.succeed)


encodeImpact : Impact -> Encode.Value
encodeImpact v =
    Encode.object
        [ ( "trigram", encodeTrigram v.trigram )
        , ( "label", Encode.string v.label )
        , ( "unit", Encode.string v.unit )
        ]


encodeTrigram : Trigram -> Encode.Value
encodeTrigram =
    trigramToString >> Encode.string


trigramToString : Trigram -> String
trigramToString (Trigram string) =
    string


trigramFromString : String -> Trigram
trigramFromString =
    Trigram
