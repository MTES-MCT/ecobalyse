module Gen.Data.Country exposing (annotation_, call_, caseOf_, codeFromString, codeToString, decodeCode, decodeList, encode, encodeCode, findByCode, make_, moduleName_, values_)

{-| 
@docs moduleName_, encodeCode, encode, decodeList, decodeCode, findByCode, codeToString, codeFromString, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Country" ]


{-| encodeCode: Code -> Encode.Value -}
encodeCode : Elm.Expression -> Elm.Expression
encodeCode encodeCodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Country" ]
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


{-| encode: Country -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Country" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decodeList: List Process -> Decoder (List Country) -}
decodeList : List Elm.Expression -> Elm.Expression
decodeList decodeListArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Country" []) ]
                        )
                    )
            }
        )
        [ Elm.list decodeListArg ]


{-| decodeCode: Decoder Code -}
decodeCode : Elm.Expression
decodeCode =
    Elm.value
        { importFrom = [ "Data", "Country" ]
        , name = "decodeCode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Code" [] ])
        }


{-| findByCode: Code -> List Country -> Result String Country -}
findByCode : Elm.Expression -> List Elm.Expression -> Elm.Expression
findByCode findByCodeArg findByCodeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "findByCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Code" []
                        , Type.list (Type.namedWith [] "Country" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Country" [] ]
                        )
                    )
            }
        )
        [ findByCodeArg, Elm.list findByCodeArg0 ]


{-| codeToString: Code -> String -}
codeToString : Elm.Expression -> Elm.Expression
codeToString codeToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Country" ]
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
            { importFrom = [ "Data", "Country" ]
            , name = "codeFromString"
            , annotation =
                Just
                    (Type.function [ Type.string ] (Type.namedWith [] "Code" [])
                    )
            }
        )
        [ Elm.string codeFromStringArg ]


annotation_ : { country : Type.Annotation, code : Type.Annotation }
annotation_ =
    { country =
        Type.alias
            moduleName_
            "Country"
            []
            (Type.record
                [ ( "code", Type.namedWith [] "Code" [] )
                , ( "name", Type.string )
                , ( "zone", Type.namedWith [] "Zone" [] )
                , ( "electricityProcess", Type.namedWith [] "Process" [] )
                , ( "heatProcess", Type.namedWith [] "Process" [] )
                , ( "airTransportRatio", Type.namedWith [] "Split" [] )
                , ( "scopes", Type.list (Type.namedWith [] "Scope" []) )
                ]
            )
    , code = Type.namedWith [ "Data", "Country" ] "Code" []
    }


make_ :
    { country :
        { code : Elm.Expression
        , name : Elm.Expression
        , zone : Elm.Expression
        , electricityProcess : Elm.Expression
        , heatProcess : Elm.Expression
        , airTransportRatio : Elm.Expression
        , scopes : Elm.Expression
        }
        -> Elm.Expression
    , code : Elm.Expression -> Elm.Expression
    }
make_ =
    { country =
        \country_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Country" ]
                    "Country"
                    []
                    (Type.record
                        [ ( "code", Type.namedWith [] "Code" [] )
                        , ( "name", Type.string )
                        , ( "zone", Type.namedWith [] "Zone" [] )
                        , ( "electricityProcess"
                          , Type.namedWith [] "Process" []
                          )
                        , ( "heatProcess", Type.namedWith [] "Process" [] )
                        , ( "airTransportRatio", Type.namedWith [] "Split" [] )
                        , ( "scopes", Type.list (Type.namedWith [] "Scope" []) )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "code" country_args.code
                    , Tuple.pair "name" country_args.name
                    , Tuple.pair "zone" country_args.zone
                    , Tuple.pair
                        "electricityProcess"
                        country_args.electricityProcess
                    , Tuple.pair "heatProcess" country_args.heatProcess
                    , Tuple.pair
                        "airTransportRatio"
                        country_args.airTransportRatio
                    , Tuple.pair "scopes" country_args.scopes
                    ]
                )
    , code =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Country" ]
                    , name = "Code"
                    , annotation = Just (Type.namedWith [] "Code" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { code :
        Elm.Expression
        -> { codeTags_0_0 | code : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    }
caseOf_ =
    { code =
        \codeExpression codeTags ->
            Elm.Case.custom
                codeExpression
                (Type.namedWith [ "Data", "Country" ] "Code" [])
                [ Elm.Case.branch1
                    "Code"
                    ( "string.String", Type.string )
                    codeTags.code
                ]
    }


call_ :
    { encodeCode : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    , decodeList : Elm.Expression -> Elm.Expression
    , findByCode : Elm.Expression -> Elm.Expression -> Elm.Expression
    , codeToString : Elm.Expression -> Elm.Expression
    , codeFromString : Elm.Expression -> Elm.Expression
    }
call_ =
    { encodeCode =
        \encodeCodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Country" ]
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
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Country" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Country" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , decodeList =
        \decodeListArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Country" ]
                    , name = "decodeList"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.list (Type.namedWith [] "Country" [])
                                    ]
                                )
                            )
                    }
                )
                [ decodeListArg ]
    , findByCode =
        \findByCodeArg findByCodeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Country" ]
                    , name = "findByCode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Code" []
                                , Type.list (Type.namedWith [] "Country" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Country" []
                                    ]
                                )
                            )
                    }
                )
                [ findByCodeArg, findByCodeArg0 ]
    , codeToString =
        \codeToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Country" ]
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
                    { importFrom = [ "Data", "Country" ]
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
    { encodeCode : Elm.Expression
    , encode : Elm.Expression
    , decodeList : Elm.Expression
    , decodeCode : Elm.Expression
    , findByCode : Elm.Expression
    , codeToString : Elm.Expression
    , codeFromString : Elm.Expression
    }
values_ =
    { encodeCode =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "encodeCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Code" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Country" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeList =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Country" []) ]
                        )
                    )
            }
    , decodeCode =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "decodeCode"
            , annotation =
                Just
                    (Type.namedWith [] "Decoder" [ Type.namedWith [] "Code" [] ]
                    )
            }
    , findByCode =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "findByCode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Code" []
                        , Type.list (Type.namedWith [] "Country" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Country" [] ]
                        )
                    )
            }
    , codeToString =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "codeToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Code" [] ] Type.string)
            }
    , codeFromString =
        Elm.value
            { importFrom = [ "Data", "Country" ]
            , name = "codeFromString"
            , annotation =
                Just
                    (Type.function [ Type.string ] (Type.namedWith [] "Code" [])
                    )
            }
    }