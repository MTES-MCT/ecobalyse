module Gen.Data.Textile.Process exposing (annotation_, call_, caseOf_, decodeFromUuid, decodeList, encodeUuid, findByUuid, getDyeingProcess, getEnnoblingHeatProcess, getImpact, getKnittingProcess, getPrintingProcess, loadWellKnown, make_, moduleName_, uuidToString, values_)

{-| 
@docs moduleName_, encodeUuid, decodeList, decodeFromUuid, uuidToString, loadWellKnown, getImpact, getPrintingProcess, getEnnoblingHeatProcess, getKnittingProcess, getDyeingProcess, findByUuid, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Process" ]


{-| encodeUuid: Uuid -> Encode.Value -}
encodeUuid : Elm.Expression -> Elm.Expression
encodeUuid encodeUuidArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "encodeUuid"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Uuid" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeUuidArg ]


{-| decodeList: Decoder (List Process) -}
decodeList : Elm.Expression
decodeList =
    Elm.value
        { importFrom = [ "Data", "Textile", "Process" ]
        , name = "decodeList"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.list (Type.namedWith [] "Process" []) ]
                )
        }


{-| decodeFromUuid: List Process -> Decoder Process -}
decodeFromUuid : List Elm.Expression -> Elm.Expression
decodeFromUuid decodeFromUuidArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "decodeFromUuid"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.namedWith [] "Process" [] ]
                        )
                    )
            }
        )
        [ Elm.list decodeFromUuidArg ]


{-| uuidToString: Uuid -> String -}
uuidToString : Elm.Expression -> Elm.Expression
uuidToString uuidToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "uuidToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Uuid" [] ] Type.string)
            }
        )
        [ uuidToStringArg ]


{-| loadWellKnown: List Process -> Result String WellKnown -}
loadWellKnown : List Elm.Expression -> Elm.Expression
loadWellKnown loadWellKnownArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "loadWellKnown"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "WellKnown" [] ]
                        )
                    )
            }
        )
        [ Elm.list loadWellKnownArg ]


{-| getImpact: Definition.Trigram -> Process -> Unit.Impact -}
getImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
getImpact getImpactArg getImpactArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Definition" ] "Trigram" []
                        , Type.namedWith [] "Process" []
                        ]
                        (Type.namedWith [ "Unit" ] "Impact" [])
                    )
            }
        )
        [ getImpactArg, getImpactArg0 ]


{-| getPrintingProcess: Printing.Kind -> WellKnown -> Process -}
getPrintingProcess : Elm.Expression -> Elm.Expression -> Elm.Expression
getPrintingProcess getPrintingProcessArg getPrintingProcessArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getPrintingProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Printing" ] "Kind" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
        )
        [ getPrintingProcessArg, getPrintingProcessArg0 ]


{-| getEnnoblingHeatProcess: WellKnown -> Zone -> HeatSource -> Process -}
getEnnoblingHeatProcess :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
getEnnoblingHeatProcess getEnnoblingHeatProcessArg getEnnoblingHeatProcessArg0 getEnnoblingHeatProcessArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getEnnoblingHeatProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "WellKnown" []
                        , Type.namedWith [] "Zone" []
                        , Type.namedWith [] "HeatSource" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
        )
        [ getEnnoblingHeatProcessArg
        , getEnnoblingHeatProcessArg0
        , getEnnoblingHeatProcessArg1
        ]


{-| getKnittingProcess: Knitting -> WellKnown -> Process -}
getKnittingProcess : Elm.Expression -> Elm.Expression -> Elm.Expression
getKnittingProcess getKnittingProcessArg getKnittingProcessArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getKnittingProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
        )
        [ getKnittingProcessArg, getKnittingProcessArg0 ]


{-| getDyeingProcess: DyeingMedium -> WellKnown -> Process -}
getDyeingProcess : Elm.Expression -> Elm.Expression -> Elm.Expression
getDyeingProcess getDyeingProcessArg getDyeingProcessArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getDyeingProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
        )
        [ getDyeingProcessArg, getDyeingProcessArg0 ]


