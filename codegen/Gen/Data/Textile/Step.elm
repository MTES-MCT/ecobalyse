module Gen.Data.Textile.Step exposing (airTransportRatioToString, annotation_, call_, computeTransports, create, displayLabel, encode, getInputSurface, getOutputSurface, initMass, make_, makingWasteToString, moduleName_, qualityToString, reparabilityToString, surfaceMassToString, updateFromInputs, updateWaste, values_, yarnSizeToString)

{-| 
@docs moduleName_, encode, yarnSizeToString, makingWasteToString, surfaceMassToString, reparabilityToString, qualityToString, airTransportRatioToString, updateWaste, initMass, updateFromInputs, getOutputSurface, getInputSurface, computeTransports, displayLabel, create, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Step" ]


{-| encode: Step -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Step" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| yarnSizeToString: Unit.YarnSize -> String -}
yarnSizeToString : Elm.Expression -> Elm.Expression
yarnSizeToString yarnSizeToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "yarnSizeToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                        Type.string
                    )
            }
        )
        [ yarnSizeToStringArg ]


{-| makingWasteToString: Split -> String -}
makingWasteToString : Elm.Expression -> Elm.Expression
makingWasteToString makingWasteToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "makingWasteToString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
        )
        [ makingWasteToStringArg ]


{-| surfaceMassToString: Unit.SurfaceMass -> String -}
surfaceMassToString : Elm.Expression -> Elm.Expression
surfaceMassToString surfaceMassToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "surfaceMassToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "SurfaceMass" [] ]
                        Type.string
                    )
            }
        )
        [ surfaceMassToStringArg ]


{-| reparabilityToString: Unit.Reparability -> String -}
reparabilityToString : Elm.Expression -> Elm.Expression
reparabilityToString reparabilityToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "reparabilityToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                        Type.string
                    )
            }
        )
        [ reparabilityToStringArg ]


{-| qualityToString: Unit.Quality -> String -}
qualityToString : Elm.Expression -> Elm.Expression
qualityToString qualityToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "qualityToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Quality" [] ]
                        Type.string
                    )
            }
        )
        [ qualityToStringArg ]


{-| airTransportRatioToString: Split -> String -}
airTransportRatioToString : Elm.Expression -> Elm.Expression
airTransportRatioToString airTransportRatioToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "airTransportRatioToString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
        )
        [ airTransportRatioToStringArg ]


{-| updateWaste: Mass -> Mass -> Step -> Step -}
updateWaste :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateWaste updateWasteArg updateWasteArg0 updateWasteArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "updateWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
        )
        [ updateWasteArg, updateWasteArg0, updateWasteArg1 ]


{-| initMass: Mass -> Step -> Step -}
initMass : Elm.Expression -> Elm.Expression -> Elm.Expression
initMass initMassArg initMassArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "initMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
        )
        [ initMassArg, initMassArg0 ]


{-| updateFromInputs: Db -> Inputs -> Step -> Step -}
updateFromInputs :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateFromInputs updateFromInputsArg updateFromInputsArg0 updateFromInputsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "updateFromInputs"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Inputs" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
        )
        [ updateFromInputsArg, updateFromInputsArg0, updateFromInputsArg1 ]


{-| getOutputSurface: Inputs -> Step -> Area -}
getOutputSurface : Elm.Expression -> Elm.Expression -> Elm.Expression
getOutputSurface getOutputSurfaceArg getOutputSurfaceArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "getOutputSurface"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Area" [])
                    )
            }
        )
        [ getOutputSurfaceArg, getOutputSurfaceArg0 ]


{-| getInputSurface: Inputs -> Step -> Area -}
getInputSurface : Elm.Expression -> Elm.Expression -> Elm.Expression
getInputSurface getInputSurfaceArg getInputSurfaceArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "getInputSurface"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Area" [])
                    )
            }
        )
        [ getInputSurfaceArg, getInputSurfaceArg0 ]


{-| {-| Computes step transport distances and impact regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/ecobalyse/methodologie/transport>

-}

computeTransports: Db -> Step -> Step -> Step
-}
computeTransports :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
computeTransports computeTransportsArg computeTransportsArg0 computeTransportsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "computeTransports"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Step" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
        )
        [ computeTransportsArg, computeTransportsArg0, computeTransportsArg1 ]


{-| displayLabel: { knitted : Bool, fadable : Bool } -> Label -> String -}
displayLabel :
    { knitted : Bool, fadable : Bool } -> Elm.Expression -> Elm.Expression
