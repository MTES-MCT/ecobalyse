module Gen.Data.Food.Ingredient.Category exposing (annotation_, call_, caseOf_, decode, fromAnimalOrigin, make_, moduleName_, toLabel, values_)

{-| 
@docs moduleName_, decode, toLabel, fromAnimalOrigin, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Ingredient", "Category" ]


{-| decode: Decoder Category -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Category" [] ]
                )
        }


{-| toLabel: Category -> String -}
toLabel : Elm.Expression -> Elm.Expression
toLabel toLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Category" [] ]
                        Type.string
                    )
            }
        )
        [ toLabelArg ]


{-| fromAnimalOrigin: Category -> Bool -}
fromAnimalOrigin : Elm.Expression -> Elm.Expression
fromAnimalOrigin fromAnimalOriginArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "fromAnimalOrigin"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Category" [] ] Type.bool
                    )
            }
        )
        [ fromAnimalOriginArg ]


annotation_ : { category : Type.Annotation }
annotation_ =
    { category =
        Type.namedWith
            [ "Data", "Food", "Ingredient", "Category" ]
            "Category"
            []
    }


make_ :
    { animalProduct : Elm.Expression
    , dairyProduct : Elm.Expression
    , grainRaw : Elm.Expression
    , grainProcessed : Elm.Expression
    , misc : Elm.Expression
    , nutOilseedRaw : Elm.Expression
    , nutOilseedProcessed : Elm.Expression
    , spiceCondimentOrAdditive : Elm.Expression
    , vegetableFresh : Elm.Expression
    , vegetableProcessed : Elm.Expression
    }
make_ =
    { animalProduct =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "AnimalProduct"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , dairyProduct =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "DairyProduct"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , grainRaw =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "GrainRaw"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , grainProcessed =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "GrainProcessed"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , misc =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "Misc"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , nutOilseedRaw =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "NutOilseedRaw"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , nutOilseedProcessed =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "NutOilseedProcessed"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , spiceCondimentOrAdditive =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "SpiceCondimentOrAdditive"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , vegetableFresh =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "VegetableFresh"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , vegetableProcessed =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "VegetableProcessed"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    }


caseOf_ :
    { category :
        Elm.Expression
        -> { categoryTags_0_0
            | animalProduct : Elm.Expression
            , dairyProduct : Elm.Expression
            , grainRaw : Elm.Expression
            , grainProcessed : Elm.Expression
            , misc : Elm.Expression
            , nutOilseedRaw : Elm.Expression
            , nutOilseedProcessed : Elm.Expression
            , spiceCondimentOrAdditive : Elm.Expression
            , vegetableFresh : Elm.Expression
            , vegetableProcessed : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { category =
        \categoryExpression categoryTags ->
            Elm.Case.custom
                categoryExpression
                (Type.namedWith
                    [ "Data", "Food", "Ingredient", "Category" ]
                    "Category"
                    []
                )
                [ Elm.Case.branch0 "AnimalProduct" categoryTags.animalProduct
                , Elm.Case.branch0 "DairyProduct" categoryTags.dairyProduct
                , Elm.Case.branch0 "GrainRaw" categoryTags.grainRaw
                , Elm.Case.branch0 "GrainProcessed" categoryTags.grainProcessed
                , Elm.Case.branch0 "Misc" categoryTags.misc
                , Elm.Case.branch0 "NutOilseedRaw" categoryTags.nutOilseedRaw
                , Elm.Case.branch0
                    "NutOilseedProcessed"
                    categoryTags.nutOilseedProcessed
                , Elm.Case.branch0
                    "SpiceCondimentOrAdditive"
                    categoryTags.spiceCondimentOrAdditive
                , Elm.Case.branch0 "VegetableFresh" categoryTags.vegetableFresh
                , Elm.Case.branch0
                    "VegetableProcessed"
                    categoryTags.vegetableProcessed
                ]
    }


call_ :
    { toLabel : Elm.Expression -> Elm.Expression
    , fromAnimalOrigin : Elm.Expression -> Elm.Expression
    }
call_ =
    { toLabel =
        \toLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
                    , name = "toLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Category" [] ]
                                Type.string
                            )
                    }
                )
                [ toLabelArg ]
    , fromAnimalOrigin =
        \fromAnimalOriginArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
                    , name = "fromAnimalOrigin"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Category" [] ]
                                Type.bool
                            )
                    }
                )
                [ fromAnimalOriginArg ]
    }


values_ :
    { decode : Elm.Expression
    , toLabel : Elm.Expression
    , fromAnimalOrigin : Elm.Expression
    }
values_ =
    { decode =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Category" [] ]
                    )
            }
    , toLabel =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Category" [] ]
                        Type.string
                    )
            }
    , fromAnimalOrigin =
        Elm.value
            { importFrom = [ "Data", "Food", "Ingredient", "Category" ]
            , name = "fromAnimalOrigin"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Category" [] ] Type.bool
                    )
            }
    }