{-| findByUuid: Uuid -> List Process -> Result String Process -}
findByUuid : Elm.Expression -> List Elm.Expression -> Elm.Expression
findByUuid findByUuidArg findByUuidArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "findByUuid"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Uuid" []
                        , Type.list (Type.namedWith [] "Process" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Process" [] ]
                        )
                    )
            }
        )
        [ findByUuidArg, Elm.list findByUuidArg0 ]


annotation_ :
    { wellKnown : Type.Annotation
    , process : Type.Annotation
    , uuid : Type.Annotation
    }
annotation_ =
    { wellKnown =
        Type.alias
            moduleName_
            "WellKnown"
            []
            (Type.record
                [ ( "airTransport", Type.namedWith [] "Process" [] )
                , ( "seaTransport", Type.namedWith [] "Process" [] )
                , ( "roadTransportPreMaking", Type.namedWith [] "Process" [] )
                , ( "roadTransportPostMaking", Type.namedWith [] "Process" [] )
                , ( "distribution", Type.namedWith [] "Process" [] )
                , ( "dyeingYarn", Type.namedWith [] "Process" [] )
                , ( "dyeingFabric", Type.namedWith [] "Process" [] )
                , ( "dyeingArticle", Type.namedWith [] "Process" [] )
                , ( "knittingMix", Type.namedWith [] "Process" [] )
                , ( "knittingFullyFashioned", Type.namedWith [] "Process" [] )
                , ( "knittingSeamless", Type.namedWith [] "Process" [] )
                , ( "knittingCircular", Type.namedWith [] "Process" [] )
                , ( "knittingStraight", Type.namedWith [] "Process" [] )
                , ( "printingPigment", Type.namedWith [] "Process" [] )
                , ( "printingSubstantive", Type.namedWith [] "Process" [] )
                , ( "finishing", Type.namedWith [] "Process" [] )
                , ( "passengerCar", Type.namedWith [] "Process" [] )
                , ( "endOfLife", Type.namedWith [] "Process" [] )
                , ( "fading", Type.namedWith [] "Process" [] )
                , ( "steamGasRER", Type.namedWith [] "Process" [] )
                , ( "steamGasRSA", Type.namedWith [] "Process" [] )
                , ( "steamLightFuelRER", Type.namedWith [] "Process" [] )
                , ( "steamLightFuelRSA", Type.namedWith [] "Process" [] )
                , ( "steamHeavyFuelRER", Type.namedWith [] "Process" [] )
                , ( "steamHeavyFuelRSA", Type.namedWith [] "Process" [] )
                , ( "steamCoalRER", Type.namedWith [] "Process" [] )
                , ( "steamCoalRSA", Type.namedWith [] "Process" [] )
                ]
            )
    , process =
        Type.alias
            moduleName_
            "Process"
            []
            (Type.record
                [ ( "name", Type.string )
                , ( "info", Type.string )
                , ( "unit", Type.string )
                , ( "source", Type.string )
                , ( "correctif", Type.string )
                , ( "stepUsage", Type.string )
                , ( "uuid", Type.namedWith [] "Uuid" [] )
                , ( "impacts", Type.namedWith [] "Impacts" [] )
                , ( "heat", Type.namedWith [] "Energy" [] )
                , ( "elec_pppm", Type.float )
                , ( "elec", Type.namedWith [] "Energy" [] )
                , ( "waste", Type.namedWith [] "Mass" [] )
                , ( "alias"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Alias" [] ]
                  )
                ]
            )
    , uuid = Type.namedWith [ "Data", "Textile", "Process" ] "Uuid" []
    }


