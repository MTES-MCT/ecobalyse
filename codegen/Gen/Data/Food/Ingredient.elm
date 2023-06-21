module Gen.Data.Food.Ingredient exposing (annotation_, byPlaneAllowed, byPlaneByDefault, call_, caseOf_, decodeBonuses, decodeId, decodeIngredients, defaultBonuses, encodeBonuses, encodeId, encodePlaneTransport, findByID, getDefaultOrganicBonuses, getDefaultOriginTransport, groupCategories, idFromString, idToString, make_, moduleName_, values_)

{-| 
@docs moduleName_, groupCategories, getDefaultOriginTransport, findByID, decodeIngredients, decodeBonuses, idToString, idFromString, getDefaultOrganicBonuses, encodePlaneTransport, encodeId, encodeBonuses, defaultBonuses, decodeId, byPlaneByDefault, byPlaneAllowed, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Ingredient" ]


{-| groupCategories: List Ingredient -> List ( IngredientCategory.Category, List Ingredient ) -}
groupCategories : List Elm.Expression -> Elm.Expression
groupCategories groupCategoriesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "groupCategories"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Ingredient" []) ]
                        (Type.list
                            (Type.tuple
                                (Type.namedWith
                                    [ "IngredientCategory" ]
                                    "Category"
                                    []
                                )
                                (Type.list (Type.namedWith [] "Ingredient" []))
                            )
                        )
                    )
            }
        )
        [ Elm.list groupCategoriesArg ]


{-| getDefaultOriginTransport: PlaneTransport -> Origin -> Transport -}
getDefaultOriginTransport : Elm.Expression -> Elm.Expression -> Elm.Expression
getDefaultOriginTransport getDefaultOriginTransportArg getDefaultOriginTransportArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "getDefaultOriginTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PlaneTransport" []
                        , Type.namedWith [] "Origin" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
        )
        [ getDefaultOriginTransportArg, getDefaultOriginTransportArg0 ]


{-| findByID: Id -> List Ingredient -> Result String Ingredient -}
findByID : Elm.Expression -> List Elm.Expression -> Elm.Expression
findByID findByIDArg findByIDArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "findByID"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" []
                        , Type.list (Type.namedWith [] "Ingredient" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Ingredient" [] ]
                        )
                    )
            }
        )
        [ findByIDArg, Elm.list findByIDArg0 ]


{-| decodeIngredients: List Process -> Decoder (List Ingredient) -}
decodeIngredients : List Elm.Expression -> Elm.Expression
decodeIngredients decodeIngredientsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "decodeIngredients"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Ingredient" []) ]
                        )
                    )
            }
        )
        [ Elm.list decodeIngredientsArg ]


{-| decodeBonuses: Decoder Bonuses -}
decodeBonuses : Elm.Expression
decodeBonuses =
    Elm.value
        { importFrom = [ "Data", "Food", "Ingredient" ]
        , name = "decodeBonuses"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Bonuses" [] ])
        }


{-| idToString: Id -> String -}
idToString : Elm.Expression -> Elm.Expression
idToString idToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
        )
        [ idToStringArg ]


{-| idFromString: String -> Id -}
idFromString : String -> Elm.Expression
idFromString idFromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "idFromString"
            , annotation =
                Just (Type.function [ Type.string ] (Type.namedWith [] "Id" []))
            }
        )
        [ Elm.string idFromStringArg ]


{-| getDefaultOrganicBonuses: Ingredient -> Bonuses -}
getDefaultOrganicBonuses : Elm.Expression -> Elm.Expression
getDefaultOrganicBonuses getDefaultOrganicBonusesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "getDefaultOrganicBonuses"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Ingredient" [] ]
                        (Type.namedWith [] "Bonuses" [])
                    )
            }
        )
        [ getDefaultOrganicBonusesArg ]


{-| encodePlaneTransport: PlaneTransport -> Maybe Encode.Value -}
encodePlaneTransport : Elm.Expression -> Elm.Expression
encodePlaneTransport encodePlaneTransportArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "encodePlaneTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PlaneTransport" [] ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [ "Encode" ] "Value" [] ]
                        )
                    )
            }
        )
        [ encodePlaneTransportArg ]


{-| encodeId: Id -> Encode.Value -}
encodeId : Elm.Expression -> Elm.Expression
encodeId encodeIdArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
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


