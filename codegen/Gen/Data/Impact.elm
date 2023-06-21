module Gen.Data.Impact exposing (addBonusImpacts, annotation_, applyBonus, bonusesImpactAsChartEntries, call_, decodeImpacts, defaultFoodTrigram, defaultTextileTrigram, encodeAggregatedScoreChartEntry, encodeBonusesImpacts, encodeImpacts, filterImpacts, getAggregatedScoreData, getImpact, grabImpactFloat, impactsFromDefinitons, make_, mapImpacts, moduleName_, noBonusImpacts, noImpacts, parseTrigram, perKg, sumImpacts, toDict, toProtectionAreas, totalBonusesImpactAsChartEntry, updateImpact, values_)

{-| 
@docs moduleName_, parseTrigram, encodeAggregatedScoreChartEntry, getAggregatedScoreData, encodeImpacts, encodeBonusesImpacts, decodeImpacts, updateImpact, toDict, sumImpacts, perKg, mapImpacts, filterImpacts, grabImpactFloat, getImpact, impactsFromDefinitons, noImpacts, toProtectionAreas, defaultTextileTrigram, defaultFoodTrigram, totalBonusesImpactAsChartEntry, bonusesImpactAsChartEntries, noBonusImpacts, applyBonus, addBonusImpacts, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Impact" ]


{-| parseTrigram: Parser (Trigram -> a) a -}
parseTrigram : Elm.Expression
parseTrigram =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "parseTrigram"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Parser"
                    [ Type.function
                        [ Type.namedWith [] "Trigram" [] ]
                        (Type.var "a")
                    , Type.var "a"
                    ]
                )
        }


{-| encodeAggregatedScoreChartEntry: { name : String, value : Float, color : String } -> Encode.Value -}
encodeAggregatedScoreChartEntry :
    { name : String, value : Float, color : String } -> Elm.Expression
encodeAggregatedScoreChartEntry encodeAggregatedScoreChartEntryArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "encodeAggregatedScoreChartEntry"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "name", Type.string )
                            , ( "value", Type.float )
                            , ( "color", Type.string )
                            ]
                        ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ Elm.record
            [ Tuple.pair
                "name"
                (Elm.string encodeAggregatedScoreChartEntryArg.name)
            , Tuple.pair
                "value"
                (Elm.float encodeAggregatedScoreChartEntryArg.value)
            , Tuple.pair
                "color"
                (Elm.string encodeAggregatedScoreChartEntryArg.color)
            ]
        ]


{-| getAggregatedScoreData: 
    (Definition -> Maybe Definition.AggregatedScoreData)
    -> Impacts
    -> List { color : String, name : String, value : Float }
-}
getAggregatedScoreData :
    (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
getAggregatedScoreData getAggregatedScoreDataArg getAggregatedScoreDataArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "getAggregatedScoreData"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [] "Definition" [] ]
                            (Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith
                                    [ "Definition" ]
                                    "AggregatedScoreData"
                                    []
                                ]
                            )
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.list
                            (Type.record
                                [ ( "color", Type.string )
                                , ( "name", Type.string )
                                , ( "value", Type.float )
                                ]
                            )
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "getAggregatedScoreDataUnpack"
            getAggregatedScoreDataArg
        , getAggregatedScoreDataArg0
        ]


{-| encodeImpacts: Scope -> Impacts -> Encode.Value -}
encodeImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
encodeImpacts encodeImpactsArg encodeImpactsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "encodeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeImpactsArg, encodeImpactsArg0 ]


{-| encodeBonusesImpacts: BonusImpacts -> Encode.Value -}
encodeBonusesImpacts : Elm.Expression -> Elm.Expression
encodeBonusesImpacts encodeBonusesImpactsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "encodeBonusesImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeBonusesImpactsArg ]


{-| decodeImpacts: Decoder Impacts -}
decodeImpacts : Elm.Expression
decodeImpacts =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "decodeImpacts"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Impacts" [] ])
        }


