module Data.Session exposing
    ( Notification(..)
    , Session
    , closeNotification
    , deserializeStore
    , notifyError
    , notifyHttpError
    , serializeStore
    )

import Browser.Navigation as Nav
import Data.Db exposing (Db)
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
    , link : String
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
        (Decode.field "link" Decode.string)


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "savedSimulations", Encode.list encodeSavedSimulation store.savedSimulations )
        ]


encodeSavedSimulation : SavedSimulation -> Encode.Value
encodeSavedSimulation { name, link } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "link", Encode.string link )
        ]


deserializeStore : String -> Store
deserializeStore =
    Decode.decodeString decodeStore >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0
