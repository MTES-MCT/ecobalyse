module Data.Session exposing
    ( Auth
    , EnabledSections
    , Notification(..)
    , Session
    , Store
    , checkComparedSimulations
    , clearNotifications
    , closeNotification
    , decodeRawStore
    , defaultStore
    , deleteBookmark
    , getAuth
    , isAuthenticated
    , isSuperuser
    , logout
    , moveBookmark
    , moveListElement
    , notifyBackendError
    , objectQueryFromScope
    , replaceBookmark
    , saveBookmark
    , selectAllBookmarks
    , selectNoBookmarks
    , serializeStore
    , setAuth
    , toggleComparedSimulation
    , updateAuth
    , updateDb
    , updateDbProcesses
    , updateFoodQuery
    , updateObjectQuery
    , updateTextileQuery
    )

import Browser.Navigation as Nav
import Data.Bookmark as Bookmark exposing (Bookmark, JsonBookmark)
import Data.Common.DecodeUtils as DU
import Data.Component as Component
import Data.Food.Query as FoodQuery
import Data.Github as Github
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Query as TextileQuery
import Data.User as User2
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import List.Extra as LE
import RemoteData exposing (WebData)
import Request.BackendHttp.Error as BackendError
import Request.Version exposing (Version)
import Set exposing (Set)
import Static.Db as StaticDb exposing (Db)
import Static.Json as StaticJson


type alias Queries =
    { food : FoodQuery.Query
    , object : Component.Query
    , textile : TextileQuery.Query
    , veli : Component.Query
    }


type alias Session =
    { clientUrl : String
    , componentConfig : Component.Config
    , currentVersion : Version
    , db : Db
    , enabledSections : EnabledSections
    , matomo : { host : String, siteId : String }
    , navKey : Nav.Key
    , notifications : List Notification
    , queries : Queries
    , releases : WebData (List Github.Release)
    , scalingoAppName : Maybe String
    , store : Store
    , versionPollSeconds : Int
    }


type alias EnabledSections =
    { food : Bool
    , objects : Bool
    , textile : Bool
    , veli : Bool
    }



-- Notifications


type Notification
    = BackendError BackendError.Error
    | GenericError String String
    | StoreDecodingError Decode.Error


clearNotifications : Session -> Session
clearNotifications session =
    { session | notifications = [] }


closeNotification : Notification -> Session -> Session
closeNotification notification ({ notifications } as session) =
    { session | notifications = notifications |> List.filter ((/=) notification) }


notifyBackendError : BackendError.Error -> Session -> Session
notifyBackendError backendError ({ notifications } as session) =
    { session | notifications = notifications ++ [ BackendError backendError ] }


notifyError : String -> String -> Session -> Session
notifyError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericError title error ] }


notifyStoreDecodingError : Decode.Error -> Session -> Session
notifyStoreDecodingError error ({ notifications } as session) =
    { session | notifications = notifications ++ [ StoreDecodingError error ] }



-- Boomarks


deleteBookmark : Bookmark -> Session -> Session
deleteBookmark bookmark =
    updateStore
        (\store ->
            { store
                | bookmarks =
                    List.filter ((/=) (Bookmark.toJson bookmark)) store.bookmarks
            }
        )


insertAt : Int -> a -> List a -> List a
insertAt index value list =
    List.concat [ List.take index list, [ value ], List.drop index list ]


moveListElement : a -> a -> List a -> List a
moveListElement from to list =
    case LE.elemIndex to list of
        Just toIndex ->
            list |> LE.remove from |> insertAt toIndex from

        Nothing ->
            list


moveBookmark : Bookmark -> Bookmark -> Session -> Session
moveBookmark dragged target =
    updateStore
        (\store ->
            { store
                | bookmarks =
                    store.bookmarks
                        |> moveListElement (Bookmark.toJson dragged) (Bookmark.toJson target)
            }
        )


replaceBookmark : Bookmark -> Session -> Session
replaceBookmark bookmark =
    updateStore
        (\store ->
            { store
                | bookmarks = Bookmark.replace bookmark store.bookmarks
            }
        )


saveBookmark : Bookmark -> Session -> Session
saveBookmark bookmark =
    updateStore
        (\store ->
            { store
                | bookmarks =
                    Bookmark.toJson bookmark :: store.bookmarks
            }
        )



-- Db


updateDb : (Db -> Db) -> Session -> Session
updateDb fn session =
    { session | db = fn session.db }



-- Queries


objectQueryFromScope : Scope -> Session -> Component.Query
objectQueryFromScope scope session =
    if scope == Scope.Veli then
        session.queries.veli

    else
        session.queries.object


updateFoodQuery : FoodQuery.Query -> Session -> Session
updateFoodQuery foodQuery ({ queries } as session) =
    { session | queries = { queries | food = foodQuery } }


