module Gen.Data.Food.Builder.Query exposing (addIngredient, addPackaging, addPreparation, annotation_, b64encode, buildApiQuery, call_, carrotCake, caseOf_, decode, deleteIngredient, deletePreparation, emptyQuery, encode, getIngredientMass, make_, moduleName_, parseBase64Query, serialize, setDistribution, setTransform, updateBonusesFromVariant, updateDistribution, updateIngredient, updatePackaging, updatePreparation, updateTransform, values_)

{-| 
@docs moduleName_, parseBase64Query, b64encode, serialize, updateBonusesFromVariant, updateDistribution, updateTransform, updatePackaging, updateIngredient, updatePreparation, setDistribution, setTransform, getIngredientMass, encode, deleteIngredient, deletePreparation, decode, carrotCake, emptyQuery, buildApiQuery, addPackaging, addIngredient, addPreparation, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Builder", "Query" ]


{-| parseBase64Query: Parser (Maybe Query -> a) a -}
parseBase64Query : Elm.Expression
parseBase64Query =
    Elm.value
        { importFrom = [ "Data", "Food", "Builder", "Query" ]
        , name = "parseBase64Query"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Parser"
                    [ Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Query" [] ]
                        ]
                        (Type.var "a")
                    , Type.var "a"
                    ]
                )
        }


{-| b64encode: Query -> String -}
b64encode : Elm.Expression -> Elm.Expression
b64encode b64encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "b64encode"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Query" [] ] Type.string)
            }
        )
        [ b64encodeArg ]


{-| serialize: Query -> String -}
serialize : Elm.Expression -> Elm.Expression
serialize serializeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "serialize"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Query" [] ] Type.string)
            }
        )
        [ serializeArg ]


{-| updateBonusesFromVariant: List Ingredient -> Ingredient.Id -> Variant -> Ingredient.Bonuses -}
updateBonusesFromVariant :
    List Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateBonusesFromVariant updateBonusesFromVariantArg updateBonusesFromVariantArg0 updateBonusesFromVariantArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateBonusesFromVariant"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Ingredient" [])
                        , Type.namedWith [ "Ingredient" ] "Id" []
                        , Type.namedWith [] "Variant" []
                        ]
                        (Type.namedWith [ "Ingredient" ] "Bonuses" [])
                    )
            }
        )
        [ Elm.list updateBonusesFromVariantArg
        , updateBonusesFromVariantArg0
        , updateBonusesFromVariantArg1
        ]


{-| updateDistribution: String -> Query -> Query -}
updateDistribution : String -> Elm.Expression -> Elm.Expression
updateDistribution updateDistributionArg updateDistributionArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateDistribution"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ Elm.string updateDistributionArg, updateDistributionArg0 ]


{-| updateTransform: ProcessQuery -> Query -> Query -}
updateTransform : Elm.Expression -> Elm.Expression -> Elm.Expression
updateTransform updateTransformArg updateTransformArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateTransform"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ updateTransformArg, updateTransformArg0 ]


{-| updatePackaging: Process.Code -> ProcessQuery -> Query -> Query -}
updatePackaging :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updatePackaging updatePackagingArg updatePackagingArg0 updatePackagingArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updatePackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Process" ] "Code" []
                        , Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ updatePackagingArg, updatePackagingArg0, updatePackagingArg1 ]


{-| updateIngredient: Ingredient.Id -> IngredientQuery -> Query -> Query -}
updateIngredient :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateIngredient updateIngredientArg updateIngredientArg0 updateIngredientArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Ingredient" ] "Id" []
                        , Type.namedWith [] "IngredientQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ updateIngredientArg, updateIngredientArg0, updateIngredientArg1 ]


{-| updatePreparation: Preparation.Id -> Preparation.Id -> Query -> Query -}
updatePreparation :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updatePreparation updatePreparationArg updatePreparationArg0 updatePreparationArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updatePreparation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ updatePreparationArg, updatePreparationArg0, updatePreparationArg1 ]