make_ :
    { wellKnown :
        { airTransport : Elm.Expression
        , seaTransport : Elm.Expression
        , roadTransportPreMaking : Elm.Expression
        , roadTransportPostMaking : Elm.Expression
        , distribution : Elm.Expression
        , dyeingYarn : Elm.Expression
        , dyeingFabric : Elm.Expression
        , dyeingArticle : Elm.Expression
        , knittingMix : Elm.Expression
        , knittingFullyFashioned : Elm.Expression
        , knittingSeamless : Elm.Expression
        , knittingCircular : Elm.Expression
        , knittingStraight : Elm.Expression
        , printingPigment : Elm.Expression
        , printingSubstantive : Elm.Expression
        , finishing : Elm.Expression
        , passengerCar : Elm.Expression
        , endOfLife : Elm.Expression
        , fading : Elm.Expression
        , steamGasRER : Elm.Expression
        , steamGasRSA : Elm.Expression
        , steamLightFuelRER : Elm.Expression
        , steamLightFuelRSA : Elm.Expression
        , steamHeavyFuelRER : Elm.Expression
        , steamHeavyFuelRSA : Elm.Expression
        , steamCoalRER : Elm.Expression
        , steamCoalRSA : Elm.Expression
        }
        -> Elm.Expression
    , process :
        { name : Elm.Expression
        , info : Elm.Expression
        , unit : Elm.Expression
        , source : Elm.Expression
        , correctif : Elm.Expression
        , stepUsage : Elm.Expression
        , uuid : Elm.Expression
        , impacts : Elm.Expression
        , heat : Elm.Expression
        , elec_pppm : Elm.Expression
        , elec : Elm.Expression
        , waste : Elm.Expression
        , alias : Elm.Expression
        }
        -> Elm.Expression
    , uuid : Elm.Expression -> Elm.Expression
    }
