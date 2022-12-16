module Data.Session exposing
    ( Notification(..)
    , Session
    , checkComparedSimulations
    , closeNotification
    , deleteBookmark
    , deserializeStore
    , maxComparedSimulations
    , notifyError
    , notifyHttpError
    , saveBookmark
    , serializeStore
    , toggleComparedSimulation
    , updateFoodQuery
    , updateTextileQuery
    )

import Browser.Navigation as Nav
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Builder.Db as BuilderDb
import Data.Food.Builder.Query as FoodQuery
import Data.Food.Explorer.Db as ExplorerDb
import Data.Textile.Db exposing (Db)
import Data.Textile.Inputs as TextileInputs
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Request.Version exposing (Version)
import Set exposing (Set)
import Time


type alias Session =
    { navKey : Nav.Key
    , clientUrl : String
    , store : Store
    , currentVersion : Version
    , db : Db
    , builderDb : BuilderDb.Db
    , explorerDb : ExplorerDb.Db
    , notifications : List Notification
    , queries :
        { food : FoodQuery.Query
        , textile : TextileInputs.Query
        }
    }



-- Notifications


type Notification
    = HttpError Http.Error
    | GenericError String String


closeNotification : Notification -> Session -> Session
closeNotification notification ({ notifications } as session) =
    { session | notifications = notifications |> List.filter ((/=) notification) }


notifyError : String -> String -> Session -> Session
notifyError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericError title error ] }


notifyHttpError : Http.Error -> Session -> Session
notifyHttpError error ({ notifications } as session) =
    { session | notifications = notifications ++ [ HttpError error ] }



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


updateTextileQuery : TextileInputs.Query -> Session -> Session
updateTextileQuery textileQuery ({ queries } as session) =
    { session | queries = { queries | textile = textileQuery } }



-- Comparator


maxComparedSimulations : Int
maxComparedSimulations =
    12


checkComparedSimulations : Session -> Session
checkComparedSimulations =
    updateStore
        (\({ bookmarks, comparedSimulations } as store) ->
            { store
                | comparedSimulations =
                    if Set.size comparedSimulations == 0 then
                        -- Add max bookmarks to compared sims
                        bookmarks
                            |> List.sortBy (.created >> Time.posixToMillis)
                            |> List.reverse
                            |> List.take maxComparedSimulations
                            |> List.map .name
                            |> Set.fromList

                    else
                        -- Purge deleted bookmarks from compared sims
                        comparedSimulations
                            |> Set.filter
                                (\name ->
                                    bookmarks
                                        |> List.map .name
                                        |> List.member name
                                )
            }
        )


toggleComparedSimulation : String -> Bool -> Session -> Session
toggleComparedSimulation name checked =
    updateStore
        (\store ->
            { store
                | comparedSimulations =
                    if checked then
                        Set.insert name store.comparedSimulations

                    else
                        Set.remove name store.comparedSimulations
            }
        )



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
    Decode.decodeString decodeStore >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0


updateStore : (Store -> Store) -> Session -> Session
updateStore update session =
    { session | store = update session.store }