{-| setDistribution: Retail.Distribution -> Query -> Query -}
setDistribution : Elm.Expression -> Elm.Expression -> Elm.Expression
setDistribution setDistributionArg setDistributionArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "setDistribution"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Retail" ] "Distribution" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ setDistributionArg, setDistributionArg0 ]


{-| setTransform: ProcessQuery -> Query -> Query -}
setTransform : Elm.Expression -> Elm.Expression -> Elm.Expression
setTransform setTransformArg setTransformArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "setTransform"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ setTransformArg, setTransformArg0 ]


{-| getIngredientMass: List { a | mass : Mass } -> Mass -}
getIngredientMass : List { a | mass : Elm.Expression } -> Elm.Expression
getIngredientMass getIngredientMassArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "getIngredientMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.extensible
                                "a"
                                [ ( "mass", Type.namedWith [] "Mass" [] ) ]
                            )
                        ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ Elm.list
            (List.map
                (\unpack -> Elm.record [ Tuple.pair "mass" unpack.mass ])
                getIngredientMassArg
            )
        ]


{-| encode: Query -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| deleteIngredient: Ingredient.Id -> Query -> Query -}
deleteIngredient : Elm.Expression -> Elm.Expression -> Elm.Expression
deleteIngredient deleteIngredientArg deleteIngredientArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "deleteIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Ingredient" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ deleteIngredientArg, deleteIngredientArg0 ]


{-| deletePreparation: Preparation.Id -> Query -> Query -}
deletePreparation : Elm.Expression -> Elm.Expression -> Elm.Expression
deletePreparation deletePreparationArg deletePreparationArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "deletePreparation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ deletePreparationArg, deletePreparationArg0 ]


{-| decode: Decoder Query -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Food", "Builder", "Query" ]
        , name = "decode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Query" [] ])
        }


{-| carrotCake: Query -}
carrotCake : Elm.Expression
carrotCake =
    Elm.value
        { importFrom = [ "Data", "Food", "Builder", "Query" ]
        , name = "carrotCake"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


{-| emptyQuery: Query -}
emptyQuery : Elm.Expression
emptyQuery =
    Elm.value
        { importFrom = [ "Data", "Food", "Builder", "Query" ]
        , name = "emptyQuery"
        , annotation = Just (Type.namedWith [] "Query" [])
        }


{-| buildApiQuery: String -> Query -> String -}
buildApiQuery : String -> Elm.Expression -> Elm.Expression
buildApiQuery buildApiQueryArg buildApiQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "buildApiQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Query" [] ]
                        Type.string
                    )
            }
        )
        [ Elm.string buildApiQueryArg, buildApiQueryArg0 ]


{-| addPackaging: ProcessQuery -> Query -> Query -}
addPackaging : Elm.Expression -> Elm.Expression -> Elm.Expression
addPackaging addPackagingArg addPackagingArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "addPackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ addPackagingArg, addPackagingArg0 ]


{-| addIngredient: IngredientQuery -> Query -> Query -}
addIngredient : Elm.Expression -> Elm.Expression -> Elm.Expression
addIngredient addIngredientArg addIngredientArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "addIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "IngredientQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ addIngredientArg, addIngredientArg0 ]


{-| addPreparation: Preparation.Id -> Query -> Query -}
addPreparation : Elm.Expression -> Elm.Expression -> Elm.Expression
addPreparation addPreparationArg addPreparationArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "addPreparation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
        )
        [ addPreparationArg, addPreparationArg0 ]


annotation_ :
    { query : Type.Annotation
    , processQuery : Type.Annotation
    , ingredientQuery : Type.Annotation
    , variant : Type.Annotation
    }
