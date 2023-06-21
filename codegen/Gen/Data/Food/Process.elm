module Gen.Data.Food.Process exposing (annotation_, call_, caseOf_, codeFromString, codeToString, decodeCode, decodeList, encodeCode, findByCode, findByName, getDisplayName, listByCategory, loadWellKnown, make_, moduleName_, nameFromString, nameToString, values_)

{-| 
@docs moduleName_, loadWellKnown, listByCategory, getDisplayName, findByName, findByCode, encodeCode, decodeList, decodeCode, nameToString, nameFromString, codeToString, codeFromString, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Process" ]


{-| loadWellKnown: List Process -> Result String WellKnown -}
loadWellKnown : List Elm.Expression -> Elm.Expression
loadWellKnown loadWellKnownArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
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


{-| listByCategory: Category -> List Process -> List Process -}
listByCategory : Elm.Expression -> List Elm.Expression -> Elm.Expression
listByCategory listByCategoryArg listByCategoryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "listByCategory"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Category" []
                        , Type.list (Type.namedWith [] "Process" [])
                        ]
                        (Type.list (Type.namedWith [] "Process" []))
                    )
            }
        )
        [ listByCategoryArg, Elm.list listByCategoryArg0 ]


{-| getDisplayName: Process -> String -}
getDisplayName : Elm.Expression -> Elm.Expression
getDisplayName getDisplayNameArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "getDisplayName"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Process" [] ]
                        Type.string
                    )
            }
        )
        [ getDisplayNameArg ]


{-| findByName: List Process -> ProcessName -> Result String Process -}
findByName : List Elm.Expression -> Elm.Expression -> Elm.Expression
findByName findByNameArg findByNameArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "findByName"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" [])
                        , Type.namedWith [] "ProcessName" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Process" [] ]
                        )
                    )
            }
        )
        [ Elm.list findByNameArg, findByNameArg0 ]


{-| findByCode: List Process -> Code -> Result String Process -}
findByCode : List Elm.Expression -> Elm.Expression -> Elm.Expression
findByCode findByCodeArg findByCodeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "findByCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" [])
                        , Type.namedWith [] "Code" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Process" [] ]
                        )
                    )
            }
        )
        [ Elm.list findByCodeArg, findByCodeArg0 ]


{-| encodeCode: Code -> Encode.Value -}
encodeCode : Elm.Expression -> Elm.Expression
encodeCode encodeCodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "encodeCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Code" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeCodeArg ]


{-| decodeList: Decoder (List Process) -}
decodeList : Elm.Expression
decodeList =
    Elm.value
        { importFrom = [ "Data", "Food", "Process" ]
        , name = "decodeList"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.list (Type.namedWith [] "Process" []) ]
                )
        }


{-| decodeCode: Decoder Code -}
decodeCode : Elm.Expression
decodeCode =
    Elm.value
        { importFrom = [ "Data", "Food", "Process" ]
        , name = "decodeCode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Code" [] ])
        }


{-| nameToString: ProcessName -> String -}
nameToString : Elm.Expression -> Elm.Expression
nameToString nameToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "nameToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessName" [] ]
                        Type.string
                    )
            }
        )
        [ nameToStringArg ]


{-| nameFromString: String -> ProcessName -}
nameFromString : String -> Elm.Expression
nameFromString nameFromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "nameFromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [] "ProcessName" [])
                    )
            }
        )
        [ Elm.string nameFromStringArg ]


{-| codeToString: Code -> String -}
codeToString : Elm.Expression -> Elm.Expression
codeToString codeToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "codeToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Code" [] ] Type.string)
            }
        )
        [ codeToStringArg ]


{-| codeFromString: String -> Code -}
codeFromString : String -> Elm.Expression
codeFromString codeFromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "codeFromString"
            , annotation =
                Just
                    (Type.function [ Type.string ] (Type.namedWith [] "Code" [])
                    )
            }
        )
        [ Elm.string codeFromStringArg ]


annotation_ :
    { wellKnown : Type.Annotation
    , process : Type.Annotation
    , processName : Type.Annotation
    , code : Type.Annotation
    , category : Type.Annotation
    }
annotation_ =
    { wellKnown =
        Type.alias
            moduleName_
            "WellKnown"
            []
            (Type.record
                [ ( "lorryTransport", Type.namedWith [] "Process" [] )
                , ( "boatTransport", Type.namedWith [] "Process" [] )
                , ( "planeTransport", Type.namedWith [] "Process" [] )
                , ( "lorryCoolingTransport", Type.namedWith [] "Process" [] )
                , ( "boatCoolingTransport", Type.namedWith [] "Process" [] )
                , ( "water", Type.namedWith [] "Process" [] )
                , ( "lowVoltageElectricity", Type.namedWith [] "Process" [] )
                , ( "domesticGasHeat", Type.namedWith [] "Process" [] )
                ]
            )
    , process =
        Type.alias
            moduleName_
            "Process"
            []
            (Type.record
                [ ( "name", Type.namedWith [] "ProcessName" [] )
                , ( "displayName", Type.namedWith [] "Maybe" [ Type.string ] )
                , ( "impacts", Type.namedWith [ "Impact" ] "Impacts" [] )
                , ( "unit", Type.string )
                , ( "code", Type.namedWith [] "Code" [] )
                , ( "category", Type.namedWith [] "Category" [] )
                , ( "systemDescription", Type.string )
                , ( "categoryTags", Type.list Type.string )
                , ( "comment", Type.namedWith [] "Maybe" [ Type.string ] )
                , ( "alias", Type.namedWith [] "Maybe" [ Type.string ] )
                ]
            )
    , processName =
        Type.namedWith [ "Data", "Food", "Process" ] "ProcessName" []
    , code = Type.namedWith [ "Data", "Food", "Process" ] "Code" []
    , category = Type.namedWith [ "Data", "Food", "Process" ] "Category" []
    }


