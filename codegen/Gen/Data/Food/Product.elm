module Gen.Data.Food.Product exposing (addIngredient, annotation_, call_, decodeProducts, defaultCountry, emptyProducts, filterItemByCategory, findByName, getAmountRatio, getItemsImpact, getStepTransports, getTotalImpact, getWeightAtPlant, make_, moduleName_, nameFromString, nameToString, removeIngredient, updateIngredientMass, updatePlantTransport, values_)

{-| 
@docs moduleName_, updatePlantTransport, getAmountRatio, removeIngredient, updateIngredientMass, addIngredient, getWeightAtPlant, getStepTransports, getTotalImpact, getItemsImpact, decodeProducts, findByName, emptyProducts, nameFromString, nameToString, filterItemByCategory, defaultCountry, annotation_, make_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Product" ]


{-| updatePlantTransport: Product -> List Process -> Country.Code -> Distances -> Product -> Product -}
updatePlantTransport :
    Elm.Expression
    -> List Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
updatePlantTransport updatePlantTransportArg updatePlantTransportArg0 updatePlantTransportArg1 updatePlantTransportArg2 updatePlantTransportArg3 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "updatePlantTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" []
                        , Type.list (Type.namedWith [] "Process" [])
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [] "Distances" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
        )
        [ updatePlantTransportArg
        , Elm.list updatePlantTransportArg0
        , updatePlantTransportArg1
        , updatePlantTransportArg2
        , updatePlantTransportArg3
        ]


{-| getAmountRatio: Mass -> Product -> Float -}
getAmountRatio : Elm.Expression -> Elm.Expression -> Elm.Expression
getAmountRatio getAmountRatioArg getAmountRatioArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getAmountRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Product" []
                        ]
                        Type.float
                    )
            }
        )
        [ getAmountRatioArg, getAmountRatioArg0 ]


{-| removeIngredient: Item -> Product -> Product -}
removeIngredient : Elm.Expression -> Elm.Expression -> Elm.Expression
removeIngredient removeIngredientArg removeIngredientArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "removeIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Item" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
        )
        [ removeIngredientArg, removeIngredientArg0 ]


{-| updateIngredientMass: Item -> Mass -> Product -> Product -}
updateIngredientMass :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
updateIngredientMass updateIngredientMassArg updateIngredientMassArg0 updateIngredientMassArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "updateIngredientMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Item" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
        )
        [ updateIngredientMassArg
        , updateIngredientMassArg0
        , updateIngredientMassArg1
        ]


{-| addIngredient: Process -> Mass -> Product -> Product -}
addIngredient :
    Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
addIngredient addIngredientArg addIngredientArg0 addIngredientArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "addIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Process" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
        )
        [ addIngredientArg, addIngredientArg0, addIngredientArg1 ]


{-| getWeightAtPlant: Items -> Mass -}
getWeightAtPlant : Elm.Expression -> Elm.Expression
getWeightAtPlant getWeightAtPlantArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getWeightAtPlant"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Items" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
        )
        [ getWeightAtPlantArg ]


{-| getStepTransports: Step -> { air : Length, rail : Length, road : Length, sea : Length } -}
getStepTransports : Elm.Expression -> Elm.Expression
getStepTransports getStepTransportsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getStepTransports"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Step" [] ]
                        (Type.record
                            [ ( "air", Type.namedWith [] "Length" [] )
                            , ( "rail", Type.namedWith [] "Length" [] )
                            , ( "road", Type.namedWith [] "Length" [] )
                            , ( "sea", Type.namedWith [] "Length" [] )
                            ]
                        )
                    )
            }
        )
        [ getStepTransportsArg ]


{-| getTotalImpact: Definition.Trigram -> Product -> Float -}
getTotalImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
getTotalImpact getTotalImpactArg getTotalImpactArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getTotalImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Definition" ] "Trigram" []
                        , Type.namedWith [] "Product" []
                        ]
                        Type.float
                    )
            }
        )
        [ getTotalImpactArg, getTotalImpactArg0 ]


{-| getItemsImpact: Definition.Trigram -> Items -> Float -}
getItemsImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
getItemsImpact getItemsImpactArg getItemsImpactArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getItemsImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Definition" ] "Trigram" []
                        , Type.namedWith [] "Items" []
                        ]
                        Type.float
                    )
            }
        )
        [ getItemsImpactArg, getItemsImpactArg0 ]


{-| decodeProducts: List Process -> Decoder Products -}
decodeProducts : List Elm.Expression -> Elm.Expression
decodeProducts decodeProductsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "decodeProducts"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.namedWith [] "Products" [] ]
                        )
                    )
            }
        )
        [ Elm.list decodeProductsArg ]


