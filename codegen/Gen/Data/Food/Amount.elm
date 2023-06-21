module Gen.Data.Food.Amount exposing (annotation_, call_, caseOf_, format, fromUnitAndFloat, getMass, make_, moduleName_, multiplyBy, setFloat, toDisplayTuple, toStandardFloat, values_)

{-| 
@docs moduleName_, toStandardFloat, toDisplayTuple, setFloat, multiplyBy, getMass, fromUnitAndFloat, format, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Amount" ]


{-| toStandardFloat: Amount -> Float -}
toStandardFloat : Elm.Expression -> Elm.Expression
toStandardFloat toStandardFloatArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "toStandardFloat"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Amount" [] ] Type.float)
            }
        )
        [ toStandardFloatArg ]


{-| {-| A tuple used for display: we display units differently than what's used in Agribalyse.
eg: kilograms in agribalyse, grams in our UI, ton.km in agribalyse, kg.km in our UI
-}

toDisplayTuple: Amount -> ( Float, String )
-}
toDisplayTuple : Elm.Expression -> Elm.Expression
toDisplayTuple toDisplayTupleArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "toDisplayTuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Amount" [] ]
                        (Type.tuple Type.float Type.string)
                    )
            }
        )
        [ toDisplayTupleArg ]


{-| {-| Updates an Amount with a new float value, preserving its current unit.
-}

setFloat: Amount -> Float -> Amount
-}
setFloat : Elm.Expression -> Float -> Elm.Expression
setFloat setFloatArg setFloatArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "setFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Amount" [], Type.float ]
                        (Type.namedWith [] "Amount" [])
                    )
            }
        )
        [ setFloatArg, Elm.float setFloatArg0 ]


{-| multiplyBy: Float -> Amount -> Amount -}
multiplyBy : Float -> Elm.Expression -> Elm.Expression
multiplyBy multiplyByArg multiplyByArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "multiplyBy"
            , annotation =
                Just
                    (Type.function
                        [ Type.float, Type.namedWith [] "Amount" [] ]
                        (Type.namedWith [] "Amount" [])
                    )
            }
        )
        [ Elm.float multiplyByArg, multiplyByArg0 ]


{-| getMass: Amount -> Mass -}
getMass : Elm.Expression -> Elm.Expression
getMass getMassArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "getMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Amount" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ getMassArg ]


{-| fromUnitAndFloat: String -> Float -> Result String Amount -}
fromUnitAndFloat : String -> Float -> Elm.Expression
fromUnitAndFloat fromUnitAndFloatArg fromUnitAndFloatArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "fromUnitAndFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.float ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Amount" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromUnitAndFloatArg, Elm.float fromUnitAndFloatArg0 ]


{-| format: Mass -> Amount -> String -}
format : Elm.Expression -> Elm.Expression -> Elm.Expression
format formatArg formatArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "format"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Amount" []
                        ]
                        Type.string
                    )
            }
        )
        [ formatArg, formatArg0 ]


annotation_ : { amount : Type.Annotation }
annotation_ =
    { amount = Type.namedWith [ "Data", "Food", "Amount" ] "Amount" [] }


make_ :
    { energyInKWh : Elm.Expression -> Elm.Expression
    , energyInMJ : Elm.Expression -> Elm.Expression
    , length : Elm.Expression -> Elm.Expression
    , mass : Elm.Expression -> Elm.Expression
    , transport : Elm.Expression -> Elm.Expression
    , volume : Elm.Expression -> Elm.Expression
    }
