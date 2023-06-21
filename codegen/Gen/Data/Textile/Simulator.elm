module Gen.Data.Textile.Simulator exposing (annotation_, call_, compute, encode, lifeCycleImpacts, make_, moduleName_, values_)

{-| 
@docs moduleName_, lifeCycleImpacts, compute, encode, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Simulator" ]


{-| lifeCycleImpacts: Simulator -> List ( String, List ( String, Float ) ) -}
lifeCycleImpacts : Elm.Expression -> Elm.Expression
lifeCycleImpacts lifeCycleImpactsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Simulator" ]
            , name = "lifeCycleImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Simulator" [] ]
                        (Type.list
                            (Type.tuple
                                Type.string
                                (Type.list (Type.tuple Type.string Type.float))
                            )
                        )
                    )
            }
        )
        [ lifeCycleImpactsArg ]


{-| {-| Computes a single impact.
-}

compute: Db -> Inputs.Query -> Result String Simulator
-}
compute : Elm.Expression -> Elm.Expression -> Elm.Expression
compute computeArg computeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Simulator" ]
            , name = "compute"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [ "Inputs" ] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Simulator" [] ]
                        )
                    )
            }
        )
        [ computeArg, computeArg0 ]


{-| encode: Simulator -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Simulator" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Simulator" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


annotation_ : { simulator : Type.Annotation }
annotation_ =
    { simulator =
        Type.alias
            moduleName_
            "Simulator"
            []
            (Type.record
                [ ( "inputs", Type.namedWith [] "Inputs" [] )
                , ( "lifeCycle", Type.namedWith [] "LifeCycle" [] )
                , ( "impacts", Type.namedWith [] "Impacts" [] )
                , ( "transport", Type.namedWith [] "Transport" [] )
                , ( "daysOfWear", Type.namedWith [] "Duration" [] )
                , ( "useNbCycles", Type.int )
                ]
            )
    }


make_ :
    { simulator :
        { inputs : Elm.Expression
        , lifeCycle : Elm.Expression
        , impacts : Elm.Expression
        , transport : Elm.Expression
        , daysOfWear : Elm.Expression
        , useNbCycles : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { simulator =
        \simulator_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Simulator" ]
                    "Simulator"
                    []
                    (Type.record
                        [ ( "inputs", Type.namedWith [] "Inputs" [] )
                        , ( "lifeCycle", Type.namedWith [] "LifeCycle" [] )
                        , ( "impacts", Type.namedWith [] "Impacts" [] )
                        , ( "transport", Type.namedWith [] "Transport" [] )
                        , ( "daysOfWear", Type.namedWith [] "Duration" [] )
                        , ( "useNbCycles", Type.int )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "inputs" simulator_args.inputs
                    , Tuple.pair "lifeCycle" simulator_args.lifeCycle
                    , Tuple.pair "impacts" simulator_args.impacts
                    , Tuple.pair "transport" simulator_args.transport
                    , Tuple.pair "daysOfWear" simulator_args.daysOfWear
                    , Tuple.pair "useNbCycles" simulator_args.useNbCycles
                    ]
                )
    }


call_ :
    { lifeCycleImpacts : Elm.Expression -> Elm.Expression
    , compute : Elm.Expression -> Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { lifeCycleImpacts =
        \lifeCycleImpactsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Simulator" ]
                    , name = "lifeCycleImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Simulator" [] ]
                                (Type.list
                                    (Type.tuple
                                        Type.string
                                        (Type.list
                                            (Type.tuple Type.string Type.float)
                                        )
                                    )
                                )
                            )
                    }
                )
                [ lifeCycleImpactsArg ]
    , compute =
        \computeArg computeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Simulator" ]
                    , name = "compute"
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
                                    , Type.namedWith [] "Simulator" []
                                    ]
                                )
                            )
                    }
                )
                [ computeArg, computeArg0 ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Simulator" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Simulator" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { lifeCycleImpacts : Elm.Expression
    , compute : Elm.Expression
    , encode : Elm.Expression
    }
values_ =
    { lifeCycleImpacts =
        Elm.value
            { importFrom = [ "Data", "Textile", "Simulator" ]
            , name = "lifeCycleImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Simulator" [] ]
                        (Type.list
                            (Type.tuple
                                Type.string
                                (Type.list (Type.tuple Type.string Type.float))
                            )
                        )
                    )
            }
    , compute =
        Elm.value
            { importFrom = [ "Data", "Textile", "Simulator" ]
            , name = "compute"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [ "Inputs" ] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Simulator" [] ]
                        )
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Simulator" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Simulator" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    }