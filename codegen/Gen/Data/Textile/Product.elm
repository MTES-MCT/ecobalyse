module Gen.Data.Textile.Product exposing (annotation_, call_, caseOf_, customDaysOfWear, decodeList, encode, encodeId, findById, getFabricProcess, getMakingDurationInMinutes, idToString, isKnitted, make_, moduleName_, values_)

{-| 
@docs moduleName_, customDaysOfWear, encodeId, encode, decodeList, isKnitted, idToString, findById, getMakingDurationInMinutes, getFabricProcess, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Product" ]


{-| {-| Computes the number of wears and the number of maintainance cycles against
quality and reparability coefficients.
-}

customDaysOfWear: 
    Maybe Unit.Quality
    -> Maybe Unit.Reparability
    -> { productOptions | daysOfWear : Duration, wearsPerCycle : Int }
    -> { daysOfWear : Duration, useNbCycles : Int }
-}
customDaysOfWear :
    Elm.Expression
    -> Elm.Expression
    -> { productOptions | daysOfWear : Elm.Expression, wearsPerCycle : Int }
    -> Elm.Expression
customDaysOfWear customDaysOfWearArg customDaysOfWearArg0 customDaysOfWearArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "customDaysOfWear"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [ "Unit" ] "Quality" [] ]
                        , Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                        , Type.extensible
                            "productOptions"
                            [ ( "daysOfWear", Type.namedWith [] "Duration" [] )
                            , ( "wearsPerCycle", Type.int )
                            ]
                        ]
                        (Type.record
                            [ ( "daysOfWear", Type.namedWith [] "Duration" [] )
                            , ( "useNbCycles", Type.int )
                            ]
                        )
                    )
            }
        )
        [ customDaysOfWearArg
        , customDaysOfWearArg0
        , Elm.record
            [ Tuple.pair "daysOfWear" customDaysOfWearArg1.daysOfWear
            , Tuple.pair
                "wearsPerCycle"
                (Elm.int customDaysOfWearArg1.wearsPerCycle)
            ]
        ]


{-| encodeId: Id -> Encode.Value -}
encodeId : Elm.Expression -> Elm.Expression
encodeId encodeIdArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeIdArg ]


{-| encode: Product -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decodeList: List Process -> Decoder (List Product) -}
decodeList : List Elm.Expression -> Elm.Expression
decodeList decodeListArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Product" []) ]
                        )
                    )
            }
        )
        [ Elm.list decodeListArg ]


{-| isKnitted: Product -> Bool -}
isKnitted : Elm.Expression -> Elm.Expression
isKnitted isKnittedArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "isKnitted"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Product" [] ] Type.bool)
            }
        )
        [ isKnittedArg ]


{-| idToString: Id -> String -}
idToString : Elm.Expression -> Elm.Expression
idToString idToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
        )
        [ idToStringArg ]


{-| findById: Id -> List Product -> Result String Product -}
findById : Elm.Expression -> List Elm.Expression -> Elm.Expression
findById findByIdArg findByIdArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "findById"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" []
                        , Type.list (Type.namedWith [] "Product" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Product" [] ]
                        )
                    )
            }
        )
        [ findByIdArg, Elm.list findByIdArg0 ]


{-| getMakingDurationInMinutes: Product -> Duration -}
getMakingDurationInMinutes : Elm.Expression -> Elm.Expression
getMakingDurationInMinutes getMakingDurationInMinutesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "getMakingDurationInMinutes"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" [] ]
                        (Type.namedWith [] "Duration" [])
                    )
            }
        )
        [ getMakingDurationInMinutesArg ]


{-| getFabricProcess: Maybe Knitting -> Product -> WellKnown -> Process -}
getFabricProcess :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
getFabricProcess getFabricProcessArg getFabricProcessArg0 getFabricProcessArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "getFabricProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Knitting" [] ]
                        , Type.namedWith [] "Product" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
        )
        [ getFabricProcessArg, getFabricProcessArg0, getFabricProcessArg1 ]


annotation_ :
    { product : Type.Annotation
    , id : Type.Annotation
    , fabricOptions : Type.Annotation
    }