annotation_ =
    { query =
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
                        [ Type.namedWith [] "ProcessQuery" [] ]
                  )
                , ( "packaging"
                  , Type.list (Type.namedWith [] "ProcessQuery" [])
                  )
                , ( "distribution"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Retail" ] "Distribution" [] ]
                  )
                , ( "preparation"
                  , Type.list (Type.namedWith [ "Preparation" ] "Id" [])
                  )
                ]
            )
    , processQuery =
        Type.alias
            moduleName_
            "ProcessQuery"
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
                [ ( "id", Type.namedWith [ "Ingredient" ] "Id" [] )
                , ( "mass", Type.namedWith [] "Mass" [] )
                , ( "variant", Type.namedWith [] "Variant" [] )
                , ( "country"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Country" ] "Code" [] ]
                  )
                , ( "planeTransport"
                  , Type.namedWith [ "Ingredient" ] "PlaneTransport" []
                  )
                , ( "bonuses"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Ingredient" ] "Bonuses" [] ]
                  )
                ]
            )
    , variant =
        Type.namedWith [ "Data", "Food", "Builder", "Query" ] "Variant" []
    }


make_ :
    { query :
        { ingredients : Elm.Expression
        , transform : Elm.Expression
        , packaging : Elm.Expression
        , distribution : Elm.Expression
        , preparation : Elm.Expression
        }
        -> Elm.Expression
    , processQuery :
        { code : Elm.Expression, mass : Elm.Expression } -> Elm.Expression
    , ingredientQuery :
        { id : Elm.Expression
        , mass : Elm.Expression
        , variant : Elm.Expression
        , country : Elm.Expression
        , planeTransport : Elm.Expression
        , bonuses : Elm.Expression
        }
        -> Elm.Expression
    , defaultVariant : Elm.Expression
    , organic : Elm.Expression
    }
make_ =
    { query =
        \query_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Query" ]
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
                                [ Type.namedWith [] "ProcessQuery" [] ]
                          )
                        , ( "packaging"
                          , Type.list (Type.namedWith [] "ProcessQuery" [])
                          )
                        , ( "distribution"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Retail" ] "Distribution" []
                                ]
                          )
                        , ( "preparation"
                          , Type.list (Type.namedWith [ "Preparation" ] "Id" [])
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "ingredients" query_args.ingredients
                    , Tuple.pair "transform" query_args.transform
                    , Tuple.pair "packaging" query_args.packaging
                    , Tuple.pair "distribution" query_args.distribution
                    , Tuple.pair "preparation" query_args.preparation
                    ]
                )
    , processQuery =
        \processQuery_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Query" ]
                    "ProcessQuery"
                    []
                    (Type.record
                        [ ( "code", Type.namedWith [ "Process" ] "Code" [] )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "code" processQuery_args.code
                    , Tuple.pair "mass" processQuery_args.mass
                    ]
                )
    , ingredientQuery =
        \ingredientQuery_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Builder", "Query" ]
                    "IngredientQuery"
                    []
                    (Type.record
                        [ ( "id", Type.namedWith [ "Ingredient" ] "Id" [] )
                        , ( "mass", Type.namedWith [] "Mass" [] )
                        , ( "variant", Type.namedWith [] "Variant" [] )
                        , ( "country"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Country" ] "Code" [] ]
                          )
                        , ( "planeTransport"
                          , Type.namedWith [ "Ingredient" ] "PlaneTransport" []
                          )
                        , ( "bonuses"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [ "Ingredient" ] "Bonuses" [] ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "id" ingredientQuery_args.id
                    , Tuple.pair "mass" ingredientQuery_args.mass
                    , Tuple.pair "variant" ingredientQuery_args.variant
                    , Tuple.pair "country" ingredientQuery_args.country
                    , Tuple.pair
                        "planeTransport"
                        ingredientQuery_args.planeTransport
                    , Tuple.pair "bonuses" ingredientQuery_args.bonuses
                    ]
                )
    , defaultVariant =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "DefaultVariant"
            , annotation = Just (Type.namedWith [] "Variant" [])
            }
    , organic =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "Organic"
            , annotation = Just (Type.namedWith [] "Variant" [])
            }
    }


