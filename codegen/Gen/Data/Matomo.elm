module Gen.Data.Matomo exposing (annotation_, call_, decodeStats, encodeStats, make_, moduleName_, values_)

{-| 
@docs moduleName_, encodeStats, decodeStats, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Matomo" ]


{-| encodeStats: List Stat -> String -}
encodeStats : List Elm.Expression -> Elm.Expression
encodeStats encodeStatsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Matomo" ]
            , name = "encodeStats"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Stat" []) ]
                        Type.string
                    )
            }
        )
        [ Elm.list encodeStatsArg ]


{-| decodeStats: String -> Decoder (List Stat) -}
decodeStats : String -> Elm.Expression
decodeStats decodeStatsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Matomo" ]
            , name = "decodeStats"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Stat" []) ]
                        )
                    )
            }
        )
        [ Elm.string decodeStatsArg ]


annotation_ : { stat : Type.Annotation }
annotation_ =
    { stat =
        Type.alias
            moduleName_
            "Stat"
            []
            (Type.record
                [ ( "label", Type.string )
                , ( "hits", Type.int )
                , ( "time", Type.namedWith [] "Posix" [] )
                ]
            )
    }


make_ :
    { stat :
        { label : Elm.Expression, hits : Elm.Expression, time : Elm.Expression }
        -> Elm.Expression
    }
make_ =
    { stat =
        \stat_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Matomo" ]
                    "Stat"
                    []
                    (Type.record
                        [ ( "label", Type.string )
                        , ( "hits", Type.int )
                        , ( "time", Type.namedWith [] "Posix" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "label" stat_args.label
                    , Tuple.pair "hits" stat_args.hits
                    , Tuple.pair "time" stat_args.time
                    ]
                )
    }


call_ :
    { encodeStats : Elm.Expression -> Elm.Expression
    , decodeStats : Elm.Expression -> Elm.Expression
    }
call_ =
    { encodeStats =
        \encodeStatsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Matomo" ]
                    , name = "encodeStats"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Stat" []) ]
                                Type.string
                            )
                    }
                )
                [ encodeStatsArg ]
    , decodeStats =
        \decodeStatsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Matomo" ]
                    , name = "decodeStats"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.list (Type.namedWith [] "Stat" []) ]
                                )
                            )
                    }
                )
                [ decodeStatsArg ]
    }


values_ : { encodeStats : Elm.Expression, decodeStats : Elm.Expression }
values_ =
    { encodeStats =
        Elm.value
            { importFrom = [ "Data", "Matomo" ]
            , name = "encodeStats"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Stat" []) ]
                        Type.string
                    )
            }
    , decodeStats =
        Elm.value
            { importFrom = [ "Data", "Matomo" ]
            , name = "decodeStats"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Stat" []) ]
                        )
                    )
            }
    }