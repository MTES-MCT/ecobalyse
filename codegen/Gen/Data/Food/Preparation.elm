module Gen.Data.Food.Preparation exposing (all, annotation_, apply, call_, caseOf_, decodeId, encodeId, findById, idToString, make_, moduleName_, unused, values_)

{-| 
@docs moduleName_, unused, idToString, findById, encodeId, decodeId, apply, all, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Preparation" ]


{-| unused: List Id -> List Preparation -> List Preparation -}
unused : List Elm.Expression -> List Elm.Expression -> Elm.Expression
unused unusedArg unusedArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "unused"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Id" [])
                        , Type.list (Type.namedWith [] "Preparation" [])
                        ]
                        (Type.list (Type.namedWith [] "Preparation" []))
                    )
            }
        )
        [ Elm.list unusedArg, Elm.list unusedArg0 ]


{-| idToString: Id -> String -}
idToString : Elm.Expression -> Elm.Expression
idToString idToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
        )
        [ idToStringArg ]


{-| findById: Id -> Result String Preparation -}
findById : Elm.Expression -> Elm.Expression
findById findByIdArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "findById"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Preparation" [] ]
                        )
                    )
            }
        )
        [ findByIdArg ]


{-| encodeId: Id -> Encode.Value -}
encodeId : Elm.Expression -> Elm.Expression
encodeId encodeIdArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeIdArg ]


{-| decodeId: Decoder Id -}
decodeId : Elm.Expression
decodeId =
    Elm.value
        { importFrom = [ "Data", "Food", "Preparation" ]
        , name = "decodeId"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Id" [] ])
        }


{-| apply: BuilderDb.Db -> Mass -> Preparation -> Impacts -}
apply : Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
apply applyArg applyArg0 applyArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "apply"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "BuilderDb" ] "Db" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Preparation" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ applyArg, applyArg0, applyArg1 ]


{-| all: List Preparation -}
all : Elm.Expression
all =
    Elm.value
        { importFrom = [ "Data", "Food", "Preparation" ]
        , name = "all"
        , annotation = Just (Type.list (Type.namedWith [] "Preparation" []))
        }


annotation_ : { preparation : Type.Annotation, id : Type.Annotation }
annotation_ =
    { preparation =
        Type.alias
            moduleName_
            "Preparation"
            []
            (Type.record
                [ ( "id", Type.namedWith [] "Id" [] )
                , ( "name", Type.string )
                , ( "elec"
                  , Type.tuple
                        (Type.namedWith [] "Energy" [])
                        (Type.namedWith [] "Split" [])
                  )
                , ( "heat"
                  , Type.tuple
                        (Type.namedWith [] "Energy" [])
                        (Type.namedWith [] "Split" [])
                  )
                , ( "applyRawToCookedRatio", Type.bool )
                ]
            )
    , id = Type.namedWith [ "Data", "Food", "Preparation" ] "Id" []
    }


make_ :
    { preparation :
        { id : Elm.Expression
        , name : Elm.Expression
        , elec : Elm.Expression
        , heat : Elm.Expression
        , applyRawToCookedRatio : Elm.Expression
        }
        -> Elm.Expression
    , id : Elm.Expression -> Elm.Expression
    }
make_ =
    { preparation =
        \preparation_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Preparation" ]
                    "Preparation"
                    []
                    (Type.record
                        [ ( "id", Type.namedWith [] "Id" [] )
                        , ( "name", Type.string )
                        , ( "elec"
                          , Type.tuple
                                (Type.namedWith [] "Energy" [])
                                (Type.namedWith [] "Split" [])
                          )
                        , ( "heat"
                          , Type.tuple
                                (Type.namedWith [] "Energy" [])
                                (Type.namedWith [] "Split" [])
                          )
                        , ( "applyRawToCookedRatio", Type.bool )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "id" preparation_args.id
                    , Tuple.pair "name" preparation_args.name
                    , Tuple.pair "elec" preparation_args.elec
                    , Tuple.pair "heat" preparation_args.heat
                    , Tuple.pair
                        "applyRawToCookedRatio"
                        preparation_args.applyRawToCookedRatio
                    ]
                )
    , id =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Preparation" ]
                    , name = "Id"
                    , annotation = Just (Type.namedWith [] "Id" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { id :
        Elm.Expression
        -> { idTags_0_0 | id : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    }
caseOf_ =
    { id =
        \idExpression idTags ->
            Elm.Case.custom
                idExpression
                (Type.namedWith [ "Data", "Food", "Preparation" ] "Id" [])
                [ Elm.Case.branch1
                    "Id"
                    ( "string.String", Type.string )
                    idTags.id
                ]
    }


call_ :
    { unused : Elm.Expression -> Elm.Expression -> Elm.Expression
    , idToString : Elm.Expression -> Elm.Expression
    , findById : Elm.Expression -> Elm.Expression
    , encodeId : Elm.Expression -> Elm.Expression
    , apply :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { unused =
        \unusedArg unusedArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Preparation" ]
                    , name = "unused"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Id" [])
                                , Type.list (Type.namedWith [] "Preparation" [])
                                ]
                                (Type.list (Type.namedWith [] "Preparation" []))
                            )
                    }
                )
                [ unusedArg, unusedArg0 ]
    , idToString =
        \idToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Preparation" ]
                    , name = "idToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                Type.string
                            )
                    }
                )
                [ idToStringArg ]
    , findById =
        \findByIdArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Preparation" ]
                    , name = "findById"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Preparation" []
                                    ]
                                )
                            )
                    }
                )
                [ findByIdArg ]
    , encodeId =
        \encodeIdArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Preparation" ]
                    , name = "encodeId"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeIdArg ]
    , apply =
        \applyArg applyArg0 applyArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Preparation" ]
                    , name = "apply"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "BuilderDb" ] "Db" []
                                , Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Preparation" []
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ applyArg, applyArg0, applyArg1 ]
    }


values_ :
    { unused : Elm.Expression
    , idToString : Elm.Expression
    , findById : Elm.Expression
    , encodeId : Elm.Expression
    , decodeId : Elm.Expression
    , apply : Elm.Expression
    , all : Elm.Expression
    }
values_ =
    { unused =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "unused"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Id" [])
                        , Type.list (Type.namedWith [] "Preparation" [])
                        ]
                        (Type.list (Type.namedWith [] "Preparation" []))
                    )
            }
    , idToString =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
    , findById =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "findById"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Preparation" [] ]
                        )
                    )
            }
    , encodeId =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeId =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "decodeId"
            , annotation =
                Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Id" [] ])
            }
    , apply =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "apply"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "BuilderDb" ] "Db" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Preparation" []
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , all =
        Elm.value
            { importFrom = [ "Data", "Food", "Preparation" ]
            , name = "all"
            , annotation = Just (Type.list (Type.namedWith [] "Preparation" []))
            }
    }