{-| findByName: ProductName -> Products -> Result String Product -}
findByName : Elm.Expression -> Elm.Expression -> Elm.Expression
findByName findByNameArg findByNameArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "findByName"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProductName" []
                        , Type.namedWith [] "Products" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Product" [] ]
                        )
                    )
            }
        )
        [ findByNameArg, findByNameArg0 ]


{-| emptyProducts: Products -}
emptyProducts : Elm.Expression
emptyProducts =
    Elm.value
        { importFrom = [ "Data", "Food", "Product" ]
        , name = "emptyProducts"
        , annotation = Just (Type.namedWith [] "Products" [])
        }


{-| nameFromString: String -> ProductName -}
nameFromString : String -> Elm.Expression
nameFromString nameFromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "nameFromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [] "ProductName" [])
                    )
            }
        )
        [ Elm.string nameFromStringArg ]


{-| nameToString: ProductName -> String -}
nameToString : Elm.Expression -> Elm.Expression
nameToString nameToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "nameToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProductName" [] ]
                        Type.string
                    )
            }
        )
        [ nameToStringArg ]


{-| filterItemByCategory: Process.Category -> Items -> Items -}
filterItemByCategory : Elm.Expression -> Elm.Expression -> Elm.Expression
filterItemByCategory filterItemByCategoryArg filterItemByCategoryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "filterItemByCategory"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Process" ] "Category" []
                        , Type.namedWith [] "Items" []
                        ]
                        (Type.namedWith [] "Items" [])
                    )
            }
        )
        [ filterItemByCategoryArg, filterItemByCategoryArg0 ]


{-| defaultCountry: Country.Code -}
defaultCountry : Elm.Expression
defaultCountry =
    Elm.value
        { importFrom = [ "Data", "Food", "Product" ]
        , name = "defaultCountry"
        , annotation = Just (Type.namedWith [ "Country" ] "Code" [])
        }


annotation_ :
    { products : Type.Annotation
    , product : Type.Annotation
    , step : Type.Annotation
    , items : Type.Annotation
    , item : Type.Annotation
    , productName : Type.Annotation
    }
annotation_ =
    { products =
        Type.alias
            moduleName_
            "Products"
            []
            (Type.namedWith
                []
                "AnyDict"
                [ Type.string
                , Type.namedWith [] "ProductName" []
                , Type.namedWith [] "Product" []
                ]
            )
    , product =
        Type.alias
            moduleName_
            "Product"
            []
            (Type.record
                [ ( "consumer", Type.namedWith [] "Step" [] )
                , ( "supermarket", Type.namedWith [] "Step" [] )
                , ( "distribution", Type.namedWith [] "Step" [] )
                , ( "packaging", Type.namedWith [] "Step" [] )
                , ( "plant", Type.namedWith [] "Items" [] )
                ]
            )
    , step =
        Type.alias
            moduleName_
            "Step"
            []
            (Type.record
                [ ( "mainItem", Type.namedWith [] "MainItem" [] )
                , ( "items", Type.namedWith [] "Items" [] )
                ]
            )
    , items =
        Type.alias
            moduleName_
            "Items"
            []
            (Type.list (Type.namedWith [] "Item" []))
    , item =
        Type.alias
            moduleName_
            "Item"
            []
            (Type.record
                [ ( "amount", Type.namedWith [] "Amount" [] )
                , ( "comment", Type.string )
                , ( "process", Type.namedWith [] "Process" [] )
                ]
            )
    , productName =
        Type.namedWith [ "Data", "Food", "Product" ] "ProductName" []
    }


