module Gen.Data.Food.Transport exposing (annotation_, call_, getLength, inKgKilometers, inTonKilometers, kilometerToTonKilometer, moduleName_, tonKilometers, values_)

{-| 
@docs moduleName_, tonKilometers, kilometerToTonKilometer, inTonKilometers, inKgKilometers, getLength, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Transport" ]


{-| tonKilometers: Float -> TransportationQuantity -}
tonKilometers : Float -> Elm.Expression
tonKilometers tonKilometersArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "tonKilometers"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "TransportationQuantity" [])
                    )
            }
        )
        [ Elm.float tonKilometersArg ]


{-| kilometerToTonKilometer: Length -> Mass -> Mass -}
kilometerToTonKilometer : Elm.Expression -> Elm.Expression -> Elm.Expression
kilometerToTonKilometer kilometerToTonKilometerArg kilometerToTonKilometerArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "kilometerToTonKilometer"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Length" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ kilometerToTonKilometerArg, kilometerToTonKilometerArg0 ]


{-| inTonKilometers: TransportationQuantity -> Float -}
inTonKilometers : Elm.Expression -> Elm.Expression
inTonKilometers inTonKilometersArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "inTonKilometers"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "TransportationQuantity" [] ]
                        Type.float
                    )
            }
        )
        [ inTonKilometersArg ]


{-| inKgKilometers: TransportationQuantity -> Float -}
inKgKilometers : Elm.Expression -> Elm.Expression
inKgKilometers inKgKilometersArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "inKgKilometers"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "TransportationQuantity" [] ]
                        Type.float
                    )
            }
        )
        [ inKgKilometersArg ]


{-| getLength: Mass -> TransportationQuantity -> Length -}
getLength : Elm.Expression -> Elm.Expression -> Elm.Expression
getLength getLengthArg getLengthArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "getLength"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "TransportationQuantity" []
                        ]
                        (Type.namedWith [] "Length" [])
                    )
            }
        )
        [ getLengthArg, getLengthArg0 ]


annotation_ : { transportationQuantity : Type.Annotation }
annotation_ =
    { transportationQuantity =
        Type.alias
            moduleName_
            "TransportationQuantity"
            []
            (Type.namedWith
                [ "Quantity" ]
                "Quantity"
                [ Type.float
                , Type.namedWith
                    [ "Quantity" ]
                    "Product"
                    [ Type.namedWith [ "Mass" ] "Kilograms" []
                    , Type.namedWith [ "Length" ] "Meters" []
                    ]
                ]
            )
    }


call_ :
    { tonKilometers : Elm.Expression -> Elm.Expression
    , kilometerToTonKilometer :
        Elm.Expression -> Elm.Expression -> Elm.Expression
    , inTonKilometers : Elm.Expression -> Elm.Expression
    , inKgKilometers : Elm.Expression -> Elm.Expression
    , getLength : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { tonKilometers =
        \tonKilometersArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Transport" ]
                    , name = "tonKilometers"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float ]
                                (Type.namedWith [] "TransportationQuantity" [])
                            )
                    }
                )
                [ tonKilometersArg ]
    , kilometerToTonKilometer =
        \kilometerToTonKilometerArg kilometerToTonKilometerArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Transport" ]
                    , name = "kilometerToTonKilometer"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Length" []
                                , Type.namedWith [] "Mass" []
                                ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ kilometerToTonKilometerArg, kilometerToTonKilometerArg0 ]
    , inTonKilometers =
        \inTonKilometersArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Transport" ]
                    , name = "inTonKilometers"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "TransportationQuantity" []
                                ]
                                Type.float
                            )
                    }
                )
                [ inTonKilometersArg ]
    , inKgKilometers =
        \inKgKilometersArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Transport" ]
                    , name = "inKgKilometers"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "TransportationQuantity" []
                                ]
                                Type.float
                            )
                    }
                )
                [ inKgKilometersArg ]
    , getLength =
        \getLengthArg getLengthArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Transport" ]
                    , name = "getLength"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "TransportationQuantity" []
                                ]
                                (Type.namedWith [] "Length" [])
                            )
                    }
                )
                [ getLengthArg, getLengthArg0 ]
    }


values_ :
    { tonKilometers : Elm.Expression
    , kilometerToTonKilometer : Elm.Expression
    , inTonKilometers : Elm.Expression
    , inKgKilometers : Elm.Expression
    , getLength : Elm.Expression
    }
values_ =
    { tonKilometers =
        Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "tonKilometers"
            , annotation =
                Just
                    (Type.function
                        [ Type.float ]
                        (Type.namedWith [] "TransportationQuantity" [])
                    )
            }
    , kilometerToTonKilometer =
        Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "kilometerToTonKilometer"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Length" []
                        , Type.namedWith [] "Mass" []
                        ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , inTonKilometers =
        Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "inTonKilometers"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "TransportationQuantity" [] ]
                        Type.float
                    )
            }
    , inKgKilometers =
        Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "inKgKilometers"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "TransportationQuantity" [] ]
                        Type.float
                    )
            }
    , getLength =
        Elm.value
            { importFrom = [ "Data", "Food", "Transport" ]
            , name = "getLength"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "TransportationQuantity" []
                        ]
                        (Type.namedWith [] "Length" [])
                    )
            }
    }