displayLabel displayLabelArg displayLabelArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "displayLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "knitted", Type.bool )
                            , ( "fadable", Type.bool )
                            ]
                        , Type.namedWith [] "Label" []
                        ]
                        Type.string
                    )
            }
        )
        [ Elm.record
            [ Tuple.pair "knitted" (Elm.bool displayLabelArg.knitted)
            , Tuple.pair "fadable" (Elm.bool displayLabelArg.fadable)
            ]
        , displayLabelArg0
        ]


{-| create: { label : Label, editable : Bool, country : Country, enabled : Bool } -> Step -}
create :
    { label : Elm.Expression
    , editable : Bool
    , country : Elm.Expression
    , enabled : Bool
    }
    -> Elm.Expression
create createArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "create"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "label", Type.namedWith [] "Label" [] )
                            , ( "editable", Type.bool )
                            , ( "country", Type.namedWith [] "Country" [] )
                            , ( "enabled", Type.bool )
                            ]
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
        )
        [ Elm.record
            [ Tuple.pair "label" createArg.label
            , Tuple.pair "editable" (Elm.bool createArg.editable)
            , Tuple.pair "country" createArg.country
            , Tuple.pair "enabled" (Elm.bool createArg.enabled)
            ]
        ]


annotation_ : { step : Type.Annotation }
annotation_ =
    { step =
        Type.alias
            moduleName_
            "Step"
            []
            (Type.record
                [ ( "label", Type.namedWith [] "Label" [] )
                , ( "enabled", Type.bool )
                , ( "country", Type.namedWith [] "Country" [] )
                , ( "editable", Type.bool )
                , ( "inputMass", Type.namedWith [] "Mass" [] )
                , ( "outputMass", Type.namedWith [] "Mass" [] )
                , ( "waste", Type.namedWith [] "Mass" [] )
                , ( "transport", Type.namedWith [] "Transport" [] )
                , ( "impacts", Type.namedWith [] "Impacts" [] )
                , ( "heat", Type.namedWith [] "Energy" [] )
                , ( "kwh", Type.namedWith [] "Energy" [] )
                , ( "processInfo", Type.namedWith [] "ProcessInfo" [] )
                , ( "airTransportRatio", Type.namedWith [] "Split" [] )
                , ( "quality", Type.namedWith [ "Unit" ] "Quality" [] )
                , ( "reparability"
                  , Type.namedWith [ "Unit" ] "Reparability" []
                  )
                , ( "makingComplexity"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "MakingComplexity" [] ]
                  )
                , ( "makingWaste"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Split" [] ]
                  )
                , ( "picking"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "PickPerMeter" [] ]
                  )
                , ( "threadDensity"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "ThreadDensity" [] ]
                  )
                , ( "yarnSize"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                  )
                , ( "surfaceMass"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "SurfaceMass" [] ]
                  )
                , ( "knittingProcess"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "Knitting" [] ]
                  )
                , ( "dyeingMedium"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "DyeingMedium" [] ]
                  )
                , ( "printing"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "Printing" [] ]
                  )
                ]
            )
    }


