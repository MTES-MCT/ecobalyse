module Gen.Data.Food.Retail exposing (all, ambient, annotation_, call_, computeImpacts, decode, displayNeeds, distributionTransport, encode, fromString, moduleName_, toDisplay, toString, values_)

{-| 
@docs moduleName_, computeImpacts, distributionTransport, decode, encode, toDisplay, fromString, toString, all, displayNeeds, ambient, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Retail" ]


{-| computeImpacts: Volume -> Distribution -> WellKnown -> Impacts -}
computeImpacts :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
computeImpacts computeImpactsArg computeImpactsArg0 computeImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "computeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Volume" []
                        , Type.namedWith [] "Distribution" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ computeImpactsArg, computeImpactsArg0, computeImpactsArg1 ]


{-| distributionTransport: Distribution -> Bool -> Transport -}
distributionTransport : Elm.Expression -> Bool -> Elm.Expression
distributionTransport distributionTransportArg distributionTransportArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "distributionTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [], Type.bool ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ distributionTransportArg, Elm.bool distributionTransportArg0 ]


{-| decode: Decoder Distribution -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Food", "Retail" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "Distribution" [] ]
                )
        }


{-| encode: Distribution -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| toDisplay: Distribution -> String -}
toDisplay : Elm.Expression -> Elm.Expression
toDisplay toDisplayArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "toDisplay"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        Type.string
                    )
            }
        )
        [ toDisplayArg ]


{-| fromString: String -> Result String Distribution -}
fromString : String -> Elm.Expression
fromString fromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Distribution" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromStringArg ]


{-| toString: Distribution -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| all: List Distribution -}
all : Elm.Expression
all =
    Elm.value
        { importFrom = [ "Data", "Food", "Retail" ]
        , name = "all"
        , annotation = Just (Type.list (Type.namedWith [] "Distribution" []))
        }


{-| displayNeeds: Distribution -> String -}
displayNeeds : Elm.Expression -> Elm.Expression
displayNeeds displayNeedsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "displayNeeds"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        Type.string
                    )
            }
        )
        [ displayNeedsArg ]


{-| ambient: Distribution -}
ambient : Elm.Expression
ambient =
    Elm.value
        { importFrom = [ "Data", "Food", "Retail" ]
        , name = "ambient"
        , annotation = Just (Type.namedWith [] "Distribution" [])
        }


annotation_ : { distribution : Type.Annotation }
annotation_ =
    { distribution =
        Type.namedWith [ "Data", "Food", "Retail" ] "Distribution" []
    }


call_ :
    { computeImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , distributionTransport : Elm.Expression -> Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    , toDisplay : Elm.Expression -> Elm.Expression
    , fromString : Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    , displayNeeds : Elm.Expression -> Elm.Expression
    }
call_ =
    { computeImpacts =
        \computeImpactsArg computeImpactsArg0 computeImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "computeImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Volume" []
                                , Type.namedWith [] "Distribution" []
                                , Type.namedWith [] "WellKnown" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ computeImpactsArg, computeImpactsArg0, computeImpactsArg1 ]
    , distributionTransport =
        \distributionTransportArg distributionTransportArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "distributionTransport"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Distribution" []
                                , Type.bool
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ distributionTransportArg, distributionTransportArg0 ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Distribution" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , toDisplay =
        \toDisplayArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "toDisplay"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Distribution" [] ]
                                Type.string
                            )
                    }
                )
                [ toDisplayArg ]
    , fromString =
        \fromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "fromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Distribution" []
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
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Distribution" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , displayNeeds =
        \displayNeedsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Retail" ]
                    , name = "displayNeeds"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Distribution" [] ]
                                Type.string
                            )
                    }
                )
                [ displayNeedsArg ]
    }


values_ :
    { computeImpacts : Elm.Expression
    , distributionTransport : Elm.Expression
    , decode : Elm.Expression
    , encode : Elm.Expression
    , toDisplay : Elm.Expression
    , fromString : Elm.Expression
    , toString : Elm.Expression
    , all : Elm.Expression
    , displayNeeds : Elm.Expression
    , ambient : Elm.Expression
    }
values_ =
    { computeImpacts =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "computeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Volume" []
                        , Type.namedWith [] "Distribution" []
                        , Type.namedWith [] "WellKnown" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , distributionTransport =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "distributionTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [], Type.bool ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Distribution" [] ]
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , toDisplay =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "toDisplay"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        Type.string
                    )
            }
    , fromString =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Distribution" [] ]
                        )
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        Type.string
                    )
            }
    , all =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "all"
            , annotation =
                Just (Type.list (Type.namedWith [] "Distribution" []))
            }
    , displayNeeds =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "displayNeeds"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Distribution" [] ]
                        Type.string
                    )
            }
    , ambient =
        Elm.value
            { importFrom = [ "Data", "Food", "Retail" ]
            , name = "ambient"
            , annotation = Just (Type.namedWith [] "Distribution" [])
            }
    }