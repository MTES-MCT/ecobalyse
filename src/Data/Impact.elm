module Data.Impact exposing
    ( Definition
    , Impacts
    , Quality(..)
    , Source
    , Trigram(..)
    , computeAggregatedScore
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
    , isAggregate
    , mapImpacts
    , noImpacts
    , parseTrigram
    , sumImpacts
    , toProtectionAreas
    , toString
    , trg
    , updateAggregatedScores
    , updateImpact
    )

import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Quantity
import Url.Parser as Parser exposing (Parser)


type alias Definition =
    { trigram : Trigram
    , source : Source
    , label : String
    , description : String
    , unit : String
    , decimals : Int
    , quality : Quality
    , pefData : Maybe AggregatedScoreData
    , ecoscoreData : Maybe AggregatedScoreData
    , scopes : List Scope
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


type alias AggregatedScoreData =
    { color : String
    , normalization : Unit.Impact
    , weighting : Unit.Ratio
    }


type alias ProtectionAreas =
    { climate : Unit.Impact -- Climat
    , biodiversity : Unit.Impact -- Biodiversité
    , resources : Unit.Impact -- Ressources
    , health : Unit.Impact -- Santé environnementale
    }


invalid : Definition
invalid =
    { trigram = defaultTrigram
    , source = { label = "N/A", url = "https://example.com/" }
    , label = "Not applicable"
    , description = "Not applicable"
    , unit = "N/A"
    , decimals = 0
    , quality = GoodQuality
    , pefData = Nothing
    , ecoscoreData = Nothing
    , scopes = []
    }


defaultTrigram : Trigram
defaultTrigram =
    trg "pef"


getDefinition : Trigram -> List Definition -> Result String Definition
getDefinition trigram =
    List.filter (.trigram >> (==) trigram)
        >> List.head
        >> Result.fromMaybe ("Impact " ++ toString trigram ++ " invalide")


isAggregate : Definition -> Bool
isAggregate { pefData, ecoscoreData } =
    case ( pefData, ecoscoreData ) of
        ( Nothing, Nothing ) ->
            True

        _ ->
            False


decodeList : Decoder (List Definition)
decodeList =
    let
        decodeDictValue =
            Decode.succeed
                (\source label description unit decimals quality pefData scoreData scopes ->
                    { source = source
                    , label = label
                    , description = description
                    , unit = unit
                    , decimals = decimals
                    , quality = quality
                    , pefData = pefData
                    , scoreData = scoreData
                    , scopes = scopes
                    }
                )
                |> Pipe.required "source" decodeSource
                |> Pipe.required "label_fr" Decode.string
                |> Pipe.required "description_fr" Decode.string
                |> Pipe.required "short_unit" Decode.string
                |> Pipe.required "decimals" Decode.int
                |> Pipe.required "quality" decodeQuality
                |> Pipe.required "pef" (Decode.maybe decodeAggregatedScoreData)
                |> Pipe.required "ecoscore" (Decode.maybe decodeAggregatedScoreData)
                |> Pipe.required "scopes" (Decode.list Scope.decode)

        toImpact ( key, { source, label, description, unit, decimals, quality, pefData, scoreData, scopes } ) =
            Definition (trg key) source label description unit decimals quality pefData scoreData scopes
    in
    Decode.dict decodeDictValue
        |> Decode.andThen (Dict.toList >> List.map toImpact >> Decode.succeed)


decodeSource : Decoder Source
decodeSource =
    Decode.map2 Source
        (Decode.field "label" Decode.string)
        (Decode.field "url" Decode.string)


decodeAggregatedScoreData : Decoder AggregatedScoreData
decodeAggregatedScoreData =
    Decode.map3 AggregatedScoreData
        (Decode.field "color" Decode.string)
        (Decode.field "normalization" Unit.decodeImpact)
        (Decode.field "weighting" Unit.decodeRatio)


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


toProtectionAreas : List Definition -> Impacts -> ProtectionAreas
toProtectionAreas defs impacts =
    let
        pick trigrams =
            impacts
                |> AnyDict.filter (\t _ -> List.member t (List.map trg trigrams))
                |> computeAggregatedScore .ecoscoreData defs
    in
    { climate =
        pick
            [ "cch" -- Climate change
            ]
    , biodiversity =
        pick
            [ "cch" -- Climate change
            , "bvi" -- Biodiversity impact
            , "acd" -- Acidification
            , "fwe" -- Freshwater Eutrophication
            , "tre" -- Terrestrial eutrophication
            , "swe" -- Marine eutrophication
            , "etf" -- Ecotoxicity: freshwater
            , "ozd" -- Ozone depletion
            , "ior" -- Ionising radiation
            , "pco" -- Photochemical ozone formation
            , "wtu" -- Water use
            , "ldu" -- Land use
            ]
    , resources =
        pick
            [ "wtu" -- Water use
            , "ldu" -- Land use
            , "fru" -- Fossile resource use
            , "mru" -- Minerals and metal resource use
            ]
    , health =
        pick
            [ "cch" -- Climate change
            , "ozd" -- Ozone depletion
            , "ior" -- Ionising radiation
            , "pco" -- Photochemical ozone formation
            , "htn" -- Human toxicity: non-carcinogenic
            , "htc" -- Human toxicity: carcinogenic
            , "wtu" -- Water use
            ]
    }



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
    AnyDict.insert trigram value


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


encodeImpacts : List Definition -> Scope -> Impacts -> Encode.Value
encodeImpacts definitions scope =
    AnyDict.filter
        (\trigram _ ->
            definitions
                |> List.filter (.scopes >> List.member scope)
                |> List.map .trigram
                |> List.member trigram
        )
        >> AnyDict.encode toString Unit.encodeImpact


updateAggregatedScores : List Definition -> Impacts -> Impacts
updateAggregatedScores definitions impacts =
    let
        aggregateScore getter trigram =
            updateImpact trigram
                (computeAggregatedScore getter definitions impacts)
    in
    impacts
        |> aggregateScore .ecoscoreData (trg "ecs")
        |> aggregateScore .pefData (trg "pef")


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
                                    |> Unit.impactAggregateScore normalization weighting
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


computeAggregatedScore : (Definition -> Maybe AggregatedScoreData) -> List Definition -> Impacts -> Unit.Impact
computeAggregatedScore getter defs =
    AnyDict.map
        (\trigram impact ->
            case defs |> getDefinition trigram |> Result.map getter of
                Ok (Just { normalization, weighting }) ->
                    impact
                        |> Unit.impactAggregateScore normalization weighting

                _ ->
                    Quantity.zero
        )
        >> AnyDict.foldl (\_ -> Quantity.plus) Quantity.zero



-- Parser


parseTrigram : Parser (Trigram -> a) a
parseTrigram =
    let
        trigrams =
            -- FIXME: find a way to have this check performed automatically from impacts db
            "acd,bvi,cch,ecs,etf,fru,fwe,htc,htn,ior,ldu,mru,ozd,pco,pef,pma,swe,tre,wtu"
                |> String.split ","
    in
    Parser.custom "TRIGRAM" <|
        \trigram ->
            if List.member trigram trigrams then
                Just (trg trigram)

            else
                Just defaultTrigram
