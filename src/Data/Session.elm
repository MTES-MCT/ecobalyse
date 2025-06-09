module Data.Session exposing
    ( Auth
    , EnabledSections
    , Notification(..)
    , Session
    , Store
    , checkComparedSimulations
    , closeNotification
    , decodeRawStore
    , defaultStore
    , deleteBookmark
    , getAuth
    , isAuthenticated
    , isStaff
    , logout
    , notifyBackendError
    , notifyError
    , notifyInfo
    , objectQueryFromScope
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
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Common.DecodeUtils as DU
import Data.Food.Query as FoodQuery
import Data.Github as Github
import Data.Object.Query as ObjectQuery
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Query as TextileQuery
import Data.User as User2
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import RemoteData exposing (WebData)
import Request.BackendHttp.Error as BackendError
import Request.Version exposing (Version)
import Set exposing (Set)
import Static.Db as StaticDb exposing (Db)
import Static.Json as StaticJson


type alias Queries =
    { food : FoodQuery.Query
    , object : ObjectQuery.Query
    , textile : TextileQuery.Query
    , veli : ObjectQuery.Query
    }


type alias Session =
    { backendApiUrl : String
    , clientUrl : String
    , currentVersion : Version
    , db : Db
    , enabledSections : EnabledSections
    , matomo : { host : String, siteId : String }
    , navKey : Nav.Key
    , notifications : List Notification
    , queries : Queries
    , releases : WebData (List Github.Release)
    , store : Store
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
    | GenericInfo String String
    | StoreDecodingError Decode.Error


closeNotification : Notification -> Session -> Session
closeNotification notification ({ notifications } as session) =
    { session | notifications = notifications |> List.filter ((/=) notification) }


notifyBackendError : BackendError.Error -> Session -> Session
notifyBackendError backendError ({ notifications } as session) =
    { session | notifications = notifications ++ [ BackendError backendError ] }


notifyError : String -> String -> Session -> Session
notifyError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericError title error ] }


notifyInfo : String -> String -> Session -> Session
notifyInfo title info ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericInfo title info ] }


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
                    List.filter ((/=) bookmark) store.bookmarks
            }
        )


saveBookmark : Bookmark -> Session -> Session
saveBookmark bookmark =
    updateStore
        (\store ->
            { store
                | bookmarks =
                    bookmark :: store.bookmarks
            }
        )



-- Db


updateDb : (Db -> Db) -> Session -> Session
updateDb fn session =
    { session | db = fn session.db }



-- Queries


objectQueryFromScope : Scope -> Session -> ObjectQuery.Query
objectQueryFromScope scope session =
    if scope == Scope.Veli then
        session.queries.veli

    else
        session.queries.object


updateFoodQuery : FoodQuery.Query -> Session -> Session
updateFoodQuery foodQuery ({ queries } as session) =
    { session | queries = { queries | food = foodQuery } }


updateObjectQuery : Scope -> ObjectQuery.Query -> Session -> Session
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
            { store
                | comparedSimulations =
                    if Set.isEmpty comparedSimulations then
                        -- Add max bookmarks to compared sims
                        bookmarks
                            |> Bookmark.sort
                            |> List.map Bookmark.toId
                            |> Set.fromList

                    else
                        -- Purge deleted bookmarks from compared sims
                        comparedSimulations
                            |> Set.filter
                                (\id ->
                                    bookmarks
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
                    store.bookmarks |> List.map Bookmark.toId |> Set.fromList
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


isStaff : Session -> Bool
isStaff =
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
    , bookmarks : List Bookmark
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
        |> JDP.optional "bookmarks" (Decode.list Bookmark.decode) []
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "comparedSimulations", store.comparedSimulations |> Set.toList |> Encode.list Encode.string )
        , ( "bookmarks", Encode.list Bookmark.encode store.bookmarks )
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
