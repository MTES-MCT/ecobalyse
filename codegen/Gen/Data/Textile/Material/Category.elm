module Gen.Data.Textile.Material.Category exposing (annotation_, call_, caseOf_, decode, make_, moduleName_, toString, values_)

{-| 
@docs moduleName_, toString, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Material", "Category" ]


{-| toString: Category -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material", "Category" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Category" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| decode: Decoder Category -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Textile", "Material", "Category" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith [] "Decoder" [ Type.namedWith [] "Category" [] ]
                )
        }


annotation_ : { category : Type.Annotation }
annotation_ =
    { category =
        Type.namedWith
            [ "Data", "Textile", "Material", "Category" ]
            "Category"
            []
    }


make_ :
    { natural : Elm.Expression
    , recycled : Elm.Expression
    , synthetic : Elm.Expression
    }
make_ =
    { natural =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material", "Category" ]
            , name = "Natural"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , recycled =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material", "Category" ]
            , name = "Recycled"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    , synthetic =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material", "Category" ]
            , name = "Synthetic"
            , annotation = Just (Type.namedWith [] "Category" [])
            }
    }


caseOf_ :
    { category :
        Elm.Expression
        -> { categoryTags_0_0
            | natural : Elm.Expression
            , recycled : Elm.Expression
            , synthetic : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { category =
        \categoryExpression categoryTags ->
            Elm.Case.custom
                categoryExpression
                (Type.namedWith
                    [ "Data", "Textile", "Material", "Category" ]
                    "Category"
                    []
                )
                [ Elm.Case.branch0 "Natural" categoryTags.natural
                , Elm.Case.branch0 "Recycled" categoryTags.recycled
                , Elm.Case.branch0 "Synthetic" categoryTags.synthetic
                ]
    }


call_ : { toString : Elm.Expression -> Elm.Expression }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material", "Category" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Category" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    }


values_ : { toString : Elm.Expression, decode : Elm.Expression }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material", "Category" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Category" [] ]
                        Type.string
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material", "Category" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Category" [] ]
                    )
            }
    }