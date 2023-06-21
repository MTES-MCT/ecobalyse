module Gen.Data.Impact.Definition exposing (annotation_, call_, caseOf_, definitions, forScope, get, isAggregate, make_, moduleName_, toString, toTrigram, trigrams, values_)

{-| 
@docs moduleName_, definitions, isAggregate, forScope, toTrigram, toString, get, trigrams, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Impact", "Definition" ]


{-| definitions: 
    { acd :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , bvi :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , cch :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , ecs :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , etf :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , etfc :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , fru :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , fwe :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , htc :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , htcc :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , htn :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , htnc :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , ior :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , ldu :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , mru :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , ozd :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , pco :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , pef :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , pma :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , swe :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , tre :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    , wtu :
        { trigramString : String
        , trigram : Trigram
        , source : Source
        , label : String
        , description : String
        , unit : String
        , decimals : Int
        , quality : Quality
        , pefData : Maybe AggregatedScoreData
        , ecoscoreData : Maybe AggregatedScoreData
        , scopes : List Data.Scope.Scope
        }
    }
-}
definitions : Elm.Expression
definitions =
    Elm.value
        { importFrom = [ "Data", "Impact", "Definition" ]
        , name = "definitions"
        , annotation =
            Just
                (Type.record
                    [ ( "acd"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "bvi"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "cch"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "ecs"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "etf"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "etfc"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "fru"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "fwe"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "htc"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "htcc"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "htn"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "htnc"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "ior"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "ldu"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "mru"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "ozd"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "pco"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "pef"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "pma"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "swe"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "tre"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    , ( "wtu"
                      , Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                      )
                    ]
                )
        }


{-| isAggregate: Trigram -> Bool -}
isAggregate : Elm.Expression -> Elm.Expression
isAggregate isAggregateArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "isAggregate"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Trigram" [] ] Type.bool)
            }
        )
        [ isAggregateArg ]


{-| forScope: 
    Data.Scope.Scope
    -> List { trigramString : String
    , trigram : Trigram
    , source : Source
    , label : String
    , description : String
    , unit : String
    , decimals : Int
    , quality : Quality
    , pefData : Maybe AggregatedScoreData
    , ecoscoreData : Maybe AggregatedScoreData
    , scopes : List Data.Scope.Scope
    }
-}
forScope : Elm.Expression -> Elm.Expression
forScope forScopeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "forScope"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Data", "Scope" ] "Scope" [] ]
                        (Type.list
                            (Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                            )
                        )
                    )
            }
        )
        [ forScopeArg ]


{-| toTrigram: String -> Result String Trigram -}
toTrigram : String -> Elm.Expression
toTrigram toTrigramArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "toTrigram"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Trigram" [] ]
                        )
                    )
            }
        )
        [ Elm.string toTrigramArg ]


{-| toString: Trigram -> String -}
toString : Elm.Expression -> Elm.Expression
toString toStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" [] ]
                        Type.string
                    )
            }
        )
        [ toStringArg ]


{-| get: 
    Trigram
    -> { trigramString : String
    , trigram : Trigram
    , source : Source
    , label : String
    , description : String
    , unit : String
    , decimals : Int
    , quality : Quality
    , pefData : Maybe AggregatedScoreData
    , ecoscoreData : Maybe AggregatedScoreData
    , scopes : List Data.Scope.Scope
    }
-}
get : Elm.Expression -> Elm.Expression
get getArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "get"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" [] ]
                        (Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                        )
                    )
            }
        )
        [ getArg ]


{-| trigrams: List Trigram -}
trigrams : Elm.Expression
trigrams =
    Elm.value
        { importFrom = [ "Data", "Impact", "Definition" ]
        , name = "trigrams"
        , annotation = Just (Type.list (Type.namedWith [] "Trigram" []))
        }


