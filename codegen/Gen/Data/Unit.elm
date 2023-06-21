module Gen.Data.Unit exposing (annotation_, call_, caseOf_, decodeImpact, decodeQuality, decodeRatio, decodeReparability, decodeSurfaceMass, decodeYarnSize, encodeImpact, encodePickPerMeter, encodeQuality, encodeReparability, encodeSurfaceMass, encodeThreadDensity, encodeYarnSize, forKWh, forKg, forKgAndDistance, forMJ, functionalToSlug, functionalToString, gramsPerSquareMeter, impact, impactAggregateScore, impactToFloat, inFunctionalUnit, make_, maxQuality, maxReparability, maxSurfaceMass, maxYarnSize, minQuality, minReparability, minSurfaceMass, minYarnSize, moduleName_, parseFunctional, pickPerMeter, pickPerMeterToFloat, quality, qualityToFloat, ratio, ratioToFloat, ratioedForKWh, ratioedForKg, ratioedForMJ, reparability, reparabilityToFloat, standardQuality, standardReparability, surfaceMassInGramsPerSquareMeters, surfaceMassToSurface, threadDensity, threadDensityHigh, threadDensityLow, threadDensityToFloat, threadDensityToInt, values_, yarnSizeGramsPer10km, yarnSizeInGrams, yarnSizeInKilometers, yarnSizeKilometersPerKg)

{-| 
@docs moduleName_, ratioedForMJ, ratioedForKWh, ratioedForKg, forMJ, forKWh, forKgAndDistance, forKg, inFunctionalUnit, encodeImpact, decodeImpact, impactAggregateScore, impactToFloat, impact, encodeSurfaceMass, decodeSurfaceMass, maxSurfaceMass, minSurfaceMass, surfaceMassToSurface, surfaceMassInGramsPerSquareMeters, gramsPerSquareMeter, encodePickPerMeter, pickPerMeterToFloat, pickPerMeter, threadDensityToFloat, threadDensityToInt, threadDensityHigh, threadDensityLow, threadDensity, encodeThreadDensity, decodeYarnSize, encodeYarnSize, yarnSizeInGrams, yarnSizeInKilometers, maxYarnSize, minYarnSize, yarnSizeGramsPer10km, yarnSizeKilometersPerKg, encodeReparability, decodeReparability, reparabilityToFloat, reparability, maxReparability, standardReparability, minReparability, encodeQuality, decodeQuality, qualityToFloat, quality, maxQuality, standardQuality, minQuality, decodeRatio, ratioToFloat, ratio, parseFunctional, functionalToSlug, functionalToString, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Unit" ]


{-| ratioedForMJ: 
    ( Quantity Float unit, Quantity Float unit )
    -> Ratio
    -> Energy
    -> Quantity Float unit
-}
ratioedForMJ :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
ratioedForMJ ratioedForMJArg ratioedForMJArg0 ratioedForMJArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioedForMJ"
            , annotation =
                Just
                    (Type.function
                        [ Type.tuple
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ ratioedForMJArg, ratioedForMJArg0, ratioedForMJArg1 ]


{-| ratioedForKWh: 
    ( Quantity Float unit, Quantity Float unit )
    -> Ratio
    -> Energy
    -> Quantity Float unit
-}
ratioedForKWh :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
ratioedForKWh ratioedForKWhArg ratioedForKWhArg0 ratioedForKWhArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioedForKWh"
            , annotation =
                Just
                    (Type.function
                        [ Type.tuple
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ ratioedForKWhArg, ratioedForKWhArg0, ratioedForKWhArg1 ]


{-| ratioedForKg: 
    ( Quantity Float unit, Quantity Float unit )
    -> Ratio
    -> Mass
    -> Quantity Float unit
-}
ratioedForKg :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
ratioedForKg ratioedForKgArg ratioedForKgArg0 ratioedForKgArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioedForKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.tuple
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ ratioedForKgArg, ratioedForKgArg0, ratioedForKgArg1 ]


{-| forMJ: Quantity Float unit -> Energy -> Quantity Float unit -}
forMJ : Elm.Expression -> Elm.Expression -> Elm.Expression
forMJ forMJArg forMJArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forMJ"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ forMJArg, forMJArg0 ]


{-| forKWh: Quantity Float unit -> Energy -> Quantity Float unit -}
forKWh : Elm.Expression -> Elm.Expression -> Elm.Expression
forKWh forKWhArg forKWhArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forKWh"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ forKWhArg, forKWhArg0 ]


{-| forKgAndDistance: Quantity Float unit -> Length -> Mass -> Quantity Float unit -}
forKgAndDistance :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
forKgAndDistance forKgAndDistanceArg forKgAndDistanceArg0 forKgAndDistanceArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forKgAndDistance"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Length" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ forKgAndDistanceArg, forKgAndDistanceArg0, forKgAndDistanceArg1 ]


{-| forKg: Quantity Float unit -> Mass -> Quantity Float unit -}
forKg : Elm.Expression -> Elm.Expression -> Elm.Expression
forKg forKgArg forKgArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
        )
        [ forKgArg, forKgArg0 ]


{-| inFunctionalUnit: Functional -> Duration -> Impact -> Impact -}
inFunctionalUnit :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
inFunctionalUnit inFunctionalUnitArg inFunctionalUnitArg0 inFunctionalUnitArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "inFunctionalUnit"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Functional" []
                        , Type.namedWith [] "Duration" []
                        , Type.namedWith [] "Impact" []
                        ]
                        (Type.namedWith [] "Impact" [])
                    )
            }
        )
        [ inFunctionalUnitArg, inFunctionalUnitArg0, inFunctionalUnitArg1 ]


{-| encodeImpact: Impact -> Encode.Value -}
encodeImpact : Elm.Expression -> Elm.Expression
encodeImpact encodeImpactArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impact" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeImpactArg ]


