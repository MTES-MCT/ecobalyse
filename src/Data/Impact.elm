module Data.Impact exposing
    ( BonusImpacts
    , Definition
    , Impacts
    , Quality(..)
    , Source
    , Trigram(..)
    , addBonusImpacts
    , bonusesImpactAsChartEntries
    , computeAggregatedScore
    , decodeImpacts
    , decodeList
    , defaultFoodTrigram
    , defaultTextileTrigram
    , encodeAggregatedScoreChartEntry
    , encodeBonusesImpacts
    , encodeImpacts
    , filterImpacts
    , getAggregatedScoreData
    , getAggregatedScoreLetter
    , getAggregatedScoreOutOf100
    , getBoundedScoreOutOf100
    , getDefinition
    , getImpact
    , grabImpactFloat
    , impactsFromDefinitons
    , invalid
    , isAggregate
    , mapImpacts
    , noBonusImpacts
    , noImpacts
    , parseTrigram
    , perKg
    , sumImpacts
    , toProtectionAreas
    , toString
    , totalBonusesImpactAsChartEntry
    , trg
    , updateAggregatedScores
    , updateImpact
    )

import Data.Food.Category as Category
import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
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


type alias BonusImpacts =
    -- Note: these are always expressed in ecoscore (ecs) µPt
    { agroDiversity : Unit.Impact
    , agroEcology : Unit.Impact
    , animalWelfare : Unit.Impact
    , total : Unit.Impact
    }


addBonusImpacts : BonusImpacts -> BonusImpacts -> BonusImpacts
addBonusImpacts a b =
    { agroDiversity = Quantity.plus a.agroDiversity b.agroDiversity
    , agroEcology = Quantity.plus a.agroEcology b.agroEcology
    , animalWelfare = Quantity.plus a.animalWelfare b.animalWelfare
    , total = Quantity.plus a.total b.total
    }


noBonusImpacts : BonusImpacts
noBonusImpacts =
    { agroDiversity = Unit.impact 0
    , agroEcology = Unit.impact 0
    , animalWelfare = Unit.impact 0
    , total = Unit.impact 0
    }


bonusesImpactAsChartEntries : BonusImpacts -> List { name : String, value : Float, color : String }
bonusesImpactAsChartEntries { agroDiversity, agroEcology, animalWelfare } =
    -- We want those bonuses to appear as negative values on the chart
    [ { name = "Bonus diversité agricole", value = -(Unit.impactToFloat agroDiversity), color = "#808080" }
    , { name = "Bonus infrastructures agro-écologiques", value = -(Unit.impactToFloat agroEcology), color = "#a0a0a0" }
    , { name = "Bonus conditions d'élevage", value = -(Unit.impactToFloat animalWelfare), color = "#c0c0c0" }
    ]


totalBonusesImpactAsChartEntry : BonusImpacts -> { name : String, value : Float, color : String }
totalBonusesImpactAsChartEntry { total } =
    -- We want those bonuses to appear as negative values on the chart
    { name = "Bonus écologique", value = -(Unit.impactToFloat total), color = "#808080" }


type alias ProtectionAreas =
    -- Protection Areas is basically scientific slang for subscores
    { climate : Unit.Impact -- Climat
    , biodiversity : Unit.Impact -- Biodiversité
    , resources : Unit.Impact -- Ressources
    , health : Unit.Impact -- Santé environnementale
    }


