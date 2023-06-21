module Gen.Data.Bookmark exposing (annotation_, call_, caseOf_, decode, encode, filterByScope, findByFoodQuery, findByTextileQuery, isFood, isTextile, make_, moduleName_, sort, toFoodQueries, toId, toQueryDescription, toTextileQueries, values_)

{-| 
@docs moduleName_, toTextileQueries, toQueryDescription, toFoodQueries, toId, sort, findByTextileQuery, findByFoodQuery, filterByScope, isTextile, isFood, encode, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Bookmark" ]


{-| toTextileQueries: List Bookmark -> List ( String, String, TextileQuery.Query ) -}
toTextileQueries : List Elm.Expression -> Elm.Expression
toTextileQueries toTextileQueriesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toTextileQueries"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Bookmark" []) ]
                        (Type.list
                            (Type.triple
                                Type.string
                                Type.string
                                (Type.namedWith [ "TextileQuery" ] "Query" [])
                            )
                        )
                    )
            }
        )
        [ Elm.list toTextileQueriesArg ]


{-| toQueryDescription: 
    { foodDb : WebData BuilderDb.Db, textileDb : TextileDb.Db }
    -> Bookmark
    -> String
-}
toQueryDescription :
    { foodDb : Elm.Expression, textileDb : Elm.Expression }
    -> Elm.Expression
    -> Elm.Expression
toQueryDescription toQueryDescriptionArg toQueryDescriptionArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toQueryDescription"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "foodDb"
                              , Type.namedWith
                                    []
                                    "WebData"
                                    [ Type.namedWith [ "BuilderDb" ] "Db" [] ]
                              )
                            , ( "textileDb"
                              , Type.namedWith [ "TextileDb" ] "Db" []
                              )
                            ]
                        , Type.namedWith [] "Bookmark" []
                        ]
                        Type.string
                    )
            }
        )
        [ Elm.record
            [ Tuple.pair "foodDb" toQueryDescriptionArg.foodDb
            , Tuple.pair "textileDb" toQueryDescriptionArg.textileDb
            ]
        , toQueryDescriptionArg0
        ]


{-| toFoodQueries: List Bookmark -> List ( String, String, FoodQuery.Query ) -}
toFoodQueries : List Elm.Expression -> Elm.Expression
toFoodQueries toFoodQueriesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toFoodQueries"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Bookmark" []) ]
                        (Type.list
                            (Type.triple
                                Type.string
                                Type.string
                                (Type.namedWith [ "FoodQuery" ] "Query" [])
                            )
                        )
                    )
            }
        )
        [ Elm.list toFoodQueriesArg ]


{-| toId: Bookmark -> String -}
toId : Elm.Expression -> Elm.Expression
toId toIdArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" [] ]
                        Type.string
                    )
            }
        )
        [ toIdArg ]


{-| sort: List Bookmark -> List Bookmark -}
sort : List Elm.Expression -> Elm.Expression
sort sortArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "sort"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Bookmark" []) ]
                        (Type.list (Type.namedWith [] "Bookmark" []))
                    )
            }
        )
        [ Elm.list sortArg ]


{-| findByTextileQuery: TextileQuery.Query -> List Bookmark -> Maybe Bookmark -}
findByTextileQuery : Elm.Expression -> List Elm.Expression -> Elm.Expression
findByTextileQuery findByTextileQueryArg findByTextileQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "findByTextileQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "TextileQuery" ] "Query" []
                        , Type.list (Type.namedWith [] "Bookmark" [])
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Bookmark" [] ]
                        )
                    )
            }
        )
        [ findByTextileQueryArg, Elm.list findByTextileQueryArg0 ]


{-| findByFoodQuery: FoodQuery.Query -> List Bookmark -> Maybe Bookmark -}
findByFoodQuery : Elm.Expression -> List Elm.Expression -> Elm.Expression
findByFoodQuery findByFoodQueryArg findByFoodQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "findByFoodQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "FoodQuery" ] "Query" []
                        , Type.list (Type.namedWith [] "Bookmark" [])
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Bookmark" [] ]
                        )
                    )
            }
        )
        [ findByFoodQueryArg, Elm.list findByFoodQueryArg0 ]


{-| filterByScope: Scope -> List Bookmark -> List Bookmark -}
filterByScope : Elm.Expression -> List Elm.Expression -> Elm.Expression
filterByScope filterByScopeArg filterByScopeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "filterByScope"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.list (Type.namedWith [] "Bookmark" [])
                        ]
                        (Type.list (Type.namedWith [] "Bookmark" []))
                    )
            }
        )
        [ filterByScopeArg, Elm.list filterByScopeArg0 ]