{-| decodeImpact: Decoder Impact -}
decodeImpact : Elm.Expression
decodeImpact =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "decodeImpact"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Impact" [] ])
        }


{-| impactAggregateScore: Impact -> Ratio -> Impact -> Impact -}
impactAggregateScore :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
impactAggregateScore impactAggregateScoreArg impactAggregateScoreArg0 impactAggregateScoreArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "impactAggregateScore"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impact" []
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Impact" []
                        ]
                        (Type.namedWith [] "Impact" [])
                    )
            }
        )
        [ impactAggregateScoreArg
        , impactAggregateScoreArg0
        , impactAggregateScoreArg1
        ]


{-| impactToFloat: Impact -> Float -}
impactToFloat : Elm.Expression -> Elm.Expression
impactToFloat impactToFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "impactToFloat"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Impact" [] ] Type.float)
            }
        )
        [ impactToFloatArg ]


{-| impact: Float -> Impact -}
impact : Float -> Elm.Expression
impact impactArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "impact"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "Impact" [])
                    )
            }
        )
        [ Elm.float impactArg ]


{-| encodeSurfaceMass: SurfaceMass -> Encode.Value -}
encodeSurfaceMass : Elm.Expression -> Elm.Expression
encodeSurfaceMass encodeSurfaceMassArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeSurfaceMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "SurfaceMass" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeSurfaceMassArg ]


{-| decodeSurfaceMass: Decoder SurfaceMass -}
decodeSurfaceMass : Elm.Expression
decodeSurfaceMass =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "decodeSurfaceMass"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "SurfaceMass" [] ]
                )
        }


{-| maxSurfaceMass: SurfaceMass -}
maxSurfaceMass : Elm.Expression
maxSurfaceMass =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "maxSurfaceMass"
        , annotation = Just (Type.namedWith [] "SurfaceMass" [])
        }


{-| minSurfaceMass: SurfaceMass -}
minSurfaceMass : Elm.Expression
minSurfaceMass =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "minSurfaceMass"
        , annotation = Just (Type.namedWith [] "SurfaceMass" [])
        }


{-| surfaceMassToSurface: SurfaceMass -> Mass -> Area -}
surfaceMassToSurface : Elm.Expression -> Elm.Expression -> Elm.Expression
surfaceMassToSurface surfaceMassToSurfaceArg surfaceMassToSurfaceArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "surfaceMassToSurface"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "SurfaceMass" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Area" [])
                    )
            }
        )
        [ surfaceMassToSurfaceArg, surfaceMassToSurfaceArg0 ]


{-| surfaceMassInGramsPerSquareMeters: SurfaceMass -> Int -}
surfaceMassInGramsPerSquareMeters : Elm.Expression -> Elm.Expression
surfaceMassInGramsPerSquareMeters surfaceMassInGramsPerSquareMetersArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "surfaceMassInGramsPerSquareMeters"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "SurfaceMass" [] ]
                        Type.int
                    )
            }
        )
        [ surfaceMassInGramsPerSquareMetersArg ]


{-| gramsPerSquareMeter: Int -> SurfaceMass -}
gramsPerSquareMeter : Int -> Elm.Expression
gramsPerSquareMeter gramsPerSquareMeterArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "gramsPerSquareMeter"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "SurfaceMass" [])
                    )
            }
        )
        [ Elm.int gramsPerSquareMeterArg ]


{-| encodePickPerMeter: PickPerMeter -> Encode.Value -}
encodePickPerMeter : Elm.Expression -> Elm.Expression
encodePickPerMeter encodePickPerMeterArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodePickPerMeter"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PickPerMeter" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodePickPerMeterArg ]


{-| pickPerMeterToFloat: PickPerMeter -> Float -}
pickPerMeterToFloat : Elm.Expression -> Elm.Expression
pickPerMeterToFloat pickPerMeterToFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "pickPerMeterToFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PickPerMeter" [] ]
                        Type.float
                    )
            }
        )
        [ pickPerMeterToFloatArg ]


{-| pickPerMeter: Int -> PickPerMeter -}
pickPerMeter : Int -> Elm.Expression
pickPerMeter pickPerMeterArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "pickPerMeter"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "PickPerMeter" [])
                    )
            }
        )
        [ Elm.int pickPerMeterArg ]


{-| threadDensityToFloat: ThreadDensity -> Float -}
threadDensityToFloat : Elm.Expression -> Elm.Expression
threadDensityToFloat threadDensityToFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensityToFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ThreadDensity" [] ]
                        Type.float
                    )
            }
        )
        [ threadDensityToFloatArg ]


{-| threadDensityToInt: ThreadDensity -> Int -}
threadDensityToInt : Elm.Expression -> Elm.Expression
threadDensityToInt threadDensityToIntArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensityToInt"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ThreadDensity" [] ]
                        Type.int
                    )
            }
        )
        [ threadDensityToIntArg ]


{-| threadDensityHigh: ThreadDensity -}
threadDensityHigh : Elm.Expression
threadDensityHigh =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "threadDensityHigh"
        , annotation = Just (Type.namedWith [] "ThreadDensity" [])
        }


{-| threadDensityLow: ThreadDensity -}
threadDensityLow : Elm.Expression
threadDensityLow =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "threadDensityLow"
        , annotation = Just (Type.namedWith [] "ThreadDensity" [])
        }


{-| threadDensity: Float -> ThreadDensity -}
threadDensity : Float -> Elm.Expression
threadDensity threadDensityArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensity"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "ThreadDensity" [])
                    )
            }
        )
        [ Elm.float threadDensityArg ]


{-| encodeThreadDensity: ThreadDensity -> Encode.Value -}
encodeThreadDensity : Elm.Expression -> Elm.Expression
encodeThreadDensity encodeThreadDensityArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeThreadDensity"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ThreadDensity" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeThreadDensityArg ]


