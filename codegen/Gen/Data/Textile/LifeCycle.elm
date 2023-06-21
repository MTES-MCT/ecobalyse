module Gen.Data.Textile.LifeCycle exposing (annotation_, call_, computeFinalImpacts, computeStepsTransport, computeTotalTransportImpacts, encode, fromQuery, getNextEnabledStep, getStep, getStepProp, init, moduleName_, updateStep, updateSteps, values_)

{-| 
@docs moduleName_, encode, updateSteps, updateStep, init, fromQuery, getStepProp, getStep, getNextEnabledStep, computeFinalImpacts, computeTotalTransportImpacts, computeStepsTransport, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "LifeCycle" ]


{-| encode: LifeCycle -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "LifeCycle" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| updateSteps: List Label -> (Step -> Step) -> LifeCycle -> LifeCycle -}
updateSteps :
    List Elm.Expression
    -> (Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
updateSteps updateStepsArg updateStepsArg0 updateStepsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "updateSteps"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Label" [])
                        , Type.function
                            [ Type.namedWith [] "Step" [] ]
                            (Type.namedWith [] "Step" [])
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
        )
        [ Elm.list updateStepsArg
        , Elm.functionReduced "updateStepsUnpack" updateStepsArg0
        , updateStepsArg1
        ]


{-| updateStep: Label -> (Step -> Step) -> LifeCycle -> LifeCycle -}
updateStep :
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
updateStep updateStepArg updateStepArg0 updateStepArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "updateStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.function
                            [ Type.namedWith [] "Step" [] ]
                            (Type.namedWith [] "Step" [])
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
        )
        [ updateStepArg
        , Elm.functionReduced "updateStepUnpack" updateStepArg0
        , updateStepArg1
        ]


{-| init: Db -> Inputs -> LifeCycle -}
init : Elm.Expression -> Elm.Expression -> Elm.Expression
init initArg initArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "init"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Inputs" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
        )
        [ initArg, initArg0 ]


{-| fromQuery: Db -> Inputs.Query -> Result String LifeCycle -}
fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
fromQuery fromQueryArg fromQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "fromQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [ "Inputs" ] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "LifeCycle" [] ]
                        )
                    )
            }
        )
        [ fromQueryArg, fromQueryArg0 ]


{-| getStepProp: Label -> (Step -> a) -> a -> LifeCycle -> a -}
getStepProp :
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
getStepProp getStepPropArg getStepPropArg0 getStepPropArg1 getStepPropArg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "getStepProp"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.function
                            [ Type.namedWith [] "Step" [] ]
                            (Type.var "a")
                        , Type.var "a"
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.var "a")
                    )
            }
        )
        [ getStepPropArg
        , Elm.functionReduced "getStepPropUnpack" getStepPropArg0
        , getStepPropArg1
        , getStepPropArg2
        ]


{-| getStep: Label -> LifeCycle -> Maybe Step -}
getStep : Elm.Expression -> Elm.Expression -> Elm.Expression
getStep getStepArg getStepArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "getStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Step" [] ]
                        )
                    )
            }
        )
        [ getStepArg, getStepArg0 ]


{-| getNextEnabledStep: Label -> LifeCycle -> Maybe Step -}
getNextEnabledStep : Elm.Expression -> Elm.Expression -> Elm.Expression
getNextEnabledStep getNextEnabledStepArg getNextEnabledStepArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "getNextEnabledStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Step" [] ]
                        )
                    )
            }
        )
        [ getNextEnabledStepArg, getNextEnabledStepArg0 ]


{-| computeFinalImpacts: LifeCycle -> Impacts -}
computeFinalImpacts : Elm.Expression -> Elm.Expression
computeFinalImpacts computeFinalImpactsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "computeFinalImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "LifeCycle" [] ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ computeFinalImpactsArg ]


{-| computeTotalTransportImpacts: LifeCycle -> Transport -}
computeTotalTransportImpacts : Elm.Expression -> Elm.Expression
computeTotalTransportImpacts computeTotalTransportImpactsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "computeTotalTransportImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "LifeCycle" [] ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ computeTotalTransportImpactsArg ]


{-| computeStepsTransport: Db -> LifeCycle -> LifeCycle -}
computeStepsTransport : Elm.Expression -> Elm.Expression -> Elm.Expression
computeStepsTransport computeStepsTransportArg computeStepsTransportArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "computeStepsTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
        )
        [ computeStepsTransportArg, computeStepsTransportArg0 ]


annotation_ : { lifeCycle : Type.Annotation }
annotation_ =
    { lifeCycle =
        Type.alias
            moduleName_
            "LifeCycle"
            []
            (Type.namedWith [] "Array" [ Type.namedWith [] "Step" [] ])
    }


