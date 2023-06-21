module Gen.Data.Textile.Inputs exposing (addMaterial, annotation_, b64decode, b64encode, buildApiQuery, call_, countryList, decodeQuery, defaultQuery, encode, encodeQuery, fromQuery, getMainMaterial, jupeCircuitAsie, make_, moduleName_, parseBase64Query, presets, removeMaterial, stepsToStrings, tShirtCotonAsie, tShirtCotonFrance, toQuery, toString, toggleStep, updateMaterial, updateMaterialShare, updateProduct, updateStepCountry, values_)

{-| 
@docs moduleName_, parseBase64Query, b64encode, b64decode, encodeQuery, decodeQuery, encode, buildApiQuery, presets, jupeCircuitAsie, tShirtCotonAsie, tShirtCotonFrance, defaultQuery, updateProduct, removeMaterial, updateMaterialShare, updateMaterial, addMaterial, toggleStep, updateStepCountry, countryList, toString, stepsToStrings, toQuery, fromQuery, getMainMaterial, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Inputs" ]


{-| parseBase64Query: Parser (Maybe Query -> a) a -}
parseBase64Query : Elm.Expression
parseBase64Query =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "parseBase64Query"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Parser"
                    [ Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Query" [] ]
                        ]
                        (Type.var "a")
                    , Type.var "a"
                    ]
                )
        }


{-| b64encode: Query -> String -}
b64encode : Elm.Expression -> Elm.Expression
b64encode b64encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "b64encode"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Query" [] ] Type.string)
            }
        )
        [ b64encodeArg ]


{-| b64decode: String -> Result String Query -}
b64decode : String -> Elm.Expression
b64decode b64decodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "b64decode"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Query" [] ]
                        )
                    )
            }
        )
        [ Elm.string b64decodeArg ]


{-| encodeQuery: Query -> Encode.Value -}
encodeQuery : Elm.Expression -> Elm.Expression
encodeQuery encodeQueryArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "encodeQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeQueryArg ]


{-| decodeQuery: Decoder Query -}
decodeQuery : Elm.Expression
decodeQuery =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "decodeQuery"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Query" [] ])
        }


{-| encode: Inputs -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| buildApiQuery: String -> Query -> String -}
buildApiQuery : String -> Elm.Expression -> Elm.Expression
buildApiQuery buildApiQueryArg buildApiQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "buildApiQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Query" [] ]
                        Type.string
                    )
            }
        )
        [ Elm.string buildApiQueryArg, buildApiQueryArg0 ]


{-| presets: List Query -}
presets : Elm.Expression
presets =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "presets"
        , annotation = Just (Type.list (Type.namedWith [] "Query" []))
        }


{-| jupeCircuitAsie: Query -}
jupeCircuitAsie : Elm.Expression
jupeCircuitAsie =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "jupeCircuitAsie"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


{-| tShirtCotonAsie: Query -}
tShirtCotonAsie : Elm.Expression
tShirtCotonAsie =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "tShirtCotonAsie"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


{-| tShirtCotonFrance: Query -}
tShirtCotonFrance : Elm.Expression
tShirtCotonFrance =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "tShirtCotonFrance"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