{-| updateImpact: Trigram -> Unit.Impact -> Impacts -> Impacts -}
updateImpact :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateImpact updateImpactArg updateImpactArg0 updateImpactArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "updateImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" []
                        , Type.namedWith [ "Unit" ] "Impact" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ updateImpactArg, updateImpactArg0, updateImpactArg1 ]


{-| toDict: Impacts -> AnyDict.AnyDict String Trigram Unit.Impact -}
toDict : Elm.Expression -> Elm.Expression
toDict toDictArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "toDict"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" [] ]
                        (Type.namedWith
                            [ "AnyDict" ]
                            "AnyDict"
                            [ Type.string
                            , Type.namedWith [] "Trigram" []
                            , Type.namedWith [ "Unit" ] "Impact" []
                            ]
                        )
                    )
            }
        )
        [ toDictArg ]


{-| sumImpacts: List Impacts -> Impacts -}
sumImpacts : List Elm.Expression -> Elm.Expression
sumImpacts sumImpactsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "sumImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Impacts" []) ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ Elm.list sumImpactsArg ]


{-| perKg: Mass -> Impacts -> Impacts -}
perKg : Elm.Expression -> Elm.Expression -> Elm.Expression
perKg perKgArg perKgArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "perKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ perKgArg, perKgArg0 ]


{-| mapImpacts: (Trigram -> Unit.Impact -> Unit.Impact) -> Impacts -> Impacts -}
mapImpacts :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
mapImpacts mapImpactsArg mapImpactsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "mapImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [] "Trigram" []
                            , Type.namedWith [ "Unit" ] "Impact" []
                            ]
                            (Type.namedWith [ "Unit" ] "Impact" [])
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ Elm.functionReduced
            "mapImpactsUnpack"
            (\functionReducedUnpack ->
                Elm.functionReduced
                    "unpack"
                    (mapImpactsArg functionReducedUnpack)
            )
        , mapImpactsArg0
        ]


{-| filterImpacts: (Trigram -> Unit.Impact -> Bool) -> Impacts -> Impacts -}
filterImpacts :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
filterImpacts filterImpactsArg filterImpactsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "filterImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [] "Trigram" []
                            , Type.namedWith [ "Unit" ] "Impact" []
                            ]
                            Type.bool
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ Elm.functionReduced
            "filterImpactsUnpack"
            (\functionReducedUnpack ->
                Elm.functionReduced
                    "unpack"
                    (filterImpactsArg functionReducedUnpack)
            )
        , filterImpactsArg0
        ]


{-| grabImpactFloat: Unit.Functional -> Duration -> Trigram -> { a | impacts : Impacts } -> Float -}
grabImpactFloat :
    Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> { a | impacts : Elm.Expression }
    -> Elm.Expression
grabImpactFloat grabImpactFloatArg grabImpactFloatArg0 grabImpactFloatArg1 grabImpactFloatArg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "grabImpactFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Functional" []
                        , Type.namedWith [] "Duration" []
                        , Type.namedWith [] "Trigram" []
                        , Type.extensible
                            "a"
                            [ ( "impacts", Type.namedWith [] "Impacts" [] ) ]
                        ]
                        Type.float
                    )
            }
        )
        [ grabImpactFloatArg
        , grabImpactFloatArg0
        , grabImpactFloatArg1
        , Elm.record [ Tuple.pair "impacts" grabImpactFloatArg2.impacts ]
        ]


{-| getImpact: Trigram -> Impacts -> Unit.Impact -}
getImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
getImpact getImpactArg getImpactArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "getImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [ "Unit" ] "Impact" [])
                    )
            }
        )
        [ getImpactArg, getImpactArg0 ]


{-| impactsFromDefinitons: Impacts -}
impactsFromDefinitons : Elm.Expression
impactsFromDefinitons =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "impactsFromDefinitons"
        , annotation = Just (Type.namedWith [] "Impacts" [])
        }