{-| decodeYarnSize: Decoder YarnSize -}
decodeYarnSize : Elm.Expression
decodeYarnSize =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "decodeYarnSize"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "YarnSize" [] ]
                )
        }


{-| encodeYarnSize: YarnSize -> Encode.Value -}
encodeYarnSize : Elm.Expression -> Elm.Expression
encodeYarnSize encodeYarnSizeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeYarnSize"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "YarnSize" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeYarnSizeArg ]


{-| yarnSizeInGrams: YarnSize -> Int -}
yarnSizeInGrams : Elm.Expression -> Elm.Expression
yarnSizeInGrams yarnSizeInGramsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeInGrams"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "YarnSize" [] ] Type.int)
            }
        )
        [ yarnSizeInGramsArg ]


{-| yarnSizeInKilometers: YarnSize -> Int -}
yarnSizeInKilometers : Elm.Expression -> Elm.Expression
yarnSizeInKilometers yarnSizeInKilometersArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeInKilometers"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "YarnSize" [] ] Type.int)
            }
        )
        [ yarnSizeInKilometersArg ]


{-| maxYarnSize: YarnSize -}
maxYarnSize : Elm.Expression
maxYarnSize =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "maxYarnSize"
        , annotation = Just (Type.namedWith [] "YarnSize" [])
        }


{-| minYarnSize: YarnSize -}
minYarnSize : Elm.Expression
minYarnSize =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "minYarnSize"
        , annotation = Just (Type.namedWith [] "YarnSize" [])
        }


{-| yarnSizeGramsPer10km: Int -> YarnSize -}
yarnSizeGramsPer10km : Int -> Elm.Expression
yarnSizeGramsPer10km yarnSizeGramsPer10kmArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeGramsPer10km"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "YarnSize" [])
                    )
            }
        )
        [ Elm.int yarnSizeGramsPer10kmArg ]


{-| yarnSizeKilometersPerKg: Int -> YarnSize -}
yarnSizeKilometersPerKg : Int -> Elm.Expression
yarnSizeKilometersPerKg yarnSizeKilometersPerKgArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeKilometersPerKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "YarnSize" [])
                    )
            }
        )
        [ Elm.int yarnSizeKilometersPerKgArg ]


{-| encodeReparability: Reparability -> Encode.Value -}
encodeReparability : Elm.Expression -> Elm.Expression
encodeReparability encodeReparabilityArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeReparability"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Reparability" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeReparabilityArg ]


{-| decodeReparability: Decoder Reparability -}
decodeReparability : Elm.Expression
decodeReparability =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "decodeReparability"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "Reparability" [] ]
                )
        }


{-| reparabilityToFloat: Reparability -> Float -}
reparabilityToFloat : Elm.Expression -> Elm.Expression
reparabilityToFloat reparabilityToFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "reparabilityToFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Reparability" [] ]
                        Type.float
                    )
            }
        )
        [ reparabilityToFloatArg ]


{-| reparability: Float -> Reparability -}
reparability : Float -> Elm.Expression
reparability reparabilityArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "reparability"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "Reparability" [])
                    )
            }
        )
        [ Elm.float reparabilityArg ]


{-| maxReparability: Reparability -}
maxReparability : Elm.Expression
maxReparability =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "maxReparability"
        , annotation = Just (Type.namedWith [] "Reparability" [])
        }


{-| standardReparability: Reparability -}
standardReparability : Elm.Expression
standardReparability =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "standardReparability"
        , annotation = Just (Type.namedWith [] "Reparability" [])
        }


{-| minReparability: Reparability -}
minReparability : Elm.Expression
minReparability =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "minReparability"
        , annotation = Just (Type.namedWith [] "Reparability" [])
        }


{-| encodeQuality: Quality -> Encode.Value -}
encodeQuality : Elm.Expression -> Elm.Expression
encodeQuality encodeQualityArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeQuality"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Quality" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeQualityArg ]


{-| decodeQuality: Decoder Quality -}
decodeQuality : Elm.Expression
decodeQuality =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "decodeQuality"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Quality" [] ])
        }


{-| qualityToFloat: Quality -> Float -}
qualityToFloat : Elm.Expression -> Elm.Expression
qualityToFloat qualityToFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "qualityToFloat"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Quality" [] ] Type.float
                    )
            }
        )
        [ qualityToFloatArg ]


{-| quality: Float -> Quality -}
quality : Float -> Elm.Expression
quality qualityArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "quality"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "Quality" [])
                    )
            }
        )
        [ Elm.float qualityArg ]


{-| maxQuality: Quality -}
maxQuality : Elm.Expression
maxQuality =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "maxQuality"
        , annotation = Just (Type.namedWith [] "Quality" [])
        }


{-| standardQuality: Quality -}
standardQuality : Elm.Expression
standardQuality =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "standardQuality"
        , annotation = Just (Type.namedWith [] "Quality" [])
        }


{-| minQuality: Quality -}
minQuality : Elm.Expression
minQuality =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "minQuality"
        , annotation = Just (Type.namedWith [] "Quality" [])
        }


{-| decodeRatio: { percentage : Bool } -> Decoder Ratio -}
decodeRatio : { percentage : Bool } -> Elm.Expression
decodeRatio decodeRatioArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.record [ ( "percentage", Type.bool ) ] ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.namedWith [] "Ratio" [] ]
                        )
                    )
            }
        )
        [ Elm.record
            [ Tuple.pair "percentage" (Elm.bool decodeRatioArg.percentage) ]
        ]


{-| ratioToFloat: Ratio -> Float -}
ratioToFloat : Elm.Expression -> Elm.Expression
ratioToFloat ratioToFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioToFloat"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Ratio" [] ] Type.float)
            }
        )
        [ ratioToFloatArg ]