{-| defaultQuery: Query -}
defaultQuery : Elm.Expression
defaultQuery =
    Elm.value
        { importFrom = [ "Data", "Textile", "Inputs" ]
        , name = "defaultQuery"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


{-| updateProduct: Product -> Query -> Query -}
updateProduct : Elm.Expression -> Elm.Expression -> Elm.Expression
updateProduct updateProductArg updateProductArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateProduct"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ updateProductArg, updateProductArg0 ]


{-| removeMaterial: Int -> Query -> Query -}
removeMaterial : Int -> Elm.Expression -> Elm.Expression
removeMaterial removeMaterialArg removeMaterialArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "removeMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ Elm.int removeMaterialArg, removeMaterialArg0 ]


{-| updateMaterialShare: Int -> Split -> Query -> Query -}
updateMaterialShare : Int -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateMaterialShare updateMaterialShareArg updateMaterialShareArg0 updateMaterialShareArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateMaterialShare"
            , annotation =
                Just
                    (Type.function
                        [ Type.int
                        , Type.namedWith [] "Split" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ Elm.int updateMaterialShareArg
        , updateMaterialShareArg0
        , updateMaterialShareArg1
        ]


{-| updateMaterial: Int -> Material -> Query -> Query -}
updateMaterial : Int -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateMaterial updateMaterialArg updateMaterialArg0 updateMaterialArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.int
                        , Type.namedWith [] "Material" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ Elm.int updateMaterialArg, updateMaterialArg0, updateMaterialArg1 ]


{-| addMaterial: Db -> Query -> Query -}
addMaterial : Elm.Expression -> Elm.Expression -> Elm.Expression
addMaterial addMaterialArg addMaterialArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "addMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ addMaterialArg, addMaterialArg0 ]


{-| toggleStep: Label -> Query -> Query -}
toggleStep : Elm.Expression -> Elm.Expression -> Elm.Expression
toggleStep toggleStepArg toggleStepArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "toggleStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ toggleStepArg, toggleStepArg0 ]


{-| updateStepCountry: Label -> Country.Code -> Query -> Query -}
updateStepCountry :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateStepCountry updateStepCountryArg updateStepCountryArg0 updateStepCountryArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateStepCountry"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ updateStepCountryArg, updateStepCountryArg0, updateStepCountryArg1 ]


{-| countryList: Inputs -> List Country -}
countryList : Elm.Expression -> Elm.Expression
countryList countryListArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "countryList"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.list (Type.namedWith [] "Country" []))
                    )
            }
        )
        [ countryListArg ]


{-| toString: Inputs -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Inputs" [] ] Type.string
                    )
            }
        )
        [ toStringArg ]


{-| stepsToStrings: Inputs -> List (List String) -}
stepsToStrings : Elm.Expression -> Elm.Expression
stepsToStrings stepsToStringsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "stepsToStrings"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.list (Type.list Type.string))
                    )
            }
        )
        [ stepsToStringsArg ]


{-| toQuery: Inputs -> Query -}
toQuery : Elm.Expression -> Elm.Expression
toQuery toQueryArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "toQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ toQueryArg ]


{-| fromQuery: Db -> Query -> Result String Inputs -}
fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
fromQuery fromQueryArg fromQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "fromQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Inputs" [] ]
                        )
                    )
            }
        )
        [ fromQueryArg, fromQueryArg0 ]


{-| getMainMaterial: List MaterialInput -> Result String Material -}
getMainMaterial : List Elm.Expression -> Elm.Expression
getMainMaterial getMainMaterialArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "getMainMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "MaterialInput" []) ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Material" [] ]
                        )
                    )
            }
        )
        [ Elm.list getMainMaterialArg ]


annotation_ :
    { query : Type.Annotation
    , materialQuery : Type.Annotation
    , inputs : Type.Annotation
    , materialInput : Type.Annotation
    }