annotation_ :
    { definitions : Type.Annotation
    , definition : Type.Annotation
    , aggregatedScoreData : Type.Annotation
    , source : Type.Annotation
    , trigram : Type.Annotation
    , quality : Type.Annotation
    }
annotation_ =
    { definitions =
        Type.alias
            moduleName_
            "Definitions"
            []
            (Type.record
                [ ( "acd"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "bvi"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "cch"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "ecs"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "etf"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "etfc"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "fru"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "fwe"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "htc"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "htcc"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "htn"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "htnc"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "ior"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "ldu"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "mru"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "ozd"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "pco"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "pef"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "pma"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "swe"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "tre"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                , ( "wtu"
                  , Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                  )
                ]
            )
    , definition =
        Type.alias
            moduleName_
            "Definition"
            []
            (Type.record
                [ ( "trigramString", Type.string )
                , ( "trigram", Type.namedWith [] "Trigram" [] )
                , ( "source", Type.namedWith [] "Source" [] )
                , ( "label", Type.string )
                , ( "description", Type.string )
                , ( "unit", Type.string )
                , ( "decimals", Type.int )
                , ( "quality", Type.namedWith [] "Quality" [] )
                , ( "pefData"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "AggregatedScoreData" [] ]
                  )
                , ( "ecoscoreData"
                  , Type.namedWith
                        []
                        "Maybe"
                        [ Type.namedWith [] "AggregatedScoreData" [] ]
                  )
                , ( "scopes"
                  , Type.list (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                  )
                ]
            )
    , aggregatedScoreData =
        Type.alias
            moduleName_
            "AggregatedScoreData"
            []
            (Type.record
                [ ( "color", Type.string )
                , ( "normalization"
                  , Type.namedWith [ "Data", "Unit" ] "Impact" []
                  )
                , ( "weighting", Type.namedWith [ "Data", "Unit" ] "Ratio" [] )
                ]
            )
    , source =
        Type.alias
            moduleName_
            "Source"
            []
            (Type.record [ ( "label", Type.string ), ( "url", Type.string ) ])
    , trigram = Type.namedWith [ "Data", "Impact", "Definition" ] "Trigram" []
    , quality = Type.namedWith [ "Data", "Impact", "Definition" ] "Quality" []
    }


make_ :
    { definitions :
        { acd : Elm.Expression
        , bvi : Elm.Expression
        , cch : Elm.Expression
        , ecs : Elm.Expression
        , etf : Elm.Expression
        , etfc : Elm.Expression
        , fru : Elm.Expression
        , fwe : Elm.Expression
        , htc : Elm.Expression
        , htcc : Elm.Expression
        , htn : Elm.Expression
        , htnc : Elm.Expression
        , ior : Elm.Expression
        , ldu : Elm.Expression
        , mru : Elm.Expression
        , ozd : Elm.Expression
        , pco : Elm.Expression
        , pef : Elm.Expression
        , pma : Elm.Expression
        , swe : Elm.Expression
        , tre : Elm.Expression
        , wtu : Elm.Expression
        }
        -> Elm.Expression
    , definition :
        { trigramString : Elm.Expression
        , trigram : Elm.Expression
        , source : Elm.Expression
        , label : Elm.Expression
        , description : Elm.Expression
        , unit : Elm.Expression
        , decimals : Elm.Expression
        , quality : Elm.Expression
        , pefData : Elm.Expression
        , ecoscoreData : Elm.Expression
        , scopes : Elm.Expression
        }
        -> Elm.Expression
    , aggregatedScoreData :
        { color : Elm.Expression
        , normalization : Elm.Expression
        , weighting : Elm.Expression
        }
        -> Elm.Expression
    , source :
        { label : Elm.Expression, url : Elm.Expression } -> Elm.Expression
    , acd : Elm.Expression
    , bvi : Elm.Expression
    , cch : Elm.Expression
    , ecs : Elm.Expression
    , etf : Elm.Expression
    , etfC : Elm.Expression
    , fru : Elm.Expression
    , fwe : Elm.Expression
    , htc : Elm.Expression
    , htcC : Elm.Expression
    , htn : Elm.Expression
    , htnC : Elm.Expression
    , ior : Elm.Expression
    , ldu : Elm.Expression
    , mru : Elm.Expression
    , ozd : Elm.Expression
    , pco : Elm.Expression
    , pef : Elm.Expression
    , pma : Elm.Expression
    , swe : Elm.Expression
    , tre : Elm.Expression
    , wtu : Elm.Expression
    , averageQuality : Elm.Expression
    , badQuality : Elm.Expression
    , goodQuality : Elm.Expression
    , notFinished : Elm.Expression
    , unknownQuality : Elm.Expression
    }
make_ =
    { definitions =
        \definitions_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Impact", "Definition" ]
                    "Definitions"
                    []
                    (Type.record
                        [ ( "acd"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "bvi"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "cch"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ecs"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "etf"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "etfc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "fru"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "fwe"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htcc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htn"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htnc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ior"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ldu"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "mru"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ozd"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "pco"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "pef"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "pma"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "swe"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "tre"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "wtu"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "acd" definitions_args.acd
                    , Tuple.pair "bvi" definitions_args.bvi
                    , Tuple.pair "cch" definitions_args.cch
                    , Tuple.pair "ecs" definitions_args.ecs
                    , Tuple.pair "etf" definitions_args.etf
                    , Tuple.pair "etfc" definitions_args.etfc
                    , Tuple.pair "fru" definitions_args.fru
                    , Tuple.pair "fwe" definitions_args.fwe
                    , Tuple.pair "htc" definitions_args.htc
                    , Tuple.pair "htcc" definitions_args.htcc
                    , Tuple.pair "htn" definitions_args.htn
                    , Tuple.pair "htnc" definitions_args.htnc
                    , Tuple.pair "ior" definitions_args.ior
                    , Tuple.pair "ldu" definitions_args.ldu
                    , Tuple.pair "mru" definitions_args.mru
                    , Tuple.pair "ozd" definitions_args.ozd
                    , Tuple.pair "pco" definitions_args.pco
                    , Tuple.pair "pef" definitions_args.pef
                    , Tuple.pair "pma" definitions_args.pma
                    , Tuple.pair "swe" definitions_args.swe
                    , Tuple.pair "tre" definitions_args.tre
                    , Tuple.pair "wtu" definitions_args.wtu
                    ]
                )
    , definition =
        \definition_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Impact", "Definition" ]
                    "Definition"
                    []
                    (Type.record
                        [ ( "trigramString", Type.string )
                        , ( "trigram", Type.namedWith [] "Trigram" [] )
                        , ( "source", Type.namedWith [] "Source" [] )
                        , ( "label", Type.string )
                        , ( "description", Type.string )
                        , ( "unit", Type.string )
                        , ( "decimals", Type.int )
                        , ( "quality", Type.namedWith [] "Quality" [] )
                        , ( "pefData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "ecoscoreData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "AggregatedScoreData" [] ]
                          )
                        , ( "scopes"
                          , Type.list
                                (Type.namedWith [ "Data", "Scope" ] "Scope" [])
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "trigramString" definition_args.trigramString
                    , Tuple.pair "trigram" definition_args.trigram
                    , Tuple.pair "source" definition_args.source
                    , Tuple.pair "label" definition_args.label
                    , Tuple.pair "description" definition_args.description
                    , Tuple.pair "unit" definition_args.unit
                    , Tuple.pair "decimals" definition_args.decimals
                    , Tuple.pair "quality" definition_args.quality
                    , Tuple.pair "pefData" definition_args.pefData
                    , Tuple.pair "ecoscoreData" definition_args.ecoscoreData
                    , Tuple.pair "scopes" definition_args.scopes
                    ]
                )
    , aggregatedScoreData =
        \aggregatedScoreData_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Impact", "Definition" ]
                    "AggregatedScoreData"
                    []
                    (Type.record
                        [ ( "color", Type.string )
                        , ( "normalization"
                          , Type.namedWith [ "Data", "Unit" ] "Impact" []
                          )
                        , ( "weighting"
                          , Type.namedWith [ "Data", "Unit" ] "Ratio" []
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "color" aggregatedScoreData_args.color
                    , Tuple.pair
                        "normalization"
                        aggregatedScoreData_args.normalization
                    , Tuple.pair "weighting" aggregatedScoreData_args.weighting
                    ]
                )
    , source =
        \source_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Impact", "Definition" ]
                    "Source"
                    []
                    (Type.record
                        [ ( "label", Type.string ), ( "url", Type.string ) ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "label" source_args.label
                    , Tuple.pair "url" source_args.url
                    ]
                )
    , acd =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Acd"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , bvi =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Bvi"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , cch =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Cch"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , ecs =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Ecs"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , etf =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Etf"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , etfC =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "EtfC"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , fru =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Fru"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , fwe =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Fwe"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , htc =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Htc"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , htcC =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "HtcC"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , htn =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Htn"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , htnC =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "HtnC"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , ior =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Ior"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , ldu =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Ldu"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , mru =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Mru"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , ozd =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Ozd"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , pco =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Pco"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , pef =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Pef"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , pma =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Pma"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , swe =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Swe"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , tre =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Tre"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , wtu =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "Wtu"
            , annotation = Just (Type.namedWith [] "Trigram" [])
            }
    , averageQuality =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "AverageQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , badQuality =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "BadQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , goodQuality =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "GoodQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , notFinished =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "NotFinished"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    , unknownQuality =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "UnknownQuality"
            , annotation = Just (Type.namedWith [] "Quality" [])
            }
    }


caseOf_ :
    { trigram :
        Elm.Expression
        -> { trigramTags_0_0
            | acd : Elm.Expression
            , bvi : Elm.Expression
            , cch : Elm.Expression
            , ecs : Elm.Expression
            , etf : Elm.Expression
            , etfC : Elm.Expression
            , fru : Elm.Expression
            , fwe : Elm.Expression
            , htc : Elm.Expression
            , htcC : Elm.Expression
            , htn : Elm.Expression
            , htnC : Elm.Expression
            , ior : Elm.Expression
            , ldu : Elm.Expression
            , mru : Elm.Expression
            , ozd : Elm.Expression
            , pco : Elm.Expression
            , pef : Elm.Expression
            , pma : Elm.Expression
            , swe : Elm.Expression
            , tre : Elm.Expression
            , wtu : Elm.Expression
        }
        -> Elm.Expression
    , quality :
        Elm.Expression
        -> { qualityTags_1_0
            | averageQuality : Elm.Expression
            , badQuality : Elm.Expression
            , goodQuality : Elm.Expression
            , notFinished : Elm.Expression
            , unknownQuality : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { trigram =
        \trigramExpression trigramTags ->
            Elm.Case.custom
                trigramExpression
                (Type.namedWith [ "Data", "Impact", "Definition" ] "Trigram" [])
                [ Elm.Case.branch0 "Acd" trigramTags.acd
                , Elm.Case.branch0 "Bvi" trigramTags.bvi
                , Elm.Case.branch0 "Cch" trigramTags.cch
                , Elm.Case.branch0 "Ecs" trigramTags.ecs
                , Elm.Case.branch0 "Etf" trigramTags.etf
                , Elm.Case.branch0 "EtfC" trigramTags.etfC
                , Elm.Case.branch0 "Fru" trigramTags.fru
                , Elm.Case.branch0 "Fwe" trigramTags.fwe
                , Elm.Case.branch0 "Htc" trigramTags.htc
                , Elm.Case.branch0 "HtcC" trigramTags.htcC
                , Elm.Case.branch0 "Htn" trigramTags.htn
                , Elm.Case.branch0 "HtnC" trigramTags.htnC
                , Elm.Case.branch0 "Ior" trigramTags.ior
                , Elm.Case.branch0 "Ldu" trigramTags.ldu
                , Elm.Case.branch0 "Mru" trigramTags.mru
                , Elm.Case.branch0 "Ozd" trigramTags.ozd
                , Elm.Case.branch0 "Pco" trigramTags.pco
                , Elm.Case.branch0 "Pef" trigramTags.pef
                , Elm.Case.branch0 "Pma" trigramTags.pma
                , Elm.Case.branch0 "Swe" trigramTags.swe
                , Elm.Case.branch0 "Tre" trigramTags.tre
                , Elm.Case.branch0 "Wtu" trigramTags.wtu
                ]
    , quality =
        \qualityExpression qualityTags ->
            Elm.Case.custom
                qualityExpression
                (Type.namedWith [ "Data", "Impact", "Definition" ] "Quality" [])
                [ Elm.Case.branch0 "AverageQuality" qualityTags.averageQuality
                , Elm.Case.branch0 "BadQuality" qualityTags.badQuality
                , Elm.Case.branch0 "GoodQuality" qualityTags.goodQuality
                , Elm.Case.branch0 "NotFinished" qualityTags.notFinished
                , Elm.Case.branch0 "UnknownQuality" qualityTags.unknownQuality
                ]
    }


call_ :
    { isAggregate : Elm.Expression -> Elm.Expression
    , forScope : Elm.Expression -> Elm.Expression
    , toTrigram : Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    , get : Elm.Expression -> Elm.Expression
    }
call_ =
    { isAggregate =
        \isAggregateArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact", "Definition" ]
                    , name = "isAggregate"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Trigram" [] ]
                                Type.bool
                            )
                    }
                )
                [ isAggregateArg ]
    , forScope =
        \forScopeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact", "Definition" ]
                    , name = "forScope"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Data", "Scope" ] "Scope" []
                                ]
                                (Type.list
                                    (Type.record
                                        [ ( "trigramString", Type.string )
                                        , ( "trigram"
                                          , Type.namedWith [] "Trigram" []
                                          )
                                        , ( "source"
                                          , Type.namedWith [] "Source" []
                                          )
                                        , ( "label", Type.string )
                                        , ( "description", Type.string )
                                        , ( "unit", Type.string )
                                        , ( "decimals", Type.int )
                                        , ( "quality"
                                          , Type.namedWith [] "Quality" []
                                          )
                                        , ( "pefData"
                                          , Type.namedWith
                                                []
                                                "Maybe"
                                                [ Type.namedWith
                                                    []
                                                    "AggregatedScoreData"
                                                    []
                                                ]
                                          )
                                        , ( "ecoscoreData"
                                          , Type.namedWith
                                                []
                                                "Maybe"
                                                [ Type.namedWith
                                                    []
                                                    "AggregatedScoreData"
                                                    []
                                                ]
                                          )
                                        , ( "scopes"
                                          , Type.list
                                                (Type.namedWith
                                                    [ "Data", "Scope" ]
                                                    "Scope"
                                                    []
                                                )
                                          )
                                        ]
                                    )
                                )
                            )
                    }
                )
                [ forScopeArg ]
    , toTrigram =
        \toTrigramArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact", "Definition" ]
                    , name = "toTrigram"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Trigram" []
                                    ]
                                )
                            )
                    }
                )
                [ toTrigramArg ]
    , toString =
        \toStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact", "Definition" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Trigram" [] ]
                                Type.string
                            )
                    }
                )
                [ toStringArg ]
    , get =
        \getArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Impact", "Definition" ]
                    , name = "get"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Trigram" [] ]
                                (Type.record
                                    [ ( "trigramString", Type.string )
                                    , ( "trigram"
                                      , Type.namedWith [] "Trigram" []
                                      )
                                    , ( "source"
                                      , Type.namedWith [] "Source" []
                                      )
                                    , ( "label", Type.string )
                                    , ( "description", Type.string )
                                    , ( "unit", Type.string )
                                    , ( "decimals", Type.int )
                                    , ( "quality"
                                      , Type.namedWith [] "Quality" []
                                      )
                                    , ( "pefData"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith
                                                []
                                                "AggregatedScoreData"
                                                []
                                            ]
                                      )
                                    , ( "ecoscoreData"
                                      , Type.namedWith
                                            []
                                            "Maybe"
                                            [ Type.namedWith
                                                []
                                                "AggregatedScoreData"
                                                []
                                            ]
                                      )
                                    , ( "scopes"
                                      , Type.list
                                            (Type.namedWith
                                                [ "Data", "Scope" ]
                                                "Scope"
                                                []
                                            )
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ getArg ]
    }


