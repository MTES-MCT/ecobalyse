module Gen.Data.Food.Origin exposing (annotation_, call_, caseOf_, decode, make_, moduleName_, toLabel, values_)

{-| 
@docs moduleName_, toLabel, decode, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Food", "Origin" ]


{-| toLabel: Origin -> String -}
toLabel : Elm.Expression -> Elm.Expression
toLabel toLabelArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Origin" [] ] Type.string
                    )
            }
        )
        [ toLabelArg ]


{-| decode: Decoder Origin -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Food", "Origin" ]
        , name = "decode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Origin" [] ])
        }


annotation_ : { origin : Type.Annotation }
annotation_ =
    { origin = Type.namedWith [ "Data", "Food", "Origin" ] "Origin" [] }


make_ :
    { france : Elm.Expression
    , europeAndMaghreb : Elm.Expression
    , outOfEuropeAndMaghreb : Elm.Expression
    , outOfEuropeAndMaghrebByPlane : Elm.Expression
    }
make_ =
    { france =
        Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "France"
            , annotation = Just (Type.namedWith [] "Origin" [])
            }
    , europeAndMaghreb =
        Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "EuropeAndMaghreb"
            , annotation = Just (Type.namedWith [] "Origin" [])
            }
    , outOfEuropeAndMaghreb =
        Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "OutOfEuropeAndMaghreb"
            , annotation = Just (Type.namedWith [] "Origin" [])
            }
    , outOfEuropeAndMaghrebByPlane =
        Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "OutOfEuropeAndMaghrebByPlane"
            , annotation = Just (Type.namedWith [] "Origin" [])
            }
    }


caseOf_ :
    { origin :
        Elm.Expression
        -> { originTags_0_0
            | france : Elm.Expression
            , europeAndMaghreb : Elm.Expression
            , outOfEuropeAndMaghreb : Elm.Expression
            , outOfEuropeAndMaghrebByPlane : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { origin =
        \originExpression originTags ->
            Elm.Case.custom
                originExpression
                (Type.namedWith [ "Data", "Food", "Origin" ] "Origin" [])
                [ Elm.Case.branch0 "France" originTags.france
                , Elm.Case.branch0
                    "EuropeAndMaghreb"
                    originTags.europeAndMaghreb
                , Elm.Case.branch0
                    "OutOfEuropeAndMaghreb"
                    originTags.outOfEuropeAndMaghreb
                , Elm.Case.branch0
                    "OutOfEuropeAndMaghrebByPlane"
                    originTags.outOfEuropeAndMaghrebByPlane
                ]
    }


call_ : { toLabel : Elm.Expression -> Elm.Expression }
call_ =
    { toLabel =
        \toLabelArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Food", "Origin" ]
                    , name = "toLabel"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Origin" [] ]
                                Type.string
                            )
                    }
                )
                [ toLabelArg ]
    }


values_ : { toLabel : Elm.Expression, decode : Elm.Expression }
values_ =
    { toLabel =
        Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "toLabel"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Origin" [] ] Type.string
                    )
            }
    , decode =
        Elm.value
            { importFrom = [ "Data", "Food", "Origin" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith
                        []
                        "Decoder"
                        [ Type.namedWith [] "Origin" [] ]
                    )
            }
    }