make_ :
    { product :
        { consumer : Elm.Expression
        , supermarket : Elm.Expression
        , distribution : Elm.Expression
        , packaging : Elm.Expression
        , plant : Elm.Expression
        }
        -> Elm.Expression
    , step :
        { mainItem : Elm.Expression, items : Elm.Expression } -> Elm.Expression
    , item :
        { amount : Elm.Expression
        , comment : Elm.Expression
        , process : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { product =
        \product_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Product" ]
                    "Product"
                    []
                    (Type.record
                        [ ( "consumer", Type.namedWith [] "Step" [] )
                        , ( "supermarket", Type.namedWith [] "Step" [] )
                        , ( "distribution", Type.namedWith [] "Step" [] )
                        , ( "packaging", Type.namedWith [] "Step" [] )
                        , ( "plant", Type.namedWith [] "Items" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "consumer" product_args.consumer
                    , Tuple.pair "supermarket" product_args.supermarket
                    , Tuple.pair "distribution" product_args.distribution
                    , Tuple.pair "packaging" product_args.packaging
                    , Tuple.pair "plant" product_args.plant
                    ]
                )
    , step =
        \step_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Product" ]
                    "Step"
                    []
                    (Type.record
                        [ ( "mainItem", Type.namedWith [] "MainItem" [] )
                        , ( "items", Type.namedWith [] "Items" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "mainItem" step_args.mainItem
                    , Tuple.pair "items" step_args.items
                    ]
                )
    , item =
        \item_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Product" ]
                    "Item"
                    []
                    (Type.record
                        [ ( "amount", Type.namedWith [] "Amount" [] )
                        , ( "comment", Type.string )
                        , ( "process", Type.namedWith [] "Process" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "amount" item_args.amount
                    , Tuple.pair "comment" item_args.comment
                    , Tuple.pair "process" item_args.process
                    ]
                )
    }


call_ :
    { updatePlantTransport :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , getAmountRatio : Elm.Expression -> Elm.Expression -> Elm.Expression
    , removeIngredient : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateIngredientMass :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , addIngredient :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , getWeightAtPlant : Elm.Expression -> Elm.Expression
    , getStepTransports : Elm.Expression -> Elm.Expression
    , getTotalImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getItemsImpact : Elm.Expression -> Elm.Expression -> Elm.Expression
    , decodeProducts : Elm.Expression -> Elm.Expression
    , findByName : Elm.Expression -> Elm.Expression -> Elm.Expression
    , nameFromString : Elm.Expression -> Elm.Expression
    , nameToString : Elm.Expression -> Elm.Expression
    , filterItemByCategory : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { updatePlantTransport =
        \updatePlantTransportArg updatePlantTransportArg0 updatePlantTransportArg1 updatePlantTransportArg2 updatePlantTransportArg3 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "updatePlantTransport"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Product" []
                                , Type.list (Type.namedWith [] "Process" [])
                                , Type.namedWith [ "Country" ] "Code" []
                                , Type.namedWith [] "Distances" []
                                , Type.namedWith [] "Product" []
                                ]
                                (Type.namedWith [] "Product" [])
                            )
                    }
                )
                [ updatePlantTransportArg
                , updatePlantTransportArg0
                , updatePlantTransportArg1
                , updatePlantTransportArg2
                , updatePlantTransportArg3
                ]
    , getAmountRatio =
        \getAmountRatioArg getAmountRatioArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "getAmountRatio"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Product" []
                                ]
                                Type.float
                            )
                    }
                )
                [ getAmountRatioArg, getAmountRatioArg0 ]
    , removeIngredient =
        \removeIngredientArg removeIngredientArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "removeIngredient"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Item" []
                                , Type.namedWith [] "Product" []
                                ]
                                (Type.namedWith [] "Product" [])
                            )
                    }
                )
                [ removeIngredientArg, removeIngredientArg0 ]
    , updateIngredientMass =
        \updateIngredientMassArg updateIngredientMassArg0 updateIngredientMassArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "updateIngredientMass"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Item" []
                                , Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Product" []
                                ]
                                (Type.namedWith [] "Product" [])
                            )
                    }
                )
                [ updateIngredientMassArg
                , updateIngredientMassArg0
                , updateIngredientMassArg1
                ]
    , addIngredient =
        \addIngredientArg addIngredientArg0 addIngredientArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "addIngredient"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Process" []
                                , Type.namedWith [] "Mass" []
                                , Type.namedWith [] "Product" []
                                ]
                                (Type.namedWith [] "Product" [])
                            )
                    }
                )
                [ addIngredientArg, addIngredientArg0, addIngredientArg1 ]
    , getWeightAtPlant =
        \getWeightAtPlantArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "getWeightAtPlant"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Items" [] ]
                                (Type.namedWith [] "Mass" [])
                            )
                    }
                )
                [ getWeightAtPlantArg ]
    , getStepTransports =
        \getStepTransportsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "getStepTransports"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Step" [] ]
                                (Type.record
                                    [ ( "air", Type.namedWith [] "Length" [] )
                                    , ( "rail", Type.namedWith [] "Length" [] )
                                    , ( "road", Type.namedWith [] "Length" [] )
                                    , ( "sea", Type.namedWith [] "Length" [] )
                                    ]
                                )
                            )
                    }
                )
                [ getStepTransportsArg ]
    , getTotalImpact =
        \getTotalImpactArg getTotalImpactArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "getTotalImpact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Definition" ] "Trigram" []
                                , Type.namedWith [] "Product" []
                                ]
                                Type.float
                            )
                    }
                )
                [ getTotalImpactArg, getTotalImpactArg0 ]
    , getItemsImpact =
        \getItemsImpactArg getItemsImpactArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "getItemsImpact"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Definition" ] "Trigram" []
                                , Type.namedWith [] "Items" []
                                ]
                                Type.float
                            )
                    }
                )
                [ getItemsImpactArg, getItemsImpactArg0 ]
    , decodeProducts =
        \decodeProductsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "decodeProducts"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.namedWith [] "Products" [] ]
                                )
                            )
                    }
                )
                [ decodeProductsArg ]
    , findByName =
        \findByNameArg findByNameArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "findByName"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ProductName" []
                                , Type.namedWith [] "Products" []
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Product" []
                                    ]
                                )
                            )
                    }
                )
                [ findByNameArg, findByNameArg0 ]
    , nameFromString =
        \nameFromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "nameFromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith [] "ProductName" [])
                            )
                    }
                )
                [ nameFromStringArg ]
    , nameToString =
        \nameToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "nameToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "ProductName" [] ]
                                Type.string
                            )
                    }
                )
                [ nameToStringArg ]
    , filterItemByCategory =
        \filterItemByCategoryArg filterItemByCategoryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Product" ]
                    , name = "filterItemByCategory"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Process" ] "Category" []
                                , Type.namedWith [] "Items" []
                                ]
                                (Type.namedWith [] "Items" [])
                            )
                    }
                )
                [ filterItemByCategoryArg, filterItemByCategoryArg0 ]
    }