updateObjectQuery : Scope -> Component.Query -> Session -> Session
updateObjectQuery scope objectQuery ({ queries } as session) =
    { session
        | queries =
            if scope == Scope.Veli then
                { queries | veli = objectQuery }

            else
                { queries | object = objectQuery }
    }


updateTextileQuery : TextileQuery.Query -> Session -> Session
updateTextileQuery textileQuery ({ queries } as session) =
    { session | queries = { queries | textile = textileQuery } }



-- Comparator


checkComparedSimulations : Session -> Session
checkComparedSimulations =
    updateStore
        (\({ bookmarks, comparedSimulations } as store) ->
            let
                validBookmarks =
                    Bookmark.onlyValid bookmarks
            in
            { store
                | comparedSimulations =
                    if Set.isEmpty comparedSimulations then
                        -- Add max bookmarks to compared sims
                        validBookmarks
                            |> Bookmark.sort
                            |> List.map Bookmark.toId
                            |> Set.fromList

                    else
                        -- Purge deleted bookmarks from compared sims
                        comparedSimulations
                            |> Set.filter
                                (\id ->
                                    validBookmarks
                                        |> List.map Bookmark.toId
                                        |> List.member id
                                )
            }
        )


toggleComparedSimulation : Bookmark -> Bool -> Session -> Session
toggleComparedSimulation bookmark checked =
    updateStore
        (\store ->
            { store
                | comparedSimulations =
                    if checked then
                        Set.insert (Bookmark.toId bookmark) store.comparedSimulations

                    else
                        Set.remove (Bookmark.toId bookmark) store.comparedSimulations
            }
        )


selectAllBookmarks : Session -> Session
selectAllBookmarks =
    updateStore
        (\store ->
            { store
                | comparedSimulations =
                    store.bookmarks |> Bookmark.onlyValid |> List.map Bookmark.toId |> Set.fromList
            }
        )


selectNoBookmarks : Session -> Session
selectNoBookmarks =
    updateStore (\store -> { store | comparedSimulations = Set.empty })



--
-- Auth
--


type alias Auth =
    { accessTokenData : User2.AccessTokenData
    , user : User2.User
    }


decodeAuth : Decoder Auth
decodeAuth =
    Decode.succeed Auth
        |> JDP.required "accessTokenData" User2.decodeAccessTokenData
        |> JDP.required "user" User2.decodeUser


encodeAuth : Auth -> Encode.Value
encodeAuth auth2 =
    Encode.object
        [ ( "accessTokenData", User2.encodeAccessTokenData auth2.accessTokenData )
        , ( "user", User2.encodeUser auth2.user )
        ]


getAuth : Session -> Maybe Auth
getAuth { store } =
    store.auth2


isAuthenticated : Session -> Bool
isAuthenticated { store } =
    case store.auth2 of
        Just _ ->
            True

        Nothing ->
            False


isSuperuser : Session -> Bool
isSuperuser =
    getAuth
        >> Maybe.map (.user >> .isSuperuser)
        >> Maybe.withDefault False


logout : Session -> Session
logout session =
    (case StaticDb.db StaticJson.processesJson of
        Err err ->
            session |> notifyError "Impossible de recharger les procédés par défaut" err

        Ok db ->
            { session | db = db }
    )
        |> updateStore (\store -> { store | auth2 = Nothing })


setAuth : Maybe Auth -> Session -> Session
setAuth auth2 =
    updateStore (\store -> { store | auth2 = auth2 })


updateAuth : (Auth -> Auth) -> Session -> Session
updateAuth fn =
    updateStore (\store -> { store | auth2 = store.auth2 |> Maybe.map fn })


{-| A serializable data structure holding session information you want to share
across browser restarts, typically in localStorage.
-}
type alias Store =
    { auth2 : Maybe Auth
    , bookmarks : List JsonBookmark
    , comparedSimulations : Set String
    }


defaultStore : Store
defaultStore =
    { auth2 = Nothing
    , bookmarks = []
    , comparedSimulations = Set.empty
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> DU.strictOptional "auth2" decodeAuth
        |> JDP.optional "bookmarks" Bookmark.decodeJsonList []
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "comparedSimulations", store.comparedSimulations |> Encode.set Encode.string )
        , ( "bookmarks", store.bookmarks |> Bookmark.encodeJsonList )
        , ( "auth2", store.auth2 |> Maybe.map encodeAuth |> Maybe.withDefault Encode.null )
        ]


decodeRawStore : String -> Session -> Session
decodeRawStore rawStore session =
    case Decode.decodeString decodeStore rawStore of
        Err error ->
            session |> notifyStoreDecodingError error

        Ok store ->
            { session | store = store }


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0


updateDbProcesses : String -> Session -> Session
updateDbProcesses rawDetailedProcessesJson session =
    case StaticDb.db rawDetailedProcessesJson of
        Err err ->
            session |> notifyError "Impossible de recharger la db avec les nouveaux procédés" err

        Ok db ->
            { session | db = db }


updateStore : (Store -> Store) -> Session -> Session
updateStore update session =
    { session | store = update session.store }