{-| encodeBonuses: Bonuses -> Encode.Value -}
encodeBonuses : Elm.Expression -> Elm.Expression
encodeBonuses encodeBonusesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "encodeBonuses"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bonuses" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeBonusesArg ]


{-| defaultBonuses: { a | category : IngredientCategory.Category } -> Bonuses -}
defaultBonuses : { a | category : Elm.Expression } -> Elm.Expression
defaultBonuses defaultBonusesArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "defaultBonuses"
            , annotation =
                Just
                    (Type.function
                        [ Type.extensible
                            "a"
                            [ ( "category"
                              , Type.namedWith
                                    [ "IngredientCategory" ]
                                    "Category"
                                    []
                              )
                            ]
                        ]
                        (Type.namedWith [] "Bonuses" [])
                    )
            }
        )
        [ Elm.record [ Tuple.pair "category" defaultBonusesArg.category ] ]


{-| decodeId: Decode.Decoder Id -}
decodeId : Elm.Expression
decodeId =
    Elm.value
        { importFrom = [ "Data", "Food", "Ingredient" ]
        , name = "decodeId"
        , annotation =
            Just
                (Type.namedWith
                    [ "Decode" ]
                    "Decoder"
                    [ Type.namedWith [] "Id" [] ]
                )
        }


{-| byPlaneByDefault: Ingredient -> PlaneTransport -}
byPlaneByDefault : Elm.Expression -> Elm.Expression
byPlaneByDefault byPlaneByDefaultArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "byPlaneByDefault"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Ingredient" [] ]
                        (Type.namedWith [] "PlaneTransport" [])
                    )
            }
        )
        [ byPlaneByDefaultArg ]


{-| byPlaneAllowed: PlaneTransport -> Ingredient -> Result String PlaneTransport -}
byPlaneAllowed : Elm.Expression -> Elm.Expression -> Elm.Expression
byPlaneAllowed byPlaneAllowedArg byPlaneAllowedArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "byPlaneAllowed"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PlaneTransport" []
                        , Type.namedWith [] "Ingredient" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string
                            , Type.namedWith [] "PlaneTransport" []
                            ]
                        )
                    )
            }
        )
        [ byPlaneAllowedArg, byPlaneAllowedArg0 ]


annotation_ :
    { bonuses : Type.Annotation
    , ingredient : Type.Annotation
    , transportCooling : Type.Annotation
    , planeTransport : Type.Annotation
    , id : Type.Annotation
    }
annotation_ =
    { bonuses =
        Type.alias
            moduleName_
            "Bonuses"
            []
            (Type.record
                [ ( "agroDiversity", Type.namedWith [] "Split" [] )
                , ( "agroEcology", Type.namedWith [] "Split" [] )
                , ( "animalWelfare", Type.namedWith [] "Split" [] )
                ]
            )
    , ingredient =
        Type.alias
            moduleName_
            "Ingredient"
            []
            (Type.record
                [ ( "id", Type.namedWith [] "Id" [] )
                , ( "name", Type.string )
                , ( "category"
                  , Type.namedWith [ "IngredientCategory" ] "Category" []
                  )
                , ( "default", Type.namedWith [] "Process" [] )
                , ( "defaultOrigin", Type.namedWith [] "Origin" [] )
                , ( "rawToCookedRatio", Type.namedWith [ "Unit" ] "Ratio" [] )
                , ( "variants", Type.namedWith [] "Variants" [] )
                , ( "density", Type.namedWith [] "Density" [] )
                , ( "transportCooling"
                  , Type.namedWith [] "TransportCooling" []
                  )
                , ( "visible", Type.bool )
                ]
            )
    , transportCooling =
        Type.namedWith [ "Data", "Food", "Ingredient" ] "TransportCooling" []
    , planeTransport =
        Type.namedWith [ "Data", "Food", "Ingredient" ] "PlaneTransport" []
    , id = Type.namedWith [ "Data", "Food", "Ingredient" ] "Id" []
    }


