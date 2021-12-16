module Data.Impact exposing (..)

import Dict
import Json.Decode as Decode exposing (Decoder)


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
            Decode.map2 (\a b -> { label = a, unit = b })
                (Decode.field "label_fr" Decode.string)
                (Decode.field "unit_fr" Decode.string)
    in
    Decode.dict decodeDictValue
        |> Decode.andThen
            (Dict.toList
                >> List.map
                    (\( trigram, { label, unit } ) ->
                        Impact (Trigram trigram) label unit
                    )
                >> Decode.succeed
            )


trigramToString : Trigram -> String
trigramToString (Trigram string) =
    string


trigramFromString : String -> Trigram
trigramFromString =
    Trigram