caseOf_ :
    { variant :
        Elm.Expression
        -> { variantTags_0_0
            | defaultVariant : Elm.Expression
            , organic : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { variant =
        \variantExpression variantTags ->
            Elm.Case.custom
                variantExpression
                (Type.namedWith
                    [ "Data", "Food", "Builder", "Query" ]
                    "Variant"
                    []
                )
                [ Elm.Case.branch0 "DefaultVariant" variantTags.defaultVariant
                , Elm.Case.branch0 "Organic" variantTags.organic
                ]
    }


call_ :
    { b64encode : Elm.Expression -> Elm.Expression
    , serialize : Elm.Expression -> Elm.Expression
    , updateBonusesFromVariant :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateDistribution : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateTransform : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updatePackaging :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateIngredient :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , updatePreparation :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , setDistribution : Elm.Expression -> Elm.Expression -> Elm.Expression
    , setTransform : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getIngredientMass : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    , deleteIngredient : Elm.Expression -> Elm.Expression -> Elm.Expression
    , deletePreparation : Elm.Expression -> Elm.Expression -> Elm.Expression
    , buildApiQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , addPackaging : Elm.Expression -> Elm.Expression -> Elm.Expression
    , addIngredient : Elm.Expression -> Elm.Expression -> Elm.Expression
    , addPreparation : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { b64encode =
        \b64encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "b64encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                Type.string
                            )
                    }
                )
                [ b64encodeArg ]
    , serialize =
        \serializeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "serialize"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                Type.string
                            )
                    }
                )
                [ serializeArg ]
    , updateBonusesFromVariant =
        \updateBonusesFromVariantArg updateBonusesFromVariantArg0 updateBonusesFromVariantArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "updateBonusesFromVariant"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Ingredient" [])
                                , Type.namedWith [ "Ingredient" ] "Id" []
                                , Type.namedWith [] "Variant" []
                                ]
                                (Type.namedWith [ "Ingredient" ] "Bonuses" [])
                            )
                    }
                )
                [ updateBonusesFromVariantArg
                , updateBonusesFromVariantArg0
                , updateBonusesFromVariantArg1
                ]
    , updateDistribution =
        \updateDistributionArg updateDistributionArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "updateDistribution"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string, Type.namedWith [] "Query" [] ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateDistributionArg, updateDistributionArg0 ]
    , updateTransform =
        \updateTransformArg updateTransformArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "updateTransform"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ProcessQuery" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateTransformArg, updateTransformArg0 ]
    , updatePackaging =
        \updatePackagingArg updatePackagingArg0 updatePackagingArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "updatePackaging"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Process" ] "Code" []
                                , Type.namedWith [] "ProcessQuery" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updatePackagingArg, updatePackagingArg0, updatePackagingArg1 ]
    , updateIngredient =
        \updateIngredientArg updateIngredientArg0 updateIngredientArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "updateIngredient"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Ingredient" ] "Id" []
                                , Type.namedWith [] "IngredientQuery" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updateIngredientArg
                , updateIngredientArg0
                , updateIngredientArg1
                ]
    , updatePreparation =
        \updatePreparationArg updatePreparationArg0 updatePreparationArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "updatePreparation"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Preparation" ] "Id" []
                                , Type.namedWith [ "Preparation" ] "Id" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ updatePreparationArg
                , updatePreparationArg0
                , updatePreparationArg1
                ]
    , setDistribution =
        \setDistributionArg setDistributionArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "setDistribution"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Retail" ] "Distribution" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ setDistributionArg, setDistributionArg0 ]
    , setTransform =
        \setTransformArg setTransformArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "setTransform"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ProcessQuery" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ setTransformArg, setTransformArg0 ]
    , getIngredientMass =
        \getIngredientMassArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "getIngredientMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.extensible
                                        "a"
                                        [ ( "mass"
                                          , Type.namedWith [] "Mass" []
                                          )
                                        ]
                                    )
                                ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ getIngredientMassArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Query" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , deleteIngredient =
        \deleteIngredientArg deleteIngredientArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "deleteIngredient"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Ingredient" ] "Id" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ deleteIngredientArg, deleteIngredientArg0 ]
    , deletePreparation =
        \deletePreparationArg deletePreparationArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "deletePreparation"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Preparation" ] "Id" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ deletePreparationArg, deletePreparationArg0 ]
    , buildApiQuery =
        \buildApiQueryArg buildApiQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "buildApiQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string, Type.namedWith [] "Query" [] ]
                                Type.string
                            )
                    }
                )
                [ buildApiQueryArg, buildApiQueryArg0 ]
    , addPackaging =
        \addPackagingArg addPackagingArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "addPackaging"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ProcessQuery" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ addPackagingArg, addPackagingArg0 ]
    , addIngredient =
        \addIngredientArg addIngredientArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "addIngredient"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "IngredientQuery" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ addIngredientArg, addIngredientArg0 ]
    , addPreparation =
        \addPreparationArg addPreparationArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Builder", "Query" ]
                    , name = "addPreparation"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Preparation" ] "Id" []
                                , Type.namedWith [] "Query" []
                                ]
                                (Type.namedWith [] "Query" [])
                            )
                    }
                )
                [ addPreparationArg, addPreparationArg0 ]
    }


