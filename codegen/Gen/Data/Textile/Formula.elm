module Gen.Data.Textile.Formula exposing (call_, computePicking, computeThreadDensity, dyeingImpacts, endOfLifeImpacts, finishingImpacts, genericWaste, knittingImpacts, makingImpacts, makingWaste, moduleName_, printingImpacts, pureMaterialImpacts, recycledMaterialImpacts, spinningImpacts, transportRatio, useImpacts, values_, weavingImpacts)

{-| 
@docs moduleName_, transportRatio, endOfLifeImpacts, useImpacts, computePicking, computeThreadDensity, weavingImpacts, knittingImpacts, makingImpacts, finishingImpacts, printingImpacts, dyeingImpacts, spinningImpacts, recycledMaterialImpacts, pureMaterialImpacts, makingWaste, genericWaste, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Formula" ]


{-| transportRatio: Split -> Transport -> Transport -}
transportRatio : Elm.Expression -> Elm.Expression -> Elm.Expression
transportRatio transportRatioArg transportRatioArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "transportRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" []
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ transportRatioArg, transportRatioArg0 ]


{-| endOfLifeImpacts: 
    Impacts
    -> { volume : Volume
    , passengerCar : Process
    , endOfLife : Process
    , countryElecProcess : Process
    , heatProcess : Process
    }
    -> Mass
    -> { kwh : Energy, heat : Energy, impacts : Impacts }
-}
endOfLifeImpacts :
    Elm.Expression
    -> { volume : Elm.Expression
    , passengerCar : Elm.Expression
    , endOfLife : Elm.Expression
    , countryElecProcess : Elm.Expression
    , heatProcess : Elm.Expression
    }
    -> Elm.Expression
    -> Elm.Expression
endOfLifeImpacts endOfLifeImpactsArg endOfLifeImpactsArg0 endOfLifeImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "endOfLifeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "volume", Type.namedWith [] "Volume" [] )
                            , ( "passengerCar", Type.namedWith [] "Process" [] )
                            , ( "endOfLife", Type.namedWith [] "Process" [] )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "heatProcess", Type.namedWith [] "Process" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ endOfLifeImpactsArg
        , Elm.record
            [ Tuple.pair "volume" endOfLifeImpactsArg0.volume
            , Tuple.pair "passengerCar" endOfLifeImpactsArg0.passengerCar
            , Tuple.pair "endOfLife" endOfLifeImpactsArg0.endOfLife
            , Tuple.pair
                "countryElecProcess"
                endOfLifeImpactsArg0.countryElecProcess
            , Tuple.pair "heatProcess" endOfLifeImpactsArg0.heatProcess
            ]
        , endOfLifeImpactsArg1
        ]


{-| useImpacts: 
    Impacts
    -> { useNbCycles : Int
    , ironingProcess : Process
    , nonIroningProcess : Process
    , countryElecProcess : Process
    }
    -> Mass
    -> { kwh : Energy, impacts : Impacts }
-}
useImpacts :
    Elm.Expression
    -> { useNbCycles : Int
    , ironingProcess : Elm.Expression
    , nonIroningProcess : Elm.Expression
    , countryElecProcess : Elm.Expression
    }
    -> Elm.Expression
    -> Elm.Expression
useImpacts useImpactsArg useImpactsArg0 useImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "useImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "useNbCycles", Type.int )
                            , ( "ironingProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "nonIroningProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ useImpactsArg
        , Elm.record
            [ Tuple.pair "useNbCycles" (Elm.int useImpactsArg0.useNbCycles)
            , Tuple.pair "ironingProcess" useImpactsArg0.ironingProcess
            , Tuple.pair "nonIroningProcess" useImpactsArg0.nonIroningProcess
            , Tuple.pair "countryElecProcess" useImpactsArg0.countryElecProcess
            ]
        , useImpactsArg1
        ]