make_ =
    { wellKnown =
        \wellKnown_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Process" ]
                    "WellKnown"
                    []
                    (Type.record
                        [ ( "airTransport", Type.namedWith [] "Process" [] )
                        , ( "seaTransport", Type.namedWith [] "Process" [] )
                        , ( "roadTransportPreMaking"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "roadTransportPostMaking"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "distribution", Type.namedWith [] "Process" [] )
                        , ( "dyeingYarn", Type.namedWith [] "Process" [] )
                        , ( "dyeingFabric", Type.namedWith [] "Process" [] )
                        , ( "dyeingArticle", Type.namedWith [] "Process" [] )
                        , ( "knittingMix", Type.namedWith [] "Process" [] )
                        , ( "knittingFullyFashioned"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "knittingSeamless", Type.namedWith [] "Process" [] )
                        , ( "knittingCircular", Type.namedWith [] "Process" [] )
                        , ( "knittingStraight", Type.namedWith [] "Process" [] )
                        , ( "printingPigment", Type.namedWith [] "Process" [] )
                        , ( "printingSubstantive"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "finishing", Type.namedWith [] "Process" [] )
                        , ( "passengerCar", Type.namedWith [] "Process" [] )
                        , ( "endOfLife", Type.namedWith [] "Process" [] )
                        , ( "fading", Type.namedWith [] "Process" [] )
                        , ( "steamGasRER", Type.namedWith [] "Process" [] )
                        , ( "steamGasRSA", Type.namedWith [] "Process" [] )
                        , ( "steamLightFuelRER"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "steamLightFuelRSA"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "steamHeavyFuelRER"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "steamHeavyFuelRSA"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "steamCoalRER", Type.namedWith [] "Process" [] )
                        , ( "steamCoalRSA", Type.namedWith [] "Process" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "airTransport" wellKnown_args.airTransport
                    , Tuple.pair "seaTransport" wellKnown_args.seaTransport
                    , Tuple.pair
                        "roadTransportPreMaking"
                        wellKnown_args.roadTransportPreMaking
                    , Tuple.pair
                        "roadTransportPostMaking"
                        wellKnown_args.roadTransportPostMaking
                    , Tuple.pair "distribution" wellKnown_args.distribution
                    , Tuple.pair "dyeingYarn" wellKnown_args.dyeingYarn
                    , Tuple.pair "dyeingFabric" wellKnown_args.dyeingFabric
                    , Tuple.pair "dyeingArticle" wellKnown_args.dyeingArticle
                    , Tuple.pair "knittingMix" wellKnown_args.knittingMix
                    , Tuple.pair
                        "knittingFullyFashioned"
                        wellKnown_args.knittingFullyFashioned
                    , Tuple.pair
                        "knittingSeamless"
                        wellKnown_args.knittingSeamless
                    , Tuple.pair
                        "knittingCircular"
                        wellKnown_args.knittingCircular
                    , Tuple.pair
                        "knittingStraight"
                        wellKnown_args.knittingStraight
                    , Tuple.pair
                        "printingPigment"
                        wellKnown_args.printingPigment
                    , Tuple.pair
                        "printingSubstantive"
                        wellKnown_args.printingSubstantive
                    , Tuple.pair "finishing" wellKnown_args.finishing
                    , Tuple.pair "passengerCar" wellKnown_args.passengerCar
                    , Tuple.pair "endOfLife" wellKnown_args.endOfLife
                    , Tuple.pair "fading" wellKnown_args.fading
                    , Tuple.pair "steamGasRER" wellKnown_args.steamGasRER
                    , Tuple.pair "steamGasRSA" wellKnown_args.steamGasRSA
                    , Tuple.pair
                        "steamLightFuelRER"
                        wellKnown_args.steamLightFuelRER
                    , Tuple.pair
                        "steamLightFuelRSA"
                        wellKnown_args.steamLightFuelRSA
                    , Tuple.pair
                        "steamHeavyFuelRER"
                        wellKnown_args.steamHeavyFuelRER
                    , Tuple.pair
                        "steamHeavyFuelRSA"
                        wellKnown_args.steamHeavyFuelRSA
                    , Tuple.pair "steamCoalRER" wellKnown_args.steamCoalRER
                    , Tuple.pair "steamCoalRSA" wellKnown_args.steamCoalRSA
                    ]
                )
    , process =
        \process_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Process" ]
                    "Process"
                    []
                    (Type.record
                        [ ( "name", Type.string )
                        , ( "info", Type.string )
                        , ( "unit", Type.string )
                        , ( "source", Type.string )
                        , ( "correctif", Type.string )
                        , ( "stepUsage", Type.string )
                        , ( "uuid", Type.namedWith [] "Uuid" [] )
                        , ( "impacts", Type.namedWith [] "Impacts" [] )
                        , ( "heat", Type.namedWith [] "Energy" [] )
                        , ( "elec_pppm", Type.float )
                        , ( "elec", Type.namedWith [] "Energy" [] )
                        , ( "waste", Type.namedWith [] "Mass" [] )
                        , ( "alias"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Alias" [] ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "name" process_args.name
                    , Tuple.pair "info" process_args.info
                    , Tuple.pair "unit" process_args.unit
                    , Tuple.pair "source" process_args.source
                    , Tuple.pair "correctif" process_args.correctif
                    , Tuple.pair "stepUsage" process_args.stepUsage
                    , Tuple.pair "uuid" process_args.uuid
                    , Tuple.pair "impacts" process_args.impacts
                    , Tuple.pair "heat" process_args.heat
                    , Tuple.pair "elec_pppm" process_args.elec_pppm
                    , Tuple.pair "elec" process_args.elec
                    , Tuple.pair "waste" process_args.waste
                    , Tuple.pair "alias" process_args.alias
                    ]
                )
    , uuid =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "Uuid"
                    , annotation = Just (Type.namedWith [] "Uuid" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { uuid :
        Elm.Expression
        -> { uuidTags_0_0 | uuid : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    }
caseOf_ =
    { uuid =
        \uuidExpression uuidTags ->
            Elm.Case.custom
                uuidExpression
                (Type.namedWith [ "Data", "Textile", "Process" ] "Uuid" [])
                [ Elm.Case.branch1
                    "Uuid"
                    ( "string.String", Type.string )
                    uuidTags.uuid
                ]
    }


call_ :
    { encodeUuid : Elm.Expression -> Elm.Expression
    , decodeFromUuid : Elm.Expression -> Elm.Expression
    , uuidToString : Elm.Expression -> Elm.Expression
    , loadWellKnown : Elm.Expression -> Elm.Expression
    , getImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getPrintingProcess : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getEnnoblingHeatProcess :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , getKnittingProcess : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getDyeingProcess : Elm.Expression -> Elm.Expression -> Elm.Expression
    , findByUuid : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { encodeUuid =
        \encodeUuidArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "encodeUuid"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Uuid" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeUuidArg ]
    , decodeFromUuid =
        \decodeFromUuidArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "decodeFromUuid"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.namedWith [] "Process" [] ]
                                )
                            )
                    }
                )
                [ decodeFromUuidArg ]
    , uuidToString =
        \uuidToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "uuidToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Uuid" [] ]
                                Type.string
                            )
                    }
                )
                [ uuidToStringArg ]
    , loadWellKnown =
        \loadWellKnownArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "loadWellKnown"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "WellKnown" []
                                    ]
                                )
                            )
                    }
                )
                [ loadWellKnownArg ]
    , getImpact =
        \getImpactArg getImpactArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "getImpact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Definition" ] "Trigram" []
                                , Type.namedWith [] "Process" []
                                ]
                                (Type.namedWith [ "Unit" ] "Impact" [])
                            )
                    }
                )
                [ getImpactArg, getImpactArg0 ]
    , getPrintingProcess =
        \getPrintingProcessArg getPrintingProcessArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "getPrintingProcess"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Printing" ] "Kind" []
                                , Type.namedWith [] "WellKnown" []
                                ]
                                (Type.namedWith [] "Process" [])
                            )
                    }
                )
                [ getPrintingProcessArg, getPrintingProcessArg0 ]
    , getEnnoblingHeatProcess =
        \getEnnoblingHeatProcessArg getEnnoblingHeatProcessArg0 getEnnoblingHeatProcessArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "getEnnoblingHeatProcess"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "WellKnown" []
                                , Type.namedWith [] "Zone" []
                                , Type.namedWith [] "HeatSource" []
                                ]
                                (Type.namedWith [] "Process" [])
                            )
                    }
                )
                [ getEnnoblingHeatProcessArg
                , getEnnoblingHeatProcessArg0
                , getEnnoblingHeatProcessArg1
                ]
    , getKnittingProcess =
        \getKnittingProcessArg getKnittingProcessArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "getKnittingProcess"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Knitting" []
                                , Type.namedWith [] "WellKnown" []
                                ]
                                (Type.namedWith [] "Process" [])
                            )
                    }
                )
                [ getKnittingProcessArg, getKnittingProcessArg0 ]
    , getDyeingProcess =
        \getDyeingProcessArg getDyeingProcessArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "getDyeingProcess"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "DyeingMedium" []
                                , Type.namedWith [] "WellKnown" []
                                ]
                                (Type.namedWith [] "Process" [])
                            )
                    }
                )
                [ getDyeingProcessArg, getDyeingProcessArg0 ]
    , findByUuid =
        \findByUuidArg findByUuidArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Process" ]
                    , name = "findByUuid"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Uuid" []
                                , Type.list (Type.namedWith [] "Process" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Process" []
                                    ]
                                )
                            )
                    }
                )
                [ findByUuidArg, findByUuidArg0 ]
    }


