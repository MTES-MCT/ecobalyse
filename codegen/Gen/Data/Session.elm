module Gen.Data.Session exposing (annotation_, call_, caseOf_, checkComparedSimulations, closeNotification, deleteBookmark, deserializeStore, fromUnloaded, make_, maxComparedSimulations, moduleName_, notifyError, notifyHttpError, saveBookmark, serializeStore, toggleComparedSimulation, updateFoodQuery, updateTextileQuery, values_)

{-| 
@docs moduleName_, serializeStore, deserializeStore, toggleComparedSimulation, checkComparedSimulations, maxComparedSimulations, updateTextileQuery, updateFoodQuery, saveBookmark, deleteBookmark, notifyHttpError, notifyError, closeNotification, fromUnloaded, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Session" ]


{-| serializeStore: Store -> String -}
serializeStore : Elm.Expression -> Elm.Expression
serializeStore serializeStoreArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "serializeStore"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Store" [] ] Type.string)
            }
        )
        [ serializeStoreArg ]


{-| deserializeStore: String -> Store -}
deserializeStore : String -> Elm.Expression
deserializeStore deserializeStoreArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "deserializeStore"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [] "Store" [])
                    )
            }
        )
        [ Elm.string deserializeStoreArg ]


{-| toggleComparedSimulation: Bookmark -> Bool -> Session -> Session -}
toggleComparedSimulation :
    Elm.Expression -> Bool -> Elm.Expression -> Elm.Expression
toggleComparedSimulation toggleComparedSimulationArg toggleComparedSimulationArg0 toggleComparedSimulationArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "toggleComparedSimulation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" []
                        , Type.bool
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ toggleComparedSimulationArg
        , Elm.bool toggleComparedSimulationArg0
        , toggleComparedSimulationArg1
        ]


{-| checkComparedSimulations: Session -> Session -}
checkComparedSimulations : Elm.Expression -> Elm.Expression
checkComparedSimulations checkComparedSimulationsArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "checkComparedSimulations"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Session" [] ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ checkComparedSimulationsArg ]


{-| maxComparedSimulations: Int -}
maxComparedSimulations : Elm.Expression
maxComparedSimulations =
    Elm.value
        { importFrom = [ "Data", "Session" ]
        , name = "maxComparedSimulations"
        , annotation = Just Type.int
        }


{-| updateTextileQuery: TextileInputs.Query -> Session -> Session -}
updateTextileQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
updateTextileQuery updateTextileQueryArg updateTextileQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "updateTextileQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "TextileInputs" ] "Query" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ updateTextileQueryArg, updateTextileQueryArg0 ]


{-| updateFoodQuery: FoodQuery.Query -> Session -> Session -}
updateFoodQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
updateFoodQuery updateFoodQueryArg updateFoodQueryArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "updateFoodQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "FoodQuery" ] "Query" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ updateFoodQueryArg, updateFoodQueryArg0 ]


{-| saveBookmark: Bookmark -> Session -> Session -}
saveBookmark : Elm.Expression -> Elm.Expression -> Elm.Expression
saveBookmark saveBookmarkArg saveBookmarkArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "saveBookmark"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ saveBookmarkArg, saveBookmarkArg0 ]


{-| deleteBookmark: Bookmark -> Session -> Session -}
deleteBookmark : Elm.Expression -> Elm.Expression -> Elm.Expression
deleteBookmark deleteBookmarkArg deleteBookmarkArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "deleteBookmark"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ deleteBookmarkArg, deleteBookmarkArg0 ]


{-| notifyHttpError: 
    Http.Error
    -> { a | notifications : List Notification }
    -> { a | notifications : List Notification }
-}
notifyHttpError :
    Elm.Expression
    -> { a | notifications : List Elm.Expression }
    -> Elm.Expression
notifyHttpError notifyHttpErrorArg notifyHttpErrorArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "notifyHttpError"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Http" ] "Error" []
                        , Type.extensible
                            "a"
                            [ ( "notifications"
                              , Type.list (Type.namedWith [] "Notification" [])
                              )
                            ]
                        ]
                        (Type.extensible
                            "a"
                            [ ( "notifications"
                              , Type.list (Type.namedWith [] "Notification" [])
                              )
                            ]
                        )
                    )
            }
        )
        [ notifyHttpErrorArg
        , Elm.record
            [ Tuple.pair
                "notifications"
                (Elm.list notifyHttpErrorArg0.notifications)
            ]
        ]


{-| notifyError: String -> String -> Session -> Session -}
notifyError : String -> String -> Elm.Expression -> Elm.Expression
notifyError notifyErrorArg notifyErrorArg0 notifyErrorArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "notifyError"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.string
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ Elm.string notifyErrorArg
        , Elm.string notifyErrorArg0
        , notifyErrorArg1
        ]


