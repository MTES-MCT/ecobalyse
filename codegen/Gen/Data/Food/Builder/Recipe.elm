module Gen.Data.Food.Builder.Recipe exposing (annotation_, availableIngredients, availablePackagings, call_, compute, computeIngredientBonusesImpacts, computeIngredientTransport, computeProcessImpacts, deletePackaging, encodeResults, fromQuery, getMassAtPackaging, getPackagingMass, getTransformedIngredientsMass, ingredientQueryFromIngredient, make_, moduleName_, processQueryFromProcess, resetDistribution, resetTransform, toString, values_)

{-| 
@docs moduleName_, toString, resetDistribution, resetTransform, processQueryFromProcess, ingredientQueryFromIngredient, getTransformedIngredientsMass, getPackagingMass, getMassAtPackaging, fromQuery, encodeResults, deletePackaging, computeIngredientTransport, computeProcessImpacts, computeIngredientBonusesImpacts, compute, availablePackagings, availableIngredients, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Builder", "Recipe" ]


{-| toString: Recipe -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Recipe" [] ] Type.string
                    )
            }
        )
        [ toStringArg ]


{-| resetDistribution: Query -> Query -}
resetDistribution : Elm.Expression -> Elm.Expression
resetDistribution resetDistributionArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "resetDistribution"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ resetDistributionArg ]


{-| resetTransform: Query -> Query -}
resetTransform : Elm.Expression -> Elm.Expression
resetTransform resetTransformArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "resetTransform"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ resetTransformArg ]


{-| processQueryFromProcess: Process -> BuilderQuery.ProcessQuery -}
processQueryFromProcess : Elm.Expression -> Elm.Expression
processQueryFromProcess processQueryFromProcessArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "processQueryFromProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Process" [] ]
                        (Type.namedWith [ "BuilderQuery" ] "ProcessQuery" [])
                    )
            }
        )
        [ processQueryFromProcessArg ]


{-| ingredientQueryFromIngredient: Ingredient -> BuilderQuery.IngredientQuery -}
ingredientQueryFromIngredient : Elm.Expression -> Elm.Expression
ingredientQueryFromIngredient ingredientQueryFromIngredientArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "ingredientQueryFromIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Ingredient" [] ]
                        (Type.namedWith [ "BuilderQuery" ] "IngredientQuery" [])
                    )
            }
        )
        [ ingredientQueryFromIngredientArg ]


{-| getTransformedIngredientsMass: Recipe -> Mass -}
getTransformedIngredientsMass : Elm.Expression -> Elm.Expression
getTransformedIngredientsMass getTransformedIngredientsMassArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "getTransformedIngredientsMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ getTransformedIngredientsMassArg ]


{-| getPackagingMass: Recipe -> Mass -}
getPackagingMass : Elm.Expression -> Elm.Expression
getPackagingMass getPackagingMassArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "getPackagingMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ getPackagingMassArg ]


{-| getMassAtPackaging: Recipe -> Mass -}
getMassAtPackaging : Elm.Expression -> Elm.Expression
getMassAtPackaging getMassAtPackagingArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "getMassAtPackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ getMassAtPackagingArg ]


{-| fromQuery: Db -> Query -> Result String Recipe -}
fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
fromQuery fromQueryArg fromQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
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


{-| encodeResults: Results -> Encode.Value -}
encodeResults : Elm.Expression -> Elm.Expression
encodeResults encodeResultsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "encodeResults"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Results" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeResultsArg ]


{-| deletePackaging: Process.Code -> Query -> Query -}
deletePackaging : Elm.Expression -> Elm.Expression -> Elm.Expression
deletePackaging deletePackagingArg deletePackagingArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "deletePackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Process" ] "Code" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ deletePackagingArg, deletePackagingArg0 ]


{-| computeIngredientTransport: Db -> RecipeIngredient -> Transport -}
computeIngredientTransport : Elm.Expression -> Elm.Expression -> Elm.Expression
computeIngredientTransport computeIngredientTransportArg computeIngredientTransportArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "computeIngredientTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "RecipeIngredient" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ computeIngredientTransportArg, computeIngredientTransportArg0 ]