values_ :
    { encodeUuid : Elm.Expression
    , decodeList : Elm.Expression
    , decodeFromUuid : Elm.Expression
    , uuidToString : Elm.Expression
    , loadWellKnown : Elm.Expression
    , getImpact : Elm.Expression
    , getPrintingProcess : Elm.Expression
    , getEnnoblingHeatProcess : Elm.Expression
    , getKnittingProcess : Elm.Expression
    , getDyeingProcess : Elm.Expression
    , findByUuid : Elm.Expression
    }
values_ =
    { encodeUuid =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "encodeUuid"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Uuid" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeList =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.list (Type.namedWith [] "Process" []) ]
                    )
            }
    , decodeFromUuid =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "decodeFromUuid"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.namedWith [] "Process" [] ]
                        )
                    )
            }
    , uuidToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "uuidToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Uuid" [] ] Type.string)
            }
    , loadWellKnown =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "loadWellKnown"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "WellKnown" [] ]
                        )
                    )
            }
    , getImpact =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Definition" ] "Trigram" []
                        , Type.namedWith [] "Process" []
                        ]
                        (Type.namedWith [ "Unit" ] "Impact" [])
                    )
            }
    , getPrintingProcess =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getPrintingProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Printing" ] "Kind" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
    , getEnnoblingHeatProcess =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getEnnoblingHeatProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "WellKnown" []
                        , Type.namedWith [] "Zone" []
                        , Type.namedWith [] "HeatSource" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
    , getKnittingProcess =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getKnittingProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
    , getDyeingProcess =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "getDyeingProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
    , findByUuid =
        Elm.value
            { importFrom = [ "Data", "Textile", "Process" ]
            , name = "findByUuid"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Uuid" []
                        , Type.list (Type.namedWith [] "Process" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Process" [] ]
                        )
                    )
            }
    }