module Gen.Data.Textile.Db exposing (annotation_, buildFromJson, call_, make_, moduleName_, values_)

{-| 
@docs moduleName_, buildFromJson, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Db" ]


{-| buildFromJson: String -> Result String Db -}
buildFromJson : String -> Elm.Expression
buildFromJson buildFromJsonArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Db" ]
            , name = "buildFromJson"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Db" [] ]
                        )
                    )
            }
        )
        [ Elm.string buildFromJsonArg ]


annotation_ : { db : Type.Annotation }
annotation_ =
    { db =
        Type.alias
            moduleName_
            "Db"
            []
            (Type.record
                [ ( "processes", Type.list (Type.namedWith [] "Process" []) )
                , ( "countries", Type.list (Type.namedWith [] "Country" []) )
                , ( "materials", Type.list (Type.namedWith [] "Material" []) )
                , ( "products", Type.list (Type.namedWith [] "Product" []) )
                , ( "transports", Type.namedWith [] "Distances" [] )
                , ( "wellKnown", Type.namedWith [ "Process" ] "WellKnown" [] )
                ]
            )
    }


make_ :
    { db :
        { processes : Elm.Expression
        , countries : Elm.Expression
        , materials : Elm.Expression
        , products : Elm.Expression
        , transports : Elm.Expression
        , wellKnown : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { db =
        \db_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Db" ]
                    "Db"
                    []
                    (Type.record
                        [ ( "processes"
                          , Type.list (Type.namedWith [] "Process" [])
                          )
                        , ( "countries"
                          , Type.list (Type.namedWith [] "Country" [])
                          )
                        , ( "materials"
                          , Type.list (Type.namedWith [] "Material" [])
                          )
                        , ( "products"
                          , Type.list (Type.namedWith [] "Product" [])
                          )
                        , ( "transports", Type.namedWith [] "Distances" [] )
                        , ( "wellKnown"
                          , Type.namedWith [ "Process" ] "WellKnown" []
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "processes" db_args.processes
                    , Tuple.pair "countries" db_args.countries
                    , Tuple.pair "materials" db_args.materials
                    , Tuple.pair "products" db_args.products
                    , Tuple.pair "transports" db_args.transports
                    , Tuple.pair "wellKnown" db_args.wellKnown
                    ]
                )
    }


call_ : { buildFromJson : Elm.Expression -> Elm.Expression }
call_ =
    { buildFromJson =
        \buildFromJsonArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Db" ]
                    , name = "buildFromJson"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string, Type.namedWith [] "Db" [] ]
                                )
                            )
                    }
                )
                [ buildFromJsonArg ]
    }


values_ : { buildFromJson : Elm.Expression }
values_ =
    { buildFromJson =
        Elm.value
            { importFrom = [ "Data", "Textile", "Db" ]
            , name = "buildFromJson"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Db" [] ]
                        )
                    )
            }
    }