{-| noImpacts: Impacts -}
noImpacts : Elm.Expression
noImpacts =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "noImpacts"
        , annotation = Just (Type.namedWith [] "Impacts" [])
        }


{-| toProtectionAreas: Impacts -> ProtectionAreas -}
toProtectionAreas : Elm.Expression -> Elm.Expression
toProtectionAreas toProtectionAreasArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "toProtectionAreas"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" [] ]
                        (Type.namedWith [] "ProtectionAreas" [])
                    )
            }
        )
        [ toProtectionAreasArg ]


{-| defaultTextileTrigram: Trigram -}
defaultTextileTrigram : Elm.Expression
defaultTextileTrigram =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "defaultTextileTrigram"
        , annotation = Just (Type.namedWith [] "Trigram" [])
        }


{-| defaultFoodTrigram: Trigram -}
defaultFoodTrigram : Elm.Expression
defaultFoodTrigram =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "defaultFoodTrigram"
        , annotation = Just (Type.namedWith [] "Trigram" [])
        }


{-| totalBonusesImpactAsChartEntry: BonusImpacts -> { name : String, value : Float, color : String } -}
totalBonusesImpactAsChartEntry : Elm.Expression -> Elm.Expression
totalBonusesImpactAsChartEntry totalBonusesImpactAsChartEntryArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "totalBonusesImpactAsChartEntry"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" [] ]
                        (Type.record
                            [ ( "name", Type.string )
                            , ( "value", Type.float )
                            , ( "color", Type.string )
                            ]
                        )
                    )
            }
        )
        [ totalBonusesImpactAsChartEntryArg ]


{-| bonusesImpactAsChartEntries: BonusImpacts -> List { name : String, value : Float, color : String } -}
bonusesImpactAsChartEntries : Elm.Expression -> Elm.Expression
bonusesImpactAsChartEntries bonusesImpactAsChartEntriesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "bonusesImpactAsChartEntries"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" [] ]
                        (Type.list
                            (Type.record
                                [ ( "name", Type.string )
                                , ( "value", Type.float )
                                , ( "color", Type.string )
                                ]
                            )
                        )
                    )
            }
        )
        [ bonusesImpactAsChartEntriesArg ]


{-| noBonusImpacts: BonusImpacts -}
noBonusImpacts : Elm.Expression
noBonusImpacts =
    Elm.value
        { importFrom = [ "Data", "Impact" ]
        , name = "noBonusImpacts"
        , annotation = Just (Type.namedWith [] "BonusImpacts" [])
        }


{-| applyBonus: Unit.Impact -> Impacts -> Impacts -}
applyBonus : Elm.Expression -> Elm.Expression -> Elm.Expression
applyBonus applyBonusArg applyBonusArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "applyBonus"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Impact" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ applyBonusArg, applyBonusArg0 ]


{-| addBonusImpacts: BonusImpacts -> BonusImpacts -> BonusImpacts -}
addBonusImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
addBonusImpacts addBonusImpactsArg addBonusImpactsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "addBonusImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" []
                        , Type.namedWith [] "BonusImpacts" []
                        ]
                        (Type.namedWith [] "BonusImpacts" [])
                    )
            }
        )
        [ addBonusImpactsArg, addBonusImpactsArg0 ]


annotation_ : { bonusImpacts : Type.Annotation, impacts : Type.Annotation }
annotation_ =
    { bonusImpacts =
        Type.alias
            moduleName_
            "BonusImpacts"
            []
            (Type.record
                [ ( "agroDiversity", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "agroEcology", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "animalWelfare", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "total", Type.namedWith [ "Unit" ] "Impact" [] )
                ]
            )
    , impacts = Type.namedWith [ "Data", "Impact" ] "Impacts" []
    }


