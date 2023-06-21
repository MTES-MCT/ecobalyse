module Gen.Data.Gitbook exposing (annotation_, call_, caseOf_, handleMarkdownGitbookLink, make_, moduleName_, publicUrlFromPath, values_)

{-| 
@docs moduleName_, handleMarkdownGitbookLink, publicUrlFromPath, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Gitbook" ]


{-| handleMarkdownGitbookLink: Maybe Path -> String -> String -}
handleMarkdownGitbookLink : Elm.Expression -> String -> Elm.Expression
handleMarkdownGitbookLink handleMarkdownGitbookLinkArg handleMarkdownGitbookLinkArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "handleMarkdownGitbookLink"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Path" [] ]
                        , Type.string
                        ]
                        Type.string
                    )
            }
        )
        [ handleMarkdownGitbookLinkArg
        , Elm.string handleMarkdownGitbookLinkArg0
        ]


{-| publicUrlFromPath: Path -> String -}
publicUrlFromPath : Elm.Expression -> Elm.Expression
publicUrlFromPath publicUrlFromPathArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "publicUrlFromPath"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Path" [] ] Type.string)
            }
        )
        [ publicUrlFromPathArg ]


annotation_ : { page : Type.Annotation, path : Type.Annotation }
annotation_ =
    { page =
        Type.alias
            moduleName_
            "Page"
            []
            (Type.record
                [ ( "title", Type.string )
                , ( "description", Type.namedWith [] "Maybe" [ Type.string ] )
                , ( "markdown", Type.string )
                , ( "path", Type.namedWith [] "Path" [] )
                ]
            )
    , path = Type.namedWith [ "Data", "Gitbook" ] "Path" []
    }


make_ :
    { page :
        { title : Elm.Expression
        , description : Elm.Expression
        , markdown : Elm.Expression
        , path : Elm.Expression
        }
        -> Elm.Expression
    , foodBonuses : Elm.Expression
    , foodRawToCookedRatio : Elm.Expression
    , impactQuality : Elm.Expression
    , textileAerialTransport : Elm.Expression
    , textileDistribution : Elm.Expression
    , textileElectricity : Elm.Expression
    , textileEndOfLife : Elm.Expression
    , textileEnnobling : Elm.Expression
    , textileFabric : Elm.Expression
    , textileHeat : Elm.Expression
    , textileMaking : Elm.Expression
    , textileMakingComplexity : Elm.Expression
    , textileMaterialAndSpinning : Elm.Expression
    , textileTransport : Elm.Expression
    , textileUse : Elm.Expression
    }
make_ =
    { page =
        \page_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Gitbook" ]
                    "Page"
                    []
                    (Type.record
                        [ ( "title", Type.string )
                        , ( "description"
                          , Type.namedWith [] "Maybe" [ Type.string ]
                          )
                        , ( "markdown", Type.string )
                        , ( "path", Type.namedWith [] "Path" [] )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "title" page_args.title
                    , Tuple.pair "description" page_args.description
                    , Tuple.pair "markdown" page_args.markdown
                    , Tuple.pair "path" page_args.path
                    ]
                )
    , foodBonuses =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "FoodBonuses"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , foodRawToCookedRatio =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "FoodRawToCookedRatio"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , impactQuality =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "ImpactQuality"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileAerialTransport =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileAerialTransport"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileDistribution =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileDistribution"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileElectricity =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileElectricity"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileEndOfLife =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileEndOfLife"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileEnnobling =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileEnnobling"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileFabric =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileFabric"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileHeat =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileHeat"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileMaking =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileMaking"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileMakingComplexity =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileMakingComplexity"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileMaterialAndSpinning =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileMaterialAndSpinning"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileTransport =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileTransport"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    , textileUse =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "TextileUse"
            , annotation = Just (Type.namedWith [] "Path" [])
            }
    }


caseOf_ :
    { path :
        Elm.Expression
        -> { pathTags_0_0
            | foodBonuses : Elm.Expression
            , foodRawToCookedRatio : Elm.Expression
            , impactQuality : Elm.Expression
            , textileAerialTransport : Elm.Expression
            , textileDistribution : Elm.Expression
            , textileElectricity : Elm.Expression
            , textileEndOfLife : Elm.Expression
            , textileEnnobling : Elm.Expression
            , textileFabric : Elm.Expression
            , textileHeat : Elm.Expression
            , textileMaking : Elm.Expression
            , textileMakingComplexity : Elm.Expression
            , textileMaterialAndSpinning : Elm.Expression
            , textileTransport : Elm.Expression
            , textileUse : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { path =
        \pathExpression pathTags ->
            Elm.Case.custom
                pathExpression
                (Type.namedWith [ "Data", "Gitbook" ] "Path" [])
                [ Elm.Case.branch0 "FoodBonuses" pathTags.foodBonuses
                , Elm.Case.branch0
                    "FoodRawToCookedRatio"
                    pathTags.foodRawToCookedRatio
                , Elm.Case.branch0 "ImpactQuality" pathTags.impactQuality
                , Elm.Case.branch0
                    "TextileAerialTransport"
                    pathTags.textileAerialTransport
                , Elm.Case.branch0
                    "TextileDistribution"
                    pathTags.textileDistribution
                , Elm.Case.branch0
                    "TextileElectricity"
                    pathTags.textileElectricity
                , Elm.Case.branch0 "TextileEndOfLife" pathTags.textileEndOfLife
                , Elm.Case.branch0 "TextileEnnobling" pathTags.textileEnnobling
                , Elm.Case.branch0 "TextileFabric" pathTags.textileFabric
                , Elm.Case.branch0 "TextileHeat" pathTags.textileHeat
                , Elm.Case.branch0 "TextileMaking" pathTags.textileMaking
                , Elm.Case.branch0
                    "TextileMakingComplexity"
                    pathTags.textileMakingComplexity
                , Elm.Case.branch0
                    "TextileMaterialAndSpinning"
                    pathTags.textileMaterialAndSpinning
                , Elm.Case.branch0 "TextileTransport" pathTags.textileTransport
                , Elm.Case.branch0 "TextileUse" pathTags.textileUse
                ]
    }


call_ :
    { handleMarkdownGitbookLink :
        Elm.Expression -> Elm.Expression -> Elm.Expression
    , publicUrlFromPath : Elm.Expression -> Elm.Expression
    }
call_ =
    { handleMarkdownGitbookLink =
        \handleMarkdownGitbookLinkArg handleMarkdownGitbookLinkArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Gitbook" ]
                    , name = "handleMarkdownGitbookLink"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "Path" [] ]
                                , Type.string
                                ]
                                Type.string
                            )
                    }
                )
                [ handleMarkdownGitbookLinkArg, handleMarkdownGitbookLinkArg0 ]
    , publicUrlFromPath =
        \publicUrlFromPathArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Gitbook" ]
                    , name = "publicUrlFromPath"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Path" [] ]
                                Type.string
                            )
                    }
                )
                [ publicUrlFromPathArg ]
    }


values_ :
    { handleMarkdownGitbookLink : Elm.Expression
    , publicUrlFromPath : Elm.Expression
    }
values_ =
    { handleMarkdownGitbookLink =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "handleMarkdownGitbookLink"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            []
                            "Maybe"
                            [ Type.namedWith [] "Path" [] ]
                        , Type.string
                        ]
                        Type.string
                    )
            }
    , publicUrlFromPath =
        Elm.value
            { importFrom = [ "Data", "Gitbook" ]
            , name = "publicUrlFromPath"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Path" [] ] Type.string)
            }
    }