call_ :
    { encode : Elm.Expression -> Elm.Expression
    , updateSteps :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateStep :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , init : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getStepProp :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , getStep : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getNextEnabledStep : Elm.Expression -> Elm.Expression -> Elm.Expression
    , computeFinalImpacts : Elm.Expression -> Elm.Expression
    , computeTotalTransportImpacts : Elm.Expression -> Elm.Expression
    , computeStepsTransport : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "LifeCycle" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , updateSteps =
        \updateStepsArg updateStepsArg0 updateStepsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "updateSteps"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Label" [])
                                , Type.function
                                    [ Type.namedWith [] "Step" [] ]
                                    (Type.namedWith [] "Step" [])
                                , Type.namedWith [] "LifeCycle" []
                                ]
                                (Type.namedWith [] "LifeCycle" [])
                            )
                    }
                )
                [ updateStepsArg, updateStepsArg0, updateStepsArg1 ]
    , updateStep =
        \updateStepArg updateStepArg0 updateStepArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "updateStep"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" []
                                , Type.function
                                    [ Type.namedWith [] "Step" [] ]
                                    (Type.namedWith [] "Step" [])
                                , Type.namedWith [] "LifeCycle" []
                                ]
                                (Type.namedWith [] "LifeCycle" [])
                            )
                    }
                )
                [ updateStepArg, updateStepArg0, updateStepArg1 ]
    , init =
        \initArg initArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "init"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Inputs" []
                                ]
                                (Type.namedWith [] "LifeCycle" [])
                            )
                    }
                )
                [ initArg, initArg0 ]
    , fromQuery =
        \fromQueryArg fromQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "fromQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [ "Inputs" ] "Query" []
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "LifeCycle" []
                                    ]
                                )
                            )
                    }
                )
                [ fromQueryArg, fromQueryArg0 ]
    , getStepProp =
        \getStepPropArg getStepPropArg0 getStepPropArg1 getStepPropArg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "getStepProp"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" []
                                , Type.function
                                    [ Type.namedWith [] "Step" [] ]
                                    (Type.var "a")
                                , Type.var "a"
                                , Type.namedWith [] "LifeCycle" []
                                ]
                                (Type.var "a")
                            )
                    }
                )
                [ getStepPropArg
                , getStepPropArg0
                , getStepPropArg1
                , getStepPropArg2
                ]
    , getStep =
        \getStepArg getStepArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "getStep"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" []
                                , Type.namedWith [] "LifeCycle" []
                                ]
                                (Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Step" [] ]
                                )
                            )
                    }
                )
                [ getStepArg, getStepArg0 ]
    , getNextEnabledStep =
        \getNextEnabledStepArg getNextEnabledStepArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "getNextEnabledStep"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" []
                                , Type.namedWith [] "LifeCycle" []
                                ]
                                (Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Step" [] ]
                                )
                            )
                    }
                )
                [ getNextEnabledStepArg, getNextEnabledStepArg0 ]
    , computeFinalImpacts =
        \computeFinalImpactsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "computeFinalImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "LifeCycle" [] ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ computeFinalImpactsArg ]
    , computeTotalTransportImpacts =
        \computeTotalTransportImpactsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "computeTotalTransportImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "LifeCycle" [] ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ computeTotalTransportImpactsArg ]
    , computeStepsTransport =
        \computeStepsTransportArg computeStepsTransportArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "LifeCycle" ]
                    , name = "computeStepsTransport"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "LifeCycle" []
                                ]
                                (Type.namedWith [] "LifeCycle" [])
                            )
                    }
                )
                [ computeStepsTransportArg, computeStepsTransportArg0 ]
    }


values_ :
    { encode : Elm.Expression
    , updateSteps : Elm.Expression
    , updateStep : Elm.Expression
    , init : Elm.Expression
    , fromQuery : Elm.Expression
    , getStepProp : Elm.Expression
    , getStep : Elm.Expression
    , getNextEnabledStep : Elm.Expression
    , computeFinalImpacts : Elm.Expression
    , computeTotalTransportImpacts : Elm.Expression
    , computeStepsTransport : Elm.Expression
    }
values_ =
    { encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "LifeCycle" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , updateSteps =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "updateSteps"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Label" [])
                        , Type.function
                            [ Type.namedWith [] "Step" [] ]
                            (Type.namedWith [] "Step" [])
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
    , updateStep =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "updateStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.function
                            [ Type.namedWith [] "Step" [] ]
                            (Type.namedWith [] "Step" [])
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
    , init =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "init"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Inputs" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
    , fromQuery =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "fromQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [ "Inputs" ] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "LifeCycle" [] ]
                        )
                    )
            }
    , getStepProp =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "getStepProp"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.function
                            [ Type.namedWith [] "Step" [] ]
                            (Type.var "a")
                        , Type.var "a"
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.var "a")
                    )
            }
    , getStep =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "getStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Step" [] ]
                        )
                    )
            }
    , getNextEnabledStep =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "getNextEnabledStep"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" []
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Step" [] ]
                        )
                    )
            }
    , computeFinalImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "computeFinalImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "LifeCycle" [] ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , computeTotalTransportImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "computeTotalTransportImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "LifeCycle" [] ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , computeStepsTransport =
        Elm.value
            { importFrom = [ "Data", "Textile", "LifeCycle" ]
            , name = "computeStepsTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "LifeCycle" []
                        ]
                        (Type.namedWith [] "LifeCycle" [])
                    )
            }
    }