make_ :
    { bonusImpacts :
        { agroDiversity : Elm.Expression
        , agroEcology : Elm.Expression
        , animalWelfare : Elm.Expression
        , total : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { bonusImpacts =
        \bonusImpacts_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Impact" ]
                    "BonusImpacts"
                    []
                    (Type.record
                        [ ( "agroDiversity"
                          , Type.namedWith [ "Unit" ] "Impact" []
                          )
                        , ( "agroEcology"
                          , Type.namedWith [ "Unit" ] "Impact" []
                          )
                        , ( "animalWelfare"
                          , Type.namedWith [ "Unit" ] "Impact" []
                          )
                        , ( "total", Type.namedWith [ "Unit" ] "Impact" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "agroDiversity" bonusImpacts_args.agroDiversity
                    , Tuple.pair "agroEcology" bonusImpacts_args.agroEcology
                    , Tuple.pair "animalWelfare" bonusImpacts_args.animalWelfare
                    , Tuple.pair "total" bonusImpacts_args.total
                    ]
                )
    }


call_ :
    { encodeAggregatedScoreChartEntry : Elm.Expression -> Elm.Expression
    , getAggregatedScoreData :
        Elm.Expression -> Elm.Expression -> Elm.Expression
    , encodeImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
    , encodeBonusesImpacts : Elm.Expression -> Elm.Expression
    , updateImpact :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , toDict : Elm.Expression -> Elm.Expression
    , sumImpacts : Elm.Expression -> Elm.Expression
    , perKg : Elm.Expression -> Elm.Expression -> Elm.Expression
    , mapImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
    , filterImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
    , grabImpactFloat :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , getImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
    , toProtectionAreas : Elm.Expression -> Elm.Expression
    , totalBonusesImpactAsChartEntry : Elm.Expression -> Elm.Expression
    , bonusesImpactAsChartEntries : Elm.Expression -> Elm.Expression
    , applyBonus : Elm.Expression -> Elm.Expression -> Elm.Expression
    , addBonusImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { encodeAggregatedScoreChartEntry =
        \encodeAggregatedScoreChartEntryArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "encodeAggregatedScoreChartEntry"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.record
                                    [ ( "name", Type.string )
                                    , ( "value", Type.float )
                                    , ( "color", Type.string )
                                    ]
                                ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeAggregatedScoreChartEntryArg ]
    , getAggregatedScoreData =
        \getAggregatedScoreDataArg getAggregatedScoreDataArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "getAggregatedScoreData"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.namedWith [] "Definition" [] ]
                                    (Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            [ "Definition" ]
                                            "AggregatedScoreData"
                                            []
                                        ]
                                    )
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.list
                                    (Type.record
                                        [ ( "color", Type.string )
                                        , ( "name", Type.string )
                                        , ( "value", Type.float )
                                        ]
                                    )
                                )
                            )
                    }
                )
                [ getAggregatedScoreDataArg, getAggregatedScoreDataArg0 ]
    , encodeImpacts =
        \encodeImpactsArg encodeImpactsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "encodeImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeImpactsArg, encodeImpactsArg0 ]
    , encodeBonusesImpacts =
        \encodeBonusesImpactsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "encodeBonusesImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "BonusImpacts" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeBonusesImpactsArg ]
    , updateImpact =
        \updateImpactArg updateImpactArg0 updateImpactArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "updateImpact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Trigram" []
                                , Type.namedWith [ "Unit" ] "Impact" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ updateImpactArg, updateImpactArg0, updateImpactArg1 ]
    , toDict =
        \toDictArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "toDict"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" [] ]
                                (Type.namedWith
                                    [ "AnyDict" ]
                                    "AnyDict"
                                    [ Type.string
                                    , Type.namedWith [] "Trigram" []
                                    , Type.namedWith [ "Unit" ] "Impact" []
                                    ]
                                )
                            )
                    }
                )
                [ toDictArg ]
    , sumImpacts =
        \sumImpactsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "sumImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Impacts" []) ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ sumImpactsArg ]
    , perKg =
        \perKgArg perKgArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "perKg"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ perKgArg, perKgArg0 ]
    , mapImpacts =
        \mapImpactsArg mapImpactsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "mapImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.namedWith [] "Trigram" []
                                    , Type.namedWith [ "Unit" ] "Impact" []
                                    ]
                                    (Type.namedWith [ "Unit" ] "Impact" [])
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ mapImpactsArg, mapImpactsArg0 ]
    , filterImpacts =
        \filterImpactsArg filterImpactsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "filterImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.namedWith [] "Trigram" []
                                    , Type.namedWith [ "Unit" ] "Impact" []
                                    ]
                                    Type.bool
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ filterImpactsArg, filterImpactsArg0 ]
    , grabImpactFloat =
        \grabImpactFloatArg grabImpactFloatArg0 grabImpactFloatArg1 grabImpactFloatArg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "grabImpactFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "Functional" []
                                , Type.namedWith [] "Duration" []
                                , Type.namedWith [] "Trigram" []
                                , Type.extensible
                                    "a"
                                    [ ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                ]
                                Type.float
                            )
                    }
                )
                [ grabImpactFloatArg
                , grabImpactFloatArg0
                , grabImpactFloatArg1
                , grabImpactFloatArg2
                ]
    , getImpact =
        \getImpactArg getImpactArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "getImpact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Trigram" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [ "Unit" ] "Impact" [])
                            )
                    }
                )
                [ getImpactArg, getImpactArg0 ]
    , toProtectionAreas =
        \toProtectionAreasArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "toProtectionAreas"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" [] ]
                                (Type.namedWith [] "ProtectionAreas" [])
                            )
                    }
                )
                [ toProtectionAreasArg ]
    , totalBonusesImpactAsChartEntry =
        \totalBonusesImpactAsChartEntryArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "totalBonusesImpactAsChartEntry"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "BonusImpacts" [] ]
                                (Type.record
                                    [ ( "name", Type.string )
                                    , ( "value", Type.float )
                                    , ( "color", Type.string )
                                    ]
                                )
                            )
                    }
                )
                [ totalBonusesImpactAsChartEntryArg ]
    , bonusesImpactAsChartEntries =
        \bonusesImpactAsChartEntriesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "bonusesImpactAsChartEntries"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "BonusImpacts" [] ]
                                (Type.list
                                    (Type.record
                                        [ ( "name", Type.string )
                                        , ( "value", Type.float )
                                        , ( "color", Type.string )
                                        ]
                                    )
                                )
                            )
                    }
                )
                [ bonusesImpactAsChartEntriesArg ]
    , applyBonus =
        \applyBonusArg applyBonusArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "applyBonus"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "Impact" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ applyBonusArg, applyBonusArg0 ]
    , addBonusImpacts =
        \addBonusImpactsArg addBonusImpactsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact" ]
                    , name = "addBonusImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "BonusImpacts" []
                                , Type.namedWith [] "BonusImpacts" []
                                ]
                                (Type.namedWith [] "BonusImpacts" [])
                            )
                    }
                )
                [ addBonusImpactsArg, addBonusImpactsArg0 ]
    }