annotation_ =
    { query =
        Type.alias
            moduleName_
            "Query"
            []
            (Type.record
                [ ( "mass", Type.namedWith [] "Mass" [] )
                , ( "materials"
                  , Type.list (Type.namedWith [] "MaterialQuery" [])
                  )
                , ( "product", Type.namedWith [ "Product" ] "Id" [] )
                , ( "countrySpinning"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Country" ] "Code" [] ]
                  )
                , ( "countryFabric", Type.namedWith [ "Country" ] "Code" [] )
                , ( "countryDyeing", Type.namedWith [ "Country" ] "Code" [] )
                , ( "countryMaking", Type.namedWith [ "Country" ] "Code" [] )
                , ( "airTransportRatio"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Split" [] ]
                  )
                , ( "quality"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "Quality" [] ]
                  )
                , ( "reparability"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                  )
                , ( "makingWaste"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Split" [] ]
                  )
                , ( "makingComplexity"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "MakingComplexity" [] ]
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
                , ( "disabledSteps", Type.list (Type.namedWith [] "Label" []) )
                , ( "disabledFading", Type.namedWith [] "Maybe" [ Type.bool ] )
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
                , ( "ennoblingHeatSource"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "HeatSource" [] ]
                  )
                ]
            )
    , materialQuery =
        Type.alias
            moduleName_
            "MaterialQuery"
            []
            (Type.record
                [ ( "id", Type.namedWith [ "Material" ] "Id" [] )
                , ( "share", Type.namedWith [] "Split" [] )
                ]
            )
    , inputs =
        Type.alias
            moduleName_
            "Inputs"
            []
            (Type.record
                [ ( "mass", Type.namedWith [] "Mass" [] )
                , ( "materials"
                  , Type.list (Type.namedWith [] "MaterialInput" [])
                  )
                , ( "product", Type.namedWith [] "Product" [] )
                , ( "countryMaterial", Type.namedWith [] "Country" [] )
                , ( "countrySpinning", Type.namedWith [] "Country" [] )
                , ( "countryFabric", Type.namedWith [] "Country" [] )
                , ( "countryDyeing", Type.namedWith [] "Country" [] )
                , ( "countryMaking", Type.namedWith [] "Country" [] )
                , ( "countryDistribution", Type.namedWith [] "Country" [] )
                , ( "countryUse", Type.namedWith [] "Country" [] )
                , ( "countryEndOfLife", Type.namedWith [] "Country" [] )
                , ( "airTransportRatio"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Split" [] ]
                  )
                , ( "quality"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "Quality" [] ]
                  )
                , ( "reparability"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                  )
                , ( "makingWaste"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Split" [] ]
                  )
                , ( "makingComplexity"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "MakingComplexity" [] ]
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
                , ( "disabledSteps", Type.list (Type.namedWith [] "Label" []) )
                , ( "disabledFading", Type.namedWith [] "Maybe" [ Type.bool ] )
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
                , ( "ennoblingHeatSource"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "HeatSource" [] ]
                  )
                ]
            )
    , materialInput =
        Type.alias
            moduleName_
            "MaterialInput"
            []
            (Type.record
                [ ( "material", Type.namedWith [] "Material" [] )
                , ( "share", Type.namedWith [] "Split" [] )
                ]
            )
    }


make_ :
    { query :
        { mass : Elm.Expression
        , materials : Elm.Expression
        , product : Elm.Expression
        , countrySpinning : Elm.Expression
        , countryFabric : Elm.Expression
        , countryDyeing : Elm.Expression
        , countryMaking : Elm.Expression
        , airTransportRatio : Elm.Expression
        , quality : Elm.Expression
        , reparability : Elm.Expression
        , makingWaste : Elm.Expression
        , makingComplexity : Elm.Expression
        , yarnSize : Elm.Expression
        , surfaceMass : Elm.Expression
        , knittingProcess : Elm.Expression
        , disabledSteps : Elm.Expression
        , disabledFading : Elm.Expression
        , dyeingMedium : Elm.Expression
        , printing : Elm.Expression
        , ennoblingHeatSource : Elm.Expression
        }
        -> Elm.Expression
    , materialQuery :
        { id : Elm.Expression, share : Elm.Expression } -> Elm.Expression
    , inputs :
        { mass : Elm.Expression
        , materials : Elm.Expression
        , product : Elm.Expression
        , countryMaterial : Elm.Expression
        , countrySpinning : Elm.Expression
        , countryFabric : Elm.Expression
        , countryDyeing : Elm.Expression
        , countryMaking : Elm.Expression
        , countryDistribution : Elm.Expression
        , countryUse : Elm.Expression
        , countryEndOfLife : Elm.Expression
        , airTransportRatio : Elm.Expression
        , quality : Elm.Expression
        , reparability : Elm.Expression
        , makingWaste : Elm.Expression
        , makingComplexity : Elm.Expression
        , yarnSize : Elm.Expression
        , surfaceMass : Elm.Expression
        , knittingProcess : Elm.Expression
        , disabledSteps : Elm.Expression
        , disabledFading : Elm.Expression
        , dyeingMedium : Elm.Expression
        , printing : Elm.Expression
        , ennoblingHeatSource : Elm.Expression
        }
        -> Elm.Expression
    , materialInput :
        { material : Elm.Expression, share : Elm.Expression } -> Elm.Expression
    }