values_ :
    { definitions : Elm.Expression
    , isAggregate : Elm.Expression
    , forScope : Elm.Expression
    , toTrigram : Elm.Expression
    , toString : Elm.Expression
    , get : Elm.Expression
    , trigrams : Elm.Expression
    }
values_ =
    { definitions =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "definitions"
            , annotation =
                Just
                    (Type.record
                        [ ( "acd"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "bvi"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "cch"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ecs"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "etf"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "etfc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "fru"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "fwe"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htcc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htn"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "htnc"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ior"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ldu"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "mru"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "ozd"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "pco"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "pef"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "pma"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "swe"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "tre"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        , ( "wtu"
                          , Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                          )
                        ]
                    )
            }
    , isAggregate =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "isAggregate"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Trigram" [] ] Type.bool)
            }
    , forScope =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "forScope"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Data", "Scope" ] "Scope" [] ]
                        (Type.list
                            (Type.record
                                [ ( "trigramString", Type.string )
                                , ( "trigram", Type.namedWith [] "Trigram" [] )
                                , ( "source", Type.namedWith [] "Source" [] )
                                , ( "label", Type.string )
                                , ( "description", Type.string )
                                , ( "unit", Type.string )
                                , ( "decimals", Type.int )
                                , ( "quality", Type.namedWith [] "Quality" [] )
                                , ( "pefData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "ecoscoreData"
                                  , Type.namedWith
                                        []
                                        "Maybe"
                                        [ Type.namedWith
                                            []
                                            "AggregatedScoreData"
                                            []
                                        ]
                                  )
                                , ( "scopes"
                                  , Type.list
                                        (Type.namedWith
                                            [ "Data", "Scope" ]
                                            "Scope"
                                            []
                                        )
                                  )
                                ]
                            )
                        )
                    )
            }
    , toTrigram =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "toTrigram"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Trigram" [] ]
                        )
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" [] ]
                        Type.string
                    )
            }
    , get =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "get"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Trigram" [] ]
                        (Type.record
                            [ ( "trigramString", Type.string )
                            , ( "trigram", Type.namedWith [] "Trigram" [] )
                            , ( "source", Type.namedWith [] "Source" [] )
                            , ( "label", Type.string )
                            , ( "description", Type.string )
                            , ( "unit", Type.string )
                            , ( "decimals", Type.int )
                            , ( "quality", Type.namedWith [] "Quality" [] )
                            , ( "pefData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "ecoscoreData"
                              , Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.namedWith [] "AggregatedScoreData" []
                                    ]
                              )
                            , ( "scopes"
                              , Type.list
                                    (Type.namedWith
                                        [ "Data", "Scope" ]
                                        "Scope"
                                        []
                                    )
                              )
                            ]
                        )
                    )
            }
    , trigrams =
        Elm.value
            { importFrom = [ "Data", "Impact", "Definition" ]
            , name = "trigrams"
            , annotation = Just (Type.list (Type.namedWith [] "Trigram" []))
            }
    }