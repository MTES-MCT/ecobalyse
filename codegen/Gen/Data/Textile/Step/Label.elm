module Gen.Data.Textile.Step.Label exposing (all, annotation_, call_, caseOf_, decodeFromCode, encode, fromCodeString, make_, moduleName_, toGitbookPath, toString, values_)

{-| 
@docs moduleName_, encode, decodeFromCode, toGitbookPath, fromCodeString, toString, all, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Step", "Label" ]


{-| encode: Label -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decodeFromCode: Decoder Label -}
decodeFromCode : Elm.Expression
decodeFromCode =
    Elm.value
        { importFrom = [ "Data", "Textile", "Step", "Label" ]
        , name = "decodeFromCode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Label" [] ])
        }


{-| toGitbookPath: Label -> Gitbook.Path -}
toGitbookPath : Elm.Expression -> Elm.Expression
toGitbookPath toGitbookPathArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "toGitbookPath"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" [] ]
                        (Type.namedWith [ "Gitbook" ] "Path" [])
                    )
            }
        )
        [ toGitbookPathArg ]


{-| fromCodeString: String -> Result String Label -}
fromCodeString : String -> Elm.Expression
fromCodeString fromCodeStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "fromCodeString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Label" [] ]
                        )
                    )
            }
        )
        [ Elm.string fromCodeStringArg ]


{-| toString: Label -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Label" [] ] Type.string)
            }
        )
        [ toStringArg ]


{-| all: List Label -}
all : Elm.Expression
all =
    Elm.value
        { importFrom = [ "Data", "Textile", "Step", "Label" ]
        , name = "all"
        , annotation = Just (Type.list (Type.namedWith [] "Label" []))
        }


annotation_ : { label : Type.Annotation }
annotation_ =
    { label = Type.namedWith [ "Data", "Textile", "Step", "Label" ] "Label" [] }


make_ :
    { material : Elm.Expression
    , spinning : Elm.Expression
    , fabric : Elm.Expression
    , ennobling : Elm.Expression
    , making : Elm.Expression
    , distribution : Elm.Expression
    , use : Elm.Expression
    , endOfLife : Elm.Expression
    }
make_ =
    { material =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Material"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , spinning =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Spinning"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , fabric =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Fabric"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , ennobling =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Ennobling"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , making =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Making"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , distribution =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Distribution"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , use =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "Use"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    , endOfLife =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "EndOfLife"
            , annotation = Just (Type.namedWith [] "Label" [])
            }
    }


caseOf_ :
    { label :
        Elm.Expression
        -> { labelTags_0_0
            | material : Elm.Expression
            , spinning : Elm.Expression
            , fabric : Elm.Expression
            , ennobling : Elm.Expression
            , making : Elm.Expression
            , distribution : Elm.Expression
            , use : Elm.Expression
            , endOfLife : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { label =
        \labelExpression labelTags ->
            Elm.Case.custom
                labelExpression
                (Type.namedWith
                    [ "Data", "Textile", "Step", "Label" ]
                    "Label"
                    []
                )
                [ Elm.Case.branch0 "Material" labelTags.material
                , Elm.Case.branch0 "Spinning" labelTags.spinning
                , Elm.Case.branch0 "Fabric" labelTags.fabric
                , Elm.Case.branch0 "Ennobling" labelTags.ennobling
                , Elm.Case.branch0 "Making" labelTags.making
                , Elm.Case.branch0 "Distribution" labelTags.distribution
                , Elm.Case.branch0 "Use" labelTags.use
                , Elm.Case.branch0 "EndOfLife" labelTags.endOfLife
                ]
    }


call_ :
    { encode : Elm.Expression -> Elm.Expression
    , toGitbookPath : Elm.Expression -> Elm.Expression
    , fromCodeString : Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    }
call_ =
    { encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step", "Label" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , toGitbookPath =
        \toGitbookPathArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step", "Label" ]
                    , name = "toGitbookPath"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" [] ]
                                (Type.namedWith [ "Gitbook" ] "Path" [])
                            )
                    }
                )
                [ toGitbookPathArg ]
    , fromCodeString =
        \fromCodeStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step", "Label" ]
                    , name = "fromCodeString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Label" []
                                    ]
                                )
                            )
                    }
                )
                [ fromCodeStringArg ]
    , toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Step", "Label" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Label" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    }


values_ :
    { encode : Elm.Expression
    , decodeFromCode : Elm.Expression
    , toGitbookPath : Elm.Expression
    , fromCodeString : Elm.Expression
    , toString : Elm.Expression
    , all : Elm.Expression
    }
values_ =
    { encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeFromCode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "decodeFromCode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Label" [] ]
                    )
            }
    , toGitbookPath =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "toGitbookPath"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Label" [] ]
                        (Type.namedWith [ "Gitbook" ] "Path" [])
                    )
            }
    , fromCodeString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "fromCodeString"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Label" [] ]
                        )
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Label" [] ] Type.string)
            }
    , all =
        Elm.value
            { importFrom = [ "Data", "Textile", "Step", "Label" ]
            , name = "all"
            , annotation = Just (Type.list (Type.namedWith [] "Label" []))
            }
    }