{-| computeProcessImpacts: { a | process : Process, mass : Mass } -> Impacts -}
computeProcessImpacts :
    { a | process : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
computeProcessImpacts computeProcessImpactsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "computeProcessImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.extensible
                            "a"
                            [ ( "process", Type.namedWith [] "Process" [] )
                            , ( "mass", Type.namedWith [] "Mass" [] )
                            ]
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
        )
        [ Elm.record
            [ Tuple.pair "process" computeProcessImpactsArg.process
            , Tuple.pair "mass" computeProcessImpactsArg.mass
            ]
        ]


{-| computeIngredientBonusesImpacts: Ingredient.Bonuses -> Impacts -> Impact.BonusImpacts -}
computeIngredientBonusesImpacts :
    Elm.Expression -> Elm.Expression -> Elm.Expression
computeIngredientBonusesImpacts computeIngredientBonusesImpactsArg computeIngredientBonusesImpactsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "computeIngredientBonusesImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Ingredient" ] "Bonuses" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [ "Impact" ] "BonusImpacts" [])
                    )
            }
        )
        [ computeIngredientBonusesImpactsArg
        , computeIngredientBonusesImpactsArg0
        ]


{-| compute: Db -> Query -> Result String ( Recipe, Results ) -}
compute : Elm.Expression -> Elm.Expression -> Elm.Expression
compute computeArg computeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
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


{-| availablePackagings: List Process.Code -> List Process -> List Process -}
availablePackagings :
    List Elm.Expression -> List Elm.Expression -> Elm.Expression
availablePackagings availablePackagingsArg availablePackagingsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "availablePackagings"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [ "Process" ] "Code" [])
                        , Type.list (Type.namedWith [] "Process" [])
                        ]
                        (Type.list (Type.namedWith [] "Process" []))
                    )
            }
        )
        [ Elm.list availablePackagingsArg, Elm.list availablePackagingsArg0 ]


{-| availableIngredients: List Ingredient.Id -> List Ingredient -> List Ingredient -}
availableIngredients :
    List Elm.Expression -> List Elm.Expression -> Elm.Expression
availableIngredients availableIngredientsArg availableIngredientsArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "availableIngredients"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [ "Ingredient" ] "Id" [])
                        , Type.list (Type.namedWith [] "Ingredient" [])
                        ]
                        (Type.list (Type.namedWith [] "Ingredient" []))
                    )
            }
        )
        [ Elm.list availableIngredientsArg, Elm.list availableIngredientsArg0 ]


annotation_ :
    { transform : Type.Annotation
    , scoring : Type.Annotation
    , results : Type.Annotation
    , recipe : Type.Annotation
    , recipeIngredient : Type.Annotation
    }
