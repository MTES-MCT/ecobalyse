module Gen.Data.Food.Builder.Db exposing (annotation_, buildFromJson, call_, make_, moduleName_, values_)

{-| 
@docs moduleName_, buildFromJson, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Builder", "Db" ]


{-| buildFromJson: TextileDb.Db -> String -> String -> Result String Db -}
buildFromJson : Elm.Expression -> String -> String -> Elm.Expression
buildFromJson buildFromJsonArg buildFromJsonArg0 buildFromJsonArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Db" ]
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
                , ( "ingredients"
                  , Type.list (Type.namedWith [] "Ingredient" [])
                  )
                , ( "wellKnown", Type.namedWith [ "Process" ] "WellKnown" [] )
                ]
            )
    }


make_ :
    { db :
        { countries : Elm.Expression
        , transports : Elm.Expression
        , processes : Elm.Expression
        , ingredients : Elm.Expression
        , wellKnown : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { db =
        \db_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Db" ]
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
                        , ( "ingredients"
                          , Type.list (Type.namedWith [] "Ingredient" [])
                          )
                        , ( "wellKnown"
                          , Type.namedWith [ "Process" ] "WellKnown" []
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "countries" db_args.countries
                    , Tuple.pair "transports" db_args.transports
                    , Tuple.pair "processes" db_args.processes
                    , Tuple.pair "ingredients" db_args.ingredients
                    , Tuple.pair "wellKnown" db_args.wellKnown
                    ]
                )
    }


call_ :
    { buildFromJson :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { buildFromJson =
        \buildFromJsonArg buildFromJsonArg0 buildFromJsonArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Db" ]
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
    }


values_ : { buildFromJson : Elm.Expression }
values_ =
    { buildFromJson =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Db" ]
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
    }