annotation_ =
    { product =
        Type.alias
            moduleName_
            "Product"
            []
            (Type.record
                [ ( "id", Type.namedWith [] "Id" [] )
                , ( "name", Type.string )
                , ( "mass", Type.namedWith [] "Mass" [] )
                , ( "surfaceMass", Type.namedWith [ "Unit" ] "SurfaceMass" [] )
                , ( "yarnSize"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                  )
                , ( "fabric", Type.namedWith [] "FabricOptions" [] )
                , ( "dyeing", Type.namedWith [] "DyeingOptions" [] )
                , ( "making", Type.namedWith [] "MakingOptions" [] )
                , ( "use", Type.namedWith [] "UseOptions" [] )
                , ( "endOfLife", Type.namedWith [] "EndOfLifeOptions" [] )
                ]
            )
    , id = Type.namedWith [ "Data", "Textile", "Product" ] "Id" []
    , fabricOptions =
        Type.namedWith [ "Data", "Textile", "Product" ] "FabricOptions" []
    }


make_ :
    { product :
        { id : Elm.Expression
        , name : Elm.Expression
        , mass : Elm.Expression
        , surfaceMass : Elm.Expression
        , yarnSize : Elm.Expression
        , fabric : Elm.Expression
        , dyeing : Elm.Expression
        , making : Elm.Expression
        , use : Elm.Expression
        , endOfLife : Elm.Expression
        }
        -> Elm.Expression
    , id : Elm.Expression -> Elm.Expression
    , knitted : Elm.Expression -> Elm.Expression
    , weaved : Elm.Expression -> Elm.Expression
    }
make_ =
    { product =
        \product_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Product" ]
                    "Product"
                    []
                    (Type.record
                        [ ( "id", Type.namedWith [] "Id" [] )
                        , ( "name", Type.string )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        , ( "surfaceMass"
                          , Type.namedWith [ "Unit" ] "SurfaceMass" []
                          )
                        , ( "yarnSize"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Unit" ] "YarnSize" [] ]
                          )
                        , ( "fabric", Type.namedWith [] "FabricOptions" [] )
                        , ( "dyeing", Type.namedWith [] "DyeingOptions" [] )
                        , ( "making", Type.namedWith [] "MakingOptions" [] )
                        , ( "use", Type.namedWith [] "UseOptions" [] )
                        , ( "endOfLife"
                          , Type.namedWith [] "EndOfLifeOptions" []
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "id" product_args.id
                    , Tuple.pair "name" product_args.name
                    , Tuple.pair "mass" product_args.mass
                    , Tuple.pair "surfaceMass" product_args.surfaceMass
                    , Tuple.pair "yarnSize" product_args.yarnSize
                    , Tuple.pair "fabric" product_args.fabric
                    , Tuple.pair "dyeing" product_args.dyeing
                    , Tuple.pair "making" product_args.making
                    , Tuple.pair "use" product_args.use
                    , Tuple.pair "endOfLife" product_args.endOfLife
                    ]
                )
    , id =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "Id"
                    , annotation = Just (Type.namedWith [] "Id" [])
                    }
                )
                [ ar0 ]
    , knitted =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "Knitted"
                    , annotation = Just (Type.namedWith [] "FabricOptions" [])
                    }
                )
                [ ar0 ]
    , weaved =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "Weaved"
                    , annotation = Just (Type.namedWith [] "FabricOptions" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { id :
        Elm.Expression
        -> { idTags_0_0 | id : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    , fabricOptions :
        Elm.Expression
        -> { fabricOptionsTags_1_0
            | knitted : Elm.Expression -> Elm.Expression
            , weaved : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { id =
        \idExpression idTags ->
            Elm.Case.custom
                idExpression
                (Type.namedWith [ "Data", "Textile", "Product" ] "Id" [])
                [ Elm.Case.branch1
                    "Id"
                    ( "string.String", Type.string )
                    idTags.id
                ]
    , fabricOptions =
        \fabricOptionsExpression fabricOptionsTags ->
            Elm.Case.custom
                fabricOptionsExpression
                (Type.namedWith
                    [ "Data", "Textile", "Product" ]
                    "FabricOptions"
                    []
                )
                [ Elm.Case.branch1
                    "Knitted"
                    ( "process", Type.namedWith [] "Process" [] )
                    fabricOptionsTags.knitted
                , Elm.Case.branch1
                    "Weaved"
                    ( "process", Type.namedWith [] "Process" [] )
                    fabricOptionsTags.weaved
                ]
    }


call_ :
    { customDaysOfWear :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , encodeId : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    , decodeList : Elm.Expression -> Elm.Expression
    , isKnitted : Elm.Expression -> Elm.Expression
    , idToString : Elm.Expression -> Elm.Expression
    , findById : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getMakingDurationInMinutes : Elm.Expression -> Elm.Expression
    , getFabricProcess :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { customDaysOfWear =
        \customDaysOfWearArg customDaysOfWearArg0 customDaysOfWearArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "customDaysOfWear"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [ "Unit" ] "Quality" [] ]
                                , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith
                                        [ "Unit" ]
                                        "Reparability"
                                        []
                                    ]
                                , Type.extensible
                                    "productOptions"
                                    [ ( "daysOfWear"
                                      , Type.namedWith [] "Duration" []
                                      )
                                    , ( "wearsPerCycle", Type.int )
                                    ]
                                ]
                                (Type.record
                                    [ ( "daysOfWear"
                                      , Type.namedWith [] "Duration" []
                                      )
                                    , ( "useNbCycles", Type.int )
                                    ]
                                )
                            )
                    }
                )
                [ customDaysOfWearArg
                , customDaysOfWearArg0
                , customDaysOfWearArg1
                ]
    , encodeId =
        \encodeIdArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "encodeId"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeIdArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Product" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , decodeList =
        \decodeListArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "decodeList"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.list (Type.namedWith [] "Product" [])
                                    ]
                                )
                            )
                    }
                )
                [ decodeListArg ]
    , isKnitted =
        \isKnittedArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "isKnitted"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Product" [] ]
                                Type.bool
                            )
                    }
                )
                [ isKnittedArg ]
    , idToString =
        \idToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "idToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                Type.string
                            )
                    }
                )
                [ idToStringArg ]
    , findById =
        \findByIdArg findByIdArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "findById"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" []
                                , Type.list (Type.namedWith [] "Product" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Product" []
                                    ]
                                )
                            )
                    }
                )
                [ findByIdArg, findByIdArg0 ]
    , getMakingDurationInMinutes =
        \getMakingDurationInMinutesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "getMakingDurationInMinutes"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Product" [] ]
                                (Type.namedWith [] "Duration" [])
                            )
                    }
                )
                [ getMakingDurationInMinutesArg ]
    , getFabricProcess =
        \getFabricProcessArg getFabricProcessArg0 getFabricProcessArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Product" ]
                    , name = "getFabricProcess"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Knitting" [] ]
                                , Type.namedWith [] "Product" []
                                , Type.namedWith [] "WellKnown" []
                                ]
                                (Type.namedWith [] "Process" [])
                            )
                    }
                )
                [ getFabricProcessArg
                , getFabricProcessArg0
                , getFabricProcessArg1
                ]
    }