{-| closeNotification: Notification -> Session -> Session -}
closeNotification : Elm.Expression -> Elm.Expression -> Elm.Expression
closeNotification closeNotificationArg closeNotificationArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "closeNotification"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Notification" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ closeNotificationArg, closeNotificationArg0 ]


{-| fromUnloaded: UnloadedSession -> Db -> Session -}
fromUnloaded : Elm.Expression -> Elm.Expression -> Elm.Expression
fromUnloaded fromUnloadedArg fromUnloadedArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "fromUnloaded"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "UnloadedSession" []
                        , Type.namedWith [] "Db" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
        )
        [ fromUnloadedArg, fromUnloadedArg0 ]


annotation_ :
    { unloadedSession : Type.Annotation
    , session : Type.Annotation
    , notification : Type.Annotation
    }
annotation_ =
    { unloadedSession =
        Type.alias
            moduleName_
            "UnloadedSession"
            []
            (Type.record
                [ ( "navKey", Type.namedWith [ "Nav" ] "Key" [] )
                , ( "clientUrl", Type.string )
                , ( "store", Type.namedWith [] "Store" [] )
                , ( "currentVersion", Type.namedWith [] "Version" [] )
                , ( "builderDb"
                  , Type.namedWith
                        []
                        "WebData"
                        [ Type.namedWith [ "BuilderDb" ] "Db" [] ]
                  )
                , ( "explorerDb", Type.namedWith [ "ExplorerDb" ] "Db" [] )
                , ( "notifications"
                  , Type.list (Type.namedWith [] "Notification" [])
                  )
                , ( "queries"
                  , Type.record
                        [ ( "food", Type.namedWith [ "FoodQuery" ] "Query" [] )
                        , ( "textile"
                          , Type.namedWith [ "TextileInputs" ] "Query" []
                          )
                        ]
                  )
                ]
            )
    , session =
        Type.alias
            moduleName_
            "Session"
            []
            (Type.record
                [ ( "navKey", Type.namedWith [ "Nav" ] "Key" [] )
                , ( "clientUrl", Type.string )
                , ( "store", Type.namedWith [] "Store" [] )
                , ( "currentVersion", Type.namedWith [] "Version" [] )
                , ( "db", Type.namedWith [] "Db" [] )
                , ( "builderDb"
                  , Type.namedWith
                        []
                        "WebData"
                        [ Type.namedWith [ "BuilderDb" ] "Db" [] ]
                  )
                , ( "explorerDb", Type.namedWith [ "ExplorerDb" ] "Db" [] )
                , ( "notifications"
                  , Type.list (Type.namedWith [] "Notification" [])
                  )
                , ( "queries"
                  , Type.record
                        [ ( "food", Type.namedWith [ "FoodQuery" ] "Query" [] )
                        , ( "textile"
                          , Type.namedWith [ "TextileInputs" ] "Query" []
                          )
                        ]
                  )
                ]
            )
    , notification = Type.namedWith [ "Data", "Session" ] "Notification" []
    }


