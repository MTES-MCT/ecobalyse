module Data.Impact exposing (..)

import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Trigram
    = Trigram String


type alias Impact =
    { trigram : Trigram
    , label : String
    , unit : String
    }


type Unit
    = Unit Float Trigram


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
        [ ( "trigram", v.trigram |> trigramToString |> Encode.string )
        , ( "label", Encode.string v.label )
        , ( "unit", Encode.string v.unit )
        ]


trigramToString : Trigram -> String
trigramToString (Trigram string) =
    string


trigramFromString : String -> Trigram
trigramFromString =
    Trigram