{-| ratio: Float -> Ratio -}
ratio : Float -> Elm.Expression
ratio ratioArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratio"
            , annotation =
                Just
                    (Type.function [ Type.float ] (Type.namedWith [] "Ratio" [])
                    )
            }
        )
        [ Elm.float ratioArg ]


{-| parseFunctional: Parser (Functional -> a) a -}
parseFunctional : Elm.Expression
parseFunctional =
    Elm.value
        { importFrom = [ "Data", "Unit" ]
        , name = "parseFunctional"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Parser"
                    [ Type.function
                        [ Type.namedWith [] "Functional" [] ]
                        (Type.var "a")
                    , Type.var "a"
                    ]
                )
        }


{-| functionalToSlug: Functional -> String -}
functionalToSlug : Elm.Expression -> Elm.Expression
functionalToSlug functionalToSlugArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "functionalToSlug"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Functional" [] ]
                        Type.string
                    )
            }
        )
        [ functionalToSlugArg ]


{-| functionalToString: Functional -> String -}
functionalToString : Elm.Expression -> Elm.Expression
functionalToString functionalToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "functionalToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Functional" [] ]
                        Type.string
                    )
            }
        )
        [ functionalToStringArg ]


annotation_ :
    { impact : Type.Annotation
    , surfaceMass : Type.Annotation
    , yarnSize : Type.Annotation
    , impactUnit : Type.Annotation
    , pickPerMeter : Type.Annotation
    , threadDensity : Type.Annotation
    , reparability : Type.Annotation
    , quality : Type.Annotation
    , ratio : Type.Annotation
    , functional : Type.Annotation
    }
annotation_ =
    { impact =
        Type.alias
            moduleName_
            "Impact"
            []
            (Type.namedWith
                []
                "Quantity"
                [ Type.float, Type.namedWith [] "ImpactUnit" [] ]
            )
    , surfaceMass =
        Type.alias
            moduleName_
            "SurfaceMass"
            []
            (Type.namedWith
                []
                "Quantity"
                [ Type.float
                , Type.namedWith
                    [ "Quantity" ]
                    "Rate"
                    [ Type.namedWith [ "Mass" ] "Kilograms" []
                    , Type.namedWith [ "Area" ] "SquareMeters" []
                    ]
                ]
            )
    , yarnSize =
        Type.alias
            moduleName_
            "YarnSize"
            []
            (Type.namedWith
                []
                "Quantity"
                [ Type.float
                , Type.namedWith
                    [ "Quantity" ]
                    "Rate"
                    [ Type.namedWith [ "Length" ] "Meters" []
                    , Type.namedWith [ "Mass" ] "Kilograms" []
                    ]
                ]
            )
    , impactUnit = Type.namedWith [ "Data", "Unit" ] "ImpactUnit" []
    , pickPerMeter = Type.namedWith [ "Data", "Unit" ] "PickPerMeter" []
    , threadDensity = Type.namedWith [ "Data", "Unit" ] "ThreadDensity" []
    , reparability = Type.namedWith [ "Data", "Unit" ] "Reparability" []
    , quality = Type.namedWith [ "Data", "Unit" ] "Quality" []
    , ratio = Type.namedWith [ "Data", "Unit" ] "Ratio" []
    , functional = Type.namedWith [ "Data", "Unit" ] "Functional" []
    }


make_ :
    { impactUnit : Elm.Expression -> Elm.Expression
    , pickPerMeter : Elm.Expression -> Elm.Expression
    , threadDensity : Elm.Expression -> Elm.Expression
    , reparability : Elm.Expression -> Elm.Expression
    , quality : Elm.Expression -> Elm.Expression
    , ratio : Elm.Expression -> Elm.Expression
    , perDayOfWear : Elm.Expression
    , perItem : Elm.Expression
    }
make_ =
    { impactUnit =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ImpactUnit"
                    , annotation = Just (Type.namedWith [] "ImpactUnit" [])
                    }
                )
                [ ar0 ]
    , pickPerMeter =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "PickPerMeter"
                    , annotation = Just (Type.namedWith [] "PickPerMeter" [])
                    }
                )
                [ ar0 ]
    , threadDensity =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ThreadDensity"
                    , annotation = Just (Type.namedWith [] "ThreadDensity" [])
                    }
                )
                [ ar0 ]
    , reparability =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "Reparability"
                    , annotation = Just (Type.namedWith [] "Reparability" [])
                    }
                )
                [ ar0 ]
    , quality =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "Quality"
                    , annotation = Just (Type.namedWith [] "Quality" [])
                    }
                )
                [ ar0 ]
    , ratio =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "Ratio"
                    , annotation = Just (Type.namedWith [] "Ratio" [])
                    }
                )
                [ ar0 ]
    , perDayOfWear =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "PerDayOfWear"
            , annotation = Just (Type.namedWith [] "Functional" [])
            }
    , perItem =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "PerItem"
            , annotation = Just (Type.namedWith [] "Functional" [])
            }
    }