make_ :
    { unloadedSession :
        { navKey : Elm.Expression
        , clientUrl : Elm.Expression
        , store : Elm.Expression
        , currentVersion : Elm.Expression
        , builderDb : Elm.Expression
        , explorerDb : Elm.Expression
        , notifications : Elm.Expression
        , queries : Elm.Expression
        }
        -> Elm.Expression
    , session :
        { navKey : Elm.Expression
        , clientUrl : Elm.Expression
        , store : Elm.Expression
        , currentVersion : Elm.Expression
        , db : Elm.Expression
        , builderDb : Elm.Expression
        , explorerDb : Elm.Expression
        , notifications : Elm.Expression
        , queries : Elm.Expression
        }
        -> Elm.Expression
    , httpError : Elm.Expression -> Elm.Expression
    , genericError : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
make_ =
    { unloadedSession =
        \unloadedSession_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Session" ]
                    "UnloadedSession"
                    []
                    (Type.record
                        [ ( "navKey", Type.namedWith [ "Nav" ] "Key" [] )
                        , ( "clientUrl", Type.string )
                        , ( "store", Type.namedWith [] "Store" [] )
                        , ( "currentVersion", Type.namedWith [] "Version" [] )
                        , ( "builderDb"
                          , Type.namedWith
                                []
                                "WebData"
                                [ Type.namedWith [ "BuilderDb" ] "Db" [] ]
                          )
                        , ( "explorerDb"
                          , Type.namedWith [ "ExplorerDb" ] "Db" []
                          )
                        , ( "notifications"
                          , Type.list (Type.namedWith [] "Notification" [])
                          )
                        , ( "queries"
                          , Type.record
                                [ ( "food"
                                  , Type.namedWith [ "FoodQuery" ] "Query" []
                                  )
                                , ( "textile"
                                  , Type.namedWith
                                        [ "TextileInputs" ]
                                        "Query"
                                        []
                                  )
                                ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "navKey" unloadedSession_args.navKey
                    , Tuple.pair "clientUrl" unloadedSession_args.clientUrl
                    , Tuple.pair "store" unloadedSession_args.store
                    , Tuple.pair
                        "currentVersion"
                        unloadedSession_args.currentVersion
                    , Tuple.pair "builderDb" unloadedSession_args.builderDb
                    , Tuple.pair "explorerDb" unloadedSession_args.explorerDb
                    , Tuple.pair
                        "notifications"
                        unloadedSession_args.notifications
                    , Tuple.pair "queries" unloadedSession_args.queries
                    ]
                )
    , session =
        \session_args ->
            Elm.withType
                (Type.alias
                    [ "Data", "Session" ]
                    "Session"
                    []
                    (Type.record
                        [ ( "navKey", Type.namedWith [ "Nav" ] "Key" [] )
                        , ( "clientUrl", Type.string )
                        , ( "store", Type.namedWith [] "Store" [] )
                        , ( "currentVersion", Type.namedWith [] "Version" [] )
                        , ( "db", Type.namedWith [] "Db" [] )
                        , ( "builderDb"
                          , Type.namedWith
                                []
                                "WebData"
                                [ Type.namedWith [ "BuilderDb" ] "Db" [] ]
                          )
                        , ( "explorerDb"
                          , Type.namedWith [ "ExplorerDb" ] "Db" []
                          )
                        , ( "notifications"
                          , Type.list (Type.namedWith [] "Notification" [])
                          )
                        , ( "queries"
                          , Type.record
                                [ ( "food"
                                  , Type.namedWith [ "FoodQuery" ] "Query" []
                                  )
                                , ( "textile"
                                  , Type.namedWith
                                        [ "TextileInputs" ]
                                        "Query"
                                        []
                                  )
                                ]
                          )
                        ]
                    )
                )
                (Elm.record
                    [ Tuple.pair "navKey" session_args.navKey
                    , Tuple.pair "clientUrl" session_args.clientUrl
                    , Tuple.pair "store" session_args.store
                    , Tuple.pair "currentVersion" session_args.currentVersion
                    , Tuple.pair "db" session_args.db
                    , Tuple.pair "builderDb" session_args.builderDb
                    , Tuple.pair "explorerDb" session_args.explorerDb
                    , Tuple.pair "notifications" session_args.notifications
                    , Tuple.pair "queries" session_args.queries
                    ]
                )
    , httpError =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "HttpError"
                    , annotation = Just (Type.namedWith [] "Notification" [])
                    }
                )
                [ ar0 ]
    , genericError =
        \ar0 ar1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "GenericError"
                    , annotation = Just (Type.namedWith [] "Notification" [])
                    }
                )
                [ ar0, ar1 ]
    }


