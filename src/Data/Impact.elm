module Data.Impact exposing
    ( Definition
    , Impacts
    , Quality(..)
    , Trigram(..)
    , computePefScore
    , decodeImpacts
    , decodeList
    , default
    , defaultTrigram
    , encodeDefinition
    , encodeImpacts
    , filterImpacts
    , getDefinition
    , getImpact
    , grabImpactFloat
    , impactsFromDefinitons
    , mapImpacts
    , noImpacts
    , parseTrigram
    , toString
    , trg
    , updateImpact
    , updatePefImpact
    )

import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity(..))
import Url.Parser as Parser exposing (Parser)


type alias Definition =
    { trigram : Trigram
    , label : String
    , description : String
    , unit : String
    , quality : Quality
    , pefData : Maybe PefData
    }


type Trigram
    = Trigram String


type Quality
    = GoodQuality
    | AverageQuality
    | BadQuality
    | UnknownQuality


type alias PefData =
    { normalization : Unit.Impact
    , weighting : Unit.Ratio
    }


default : Definition
default =
    { trigram = defaultTrigram
    , label = "Changement climatique"
    , description = "Changement climatique"
    , unit = "kgCO₂e"
    , quality = GoodQuality
    , pefData = Nothing
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
            Decode.map5
                (\label description unit quality pefData ->
                    { label = label
                    , description = description
                    , unit = unit
                    , quality = quality
                    , pefData = pefData
                    }
                )
                (Decode.field "label_fr" Decode.string)
                (Decode.field "description_fr" Decode.string)
                (Decode.field "short_unit" Decode.string)
                (Decode.field "quality" decodeQuality)
                (Decode.field "pef" (Decode.maybe decodePefData))

        toImpact ( key, { label, description, unit, quality, pefData } ) =
            Definition (trg key) label description unit quality pefData
    in
    Decode.dict decodeDictValue
        |> Decode.andThen (Dict.toList >> List.map toImpact >> Decode.succeed)


decodePefData : Decoder PefData
decodePefData =
    Decode.map2 PefData
        (Decode.field "normalization" Unit.decodeImpact)
        (Decode.field "weighting" (Decode.map getPefWeighting Unit.decodeRatio))


getPefWeighting : Unit.Ratio -> Unit.Ratio
getPefWeighting weighting =
    -- Pef score weighting is provided using percentages for each impact, though
    -- we don't have data to take them all into account, so the actual weighting
    -- total we're basing on is 85.6%, not 100%.
    --
    -- The PEF impacts not currently taken into account are:
    -- - Toxicité humaine (cancer): 2,13 %
    -- - Toxicité humaine (non cancer): 1,84 %
    -- - Ecotoxicité eaux douces: 1,92 %
    -- - Epuisement des ressources en eau: 8,51 %
    --
    -- If we want to have results normalized to 100%, we can uncomment this line:
    --
    -- Unit.Ratio (weighting / 0.856)
    --
    -- Otherwise, PEF scores are documented incomplete.
    weighting


decodeQuality : Decoder Quality
decodeQuality =
    Decode.maybe Decode.int
        |> Decode.andThen
            (\maybeInt ->
                case maybeInt of
                    Just 1 ->
                        Decode.succeed GoodQuality

                    Just 2 ->
                        Decode.succeed AverageQuality

                    Just 3 ->
                        Decode.succeed BadQuality

                    _ ->
                        Decode.succeed UnknownQuality
            )


encodePefData : PefData -> Encode.Value
encodePefData v =
    Encode.object
        [ ( "normalization", Unit.encodeImpact v.normalization )
        , ( "weighting", Unit.encodeRatio v.weighting )
        ]


encodeTrigram : Trigram -> Encode.Value
encodeTrigram =
    toString >> Encode.string


encodeDefinition : Definition -> Encode.Value
encodeDefinition v =
    Encode.object
        [ ( "trigram", encodeTrigram v.trigram )
        , ( "label", Encode.string v.label )
        , ( "unit", Encode.string v.unit )
        , ( "quality", encodeQuality v.quality )
        , ( "pef", v.pefData |> Maybe.map encodePefData |> Maybe.withDefault Encode.null )
        ]


encodeQuality : Quality -> Encode.Value
encodeQuality v =
    case v of
        GoodQuality ->
            Encode.int 1

        AverageQuality ->
            Encode.int 2

        BadQuality ->
            Encode.int 3

        UnknownQuality ->
            Encode.null


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


getImpact : Trigram -> Impacts -> Unit.Impact
getImpact trigram =
    AnyDict.get trigram
        >> Maybe.withDefault Quantity.zero


grabImpactFloat : Unit.Functional -> Duration -> Trigram -> { a | impacts : Impacts } -> Float
grabImpactFloat funit daysOfWear trigram { impacts } =
    impacts
        |> getImpact trigram
        |> Unit.inFunctionalUnit funit daysOfWear
        |> Unit.impactToFloat


filterImpacts : (Trigram -> Unit.Impact -> Bool) -> Impacts -> Impacts
filterImpacts fn =
    AnyDict.filter fn


mapImpacts : (Trigram -> Unit.Impact -> Unit.Impact) -> Impacts -> Impacts
mapImpacts fn =
    AnyDict.map fn


updateImpact : Trigram -> Unit.Impact -> Impacts -> Impacts
updateImpact trigram value =
    AnyDict.update trigram (Maybe.map (always value))


decodeImpacts : List Definition -> Decoder Impacts
decodeImpacts definitions =
    AnyDict.decode_
        (\str _ ->
            if definitions |> List.map .trigram |> List.member (trg str) then
                Ok (trg str)

            else
                Err <| "Trigramme d'impact inconnu: " ++ str
        )
        toString
        Unit.decodeImpact


encodeImpacts : Impacts -> Encode.Value
encodeImpacts =
    AnyDict.encode toString Unit.encodeImpact


updatePefImpact : List Definition -> Impacts -> Impacts
updatePefImpact definitions impacts =
    impacts
        |> updateImpact (trg "pef")
            (computePefScore definitions impacts)


computePefScore : List Definition -> Impacts -> Unit.Impact
computePefScore defs =
    AnyDict.map
        (\trigram impact ->
            case getDefinition trigram defs of
                Ok { pefData } ->
                    case pefData of
                        Just { normalization, weighting } ->
                            impact
                                |> Unit.impactPefScore normalization weighting

                        Nothing ->
                            Quantity.zero

                Err _ ->
                    Quantity.zero
        )
        >> AnyDict.foldl (\_ -> Quantity.plus) Quantity.zero



-- Parser


parseTrigram : Parser (Trigram -> a) a
parseTrigram =
    let
        trigrams =
            -- FIXME: find a way to have this check performed automatically from impacts db
            "acd,ozd,cch,ccb,ccf,ccl,fwe,swe,tre,pco,pma,ior,fru,mru,ldu,pef,wtu"
                |> String.split ","
    in
    Parser.custom "TRIGRAM" <|
        \trigram ->
            if List.member trigram trigrams then
                Just (trg trigram)

            else
                Just defaultTrigram