invalid : Scope -> Definition
invalid scope =
    { trigram = defaultTrigram scope
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


defaultFoodTrigram : Trigram
defaultFoodTrigram =
    trg "ecs"


defaultTextileTrigram : Trigram
defaultTextileTrigram =
    trg "pef"


defaultTrigram : Scope -> Trigram
defaultTrigram scope =
    case scope of
        Scope.Food ->
            defaultFoodTrigram

        Scope.Textile ->
            defaultTextileTrigram


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
        (Decode.field "weighting" (Unit.decodeRatio { percentage = True }))


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
toProtectionAreas defs impactsPerKg =
    let
        pick trigrams =
            impactsPerKg
                |> AnyDict.filter (\t _ -> List.member t (List.map trg trigrams))
                |> computeAggregatedScore .ecoscoreData defs
    in
    { climate =
        pick
            [ "cch" -- Climate change
            ]
    , biodiversity =
        pick
            [ "bvi" -- Biodiversity impact
            , "acd" -- Acidification
            , "tre" -- Terrestrial eutrophication
            , "fwe" -- Freshwater Eutrophication
            , "swe" -- Marine eutrophication
            , "etf-c" -- Ecotoxicity: freshwater
            , "ldu" -- Land use
            ]
    , health =
        pick
            [ "ozd" -- Ozone depletion
            , "ior" -- Ionising radiation
            , "pco" -- Photochemical ozone formation
            , "htn-c" -- Human toxicity: non-carcinogenic
            , "htc-c" -- Human toxicity: carcinogenic
            , "pma" -- Particulate matter
            ]
    , resources =
        pick
            [ "wtu" -- Water use
            , "fru" -- Fossile resource use
            , "mru" -- Minerals and metal resource use
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
mapImpacts =
    AnyDict.map


perKg : Mass -> Impacts -> Impacts
perKg totalMass =
    mapImpacts (\_ -> Quantity.divideBy (Mass.inKilograms totalMass))


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


encodeBonusesImpacts : BonusImpacts -> Encode.Value
encodeBonusesImpacts bonuses =
    Encode.object
        [ ( "agroDiversity", Unit.impactToFloat bonuses.agroDiversity |> Encode.float )
        , ( "agroEcology", Unit.impactToFloat bonuses.agroEcology |> Encode.float )
        , ( "animalWelfare", Unit.impactToFloat bonuses.animalWelfare |> Encode.float )
        , ( "total", Unit.impactToFloat bonuses.total |> Encode.float )
        ]


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


ln : Float -> Float
ln =
    logBase e


getAggregatedScoreData :
    List Definition
    -> (Definition -> Maybe AggregatedScoreData)
    -> Impacts
    -> List { color : String, name : String, value : Float }
getAggregatedScoreData defs getter =
    AnyDict.foldl
        (\trigram impact acc ->
            case getDefinition trigram defs of
                Ok def ->
                    case getter def of
                        Just { normalization, weighting, color } ->
                            { name = def.label
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


getAggregatedScoreOutOf100 : Unit.Impact -> Int
getAggregatedScoreOutOf100 =
    getBoundedScoreOutOf100 { impact100 = 70.9, impact0 = 2270 }


getBoundedScoreOutOf100 : Category.Bounds -> Unit.Impact -> Int
getBoundedScoreOutOf100 { impact100, impact0 } =
    -- Docs: https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/score-100
    Unit.impactToFloat
        >> (\value ->
                100 * (ln impact0 - ln value) / (ln impact0 - ln impact100)
           )
        >> floor
        >> clamp 0 100


getAggregatedScoreLetter : Int -> String
getAggregatedScoreLetter score =
    if score >= 80 then
        "A"

    else if score >= 60 then
        "B"

    else if score >= 40 then
        "C"

    else if score >= 20 then
        "D"

    else
        "E"


encodeAggregatedScoreChartEntry : { name : String, value : Float, color : String } -> Encode.Value
encodeAggregatedScoreChartEntry entry =
    -- This is to be easily used with Highcharts.js in a Web Component
    Encode.object
        [ ( "name", Encode.string entry.name )
        , ( "y", Encode.float entry.value )
        , ( "color", Encode.string entry.color )
        ]


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


parseTrigram : Scope -> Parser (Trigram -> a) a
parseTrigram scope =
    let
        trigrams =
            -- FIXME: find a way to have this check performed automatically from impacts db
            "acd,bvi,cch,ecs,etf,etf-c,fru,fwe,htc,htc-c,htn,htc-c,ior,ldu,mru,ozd,pco,pef,pma,swe,tre,wtu"
                |> String.split ","
    in
    Parser.custom "TRIGRAM" <|
        \trigram ->
            if List.member trigram trigrams then
                Just (trg trigram)

            else
                Just (defaultTrigram scope)
