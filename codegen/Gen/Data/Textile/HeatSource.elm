module Gen.Data.Textile.HeatSource exposing (annotation_, call_, caseOf_, decode, encode, fromString, make_, moduleName_, toLabelWithZone, toString, values_)

{-| 
@docs moduleName_, toString, toLabelWithZone, fromString, encode, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "HeatSource" ]


{-| toString: HeatSource -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "HeatSource" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| toLabelWithZone: Zone -> HeatSource -> String -}
toLabelWithZone : Elm.Expression -> Elm.Expression -> Elm.Expression
toLabelWithZone toLabelWithZoneArg toLabelWithZoneArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "toLabelWithZone"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Zone" []
                        , Type.namedWith [] "HeatSource" []
                        ]
                        Type.string
                    )
            }
        )
        [ toLabelWithZoneArg, toLabelWithZoneArg0 ]


{-| fromString: String -> Result String HeatSource -}
fromString : String -> Elm.Expression
fromString fromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "HeatSource" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromStringArg ]


{-| encode: HeatSource -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "HeatSource" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decode: Decoder HeatSource -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Textile", "HeatSource" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "HeatSource" [] ]
                )
        }


annotation_ : { heatSource : Type.Annotation }
annotation_ =
    { heatSource =
        Type.namedWith [ "Data", "Textile", "HeatSource" ] "HeatSource" []
    }


make_ :
    { coal : Elm.Expression
    , heavyFuel : Elm.Expression
    , lightFuel : Elm.Expression
    , naturalGas : Elm.Expression
    }
make_ =
    { coal =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "Coal"
            , annotation = Just (Type.namedWith [] "HeatSource" [])
            }
    , heavyFuel =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "HeavyFuel"
            , annotation = Just (Type.namedWith [] "HeatSource" [])
            }
    , lightFuel =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "LightFuel"
            , annotation = Just (Type.namedWith [] "HeatSource" [])
            }
    , naturalGas =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "NaturalGas"
            , annotation = Just (Type.namedWith [] "HeatSource" [])
            }
    }


caseOf_ :
    { heatSource :
        Elm.Expression
        -> { heatSourceTags_0_0
            | coal : Elm.Expression
            , heavyFuel : Elm.Expression
            , lightFuel : Elm.Expression
            , naturalGas : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { heatSource =
        \heatSourceExpression heatSourceTags ->
            Elm.Case.custom
                heatSourceExpression
                (Type.namedWith
                    [ "Data", "Textile", "HeatSource" ]
                    "HeatSource"
                    []
                )
                [ Elm.Case.branch0 "Coal" heatSourceTags.coal
                , Elm.Case.branch0 "HeavyFuel" heatSourceTags.heavyFuel
                , Elm.Case.branch0 "LightFuel" heatSourceTags.lightFuel
                , Elm.Case.branch0 "NaturalGas" heatSourceTags.naturalGas
                ]
    }


call_ :
    { toString : Elm.Expression -> Elm.Expression
    , toLabelWithZone : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromString : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "HeatSource" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "HeatSource" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , toLabelWithZone =
        \toLabelWithZoneArg toLabelWithZoneArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "HeatSource" ]
                    , name = "toLabelWithZone"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Zone" []
                                , Type.namedWith [] "HeatSource" []
                                ]
                                Type.string
                            )
                    }
                )
                [ toLabelWithZoneArg, toLabelWithZoneArg0 ]
    , fromString =
        \fromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "HeatSource" ]
                    , name = "fromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "HeatSource" []
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
                    { importFrom = [ "Data", "Textile", "HeatSource" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "HeatSource" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { toString : Elm.Expression
    , toLabelWithZone : Elm.Expression
    , fromString : Elm.Expression
    , encode : Elm.Expression
    , decode : Elm.Expression
    }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "HeatSource" [] ]
                        Type.string
                    )
            }
    , toLabelWithZone =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "toLabelWithZone"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Zone" []
                        , Type.namedWith [] "HeatSource" []
                        ]
                        Type.string
                    )
            }
    , fromString =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "HeatSource" [] ]
                        )
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "HeatSource" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "HeatSource" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "HeatSource" [] ]
                    )
            }
    }