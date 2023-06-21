module Gen.Data.Split exposing (annotation_, apply, call_, complement, decodeFloat, decodePercent, encodeFloat, encodePercent, fourty, fromFloat, fromPercent, full, half, moduleName_, quarter, tenth, toFloat, toFloatString, toPercent, toPercentString, twenty, values_, zero)

{-| 
@docs moduleName_, encodePercent, encodeFloat, decodePercent, decodeFloat, apply, complement, toPercentString, toFloatString, toPercent, toFloat, fromPercent, fromFloat, quarter, half, fourty, twenty, tenth, full, zero, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Split" ]


{-| encodePercent: Split -> Encode.Value -}
encodePercent : Elm.Expression -> Elm.Expression
encodePercent encodePercentArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "encodePercent"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodePercentArg ]


{-| encodeFloat: Split -> Encode.Value -}
encodeFloat : Elm.Expression -> Elm.Expression
encodeFloat encodeFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "encodeFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeFloatArg ]


{-| decodePercent: Decoder Split -}
decodePercent : Elm.Expression
decodePercent =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "decodePercent"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Split" [] ])
        }


{-| decodeFloat: Decoder Split -}
decodeFloat : Elm.Expression
decodeFloat =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "decodeFloat"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Split" [] ])
        }


{-| apply: Float -> Split -> Float -}
apply : Float -> Elm.Expression -> Elm.Expression
apply applyArg applyArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "apply"
            , annotation =
                Just
                    (Type.function
                        [ Type.float, Type.namedWith [] "Split" [] ]
                        Type.float
                    )
            }
        )
        [ Elm.float applyArg, applyArg0 ]


{-| complement: Split -> Split -}
complement : Elm.Expression -> Elm.Expression
complement complementArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "complement"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" [] ]
                        (Type.namedWith [] "Split" [])
                    )
            }
        )
        [ complementArg ]


{-| toPercentString: Split -> String -}
toPercentString : Elm.Expression -> Elm.Expression
toPercentString toPercentStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toPercentString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
        )
        [ toPercentStringArg ]


{-| toFloatString: Split -> String -}
toFloatString : Elm.Expression -> Elm.Expression
toFloatString toFloatStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toFloatString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
        )
        [ toFloatStringArg ]


{-| toPercent: Split -> Int -}
toPercent : Elm.Expression -> Elm.Expression
toPercent toPercentArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toPercent"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Split" [] ] Type.int)
            }
        )
        [ toPercentArg ]


{-| toFloat: Split -> Float -}
toFloat : Elm.Expression -> Elm.Expression
toFloat toFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toFloat"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Split" [] ] Type.float)
            }
        )
        [ toFloatArg ]


{-| fromPercent: Int -> Result String Split -}
fromPercent : Int -> Elm.Expression
fromPercent fromPercentArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "fromPercent"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Split" [] ]
                        )
                    )
            }
        )
        [ Elm.int fromPercentArg ]


{-| fromFloat: Float -> Result String Split -}
fromFloat : Float -> Elm.Expression
fromFloat fromFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "fromFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Split" [] ]
                        )
                    )
            }
        )
        [ Elm.float fromFloatArg ]