make_ :
    { step :
        { label : Elm.Expression
        , enabled : Elm.Expression
        , country : Elm.Expression
        , editable : Elm.Expression
        , inputMass : Elm.Expression
        , outputMass : Elm.Expression
        , waste : Elm.Expression
        , transport : Elm.Expression
        , impacts : Elm.Expression
        , heat : Elm.Expression
        , kwh : Elm.Expression
        , processInfo : Elm.Expression
        , airTransportRatio : Elm.Expression
        , quality : Elm.Expression
        , reparability : Elm.Expression
        , makingComplexity : Elm.Expression
        , makingWaste : Elm.Expression
        , picking : Elm.Expression
        , threadDensity : Elm.Expression
        , yarnSize : Elm.Expression
        , surfaceMass : Elm.Expression
        , knittingProcess : Elm.Expression
        , dyeingMedium : Elm.Expression
        , printing : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { step =
        \step_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Step" ]
                    "Step"
                    []
                    (Type.record
                        [ ( "label", Type.namedWith [] "Label" [] )
                        , ( "enabled", Type.bool )
                        , ( "country", Type.namedWith [] "Country" [] )
                        , ( "editable", Type.bool )
                        , ( "inputMass", Type.namedWith [] "Mass" [] )
                        , ( "outputMass", Type.namedWith [] "Mass" [] )
                        , ( "waste", Type.namedWith [] "Mass" [] )
                        , ( "transport", Type.namedWith [] "Transport" [] )
                        , ( "impacts", Type.namedWith [] "Impacts" [] )
                        , ( "heat", Type.namedWith [] "Energy" [] )
                        , ( "kwh", Type.namedWith [] "Energy" [] )
                        , ( "processInfo", Type.namedWith [] "ProcessInfo" [] )
                        , ( "airTransportRatio", Type.namedWith [] "Split" [] )
                        , ( "quality", Type.namedWith [ "Unit" ] "Quality" [] )
                        , ( "reparability"
                          , Type.namedWith [ "Unit" ] "Reparability" []
                          )
                        , ( "makingComplexity"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "MakingComplexity" [] ]
                          )
                        , ( "makingWaste"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Split" [] ]
                          )
                        , ( "picking"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "PickPerMeter" [] ]
                          )
                        , ( "threadDensity"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "ThreadDensity" [] ]
                          )
                        , ( "yarnSize"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                          )
                        , ( "surfaceMass"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "SurfaceMass" [] ]
                          )
                        , ( "knittingProcess"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Knitting" [] ]
                          )
                        , ( "dyeingMedium"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "DyeingMedium" [] ]
                          )
                        , ( "printing"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Printing" [] ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "label" step_args.label
                    , Tuple.pair "enabled" step_args.enabled
                    , Tuple.pair "country" step_args.country
                    , Tuple.pair "editable" step_args.editable
                    , Tuple.pair "inputMass" step_args.inputMass
                    , Tuple.pair "outputMass" step_args.outputMass
                    , Tuple.pair "waste" step_args.waste
                    , Tuple.pair "transport" step_args.transport
                    , Tuple.pair "impacts" step_args.impacts
                    , Tuple.pair "heat" step_args.heat
                    , Tuple.pair "kwh" step_args.kwh
                    , Tuple.pair "processInfo" step_args.processInfo
                    , Tuple.pair "airTransportRatio" step_args.airTransportRatio
                    , Tuple.pair "quality" step_args.quality
                    , Tuple.pair "reparability" step_args.reparability
                    , Tuple.pair "makingComplexity" step_args.makingComplexity
                    , Tuple.pair "makingWaste" step_args.makingWaste
                    , Tuple.pair "picking" step_args.picking
                    , Tuple.pair "threadDensity" step_args.threadDensity
                    , Tuple.pair "yarnSize" step_args.yarnSize
                    , Tuple.pair "surfaceMass" step_args.surfaceMass
                    , Tuple.pair "knittingProcess" step_args.knittingProcess
                    , Tuple.pair "dyeingMedium" step_args.dyeingMedium
                    , Tuple.pair "printing" step_args.printing
                    ]
                )
    }


call_ :
    { encode : Elm.Expression -> Elm.Expression
    , yarnSizeToString : Elm.Expression -> Elm.Expression
    , makingWasteToString : Elm.Expression -> Elm.Expression
    , surfaceMassToString : Elm.Expression -> Elm.Expression
    , reparabilityToString : Elm.Expression -> Elm.Expression
    , qualityToString : Elm.Expression -> Elm.Expression
    , airTransportRatioToString : Elm.Expression -> Elm.Expression
    , updateWaste :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , initMass : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateFromInputs :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , getOutputSurface : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getInputSurface : Elm.Expression -> Elm.Expression -> Elm.Expression
    , computeTransports :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , displayLabel : Elm.Expression -> Elm.Expression -> Elm.Expression
    , create : Elm.Expression -> Elm.Expression
    }
