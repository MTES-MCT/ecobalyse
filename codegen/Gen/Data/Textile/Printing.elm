module Gen.Data.Textile.Printing exposing (annotation_, call_, caseOf_, decode, defaultRatio, encode, fromString, fromStringParam, kindLabel, make_, moduleName_, toFullLabel, toString, values_)

{-| 
@docs moduleName_, toString, toFullLabel, kindLabel, fromString, fromStringParam, encode, defaultRatio, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Printing" ]


{-| toString: Kind -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "toString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Kind" [] ] Type.string)
            }
        )
        [ toStringArg ]


{-| toFullLabel: Printing -> String -}
toFullLabel : Elm.Expression -> Elm.Expression
toFullLabel toFullLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "toFullLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Printing" [] ]
                        Type.string
                    )
            }
        )
        [ toFullLabelArg ]


{-| kindLabel: Kind -> String -}
kindLabel : Elm.Expression -> Elm.Expression
kindLabel kindLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "kindLabel"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Kind" [] ] Type.string)
            }
        )
        [ kindLabelArg ]


{-| fromString: String -> Result String Kind -}
fromString : String -> Elm.Expression
fromString fromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Kind" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromStringArg ]


{-| fromStringParam: String -> Result String Printing -}
fromStringParam : String -> Elm.Expression
fromStringParam fromStringParamArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "fromStringParam"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Printing" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromStringParamArg ]


{-| encode: Printing -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Printing" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| defaultRatio: Split -}
defaultRatio : Elm.Expression
defaultRatio =
    Elm.value
        { importFrom = [ "Data", "Textile", "Printing" ]
        , name = "defaultRatio"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| decode: Decoder Printing -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Textile", "Printing" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Printing" [] ]
                )
        }


annotation_ : { printing : Type.Annotation, kind : Type.Annotation }
annotation_ =
    { printing =
        Type.alias
            moduleName_
            "Printing"
            []
            (Type.record
                [ ( "kind", Type.namedWith [] "Kind" [] )
                , ( "ratio", Type.namedWith [] "Split" [] )
                ]
            )
    , kind = Type.namedWith [ "Data", "Textile", "Printing" ] "Kind" []
    }


make_ :
    { printing :
        { kind : Elm.Expression, ratio : Elm.Expression } -> Elm.Expression
    , pigment : Elm.Expression
    , substantive : Elm.Expression
    }
make_ =
    { printing =
        \printing_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Printing" ]
                    "Printing"
                    []
                    (Type.record
                        [ ( "kind", Type.namedWith [] "Kind" [] )
                        , ( "ratio", Type.namedWith [] "Split" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "kind" printing_args.kind
                    , Tuple.pair "ratio" printing_args.ratio
                    ]
                )
    , pigment =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "Pigment"
            , annotation = Just (Type.namedWith [] "Kind" [])
            }
    , substantive =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "Substantive"
            , annotation = Just (Type.namedWith [] "Kind" [])
            }
    }


caseOf_ :
    { kind :
        Elm.Expression
        -> { kindTags_0_0
            | pigment : Elm.Expression
            , substantive : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { kind =
        \kindExpression kindTags ->
            Elm.Case.custom
                kindExpression
                (Type.namedWith [ "Data", "Textile", "Printing" ] "Kind" [])
                [ Elm.Case.branch0 "Pigment" kindTags.pigment
                , Elm.Case.branch0 "Substantive" kindTags.substantive
                ]
    }


call_ :
    { toString : Elm.Expression -> Elm.Expression
    , toFullLabel : Elm.Expression -> Elm.Expression
    , kindLabel : Elm.Expression -> Elm.Expression
    , fromString : Elm.Expression -> Elm.Expression
    , fromStringParam : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Printing" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Kind" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , toFullLabel =
        \toFullLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Printing" ]
                    , name = "toFullLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Printing" [] ]
                                Type.string
                            )
                    }
                )
                [ toFullLabelArg ]
    , kindLabel =
        \kindLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Printing" ]
                    , name = "kindLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Kind" [] ]
                                Type.string
                            )
                    }
                )
                [ kindLabelArg ]
    , fromString =
        \fromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Printing" ]
                    , name = "fromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string, Type.namedWith [] "Kind" [] ]
                                )
                            )
                    }
                )
                [ fromStringArg ]
    , fromStringParam =
        \fromStringParamArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Printing" ]
                    , name = "fromStringParam"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Printing" []
                                    ]
                                )
                            )
                    }
                )
                [ fromStringParamArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Printing" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Printing" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { toString : Elm.Expression
    , toFullLabel : Elm.Expression
    , kindLabel : Elm.Expression
    , fromString : Elm.Expression
    , fromStringParam : Elm.Expression
    , encode : Elm.Expression
    , defaultRatio : Elm.Expression
    , decode : Elm.Expression
    }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "toString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Kind" [] ] Type.string)
            }
    , toFullLabel =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "toFullLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Printing" [] ]
                        Type.string
                    )
            }
    , kindLabel =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "kindLabel"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Kind" [] ] Type.string)
            }
    , fromString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Kind" [] ]
                        )
                    )
            }
    , fromStringParam =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "fromStringParam"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Printing" [] ]
                        )
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Printing" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , defaultRatio =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "defaultRatio"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Printing" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Printing" [] ]
                    )
            }
    }