{-| quarter: Split -}
quarter : Elm.Expression
quarter =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "quarter"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| half: Split -}
half : Elm.Expression
half =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "half"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| fourty: Split -}
fourty : Elm.Expression
fourty =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "fourty"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| twenty: Split -}
twenty : Elm.Expression
twenty =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "twenty"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| tenth: Split -}
tenth : Elm.Expression
tenth =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "tenth"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| full: Split -}
full : Elm.Expression
full =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "full"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| zero: Split -}
zero : Elm.Expression
zero =
    Elm.value
        { importFrom = [ "Data", "Split" ]
        , name = "zero"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


annotation_ : { split : Type.Annotation }
annotation_ =
    { split = Type.namedWith [ "Data", "Split" ] "Split" [] }


call_ :
    { encodePercent : Elm.Expression -> Elm.Expression
    , encodeFloat : Elm.Expression -> Elm.Expression
    , apply : Elm.Expression -> Elm.Expression -> Elm.Expression
    , complement : Elm.Expression -> Elm.Expression
    , toPercentString : Elm.Expression -> Elm.Expression
    , toFloatString : Elm.Expression -> Elm.Expression
    , toPercent : Elm.Expression -> Elm.Expression
    , toFloat : Elm.Expression -> Elm.Expression
    , fromPercent : Elm.Expression -> Elm.Expression
    , fromFloat : Elm.Expression -> Elm.Expression
    }
call_ =
    { encodePercent =
        \encodePercentArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "encodePercent"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodePercentArg ]
    , encodeFloat =
        \encodeFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "encodeFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeFloatArg ]
    , apply =
        \applyArg applyArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "apply"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float, Type.namedWith [] "Split" [] ]
                                Type.float
                            )
                    }
                )
                [ applyArg, applyArg0 ]
    , complement =
        \complementArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "complement"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                (Type.namedWith [] "Split" [])
                            )
                    }
                )
                [ complementArg ]
    , toPercentString =
        \toPercentStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "toPercentString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                Type.string
                            )
                    }
                )
                [ toPercentStringArg ]
    , toFloatString =
        \toFloatStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "toFloatString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                Type.string
                            )
                    }
                )
                [ toFloatStringArg ]
    , toPercent =
        \toPercentArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "toPercent"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                Type.int
                            )
                    }
                )
                [ toPercentArg ]
    , toFloat =
        \toFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "toFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Split" [] ]
                                Type.float
                            )
                    }
                )
                [ toFloatArg ]
    , fromPercent =
        \fromPercentArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "fromPercent"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Split" []
                                    ]
                                )
                            )
                    }
                )
                [ fromPercentArg ]
    , fromFloat =
        \fromFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Split" ]
                    , name = "fromFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Split" []
                                    ]
                                )
                            )
                    }
                )
                [ fromFloatArg ]
    }


values_ :
    { encodePercent : Elm.Expression
    , encodeFloat : Elm.Expression
    , decodePercent : Elm.Expression
    , decodeFloat : Elm.Expression
    , apply : Elm.Expression
    , complement : Elm.Expression
    , toPercentString : Elm.Expression
    , toFloatString : Elm.Expression
    , toPercent : Elm.Expression
    , toFloat : Elm.Expression
    , fromPercent : Elm.Expression
    , fromFloat : Elm.Expression
    , quarter : Elm.Expression
    , half : Elm.Expression
    , fourty : Elm.Expression
    , twenty : Elm.Expression
    , tenth : Elm.Expression
    , full : Elm.Expression
    , zero : Elm.Expression
    }
values_ =
    { encodePercent =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "encodePercent"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , encodeFloat =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "encodeFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodePercent =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "decodePercent"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Split" [] ]
                    )
            }
    , decodeFloat =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "decodeFloat"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Split" [] ]
                    )
            }
    , apply =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "apply"
            , annotation =
                Just
                    (Type.function
                        [ Type.float, Type.namedWith [] "Split" [] ]
                        Type.float
                    )
            }
    , complement =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "complement"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Split" [] ]
                        (Type.namedWith [] "Split" [])
                    )
            }
    , toPercentString =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toPercentString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
    , toFloatString =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toFloatString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Split" [] ] Type.string)
            }
    , toPercent =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toPercent"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Split" [] ] Type.int)
            }
    , toFloat =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "toFloat"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Split" [] ] Type.float)
            }
    , fromPercent =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "fromPercent"
            , annotation =
                Just
                    (Type.function
                        [ Type.int ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Split" [] ]
                        )
                    )
            }
    , fromFloat =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "fromFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Split" [] ]
                        )
                    )
            }
    , quarter =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "quarter"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , half =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "half"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , fourty =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "fourty"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , twenty =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "twenty"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , tenth =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "tenth"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , full =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "full"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , zero =
        Elm.value
            { importFrom = [ "Data", "Split" ]
            , name = "zero"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    }