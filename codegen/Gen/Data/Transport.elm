module Gen.Data.Transport exposing (add, addRoadWithCooling, annotation_, call_, computeImpacts, decodeDistances, default, defaultInland, emptyDistances, encode, getTransportBetween, make_, moduleName_, roadSeaTransportRatio, sum, totalKm, values_)

{-| 
@docs moduleName_, decodeDistances, encode, getTransportBetween, roadSeaTransportRatio, totalKm, emptyDistances, sum, computeImpacts, addRoadWithCooling, add, defaultInland, default, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Transport" ]


{-| decodeDistances: Decoder Distances -}
decodeDistances : Elm.Expression
decodeDistances =
    Elm.value
        { importFrom = [ "Data", "Transport" ]
        , name = "decodeDistances"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "Distances" [] ]
                )
        }


{-| encode: Transport -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| getTransportBetween: Scope -> Impacts -> Country.Code -> Country.Code -> Distances -> Transport -}
getTransportBetween :
    Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
getTransportBetween getTransportBetweenArg getTransportBetweenArg0 getTransportBetweenArg1 getTransportBetweenArg2 getTransportBetweenArg3 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "getTransportBetween"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.namedWith [] "Impacts" []
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [] "Distances" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ getTransportBetweenArg
        , getTransportBetweenArg0
        , getTransportBetweenArg1
        , getTransportBetweenArg2
        , getTransportBetweenArg3
        ]


{-| {-| Determine road/sea transport ratio, so road transport is priviledged
for shorter distances. A few notes:

  - When road distance is 0, we fully take sea distance
  - When sea distance is 0, we fully take road distance
  - Otherwise we can apply specific ratios

-}

roadSeaTransportRatio: Transport -> Split
-}
roadSeaTransportRatio : Elm.Expression -> Elm.Expression
roadSeaTransportRatio roadSeaTransportRatioArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "roadSeaTransportRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" [] ]
                        (Type.namedWith [] "Split" [])
                    )
            }
        )
        [ roadSeaTransportRatioArg ]


{-| totalKm: Transport -> Float -}
totalKm : Elm.Expression -> Elm.Expression
totalKm totalKmArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "totalKm"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" [] ]
                        Type.float
                    )
            }
        )
        [ totalKmArg ]


{-| emptyDistances: Distances -}
emptyDistances : Elm.Expression
emptyDistances =
    Elm.value
        { importFrom = [ "Data", "Transport" ]
        , name = "emptyDistances"
        , annotation = Just (Type.namedWith [] "Distances" [])
        }


{-| sum: List Transport -> Transport -}
sum : List Elm.Expression -> Elm.Expression
sum sumArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "sum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Transport" []) ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ Elm.list sumArg ]


{-| computeImpacts: { a | wellKnown : Process.WellKnown } -> Mass -> Transport -> Transport -}
computeImpacts :
    { a | wellKnown : Elm.Expression }
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
computeImpacts computeImpactsArg computeImpactsArg0 computeImpactsArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "computeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.extensible
                            "a"
                            [ ( "wellKnown"
                              , Type.namedWith [ "Process" ] "WellKnown" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ Elm.record [ Tuple.pair "wellKnown" computeImpactsArg.wellKnown ]
        , computeImpactsArg0
        , computeImpactsArg1
        ]


{-| addRoadWithCooling: Length.Length -> Bool -> Transport -> Transport -}
addRoadWithCooling : Elm.Expression -> Bool -> Elm.Expression -> Elm.Expression
addRoadWithCooling addRoadWithCoolingArg addRoadWithCoolingArg0 addRoadWithCoolingArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "addRoadWithCooling"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Length" ] "Length" []
                        , Type.bool
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ addRoadWithCoolingArg
        , Elm.bool addRoadWithCoolingArg0
        , addRoadWithCoolingArg1
        ]


{-| add: Transport -> Transport -> Transport -}
add : Elm.Expression -> Elm.Expression -> Elm.Expression
add addArg addArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "add"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" []
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ addArg, addArg0 ]


{-| defaultInland: Scope -> Impacts -> Transport -}
defaultInland : Elm.Expression -> Elm.Expression -> Elm.Expression
defaultInland defaultInlandArg defaultInlandArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "defaultInland"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ defaultInlandArg, defaultInlandArg0 ]


{-| default: Impacts -> Transport -}
default : Elm.Expression -> Elm.Expression
default defaultArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "default"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" [] ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ defaultArg ]


annotation_ : { transport : Type.Annotation, distances : Type.Annotation }
annotation_ =
    { transport =
        Type.alias
            moduleName_
            "Transport"
            []
            (Type.record
                [ ( "road", Type.namedWith [] "Length" [] )
                , ( "roadCooled", Type.namedWith [] "Length" [] )
                , ( "sea", Type.namedWith [] "Length" [] )
                , ( "seaCooled", Type.namedWith [] "Length" [] )
                , ( "air", Type.namedWith [] "Length" [] )
                , ( "impacts", Type.namedWith [] "Impacts" [] )
                ]
            )
    , distances =
        Type.alias
            moduleName_
            "Distances"
            []
            (Type.namedWith
                []
                "AnyDict"
                [ Type.string
                , Type.namedWith [ "Country" ] "Code" []
                , Type.namedWith [] "Distance" []
                ]
            )
    }