caseOf_ :
    { notification :
        Elm.Expression
        -> { notificationTags_0_0
            | httpError : Elm.Expression -> Elm.Expression
            , genericError : Elm.Expression -> Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { notification =
        \notificationExpression notificationTags ->
            Elm.Case.custom
                notificationExpression
                (Type.namedWith [ "Data", "Session" ] "Notification" [])
                [ Elm.Case.branch1
                    "HttpError"
                    ( "http.Error", Type.namedWith [ "Http" ] "Error" [] )
                    notificationTags.httpError
                , Elm.Case.branch2
                    "GenericError"
                    ( "string.String", Type.string )
                    ( "string.String", Type.string )
                    notificationTags.genericError
                ]
    }


call_ :
    { serializeStore : Elm.Expression -> Elm.Expression
    , deserializeStore : Elm.Expression -> Elm.Expression
    , toggleComparedSimulation :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , checkComparedSimulations : Elm.Expression -> Elm.Expression
    , updateTextileQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , updateFoodQuery : Elm.Expression -> Elm.Expression -> Elm.Expression
    , saveBookmark : Elm.Expression -> Elm.Expression -> Elm.Expression
    , deleteBookmark : Elm.Expression -> Elm.Expression -> Elm.Expression
    , notifyHttpError : Elm.Expression -> Elm.Expression -> Elm.Expression
    , notifyError :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , closeNotification : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromUnloaded : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { serializeStore =
        \serializeStoreArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "serializeStore"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Store" [] ]
                                Type.string
                            )
                    }
                )
                [ serializeStoreArg ]
    , deserializeStore =
        \deserializeStoreArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "deserializeStore"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith [] "Store" [])
                            )
                    }
                )
                [ deserializeStoreArg ]
    , toggleComparedSimulation =
        \toggleComparedSimulationArg toggleComparedSimulationArg0 toggleComparedSimulationArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "toggleComparedSimulation"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" []
                                , Type.bool
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ toggleComparedSimulationArg
                , toggleComparedSimulationArg0
                , toggleComparedSimulationArg1
                ]
    , checkComparedSimulations =
        \checkComparedSimulationsArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "checkComparedSimulations"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Session" [] ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ checkComparedSimulationsArg ]
    , updateTextileQuery =
        \updateTextileQueryArg updateTextileQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "updateTextileQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "TextileInputs" ] "Query" []
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ updateTextileQueryArg, updateTextileQueryArg0 ]
    , updateFoodQuery =
        \updateFoodQueryArg updateFoodQueryArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "updateFoodQuery"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "FoodQuery" ] "Query" []
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ updateFoodQueryArg, updateFoodQueryArg0 ]
    , saveBookmark =
        \saveBookmarkArg saveBookmarkArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "saveBookmark"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" []
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ saveBookmarkArg, saveBookmarkArg0 ]
    , deleteBookmark =
        \deleteBookmarkArg deleteBookmarkArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "deleteBookmark"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Bookmark" []
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ deleteBookmarkArg, deleteBookmarkArg0 ]
    , notifyHttpError =
        \notifyHttpErrorArg notifyHttpErrorArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "notifyHttpError"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Http" ] "Error" []
                                , Type.extensible
                                    "a"
                                    [ ( "notifications"
                                      , Type.list
                                            (Type.namedWith [] "Notification" []
                                            )
                                      )
                                    ]
                                ]
                                (Type.extensible
                                    "a"
                                    [ ( "notifications"
                                      , Type.list
                                            (Type.namedWith [] "Notification" []
                                            )
                                      )
                                    ]
                                )
                            )
                    }
                )
                [ notifyHttpErrorArg, notifyHttpErrorArg0 ]
    , notifyError =
        \notifyErrorArg notifyErrorArg0 notifyErrorArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "notifyError"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string
                                , Type.string
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ notifyErrorArg, notifyErrorArg0, notifyErrorArg1 ]
    , closeNotification =
        \closeNotificationArg closeNotificationArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "closeNotification"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "Notification" []
                                , Type.namedWith [] "Session" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ closeNotificationArg, closeNotificationArg0 ]
    , fromUnloaded =
        \fromUnloadedArg fromUnloadedArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Data", "Session" ]
                    , name = "fromUnloaded"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [] "UnloadedSession" []
                                , Type.namedWith [] "Db" []
                                ]
                                (Type.namedWith [] "Session" [])
                            )
                    }
                )
                [ fromUnloadedArg, fromUnloadedArg0 ]
    }


values_ :
    { serializeStore : Elm.Expression
    , deserializeStore : Elm.Expression
    , toggleComparedSimulation : Elm.Expression
    , checkComparedSimulations : Elm.Expression
    , maxComparedSimulations : Elm.Expression
    , updateTextileQuery : Elm.Expression
    , updateFoodQuery : Elm.Expression
    , saveBookmark : Elm.Expression
    , deleteBookmark : Elm.Expression
    , notifyHttpError : Elm.Expression
    , notifyError : Elm.Expression
    , closeNotification : Elm.Expression
    , fromUnloaded : Elm.Expression
    }
values_ =
    { serializeStore =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "serializeStore"
            , annotation =
                Just
                    (Type.function [ Type.namedWith [] "Store" [] ] Type.string)
            }
    , deserializeStore =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "deserializeStore"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [] "Store" [])
                    )
            }
    , toggleComparedSimulation =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "toggleComparedSimulation"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" []
                        , Type.bool
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , checkComparedSimulations =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "checkComparedSimulations"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Session" [] ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , maxComparedSimulations =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "maxComparedSimulations"
            , annotation = Just Type.int
            }
    , updateTextileQuery =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "updateTextileQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "TextileInputs" ] "Query" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , updateFoodQuery =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "updateFoodQuery"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "FoodQuery" ] "Query" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , saveBookmark =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "saveBookmark"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , deleteBookmark =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "deleteBookmark"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Bookmark" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , notifyHttpError =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "notifyHttpError"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Http" ] "Error" []
                        , Type.extensible
                            "a"
                            [ ( "notifications"
                              , Type.list (Type.namedWith [] "Notification" [])
                              )
                            ]
                        ]
                        (Type.extensible
                            "a"
                            [ ( "notifications"
                              , Type.list (Type.namedWith [] "Notification" [])
                              )
                            ]
                        )
                    )
            }
    , notifyError =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "notifyError"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.string
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , closeNotification =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "closeNotification"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "Notification" []
                        , Type.namedWith [] "Session" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    , fromUnloaded =
        Elm.value
            { importFrom = [ "Data", "Session" ]
            , name = "fromUnloaded"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [] "UnloadedSession" []
                        , Type.namedWith [] "Db" []
                        ]
                        (Type.namedWith [] "Session" [])
                    )
            }
    }