make_ :
    { wellKnown :
        { lorryTransport : Elm.Expression
        , boatTransport : Elm.Expression
        , planeTransport : Elm.Expression
        , lorryCoolingTransport : Elm.Expression
        , boatCoolingTransport : Elm.Expression
        , water : Elm.Expression
        , lowVoltageElectricity : Elm.Expression
        , domesticGasHeat : Elm.Expression
        }
        -> Elm.Expression
    , process :
        { name : Elm.Expression
        , displayName : Elm.Expression
        , impacts : Elm.Expression
        , unit : Elm.Expression
        , code : Elm.Expression
        , category : Elm.Expression
        , systemDescription : Elm.Expression
        , categoryTags : Elm.Expression
        , comment : Elm.Expression
        , alias : Elm.Expression
        }
        -> Elm.Expression
    , energy : Elm.Expression
    , ingredient : Elm.Expression
    , material : Elm.Expression
    , packaging : Elm.Expression
    , processing : Elm.Expression
    , transform : Elm.Expression
    , transport : Elm.Expression
    , wasteTreatment : Elm.Expression
    }
make_ =
    { wellKnown =
        \wellKnown_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Process" ]
                    "WellKnown"
                    []
                    (Type.record
                        [ ( "lorryTransport", Type.namedWith [] "Process" [] )
                        , ( "boatTransport", Type.namedWith [] "Process" [] )
                        , ( "planeTransport", Type.namedWith [] "Process" [] )
                        , ( "lorryCoolingTransport"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "boatCoolingTransport"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "water", Type.namedWith [] "Process" [] )
                        , ( "lowVoltageElectricity"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "domesticGasHeat", Type.namedWith [] "Process" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "lorryTransport" wellKnown_args.lorryTransport
                    , Tuple.pair "boatTransport" wellKnown_args.boatTransport
                    , Tuple.pair "planeTransport" wellKnown_args.planeTransport
                    , Tuple.pair
                        "lorryCoolingTransport"
                        wellKnown_args.lorryCoolingTransport
                    , Tuple.pair
                        "boatCoolingTransport"
                        wellKnown_args.boatCoolingTransport
                    , Tuple.pair "water" wellKnown_args.water
                    , Tuple.pair
                        "lowVoltageElectricity"
                        wellKnown_args.lowVoltageElectricity
                    , Tuple.pair
                        "domesticGasHeat"
                        wellKnown_args.domesticGasHeat
                    ]
                )
    , process =
        \process_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Process" ]
                    "Process"
                    []
                    (Type.record
                        [ ( "name", Type.namedWith [] "ProcessName" [] )
                        , ( "displayName"
                          , Type.namedWith [] "Maybe" [ Type.string ]
                          )
                        , ( "impacts"
                          , Type.namedWith [ "Impact" ] "Impacts" []
                          )
                        , ( "unit", Type.string )
                        , ( "code", Type.namedWith [] "Code" [] )
                        , ( "category", Type.namedWith [] "Category" [] )
                        , ( "systemDescription", Type.string )
                        , ( "categoryTags", Type.list Type.string )
                        , ( "comment"
                          , Type.namedWith [] "Maybe" [ Type.string ]
                          )
                        , ( "alias", Type.namedWith [] "Maybe" [ Type.string ] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "name" process_args.name
                    , Tuple.pair "displayName" process_args.displayName
                    , Tuple.pair "impacts" process_args.impacts
                    , Tuple.pair "unit" process_args.unit
                    , Tuple.pair "code" process_args.code
                    , Tuple.pair "category" process_args.category
                    , Tuple.pair
                        "systemDescription"
                        process_args.systemDescription
                    , Tuple.pair "categoryTags" process_args.categoryTags
                    , Tuple.pair "comment" process_args.comment
                    , Tuple.pair "alias" process_args.alias
                    ]
                )
    , energy =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Energy"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , ingredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Ingredient"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , material =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Material"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , packaging =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Packaging"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , processing =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Processing"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , transform =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Transform"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , transport =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "Transport"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , wasteTreatment =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "WasteTreatment"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    }


caseOf_ :
    { category :
        Elm.Expression
        -> { categoryTags_0_0
            | energy : Elm.Expression
            , ingredient : Elm.Expression
            , material : Elm.Expression
            , packaging : Elm.Expression
            , processing : Elm.Expression
            , transform : Elm.Expression
            , transport : Elm.Expression
            , wasteTreatment : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { category =
        \categoryExpression categoryTags ->
            Elm.Case.custom
                categoryExpression
                (Type.namedWith [ "Data", "Food", "Process" ] "Category" [])
                [ Elm.Case.branch0 "Energy" categoryTags.energy
                , Elm.Case.branch0 "Ingredient" categoryTags.ingredient
                , Elm.Case.branch0 "Material" categoryTags.material
                , Elm.Case.branch0 "Packaging" categoryTags.packaging
                , Elm.Case.branch0 "Processing" categoryTags.processing
                , Elm.Case.branch0 "Transform" categoryTags.transform
                , Elm.Case.branch0 "Transport" categoryTags.transport
                , Elm.Case.branch0 "WasteTreatment" categoryTags.wasteTreatment
                ]
    }


call_ :
    { loadWellKnown : Elm.Expression -> Elm.Expression
    , listByCategory : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getDisplayName : Elm.Expression -> Elm.Expression
    , findByName : Elm.Expression -> Elm.Expression -> Elm.Expression
    , findByCode : Elm.Expression -> Elm.Expression -> Elm.Expression
    , encodeCode : Elm.Expression -> Elm.Expression
    , nameToString : Elm.Expression -> Elm.Expression
    , nameFromString : Elm.Expression -> Elm.Expression
    , codeToString : Elm.Expression -> Elm.Expression
    , codeFromString : Elm.Expression -> Elm.Expression
    }
call_ =
    { loadWellKnown =
        \loadWellKnownArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
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
    , listByCategory =
        \listByCategoryArg listByCategoryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "listByCategory"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Category" []
                                , Type.list (Type.namedWith [] "Process" [])
                                ]
                                (Type.list (Type.namedWith [] "Process" []))
                            )
                    }
                )
                [ listByCategoryArg, listByCategoryArg0 ]
    , getDisplayName =
        \getDisplayNameArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "getDisplayName"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Process" [] ]
                                Type.string
                            )
                    }
                )
                [ getDisplayNameArg ]
    , findByName =
        \findByNameArg findByNameArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "findByName"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" [])
                                , Type.namedWith [] "ProcessName" []
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
                [ findByNameArg, findByNameArg0 ]
    , findByCode =
        \findByCodeArg findByCodeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "findByCode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" [])
                                , Type.namedWith [] "Code" []
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
                [ findByCodeArg, findByCodeArg0 ]
    , encodeCode =
        \encodeCodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "encodeCode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Code" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeCodeArg ]
    , nameToString =
        \nameToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "nameToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ProcessName" [] ]
                                Type.string
                            )
                    }
                )
                [ nameToStringArg ]
    , nameFromString =
        \nameFromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "nameFromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith [] "ProcessName" [])
                            )
                    }
                )
                [ nameFromStringArg ]
    , codeToString =
        \codeToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "codeToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Code" [] ]
                                Type.string
                            )
                    }
                )
                [ codeToStringArg ]
    , codeFromString =
        \codeFromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Process" ]
                    , name = "codeFromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith [] "Code" [])
                            )
                    }
                )
                [ codeFromStringArg ]
    }


