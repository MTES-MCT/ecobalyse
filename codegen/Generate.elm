
module Generate exposing (main)

{-| -}

import Data.Scope
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Elm.Case
import Elm.Declare
import Elm.Op
import Gen.CodeGen.Generate as Generate
import Gen.Data.Scope
import Gen.Data.Unit
import Gen.List
import Gen.Result
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Data.Scope as Scope exposing (Scope)


main : Program Decode.Value () ()
main =
    Generate.fromJson
        decodeDefinitions
        generateDefinitions


type alias Definition =
    { source : Source
    , label : String
    , description : String
    , unit : String
    , decimals : Int
    , quality : Quality
    , pefData : Maybe AggregatedScoreData
    , ecoscoreData : Maybe AggregatedScoreData
    , scopes : List Scope
    }


type alias Definitions = Dict String Definition


type alias Source =
    { label : String, url : String }


genSource = 
    (Type.record
        [ ("label", Type.string)
        , ("url", Type.string)
        ]
    )
    


type Quality
    = AverageQuality
    | BadQuality
    | GoodQuality
    | NotFinished
    | UnknownQuality


qualityType =  Elm.customType "Quality"
    [ Elm.variant "AverageQuality"
    , Elm.variant "BadQuality"
    , Elm.variant "GoodQuality"
    , Elm.variant "NotFinished"
    , Elm.variant "UnknownQuality"
    ]


type alias AggregatedScoreData =
    { color : String
    , normalization : Float
    , weighting : Float
    }

genAggregatedScoreData =
    (Type.record
        [ ("color", Type.string)
        , ("normalization", Type.named [ "Data", "Unit" ] "Impact")
        , ("weighting", Type.named [ "Data", "Unit" ] "Ratio")
        ]
    )


decodeDefinitions: Decoder Definitions
decodeDefinitions =
    Decode.dict decodeDefinition

decodeSource : Decoder Source
decodeSource =
    Decode.map2 Source
        (Decode.field "label" Decode.string)
        (Decode.field "url" Decode.string)


decodeAggregatedScoreData : Decoder AggregatedScoreData
decodeAggregatedScoreData =
    Decode.map3 AggregatedScoreData
        (Decode.field "color" Decode.string)
        (Decode.field "normalization" Decode.float)
        (Decode.field "weighting" Decode.float)


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


decodeDefinition: Decoder Definition
decodeDefinition =
    Decode.succeed Definition
        |> Pipe.required "source" decodeSource
        |> Pipe.required "label_fr" Decode.string
        |> Pipe.required "description_fr" Decode.string
        |> Pipe.required "short_unit" Decode.string
        |> Pipe.required "decimals" Decode.int
        |> Pipe.required "quality" decodeQuality
        |> Pipe.required "pef" (Decode.maybe decodeAggregatedScoreData)
        |> Pipe.required "ecoscore" (Decode.maybe decodeAggregatedScoreData)
        |> Pipe.required "scopes" (Decode.list Scope.decode)

    
toTrigram : String -> String
toTrigram trigram =
    case String.uncons trigram of
        Just (head, tail) ->
            String.fromChar (Char.toUpper head) ++ (String.replace "-c" "C" tail)

        Nothing ->
            trigram

