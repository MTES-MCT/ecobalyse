module Gen.Data.Textile.DyeingMedium exposing (annotation_, call_, caseOf_, decode, encode, fromString, make_, moduleName_, toLabel, toString, values_)

{-| 
@docs moduleName_, toString, toLabel, fromString, encode, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "DyeingMedium" ]


{-| toString: DyeingMedium -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| toLabel: DyeingMedium -> String -}
toLabel : Elm.Expression -> Elm.Expression
toLabel toLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" [] ]
                        Type.string
                    )
            }
        )
        [ toLabelArg ]


{-| fromString: String -> Result String DyeingMedium -}
fromString : String -> Elm.Expression
fromString fromStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "DyeingMedium" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromStringArg ]


{-| encode: DyeingMedium -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decode: Decoder DyeingMedium -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Textile", "DyeingMedium" ]
        , name = "decode"
        , annotation =
            Just
                (Type.namedWith
                    []
                    "Decoder"
                    [ Type.namedWith [] "DyeingMedium" [] ]
                )
        }


annotation_ : { dyeingMedium : Type.Annotation }
annotation_ =
    { dyeingMedium =
        Type.namedWith [ "Data", "Textile", "DyeingMedium" ] "DyeingMedium" []
    }


make_ :
    { article : Elm.Expression, fabric : Elm.Expression, yarn : Elm.Expression }
make_ =
    { article =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "Article"
            , annotation = Just (Type.namedWith [] "DyeingMedium" [])
            }
    , fabric =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "Fabric"
            , annotation = Just (Type.namedWith [] "DyeingMedium" [])
            }
    , yarn =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "Yarn"
            , annotation = Just (Type.namedWith [] "DyeingMedium" [])
            }
    }


caseOf_ :
    { dyeingMedium :
        Elm.Expression
        -> { dyeingMediumTags_0_0
            | article : Elm.Expression
            , fabric : Elm.Expression
            , yarn : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { dyeingMedium =
        \dyeingMediumExpression dyeingMediumTags ->
            Elm.Case.custom
                dyeingMediumExpression
                (Type.namedWith
                    [ "Data", "Textile", "DyeingMedium" ]
                    "DyeingMedium"
                    []
                )
                [ Elm.Case.branch0 "Article" dyeingMediumTags.article
                , Elm.Case.branch0 "Fabric" dyeingMediumTags.fabric
                , Elm.Case.branch0 "Yarn" dyeingMediumTags.yarn
                ]
    }


call_ :
    { toString : Elm.Expression -> Elm.Expression
    , toLabel : Elm.Expression -> Elm.Expression
    , fromString : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "DyeingMedium" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "DyeingMedium" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , toLabel =
        \toLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "DyeingMedium" ]
                    , name = "toLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "DyeingMedium" [] ]
                                Type.string
                            )
                    }
                )
                [ toLabelArg ]
    , fromString =
        \fromStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "DyeingMedium" ]
                    , name = "fromString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "DyeingMedium" []
                                    ]
                                )
                            )
                    }
                )
                [ fromStringArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "DyeingMedium" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "DyeingMedium" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    }


values_ :
    { toString : Elm.Expression
    , toLabel : Elm.Expression
    , fromString : Elm.Expression
    , encode : Elm.Expression
    , decode : Elm.Expression
    }
values_ =
    { toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" [] ]
                        Type.string
                    )
            }
    , toLabel =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" [] ]
                        Type.string
                    )
            }
    , fromString =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "fromString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "DyeingMedium" [] ]
                        )
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "DyeingMedium" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Textile", "DyeingMedium" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "DyeingMedium" [] ]
                    )
            }
    }