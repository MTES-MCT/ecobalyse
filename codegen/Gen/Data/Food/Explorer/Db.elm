module Gen.Data.Food.Explorer.Db exposing (annotation_, buildFromJson, call_, empty, isEmpty, make_, moduleName_, values_)

{-| 
@docs moduleName_, buildFromJson, isEmpty, empty, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Explorer", "Db" ]


{-| buildFromJson: TextileDb.Db -> String -> String -> Result String Db -}
buildFromJson : Elm.Expression -> String -> String -> Elm.Expression
buildFromJson buildFromJsonArg buildFromJsonArg0 buildFromJsonArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Db" ]
            , name = "buildFromJson"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "TextileDb" ] "Db" []
                        , Type.string
                        , Type.string
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Db" [] ]
                        )
                    )
            }
        )
        [ buildFromJsonArg
        , Elm.string buildFromJsonArg0
        , Elm.string buildFromJsonArg1
        ]


{-| isEmpty: Db -> Bool -}
isEmpty : Elm.Expression -> Elm.Expression
isEmpty isEmptyArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Db" ]
            , name = "isEmpty"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Db" [] ] Type.bool)
            }
        )
        [ isEmptyArg ]


{-| empty: Db -}
empty : Elm.Expression
empty =
    Elm.value
        { importFrom = [ "Data", "Food", "Explorer", "Db" ]
        , name = "empty"
        , annotation = Just (Type.namedWith [] "Db" [])
        }


annotation_ : { db : Type.Annotation }
annotation_ =
    { db =
        Type.alias
            moduleName_
            "Db"
            []
            (Type.record
                [ ( "countries", Type.list (Type.namedWith [] "Country" []) )
                , ( "transports"
                  , Type.namedWith [ "Transport" ] "Distances" []
                  )
                , ( "processes", Type.list (Type.namedWith [] "Process" []) )
                , ( "products", Type.namedWith [] "Products" [] )
                ]
            )
    }


make_ :
    { db :
        { countries : Elm.Expression
        , transports : Elm.Expression
        , processes : Elm.Expression
        , products : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { db =
        \db_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Db" ]
                    "Db"
                    []
                    (Type.record
                        [ ( "countries"
                          , Type.list (Type.namedWith [] "Country" [])
                          )
                        , ( "transports"
                          , Type.namedWith [ "Transport" ] "Distances" []
                          )
                        , ( "processes"
                          , Type.list (Type.namedWith [] "Process" [])
                          )
                        , ( "products", Type.namedWith [] "Products" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "countries" db_args.countries
                    , Tuple.pair "transports" db_args.transports
                    , Tuple.pair "processes" db_args.processes
                    , Tuple.pair "products" db_args.products
                    ]
                )
    }


call_ :
    { buildFromJson :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , isEmpty : Elm.Expression -> Elm.Expression
    }
call_ =
    { buildFromJson =
        \buildFromJsonArg buildFromJsonArg0 buildFromJsonArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Explorer", "Db" ]
                    , name = "buildFromJson"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "TextileDb" ] "Db" []
                                , Type.string
                                , Type.string
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string, Type.namedWith [] "Db" [] ]
                                )
                            )
                    }
                )
                [ buildFromJsonArg, buildFromJsonArg0, buildFromJsonArg1 ]
    , isEmpty =
        \isEmptyArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Explorer", "Db" ]
                    , name = "isEmpty"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" [] ]
                                Type.bool
                            )
                    }
                )
                [ isEmptyArg ]
    }


values_ :
    { buildFromJson : Elm.Expression
    , isEmpty : Elm.Expression
    , empty : Elm.Expression
    }
values_ =
    { buildFromJson =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Db" ]
            , name = "buildFromJson"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "TextileDb" ] "Db" []
                        , Type.string
                        , Type.string
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Db" [] ]
                        )
                    )
            }
    , isEmpty =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Db" ]
            , name = "isEmpty"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Db" [] ] Type.bool)
            }
    , empty =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Db" ]
            , name = "empty"
            , annotation = Just (Type.namedWith [] "Db" [])
            }
    }