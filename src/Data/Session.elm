module Data.Session exposing
    ( Notification(..)
    , Session
    , checkComparedSimulations
    , closeNotification
    , createFoodExample
    , createTextileExample
    , deleteBookmark
    , deserializeStore
    , notifyError
    , saveBookmark
    , selectAllBookmarks
    , selectNoBookmarks
    , serializeStore
    , toggleComparedSimulation
    , updateFoodExample
    , updateFoodQuery
    , updateTextileExample
    , updateTextileQuery
    )

import Browser.Navigation as Nav
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Example exposing (Example)
import Data.Food.Db as FoodDb
import Data.Food.Query as FoodQuery
import Data.Textile.Db as TextileDb
import Data.Textile.Query as TextileQuery
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Request.Version exposing (Version)
import Set exposing (Set)
import Static.Db as Db exposing (Db)


type alias Session =
    { db : Db
    , github : { repository : String, branch : String }
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



-- Example products


createFoodExample : Example FoodQuery.Query -> Session -> Session
createFoodExample example =
    updateFoodDb
        (\({ examples } as food) ->
            { food | examples = example :: examples }
        )


createTextileExample : Example TextileQuery.Query -> Session -> Session
createTextileExample example =
    updateTextileDb
        (\({ examples } as textile) ->
            { textile | examples = example :: examples }
        )


updateFoodDb : (FoodDb.Db -> FoodDb.Db) -> Session -> Session
updateFoodDb update ({ db } as session) =
    { session | db = Db.updateFoodDb update db }


updateTextileDb : (TextileDb.Db -> TextileDb.Db) -> Session -> Session
updateTextileDb update ({ db } as session) =
    { session | db = Db.updateTextileDb update db }


updateFoodExample : Example FoodQuery.Query -> Session -> Session
updateFoodExample updated =
    updateFoodDb
        (\({ examples } as foodDb) ->
            { foodDb
                | examples =
                    examples
                        |> List.map
                            (\example ->
                                if example.id == updated.id then
                                    updated

                                else
                                    example
                            )
            }
        )


updateTextileExample : Example TextileQuery.Query -> Session -> Session
updateTextileExample updated =
    updateTextileDb
        (\({ examples } as textileDb) ->
            { textileDb
                | examples =
                    examples
                        |> List.map
                            (\example ->
                                if example.id == updated.id then
                                    updated

                                else
                                    example
                            )
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
    }


defaultStore : Store
defaultStore =
    { comparedSimulations = Set.empty
    , bookmarks = []
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty
        |> JDP.optional "bookmarks" (Decode.list Bookmark.decode) []


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "comparedSimulations", store.comparedSimulations |> Set.toList |> Encode.list Encode.string )
        , ( "bookmarks", Encode.list Bookmark.encode store.bookmarks )
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