{-| computePicking: Unit.ThreadDensity -> Area -> Unit.PickPerMeter -}
computePicking : Elm.Expression -> Elm.Expression -> Elm.Expression
computePicking computePickingArg computePickingArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "computePicking"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "ThreadDensity" []
                        , Type.namedWith [] "Area" []
                        ]
                        (Type.namedWith [ "Unit" ] "PickPerMeter" [])
                    )
            }
        )
        [ computePickingArg, computePickingArg0 ]


{-| computeThreadDensity: Unit.SurfaceMass -> Unit.YarnSize -> Unit.ThreadDensity -}
computeThreadDensity : Elm.Expression -> Elm.Expression -> Elm.Expression
computeThreadDensity computeThreadDensityArg computeThreadDensityArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "computeThreadDensity"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "SurfaceMass" []
                        , Type.namedWith [ "Unit" ] "YarnSize" []
                        ]
                        (Type.namedWith [ "Unit" ] "ThreadDensity" [])
                    )
            }
        )
        [ computeThreadDensityArg, computeThreadDensityArg0 ]


{-| weavingImpacts: 
    Impacts
    -> { countryElecProcess : Process
    , outputMass : Mass
    , pickingElec : Float
    , surfaceMass : Unit.SurfaceMass
    , yarnSize : Unit.YarnSize
    }
    -> { kwh : Energy
    , threadDensity : Maybe Unit.ThreadDensity
    , picking : Maybe Unit.PickPerMeter
    , impacts : Impacts
    }
-}
weavingImpacts :
    Elm.Expression
    -> { countryElecProcess : Elm.Expression
    , outputMass : Elm.Expression
    , pickingElec : Float
    , surfaceMass : Elm.Expression
    , yarnSize : Elm.Expression
    }
    -> Elm.Expression
weavingImpacts weavingImpactsArg weavingImpactsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "weavingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "outputMass", Type.namedWith [] "Mass" [] )
                            , ( "pickingElec", Type.float )
                            , ( "surfaceMass"
                              , Type.namedWith [ "Unit" ] "SurfaceMass" []
                              )
                            , ( "yarnSize"
                              , Type.namedWith [ "Unit" ] "YarnSize" []
                              )
                            ]
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "threadDensity"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "ThreadDensity"
                                        []
                                    ]
                              )
                            , ( "picking"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "PickPerMeter"
                                        []
                                    ]
                              )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ weavingImpactsArg
        , Elm.record
            [ Tuple.pair
                "countryElecProcess"
                weavingImpactsArg0.countryElecProcess
            , Tuple.pair "outputMass" weavingImpactsArg0.outputMass
            , Tuple.pair
                "pickingElec"
                (Elm.float weavingImpactsArg0.pickingElec)
            , Tuple.pair "surfaceMass" weavingImpactsArg0.surfaceMass
            , Tuple.pair "yarnSize" weavingImpactsArg0.yarnSize
            ]
        ]


{-| knittingImpacts: 
    Impacts
    -> { elec : Energy, countryElecProcess : Process }
    -> Mass
    -> { kwh : Energy
    , threadDensity : Maybe Unit.ThreadDensity
    , picking : Maybe Unit.PickPerMeter
    , impacts : Impacts
    }
-}
knittingImpacts :
    Elm.Expression
    -> { elec : Elm.Expression, countryElecProcess : Elm.Expression }
    -> Elm.Expression
    -> Elm.Expression
knittingImpacts knittingImpactsArg knittingImpactsArg0 knittingImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "knittingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "elec", Type.namedWith [] "Energy" [] )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "threadDensity"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "ThreadDensity"
                                        []
                                    ]
                              )
                            , ( "picking"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "PickPerMeter"
                                        []
                                    ]
                              )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ knittingImpactsArg
        , Elm.record
            [ Tuple.pair "elec" knittingImpactsArg0.elec
            , Tuple.pair
                "countryElecProcess"
                knittingImpactsArg0.countryElecProcess
            ]
        , knittingImpactsArg1
        ]