generateDefinitions : Definitions -> List Elm.File
generateDefinitions definitions =
    let
        trigramType =
            Dict.keys definitions
                |> List.map toTrigram
                |> List.map Elm.variant

        definitionType =
            Type.record
                [ ( "trigramString", Type.string)
                , ( "trigram", Type.named [] "Trigram")
                , ( "source", Type.alias [] "Source" [] genSource)
                , ( "label", Type.string)
                , ( "description", Type.string)
                , ( "unit", Type.string)
                , ( "decimals", Type.int)
                , ( "quality", Type.named [] "Quality" )
                , ( "pefData", Type.maybe (Type.alias [] "AggregatedScoreData" [] genAggregatedScoreData))
                , ( "ecoscoreData", Type.maybe (Type.alias [] "AggregatedScoreData" [] genAggregatedScoreData))
                , ( "scopes", Type.list (Type.named [ "Data", "Scope" ] "Scope"))
                ]

        definitionsType =
            Type.record
                (Dict.keys definitions
                    |> List.map (\trigram ->
                        (String.replace "-" "" trigram, definitionType)
                    )
                )

        definitionsExpression =
                (Elm.record
                    (Dict.toList definitions
                        |> List.map (\(trigram, definition) ->
                            (String.replace "-" "" trigram
                            , genDefinition trigram definition)
                        )
                    )
                )
                |> Elm.withType definitionsType 

        trigramsExpression =
            Dict.keys definitions
                |> List.map toTrigram
                |> List.map (\trigram -> Elm.value { importFrom = [], name = trigram, annotation = Nothing } )
                |> Elm.list
                |> Elm.withType (Type.named [] "List Trigram")

        trigrams = Elm.Declare.value "trigrams"
            trigramsExpression

        get = Elm.Declare.fn "get"
            ( "trigram", Nothing)
            (\trigram ->
                Elm.Case.custom trigram
                (Type.named [] "Trigram")
                (Dict.keys definitions
                    |> List.map toTrigram
                    |> List.map (\trigramString ->
                        Elm.Case.branch0 trigramString (Elm.get (String.toLower trigramString) definitionsExpression)
                    )
                )
            )
    in
    [ Elm.fileWith
        -- Module path
        [ "Data", "Impact", "Definition" ]
        -- Docs rendering
        { docs = \docs -> "foobar" :: (List.map Elm.docs docs)
        , aliases = [] }
        -- List of declarations
        [ Elm.comment "/!\\ This file is automatically generated, don't modify!"
        , Elm.comment "The generation is done with elm-codegen, from the script codegen/Generate.elm"
        -- Types
        , Elm.comment "Types"
        , Elm.alias "Source" genSource
            |> Elm.expose
        , qualityType
            |> Elm.exposeWith { exposeConstructor = True, group = Nothing }
        , Elm.alias "AggregatedScoreData" genAggregatedScoreData
            |> Elm.expose
        , Elm.customType "Trigram" trigramType
            |> Elm.exposeWith { exposeConstructor = True, group = Nothing }
        , Elm.alias "Definition"
            definitionType
            |> Elm.expose
        , Elm.alias "Definitions"
            definitionsType
            |> Elm.expose
        -- Helpers
        , Elm.comment "Helpers"
        , Elm.declaration "trigrams"
            trigramsExpression
            |> Elm.expose
        , get.declaration
            |> Elm.expose
        , Elm.declaration "toString"
            (Elm.fn ( "trigram", Nothing )
                (\trigram ->
                    (get.call trigram)
                    |> Elm.Op.pipe (Elm.val ".trigramString")
                )
                |> Elm.withType (Type.function [ Type.named [] "Trigram" ] Type.string)
            )
            |> Elm.expose
        , Elm.declaration "toTrigram"
            (Elm.fn ( "str", Nothing )
                (\str ->
                    Elm.Case.string str
                    { cases = (
                        Dict.keys definitions
                            |> List.map (\trigram ->
                                (trigram, Gen.Result.make_.ok (Elm.val (toTrigram trigram)))
                            )
                        )
                    , otherwise = Gen.Result.make_.err (Elm.val "<| \"Trigramme d'impact inconnu: \" ++ str")
                    }
                )
                |> Elm.withType (Type.function [ Type.string ] (Type.result Type.string (Type.named [] "Trigram" )))
            )
            |> Elm.expose
        , Elm.declaration "forScope"
            (Elm.fn ( "scope", Nothing )
                (\scope ->
                    trigrams.value
                    |> Elm.Op.pipe (Elm.val "List.map get")
                    |> Elm.Op.pipe (Elm.val "List.filter (.scopes >> List.member scope)")
                )
                |> Elm.withType (Type.function [Type.named [ "Data", "Scope" ] "Scope"] (Type.list definitionType))
            )
            |> Elm.expose
        , Elm.declaration "isAggregate"
            (Elm.fn ( "trigram", Nothing )
                (\trigram ->
                    Elm.val "trigram == Pef || trigram == Ecs"
                )
                |> Elm.withType (Type.function [Type.named [] "Trigram" ] Type.bool)
            )
            |> Elm.expose
            
        -- Data
        , Elm.comment "Data: the definitions imported from public/data/impacts.json"
        , Elm.declaration "definitions"
            definitionsExpression
            |> Elm.expose
        ]
    ]

genDefinition : String -> Definition -> Elm.Expression
genDefinition trigram definition =
    Elm.record
        [ ( "trigramString", Elm.string trigram )
        , ( "trigram", Elm.value { importFrom = [], name = toTrigram trigram, annotation = Nothing } )
        , ( "source", Elm.record [ ("label", Elm.string definition.source.label) , ("url", Elm.string definition.source.label) ] )
        , ( "label", Elm.string definition.label )
        , ( "description", Elm.string definition.description )
        , ( "unit", Elm.string definition.unit )
        , ( "decimals", Elm.int definition.decimals )
        , ( "quality", Elm.value { importFrom = [], name = qualityToString definition.quality, annotation = Nothing } )
        , ( "pefData", maybeAggregatedScoreDataToExpression definition.pefData )
        , ( "ecoscoreData", maybeAggregatedScoreDataToExpression definition.ecoscoreData )
        , ( "scopes", scopesToExpression definition.scopes )
        ]


qualityToString : Quality -> String
qualityToString quality =
    case quality of
        AverageQuality ->
            "AverageQuality"

        BadQuality ->
            "BadQuality"

        GoodQuality ->
            "GoodQuality"

        NotFinished ->
            "NotFinished"

        UnknownQuality ->
            "UnknownQuality"


maybeAggregatedScoreDataToExpression : Maybe AggregatedScoreData -> Elm.Expression
maybeAggregatedScoreDataToExpression maybeAggregatedScoreData =
    case maybeAggregatedScoreData of
        Just aggregatedScoreData ->
            Elm.just (
                (Elm.record
                    [ ("color", Elm.string aggregatedScoreData.color)
                    , ("normalization", Gen.Data.Unit.call_.impact (Elm.float aggregatedScoreData.normalization ) )
                    , ("weighting", Gen.Data.Unit.call_.ratio (Elm.float aggregatedScoreData.weighting ) )
                    ]
                )
            )

        Nothing ->
            Elm.nothing

scopesToExpression : List Scope -> Elm.Expression
scopesToExpression scopes =
    scopes
        |> List.map (\scope ->
            case scope of
                Data.Scope.Food ->
                    Gen.Data.Scope.make_.food
                Data.Scope.Textile ->
                    Gen.Data.Scope.make_.textile
            )
        |> Elm.list