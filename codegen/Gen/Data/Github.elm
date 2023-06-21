module Gen.Data.Github exposing (annotation_, decodeCommit, make_, moduleName_, values_)

{-| 
@docs moduleName_, decodeCommit, annotation_, make_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Github" ]


{-| decodeCommit: Decoder Commit -}
decodeCommit : Elm.Expression
decodeCommit =
    Elm.value
        { importFrom = [ "Data", "Github" ]
        , name = "decodeCommit"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Commit" [] ])
        }


annotation_ : { commit : Type.Annotation }
annotation_ =
    { commit =
        Type.alias
            moduleName_
            "Commit"
            []
            (Type.record
                [ ( "sha", Type.string )
                , ( "message", Type.string )
                , ( "date", Type.namedWith [] "Posix" [] )
                , ( "authorName", Type.string )
                , ( "authorLogin", Type.string )
                , ( "authorAvatar", Type.string )
                ]
            )
    }


make_ :
    { commit :
        { sha : Elm.Expression
        , message : Elm.Expression
        , date : Elm.Expression
        , authorName : Elm.Expression
        , authorLogin : Elm.Expression
        , authorAvatar : Elm.Expression
        }
        -> Elm.Expression
    }
make_ =
    { commit =
        \commit_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Github" ]
                    "Commit"
                    []
                    (Type.record
                        [ ( "sha", Type.string )
                        , ( "message", Type.string )
                        , ( "date", Type.namedWith [] "Posix" [] )
                        , ( "authorName", Type.string )
                        , ( "authorLogin", Type.string )
                        , ( "authorAvatar", Type.string )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "sha" commit_args.sha
                    , Tuple.pair "message" commit_args.message
                    , Tuple.pair "date" commit_args.date
                    , Tuple.pair "authorName" commit_args.authorName
                    , Tuple.pair "authorLogin" commit_args.authorLogin
                    , Tuple.pair "authorAvatar" commit_args.authorAvatar
                    ]
                )
    }


values_ : { decodeCommit : Elm.Expression }
values_ =
    { decodeCommit =
        Elm.value
            { importFrom = [ "Data", "Github" ]
            , name = "decodeCommit"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Commit" [] ]
                    )
            }
    }