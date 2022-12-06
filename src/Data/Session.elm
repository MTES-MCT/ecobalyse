module Data.Session exposing
    ( Notification(..)
    , SavedSimulation
    , Session
    , checkComparedSimulations
    , closeNotification
    , deleteSimulation
    , deserializeStore
    , maxComparedSimulations
    , notifyError
    , notifyHttpError
    , saveRecipe
    , saveSimulation
    , serializeStore
    , toggleComparedSimulation
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


type alias Session =
    { navKey : Nav.Key
    , clientUrl : String
    , store : Store
    , currentVersion : Version
    , db : Db
    , builderDb : BuilderDb.Db
    , explorerDb : ExplorerDb.Db
    , notifications : List Notification
    , query : TextileInputs.Query
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



-- Saved food recipes


type alias SavedRecipe =
    { name : String
    , query : FoodQuery.Query
    }


saveRecipe : SavedRecipe -> Session -> Session
saveRecipe recipe =
    updateStore
        (\store ->
            { store
                | savedRecipes =
                    recipe :: store.savedRecipes
            }
        )



-- Saved textile simulations


type alias SavedSimulation =
    { name : String
    , query : TextileInputs.Query
    }


maxComparedSimulations : Int
maxComparedSimulations =
    12


checkComparedSimulations : Session -> Session
checkComparedSimulations session =
    if Set.size session.store.comparedSimulations == 0 then
        session
            |> updateStore
                (\store ->
                    { store
                        | comparedSimulations =
                            store.savedSimulations
                                |> List.take maxComparedSimulations
                                |> List.map .name
                                |> Set.fromList
                    }
                )

    else
        session


deleteSimulation : SavedSimulation -> Session -> Session
deleteSimulation simulation =
    updateStore
        (\store ->
            { store
                | savedSimulations =
                    List.filter ((/=) simulation) store.savedSimulations
                , comparedSimulations =
                    Set.filter ((/=) simulation.name) store.comparedSimulations
            }
        )


saveSimulation : SavedSimulation -> Session -> Session
saveSimulation simulation =
    updateStore
        (\store ->
            { store
                | savedSimulations =
                    simulation :: store.savedSimulations
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
    { savedRecipes : List SavedRecipe
    , savedSimulations : List SavedSimulation
    , comparedSimulations : Set String
    , bookmarks : List Bookmark
    }


defaultStore : Store
defaultStore =
    { savedRecipes = []
    , savedSimulations = []
    , comparedSimulations = Set.empty
    , bookmarks = []
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> JDP.optional "savedRecipes" (Decode.list decodeSavedRecipes) []
        |> JDP.optional "savedSimulations" (Decode.list decodeSavedSimulation) []
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty
        |> JDP.optional "bookmarks" (Decode.list Bookmark.decode) []


decodeSavedRecipes : Decoder SavedRecipe
decodeSavedRecipes =
    Decode.map2 SavedRecipe
        (Decode.field "name" Decode.string)
        (Decode.field "query" FoodQuery.decode)


decodeSavedSimulation : Decoder SavedSimulation
decodeSavedSimulation =
    Decode.map2 SavedSimulation
        (Decode.field "name" Decode.string)
        (Decode.field "query" TextileInputs.decodeQuery)


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "savedRecipes", Encode.list encodeSavedRecipe store.savedRecipes )
        , ( "savedSimulations", Encode.list encodeSavedSimulation store.savedSimulations )
        , ( "comparedSimulations", store.comparedSimulations |> Set.toList |> Encode.list Encode.string )
        , ( "bookmarks", Encode.list Bookmark.encode store.bookmarks )
        ]


encodeSavedRecipe : SavedRecipe -> Encode.Value
encodeSavedRecipe { name, query } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "query", FoodQuery.encode query )
        ]


encodeSavedSimulation : SavedSimulation -> Encode.Value
encodeSavedSimulation { name, query } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "query", TextileInputs.encodeQuery query )
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