annotation_ =
    { transform =
        Type.alias
            moduleName_
            "Transform"
            []
            (Type.record
                [ ( "process", Type.namedWith [ "Process" ] "Process" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                ]
            )
    , scoring =
        Type.alias
            moduleName_
            "Scoring"
            []
            (Type.record
                [ ( "all", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "climate", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "biodiversity", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "health", Type.namedWith [ "Unit" ] "Impact" [] )
                , ( "resources", Type.namedWith [ "Unit" ] "Impact" [] )
                ]
            )
    , results =
        Type.alias
            moduleName_
            "Results"
            []
            (Type.record
                [ ( "total", Type.namedWith [] "Impacts" [] )
                , ( "perKg", Type.namedWith [] "Impacts" [] )
                , ( "scoring", Type.namedWith [] "Scoring" [] )
                , ( "totalMass", Type.namedWith [] "Mass" [] )
                , ( "preparedMass", Type.namedWith [] "Mass" [] )
                , ( "recipe"
                  , Type.record
                        [ ( "total", Type.namedWith [] "Impacts" [] )
                        , ( "ingredientsTotal", Type.namedWith [] "Impacts" [] )
                        , ( "ingredients"
                          , Type.list
                                (Type.tuple
                                    (Type.namedWith [] "RecipeIngredient" [])
                                    (Type.namedWith [] "Impacts" [])
                                )
                          )
                        , ( "totalBonusesImpact"
                          , Type.namedWith [ "Impact" ] "BonusImpacts" []
                          )
                        , ( "totalBonusesImpactPerKg"
                          , Type.namedWith [ "Impact" ] "BonusImpacts" []
                          )
                        , ( "transform", Type.namedWith [] "Impacts" [] )
                        , ( "transports", Type.namedWith [] "Transport" [] )
                        , ( "transformedMass", Type.namedWith [] "Mass" [] )
                        ]
                  )
                , ( "packaging", Type.namedWith [] "Impacts" [] )
                , ( "distribution"
                  , Type.record
                        [ ( "total", Type.namedWith [] "Impacts" [] )
                        , ( "transports", Type.namedWith [] "Transport" [] )
                        ]
                  )
                , ( "preparation", Type.namedWith [] "Impacts" [] )
                , ( "transports", Type.namedWith [] "Transport" [] )
                ]
            )
    , recipe =
        Type.alias
            moduleName_
            "Recipe"
            []
            (Type.record
                [ ( "ingredients"
                  , Type.list (Type.namedWith [] "RecipeIngredient" [])
                  )
                , ( "transform"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "Transform" [] ]
                  )
                , ( "packaging", Type.list (Type.namedWith [] "Packaging" []) )
                , ( "distribution"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Retail" ] "Distribution" [] ]
                  )
                , ( "preparation"
                  , Type.list (Type.namedWith [] "Preparation" [])
                  )
                ]
            )
    , recipeIngredient =
        Type.alias
            moduleName_
            "RecipeIngredient"
            []
            (Type.record
                [ ( "ingredient", Type.namedWith [] "Ingredient" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                , ( "variant", Type.namedWith [ "BuilderQuery" ] "Variant" [] )
                , ( "country"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Country" [] ]
                  )
                , ( "planeTransport"
                  , Type.namedWith [ "Ingredient" ] "PlaneTransport" []
                  )
                , ( "bonuses", Type.namedWith [ "Ingredient" ] "Bonuses" [] )
                ]
            )
    }


make_ :
    { transform :
        { process : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
    , scoring :
        { all : Elm.Expression
        , climate : Elm.Expression
        , biodiversity : Elm.Expression
        , health : Elm.Expression
        , resources : Elm.Expression
        }
        -> Elm.Expression
    , results :
        { total : Elm.Expression
        , perKg : Elm.Expression
        , scoring : Elm.Expression
        , totalMass : Elm.Expression
        , preparedMass : Elm.Expression
        , recipe : Elm.Expression
        , packaging : Elm.Expression
        , distribution : Elm.Expression
        , preparation : Elm.Expression
        , transports : Elm.Expression
        }
        -> Elm.Expression
    , recipe :
        { ingredients : Elm.Expression
        , transform : Elm.Expression
        , packaging : Elm.Expression
        , distribution : Elm.Expression
        , preparation : Elm.Expression
        }
        -> Elm.Expression
    , recipeIngredient :
        { ingredient : Elm.Expression
        , mass : Elm.Expression
        , variant : Elm.Expression
        , country : Elm.Expression
        , planeTransport : Elm.Expression
        , bonuses : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { transform =
        \transform_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Recipe" ]
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
    , scoring =
        \scoring_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Recipe" ]
                    "Scoring"
                    []
                    (Type.record
                        [ ( "all", Type.namedWith [ "Unit" ] "Impact" [] )
                        , ( "climate", Type.namedWith [ "Unit" ] "Impact" [] )
                        , ( "biodiversity"
                          , Type.namedWith [ "Unit" ] "Impact" []
                          )
                        , ( "health", Type.namedWith [ "Unit" ] "Impact" [] )
                        , ( "resources", Type.namedWith [ "Unit" ] "Impact" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "all" scoring_args.all
                    , Tuple.pair "climate" scoring_args.climate
                    , Tuple.pair "biodiversity" scoring_args.biodiversity
                    , Tuple.pair "health" scoring_args.health
                    , Tuple.pair "resources" scoring_args.resources
                    ]
                )
    , results =
        \results_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Recipe" ]
                    "Results"
                    []
                    (Type.record
                        [ ( "total", Type.namedWith [] "Impacts" [] )
                        , ( "perKg", Type.namedWith [] "Impacts" [] )
                        , ( "scoring", Type.namedWith [] "Scoring" [] )
                        , ( "totalMass", Type.namedWith [] "Mass" [] )
                        , ( "preparedMass", Type.namedWith [] "Mass" [] )
                        , ( "recipe"
                          , Type.record
                                [ ( "total", Type.namedWith [] "Impacts" [] )
                                , ( "ingredientsTotal"
                                  , Type.namedWith [] "Impacts" []
                                  )
                                , ( "ingredients"
                                  , Type.list
                                        (Type.tuple
                                            (Type.namedWith
                                                []
                                                "RecipeIngredient"
                                                []
                                            )
                                            (Type.namedWith [] "Impacts" [])
                                        )
                                  )
                                , ( "totalBonusesImpact"
                                  , Type.namedWith
                                        [ "Impact" ]
                                        "BonusImpacts"
                                        []
                                  )
                                , ( "totalBonusesImpactPerKg"
                                  , Type.namedWith
                                        [ "Impact" ]
                                        "BonusImpacts"
                                        []
                                  )
                                , ( "transform"
                                  , Type.namedWith [] "Impacts" []
                                  )
                                , ( "transports"
                                  , Type.namedWith [] "Transport" []
                                  )
                                , ( "transformedMass"
                                  , Type.namedWith [] "Mass" []
                                  )
                                ]
                          )
                        , ( "packaging", Type.namedWith [] "Impacts" [] )
                        , ( "distribution"
                          , Type.record
                                [ ( "total", Type.namedWith [] "Impacts" [] )
                                , ( "transports"
                                  , Type.namedWith [] "Transport" []
                                  )
                                ]
                          )
                        , ( "preparation", Type.namedWith [] "Impacts" [] )
                        , ( "transports", Type.namedWith [] "Transport" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "total" results_args.total
                    , Tuple.pair "perKg" results_args.perKg
                    , Tuple.pair "scoring" results_args.scoring
                    , Tuple.pair "totalMass" results_args.totalMass
                    , Tuple.pair "preparedMass" results_args.preparedMass
                    , Tuple.pair "recipe" results_args.recipe
                    , Tuple.pair "packaging" results_args.packaging
                    , Tuple.pair "distribution" results_args.distribution
                    , Tuple.pair "preparation" results_args.preparation
                    , Tuple.pair "transports" results_args.transports
                    ]
                )
    , recipe =
        \recipe_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Recipe" ]
                    "Recipe"
                    []
                    (Type.record
                        [ ( "ingredients"
                          , Type.list (Type.namedWith [] "RecipeIngredient" [])
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
                        , ( "distribution"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Retail" ] "Distribution" []
                                ]
                          )
                        , ( "preparation"
                          , Type.list (Type.namedWith [] "Preparation" [])
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "ingredients" recipe_args.ingredients
                    , Tuple.pair "transform" recipe_args.transform
                    , Tuple.pair "packaging" recipe_args.packaging
                    , Tuple.pair "distribution" recipe_args.distribution
                    , Tuple.pair "preparation" recipe_args.preparation
                    ]
                )
    , recipeIngredient =
        \recipeIngredient_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Recipe" ]
                    "RecipeIngredient"
                    []
                    (Type.record
                        [ ( "ingredient", Type.namedWith [] "Ingredient" [] )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        , ( "variant"
                          , Type.namedWith [ "BuilderQuery" ] "Variant" []
                          )
                        , ( "country"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Country" [] ]
                          )
                        , ( "planeTransport"
                          , Type.namedWith [ "Ingredient" ] "PlaneTransport" []
                          )
                        , ( "bonuses"
                          , Type.namedWith [ "Ingredient" ] "Bonuses" []
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "ingredient" recipeIngredient_args.ingredient
                    , Tuple.pair "mass" recipeIngredient_args.mass
                    , Tuple.pair "variant" recipeIngredient_args.variant
                    , Tuple.pair "country" recipeIngredient_args.country
                    , Tuple.pair
                        "planeTransport"
                        recipeIngredient_args.planeTransport
                    , Tuple.pair "bonuses" recipeIngredient_args.bonuses
                    ]
                )
    }


call_ :
    { toString : Elm.Expression -> Elm.Expression
    , resetDistribution : Elm.Expression -> Elm.Expression
    , resetTransform : Elm.Expression -> Elm.Expression
    , processQueryFromProcess : Elm.Expression -> Elm.Expression
    , ingredientQueryFromIngredient : Elm.Expression -> Elm.Expression
    , getTransformedIngredientsMass : Elm.Expression -> Elm.Expression
    , getPackagingMass : Elm.Expression -> Elm.Expression
    , getMassAtPackaging : Elm.Expression -> Elm.Expression
    , fromQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , encodeResults : Elm.Expression -> Elm.Expression
    , deletePackaging : Elm.Expression -> Elm.Expression -> Elm.Expression
    , computeIngredientTransport :
        Elm.Expression -> Elm.Expression -> Elm.Expression
    , computeProcessImpacts : Elm.Expression -> Elm.Expression
    , computeIngredientBonusesImpacts :
        Elm.Expression -> Elm.Expression -> Elm.Expression
    , compute : Elm.Expression -> Elm.Expression -> Elm.Expression
    , availablePackagings : Elm.Expression -> Elm.Expression -> Elm.Expression
    , availableIngredients : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Recipe" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , resetDistribution =
        \resetDistributionArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "resetDistribution"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ resetDistributionArg ]
    , resetTransform =
        \resetTransformArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "resetTransform"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ resetTransformArg ]
    , processQueryFromProcess =
        \processQueryFromProcessArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "processQueryFromProcess"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Process" [] ]
                                (Type.namedWith
                                    [ "BuilderQuery" ]
                                    "ProcessQuery"
                                    []
                                )
                            )
                    }
                )
                [ processQueryFromProcessArg ]
    , ingredientQueryFromIngredient =
        \ingredientQueryFromIngredientArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "ingredientQueryFromIngredient"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Ingredient" [] ]
                                (Type.namedWith
                                    [ "BuilderQuery" ]
                                    "IngredientQuery"
                                    []
                                )
                            )
                    }
                )
                [ ingredientQueryFromIngredientArg ]
    , getTransformedIngredientsMass =
        \getTransformedIngredientsMassArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "getTransformedIngredientsMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Recipe" [] ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ getTransformedIngredientsMassArg ]
    , getPackagingMass =
        \getPackagingMassArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "getPackagingMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Recipe" [] ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ getPackagingMassArg ]
    , getMassAtPackaging =
        \getMassAtPackagingArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "getMassAtPackaging"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Recipe" [] ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ getMassAtPackagingArg ]
    , fromQuery =
        \fromQueryArg fromQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
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
    , encodeResults =
        \encodeResultsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "encodeResults"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Results" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeResultsArg ]
    , deletePackaging =
        \deletePackagingArg deletePackagingArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "deletePackaging"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Process" ] "Code" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ deletePackagingArg, deletePackagingArg0 ]
    , computeIngredientTransport =
        \computeIngredientTransportArg computeIngredientTransportArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "computeIngredientTransport"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Db" []
                                , Type.namedWith [] "RecipeIngredient" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ computeIngredientTransportArg
                , computeIngredientTransportArg0
                ]
    , computeProcessImpacts =
        \computeProcessImpactsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "computeProcessImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.extensible
                                    "a"
                                    [ ( "process"
                                      , Type.namedWith [] "Process" []
                                      )
                                    , ( "mass", Type.namedWith [] "Mass" [] )
                                    ]
                                ]
                                (Type.namedWith [] "Impacts" [])
                            )
                    }
                )
                [ computeProcessImpactsArg ]
    , computeIngredientBonusesImpacts =
        \computeIngredientBonusesImpactsArg computeIngredientBonusesImpactsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "computeIngredientBonusesImpacts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Ingredient" ] "Bonuses" []
                                , Type.namedWith [] "Impacts" []
                                ]
                                (Type.namedWith [ "Impact" ] "BonusImpacts" [])
                            )
                    }
                )
                [ computeIngredientBonusesImpactsArg
                , computeIngredientBonusesImpactsArg0
                ]
    , compute =
        \computeArg computeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
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
    , availablePackagings =
        \availablePackagingsArg availablePackagingsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "availablePackagings"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith [ "Process" ] "Code" [])
                                , Type.list (Type.namedWith [] "Process" [])
                                ]
                                (Type.list (Type.namedWith [] "Process" []))
                            )
                    }
                )
                [ availablePackagingsArg, availablePackagingsArg0 ]
    , availableIngredients =
        \availableIngredientsArg availableIngredientsArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
                    , name = "availableIngredients"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith [ "Ingredient" ] "Id" [])
                                , Type.list (Type.namedWith [] "Ingredient" [])
                                ]
                                (Type.list (Type.namedWith [] "Ingredient" []))
                            )
                    }
                )
                [ availableIngredientsArg, availableIngredientsArg0 ]
    }


