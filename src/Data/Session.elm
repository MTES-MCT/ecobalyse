module Data.Session exposing (..)

import Browser.Navigation as Nav
import Data.Db exposing (Db)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Session =
    { navKey : Nav.Key
    , clientUrl : String
    , store : Store
    , db : Db
    , notifications : List Notification
    }



-- Notifications


type Notification
    = HttpError String Http.Error
    | GenericError String String


clearNotifications : Session -> Session
clearNotifications session =
    { session | notifications = [] }


notifyError : String -> String -> Session -> Session
notifyError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericError title error ] }


notifyHttpError : String -> Http.Error -> Session -> Session
notifyHttpError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ HttpError title error ] }



-- Store


{-| A serializable data structure holding session information you want to share
across browser restarts, typically in localStorage.
-}
type alias Store =
    {}


defaultStore : Store
defaultStore =
    {}


decodeStore : Decoder Store
decodeStore =
    Decode.succeed {}


encodeStore : Store -> Encode.Value
encodeStore _ =
    Encode.object []


deserializeStore : String -> Store
deserializeStore =
    Decode.decodeString decodeStore >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0