values_ :
    { updatePlantTransport : Elm.Expression
    , getAmountRatio : Elm.Expression
    , removeIngredient : Elm.Expression
    , updateIngredientMass : Elm.Expression
    , addIngredient : Elm.Expression
    , getWeightAtPlant : Elm.Expression
    , getStepTransports : Elm.Expression
    , getTotalImpact : Elm.Expression
    , getItemsImpact : Elm.Expression
    , decodeProducts : Elm.Expression
    , findByName : Elm.Expression
    , emptyProducts : Elm.Expression
    , nameFromString : Elm.Expression
    , nameToString : Elm.Expression
    , filterItemByCategory : Elm.Expression
    , defaultCountry : Elm.Expression
    }
values_ =
    { updatePlantTransport =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "updatePlantTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Product" []
                        , Type.list (Type.namedWith [] "Process" [])
                        , Type.namedWith [ "Country" ] "Code" []
                        , Type.namedWith [] "Distances" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
    , getAmountRatio =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getAmountRatio"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Product" []
                        ]
                        Type.float
                    )
            }
    , removeIngredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "removeIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Item" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
    , updateIngredientMass =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "updateIngredientMass"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Item" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
    , addIngredient =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "addIngredient"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Process" []
                        , Type.namedWith [] "Mass" []
                        , Type.namedWith [] "Product" []
                        ]
                        (Type.namedWith [] "Product" [])
                    )
            }
    , getWeightAtPlant =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getWeightAtPlant"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Items" [] ]
                        (Type.namedWith [] "Mass" [])
                    )
            }
    , getStepTransports =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getStepTransports"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Step" [] ]
                        (Type.record
                            [ ( "air", Type.namedWith [] "Length" [] )
                            , ( "rail", Type.namedWith [] "Length" [] )
                            , ( "road", Type.namedWith [] "Length" [] )
                            , ( "sea", Type.namedWith [] "Length" [] )
                            ]
                        )
                    )
            }
    , getTotalImpact =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getTotalImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Definition" ] "Trigram" []
                        , Type.namedWith [] "Product" []
                        ]
                        Type.float
                    )
            }
    , getItemsImpact =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "getItemsImpact"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Definition" ] "Trigram" []
                        , Type.namedWith [] "Items" []
                        ]
                        Type.float
                    )
            }
    , decodeProducts =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "decodeProducts"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.namedWith [] "Products" [] ]
                        )
                    )
            }
    , findByName =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "findByName"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProductName" []
                        , Type.namedWith [] "Products" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Product" [] ]
                        )
                    )
            }
    , emptyProducts =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "emptyProducts"
            , annotation = Just (Type.namedWith [] "Products" [])
            }
    , nameFromString =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "nameFromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [] "ProductName" [])
                    )
            }
    , nameToString =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "nameToString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "ProductName" [] ]
                        Type.string
                    )
            }
    , filterItemByCategory =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "filterItemByCategory"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Process" ] "Category" []
                        , Type.namedWith [] "Items" []
                        ]
                        (Type.namedWith [] "Items" [])
                    )
            }
    , defaultCountry =
        Elm.value
            { importFrom = [ "Data", "Food", "Product" ]
            , name = "defaultCountry"
            , annotation = Just (Type.namedWith [ "Country" ] "Code" [])
            }
    }