make_ =
    { query =
        \query_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Inputs" ]
                    "Query"
                    []
                    (Type.record
                        [ ( "mass", Type.namedWith [] "Mass" [] )
                        , ( "materials"
                          , Type.list (Type.namedWith [] "MaterialQuery" [])
                          )
                        , ( "product", Type.namedWith [ "Product" ] "Id" [] )
                        , ( "countrySpinning"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Country" ] "Code" [] ]
                          )
                        , ( "countryFabric"
                          , Type.namedWith [ "Country" ] "Code" []
                          )
                        , ( "countryDyeing"
                          , Type.namedWith [ "Country" ] "Code" []
                          )
                        , ( "countryMaking"
                          , Type.namedWith [ "Country" ] "Code" []
                          )
                        , ( "airTransportRatio"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Split" [] ]
                          )
                        , ( "quality"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "Quality" [] ]
                          )
                        , ( "reparability"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                          )
                        , ( "makingWaste"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Split" [] ]
                          )
                        , ( "makingComplexity"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "MakingComplexity" [] ]
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
                        , ( "disabledSteps"
                          , Type.list (Type.namedWith [] "Label" [])
                          )
                        , ( "disabledFading"
                          , Type.namedWith [] "Maybe" [ Type.bool ]
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
                        , ( "ennoblingHeatSource"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "HeatSource" [] ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "mass" query_args.mass
                    , Tuple.pair "materials" query_args.materials
                    , Tuple.pair "product" query_args.product
                    , Tuple.pair "countrySpinning" query_args.countrySpinning
                    , Tuple.pair "countryFabric" query_args.countryFabric
                    , Tuple.pair "countryDyeing" query_args.countryDyeing
                    , Tuple.pair "countryMaking" query_args.countryMaking
                    , Tuple.pair
                        "airTransportRatio"
                        query_args.airTransportRatio
                    , Tuple.pair "quality" query_args.quality
                    , Tuple.pair "reparability" query_args.reparability
                    , Tuple.pair "makingWaste" query_args.makingWaste
                    , Tuple.pair "makingComplexity" query_args.makingComplexity
                    , Tuple.pair "yarnSize" query_args.yarnSize
                    , Tuple.pair "surfaceMass" query_args.surfaceMass
                    , Tuple.pair "knittingProcess" query_args.knittingProcess
                    , Tuple.pair "disabledSteps" query_args.disabledSteps
                    , Tuple.pair "disabledFading" query_args.disabledFading
                    , Tuple.pair "dyeingMedium" query_args.dyeingMedium
                    , Tuple.pair "printing" query_args.printing
                    , Tuple.pair
                        "ennoblingHeatSource"
                        query_args.ennoblingHeatSource
                    ]
                )
    , materialQuery =
        \materialQuery_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Inputs" ]
                    "MaterialQuery"
                    []
                    (Type.record
                        [ ( "id", Type.namedWith [ "Material" ] "Id" [] )
                        , ( "share", Type.namedWith [] "Split" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "id" materialQuery_args.id
                    , Tuple.pair "share" materialQuery_args.share
                    ]
                )
    , inputs =
        \inputs_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Inputs" ]
                    "Inputs"
                    []
                    (Type.record
                        [ ( "mass", Type.namedWith [] "Mass" [] )
                        , ( "materials"
                          , Type.list (Type.namedWith [] "MaterialInput" [])
                          )
                        , ( "product", Type.namedWith [] "Product" [] )
                        , ( "countryMaterial", Type.namedWith [] "Country" [] )
                        , ( "countrySpinning", Type.namedWith [] "Country" [] )
                        , ( "countryFabric", Type.namedWith [] "Country" [] )
                        , ( "countryDyeing", Type.namedWith [] "Country" [] )
                        , ( "countryMaking", Type.namedWith [] "Country" [] )
                        , ( "countryDistribution"
                          , Type.namedWith [] "Country" []
                          )
                        , ( "countryUse", Type.namedWith [] "Country" [] )
                        , ( "countryEndOfLife", Type.namedWith [] "Country" [] )
                        , ( "airTransportRatio"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Split" [] ]
                          )
                        , ( "quality"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "Quality" [] ]
                          )
                        , ( "reparability"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                          )
                        , ( "makingWaste"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Split" [] ]
                          )
                        , ( "makingComplexity"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "MakingComplexity" [] ]
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
                        , ( "disabledSteps"
                          , Type.list (Type.namedWith [] "Label" [])
                          )
                        , ( "disabledFading"
                          , Type.namedWith [] "Maybe" [ Type.bool ]
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
                        , ( "ennoblingHeatSource"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "HeatSource" [] ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "mass" inputs_args.mass
                    , Tuple.pair "materials" inputs_args.materials
                    , Tuple.pair "product" inputs_args.product
                    , Tuple.pair "countryMaterial" inputs_args.countryMaterial
                    , Tuple.pair "countrySpinning" inputs_args.countrySpinning
                    , Tuple.pair "countryFabric" inputs_args.countryFabric
                    , Tuple.pair "countryDyeing" inputs_args.countryDyeing
                    , Tuple.pair "countryMaking" inputs_args.countryMaking
                    , Tuple.pair
                        "countryDistribution"
                        inputs_args.countryDistribution
                    , Tuple.pair "countryUse" inputs_args.countryUse
                    , Tuple.pair "countryEndOfLife" inputs_args.countryEndOfLife
                    , Tuple.pair
                        "airTransportRatio"
                        inputs_args.airTransportRatio
                    , Tuple.pair "quality" inputs_args.quality
                    , Tuple.pair "reparability" inputs_args.reparability
                    , Tuple.pair "makingWaste" inputs_args.makingWaste
                    , Tuple.pair "makingComplexity" inputs_args.makingComplexity
                    , Tuple.pair "yarnSize" inputs_args.yarnSize
                    , Tuple.pair "surfaceMass" inputs_args.surfaceMass
                    , Tuple.pair "knittingProcess" inputs_args.knittingProcess
                    , Tuple.pair "disabledSteps" inputs_args.disabledSteps
                    , Tuple.pair "disabledFading" inputs_args.disabledFading
                    , Tuple.pair "dyeingMedium" inputs_args.dyeingMedium
                    , Tuple.pair "printing" inputs_args.printing
                    , Tuple.pair
                        "ennoblingHeatSource"
                        inputs_args.ennoblingHeatSource
                    ]
                )
    , materialInput =
        \materialInput_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Inputs" ]
                    "MaterialInput"
                    []
                    (Type.record
                        [ ( "material", Type.namedWith [] "Material" [] )
                        , ( "share", Type.namedWith [] "Split" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "material" materialInput_args.material
                    , Tuple.pair "share" materialInput_args.share
                    ]
                )
    }


call_ :
    { b64encode : Elm.Expression -> Elm.Expression
    , b64decode : Elm.Expression -> Elm.Expression
    , encodeQuery : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    , buildApiQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateProduct : Elm.Expression -> Elm.Expression -> Elm.Expression
    , removeMaterial : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateMaterialShare :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateMaterial :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , addMaterial : Elm.Expression -> Elm.Expression -> Elm.Expression
    , toggleStep : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateStepCountry :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , countryList : Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    , stepsToStrings : Elm.Expression -> Elm.Expression
    , toQuery : Elm.Expression -> Elm.Expression
    , fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getMainMaterial : Elm.Expression -> Elm.Expression
    }
call_ =
    { b64encode =
        \b64encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "b64encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                Type.string
                            )
                    }
                )
                [ b64encodeArg ]
    , b64decode =
        \b64decodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "b64decode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Query" []
                                    ]
                                )
                            )
                    }
                )
                [ b64decodeArg ]
    , encodeQuery =
        \encodeQueryArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "encodeQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeQueryArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , buildApiQuery =
        \buildApiQueryArg buildApiQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "buildApiQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string, Type.namedWith [] "Query" [] ]
                                Type.string
                            )
                    }
                )
                [ buildApiQueryArg, buildApiQueryArg0 ]
    , updateProduct =
        \updateProductArg updateProductArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "updateProduct"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Product" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateProductArg, updateProductArg0 ]
    , removeMaterial =
        \removeMaterialArg removeMaterialArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "removeMaterial"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int, Type.namedWith [] "Query" [] ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ removeMaterialArg, removeMaterialArg0 ]
    , updateMaterialShare =
        \updateMaterialShareArg updateMaterialShareArg0 updateMaterialShareArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "updateMaterialShare"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int
                                , Type.namedWith [] "Split" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateMaterialShareArg
                , updateMaterialShareArg0
                , updateMaterialShareArg1
                ]
    , updateMaterial =
        \updateMaterialArg updateMaterialArg0 updateMaterialArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "updateMaterial"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int
                                , Type.namedWith [] "Material" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateMaterialArg, updateMaterialArg0, updateMaterialArg1 ]
    , addMaterial =
        \addMaterialArg addMaterialArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "addMaterial"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ addMaterialArg, addMaterialArg0 ]
    , toggleStep =
        \toggleStepArg toggleStepArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "toggleStep"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ toggleStepArg, toggleStepArg0 ]
    , updateStepCountry =
        \updateStepCountryArg updateStepCountryArg0 updateStepCountryArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "updateStepCountry"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" []
                                , Type.namedWith [ "Country" ] "Code" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateStepCountryArg
                , updateStepCountryArg0
                , updateStepCountryArg1
                ]
    , countryList =
        \countryListArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "countryList"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" [] ]
                                (Type.list (Type.namedWith [] "Country" []))
                            )
                    }
                )
                [ countryListArg ]
    , toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , stepsToStrings =
        \stepsToStringsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "stepsToStrings"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" [] ]
                                (Type.list (Type.list Type.string))
                            )
                    }
                )
                [ stepsToStringsArg ]
    , toQuery =
        \toQueryArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "toQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Inputs" [] ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ toQueryArg ]
    , fromQuery =
        \fromQueryArg fromQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "fromQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Inputs" []
                                    ]
                                )
                            )
                    }
                )
                [ fromQueryArg, fromQueryArg0 ]
    , getMainMaterial =
        \getMainMaterialArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Inputs" ]
                    , name = "getMainMaterial"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith [] "MaterialInput" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Material" []
                                    ]
                                )
                            )
                    }
                )
                [ getMainMaterialArg ]
    }