call_ =
    { encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Step" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , yarnSizeToString =
        \yarnSizeToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "yarnSizeToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                                Type.string
                            )
                    }
                )
                [ yarnSizeToStringArg ]
    , makingWasteToString =
        \makingWasteToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "makingWasteToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                Type.string
                            )
                    }
                )
                [ makingWasteToStringArg ]
    , surfaceMassToString =
        \surfaceMassToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "surfaceMassToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "SurfaceMass" [] ]
                                Type.string
                            )
                    }
                )
                [ surfaceMassToStringArg ]
    , reparabilityToString =
        \reparabilityToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "reparabilityToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                                Type.string
                            )
                    }
                )
                [ reparabilityToStringArg ]
    , qualityToString =
        \qualityToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "qualityToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "Quality" [] ]
                                Type.string
                            )
                    }
                )
                [ qualityToStringArg ]
    , airTransportRatioToString =
        \airTransportRatioToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "airTransportRatioToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                Type.string
                            )
                    }
                )
                [ airTransportRatioToStringArg ]
    , updateWaste =
        \updateWasteArg updateWasteArg0 updateWasteArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "updateWaste"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Step" []
                                ]
                                (Type.namedWith [] "Step" [])
                            )
                    }
                )
                [ updateWasteArg, updateWasteArg0, updateWasteArg1 ]
    , initMass =
        \initMassArg initMassArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "initMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Step" []
                                ]
                                (Type.namedWith [] "Step" [])
                            )
                    }
                )
                [ initMassArg, initMassArg0 ]
    , updateFromInputs =
        \updateFromInputsArg updateFromInputsArg0 updateFromInputsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "updateFromInputs"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Inputs" []
                                , Type.namedWith [] "Step" []
                                ]
                                (Type.namedWith [] "Step" [])
                            )
                    }
                )
                [ updateFromInputsArg
                , updateFromInputsArg0
                , updateFromInputsArg1
                ]
    , getOutputSurface =
        \getOutputSurfaceArg getOutputSurfaceArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "getOutputSurface"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" []
                                , Type.namedWith [] "Step" []
                                ]
                                (Type.namedWith [] "Area" [])
                            )
                    }
                )
                [ getOutputSurfaceArg, getOutputSurfaceArg0 ]
    , getInputSurface =
        \getInputSurfaceArg getInputSurfaceArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "getInputSurface"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" []
                                , Type.namedWith [] "Step" []
                                ]
                                (Type.namedWith [] "Area" [])
                            )
                    }
                )
                [ getInputSurfaceArg, getInputSurfaceArg0 ]
    , computeTransports =
        \computeTransportsArg computeTransportsArg0 computeTransportsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "computeTransports"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Step" []
                                , Type.namedWith [] "Step" []
                                ]
                                (Type.namedWith [] "Step" [])
                            )
                    }
                )
                [ computeTransportsArg
                , computeTransportsArg0
                , computeTransportsArg1
                ]
    , displayLabel =
        \displayLabelArg displayLabelArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "displayLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.record
                                    [ ( "knitted", Type.bool )
                                    , ( "fadable", Type.bool )
                                    ]
                                , Type.namedWith [] "Label" []
                                ]
                                Type.string
                            )
                    }
                )
                [ displayLabelArg, displayLabelArg0 ]
    , create =
        \createArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step" ]
                    , name = "create"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.record
                                    [ ( "label", Type.namedWith [] "Label" [] )
                                    , ( "editable", Type.bool )
                                    , ( "country"
                                      , Type.namedWith [] "Country" []
                                      )
                                    , ( "enabled", Type.bool )
                                    ]
                                ]
                                (Type.namedWith [] "Step" [])
                            )
                    }
                )
                [ createArg ]
    }


values_ :
    { encode : Elm.Expression
    , yarnSizeToString : Elm.Expression
    , makingWasteToString : Elm.Expression
    , surfaceMassToString : Elm.Expression
    , reparabilityToString : Elm.Expression
    , qualityToString : Elm.Expression
    , airTransportRatioToString : Elm.Expression
    , updateWaste : Elm.Expression
    , initMass : Elm.Expression
    , updateFromInputs : Elm.Expression
    , getOutputSurface : Elm.Expression
    , getInputSurface : Elm.Expression
    , computeTransports : Elm.Expression
    , displayLabel : Elm.Expression
    , create : Elm.Expression
    }
values_ =
    { encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Step" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , yarnSizeToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "yarnSizeToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                        Type.string
                    )
            }
    , makingWasteToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "makingWasteToString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
    , surfaceMassToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "surfaceMassToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "SurfaceMass" [] ]
                        Type.string
                    )
            }
    , reparabilityToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "reparabilityToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                        Type.string
                    )
            }
    , qualityToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "qualityToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "Quality" [] ]
                        Type.string
                    )
            }
    , airTransportRatioToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "airTransportRatioToString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
    , updateWaste =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "updateWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
    , initMass =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "initMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
    , updateFromInputs =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "updateFromInputs"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Inputs" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
    , getOutputSurface =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "getOutputSurface"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Area" [])
                    )
            }
    , getInputSurface =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "getInputSurface"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Area" [])
                    )
            }
    , computeTransports =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "computeTransports"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Step" []
                        , Type.namedWith [] "Step" []
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
    , displayLabel =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "displayLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "knitted", Type.bool )
                            , ( "fadable", Type.bool )
                            ]
                        , Type.namedWith [] "Label" []
                        ]
                        Type.string
                    )
            }
    , create =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step" ]
            , name = "create"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "label", Type.namedWith [] "Label" [] )
                            , ( "editable", Type.bool )
                            , ( "country", Type.namedWith [] "Country" [] )
                            , ( "enabled", Type.bool )
                            ]
                        ]
                        (Type.namedWith [] "Step" [])
                    )
            }
    }