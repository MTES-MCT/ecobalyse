module Gen.Data.Food.Explorer.Recipe exposing (annotation_, call_, compute, fromQuery, make_, moduleName_, toQuery, tunaPizza, values_)

{-| 
@docs moduleName_, compute, toQuery, fromQuery, tunaPizza, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Explorer", "Recipe" ]


{-| compute: Db -> Query -> Result String ( Recipe, Results ) -}
compute : Elm.Expression -> Elm.Expression -> Elm.Expression
compute computeArg computeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "compute"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string
                            , Type.tuple
                                (Type.namedWith [] "Recipe" [])
                                (Type.namedWith [] "Results" [])
                            ]
                        )
                    )
            }
        )
        [ computeArg, computeArg0 ]


{-| toQuery: Recipe -> Query -}
toQuery : Elm.Expression -> Elm.Expression
toQuery toQueryArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "toQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ toQueryArg ]


{-| fromQuery: Db -> Query -> Result String Recipe -}
fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
fromQuery fromQueryArg fromQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "fromQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Recipe" [] ]
                        )
                    )
            }
        )
        [ fromQueryArg, fromQueryArg0 ]


{-| tunaPizza: Query -}
tunaPizza : Elm.Expression
tunaPizza =
    Elm.value
        { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
        , name = "tunaPizza"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


annotation_ :
    { results : Type.Annotation
    , recipe : Type.Annotation
    , packaging : Type.Annotation
    , transform : Type.Annotation
    , plantOptions : Type.Annotation
    , query : Type.Annotation
    , packagingQuery : Type.Annotation
    , transformQuery : Type.Annotation
    , ingredientQuery : Type.Annotation
    }
annotation_ =
    { results =
        Type.alias
            moduleName_
            "Results"
            []
            (Type.record
                [ ( "impacts", Type.namedWith [] "Impacts" [] )
                , ( "recipe"
                  , Type.record
                        [ ( "ingredients", Type.namedWith [] "Impacts" [] )
                        , ( "transform", Type.namedWith [] "Impacts" [] )
                        ]
                  )
                , ( "packaging", Type.namedWith [] "Impacts" [] )
                ]
            )
    , recipe =
        Type.alias
            moduleName_
            "Recipe"
            []
            (Type.record
                [ ( "ingredients"
                  , Type.list (Type.namedWith [] "Ingredient" [])
                  )
                , ( "transform"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "Transform" [] ]
                  )
                , ( "packaging", Type.list (Type.namedWith [] "Packaging" []) )
                , ( "plant", Type.namedWith [] "PlantOptions" [] )
                ]
            )
    , packaging =
        Type.alias
            moduleName_
            "Packaging"
            []
            (Type.record
                [ ( "process", Type.namedWith [ "Process" ] "Process" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                ]
            )
    , transform =
        Type.alias
            moduleName_
            "Transform"
            []
            (Type.record
                [ ( "process", Type.namedWith [ "Process" ] "Process" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                ]
            )
    , plantOptions =
        Type.alias
            moduleName_
            "PlantOptions"
            []
            (Type.record
                [ ( "country"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Country" ] "Code" [] ]
                  )
                ]
            )
    , query =
        Type.alias
            moduleName_
            "Query"
            []
            (Type.record
                [ ( "ingredients"
                  , Type.list (Type.namedWith [] "IngredientQuery" [])
                  )
                , ( "transform"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "TransformQuery" [] ]
                  )
                , ( "packaging"
                  , Type.list (Type.namedWith [] "PackagingQuery" [])
                  )
                , ( "plant", Type.namedWith [] "PlantOptions" [] )
                ]
            )
    , packagingQuery =
        Type.alias
            moduleName_
            "PackagingQuery"
            []
            (Type.record
                [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                ]
            )
    , transformQuery =
        Type.alias
            moduleName_
            "TransformQuery"
            []
            (Type.record
                [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                ]
            )
    , ingredientQuery =
        Type.alias
            moduleName_
            "IngredientQuery"
            []
            (Type.record
                [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                , ( "country"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Country" ] "Code" [] ]
                  )
                , ( "labels", Type.list Type.string )
                ]
            )
    }


make_ :
    { results :
        { impacts : Elm.Expression
        , recipe : Elm.Expression
        , packaging : Elm.Expression
        }
        -> Elm.Expression
    , recipe :
        { ingredients : Elm.Expression
        , transform : Elm.Expression
        , packaging : Elm.Expression
        , plant : Elm.Expression
        }
        -> Elm.Expression
    , packaging :
        { process : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
    , transform :
        { process : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
    , plantOptions : { country : Elm.Expression } -> Elm.Expression
    , query :
        { ingredients : Elm.Expression
        , transform : Elm.Expression
        , packaging : Elm.Expression
        , plant : Elm.Expression
        }
        -> Elm.Expression
    , packagingQuery :
        { code : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
    , transformQuery :
        { code : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
    , ingredientQuery :
        { code : Elm.Expression
        , mass : Elm.Expression
        , country : Elm.Expression
        , labels : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { results =
        \results_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "Results"
                    []
                    (Type.record
                        [ ( "impacts", Type.namedWith [] "Impacts" [] )
                        , ( "recipe"
                          , Type.record
                                [ ( "ingredients"
                                  , Type.namedWith [] "Impacts" []
                                  )
                                , ( "transform"
                                  , Type.namedWith [] "Impacts" []
                                  )
                                ]
                          )
                        , ( "packaging", Type.namedWith [] "Impacts" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "impacts" results_args.impacts
                    , Tuple.pair "recipe" results_args.recipe
                    , Tuple.pair "packaging" results_args.packaging
                    ]
                )
    , recipe =
        \recipe_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "Recipe"
                    []
                    (Type.record
                        [ ( "ingredients"
                          , Type.list (Type.namedWith [] "Ingredient" [])
                          )
                        , ( "transform"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Transform" [] ]
                          )
                        , ( "packaging"
                          , Type.list (Type.namedWith [] "Packaging" [])
                          )
                        , ( "plant", Type.namedWith [] "PlantOptions" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "ingredients" recipe_args.ingredients
                    , Tuple.pair "transform" recipe_args.transform
                    , Tuple.pair "packaging" recipe_args.packaging
                    , Tuple.pair "plant" recipe_args.plant
                    ]
                )
    , packaging =
        \packaging_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "Packaging"
                    []
                    (Type.record
                        [ ( "process"
                          , Type.namedWith [ "Process" ] "Process" []
                          )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "process" packaging_args.process
                    , Tuple.pair "mass" packaging_args.mass
                    ]
                )
    , transform =
        \transform_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "Transform"
                    []
                    (Type.record
                        [ ( "process"
                          , Type.namedWith [ "Process" ] "Process" []
                          )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "process" transform_args.process
                    , Tuple.pair "mass" transform_args.mass
                    ]
                )
    , plantOptions =
        \plantOptions_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "PlantOptions"
                    []
                    (Type.record
                        [ ( "country"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Country" ] "Code" [] ]
                          )
                        ]
                    )
                )
                (Elm.record [ Tuple.pair "country" plantOptions_args.country ])
    , query =
        \query_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "Query"
                    []
                    (Type.record
                        [ ( "ingredients"
                          , Type.list (Type.namedWith [] "IngredientQuery" [])
                          )
                        , ( "transform"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "TransformQuery" [] ]
                          )
                        , ( "packaging"
                          , Type.list (Type.namedWith [] "PackagingQuery" [])
                          )
                        , ( "plant", Type.namedWith [] "PlantOptions" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "ingredients" query_args.ingredients
                    , Tuple.pair "transform" query_args.transform
                    , Tuple.pair "packaging" query_args.packaging
                    , Tuple.pair "plant" query_args.plant
                    ]
                )
    , packagingQuery =
        \packagingQuery_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "PackagingQuery"
                    []
                    (Type.record
                        [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "code" packagingQuery_args.code
                    , Tuple.pair "mass" packagingQuery_args.mass
                    ]
                )
    , transformQuery =
        \transformQuery_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "TransformQuery"
                    []
                    (Type.record
                        [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "code" transformQuery_args.code
                    , Tuple.pair "mass" transformQuery_args.mass
                    ]
                )
    , ingredientQuery =
        \ingredientQuery_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Explorer", "Recipe" ]
                    "IngredientQuery"
                    []
                    (Type.record
                        [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        , ( "country"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Country" ] "Code" [] ]
                          )
                        , ( "labels", Type.list Type.string )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "code" ingredientQuery_args.code
                    , Tuple.pair "mass" ingredientQuery_args.mass
                    , Tuple.pair "country" ingredientQuery_args.country
                    , Tuple.pair "labels" ingredientQuery_args.labels
                    ]
                )
    }


call_ :
    { compute : Elm.Expression -> Elm.Expression -> Elm.Expression
    , toQuery : Elm.Expression -> Elm.Expression
    , fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { compute =
        \computeArg computeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
                    , name = "compute"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.tuple
                                        (Type.namedWith [] "Recipe" [])
                                        (Type.namedWith [] "Results" [])
                                    ]
                                )
                            )
                    }
                )
                [ computeArg, computeArg0 ]
    , toQuery =
        \toQueryArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
                    , name = "toQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Recipe" [] ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ toQueryArg ]
    , fromQuery =
        \fromQueryArg fromQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
                    , name = "fromQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Recipe" []
                                    ]
                                )
                            )
                    }
                )
                [ fromQueryArg, fromQueryArg0 ]
    }


values_ :
    { compute : Elm.Expression
    , toQuery : Elm.Expression
    , fromQuery : Elm.Expression
    , tunaPizza : Elm.Expression
    }
values_ =
    { compute =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "compute"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string
                            , Type.tuple
                                (Type.namedWith [] "Recipe" [])
                                (Type.namedWith [] "Results" [])
                            ]
                        )
                    )
            }
    , toQuery =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "toQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , fromQuery =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "fromQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Recipe" [] ]
                        )
                    )
            }
    , tunaPizza =
        Elm.value
            { importFrom = [ "Data", "Food", "Explorer", "Recipe" ]
            , name = "tunaPizza"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    }