make_ :
    { bonuses :
        { agroDiversity : Elm.Expression
        , agroEcology : Elm.Expression
        , animalWelfare : Elm.Expression
        }
        -> Elm.Expression
    , ingredient :
        { id : Elm.Expression
        , name : Elm.Expression
        , category : Elm.Expression
        , default : Elm.Expression
        , defaultOrigin : Elm.Expression
        , rawToCookedRatio : Elm.Expression
        , variants : Elm.Expression
        , density : Elm.Expression
        , transportCooling : Elm.Expression
        , visible : Elm.Expression
        }
        -> Elm.Expression
    , noCooling : Elm.Expression
    , alwaysCool : Elm.Expression
    , coolOnceTransformed : Elm.Expression
    , planeNotApplicable : Elm.Expression
    , byPlane : Elm.Expression
    , noPlane : Elm.Expression
    , id : Elm.Expression -> Elm.Expression
    }
make_ =
    { bonuses =
        \bonuses_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Ingredient" ]
                    "Bonuses"
                    []
                    (Type.record
                        [ ( "agroDiversity", Type.namedWith [] "Split" [] )
                        , ( "agroEcology", Type.namedWith [] "Split" [] )
                        , ( "animalWelfare", Type.namedWith [] "Split" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "agroDiversity" bonuses_args.agroDiversity
                    , Tuple.pair "agroEcology" bonuses_args.agroEcology
                    , Tuple.pair "animalWelfare" bonuses_args.animalWelfare
                    ]
                )
    , ingredient =
        \ingredient_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Food", "Ingredient" ]
                    "Ingredient"
                    []
                    (Type.record
                        [ ( "id", Type.namedWith [] "Id" [] )
                        , ( "name", Type.string )
                        , ( "category"
                          , Type.namedWith
                                [ "IngredientCategory" ]
                                "Category"
                                []
                          )
                        , ( "default", Type.namedWith [] "Process" [] )
                        , ( "defaultOrigin", Type.namedWith [] "Origin" [] )
                        , ( "rawToCookedRatio"
                          , Type.namedWith [ "Unit" ] "Ratio" []
                          )
                        , ( "variants", Type.namedWith [] "Variants" [] )
                        , ( "density", Type.namedWith [] "Density" [] )
                        , ( "transportCooling"
                          , Type.namedWith [] "TransportCooling" []
                          )
                        , ( "visible", Type.bool )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "id" ingredient_args.id
                    , Tuple.pair "name" ingredient_args.name
                    , Tuple.pair "category" ingredient_args.category
                    , Tuple.pair "default" ingredient_args.default
                    , Tuple.pair "defaultOrigin" ingredient_args.defaultOrigin
                    , Tuple.pair
                        "rawToCookedRatio"
                        ingredient_args.rawToCookedRatio
                    , Tuple.pair "variants" ingredient_args.variants
                    , Tuple.pair "density" ingredient_args.density
                    , Tuple.pair
                        "transportCooling"
                        ingredient_args.transportCooling
                    , Tuple.pair "visible" ingredient_args.visible
                    ]
                )
    , noCooling =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "NoCooling"
            , annotation = Just (Type.namedWith [] "TransportCooling" [])
            }
    , alwaysCool =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "AlwaysCool"
            , annotation = Just (Type.namedWith [] "TransportCooling" [])
            }
    , coolOnceTransformed =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "CoolOnceTransformed"
            , annotation = Just (Type.namedWith [] "TransportCooling" [])
            }
    , planeNotApplicable =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "PlaneNotApplicable"
            , annotation = Just (Type.namedWith [] "PlaneTransport" [])
            }
    , byPlane =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "ByPlane"
            , annotation = Just (Type.namedWith [] "PlaneTransport" [])
            }
    , noPlane =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "NoPlane"
            , annotation = Just (Type.namedWith [] "PlaneTransport" [])
            }
    , id =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "Id"
                    , annotation = Just (Type.namedWith [] "Id" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { transportCooling :
        Elm.Expression
        -> { transportCoolingTags_0_0
            | noCooling : Elm.Expression
            , alwaysCool : Elm.Expression
            , coolOnceTransformed : Elm.Expression
        }
        -> Elm.Expression
    , planeTransport :
        Elm.Expression
        -> { planeTransportTags_1_0
            | planeNotApplicable : Elm.Expression
            , byPlane : Elm.Expression
            , noPlane : Elm.Expression
        }
        -> Elm.Expression
    , id :
        Elm.Expression
        -> { idTags_2_0 | id : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    }
caseOf_ =
    { transportCooling =
        \transportCoolingExpression transportCoolingTags ->
            Elm.Case.custom
                transportCoolingExpression
                (Type.namedWith
                    [ "Data", "Food", "Ingredient" ]
                    "TransportCooling"
                    []
                )
                [ Elm.Case.branch0 "NoCooling" transportCoolingTags.noCooling
                , Elm.Case.branch0 "AlwaysCool" transportCoolingTags.alwaysCool
                , Elm.Case.branch0
                    "CoolOnceTransformed"
                    transportCoolingTags.coolOnceTransformed
                ]
    , planeTransport =
        \planeTransportExpression planeTransportTags ->
            Elm.Case.custom
                planeTransportExpression
                (Type.namedWith
                    [ "Data", "Food", "Ingredient" ]
                    "PlaneTransport"
                    []
                )
                [ Elm.Case.branch0
                    "PlaneNotApplicable"
                    planeTransportTags.planeNotApplicable
                , Elm.Case.branch0 "ByPlane" planeTransportTags.byPlane
                , Elm.Case.branch0 "NoPlane" planeTransportTags.noPlane
                ]
    , id =
        \idExpression idTags ->
            Elm.Case.custom
                idExpression
                (Type.namedWith [ "Data", "Food", "Ingredient" ] "Id" [])
                [ Elm.Case.branch1
                    "Id"
                    ( "string.String", Type.string )
                    idTags.id
                ]
    }


call_ :
    { groupCategories : Elm.Expression -> Elm.Expression
    , getDefaultOriginTransport :
        Elm.Expression -> Elm.Expression -> Elm.Expression
    , findByID : Elm.Expression -> Elm.Expression -> Elm.Expression
    , decodeIngredients : Elm.Expression -> Elm.Expression
    , idToString : Elm.Expression -> Elm.Expression
    , idFromString : Elm.Expression -> Elm.Expression
    , getDefaultOrganicBonuses : Elm.Expression -> Elm.Expression
    , encodePlaneTransport : Elm.Expression -> Elm.Expression
    , encodeId : Elm.Expression -> Elm.Expression
    , encodeBonuses : Elm.Expression -> Elm.Expression
    , defaultBonuses : Elm.Expression -> Elm.Expression
    , byPlaneByDefault : Elm.Expression -> Elm.Expression
    , byPlaneAllowed : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { groupCategories =
        \groupCategoriesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "groupCategories"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Ingredient" [])
                                ]
                                (Type.list
                                    (Type.tuple
                                        (Type.namedWith
                                            [ "IngredientCategory" ]
                                            "Category"
                                            []
                                        )
                                        (Type.list
                                            (Type.namedWith [] "Ingredient" [])
                                        )
                                    )
                                )
                            )
                    }
                )
                [ groupCategoriesArg ]
    , getDefaultOriginTransport =
        \getDefaultOriginTransportArg getDefaultOriginTransportArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "getDefaultOriginTransport"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "PlaneTransport" []
                                , Type.namedWith [] "Origin" []
                                ]
                                (Type.namedWith [] "Transport" [])
                            )
                    }
                )
                [ getDefaultOriginTransportArg, getDefaultOriginTransportArg0 ]
    , findByID =
        \findByIDArg findByIDArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "findByID"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" []
                                , Type.list (Type.namedWith [] "Ingredient" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Ingredient" []
                                    ]
                                )
                            )
                    }
                )
                [ findByIDArg, findByIDArg0 ]
    , decodeIngredients =
        \decodeIngredientsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "decodeIngredients"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.list
                                        (Type.namedWith [] "Ingredient" [])
                                    ]
                                )
                            )
                    }
                )
                [ decodeIngredientsArg ]
    , idToString =
        \idToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
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
    , idFromString =
        \idFromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "idFromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith [] "Id" [])
                            )
                    }
                )
                [ idFromStringArg ]
    , getDefaultOrganicBonuses =
        \getDefaultOrganicBonusesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "getDefaultOrganicBonuses"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Ingredient" [] ]
                                (Type.namedWith [] "Bonuses" [])
                            )
                    }
                )
                [ getDefaultOrganicBonusesArg ]
    , encodePlaneTransport =
        \encodePlaneTransportArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "encodePlaneTransport"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "PlaneTransport" [] ]
                                (Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [ "Encode" ] "Value" [] ]
                                )
                            )
                    }
                )
                [ encodePlaneTransportArg ]
    , encodeId =
        \encodeIdArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
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
    , encodeBonuses =
        \encodeBonusesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "encodeBonuses"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bonuses" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeBonusesArg ]
    , defaultBonuses =
        \defaultBonusesArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "defaultBonuses"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.extensible
                                    "a"
                                    [ ( "category"
                                      , Type.namedWith
                                            [ "IngredientCategory" ]
                                            "Category"
                                            []
                                      )
                                    ]
                                ]
                                (Type.namedWith [] "Bonuses" [])
                            )
                    }
                )
                [ defaultBonusesArg ]
    , byPlaneByDefault =
        \byPlaneByDefaultArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "byPlaneByDefault"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Ingredient" [] ]
                                (Type.namedWith [] "PlaneTransport" [])
                            )
                    }
                )
                [ byPlaneByDefaultArg ]
    , byPlaneAllowed =
        \byPlaneAllowedArg byPlaneAllowedArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient" ]
                    , name = "byPlaneAllowed"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "PlaneTransport" []
                                , Type.namedWith [] "Ingredient" []
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "PlaneTransport" []
                                    ]
                                )
                            )
                    }
                )
                [ byPlaneAllowedArg, byPlaneAllowedArg0 ]
    }


