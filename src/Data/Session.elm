module Data.Session exposing
    ( Auth(..)
    , EnabledSections
    , Notification(..)
    , Session
    , Store
    , authenticated
    , checkComparedSimulations
    , closeNotification
    , decodeRawStore
    , defaultStore
    , deleteBookmark
    , getUser
    , isAuthenticated
    , isStaff
    , logout
    , notifyError
    , notifyInfo
    , objectQueryFromScope
    , saveBookmark
    , selectAllBookmarks
    , selectNoBookmarks
    , serializeStore
    , toggleComparedSimulation
    , updateDb
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
import Data.User as User exposing (User)
import Data.User2 as User2
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import RemoteData exposing (WebData)
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
    = GenericError String String
    | GenericInfo String String
    | StoreDecodingError Decode.Error


closeNotification : Notification -> Session -> Session
closeNotification notification ({ notifications } as session) =
    { session | notifications = notifications |> List.filter ((/=) notification) }


notifyInfo : String -> String -> Session -> Session
notifyInfo title info ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericInfo title info ] }


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


{-| A serializable data structure holding session information you want to share
across browser restarts, typically in localStorage.
-}
type alias Store =
    { auth : Auth
    , auth2 : Maybe Auth2
    , bookmarks : List Bookmark
    , comparedSimulations : Set String
    }


type alias Auth2 =
    { accessTokenData : User2.AccessTokenData
    , user : User2.User
    }


type Auth
    = Authenticated User
    | NotAuthenticated


defaultStore : Store
defaultStore =
    { auth = NotAuthenticated
    , auth2 = Nothing
    , bookmarks = []
    , comparedSimulations = Set.empty
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> DU.strictOptionalWithDefault "auth" decodeAuth NotAuthenticated
        |> DU.strictOptional "auth2" decodeAuth2
        |> JDP.optional "bookmarks" (Decode.list Bookmark.decode) []
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty


decodeAuth : Decoder Auth
decodeAuth =
    Decode.succeed Authenticated
        |> JDP.required "user" User.decode


decodeAuth2 : Decoder Auth2
decodeAuth2 =
    Decode.succeed Auth2
        |> JDP.required "accessTokenData" User2.decodeAccessTokenData
        |> JDP.required "user" User2.decodeUser


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "comparedSimulations", store.comparedSimulations |> Set.toList |> Encode.list Encode.string )
        , ( "bookmarks", Encode.list Bookmark.encode store.bookmarks )
        , ( "auth", encodeAuth store.auth )
        ]


encodeAuth : Auth -> Encode.Value
encodeAuth auth =
    case auth of
        Authenticated user ->
            Encode.object [ ( "user", User.encode user ) ]

        NotAuthenticated ->
            Encode.null


getUser : Session -> Maybe User
getUser { store } =
    case store.auth of
        Authenticated user ->
            Just user

        NotAuthenticated ->
            Nothing


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


updateStore : (Store -> Store) -> Session -> Session
updateStore update session =
    { session | store = update session.store }


authenticated : User -> String -> Session -> Session
authenticated user rawDetailedProcessesJson ({ store } as session) =
    case StaticDb.db rawDetailedProcessesJson of
        Err err ->
            session
                |> notifyError "Impossible de recharger la db avec les nouveaux procédés" err

        Ok db ->
            { session | db = db, store = { store | auth = Authenticated user } }


logout : Session -> Session
logout ({ store } as session) =
    case StaticDb.db StaticJson.processesJson of
        Err err ->
            { session | store = { store | auth = NotAuthenticated } }
                |> notifyError "Impossible de recharger la db avec les procédés par défaut" err

        Ok db ->
            { session | db = db, store = { store | auth = NotAuthenticated } }


isAuthenticated : Session -> Bool
isAuthenticated { store } =
    case store.auth of
        Authenticated _ ->
            True

        _ ->
            False


isStaff : Session -> Bool
isStaff =
    getUser
        >> Maybe.map .staff
        >> Maybe.withDefault False