{-| makingImpacts: 
    Impacts
    -> { makingComplexity : MakingComplexity
    , fadingProcess : Maybe Process
    , countryElecProcess : Process
    , countryHeatProcess : Process
    }
    -> Mass
    -> { kwh : Energy, heat : Energy, impacts : Impacts }
-}
makingImpacts :
    Elm.Expression
    -> { makingComplexity : Elm.Expression
    , fadingProcess : Elm.Expression
    , countryElecProcess : Elm.Expression
    , countryHeatProcess : Elm.Expression
    }
    -> Elm.Expression
    -> Elm.Expression
makingImpacts makingImpactsArg makingImpactsArg0 makingImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "makingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "makingComplexity"
                              , Type.namedWith [] "MakingComplexity" []
                              )
                            , ( "fadingProcess"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Process" [] ]
                              )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "countryHeatProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ makingImpactsArg
        , Elm.record
            [ Tuple.pair "makingComplexity" makingImpactsArg0.makingComplexity
            , Tuple.pair "fadingProcess" makingImpactsArg0.fadingProcess
            , Tuple.pair
                "countryElecProcess"
                makingImpactsArg0.countryElecProcess
            , Tuple.pair
                "countryHeatProcess"
                makingImpactsArg0.countryHeatProcess
            ]
        , makingImpactsArg1
        ]


{-| finishingImpacts: 
    Impacts
    -> { finishingProcess : Process, heatProcess : Process, elecProcess : Process }
    -> Mass
    -> { heat : Energy, kwh : Energy, impacts : Impacts }
-}
finishingImpacts :
    Elm.Expression
    -> { finishingProcess : Elm.Expression
    , heatProcess : Elm.Expression
    , elecProcess : Elm.Expression
    }
    -> Elm.Expression
    -> Elm.Expression
finishingImpacts finishingImpactsArg finishingImpactsArg0 finishingImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "finishingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "finishingProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "heatProcess", Type.namedWith [] "Process" [] )
                            , ( "elecProcess", Type.namedWith [] "Process" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ finishingImpactsArg
        , Elm.record
            [ Tuple.pair
                "finishingProcess"
                finishingImpactsArg0.finishingProcess
            , Tuple.pair "heatProcess" finishingImpactsArg0.heatProcess
            , Tuple.pair "elecProcess" finishingImpactsArg0.elecProcess
            ]
        , finishingImpactsArg1
        ]


{-| printingImpacts: 
    Impacts
    -> { printingProcess : Process
    , heatProcess : Process
    , elecProcess : Process
    , surfaceMass : Unit.SurfaceMass
    , ratio : Split
    }
    -> Mass
    -> { heat : Energy, kwh : Energy, impacts : Impacts }
-}
printingImpacts :
    Elm.Expression
    -> { printingProcess : Elm.Expression
    , heatProcess : Elm.Expression
    , elecProcess : Elm.Expression
    , surfaceMass : Elm.Expression
    , ratio : Elm.Expression
    }
    -> Elm.Expression
    -> Elm.Expression
printingImpacts printingImpactsArg printingImpactsArg0 printingImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "printingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "printingProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "heatProcess", Type.namedWith [] "Process" [] )
                            , ( "elecProcess", Type.namedWith [] "Process" [] )
                            , ( "surfaceMass"
                              , Type.namedWith [ "Unit" ] "SurfaceMass" []
                              )
                            , ( "ratio", Type.namedWith [] "Split" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ printingImpactsArg
        , Elm.record
            [ Tuple.pair "printingProcess" printingImpactsArg0.printingProcess
            , Tuple.pair "heatProcess" printingImpactsArg0.heatProcess
            , Tuple.pair "elecProcess" printingImpactsArg0.elecProcess
            , Tuple.pair "surfaceMass" printingImpactsArg0.surfaceMass
            , Tuple.pair "ratio" printingImpactsArg0.ratio
            ]
        , printingImpactsArg1
        ]


{-| dyeingImpacts: 
    Impacts
    -> Process
    -> Process
    -> Process
    -> Mass
    -> { heat : Energy, kwh : Energy, impacts : Impacts }
-}
dyeingImpacts :
    Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
