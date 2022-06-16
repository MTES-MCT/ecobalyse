module Data.Impact exposing
    ( Definition
    , Impacts
    , Quality(..)
    , Source
    , Target(..)
    , Trigram(..)
    , computePefScore
    , decodeImpacts
    , decodeList
    , defaultTrigram
    , encodeImpacts
    , filterImpacts
    , getDefinition
    , getImpact
    , getPefPieData
    , grabImpactFloat
    , impactsFromDefinitons
    , invalid
    , mapImpacts
    , noImpacts
    , parseTrigram
    , sumImpacts
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
import Quantity
import Url.Parser as Parser exposing (Parser)


type alias Definition =
    { trigram : Trigram
    , source : Source
    , label : String
    , description : String
    , unit : String
    , quality : Quality
    , primary : Bool
    , pefData : Maybe PefData
    , scope : Scope
    }


type Trigram
    = Trigram String


type alias Source =
    { label : String, url : String }


type Quality
    = NotFinished
    | GoodQuality
    | AverageQuality
    | BadQuality
    | UnknownQuality


type alias PefData =
    { color : String
    , normalization : Unit.Impact
    , weighting : Unit.Ratio
    }


type alias Scope =
    List Target


type Target
    = Textile
    | Food


invalid : Definition
invalid =
    { trigram = defaultTrigram
    , source = { label = "N/A", url = "https://example.com/" }
    , label = "Not applicable"
    , description = "Not applicable"
    , unit = "N/A"
    , quality = GoodQuality
    , primary = False
    , pefData = Nothing
    , scope = []
    }


defaultTrigram : Trigram
defaultTrigram =
    trg "pef"


getDefinition : Trigram -> List Definition -> Result String Definition
getDefinition trigram =
    List.filter (.trigram >> (==) trigram)
        >> List.head
        >> Result.fromMaybe ("Impact " ++ toString trigram ++ " invalide")


decodeList : Decoder (List Definition)
decodeList =
    let
        decodeDictValue =
            Decode.map8
                (\source label description unit quality primary pefData scope ->
                    { source = source
                    , label = label
                    , description = description
                    , unit = unit
                    , quality = quality
                    , primary = primary
                    , pefData = pefData
                    , scope = scope
                    }
                )
                (Decode.field "source" decodeSource)
                (Decode.field "label_fr" Decode.string)
                (Decode.field "description_fr" Decode.string)
                (Decode.field "short_unit" Decode.string)
                (Decode.field "quality" decodeQuality)
                (Decode.field "primary" Decode.bool)
                (Decode.field "pef" (Decode.maybe decodePefData))
                (Decode.field "scope" decodeScope)

        toImpact ( key, { source, label, description, unit, quality, primary, pefData, scope } ) =
            Definition (trg key) source label description unit quality primary pefData scope
    in
    Decode.dict decodeDictValue
        |> Decode.andThen (Dict.toList >> List.map toImpact >> Decode.succeed)


decodeSource : Decoder Source
decodeSource =
    Decode.map2 Source
        (Decode.field "label" Decode.string)
        (Decode.field "url" Decode.string)


decodePefData : Decoder PefData
decodePefData =
    Decode.map3 PefData
        (Decode.field "color" Decode.string)
        (Decode.field "normalization" Unit.decodeImpact)
        (Decode.field "weighting" (Decode.map getPefWeighting Unit.decodeRatio))


decodeScope : Decoder Scope
decodeScope =
    Decode.list targetDecoder


targetDecoder : Decoder Target
targetDecoder =
    Decode.string
        |> Decode.andThen
            (\target ->
                case target of
                    "textile" ->
                        Decode.succeed Textile

                    "food" ->
                        Decode.succeed Food

                    _ ->
                        Decode.fail <| "Couldn't decode unknown target " ++ target
            )


getPefWeighting : Unit.Ratio -> Unit.Ratio
getPefWeighting weighting =
    -- The following is only relevant for the textile:
    --
    -- Pef score weighting is provided using percentages for each impact, though
    -- we don't have data to take them all into account, so the actual weighting
    -- total we're basing on is 94,11%, not 100%.
    --
    -- The PEF impacts not currently taken into account for the textile are:
    -- - Toxicité humaine (cancer): 2,13 %
    -- - Toxicité humaine (non cancer): 1,84 %
    -- - Ecotoxicité eaux douces: 1,92 %
    --
    -- If we want to have results normalized to 100%, we can uncomment this line:
    --
    -- Unit.Ratio (weighting / 0.9411)
    --
    -- Otherwise, PEF scores are documented incomplete.
    weighting


decodeQuality : Decoder Quality
decodeQuality =
    Decode.maybe Decode.int
        |> Decode.andThen
            (\maybeInt ->
                case maybeInt of
                    Just 0 ->
                        Decode.succeed NotFinished

                    Just 1 ->
                        Decode.succeed GoodQuality

                    Just 2 ->
                        Decode.succeed AverageQuality

                    Just 3 ->
                        Decode.succeed BadQuality

                    _ ->
                        Decode.succeed UnknownQuality
            )


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


sumImpacts : List Definition -> List Impacts -> Impacts
sumImpacts defs =
    List.foldl
        (\impacts ->
            mapImpacts
                (\trigram impact ->
                    Quantity.sum [ getImpact trigram impacts, impact ]
                )
        )
        (impactsFromDefinitons defs)


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


getPefPieData : List Definition -> Impacts -> String
getPefPieData defs =
    let
        encode entry =
            Encode.object
                [ ( "name", Encode.string entry.name )
                , ( "y", Encode.float entry.value )
                , ( "color", Encode.string entry.color )
                ]
    in
    AnyDict.foldl
        (\trigram impact acc ->
            case getDefinition trigram defs of
                Ok { label, pefData } ->
                    case pefData of
                        Just { normalization, weighting, color } ->
                            { name = label
                            , value =
                                impact
                                    |> Unit.impactPefScore normalization weighting
                                    |> Unit.impactToFloat
                            , color = color ++ "bb" -- pastelization through slight transparency
                            }
                                :: acc

                        Nothing ->
                            acc

                Err _ ->
                    acc
        )
        []
        >> List.sortBy .value
        >> List.reverse
        >> Encode.list encode
        >> Encode.encode 0


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