values_ :
    { parseBase64Query : Elm.Expression
    , b64encode : Elm.Expression
    , serialize : Elm.Expression
    , updateBonusesFromVariant : Elm.Expression
    , updateDistribution : Elm.Expression
    , updateTransform : Elm.Expression
    , updatePackaging : Elm.Expression
    , updateIngredient : Elm.Expression
    , updatePreparation : Elm.Expression
    , setDistribution : Elm.Expression
    , setTransform : Elm.Expression
    , getIngredientMass : Elm.Expression
    , encode : Elm.Expression
    , deleteIngredient : Elm.Expression
    , deletePreparation : Elm.Expression
    , decode : Elm.Expression
    , carrotCake : Elm.Expression
    , emptyQuery : Elm.Expression
    , buildApiQuery : Elm.Expression
    , addPackaging : Elm.Expression
    , addIngredient : Elm.Expression
    , addPreparation : Elm.Expression
    }
values_ =
    { parseBase64Query =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "parseBase64Query"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Parser"
                        [ Type.function
                            [ Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Query" [] ]
                            ]
                            (Type.var "a")
                        , Type.var "a"
                        ]
                    )
            }
    , b64encode =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "b64encode"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Query" [] ] Type.string)
            }
    , serialize =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "serialize"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Query" [] ] Type.string)
            }
    , updateBonusesFromVariant =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateBonusesFromVariant"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Ingredient" [])
                        , Type.namedWith [ "Ingredient" ] "Id" []
                        , Type.namedWith [] "Variant" []
                        ]
                        (Type.namedWith [ "Ingredient" ] "Bonuses" [])
                    )
            }
    , updateDistribution =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateDistribution"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Query" [] ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updateTransform =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateTransform"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updatePackaging =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updatePackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Process" ] "Code" []
                        , Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updateIngredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updateIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Ingredient" ] "Id" []
                        , Type.namedWith [] "IngredientQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , updatePreparation =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "updatePreparation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , setDistribution =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "setDistribution"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Retail" ] "Distribution" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , setTransform =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "setTransform"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , getIngredientMass =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "getIngredientMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.extensible
                                "a"
                                [ ( "mass", Type.namedWith [] "Mass" [] ) ]
                            )
                        ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Query" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , deleteIngredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "deleteIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Ingredient" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , deletePreparation =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "deletePreparation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Query" [] ]
                    )
            }
    , carrotCake =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "carrotCake"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    , emptyQuery =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "emptyQuery"
            , annotation = Just (Type.namedWith [] "Query" [])
            }
    , buildApiQuery =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "buildApiQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Query" [] ]
                        Type.string
                    )
            }
    , addPackaging =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "addPackaging"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProcessQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , addIngredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "addIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "IngredientQuery" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    , addPreparation =
        Elm.value
            { importFrom = [ "Data", "Food", "Builder", "Query" ]
            , name = "addPreparation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Preparation" ] "Id" []
                        , Type.namedWith [] "Query" []
                        ]
                        (Type.namedWith [] "Query" [])
                    )
            }
    }