dyeingImpacts dyeingImpactsArg dyeingImpactsArg0 dyeingImpactsArg1 dyeingImpactsArg2 dyeingImpactsArg3 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "dyeingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ dyeingImpactsArg
        , dyeingImpactsArg0
        , dyeingImpactsArg1
        , dyeingImpactsArg2
        , dyeingImpactsArg3
        ]


{-| spinningImpacts: 
    Impacts
    -> { spinningProcess : Process, countryElecProcess : Process }
    -> Mass
    -> { kwh : Energy, impacts : Impacts }
-}
spinningImpacts :
    Elm.Expression
    -> { spinningProcess : Elm.Expression, countryElecProcess : Elm.Expression }
    -> Elm.Expression
    -> Elm.Expression
spinningImpacts spinningImpactsArg spinningImpactsArg0 spinningImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "spinningImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "spinningProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
        )
        [ spinningImpactsArg
        , Elm.record
            [ Tuple.pair "spinningProcess" spinningImpactsArg0.spinningProcess
            , Tuple.pair
                "countryElecProcess"
                spinningImpactsArg0.countryElecProcess
            ]
        , spinningImpactsArg1
        ]


{-| recycledMaterialImpacts: 
    Impacts
    -> { recycledProcess : Process
    , nonRecycledProcess : Process
    , cffData : CFFData
    }
    -> Mass
    -> Impacts
-}
recycledMaterialImpacts :
    Elm.Expression
    -> { recycledProcess : Elm.Expression
    , nonRecycledProcess : Elm.Expression
    , cffData : Elm.Expression
    }
    -> Elm.Expression
    -> Elm.Expression
recycledMaterialImpacts recycledMaterialImpactsArg recycledMaterialImpactsArg0 recycledMaterialImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "recycledMaterialImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "recycledProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "nonRecycledProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "cffData", Type.namedWith [] "CFFData" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ recycledMaterialImpactsArg
        , Elm.record
            [ Tuple.pair
                "recycledProcess"
                recycledMaterialImpactsArg0.recycledProcess
            , Tuple.pair
                "nonRecycledProcess"
                recycledMaterialImpactsArg0.nonRecycledProcess
            , Tuple.pair "cffData" recycledMaterialImpactsArg0.cffData
            ]
        , recycledMaterialImpactsArg1
        ]


{-| pureMaterialImpacts: Impacts -> Process -> Mass -> Impacts -}
pureMaterialImpacts :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
pureMaterialImpacts pureMaterialImpactsArg pureMaterialImpactsArg0 pureMaterialImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "pureMaterialImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ pureMaterialImpactsArg
        , pureMaterialImpactsArg0
        , pureMaterialImpactsArg1
        ]


{-| {-| Compute source material mass needed and waste generated by the operation, according to
material & product waste data.
-}

makingWaste: Split -> Mass -> { waste : Mass, mass : Mass }
-}
makingWaste : Elm.Expression -> Elm.Expression -> Elm.Expression
makingWaste makingWasteArg makingWasteArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "makingWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "waste", Type.namedWith [] "Mass" [] )
                            , ( "mass", Type.namedWith [] "Mass" [] )
                            ]
                        )
                    )
            }
        )
        [ makingWasteArg, makingWasteArg0 ]


{-| {-| Compute source mass needed and waste generated by the operation.
-}

genericWaste: Mass -> Mass -> { waste : Mass, mass : Mass }
-}
genericWaste : Elm.Expression -> Elm.Expression -> Elm.Expression
genericWaste genericWasteArg genericWasteArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "genericWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "waste", Type.namedWith [] "Mass" [] )
                            , ( "mass", Type.namedWith [] "Mass" [] )
                            ]
                        )
                    )
            }
        )
        [ genericWasteArg, genericWasteArg0 ]


