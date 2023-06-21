module Gen.Data.Dataset exposing (annotation_, call_, caseOf_, datasets, isDetailed, label, make_, moduleName_, parseSlug, reset, same, setIdFromString, toRoutePath, values_)

{-| 
@docs moduleName_, toRoutePath, setIdFromString, same, reset, parseSlug, label, isDetailed, datasets, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Dataset" ]


{-| toRoutePath: Dataset -> List String -}
toRoutePath : Elm.Expression -> Elm.Expression
toRoutePath toRoutePathArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "toRoutePath"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        (Type.list Type.string)
                    )
            }
        )
        [ toRoutePathArg ]


{-| setIdFromString: String -> Dataset -> Dataset -}
setIdFromString : String -> Elm.Expression -> Elm.Expression
setIdFromString setIdFromStringArg setIdFromStringArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "setIdFromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Dataset" [] ]
                        (Type.namedWith [] "Dataset" [])
                    )
            }
        )
        [ Elm.string setIdFromStringArg, setIdFromStringArg0 ]


{-| same: Dataset -> Dataset -> Bool -}
same : Elm.Expression -> Elm.Expression -> Elm.Expression
same sameArg sameArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "same"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" []
                        , Type.namedWith [] "Dataset" []
                        ]
                        Type.bool
                    )
            }
        )
        [ sameArg, sameArg0 ]


{-| reset: Dataset -> Dataset -}
reset : Elm.Expression -> Elm.Expression
reset resetArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "reset"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        (Type.namedWith [] "Dataset" [])
                    )
            }
        )
        [ resetArg ]


{-| parseSlug: Parser (Dataset -> a) a -}
parseSlug : Elm.Expression
parseSlug =
    Elm.value
        { importFrom = [ "Data", "Dataset" ]
        , name = "parseSlug"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Parser"
                    [ Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        (Type.var "a")
                    , Type.var "a"
                    ]
                )
        }


{-| label: Dataset -> String -}
label : Elm.Expression -> Elm.Expression
label labelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "label"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        Type.string
                    )
            }
        )
        [ labelArg ]


{-| isDetailed: Dataset -> Bool -}
isDetailed : Elm.Expression -> Elm.Expression
isDetailed isDetailedArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "isDetailed"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Dataset" [] ] Type.bool)
            }
        )
        [ isDetailedArg ]


{-| datasets: Scope -> List Dataset -}
datasets : Elm.Expression -> Elm.Expression
datasets datasetsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "datasets"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" [] ]
                        (Type.list (Type.namedWith [] "Dataset" []))
                    )
            }
        )
        [ datasetsArg ]


annotation_ : { dataset : Type.Annotation }
annotation_ =
    { dataset = Type.namedWith [ "Data", "Dataset" ] "Dataset" [] }


make_ :
    { countries : Elm.Expression -> Elm.Expression
    , impacts : Elm.Expression -> Elm.Expression
    , foodIngredients : Elm.Expression -> Elm.Expression
    , textileProducts : Elm.Expression -> Elm.Expression
    , textileMaterials : Elm.Expression -> Elm.Expression
    , textileProcesses : Elm.Expression -> Elm.Expression
    }
