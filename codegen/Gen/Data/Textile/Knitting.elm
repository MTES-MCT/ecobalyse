module Gen.Data.Textile.Knitting exposing (annotation_, call_, caseOf_, decode, encode, fromString, getMakingComplexity, getMakingWaste, make_, moduleName_, toLabel, toString, values_)

{-| 
@docs moduleName_, toString, toLabel, getMakingWaste, getMakingComplexity, fromString, encode, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Knitting" ]


{-| toString: Knitting -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| toLabel: Knitting -> String -}
toLabel : Elm.Expression -> Elm.Expression
toLabel toLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" [] ]
                        Type.string
                    )
            }
        )
        [ toLabelArg ]


{-| getMakingWaste: Split -> Knitting -> Split -}
getMakingWaste : Elm.Expression -> Elm.Expression -> Elm.Expression
getMakingWaste getMakingWasteArg getMakingWasteArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "getMakingWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" []
                        , Type.namedWith [] "Knitting" []
                        ]
                        (Type.namedWith [] "Split" [])
                    )
            }
        )
        [ getMakingWasteArg, getMakingWasteArg0 ]


{-| getMakingComplexity: MakingComplexity -> Knitting -> MakingComplexity -}
getMakingComplexity : Elm.Expression -> Elm.Expression -> Elm.Expression
getMakingComplexity getMakingComplexityArg getMakingComplexityArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "getMakingComplexity"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" []
                        , Type.namedWith [] "Knitting" []
                        ]
                        (Type.namedWith [] "MakingComplexity" [])
                    )
            }
        )
        [ getMakingComplexityArg, getMakingComplexityArg0 ]


{-| fromString: String -> Result String Knitting -}
fromString : String -> Elm.Expression
fromString fromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Knitting" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromStringArg ]


{-| encode: Knitting -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decode: Decoder Knitting -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Textile", "Knitting" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Knitting" [] ]
                )
        }


annotation_ : { knitting : Type.Annotation }
annotation_ =
    { knitting = Type.namedWith [ "Data", "Textile", "Knitting" ] "Knitting" []
    }


make_ :
    { circular : Elm.Expression
    , fullyFashioned : Elm.Expression
    , mix : Elm.Expression
    , seamless : Elm.Expression
    , straight : Elm.Expression
    }
make_ =
    { circular =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "Circular"
            , annotation = Just (Type.namedWith [] "Knitting" [])
            }
    , fullyFashioned =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "FullyFashioned"
            , annotation = Just (Type.namedWith [] "Knitting" [])
            }
    , mix =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "Mix"
            , annotation = Just (Type.namedWith [] "Knitting" [])
            }
    , seamless =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "Seamless"
            , annotation = Just (Type.namedWith [] "Knitting" [])
            }
    , straight =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "Straight"
            , annotation = Just (Type.namedWith [] "Knitting" [])
            }
    }


caseOf_ :
    { knitting :
        Elm.Expression
        -> { knittingTags_0_0
            | circular : Elm.Expression
            , fullyFashioned : Elm.Expression
            , mix : Elm.Expression
            , seamless : Elm.Expression
            , straight : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { knitting =
        \knittingExpression knittingTags ->
            Elm.Case.custom
                knittingExpression
                (Type.namedWith [ "Data", "Textile", "Knitting" ] "Knitting" [])
                [ Elm.Case.branch0 "Circular" knittingTags.circular
                , Elm.Case.branch0 "FullyFashioned" knittingTags.fullyFashioned
                , Elm.Case.branch0 "Mix" knittingTags.mix
                , Elm.Case.branch0 "Seamless" knittingTags.seamless
                , Elm.Case.branch0 "Straight" knittingTags.straight
                ]
    }


call_ :
    { toString : Elm.Expression -> Elm.Expression
    , toLabel : Elm.Expression -> Elm.Expression
    , getMakingWaste : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getMakingComplexity : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromString : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Knitting" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Knitting" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , toLabel =
        \toLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Knitting" ]
                    , name = "toLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Knitting" [] ]
                                Type.string
                            )
                    }
                )
                [ toLabelArg ]
    , getMakingWaste =
        \getMakingWasteArg getMakingWasteArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Knitting" ]
                    , name = "getMakingWaste"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" []
                                , Type.namedWith [] "Knitting" []
                                ]
                                (Type.namedWith [] "Split" [])
                            )
                    }
                )
                [ getMakingWasteArg, getMakingWasteArg0 ]
    , getMakingComplexity =
        \getMakingComplexityArg getMakingComplexityArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Knitting" ]
                    , name = "getMakingComplexity"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "MakingComplexity" []
                                , Type.namedWith [] "Knitting" []
                                ]
                                (Type.namedWith [] "MakingComplexity" [])
                            )
                    }
                )
                [ getMakingComplexityArg, getMakingComplexityArg0 ]
    , fromString =
        \fromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Knitting" ]
                    , name = "fromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Knitting" []
                                    ]
                                )
                            )
                    }
                )
                [ fromStringArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Knitting" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Knitting" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { toString : Elm.Expression
    , toLabel : Elm.Expression
    , getMakingWaste : Elm.Expression
    , getMakingComplexity : Elm.Expression
    , fromString : Elm.Expression
    , encode : Elm.Expression
    , decode : Elm.Expression
    }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" [] ]
                        Type.string
                    )
            }
    , toLabel =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" [] ]
                        Type.string
                    )
            }
    , getMakingWaste =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "getMakingWaste"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" []
                        , Type.namedWith [] "Knitting" []
                        ]
                        (Type.namedWith [] "Split" [])
                    )
            }
    , getMakingComplexity =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "getMakingComplexity"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" []
                        , Type.namedWith [] "Knitting" []
                        ]
                        (Type.namedWith [] "MakingComplexity" [])
                    )
            }
    , fromString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Knitting" [] ]
                        )
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Knitting" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Knitting" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Knitting" [] ]
                    )
            }
    }