values_ :
    { loadWellKnown : Elm.Expression
    , listByCategory : Elm.Expression
    , getDisplayName : Elm.Expression
    , findByName : Elm.Expression
    , findByCode : Elm.Expression
    , encodeCode : Elm.Expression
    , decodeList : Elm.Expression
    , decodeCode : Elm.Expression
    , nameToString : Elm.Expression
    , nameFromString : Elm.Expression
    , codeToString : Elm.Expression
    , codeFromString : Elm.Expression
    }
values_ =
    { loadWellKnown =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
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
    , listByCategory =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "listByCategory"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Category" []
                        , Type.list (Type.namedWith [] "Process" [])
                        ]
                        (Type.list (Type.namedWith [] "Process" []))
                    )
            }
    , getDisplayName =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "getDisplayName"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Process" [] ]
                        Type.string
                    )
            }
    , findByName =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "findByName"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" [])
                        , Type.namedWith [] "ProcessName" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Process" [] ]
                        )
                    )
            }
    , findByCode =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "findByCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" [])
                        , Type.namedWith [] "Code" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Process" [] ]
                        )
                    )
            }
    , encodeCode =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "encodeCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Code" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeList =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.list (Type.namedWith [] "Process" []) ]
                    )
            }
    , decodeCode =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "decodeCode"
            , annotation =
                Just
                    (Type.namedWith [] "Decoder" [ Type.namedWith [] "Code" [] ]
                    )
            }
    , nameToString =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "nameToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessName" [] ]
                        Type.string
                    )
            }
    , nameFromString =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "nameFromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [] "ProcessName" [])
                    )
            }
    , codeToString =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "codeToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Code" [] ] Type.string)
            }
    , codeFromString =
        Elm.value
            { importFrom = [ "Data", "Food", "Process" ]
            , name = "codeFromString"
            , annotation =
                Just
                    (Type.function [ Type.string ] (Type.namedWith [] "Code" [])
                    )
            }
    }