make_ =
    { energyInKWh =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "EnergyInKWh"
                    , annotation = Just (Type.namedWith [] "Amount" [])
                    }
                )
                [ ar0 ]
    , energyInMJ =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "EnergyInMJ"
                    , annotation = Just (Type.namedWith [] "Amount" [])
                    }
                )
                [ ar0 ]
    , length =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "Length"
                    , annotation = Just (Type.namedWith [] "Amount" [])
                    }
                )
                [ ar0 ]
    , mass =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "Mass"
                    , annotation = Just (Type.namedWith [] "Amount" [])
                    }
                )
                [ ar0 ]
    , transport =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "Transport"
                    , annotation = Just (Type.namedWith [] "Amount" [])
                    }
                )
                [ ar0 ]
    , volume =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "Volume"
                    , annotation = Just (Type.namedWith [] "Amount" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { amount :
        Elm.Expression
        -> { amountTags_0_0
            | energyInKWh : Elm.Expression -> Elm.Expression
            , energyInMJ : Elm.Expression -> Elm.Expression
            , length : Elm.Expression -> Elm.Expression
            , mass : Elm.Expression -> Elm.Expression
            , transport : Elm.Expression -> Elm.Expression
            , volume : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { amount =
        \amountExpression amountTags ->
            Elm.Case.custom
                amountExpression
                (Type.namedWith [ "Data", "Food", "Amount" ] "Amount" [])
                [ Elm.Case.branch1
                    "EnergyInKWh"
                    ( "energy", Type.namedWith [] "Energy" [] )
                    amountTags.energyInKWh
                , Elm.Case.branch1
                    "EnergyInMJ"
                    ( "energy", Type.namedWith [] "Energy" [] )
                    amountTags.energyInMJ
                , Elm.Case.branch1
                    "Length"
                    ( "length", Type.namedWith [] "Length" [] )
                    amountTags.length
                , Elm.Case.branch1
                    "Mass"
                    ( "mass", Type.namedWith [] "Mass" [] )
                    amountTags.mass
                , Elm.Case.branch1
                    "Transport"
                    ( "transportationQuantity"
                    , Type.namedWith [] "TransportationQuantity" []
                    )
                    amountTags.transport
                , Elm.Case.branch1
                    "Volume"
                    ( "volume", Type.namedWith [] "Volume" [] )
                    amountTags.volume
                ]
    }


call_ :
    { toStandardFloat : Elm.Expression -> Elm.Expression
    , toDisplayTuple : Elm.Expression -> Elm.Expression
    , setFloat : Elm.Expression -> Elm.Expression -> Elm.Expression
    , multiplyBy : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getMass : Elm.Expression -> Elm.Expression
    , fromUnitAndFloat : Elm.Expression -> Elm.Expression -> Elm.Expression
    , format : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { toStandardFloat =
        \toStandardFloatArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "toStandardFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Amount" [] ]
                                Type.float
                            )
                    }
                )
                [ toStandardFloatArg ]
    , toDisplayTuple =
        \toDisplayTupleArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "toDisplayTuple"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Amount" [] ]
                                (Type.tuple Type.float Type.string)
                            )
                    }
                )
                [ toDisplayTupleArg ]
    , setFloat =
        \setFloatArg setFloatArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "setFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Amount" [], Type.float ]
                                (Type.namedWith [] "Amount" [])
                            )
                    }
                )
                [ setFloatArg, setFloatArg0 ]
    , multiplyBy =
        \multiplyByArg multiplyByArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "multiplyBy"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.float, Type.namedWith [] "Amount" [] ]
                                (Type.namedWith [] "Amount" [])
                            )
                    }
                )
                [ multiplyByArg, multiplyByArg0 ]
    , getMass =
        \getMassArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "getMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Amount" [] ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ getMassArg ]
    , fromUnitAndFloat =
        \fromUnitAndFloatArg fromUnitAndFloatArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "fromUnitAndFloat"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string, Type.float ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Amount" []
                                    ]
                                )
                            )
                    }
                )
                [ fromUnitAndFloatArg, fromUnitAndFloatArg0 ]
    , format =
        \formatArg formatArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Amount" ]
                    , name = "format"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Amount" []
                                ]
                                Type.string
                            )
                    }
                )
                [ formatArg, formatArg0 ]
    }


values_ :
    { toStandardFloat : Elm.Expression
    , toDisplayTuple : Elm.Expression
    , setFloat : Elm.Expression
    , multiplyBy : Elm.Expression
    , getMass : Elm.Expression
    , fromUnitAndFloat : Elm.Expression
    , format : Elm.Expression
    }
values_ =
    { toStandardFloat =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "toStandardFloat"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Amount" [] ] Type.float)
            }
    , toDisplayTuple =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "toDisplayTuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Amount" [] ]
                        (Type.tuple Type.float Type.string)
                    )
            }
    , setFloat =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "setFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Amount" [], Type.float ]
                        (Type.namedWith [] "Amount" [])
                    )
            }
    , multiplyBy =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "multiplyBy"
            , annotation =
                Just
                    (Type.function
                        [ Type.float, Type.namedWith [] "Amount" [] ]
                        (Type.namedWith [] "Amount" [])
                    )
            }
    , getMass =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "getMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Amount" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , fromUnitAndFloat =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "fromUnitAndFloat"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.float ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Amount" [] ]
                        )
                    )
            }
    , format =
        Elm.value
            { importFrom = [ "Data", "Food", "Amount" ]
            , name = "format"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Amount" []
                        ]
                        Type.string
                    )
            }
    }