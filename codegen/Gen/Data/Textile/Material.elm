module Gen.Data.Textile.Material exposing (annotation_, call_, caseOf_, decodeList, encode, encodeId, findById, getRecyclingData, groupAll, idToString, make_, moduleName_, values_)

{-| 
@docs moduleName_, idToString, encodeId, encode, decodeList, groupAll, findById, getRecyclingData, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Textile", "Material" ]


{-| idToString: Id -> String -}
idToString : Elm.Expression -> Elm.Expression
idToString idToStringArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
        )
        [ idToStringArg ]


{-| encodeId: Id -> Encode.Value -}
encodeId : Elm.Expression -> Elm.Expression
encodeId encodeIdArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeIdArg ]


{-| encode: Material -> Encode.Value -}
encode : Elm.Expression -> Elm.Expression
encode encodeArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Material" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
        )
        [ encodeArg ]


{-| decodeList: List Process -> Decoder (List Material) -}
decodeList : List Elm.Expression -> Elm.Expression
decodeList decodeListArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Material" []) ]
                        )
                    )
            }
        )
        [ Elm.list decodeListArg ]


{-| groupAll: List Material -> ( List Material, List Material, List Material ) -}
groupAll : List Elm.Expression -> Elm.Expression
groupAll groupAllArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "groupAll"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Material" []) ]
                        (Type.triple
                            (Type.list (Type.namedWith [] "Material" []))
                            (Type.list (Type.namedWith [] "Material" []))
                            (Type.list (Type.namedWith [] "Material" []))
                        )
                    )
            }
        )
        [ Elm.list groupAllArg ]


{-| findById: Id -> List Material -> Result String Material -}
findById : Elm.Expression -> List Elm.Expression -> Elm.Expression
findById findByIdArg findByIdArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "findById"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" []
                        , Type.list (Type.namedWith [] "Material" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Material" [] ]
                        )
                    )
            }
        )
        [ findByIdArg, Elm.list findByIdArg0 ]


{-| getRecyclingData: Material -> List Material -> Maybe ( Material, CFFData ) -}
getRecyclingData : Elm.Expression -> List Elm.Expression -> Elm.Expression
getRecyclingData getRecyclingDataArg getRecyclingDataArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "getRecyclingData"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Material" []
                        , Type.list (Type.namedWith [] "Material" [])
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.tuple
                                (Type.namedWith [] "Material" [])
                                (Type.namedWith [] "CFFData" [])
                            ]
                        )
                    )
            }
        )
        [ getRecyclingDataArg, Elm.list getRecyclingDataArg0 ]


annotation_ :
    { cFFData : Type.Annotation
    , material : Type.Annotation
    , id : Type.Annotation
    }
annotation_ =
    { cFFData =
        Type.alias
            moduleName_
            "CFFData"
            []
            (Type.record
                [ ( "manufacturerAllocation", Type.namedWith [] "Split" [] )
                , ( "recycledQualityRatio", Type.namedWith [] "Split" [] )
                ]
            )
    , material =
        Type.alias
            moduleName_
            "Material"
            []
            (Type.record
                [ ( "id", Type.namedWith [] "Id" [] )
                , ( "name", Type.string )
                , ( "shortName", Type.string )
                , ( "category", Type.namedWith [] "Category" [] )
                , ( "materialProcess", Type.namedWith [] "Process" [] )
                , ( "recycledProcess"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Process" [] ]
                  )
                , ( "recycledFrom"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Id" [] ]
                  )
                , ( "spinningProcess"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "Process" [] ]
                  )
                , ( "geographicOrigin", Type.string )
                , ( "defaultCountry", Type.namedWith [ "Country" ] "Code" [] )
                , ( "priority", Type.int )
                , ( "cffData"
                  , Type.namedWith [] "Maybe" [ Type.namedWith [] "CFFData" [] ]
                  )
                ]
            )
    , id = Type.namedWith [ "Data", "Textile", "Material" ] "Id" []
    }


