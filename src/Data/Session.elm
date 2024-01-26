module Data.Session exposing
    ( Notification(..)
    , Session
    , Store
    , checkComparedSimulations
    , closeNotification
    , deleteBookmark
    , deserializeStore
    , isLoggedIn
    , loggedIn
    , login
    , logout
    , notifyError
    , saveBookmark
    , selectAllBookmarks
    , selectNoBookmarks
    , serializeStore
    , toggleComparedSimulation
    , updateFoodQuery
    , updateTextileQuery
    )

import Browser.Navigation as Nav
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Process as FoodProcess
import Data.Food.Query as FoodQuery
import Data.Textile.Process as TextileProcess
import Data.Textile.Query as TextileQuery
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Request.Version exposing (Version)
import Set exposing (Set)
import Static.Db exposing (Db)
import Task


type alias Session =
    { db : Db
    , navKey : Nav.Key
    , clientUrl : String
    , store : Store
    , currentVersion : Version
    , matomo : { host : String, siteId : String }
    , notifications : List Notification
    , queries :
        { food : FoodQuery.Query
        , textile : TextileQuery.Query
        }
    }



-- Notifications


type Notification
    = GenericError String String


closeNotification : Notification -> Session -> Session
closeNotification notification ({ notifications } as session) =
    { session | notifications = notifications |> List.filter ((/=) notification) }


notifyError : String -> String -> Session -> Session
notifyError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericError title error ] }



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



-- Queries


updateFoodQuery : FoodQuery.Query -> Session -> Session
updateFoodQuery foodQuery ({ queries } as session) =
    { session | queries = { queries | food = foodQuery } }


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
                    if Set.size comparedSimulations == 0 then
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



-- Store
--
-- A serializable data structure holding session information you want to share
-- across browser restarts, typically in localStorage.


type alias Store =
    { comparedSimulations : Set String
    , bookmarks : List Bookmark
    , auth : Auth
    }


type Auth
    = NotLoggedIn
    | LoggedIn (List TextileProcess.Process) (List FoodProcess.Process)


defaultStore : Store
defaultStore =
    { comparedSimulations = Set.empty
    , bookmarks = []
    , auth = NotLoggedIn
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty
        |> JDP.optional "bookmarks" (Decode.list Bookmark.decode) []
        |> JDP.optional "auth" decodeAuth NotLoggedIn


decodeAuth : Decoder Auth
decodeAuth =
    Decode.succeed LoggedIn
        |> JDP.required "textileProcesses" TextileProcess.decodeList
        |> JDP.required "foodProcesses" FoodProcess.decodeList


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
        NotLoggedIn ->
            Encode.null

        LoggedIn textileProcesses foodProcesses ->
            Encode.object
                [ ( "textileProcesses", Encode.list TextileProcess.encode textileProcesses )
                , ( "foodProcesses", Encode.list FoodProcess.encode foodProcesses )
                ]


deserializeStore : String -> Store
deserializeStore =
    Decode.decodeString decodeStore
        -- FIXME: this should return a `Result String Store` so we could inform
        -- users something went wrong while decoding their data (eg. so they can
        -- report the issue).
        -- Meanwhile, if you ever need to debug JSON decode errors from session
        -- store, uncomment these lines.
        -- >> (\res ->
        --         case res of
        --             Ok r ->
        --                 Ok r
        --             Err err ->
        --                 let
        --                     _ =
        --                         Debug.log "deserializeStore error" err
        --                 in
        --                 Err err
        --    )
        >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0


updateStore : (Store -> Store) -> Session -> Session
updateStore update session =
    { session | store = update session.store }


loggedIn : Session -> List TextileProcess.Process -> List FoodProcess.Process -> Session
loggedIn ({ store } as session) textileProcesses foodProcesses =
    { session | store = { store | auth = LoggedIn textileProcesses foodProcesses } }


login : (Result String { textileProcesses : List TextileProcess.Process, foodProcesses : List FoodProcess.Process } -> msg) -> Cmd msg
login event =
    Task.attempt event
        (Task.map2
            (\textileProcesses foodProcesses -> { textileProcesses = textileProcesses, foodProcesses = foodProcesses })
            (getProcesses "data/textile/processes_impacts.json" TextileProcess.decodeList)
            (getProcesses "data/food/processes_impacts.json" FoodProcess.decodeList)
        )


getProcesses : String -> Decoder a -> Task.Task String a
getProcesses url decoder =
    Http.task
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , resolver =
            Http.stringResolver
                (\response ->
                    case response of
                        Http.GoodStatus_ _ stringBody ->
                            Decode.decodeString decoder stringBody
                                |> Result.mapError Decode.errorToString

                        _ ->
                            Err "Couldn't get the processes"
                )
        , timeout = Nothing
        }


logout : Session -> Session
logout ({ store } as session) =
    { session | store = { store | auth = NotLoggedIn } }


isLoggedIn : { a | store : Store } -> Bool
isLoggedIn { store } =
    case store.auth of
        LoggedIn _ _ ->
            True

        _ ->
            False