call_ :
    { transportRatio : Elm.Expression -> Elm.Expression -> Elm.Expression
    , endOfLifeImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , useImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , computePicking : Elm.Expression -> Elm.Expression -> Elm.Expression
    , computeThreadDensity : Elm.Expression -> Elm.Expression -> Elm.Expression
    , weavingImpacts : Elm.Expression -> Elm.Expression -> Elm.Expression
    , knittingImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , makingImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , finishingImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , printingImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , dyeingImpacts :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , spinningImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , recycledMaterialImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , pureMaterialImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , makingWaste : Elm.Expression -> Elm.Expression -> Elm.Expression
    , genericWaste : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { transportRatio =
        \transportRatioArg transportRatioArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "transportRatio"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" []
                                , Type.namedWith [] "Transport" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ transportRatioArg, transportRatioArg0 ]
    , endOfLifeImpacts =
        \endOfLifeImpactsArg endOfLifeImpactsArg0 endOfLifeImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "endOfLifeImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "volume"
                                      , Type.namedWith [] "Volume" []
                                      )
                                    , ( "passengerCar"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "endOfLife"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "countryElecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "heatProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "heat", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ endOfLifeImpactsArg
                , endOfLifeImpactsArg0
                , endOfLifeImpactsArg1
                ]
    , useImpacts =
        \useImpactsArg useImpactsArg0 useImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "useImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "useNbCycles", Type.int )
                                    , ( "ironingProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "nonIroningProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "countryElecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ useImpactsArg, useImpactsArg0, useImpactsArg1 ]
    , computePicking =
        \computePickingArg computePickingArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "computePicking"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "ThreadDensity" []
                                , Type.namedWith [] "Area" []
                                ]
                                (Type.namedWith [ "Unit" ] "PickPerMeter" [])
                            )
                    }
                )
                [ computePickingArg, computePickingArg0 ]
    , computeThreadDensity =
        \computeThreadDensityArg computeThreadDensityArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "computeThreadDensity"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Unit" ] "SurfaceMass" []
                                , Type.namedWith [ "Unit" ] "YarnSize" []
                                ]
                                (Type.namedWith [ "Unit" ] "ThreadDensity" [])
                            )
                    }
                )
                [ computeThreadDensityArg, computeThreadDensityArg0 ]
    , weavingImpacts =
        \weavingImpactsArg weavingImpactsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "weavingImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "countryElecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "outputMass"
                                      , Type.namedWith [] "Mass" []
                                      )
                                    , ( "pickingElec", Type.float )
                                    , ( "surfaceMass"
                                      , Type.namedWith
                                            [ "Unit" ]
                                            "SurfaceMass"
                                            []
                                      )
                                    , ( "yarnSize"
                                      , Type.namedWith [ "Unit" ] "YarnSize" []
                                      )
                                    ]
                                ]
                                (Type.record
                                    [ ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "threadDensity"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith
                                                [ "Unit" ]
                                                "ThreadDensity"
                                                []
                                            ]
                                      )
                                    , ( "picking"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith
                                                [ "Unit" ]
                                                "PickPerMeter"
                                                []
                                            ]
                                      )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ weavingImpactsArg, weavingImpactsArg0 ]
    , knittingImpacts =
        \knittingImpactsArg knittingImpactsArg0 knittingImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "knittingImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "elec", Type.namedWith [] "Energy" [] )
                                    , ( "countryElecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "threadDensity"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith
                                                [ "Unit" ]
                                                "ThreadDensity"
                                                []
                                            ]
                                      )
                                    , ( "picking"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith
                                                [ "Unit" ]
                                                "PickPerMeter"
                                                []
                                            ]
                                      )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ knittingImpactsArg, knittingImpactsArg0, knittingImpactsArg1 ]
    , makingImpacts =
        \makingImpactsArg makingImpactsArg0 makingImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "makingImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "makingComplexity"
                                      , Type.namedWith [] "MakingComplexity" []
                                      )
                                    , ( "fadingProcess"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith [] "Process" [] ]
                                      )
                                    , ( "countryElecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "countryHeatProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "heat", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ makingImpactsArg, makingImpactsArg0, makingImpactsArg1 ]
    , finishingImpacts =
        \finishingImpactsArg finishingImpactsArg0 finishingImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "finishingImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "finishingProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "heatProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "elecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "heat", Type.namedWith [] "Energy" [] )
                                    , ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ finishingImpactsArg
                , finishingImpactsArg0
                , finishingImpactsArg1
                ]
    , printingImpacts =
        \printingImpactsArg printingImpactsArg0 printingImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "printingImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "printingProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "heatProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "elecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "surfaceMass"
                                      , Type.namedWith
                                            [ "Unit" ]
                                            "SurfaceMass"
                                            []
                                      )
                                    , ( "ratio", Type.namedWith [] "Split" [] )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "heat", Type.namedWith [] "Energy" [] )
                                    , ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ printingImpactsArg, printingImpactsArg0, printingImpactsArg1 ]
    , dyeingImpacts =
        \dyeingImpactsArg dyeingImpactsArg0 dyeingImpactsArg1 dyeingImpactsArg2 dyeingImpactsArg3 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "dyeingImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.namedWith [] "Process" []
                                , Type.namedWith [] "Process" []
                                , Type.namedWith [] "Process" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "heat", Type.namedWith [] "Energy" [] )
                                    , ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ dyeingImpactsArg
                , dyeingImpactsArg0
                , dyeingImpactsArg1
                , dyeingImpactsArg2
                , dyeingImpactsArg3
                ]
    , spinningImpacts =
        \spinningImpactsArg spinningImpactsArg0 spinningImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "spinningImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "spinningProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "countryElecProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "kwh", Type.namedWith [] "Energy" [] )
                                    , ( "impacts"
                                      , Type.namedWith [] "Impacts" []
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ spinningImpactsArg, spinningImpactsArg0, spinningImpactsArg1 ]
    , recycledMaterialImpacts =
        \recycledMaterialImpactsArg recycledMaterialImpactsArg0 recycledMaterialImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "recycledMaterialImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.record
                                    [ ( "recycledProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "nonRecycledProcess"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "cffData"
                                      , Type.namedWith [] "CFFData" []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ recycledMaterialImpactsArg
                , recycledMaterialImpactsArg0
                , recycledMaterialImpactsArg1
                ]
    , pureMaterialImpacts =
        \pureMaterialImpactsArg pureMaterialImpactsArg0 pureMaterialImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "pureMaterialImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" []
                                , Type.namedWith [] "Process" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ pureMaterialImpactsArg
                , pureMaterialImpactsArg0
                , pureMaterialImpactsArg1
                ]
    , makingWaste =
        \makingWasteArg makingWasteArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "makingWaste"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "waste", Type.namedWith [] "Mass" [] )
                                    , ( "mass", Type.namedWith [] "Mass" [] )
                                    ]
                                )
                            )
                    }
                )
                [ makingWasteArg, makingWasteArg0 ]
    , genericWaste =
        \genericWasteArg genericWasteArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Formula" ]
                    , name = "genericWaste"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.record
                                    [ ( "waste", Type.namedWith [] "Mass" [] )
                                    , ( "mass", Type.namedWith [] "Mass" [] )
                                    ]
                                )
                            )
                    }
                )
                [ genericWasteArg, genericWasteArg0 ]
    }