make_ :
    { cFFData :
        { manufacturerAllocation : Elm.Expression
        , recycledQualityRatio : Elm.Expression
        }
        -> Elm.Expression
    , material :
        { id : Elm.Expression
        , name : Elm.Expression
        , shortName : Elm.Expression
        , category : Elm.Expression
        , materialProcess : Elm.Expression
        , recycledProcess : Elm.Expression
        , recycledFrom : Elm.Expression
        , spinningProcess : Elm.Expression
        , geographicOrigin : Elm.Expression
        , defaultCountry : Elm.Expression
        , priority : Elm.Expression
        , cffData : Elm.Expression
        }
        -> Elm.Expression
    , id : Elm.Expression -> Elm.Expression
    }
make_ =
    { cFFData =
        \cFFData_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Material" ]
                    "CFFData"
                    []
                    (Type.record
                        [ ( "manufacturerAllocation"
                          , Type.namedWith [] "Split" []
                          )
                        , ( "recycledQualityRatio"
                          , Type.namedWith [] "Split" []
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair
                        "manufacturerAllocation"
                        cFFData_args.manufacturerAllocation
                    , Tuple.pair
                        "recycledQualityRatio"
                        cFFData_args.recycledQualityRatio
                    ]
                )
    , material =
        \material_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Textile", "Material" ]
                    "Material"
                    []
                    (Type.record
                        [ ( "id", Type.namedWith [] "Id" [] )
                        , ( "name", Type.string )
                        , ( "shortName", Type.string )
                        , ( "category", Type.namedWith [] "Category" [] )
                        , ( "materialProcess", Type.namedWith [] "Process" [] )
                        , ( "recycledProcess"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Process" [] ]
                          )
                        , ( "recycledFrom"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Id" [] ]
                          )
                        , ( "spinningProcess"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "Process" [] ]
                          )
                        , ( "geographicOrigin", Type.string )
                        , ( "defaultCountry"
                          , Type.namedWith [ "Country" ] "Code" []
                          )
                        , ( "priority", Type.int )
                        , ( "cffData"
                          , Type.namedWith
                                []
                                "Maybe"
                                [ Type.namedWith [] "CFFData" [] ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "id" material_args.id
                    , Tuple.pair "name" material_args.name
                    , Tuple.pair "shortName" material_args.shortName
                    , Tuple.pair "category" material_args.category
                    , Tuple.pair "materialProcess" material_args.materialProcess
                    , Tuple.pair "recycledProcess" material_args.recycledProcess
                    , Tuple.pair "recycledFrom" material_args.recycledFrom
                    , Tuple.pair "spinningProcess" material_args.spinningProcess
                    , Tuple.pair
                        "geographicOrigin"
                        material_args.geographicOrigin
                    , Tuple.pair "defaultCountry" material_args.defaultCountry
                    , Tuple.pair "priority" material_args.priority
                    , Tuple.pair "cffData" material_args.cffData
                    ]
                )
    , id =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "Id"
                    , annotation = Just (Type.namedWith [] "Id" [])
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { id :
        Elm.Expression
        -> { idTags_0_0 | id : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    }
caseOf_ =
    { id =
        \idExpression idTags ->
            Elm.Case.custom
                idExpression
                (Type.namedWith [ "Data", "Textile", "Material" ] "Id" [])
                [ Elm.Case.branch1
                    "Id"
                    ( "string.String", Type.string )
                    idTags.id
                ]
    }


call_ :
    { idToString : Elm.Expression -> Elm.Expression
    , encodeId : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    , decodeList : Elm.Expression -> Elm.Expression
    , groupAll : Elm.Expression -> Elm.Expression
    , findById : Elm.Expression -> Elm.Expression -> Elm.Expression
    , getRecyclingData : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { idToString =
        \idToStringArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "idToString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                Type.string
                            )
                    }
                )
                [ idToStringArg ]
    , encodeId =
        \encodeIdArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "encodeId"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeIdArg ]
    , encode =
        \encodeArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "encode"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Material" [] ]
                                (Type.namedWith [ "Encode" ] "Value" [])
                            )
                    }
                )
                [ encodeArg ]
    , decodeList =
        \decodeListArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "decodeList"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Process" []) ]
                                (Type.namedWith
                                    []
                                    "Decoder"
                                    [ Type.list
                                        (Type.namedWith [] "Material" [])
                                    ]
                                )
                            )
                    }
                )
                [ decodeListArg ]
    , groupAll =
        \groupAllArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "groupAll"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list (Type.namedWith [] "Material" []) ]
                                (Type.triple
                                    (Type.list (Type.namedWith [] "Material" [])
                                    )
                                    (Type.list (Type.namedWith [] "Material" [])
                                    )
                                    (Type.list (Type.namedWith [] "Material" [])
                                    )
                                )
                            )
                    }
                )
                [ groupAllArg ]
    , findById =
        \findByIdArg findByIdArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "findById"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Id" []
                                , Type.list (Type.namedWith [] "Material" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Result"
                                    [ Type.string
                                    , Type.namedWith [] "Material" []
                                    ]
                                )
                            )
                    }
                )
                [ findByIdArg, findByIdArg0 ]
    , getRecyclingData =
        \getRecyclingDataArg getRecyclingDataArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Textile", "Material" ]
                    , name = "getRecyclingData"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Material" []
                                , Type.list (Type.namedWith [] "Material" [])
                                ]
                                (Type.namedWith
                                    []
                                    "Maybe"
                                    [ Type.tuple
                                        (Type.namedWith [] "Material" [])
                                        (Type.namedWith [] "CFFData" [])
                                    ]
                                )
                            )
                    }
                )
                [ getRecyclingDataArg, getRecyclingDataArg0 ]
    }