values_ :
    { customDaysOfWear : Elm.Expression
    , encodeId : Elm.Expression
    , encode : Elm.Expression
    , decodeList : Elm.Expression
    , isKnitted : Elm.Expression
    , idToString : Elm.Expression
    , findById : Elm.Expression
    , getMakingDurationInMinutes : Elm.Expression
    , getFabricProcess : Elm.Expression
    }
values_ =
    { customDaysOfWear =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "customDaysOfWear"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [ "Unit" ] "Quality" [] ]
                        , Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [ "Unit" ] "Reparability" [] ]
                        , Type.extensible
                            "productOptions"
                            [ ( "daysOfWear", Type.namedWith [] "Duration" [] )
                            , ( "wearsPerCycle", Type.int )
                            ]
                        ]
                        (Type.record
                            [ ( "daysOfWear", Type.namedWith [] "Duration" [] )
                            , ( "useNbCycles", Type.int )
                            ]
                        )
                    )
            }
    , encodeId =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeList =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Product" []) ]
                        )
                    )
            }
    , isKnitted =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "isKnitted"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Product" [] ] Type.bool)
            }
    , idToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
    , findById =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "findById"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" []
                        , Type.list (Type.namedWith [] "Product" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Product" [] ]
                        )
                    )
            }
    , getMakingDurationInMinutes =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "getMakingDurationInMinutes"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" [] ]
                        (Type.namedWith [] "Duration" [])
                    )
            }
    , getFabricProcess =
        Elm.value
            { importFrom = [ "Data", "Textile", "Product" ]
            , name = "getFabricProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Knitting" [] ]
                        , Type.namedWith [] "Product" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Process" [])
                    )
            }
    }