caseOf_ :
    { impactUnit :
        Elm.Expression
        -> { impactUnitTags_0_0
            | impactUnit : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    , pickPerMeter :
        Elm.Expression
        -> { pickPerMeterTags_1_0
            | pickPerMeter : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    , threadDensity :
        Elm.Expression
        -> { threadDensityTags_2_0
            | threadDensity : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    , reparability :
        Elm.Expression
        -> { reparabilityTags_3_0
            | reparability : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    , quality :
        Elm.Expression
        -> { qualityTags_4_0 | quality : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    , ratio :
        Elm.Expression
        -> { ratioTags_5_0 | ratio : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    , functional :
        Elm.Expression
        -> { functionalTags_6_0
            | perDayOfWear : Elm.Expression
            , perItem : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { impactUnit =
        \impactUnitExpression impactUnitTags ->
            Elm.Case.custom
                impactUnitExpression
                (Type.namedWith [ "Data", "Unit" ] "ImpactUnit" [])
                [ Elm.Case.branch1
                    "ImpactUnit"
                    ( "never", Type.namedWith [] "Never" [] )
                    impactUnitTags.impactUnit
                ]
    , pickPerMeter =
        \pickPerMeterExpression pickPerMeterTags ->
            Elm.Case.custom
                pickPerMeterExpression
                (Type.namedWith [ "Data", "Unit" ] "PickPerMeter" [])
                [ Elm.Case.branch1
                    "PickPerMeter"
                    ( "basics.Int", Type.int )
                    pickPerMeterTags.pickPerMeter
                ]
    , threadDensity =
        \threadDensityExpression threadDensityTags ->
            Elm.Case.custom
                threadDensityExpression
                (Type.namedWith [ "Data", "Unit" ] "ThreadDensity" [])
                [ Elm.Case.branch1
                    "ThreadDensity"
                    ( "basics.Float", Type.float )
                    threadDensityTags.threadDensity
                ]
    , reparability =
        \reparabilityExpression reparabilityTags ->
            Elm.Case.custom
                reparabilityExpression
                (Type.namedWith [ "Data", "Unit" ] "Reparability" [])
                [ Elm.Case.branch1
                    "Reparability"
                    ( "basics.Float", Type.float )
                    reparabilityTags.reparability
                ]
    , quality =
        \qualityExpression qualityTags ->
            Elm.Case.custom
                qualityExpression
                (Type.namedWith [ "Data", "Unit" ] "Quality" [])
                [ Elm.Case.branch1
                    "Quality"
                    ( "basics.Float", Type.float )
                    qualityTags.quality
                ]
    , ratio =
        \ratioExpression ratioTags ->
            Elm.Case.custom
                ratioExpression
                (Type.namedWith [ "Data", "Unit" ] "Ratio" [])
                [ Elm.Case.branch1
                    "Ratio"
                    ( "basics.Float", Type.float )
                    ratioTags.ratio
                ]
    , functional =
        \functionalExpression functionalTags ->
            Elm.Case.custom
                functionalExpression
                (Type.namedWith [ "Data", "Unit" ] "Functional" [])
                [ Elm.Case.branch0 "PerDayOfWear" functionalTags.perDayOfWear
                , Elm.Case.branch0 "PerItem" functionalTags.perItem
                ]
    }


call_ :
    { ratioedForMJ :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , ratioedForKWh :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , ratioedForKg :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , forMJ : Elm.Expression -> Elm.Expression -> Elm.Expression
    , forKWh : Elm.Expression -> Elm.Expression -> Elm.Expression
    , forKgAndDistance :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , forKg : Elm.Expression -> Elm.Expression -> Elm.Expression
    , inFunctionalUnit :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , encodeImpact : Elm.Expression -> Elm.Expression
    , impactAggregateScore :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , impactToFloat : Elm.Expression -> Elm.Expression
    , impact : Elm.Expression -> Elm.Expression
    , encodeSurfaceMass : Elm.Expression -> Elm.Expression
    , surfaceMassToSurface : Elm.Expression -> Elm.Expression -> Elm.Expression
    , surfaceMassInGramsPerSquareMeters : Elm.Expression -> Elm.Expression
    , gramsPerSquareMeter : Elm.Expression -> Elm.Expression
    , encodePickPerMeter : Elm.Expression -> Elm.Expression
    , pickPerMeterToFloat : Elm.Expression -> Elm.Expression
    , pickPerMeter : Elm.Expression -> Elm.Expression
    , threadDensityToFloat : Elm.Expression -> Elm.Expression
    , threadDensityToInt : Elm.Expression -> Elm.Expression
    , threadDensity : Elm.Expression -> Elm.Expression
    , encodeThreadDensity : Elm.Expression -> Elm.Expression
    , encodeYarnSize : Elm.Expression -> Elm.Expression
    , yarnSizeInGrams : Elm.Expression -> Elm.Expression
    , yarnSizeInKilometers : Elm.Expression -> Elm.Expression
    , yarnSizeGramsPer10km : Elm.Expression -> Elm.Expression
    , yarnSizeKilometersPerKg : Elm.Expression -> Elm.Expression
    , encodeReparability : Elm.Expression -> Elm.Expression
    , reparabilityToFloat : Elm.Expression -> Elm.Expression
    , reparability : Elm.Expression -> Elm.Expression
    , encodeQuality : Elm.Expression -> Elm.Expression
    , qualityToFloat : Elm.Expression -> Elm.Expression
    , quality : Elm.Expression -> Elm.Expression
    , decodeRatio : Elm.Expression -> Elm.Expression
    , ratioToFloat : Elm.Expression -> Elm.Expression
    , ratio : Elm.Expression -> Elm.Expression
    , functionalToSlug : Elm.Expression -> Elm.Expression
    , functionalToString : Elm.Expression -> Elm.Expression
    }
call_ =
    { ratioedForMJ =
        \ratioedForMJArg ratioedForMJArg0 ratioedForMJArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ratioedForMJ"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.tuple
                                    (Type.namedWith
                                        []
                                        "Quantity"
                                        [ Type.float, Type.var "unit" ]
                                    )
                                    (Type.namedWith
                                        []
                                        "Quantity"
                                        [ Type.float, Type.var "unit" ]
                                    )
                                , Type.namedWith [] "Ratio" []
                                , Type.namedWith [] "Energy" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ ratioedForMJArg, ratioedForMJArg0, ratioedForMJArg1 ]
    , ratioedForKWh =
        \ratioedForKWhArg ratioedForKWhArg0 ratioedForKWhArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ratioedForKWh"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.tuple
                                    (Type.namedWith
                                        []
                                        "Quantity"
                                        [ Type.float, Type.var "unit" ]
                                    )
                                    (Type.namedWith
                                        []
                                        "Quantity"
                                        [ Type.float, Type.var "unit" ]
                                    )
                                , Type.namedWith [] "Ratio" []
                                , Type.namedWith [] "Energy" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ ratioedForKWhArg, ratioedForKWhArg0, ratioedForKWhArg1 ]
    , ratioedForKg =
        \ratioedForKgArg ratioedForKgArg0 ratioedForKgArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ratioedForKg"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.tuple
                                    (Type.namedWith
                                        []
                                        "Quantity"
                                        [ Type.float, Type.var "unit" ]
                                    )
                                    (Type.namedWith
                                        []
                                        "Quantity"
                                        [ Type.float, Type.var "unit" ]
                                    )
                                , Type.namedWith [] "Ratio" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ ratioedForKgArg, ratioedForKgArg0, ratioedForKgArg1 ]
    , forMJ =
        \forMJArg forMJArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "forMJ"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                , Type.namedWith [] "Energy" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ forMJArg, forMJArg0 ]
    , forKWh =
        \forKWhArg forKWhArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "forKWh"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                , Type.namedWith [] "Energy" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ forKWhArg, forKWhArg0 ]
    , forKgAndDistance =
        \forKgAndDistanceArg forKgAndDistanceArg0 forKgAndDistanceArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "forKgAndDistance"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                , Type.namedWith [] "Length" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ forKgAndDistanceArg
                , forKgAndDistanceArg0
                , forKgAndDistanceArg1
                ]
    , forKg =
        \forKgArg forKgArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "forKg"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith
                                    []
                                    "Quantity"
                                    [ Type.float, Type.var "unit" ]
                                )
                            )
                    }
                )
                [ forKgArg, forKgArg0 ]
    , inFunctionalUnit =
        \inFunctionalUnitArg inFunctionalUnitArg0 inFunctionalUnitArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "inFunctionalUnit"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Functional" []
                                , Type.namedWith [] "Duration" []
                                , Type.namedWith [] "Impact" []
                                ]
                                (Type.namedWith [] "Impact" [])
                            )
                    }
                )
                [ inFunctionalUnitArg
                , inFunctionalUnitArg0
                , inFunctionalUnitArg1
                ]
    , encodeImpact =
        \encodeImpactArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodeImpact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impact" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeImpactArg ]
    , impactAggregateScore =
        \impactAggregateScoreArg impactAggregateScoreArg0 impactAggregateScoreArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "impactAggregateScore"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impact" []
                                , Type.namedWith [] "Ratio" []
                                , Type.namedWith [] "Impact" []
                                ]
                                (Type.namedWith [] "Impact" [])
                            )
                    }
                )
                [ impactAggregateScoreArg
                , impactAggregateScoreArg0
                , impactAggregateScoreArg1
                ]
    , impactToFloat =
        \impactToFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "impactToFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impact" [] ]
                                Type.float
                            )
                    }
                )
                [ impactToFloatArg ]
    , impact =
        \impactArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "impact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith [] "Impact" [])
                            )
                    }
                )
                [ impactArg ]
    , encodeSurfaceMass =
        \encodeSurfaceMassArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodeSurfaceMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "SurfaceMass" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeSurfaceMassArg ]
    , surfaceMassToSurface =
        \surfaceMassToSurfaceArg surfaceMassToSurfaceArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "surfaceMassToSurface"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "SurfaceMass" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith [] "Area" [])
                            )
                    }
                )
                [ surfaceMassToSurfaceArg, surfaceMassToSurfaceArg0 ]
    , surfaceMassInGramsPerSquareMeters =
        \surfaceMassInGramsPerSquareMetersArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "surfaceMassInGramsPerSquareMeters"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "SurfaceMass" [] ]
                                Type.int
                            )
                    }
                )
                [ surfaceMassInGramsPerSquareMetersArg ]
    , gramsPerSquareMeter =
        \gramsPerSquareMeterArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "gramsPerSquareMeter"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int ]
                                (Type.namedWith [] "SurfaceMass" [])
                            )
                    }
                )
                [ gramsPerSquareMeterArg ]
    , encodePickPerMeter =
        \encodePickPerMeterArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodePickPerMeter"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "PickPerMeter" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodePickPerMeterArg ]
    , pickPerMeterToFloat =
        \pickPerMeterToFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "pickPerMeterToFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "PickPerMeter" [] ]
                                Type.float
                            )
                    }
                )
                [ pickPerMeterToFloatArg ]
    , pickPerMeter =
        \pickPerMeterArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "pickPerMeter"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int ]
                                (Type.namedWith [] "PickPerMeter" [])
                            )
                    }
                )
                [ pickPerMeterArg ]
    , threadDensityToFloat =
        \threadDensityToFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "threadDensityToFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ThreadDensity" [] ]
                                Type.float
                            )
                    }
                )
                [ threadDensityToFloatArg ]
    , threadDensityToInt =
        \threadDensityToIntArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "threadDensityToInt"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ThreadDensity" [] ]
                                Type.int
                            )
                    }
                )
                [ threadDensityToIntArg ]
    , threadDensity =
        \threadDensityArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "threadDensity"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith [] "ThreadDensity" [])
                            )
                    }
                )
                [ threadDensityArg ]
    , encodeThreadDensity =
        \encodeThreadDensityArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodeThreadDensity"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ThreadDensity" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeThreadDensityArg ]
    , encodeYarnSize =
        \encodeYarnSizeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodeYarnSize"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "YarnSize" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeYarnSizeArg ]
    , yarnSizeInGrams =
        \yarnSizeInGramsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "yarnSizeInGrams"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "YarnSize" [] ]
                                Type.int
                            )
                    }
                )
                [ yarnSizeInGramsArg ]
    , yarnSizeInKilometers =
        \yarnSizeInKilometersArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "yarnSizeInKilometers"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "YarnSize" [] ]
                                Type.int
                            )
                    }
                )
                [ yarnSizeInKilometersArg ]
    , yarnSizeGramsPer10km =
        \yarnSizeGramsPer10kmArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "yarnSizeGramsPer10km"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int ]
                                (Type.namedWith [] "YarnSize" [])
                            )
                    }
                )
                [ yarnSizeGramsPer10kmArg ]
    , yarnSizeKilometersPerKg =
        \yarnSizeKilometersPerKgArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "yarnSizeKilometersPerKg"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int ]
                                (Type.namedWith [] "YarnSize" [])
                            )
                    }
                )
                [ yarnSizeKilometersPerKgArg ]
    , encodeReparability =
        \encodeReparabilityArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodeReparability"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Reparability" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeReparabilityArg ]
    , reparabilityToFloat =
        \reparabilityToFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "reparabilityToFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Reparability" [] ]
                                Type.float
                            )
                    }
                )
                [ reparabilityToFloatArg ]
    , reparability =
        \reparabilityArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "reparability"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith [] "Reparability" [])
                            )
                    }
                )
                [ reparabilityArg ]
    , encodeQuality =
        \encodeQualityArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "encodeQuality"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Quality" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeQualityArg ]
    , qualityToFloat =
        \qualityToFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "qualityToFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Quality" [] ]
                                Type.float
                            )
                    }
                )
                [ qualityToFloatArg ]
    , quality =
        \qualityArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "quality"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith [] "Quality" [])
                            )
                    }
                )
                [ qualityArg ]
    , decodeRatio =
        \decodeRatioArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "decodeRatio"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.record [ ( "percentage", Type.bool ) ] ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.namedWith [] "Ratio" [] ]
                                )
                            )
                    }
                )
                [ decodeRatioArg ]
    , ratioToFloat =
        \ratioToFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ratioToFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Ratio" [] ]
                                Type.float
                            )
                    }
                )
                [ ratioToFloatArg ]
    , ratio =
        \ratioArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "ratio"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith [] "Ratio" [])
                            )
                    }
                )
                [ ratioArg ]
    , functionalToSlug =
        \functionalToSlugArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "functionalToSlug"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Functional" [] ]
                                Type.string
                            )
                    }
                )
                [ functionalToSlugArg ]
    , functionalToString =
        \functionalToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Unit" ]
                    , name = "functionalToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Functional" [] ]
                                Type.string
                            )
                    }
                )
                [ functionalToStringArg ]
    }


