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
    , hasAccessToDetailedImpacts
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
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Common.DecodeUtils as DU
import Data.Component as Component
import Data.Db as Db exposing (Db)
import Data.Food.Query as FoodQuery
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Query as TextileQuery
import Data.User as User
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import List.Extra as LE
import Request.BackendHttp.Error as BackendError
import Request.Version exposing (Version)
import Set exposing (Set)


type alias Queries =
    { food : FoodQuery.Query
    , food2 : Component.Query
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
    , scalingoAppName : Maybe String
    , store : Store
    , versionPollSeconds : Int
    }


type alias EnabledSections =
    { food : Bool
    , food2 : Bool
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
                    List.filter ((/=) bookmark) store.bookmarks
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
                    store.bookmarks |> moveListElement dragged target
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
                    bookmark :: store.bookmarks
            }
        )



-- Db


updateDb : (Db -> Db) -> Session -> Session
updateDb fn session =
    { session | db = fn session.db }



-- Queries


objectQueryFromScope : Scope -> Session -> Component.Query
objectQueryFromScope scope session =
    case scope of
        Scope.Generic Scope.Food2 ->
            session.queries.food2

        Scope.Generic Scope.Object ->
            session.queries.object

        Scope.Generic Scope.Veli ->
            session.queries.veli

        _ ->
            Component.emptyQuery


updateFoodQuery : FoodQuery.Query -> Session -> Session
updateFoodQuery foodQuery ({ queries } as session) =
    { session | queries = { queries | food = foodQuery } }


updateObjectQuery : Scope -> Component.Query -> Session -> Session
updateObjectQuery scope query ({ queries } as session) =
    case scope of
        Scope.Generic Scope.Food2 ->
            { session | queries = { queries | food2 = query } }

        Scope.Generic Scope.Object ->
            { session | queries = { queries | object = query } }

        Scope.Generic Scope.Veli ->
            { session | queries = { queries | veli = query } }

        _ ->
            session
                |> notifyError "Erreur de mise à jour de la requête"
                    ("La requête " ++ Scope.toString scope ++ " n'est pas générique")


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
    { accessTokenData : User.AccessTokenData
    , user : User.User
    }


decodeAuth : Decoder Auth
decodeAuth =
    Decode.succeed Auth
        |> JDP.required "accessTokenData" User.decodeAccessTokenData
        |> JDP.required "user" User.decodeUser


encodeAuth : Auth -> Encode.Value
encodeAuth auth =
    Encode.object
        [ ( "accessTokenData", User.encodeAccessTokenData auth.accessTokenData )
        , ( "user", User.encodeUser auth.user )
        ]


getAuth : Session -> Maybe Auth
getAuth { store } =
    store.auth


isAuthenticated : Session -> Bool
isAuthenticated { store } =
    case store.auth of
        Just _ ->
            True

        Nothing ->
            False


hasAccessToDetailedImpacts : Session -> Bool
hasAccessToDetailedImpacts { store } =
    case store.auth of
        Just auth ->
            auth.user.profile.termsAccepted

        Nothing ->
            False


isSuperuser : Session -> Bool
isSuperuser =
    getAuth
        >> Maybe.map (.user >> .isSuperuser)
        >> Maybe.withDefault False


logout : Session -> Session
logout =
    setAuth Nothing


setAuth : Maybe Auth -> Session -> Session
setAuth auth =
    updateStore (\store -> { store | auth = auth })


updateAuth : (Auth -> Auth) -> Session -> Session
updateAuth fn =
    updateStore (\store -> { store | auth = store.auth |> Maybe.map fn })


{-| A serializable data structure holding session information you want to share
across browser restarts, typically in localStorage.
-}
type alias Store =
    { auth : Maybe Auth
    , bookmarks : List Bookmark
    , comparedSimulations : Set String
    }


defaultStore : Store
defaultStore =
    { auth = Nothing
    , bookmarks = []
    , comparedSimulations = Set.empty
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> DU.strictOptional "auth" decodeAuth
        |> JDP.optional "bookmarks" Bookmark.decodeJsonList []
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "comparedSimulations", store.comparedSimulations |> Encode.set Encode.string )
        , ( "bookmarks", store.bookmarks |> Bookmark.encodeJsonList )
        , ( "auth", store.auth |> Maybe.map encodeAuth |> Maybe.withDefault Encode.null )
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
updateDbProcesses rawDetailedProcessesJson ({ db } as session) =
    case db |> Db.updateProcesses (Db.rawJsonString rawDetailedProcessesJson) of
        Err err ->
            session |> notifyError "Impossible de recharger la db avec les nouveaux procédés" err

        Ok newDb ->
            { session | db = newDb }


updateStore : (Store -> Store) -> Session -> Session
updateStore update session =
    { session | store = update session.store }