values_ :
    { parseTrigram : Elm.Expression
    , encodeAggregatedScoreChartEntry : Elm.Expression
    , getAggregatedScoreData : Elm.Expression
    , encodeImpacts : Elm.Expression
    , encodeBonusesImpacts : Elm.Expression
    , decodeImpacts : Elm.Expression
    , updateImpact : Elm.Expression
    , toDict : Elm.Expression
    , sumImpacts : Elm.Expression
    , perKg : Elm.Expression
    , mapImpacts : Elm.Expression
    , filterImpacts : Elm.Expression
    , grabImpactFloat : Elm.Expression
    , getImpact : Elm.Expression
    , impactsFromDefinitons : Elm.Expression
    , noImpacts : Elm.Expression
    , toProtectionAreas : Elm.Expression
    , defaultTextileTrigram : Elm.Expression
    , defaultFoodTrigram : Elm.Expression
    , totalBonusesImpactAsChartEntry : Elm.Expression
    , bonusesImpactAsChartEntries : Elm.Expression
    , noBonusImpacts : Elm.Expression
    , applyBonus : Elm.Expression
    , addBonusImpacts : Elm.Expression
    }
values_ =
    { parseTrigram =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "parseTrigram"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Parser"
                        [ Type.function
                            [ Type.namedWith [] "Trigram" [] ]
                            (Type.var "a")
                        , Type.var "a"
                        ]
                    )
            }
    , encodeAggregatedScoreChartEntry =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "encodeAggregatedScoreChartEntry"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "name", Type.string )
                            , ( "value", Type.float )
                            , ( "color", Type.string )
                            ]
                        ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , getAggregatedScoreData =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "getAggregatedScoreData"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [] "Definition" [] ]
                            (Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith
                                    [ "Definition" ]
                                    "AggregatedScoreData"
                                    []
                                ]
                            )
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.list
                            (Type.record
                                [ ( "color", Type.string )
                                , ( "name", Type.string )
                                , ( "value", Type.float )
                                ]
                            )
                        )
                    )
            }
    , encodeImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "encodeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , encodeBonusesImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "encodeBonusesImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "decodeImpacts"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Impacts" [] ]
                    )
            }
    , updateImpact =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "updateImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" []
                        , Type.namedWith [ "Unit" ] "Impact" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , toDict =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "toDict"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" [] ]
                        (Type.namedWith
                            [ "AnyDict" ]
                            "AnyDict"
                            [ Type.string
                            , Type.namedWith [] "Trigram" []
                            , Type.namedWith [ "Unit" ] "Impact" []
                            ]
                        )
                    )
            }
    , sumImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "sumImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Impacts" []) ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , perKg =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "perKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , mapImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "mapImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [] "Trigram" []
                            , Type.namedWith [ "Unit" ] "Impact" []
                            ]
                            (Type.namedWith [ "Unit" ] "Impact" [])
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , filterImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "filterImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [] "Trigram" []
                            , Type.namedWith [ "Unit" ] "Impact" []
                            ]
                            Type.bool
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , grabImpactFloat =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "grabImpactFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Functional" []
                        , Type.namedWith [] "Duration" []
                        , Type.namedWith [] "Trigram" []
                        , Type.extensible
                            "a"
                            [ ( "impacts", Type.namedWith [] "Impacts" [] ) ]
                        ]
                        Type.float
                    )
            }
    , getImpact =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "getImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [ "Unit" ] "Impact" [])
                    )
            }
    , impactsFromDefinitons =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "impactsFromDefinitons"
            , annotation = Just (Type.namedWith [] "Impacts" [])
            }
    , noImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "noImpacts"
            , annotation = Just (Type.namedWith [] "Impacts" [])
            }
    , toProtectionAreas =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "toProtectionAreas"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" [] ]
                        (Type.namedWith [] "ProtectionAreas" [])
                    )
            }
    , defaultTextileTrigram =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "defaultTextileTrigram"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , defaultFoodTrigram =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "defaultFoodTrigram"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , totalBonusesImpactAsChartEntry =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "totalBonusesImpactAsChartEntry"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" [] ]
                        (Type.record
                            [ ( "name", Type.string )
                            , ( "value", Type.float )
                            , ( "color", Type.string )
                            ]
                        )
                    )
            }
    , bonusesImpactAsChartEntries =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "bonusesImpactAsChartEntries"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" [] ]
                        (Type.list
                            (Type.record
                                [ ( "name", Type.string )
                                , ( "value", Type.float )
                                , ( "color", Type.string )
                                ]
                            )
                        )
                    )
            }
    , noBonusImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "noBonusImpacts"
            , annotation = Just (Type.namedWith [] "BonusImpacts" [])
            }
    , applyBonus =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "applyBonus"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Impact" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , addBonusImpacts =
        Elm.value
            { importFrom = [ "Data", "Impact" ]
            , name = "addBonusImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "BonusImpacts" []
                        , Type.namedWith [] "BonusImpacts" []
                        ]
                        (Type.namedWith [] "BonusImpacts" [])
                    )
            }
    }