{-| isTextile: Bookmark -> Bool -}
isTextile : Elm.Expression -> Elm.Expression
isTextile isTextileArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "isTextile"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Bookmark" [] ] Type.bool
                    )
            }
        )
        [ isTextileArg ]


{-| isFood: Bookmark -> Bool -}
isFood : Elm.Expression -> Elm.Expression
isFood isFoodArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "isFood"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Bookmark" [] ] Type.bool
                    )
            }
        )
        [ isFoodArg ]


{-| encode: Bookmark -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decode: Decoder Bookmark -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Bookmark" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Bookmark" [] ]
                )
        }


annotation_ : { bookmark : Type.Annotation, query : Type.Annotation }
annotation_ =
    { bookmark =
        Type.alias
            moduleName_
            "Bookmark"
            []
            (Type.record
                [ ( "name", Type.string )
                , ( "created", Type.namedWith [] "Posix" [] )
                , ( "query", Type.namedWith [] "Query" [] )
                ]
            )
    , query = Type.namedWith [ "Data", "Bookmark" ] "Query" []
    }


make_ :
    { bookmark :
        { name : Elm.Expression
        , created : Elm.Expression
        , query : Elm.Expression
        }
        -> Elm.Expression
    , food : Elm.Expression -> Elm.Expression
    , textile : Elm.Expression -> Elm.Expression
    }
make_ =
    { bookmark =
        \bookmark_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Bookmark" ]
                    "Bookmark"
                    []
                    (Type.record
                        [ ( "name", Type.string )
                        , ( "created", Type.namedWith [] "Posix" [] )
                        , ( "query", Type.namedWith [] "Query" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "name" bookmark_args.name
                    , Tuple.pair "created" bookmark_args.created
                    , Tuple.pair "query" bookmark_args.query
                    ]
                )
    , food =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "Food"
                    , annotation = Just (Type.namedWith [] "Query" [])
                    }
                )
                [ ar0 ]
    , textile =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "Textile"
                    , annotation = Just (Type.namedWith [] "Query" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { query :
        Elm.Expression
        -> { queryTags_0_0
            | food : Elm.Expression -> Elm.Expression
            , textile : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { query =
        \queryExpression queryTags ->
            Elm.Case.custom
                queryExpression
                (Type.namedWith [ "Data", "Bookmark" ] "Query" [])
                [ Elm.Case.branch1
                    "Food"
                    ( "foodQuery.Query"
                    , Type.namedWith [ "FoodQuery" ] "Query" []
                    )
                    queryTags.food
                , Elm.Case.branch1
                    "Textile"
                    ( "textileQuery.Query"
                    , Type.namedWith [ "TextileQuery" ] "Query" []
                    )
                    queryTags.textile
                ]
    }


call_ :
    { toTextileQueries : Elm.Expression -> Elm.Expression
    , toQueryDescription : Elm.Expression -> Elm.Expression -> Elm.Expression
    , toFoodQueries : Elm.Expression -> Elm.Expression
    , toId : Elm.Expression -> Elm.Expression
    , sort : Elm.Expression -> Elm.Expression
    , findByTextileQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , findByFoodQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , filterByScope : Elm.Expression -> Elm.Expression -> Elm.Expression
    , isTextile : Elm.Expression -> Elm.Expression
    , isFood : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { toTextileQueries =
        \toTextileQueriesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "toTextileQueries"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Bookmark" []) ]
                                (Type.list
                                    (Type.triple
                                        Type.string
                                        Type.string
                                        (Type.namedWith
                                            [ "TextileQuery" ]
                                            "Query"
                                            []
                                        )
                                    )
                                )
                            )
                    }
                )
                [ toTextileQueriesArg ]
    , toQueryDescription =
        \toQueryDescriptionArg toQueryDescriptionArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "toQueryDescription"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.record
                                    [ ( "foodDb"
                                      , Type.namedWith
                                            []
                                            "WebData"
                                            [ Type.namedWith
                                                [ "BuilderDb" ]
                                                "Db"
                                                []
                                            ]
                                      )
                                    , ( "textileDb"
                                      , Type.namedWith [ "TextileDb" ] "Db" []
                                      )
                                    ]
                                , Type.namedWith [] "Bookmark" []
                                ]
                                Type.string
                            )
                    }
                )
                [ toQueryDescriptionArg, toQueryDescriptionArg0 ]
    , toFoodQueries =
        \toFoodQueriesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "toFoodQueries"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Bookmark" []) ]
                                (Type.list
                                    (Type.triple
                                        Type.string
                                        Type.string
                                        (Type.namedWith
                                            [ "FoodQuery" ]
                                            "Query"
                                            []
                                        )
                                    )
                                )
                            )
                    }
                )
                [ toFoodQueriesArg ]
    , toId =
        \toIdArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "toId"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" [] ]
                                Type.string
                            )
                    }
                )
                [ toIdArg ]
    , sort =
        \sortArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "sort"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Bookmark" []) ]
                                (Type.list (Type.namedWith [] "Bookmark" []))
                            )
                    }
                )
                [ sortArg ]
    , findByTextileQuery =
        \findByTextileQueryArg findByTextileQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "findByTextileQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "TextileQuery" ] "Query" []
                                , Type.list (Type.namedWith [] "Bookmark" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Bookmark" [] ]
                                )
                            )
                    }
                )
                [ findByTextileQueryArg, findByTextileQueryArg0 ]
    , findByFoodQuery =
        \findByFoodQueryArg findByFoodQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "findByFoodQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "FoodQuery" ] "Query" []
                                , Type.list (Type.namedWith [] "Bookmark" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Bookmark" [] ]
                                )
                            )
                    }
                )
                [ findByFoodQueryArg, findByFoodQueryArg0 ]
    , filterByScope =
        \filterByScopeArg filterByScopeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "filterByScope"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" []
                                , Type.list (Type.namedWith [] "Bookmark" [])
                                ]
                                (Type.list (Type.namedWith [] "Bookmark" []))
                            )
                    }
                )
                [ filterByScopeArg, filterByScopeArg0 ]
    , isTextile =
        \isTextileArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "isTextile"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" [] ]
                                Type.bool
                            )
                    }
                )
                [ isTextileArg ]
    , isFood =
        \isFoodArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "isFood"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" [] ]
                                Type.bool
                            )
                    }
                )
                [ isFoodArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Bookmark" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { toTextileQueries : Elm.Expression
    , toQueryDescription : Elm.Expression
    , toFoodQueries : Elm.Expression
    , toId : Elm.Expression
    , sort : Elm.Expression
    , findByTextileQuery : Elm.Expression
    , findByFoodQuery : Elm.Expression
    , filterByScope : Elm.Expression
    , isTextile : Elm.Expression
    , isFood : Elm.Expression
    , encode : Elm.Expression
    , decode : Elm.Expression
    }