values_ :
    { transportRatio : Elm.Expression
    , endOfLifeImpacts : Elm.Expression
    , useImpacts : Elm.Expression
    , computePicking : Elm.Expression
    , computeThreadDensity : Elm.Expression
    , weavingImpacts : Elm.Expression
    , knittingImpacts : Elm.Expression
    , makingImpacts : Elm.Expression
    , finishingImpacts : Elm.Expression
    , printingImpacts : Elm.Expression
    , dyeingImpacts : Elm.Expression
    , spinningImpacts : Elm.Expression
    , recycledMaterialImpacts : Elm.Expression
    , pureMaterialImpacts : Elm.Expression
    , makingWaste : Elm.Expression
    , genericWaste : Elm.Expression
    }
values_ =
    { transportRatio =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "transportRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" []
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , endOfLifeImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "endOfLifeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "volume", Type.namedWith [] "Volume" [] )
                            , ( "passengerCar", Type.namedWith [] "Process" [] )
                            , ( "endOfLife", Type.namedWith [] "Process" [] )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "heatProcess", Type.namedWith [] "Process" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , useImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "useImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "useNbCycles", Type.int )
                            , ( "ironingProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "nonIroningProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , computePicking =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "computePicking"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "ThreadDensity" []
                        , Type.namedWith [] "Area" []
                        ]
                        (Type.namedWith [ "Unit" ] "PickPerMeter" [])
                    )
            }
    , computeThreadDensity =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "computeThreadDensity"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Unit" ] "SurfaceMass" []
                        , Type.namedWith [ "Unit" ] "YarnSize" []
                        ]
                        (Type.namedWith [ "Unit" ] "ThreadDensity" [])
                    )
            }
    , weavingImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "weavingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "outputMass", Type.namedWith [] "Mass" [] )
                            , ( "pickingElec", Type.float )
                            , ( "surfaceMass"
                              , Type.namedWith [ "Unit" ] "SurfaceMass" []
                              )
                            , ( "yarnSize"
                              , Type.namedWith [ "Unit" ] "YarnSize" []
                              )
                            ]
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "threadDensity"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "ThreadDensity"
                                        []
                                    ]
                              )
                            , ( "picking"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "PickPerMeter"
                                        []
                                    ]
                              )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , knittingImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "knittingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "elec", Type.namedWith [] "Energy" [] )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "threadDensity"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "ThreadDensity"
                                        []
                                    ]
                              )
                            , ( "picking"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "PickPerMeter"
                                        []
                                    ]
                              )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , makingImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "makingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "makingComplexity"
                              , Type.namedWith [] "MakingComplexity" []
                              )
                            , ( "fadingProcess"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Process" [] ]
                              )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "countryHeatProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , finishingImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "finishingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "finishingProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "heatProcess", Type.namedWith [] "Process" [] )
                            , ( "elecProcess", Type.namedWith [] "Process" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , printingImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "printingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "printingProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "heatProcess", Type.namedWith [] "Process" [] )
                            , ( "elecProcess", Type.namedWith [] "Process" [] )
                            , ( "surfaceMass"
                              , Type.namedWith [ "Unit" ] "SurfaceMass" []
                              )
                            , ( "ratio", Type.namedWith [] "Split" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , dyeingImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "dyeingImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "heat", Type.namedWith [] "Energy" [] )
                            , ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , spinningImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "spinningImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "spinningProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "countryElecProcess"
                              , Type.namedWith [] "Process" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "kwh", Type.namedWith [] "Energy" [] )
                            , ( "impacts", Type.namedWith [] "Impacts" [] )
                            ]
                        )
                    )
            }
    , recycledMaterialImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "recycledMaterialImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.record
                            [ ( "recycledProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "nonRecycledProcess"
                              , Type.namedWith [] "Process" []
                              )
                            , ( "cffData", Type.namedWith [] "CFFData" [] )
                            ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , pureMaterialImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "pureMaterialImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" []
                        , Type.namedWith [] "Process" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , makingWaste =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "makingWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "waste", Type.namedWith [] "Mass" [] )
                            , ( "mass", Type.namedWith [] "Mass" [] )
                            ]
                        )
                    )
            }
    , genericWaste =
        Elm.value
            { importFrom = [ "Data", "Textile", "Formula" ]
            , name = "genericWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.record
                            [ ( "waste", Type.namedWith [] "Mass" [] )
                            , ( "mass", Type.namedWith [] "Mass" [] )
                            ]
                        )
                    )
            }
    }