make_ =
    { countries =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "Countries"
                    , annotation = Just (Type.namedWith [] "Dataset" [])
                    }
                )
                [ ar0 ]
    , impacts =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "Impacts"
                    , annotation = Just (Type.namedWith [] "Dataset" [])
                    }
                )
                [ ar0 ]
    , foodIngredients =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "FoodIngredients"
                    , annotation = Just (Type.namedWith [] "Dataset" [])
                    }
                )
                [ ar0 ]
    , textileProducts =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "TextileProducts"
                    , annotation = Just (Type.namedWith [] "Dataset" [])
                    }
                )
                [ ar0 ]
    , textileMaterials =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "TextileMaterials"
                    , annotation = Just (Type.namedWith [] "Dataset" [])
                    }
                )
                [ ar0 ]
    , textileProcesses =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "TextileProcesses"
                    , annotation = Just (Type.namedWith [] "Dataset" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { dataset :
        Elm.Expression
        -> { datasetTags_0_0
            | countries : Elm.Expression -> Elm.Expression
            , impacts : Elm.Expression -> Elm.Expression
            , foodIngredients : Elm.Expression -> Elm.Expression
            , textileProducts : Elm.Expression -> Elm.Expression
            , textileMaterials : Elm.Expression -> Elm.Expression
            , textileProcesses : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { dataset =
        \datasetExpression datasetTags ->
            Elm.Case.custom
                datasetExpression
                (Type.namedWith [ "Data", "Dataset" ] "Dataset" [])
                [ Elm.Case.branch1
                    "Countries"
                    ( "maybe"
                    , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Country" ] "Code" [] ]
                    )
                    datasetTags.countries
                , Elm.Case.branch1
                    "Impacts"
                    ( "maybe"
                    , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Definition" ] "Trigram" [] ]
                    )
                    datasetTags.impacts
                , Elm.Case.branch1
                    "FoodIngredients"
                    ( "maybe"
                    , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Ingredient" ] "Id" [] ]
                    )
                    datasetTags.foodIngredients
                , Elm.Case.branch1
                    "TextileProducts"
                    ( "maybe"
                    , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Product" ] "Id" [] ]
                    )
                    datasetTags.textileProducts
                , Elm.Case.branch1
                    "TextileMaterials"
                    ( "maybe"
                    , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Material" ] "Id" [] ]
                    )
                    datasetTags.textileMaterials
                , Elm.Case.branch1
                    "TextileProcesses"
                    ( "maybe"
                    , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [ "Process" ] "Uuid" [] ]
                    )
                    datasetTags.textileProcesses
                ]
    }


call_ :
    { toRoutePath : Elm.Expression -> Elm.Expression
    , setIdFromString : Elm.Expression -> Elm.Expression -> Elm.Expression
    , same : Elm.Expression -> Elm.Expression -> Elm.Expression
    , reset : Elm.Expression -> Elm.Expression
    , label : Elm.Expression -> Elm.Expression
    , isDetailed : Elm.Expression -> Elm.Expression
    , datasets : Elm.Expression -> Elm.Expression
    }
call_ =
    { toRoutePath =
        \toRoutePathArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "toRoutePath"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Dataset" [] ]
                                (Type.list Type.string)
                            )
                    }
                )
                [ toRoutePathArg ]
    , setIdFromString =
        \setIdFromStringArg setIdFromStringArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "setIdFromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string, Type.namedWith [] "Dataset" [] ]
                                (Type.namedWith [] "Dataset" [])
                            )
                    }
                )
                [ setIdFromStringArg, setIdFromStringArg0 ]
    , same =
        \sameArg sameArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "same"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Dataset" []
                                , Type.namedWith [] "Dataset" []
                                ]
                                Type.bool
                            )
                    }
                )
                [ sameArg, sameArg0 ]
    , reset =
        \resetArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "reset"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Dataset" [] ]
                                (Type.namedWith [] "Dataset" [])
                            )
                    }
                )
                [ resetArg ]
    , label =
        \labelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "label"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Dataset" [] ]
                                Type.string
                            )
                    }
                )
                [ labelArg ]
    , isDetailed =
        \isDetailedArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "isDetailed"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Dataset" [] ]
                                Type.bool
                            )
                    }
                )
                [ isDetailedArg ]
    , datasets =
        \datasetsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Dataset" ]
                    , name = "datasets"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Scope" [] ]
                                (Type.list (Type.namedWith [] "Dataset" []))
                            )
                    }
                )
                [ datasetsArg ]
    }


values_ :
    { toRoutePath : Elm.Expression
    , setIdFromString : Elm.Expression
    , same : Elm.Expression
    , reset : Elm.Expression
    , parseSlug : Elm.Expression
    , label : Elm.Expression
    , isDetailed : Elm.Expression
    , datasets : Elm.Expression
    }
values_ =
    { toRoutePath =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "toRoutePath"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        (Type.list Type.string)
                    )
            }
    , setIdFromString =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "setIdFromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.namedWith [] "Dataset" [] ]
                        (Type.namedWith [] "Dataset" [])
                    )
            }
    , same =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "same"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" []
                        , Type.namedWith [] "Dataset" []
                        ]
                        Type.bool
                    )
            }
    , reset =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "reset"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        (Type.namedWith [] "Dataset" [])
                    )
            }
    , parseSlug =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "parseSlug"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Parser"
                        [ Type.function
                            [ Type.namedWith [] "Dataset" [] ]
                            (Type.var "a")
                        , Type.var "a"
                        ]
                    )
            }
    , label =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "label"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Dataset" [] ]
                        Type.string
                    )
            }
    , isDetailed =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "isDetailed"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Dataset" [] ] Type.bool)
            }
    , datasets =
        Elm.value
            { importFrom = [ "Data", "Dataset" ]
            , name = "datasets"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Scope" [] ]
                        (Type.list (Type.namedWith [] "Dataset" []))
                    )
            }
    }