values_ =
    { toTextileQueries =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toTextileQueries"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Bookmark" []) ]
                        (Type.list
                            (Type.triple
                                Type.string
                                Type.string
                                (Type.namedWith [ "TextileQuery" ] "Query" [])
                            )
                        )
                    )
            }
    , toQueryDescription =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toQueryDescription"
            , annotation =
                Just
                    (Type.function
                        [ Type.record
                            [ ( "foodDb"
                              , Type.namedWith
                                    []
                                    "WebData"
                                    [ Type.namedWith [ "BuilderDb" ] "Db" [] ]
                              )
                            , ( "textileDb"
                              , Type.namedWith [ "TextileDb" ] "Db" []
                              )
                            ]
                        , Type.namedWith [] "Bookmark" []
                        ]
                        Type.string
                    )
            }
    , toFoodQueries =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toFoodQueries"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Bookmark" []) ]
                        (Type.list
                            (Type.triple
                                Type.string
                                Type.string
                                (Type.namedWith [ "FoodQuery" ] "Query" [])
                            )
                        )
                    )
            }
    , toId =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "toId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" [] ]
                        Type.string
                    )
            }
    , sort =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "sort"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Bookmark" []) ]
                        (Type.list (Type.namedWith [] "Bookmark" []))
                    )
            }
    , findByTextileQuery =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "findByTextileQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "TextileQuery" ] "Query" []
                        , Type.list (Type.namedWith [] "Bookmark" [])
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Bookmark" [] ]
                        )
                    )
            }
    , findByFoodQuery =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "findByFoodQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "FoodQuery" ] "Query" []
                        , Type.list (Type.namedWith [] "Bookmark" [])
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Bookmark" [] ]
                        )
                    )
            }
    , filterByScope =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "filterByScope"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" []
                        , Type.list (Type.namedWith [] "Bookmark" [])
                        ]
                        (Type.list (Type.namedWith [] "Bookmark" []))
                    )
            }
    , isTextile =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "isTextile"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Bookmark" [] ] Type.bool
                    )
            }
    , isFood =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "isFood"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Bookmark" [] ] Type.bool
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Bookmark" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Bookmark" [] ]
                    )
            }
    }