values_ :
    { groupCategories : Elm.Expression
    , getDefaultOriginTransport : Elm.Expression
    , findByID : Elm.Expression
    , decodeIngredients : Elm.Expression
    , decodeBonuses : Elm.Expression
    , idToString : Elm.Expression
    , idFromString : Elm.Expression
    , getDefaultOrganicBonuses : Elm.Expression
    , encodePlaneTransport : Elm.Expression
    , encodeId : Elm.Expression
    , encodeBonuses : Elm.Expression
    , defaultBonuses : Elm.Expression
    , decodeId : Elm.Expression
    , byPlaneByDefault : Elm.Expression
    , byPlaneAllowed : Elm.Expression
    }
values_ =
    { groupCategories =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "groupCategories"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Ingredient" []) ]
                        (Type.list
                            (Type.tuple
                                (Type.namedWith
                                    [ "IngredientCategory" ]
                                    "Category"
                                    []
                                )
                                (Type.list (Type.namedWith [] "Ingredient" []))
                            )
                        )
                    )
            }
    , getDefaultOriginTransport =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "getDefaultOriginTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PlaneTransport" []
                        , Type.namedWith [] "Origin" []
                        ]
                        (Type.namedWith [] "Transport" [])
                    )
            }
    , findByID =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "findByID"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" []
                        , Type.list (Type.namedWith [] "Ingredient" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Ingredient" [] ]
                        )
                    )
            }
    , decodeIngredients =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "decodeIngredients"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Ingredient" []) ]
                        )
                    )
            }
    , decodeBonuses =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "decodeBonuses"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Bonuses" [] ]
                    )
            }
    , idToString =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
    , idFromString =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "idFromString"
            , annotation =
                Just (Type.function [ Type.string ] (Type.namedWith [] "Id" []))
            }
    , getDefaultOrganicBonuses =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "getDefaultOrganicBonuses"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Ingredient" [] ]
                        (Type.namedWith [] "Bonuses" [])
                    )
            }
    , encodePlaneTransport =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "encodePlaneTransport"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PlaneTransport" [] ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [ "Encode" ] "Value" [] ]
                        )
                    )
            }
    , encodeId =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , encodeBonuses =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "encodeBonuses"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bonuses" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , defaultBonuses =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "defaultBonuses"
            , annotation =
                Just
                    (Type.function
                        [ Type.extensible
                            "a"
                            [ ( "category"
                              , Type.namedWith
                                    [ "IngredientCategory" ]
                                    "Category"
                                    []
                              )
                            ]
                        ]
                        (Type.namedWith [] "Bonuses" [])
                    )
            }
    , decodeId =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "decodeId"
            , annotation =
                Just
                    (Type.namedWith
                        [ "Decode" ]
                        "Decoder"
                        [ Type.namedWith [] "Id" [] ]
                    )
            }
    , byPlaneByDefault =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "byPlaneByDefault"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Ingredient" [] ]
                        (Type.namedWith [] "PlaneTransport" [])
                    )
            }
    , byPlaneAllowed =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient" ]
            , name = "byPlaneAllowed"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "PlaneTransport" []
                        , Type.namedWith [] "Ingredient" []
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string
                            , Type.namedWith [] "PlaneTransport" []
                            ]
                        )
                    )
            }
    }