module Gen.Data.Textile.MakingComplexity exposing (annotation_, call_, caseOf_, decode, fromString, make_, moduleName_, toDuration, toLabel, toString, values_)

{-| 
@docs moduleName_, decode, fromString, toString, toLabel, toDuration, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "MakingComplexity" ]


{-| decode: Decoder MakingComplexity -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Textile", "MakingComplexity" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "MakingComplexity" [] ]
                )
        }


{-| fromString: String -> Result String MakingComplexity -}
fromString : String -> Elm.Expression
fromString fromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string
                            , Type.namedWith [] "MakingComplexity" []
                            ]
                        )
                    )
            }
        )
        [ Elm.string fromStringArg ]


{-| toString: MakingComplexity -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| toLabel: MakingComplexity -> String -}
toLabel : Elm.Expression -> Elm.Expression
toLabel toLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" [] ]
                        Type.string
                    )
            }
        )
        [ toLabelArg ]


{-| toDuration: MakingComplexity -> Duration -}
toDuration : Elm.Expression -> Elm.Expression
toDuration toDurationArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "toDuration"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" [] ]
                        (Type.namedWith [] "Duration" [])
                    )
            }
        )
        [ toDurationArg ]


annotation_ : { makingComplexity : Type.Annotation }
annotation_ =
    { makingComplexity =
        Type.namedWith
            [ "Data", "Textile", "MakingComplexity" ]
            "MakingComplexity"
            []
    }


make_ :
    { veryHigh : Elm.Expression
    , high : Elm.Expression
    , medium : Elm.Expression
    , low : Elm.Expression
    , veryLow : Elm.Expression
    , notApplicable : Elm.Expression
    }
make_ =
    { veryHigh =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "VeryHigh"
            , annotation = Just (Type.namedWith [] "MakingComplexity" [])
            }
    , high =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "High"
            , annotation = Just (Type.namedWith [] "MakingComplexity" [])
            }
    , medium =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "Medium"
            , annotation = Just (Type.namedWith [] "MakingComplexity" [])
            }
    , low =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "Low"
            , annotation = Just (Type.namedWith [] "MakingComplexity" [])
            }
    , veryLow =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "VeryLow"
            , annotation = Just (Type.namedWith [] "MakingComplexity" [])
            }
    , notApplicable =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "NotApplicable"
            , annotation = Just (Type.namedWith [] "MakingComplexity" [])
            }
    }


caseOf_ :
    { makingComplexity :
        Elm.Expression
        -> { makingComplexityTags_0_0
            | veryHigh : Elm.Expression
            , high : Elm.Expression
            , medium : Elm.Expression
            , low : Elm.Expression
            , veryLow : Elm.Expression
            , notApplicable : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { makingComplexity =
        \makingComplexityExpression makingComplexityTags ->
            Elm.Case.custom
                makingComplexityExpression
                (Type.namedWith
                    [ "Data", "Textile", "MakingComplexity" ]
                    "MakingComplexity"
                    []
                )
                [ Elm.Case.branch0 "VeryHigh" makingComplexityTags.veryHigh
                , Elm.Case.branch0 "High" makingComplexityTags.high
                , Elm.Case.branch0 "Medium" makingComplexityTags.medium
                , Elm.Case.branch0 "Low" makingComplexityTags.low
                , Elm.Case.branch0 "VeryLow" makingComplexityTags.veryLow
                , Elm.Case.branch0
                    "NotApplicable"
                    makingComplexityTags.notApplicable
                ]
    }


call_ :
    { fromString : Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    , toLabel : Elm.Expression -> Elm.Expression
    , toDuration : Elm.Expression -> Elm.Expression
    }
call_ =
    { fromString =
        \fromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "MakingComplexity" ]
                    , name = "fromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "MakingComplexity" []
                                    ]
                                )
                            )
                    }
                )
                [ fromStringArg ]
    , toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "MakingComplexity" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "MakingComplexity" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , toLabel =
        \toLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "MakingComplexity" ]
                    , name = "toLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "MakingComplexity" [] ]
                                Type.string
                            )
                    }
                )
                [ toLabelArg ]
    , toDuration =
        \toDurationArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "MakingComplexity" ]
                    , name = "toDuration"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "MakingComplexity" [] ]
                                (Type.namedWith [] "Duration" [])
                            )
                    }
                )
                [ toDurationArg ]
    }


values_ :
    { decode : Elm.Expression
    , fromString : Elm.Expression
    , toString : Elm.Expression
    , toLabel : Elm.Expression
    , toDuration : Elm.Expression
    }
values_ =
    { decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "MakingComplexity" [] ]
                    )
            }
    , fromString =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string
                            , Type.namedWith [] "MakingComplexity" []
                            ]
                        )
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" [] ]
                        Type.string
                    )
            }
    , toLabel =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" [] ]
                        Type.string
                    )
            }
    , toDuration =
        Elm.value
            { importFrom = [ "Data", "Textile", "MakingComplexity" ]
            , name = "toDuration"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "MakingComplexity" [] ]
                        (Type.namedWith [] "Duration" [])
                    )
            }
    }