make_ :
    { transport :
        { road : Elm.Expression
        , roadCooled : Elm.Expression
        , sea : Elm.Expression
        , seaCooled : Elm.Expression
        , air : Elm.Expression
        , impacts : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { transport =
        \transport_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Transport" ]
                    "Transport"
                    []
                    (Type.record
                        [ ( "road", Type.namedWith [] "Length" [] )
                        , ( "roadCooled", Type.namedWith [] "Length" [] )
                        , ( "sea", Type.namedWith [] "Length" [] )
                        , ( "seaCooled", Type.namedWith [] "Length" [] )
                        , ( "air", Type.namedWith [] "Length" [] )
                        , ( "impacts", Type.namedWith [] "Impacts" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "road" transport_args.road
                    , Tuple.pair "roadCooled" transport_args.roadCooled
                    , Tuple.pair "sea" transport_args.sea
                    , Tuple.pair "seaCooled" transport_args.seaCooled
                    , Tuple.pair "air" transport_args.air
                    , Tuple.pair "impacts" transport_args.impacts
                    ]
                )
    }


call_ :
    { encode : Elm.Expression -> Elm.Expression
    , getTransportBetween :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , roadSeaTransportRatio : Elm.Expression -> Elm.Expression
    , totalKm : Elm.Expression -> Elm.Expression
    , sum : Elm.Expression -> Elm.Expression
    , computeImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , addRoadWithCooling :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , add : Elm.Expression -> Elm.Expression -> Elm.Expression
    , defaultInland : Elm.Expression -> Elm.Expression -> Elm.Expression
    , default : Elm.Expression -> Elm.Expression
    }
call_ =
    { encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Transport" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , getTransportBetween =
        \getTransportBetweenArg getTransportBetweenArg0 getTransportBetweenArg1 getTransportBetweenArg2 getTransportBetweenArg3 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "getTransportBetween"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" []
                                , Type.namedWith [] "Impacts" []
                                , Type.namedWith [ "Country" ] "Code" []
                                , Type.namedWith [ "Country" ] "Code" []
                                , Type.namedWith [] "Distances" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ getTransportBetweenArg
                , getTransportBetweenArg0
                , getTransportBetweenArg1
                , getTransportBetweenArg2
                , getTransportBetweenArg3
                ]
    , roadSeaTransportRatio =
        \roadSeaTransportRatioArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "roadSeaTransportRatio"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Transport" [] ]
                                (Type.namedWith [] "Split" [])
                            )
                    }
                )
                [ roadSeaTransportRatioArg ]
    , totalKm =
        \totalKmArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "totalKm"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Transport" [] ]
                                Type.float
                            )
                    }
                )
                [ totalKmArg ]
    , sum =
        \sumArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "sum"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Transport" []) ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ sumArg ]
    , computeImpacts =
        \computeImpactsArg computeImpactsArg0 computeImpactsArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "computeImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.extensible
                                    "a"
                                    [ ( "wellKnown"
                                      , Type.namedWith
                                            [ "Process" ]
                                            "WellKnown"
                                            []
                                      )
                                    ]
                                , Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Transport" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ computeImpactsArg, computeImpactsArg0, computeImpactsArg1 ]
    , addRoadWithCooling =
        \addRoadWithCoolingArg addRoadWithCoolingArg0 addRoadWithCoolingArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "addRoadWithCooling"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Length" ] "Length" []
                                , Type.bool
                                , Type.namedWith [] "Transport" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ addRoadWithCoolingArg
                , addRoadWithCoolingArg0
                , addRoadWithCoolingArg1
                ]
    , add =
        \addArg addArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "add"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Transport" []
                                , Type.namedWith [] "Transport" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ addArg, addArg0 ]
    , defaultInland =
        \defaultInlandArg defaultInlandArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "defaultInland"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ defaultInlandArg, defaultInlandArg0 ]
    , default =
        \defaultArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Transport" ]
                    , name = "default"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Impacts" [] ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ defaultArg ]
    }


values_ :
    { decodeDistances : Elm.Expression
    , encode : Elm.Expression
    , getTransportBetween : Elm.Expression
    , roadSeaTransportRatio : Elm.Expression
    , totalKm : Elm.Expression
    , emptyDistances : Elm.Expression
    , sum : Elm.Expression
    , computeImpacts : Elm.Expression
    , addRoadWithCooling : Elm.Expression
    , add : Elm.Expression
    , defaultInland : Elm.Expression
    , default : Elm.Expression
    }
values_ =
    { decodeDistances =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "decodeDistances"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Distances" [] ]
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , getTransportBetween =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "getTransportBetween"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.namedWith [] "Impacts" []
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [] "Distances" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , roadSeaTransportRatio =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "roadSeaTransportRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" [] ]
                        (Type.namedWith [] "Split" [])
                    )
            }
    , totalKm =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "totalKm"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" [] ]
                        Type.float
                    )
            }
    , emptyDistances =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "emptyDistances"
            , annotation = Just (Type.namedWith [] "Distances" [])
            }
    , sum =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "sum"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Transport" []) ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , computeImpacts =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "computeImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.extensible
                            "a"
                            [ ( "wellKnown"
                              , Type.namedWith [ "Process" ] "WellKnown" []
                              )
                            ]
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , addRoadWithCooling =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "addRoadWithCooling"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Length" ] "Length" []
                        , Type.bool
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , add =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "add"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Transport" []
                        , Type.namedWith [] "Transport" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , defaultInland =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "defaultInland"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , default =
        Elm.value
            { importFrom = [ "Data", "Transport" ]
            , name = "default"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Impacts" [] ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    }