values_ :
    { ratioedForMJ : Elm.Expression
    , ratioedForKWh : Elm.Expression
    , ratioedForKg : Elm.Expression
    , forMJ : Elm.Expression
    , forKWh : Elm.Expression
    , forKgAndDistance : Elm.Expression
    , forKg : Elm.Expression
    , inFunctionalUnit : Elm.Expression
    , encodeImpact : Elm.Expression
    , decodeImpact : Elm.Expression
    , impactAggregateScore : Elm.Expression
    , impactToFloat : Elm.Expression
    , impact : Elm.Expression
    , encodeSurfaceMass : Elm.Expression
    , decodeSurfaceMass : Elm.Expression
    , maxSurfaceMass : Elm.Expression
    , minSurfaceMass : Elm.Expression
    , surfaceMassToSurface : Elm.Expression
    , surfaceMassInGramsPerSquareMeters : Elm.Expression
    , gramsPerSquareMeter : Elm.Expression
    , encodePickPerMeter : Elm.Expression
    , pickPerMeterToFloat : Elm.Expression
    , pickPerMeter : Elm.Expression
    , threadDensityToFloat : Elm.Expression
    , threadDensityToInt : Elm.Expression
    , threadDensityHigh : Elm.Expression
    , threadDensityLow : Elm.Expression
    , threadDensity : Elm.Expression
    , encodeThreadDensity : Elm.Expression
    , decodeYarnSize : Elm.Expression
    , encodeYarnSize : Elm.Expression
    , yarnSizeInGrams : Elm.Expression
    , yarnSizeInKilometers : Elm.Expression
    , maxYarnSize : Elm.Expression
    , minYarnSize : Elm.Expression
    , yarnSizeGramsPer10km : Elm.Expression
    , yarnSizeKilometersPerKg : Elm.Expression
    , encodeReparability : Elm.Expression
    , decodeReparability : Elm.Expression
    , reparabilityToFloat : Elm.Expression
    , reparability : Elm.Expression
    , maxReparability : Elm.Expression
    , standardReparability : Elm.Expression
    , minReparability : Elm.Expression
    , encodeQuality : Elm.Expression
    , decodeQuality : Elm.Expression
    , qualityToFloat : Elm.Expression
    , quality : Elm.Expression
    , maxQuality : Elm.Expression
    , standardQuality : Elm.Expression
    , minQuality : Elm.Expression
    , decodeRatio : Elm.Expression
    , ratioToFloat : Elm.Expression
    , ratio : Elm.Expression
    , parseFunctional : Elm.Expression
    , functionalToSlug : Elm.Expression
    , functionalToString : Elm.Expression
    }