values_ :
    { idToString : Elm.Expression
    , encodeId : Elm.Expression
    , encode : Elm.Expression
    , decodeList : Elm.Expression
    , groupAll : Elm.Expression
    , findById : Elm.Expression
    , getRecyclingData : Elm.Expression
    }
values_ =
    { idToString =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "idToString"
            , annotation =
                Just (Type.function [ Type.namedWith [] "Id" [] ] Type.string)
            }
    , encodeId =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "encodeId"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Material" [] ]
                        (Type.namedWith [ "Encode" ] "Value" [])
                    )
            }
    , decodeList =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "decodeList"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Process" []) ]
                        (Type.namedWith
                            []
                            "Decoder"
                            [ Type.list (Type.namedWith [] "Material" []) ]
                        )
                    )
            }
    , groupAll =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "groupAll"
            , annotation =
                Just
                    (Type.function
                        [ Type.list (Type.namedWith [] "Material" []) ]
                        (Type.triple
                            (Type.list (Type.namedWith [] "Material" []))
                            (Type.list (Type.namedWith [] "Material" []))
                            (Type.list (Type.namedWith [] "Material" []))
                        )
                    )
            }
    , findById =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "findById"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Id" []
                        , Type.list (Type.namedWith [] "Material" [])
                        ]
                        (Type.namedWith
                            []
                            "Result"
                            [ Type.string, Type.namedWith [] "Material" [] ]
                        )
                    )
            }
    , getRecyclingData =
        Elm.value
            { importFrom = [ "Data", "Textile", "Material" ]
            , name = "getRecyclingData"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Material" []
                        , Type.list (Type.namedWith [] "Material" [])
                        ]
                        (Type.namedWith
                            []
                            "Maybe"
                            [ Type.tuple
                                (Type.namedWith [] "Material" [])
                                (Type.namedWith [] "CFFData" [])
                            ]
                        )
                    )
            }
    }