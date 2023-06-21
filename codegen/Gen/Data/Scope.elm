module Gen.Data.Scope exposing (annotation_, call_, caseOf_, decode, encode, make_, moduleName_, only, parseSlug, toLabel, toString, values_)

{-| 
@docs moduleName_, toString, toLabel, parseSlug, only, encode, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Scope" ]


{-| toString: Scope -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Scope" [] ] Type.string)
            }
        )
        [ toStringArg ]


{-| toLabel: Scope -> String -}
toLabel : Elm.Expression -> Elm.Expression
toLabel toLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Scope" [] ] Type.string)
            }
        )
        [ toLabelArg ]


{-| parseSlug: Parser (Scope -> a) a -}
parseSlug : Elm.Expression
parseSlug =
    Elm.value
        { importFrom = [ "Data", "Scope" ]
        , name = "parseSlug"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Parser"
                    [ Type.function
                        [ Type.namedWith [] "Scope" [] ]
                        (Type.var "a")
                    , Type.var "a"
                    ]
                )
        }


{-| only: Scope -> List { a | scopes : List Scope } -> List { a | scopes : List Scope } -}
only :
    Elm.Expression
    -> List { a | scopes : List Elm.Expression }
    -> Elm.Expression
only onlyArg onlyArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "only"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.list
                            (Type.extensible
                                "a"
                                [ ( "scopes"
                                  , Type.list (Type.namedWith [] "Scope" [])
                                  )
                                ]
                            )
                        ]
                        (Type.list
                            (Type.extensible
                                "a"
                                [ ( "scopes"
                                  , Type.list (Type.namedWith [] "Scope" [])
                                  )
                                ]
                            )
                        )
                    )
            }
        )
        [ onlyArg
        , Elm.list
            (List.map
                (\unpack ->
                    Elm.record [ Tuple.pair "scopes" (Elm.list unpack.scopes) ]
                )
                onlyArg0
            )
        ]


{-| encode: Scope -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decode: Decoder Scope -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Scope" ]
        , name = "decode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Scope" [] ])
        }


annotation_ : { scope : Type.Annotation }
annotation_ =
    { scope = Type.namedWith [ "Data", "Scope" ] "Scope" [] }


make_ : { food : Elm.Expression, textile : Elm.Expression }
make_ =
    { food =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "Food"
            , annotation = Just (Type.namedWith [] "Scope" [])
            }
    , textile =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "Textile"
            , annotation = Just (Type.namedWith [] "Scope" [])
            }
    }


caseOf_ :
    { scope :
        Elm.Expression
        -> { scopeTags_0_0 | food : Elm.Expression, textile : Elm.Expression }
        -> Elm.Expression
    }
caseOf_ =
    { scope =
        \scopeExpression scopeTags ->
            Elm.Case.custom
                scopeExpression
                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                [ Elm.Case.branch0 "Food" scopeTags.food
                , Elm.Case.branch0 "Textile" scopeTags.textile
                ]
    }


call_ :
    { toString : Elm.Expression -> Elm.Expression
    , toLabel : Elm.Expression -> Elm.Expression
    , only : Elm.Expression -> Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Scope" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , toLabel =
        \toLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Scope" ]
                    , name = "toLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" [] ]
                                Type.string
                            )
                    }
                )
                [ toLabelArg ]
    , only =
        \onlyArg onlyArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Scope" ]
                    , name = "only"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" []
                                , Type.list
                                    (Type.extensible
                                        "a"
                                        [ ( "scopes"
                                          , Type.list
                                                (Type.namedWith [] "Scope" [])
                                          )
                                        ]
                                    )
                                ]
                                (Type.list
                                    (Type.extensible
                                        "a"
                                        [ ( "scopes"
                                          , Type.list
                                                (Type.namedWith [] "Scope" [])
                                          )
                                        ]
                                    )
                                )
                            )
                    }
                )
                [ onlyArg, onlyArg0 ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Scope" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { toString : Elm.Expression
    , toLabel : Elm.Expression
    , parseSlug : Elm.Expression
    , only : Elm.Expression
    , encode : Elm.Expression
    , decode : Elm.Expression
    }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Scope" [] ] Type.string)
            }
    , toLabel =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Scope" [] ] Type.string)
            }
    , parseSlug =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "parseSlug"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Parser"
                        [ Type.function
                            [ Type.namedWith [] "Scope" [] ]
                            (Type.var "a")
                        , Type.var "a"
                        ]
                    )
            }
    , only =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "only"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.list
                            (Type.extensible
                                "a"
                                [ ( "scopes"
                                  , Type.list (Type.namedWith [] "Scope" [])
                                  )
                                ]
                            )
                        ]
                        (Type.list
                            (Type.extensible
                                "a"
                                [ ( "scopes"
                                  , Type.list (Type.namedWith [] "Scope" [])
                                  )
                                ]
                            )
                        )
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Scope" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Scope" [] ]
                    )
            }
    }