values_ :
    { parseBase64Query : Elm.Expression
    , b64encode : Elm.Expression
    , b64decode : Elm.Expression
    , encodeQuery : Elm.Expression
    , decodeQuery : Elm.Expression
    , encode : Elm.Expression
    , buildApiQuery : Elm.Expression
    , presets : Elm.Expression
    , jupeCircuitAsie : Elm.Expression
    , tShirtCotonAsie : Elm.Expression
    , tShirtCotonFrance : Elm.Expression
    , defaultQuery : Elm.Expression
    , updateProduct : Elm.Expression
    , removeMaterial : Elm.Expression
    , updateMaterialShare : Elm.Expression
    , updateMaterial : Elm.Expression
    , addMaterial : Elm.Expression
    , toggleStep : Elm.Expression
    , updateStepCountry : Elm.Expression
    , countryList : Elm.Expression
    , toString : Elm.Expression
    , stepsToStrings : Elm.Expression
    , toQuery : Elm.Expression
    , fromQuery : Elm.Expression
    , getMainMaterial : Elm.Expression
    }
values_ =
    { parseBase64Query =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "parseBase64Query"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Parser"
                        [ Type.function
                            [ Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Query" [] ]
                            ]
                            (Type.var "a")
                        , Type.var "a"
                        ]
                    )
            }
    , b64encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "b64encode"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Query" [] ] Type.string)
            }
    , b64decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "b64decode"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Query" [] ]
                        )
                    )
            }
    , encodeQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "encodeQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "decodeQuery"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Query" [] ]
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , buildApiQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "buildApiQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Query" [] ]
                        Type.string
                    )
            }
    , presets =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "presets"
            , annotation = Just (Type.list (Type.namedWith [] "Query" []))
            }
    , jupeCircuitAsie =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "jupeCircuitAsie"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    , tShirtCotonAsie =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "tShirtCotonAsie"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    , tShirtCotonFrance =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "tShirtCotonFrance"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    , defaultQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "defaultQuery"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    , updateProduct =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateProduct"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , removeMaterial =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "removeMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.int, Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updateMaterialShare =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateMaterialShare"
            , annotation =
                Just
                    (Type.function
                        [ Type.int
                        , Type.namedWith [] "Split" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updateMaterial =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.int
                        , Type.namedWith [] "Material" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , addMaterial =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "addMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , toggleStep =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "toggleStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updateStepCountry =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "updateStepCountry"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , countryList =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "countryList"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.list (Type.namedWith [] "Country" []))
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Inputs" [] ] Type.string
                    )
            }
    , stepsToStrings =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "stepsToStrings"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.list (Type.list Type.string))
                    )
            }
    , toQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "toQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Inputs" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , fromQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "fromQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Inputs" [] ]
                        )
                    )
            }
    , getMainMaterial =
        Elm.value
            { importFrom = [ "Data", "Textile", "Inputs" ]
            , name = "getMainMaterial"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "MaterialInput" []) ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Material" [] ]
                        )
                    )
            }
    }