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
    , saveSimulation
    , serializeStore
    , toggleComparedSimulation
    )

import Browser.Navigation as Nav
import Data.Db exposing (Db)
import Data.Ecobalyse.Db as Ecobalyse
import Data.Inputs as Inputs
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
    , ecobalyseDb : Ecobalyse.Db
    , notifications : List Notification
    , query : Inputs.Query
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



-- Saved simulations


type alias SavedSimulation =
    { name : String
    , query : Inputs.Query
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
    { savedSimulations : List SavedSimulation
    , comparedSimulations : Set String
    }


defaultStore : Store
defaultStore =
    { savedSimulations = []
    , comparedSimulations = Set.empty
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> JDP.optional "savedSimulations" (Decode.list decodeSavedSimulation) []
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty


decodeSavedSimulation : Decoder SavedSimulation
decodeSavedSimulation =
    Decode.map2 SavedSimulation
        (Decode.field "name" Decode.string)
        (Decode.field "query" Inputs.decodeQuery)


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "savedSimulations", Encode.list encodeSavedSimulation store.savedSimulations )
        , ( "comparedSimulations", store.comparedSimulations |> Set.toList |> Encode.list Encode.string )
        ]


encodeSavedSimulation : SavedSimulation -> Encode.Value
encodeSavedSimulation { name, query } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "query", Inputs.encodeQuery query )
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
