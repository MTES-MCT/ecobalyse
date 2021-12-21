module Data.Impact exposing (..)

import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity(..))



-- Impact definitions


type Trigram
    = Trigram String


type alias Definition =
    { trigram : Trigram
    , label : String
    , unit : String
    }


default : Definition
default =
    { trigram = defaultTrigram
    , label = "Changement climatique"
    , unit = "kgCO₂e"
    }


defaultTrigram : Trigram
defaultTrigram =
    trg "cch"


getDefinition : Trigram -> List Definition -> Result String Definition
getDefinition trigram =
    List.filter (.trigram >> (==) trigram)
        >> List.head
        >> Result.fromMaybe ("Impact " ++ toString trigram ++ " invalide")


decodeList : Decoder (List Definition)
decodeList =
    let
        decodeDictValue =
            Decode.map2 (\label unit -> { label = label, unit = unit })
                (Decode.field "label_fr" Decode.string)
                (Decode.field "short_unit" Decode.string)

        toImpact ( key, { label, unit } ) =
            Definition (trg key) label unit
    in
    Decode.dict decodeDictValue
        |> Decode.andThen (Dict.toList >> List.map toImpact >> Decode.succeed)


decodeTrigram : Decoder Trigram
decodeTrigram =
    Decode.map Trigram Decode.string


encodeDefinition : Definition -> Encode.Value
encodeDefinition v =
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



-- Impact data & scores


type alias Impacts =
    AnyDict String Trigram Unit.Impact


noImpacts : Impacts
noImpacts =
    AnyDict.fromList (always "") []


impactsFromDefinitons : List Definition -> Impacts
impactsFromDefinitons =
    List.map (\{ trigram } -> ( trigram, Quantity.zero ))
        >> AnyDict.fromList toString


impactsFromList : List ( Trigram, Unit.Impact ) -> Impacts
impactsFromList =
    AnyDict.fromList toString


getImpact : Trigram -> Impacts -> Unit.Impact
getImpact trigram =
    AnyDict.get trigram
        >> Maybe.withDefault Quantity.zero


updateImpact : Trigram -> Unit.Impact -> Impacts -> Impacts
updateImpact trigram value =
    AnyDict.update trigram (Maybe.map (always value))


decodeImpacts : Decoder Impacts
decodeImpacts =
    AnyDict.decode (\str _ -> trg str) toString Unit.decodeImpact


encodeImpacts : Impacts -> Encode.Value
encodeImpacts =
    AnyDict.encode toString Unit.encodeImpact