values_ =
    { ratioedForMJ =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioedForMJ"
            , annotation =
                Just
                    (Type.function
                        [ Type.tuple
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , ratioedForKWh =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioedForKWh"
            , annotation =
                Just
                    (Type.function
                        [ Type.tuple
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , ratioedForKg =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioedForKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.tuple
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                            (Type.namedWith
                                []
                                "Quantity"
                                [ Type.float, Type.var "unit" ]
                            )
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , forMJ =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forMJ"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , forKWh =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forKWh"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Energy" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , forKgAndDistance =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forKgAndDistance"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Length" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , forKg =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "forKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith
                            []
                            "Quantity"
                            [ Type.float, Type.var "unit" ]
                        )
                    )
            }
    , inFunctionalUnit =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "inFunctionalUnit"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Functional" []
                        , Type.namedWith [] "Duration" []
                        , Type.namedWith [] "Impact" []
                        ]
                        (Type.namedWith [] "Impact" [])
                    )
            }
    , encodeImpact =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impact" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeImpact =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeImpact"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Impact" [] ]
                    )
            }
    , impactAggregateScore =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "impactAggregateScore"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impact" []
                        , Type.namedWith [] "Ratio" []
                        , Type.namedWith [] "Impact" []
                        ]
                        (Type.namedWith [] "Impact" [])
                    )
            }
    , impactToFloat =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "impactToFloat"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Impact" [] ] Type.float)
            }
    , impact =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "impact"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "Impact" [])
                    )
            }
    , encodeSurfaceMass =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeSurfaceMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "SurfaceMass" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeSurfaceMass =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeSurfaceMass"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "SurfaceMass" [] ]
                    )
            }
    , maxSurfaceMass =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "maxSurfaceMass"
            , annotation = Just (Type.namedWith [] "SurfaceMass" [])
            }
    , minSurfaceMass =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "minSurfaceMass"
            , annotation = Just (Type.namedWith [] "SurfaceMass" [])
            }
    , surfaceMassToSurface =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "surfaceMassToSurface"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "SurfaceMass" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Area" [])
                    )
            }
    , surfaceMassInGramsPerSquareMeters =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "surfaceMassInGramsPerSquareMeters"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "SurfaceMass" [] ]
                        Type.int
                    )
            }
    , gramsPerSquareMeter =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "gramsPerSquareMeter"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "SurfaceMass" [])
                    )
            }
    , encodePickPerMeter =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodePickPerMeter"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PickPerMeter" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , pickPerMeterToFloat =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "pickPerMeterToFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PickPerMeter" [] ]
                        Type.float
                    )
            }
    , pickPerMeter =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "pickPerMeter"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "PickPerMeter" [])
                    )
            }
    , threadDensityToFloat =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensityToFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ThreadDensity" [] ]
                        Type.float
                    )
            }
    , threadDensityToInt =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensityToInt"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ThreadDensity" [] ]
                        Type.int
                    )
            }
    , threadDensityHigh =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensityHigh"
            , annotation = Just (Type.namedWith [] "ThreadDensity" [])
            }
    , threadDensityLow =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensityLow"
            , annotation = Just (Type.namedWith [] "ThreadDensity" [])
            }
    , threadDensity =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "threadDensity"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "ThreadDensity" [])
                    )
            }
    , encodeThreadDensity =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeThreadDensity"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ThreadDensity" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeYarnSize =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeYarnSize"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "YarnSize" [] ]
                    )
            }
    , encodeYarnSize =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeYarnSize"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "YarnSize" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , yarnSizeInGrams =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeInGrams"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "YarnSize" [] ] Type.int)
            }
    , yarnSizeInKilometers =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeInKilometers"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "YarnSize" [] ] Type.int)
            }
    , maxYarnSize =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "maxYarnSize"
            , annotation = Just (Type.namedWith [] "YarnSize" [])
            }
    , minYarnSize =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "minYarnSize"
            , annotation = Just (Type.namedWith [] "YarnSize" [])
            }
    , yarnSizeGramsPer10km =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeGramsPer10km"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "YarnSize" [])
                    )
            }
    , yarnSizeKilometersPerKg =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "yarnSizeKilometersPerKg"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith [] "YarnSize" [])
                    )
            }
    , encodeReparability =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeReparability"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Reparability" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeReparability =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeReparability"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Reparability" [] ]
                    )
            }
    , reparabilityToFloat =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "reparabilityToFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Reparability" [] ]
                        Type.float
                    )
            }
    , reparability =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "reparability"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "Reparability" [])
                    )
            }
    , maxReparability =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "maxReparability"
            , annotation = Just (Type.namedWith [] "Reparability" [])
            }
    , standardReparability =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "standardReparability"
            , annotation = Just (Type.namedWith [] "Reparability" [])
            }
    , minReparability =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "minReparability"
            , annotation = Just (Type.namedWith [] "Reparability" [])
            }
    , encodeQuality =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "encodeQuality"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Quality" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeQuality =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeQuality"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Quality" [] ]
                    )
            }
    , qualityToFloat =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "qualityToFloat"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Quality" [] ] Type.float
                    )
            }
    , quality =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "quality"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "Quality" [])
                    )
            }
    , maxQuality =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "maxQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , standardQuality =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "standardQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , minQuality =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "minQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , decodeRatio =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "decodeRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.record [ ( "percentage", Type.bool ) ] ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.namedWith [] "Ratio" [] ]
                        )
                    )
            }
    , ratioToFloat =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratioToFloat"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Ratio" [] ] Type.float)
            }
    , ratio =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "ratio"
            , annotation =
                Just
                    (Type.function [ Type.float ] (Type.namedWith [] "Ratio" [])
                    )
            }
    , parseFunctional =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "parseFunctional"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Parser"
                        [ Type.function
                            [ Type.namedWith [] "Functional" [] ]
                            (Type.var "a")
                        , Type.var "a"
                        ]
                    )
            }
    , functionalToSlug =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "functionalToSlug"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Functional" [] ]
                        Type.string
                    )
            }
    , functionalToString =
        Elm.value
            { importFrom = [ "Data", "Unit" ]
            , name = "functionalToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Functional" [] ]
                        Type.string
                    )
            }
    }