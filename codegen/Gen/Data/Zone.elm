module Gen.Data.Zone exposing (annotation_, caseOf_, decode, make_, moduleName_, values_)

{-| 
@docs moduleName_, decode, annotation_, make_, caseOf_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Zone" ]


{-| decode: Decoder Zone -}
decode : Elm.Expression
decode =
    Elm.value
        { importFrom = [ "Data", "Zone" ]
        , name = "decode"
        , annotation =
            Just (Type.namedWith [] "Decoder" [ Type.namedWith [] "Zone" [] ])
        }


annotation_ : { zone : Type.Annotation }
annotation_ =
    { zone = Type.namedWith [ "Data", "Zone" ] "Zone" [] }


make_ :
    { africa : Elm.Expression
    , asia : Elm.Expression
    , europe : Elm.Expression
    , middleEast : Elm.Expression
    , northAmerica : Elm.Expression
    , oceania : Elm.Expression
    , southAmerica : Elm.Expression
    }
make_ =
    { africa =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "Africa"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    , asia =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "Asia"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    , europe =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "Europe"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    , middleEast =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "MiddleEast"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    , northAmerica =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "NorthAmerica"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    , oceania =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "Oceania"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    , southAmerica =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "SouthAmerica"
            , annotation = Just (Type.namedWith [] "Zone" [])
            }
    }


caseOf_ :
    { zone :
        Elm.Expression
        -> { zoneTags_0_0
            | africa : Elm.Expression
            , asia : Elm.Expression
            , europe : Elm.Expression
            , middleEast : Elm.Expression
            , northAmerica : Elm.Expression
            , oceania : Elm.Expression
            , southAmerica : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { zone =
        \zoneExpression zoneTags ->
            Elm.Case.custom
                zoneExpression
                (Type.namedWith [ "Data", "Zone" ] "Zone" [])
                [ Elm.Case.branch0 "Africa" zoneTags.africa
                , Elm.Case.branch0 "Asia" zoneTags.asia
                , Elm.Case.branch0 "Europe" zoneTags.europe
                , Elm.Case.branch0 "MiddleEast" zoneTags.middleEast
                , Elm.Case.branch0 "NorthAmerica" zoneTags.northAmerica
                , Elm.Case.branch0 "Oceania" zoneTags.oceania
                , Elm.Case.branch0 "SouthAmerica" zoneTags.southAmerica
                ]
    }


values_ : { decode : Elm.Expression }
values_ =
    { decode =
        Elm.value
            { importFrom = [ "Data", "Zone" ]
            , name = "decode"
            , annotation =
                Just
                    (Type.namedWith [] "Decoder" [ Type.namedWith [] "Zone" [] ]
                    )
            }
    }