values_ :
    { toString : Elm.Expression
    , resetDistribution : Elm.Expression
    , resetTransform : Elm.Expression
    , processQueryFromProcess : Elm.Expression
    , ingredientQueryFromIngredient : Elm.Expression
    , getTransformedIngredientsMass : Elm.Expression
    , getPackagingMass : Elm.Expression
    , getMassAtPackaging : Elm.Expression
    , fromQuery : Elm.Expression
    , encodeResults : Elm.Expression
    , deletePackaging : Elm.Expression
    , computeIngredientTransport : Elm.Expression
    , computeProcessImpacts : Elm.Expression
    , computeIngredientBonusesImpacts : Elm.Expression
    , compute : Elm.Expression
    , availablePackagings : Elm.Expression
    , availableIngredients : Elm.Expression
    }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Recipe" [] ] Type.string
                    )
            }
    , resetDistribution =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "resetDistribution"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , resetTransform =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "resetTransform"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , processQueryFromProcess =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "processQueryFromProcess"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Process" [] ]
                        (Type.namedWith [ "BuilderQuery" ] "ProcessQuery" [])
                    )
            }
    , ingredientQueryFromIngredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "ingredientQueryFromIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Ingredient" [] ]
                        (Type.namedWith [ "BuilderQuery" ] "IngredientQuery" [])
                    )
            }
    , getTransformedIngredientsMass =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "getTransformedIngredientsMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , getPackagingMass =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "getPackagingMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , getMassAtPackaging =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "getMassAtPackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Recipe" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , fromQuery =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
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
    , encodeResults =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "encodeResults"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Results" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , deletePackaging =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "deletePackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Process" ] "Code" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , computeIngredientTransport =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "computeIngredientTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Db" []
                        , Type.namedWith [] "RecipeIngredient" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , computeProcessImpacts =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "computeProcessImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.extensible
                            "a"
                            [ ( "process", Type.namedWith [] "Process" [] )
                            , ( "mass", Type.namedWith [] "Mass" [] )
                            ]
                        ]
                        (Type.namedWith [] "Impacts" [])
                    )
            }
    , computeIngredientBonusesImpacts =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "computeIngredientBonusesImpacts"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Ingredient" ] "Bonuses" []
                        , Type.namedWith [] "Impacts" []
                        ]
                        (Type.namedWith [ "Impact" ] "BonusImpacts" [])
                    )
            }
    , compute =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
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
    , availablePackagings =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "availablePackagings"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [ "Process" ] "Code" [])
                        , Type.list (Type.namedWith [] "Process" [])
                        ]
                        (Type.list (Type.namedWith [] "Process" []))
                    )
            }
    , availableIngredients =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Recipe" ]
            , name = "availableIngredients"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [ "Ingredient" ] "Id" [])
                        , Type.list (Type.namedWith [] "Ingredient" [])
                        ]
                        (Type.list (Type.namedWith [] "Ingredient" []))
                    )
            }
    }