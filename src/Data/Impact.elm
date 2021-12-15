module Data.Impact exposing (..)

import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)


type Trigram
    = Trigram String


type Unit
    = Unit Float Trigram


type alias Impacts =
    AnyDict String Trigram Info


type alias Info =
    { label : String
    , unit : String
    }


emptyImpacts : Impacts
emptyImpacts =
    AnyDict.fromList trigramToString []


decodeImpacts : Decoder Impacts
decodeImpacts =
    AnyDict.decode (\str _ -> trigramFromString str)
        trigramToString
        decodeInfo


decodeInfo : Decoder Info
decodeInfo =
    Decode.map2 Info
        (Decode.field "label_fr" Decode.string)
        (Decode.field "unit_fr" Decode.string)


trigramToString : Trigram -> String
trigramToString (Trigram string) =
    string


trigramFromString : String -> Trigram
trigramFromString =
    Trigram
