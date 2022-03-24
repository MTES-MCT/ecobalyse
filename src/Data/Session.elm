module Data.Session exposing
    ( Notification(..)
    , SavedSimulation
    , Session
    , closeNotification
    , deleteSimulation
    , deserializeStore
    , notifyError
    , notifyHttpError
    , saveSimulation
    , serializeStore
    )

import Browser.Navigation as Nav
import Data.Db exposing (Db)
import Data.Inputs as Inputs
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Request.Version exposing (Version)


type alias Session =
    { navKey : Nav.Key
    , clientUrl : String
    , store : Store
    , currentVersion : Version
    , db : Db
    , notifications : List Notification
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



-- Store
--
-- A serializable data structure holding session information you want to share
-- across browser restarts, typically in localStorage.


type alias Store =
    { savedSimulations : List SavedSimulation
    }


type alias SavedSimulation =
    { name : String
    , query : Inputs.Query
    }


defaultStore : Store
defaultStore =
    { savedSimulations = [] }


decodeStore : Decoder Store
decodeStore =
    Decode.map Store
        (Decode.field "savedSimulations" <| Decode.list decodeSavedSimulation)


decodeSavedSimulation : Decoder SavedSimulation
decodeSavedSimulation =
    Decode.map2 SavedSimulation
        (Decode.field "name" Decode.string)
        (Decode.field "query" Inputs.decodeQuery)


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "savedSimulations", Encode.list encodeSavedSimulation store.savedSimulations )
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


deleteSimulation : SavedSimulation -> Session -> Session
deleteSimulation simulation =
    updateStore
        (\store ->
            { store
                | savedSimulations =
                    List.filter ((/=) simulation) store.savedSimulations
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
