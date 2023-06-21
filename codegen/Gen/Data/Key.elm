module Gen.Data.Key exposing (call_, escape, moduleName_, values_)

{-| 
@docs moduleName_, escape, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Key" ]


{-| escape: msg -> Decoder msg -}
escape : Elm.Expression -> Elm.Expression
escape escapeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Key" ]
            , name = "escape"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "msg" ]
                        (Type.namedWith [] "Decoder" [ Type.var "msg" ])
                    )
            }
        )
        [ escapeArg ]


call_ : { escape : Elm.Expression -> Elm.Expression }
call_ =
    { escape =
        \escapeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Key" ]
                    , name = "escape"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "msg" ]
                                (Type.namedWith [] "Decoder" [ Type.var "msg" ])
                            )
                    }
                )
                [ escapeArg ]
    }


values_ : { escape : Elm.Expression }
values_ =
    { escape =
        Elm.value
            { importFrom = [ "Data", "Key" ]
            , name = "escape"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "msg" ]
                        (Type.namedWith [] "Decoder" [ Type.var "msg" ])
                    )
            }
    }