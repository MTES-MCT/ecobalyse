module Data.Session exposing (..)

import Browser.Navigation as Nav
import Data.Db exposing (Db)
import Data.Inputs as Inputs exposing (Inputs)
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


notifyError : String -> String -> Session -> Session
notifyError title error session =
    { session | notifications = session.notifications ++ [ GenericError title error ] }


notifyHttpError : String -> Http.Error -> Session -> Session
notifyHttpError title error session =
    { session | notifications = session.notifications ++ [ HttpError title error ] }



-- Store


{-| A serializable data structure holding session information you want to share
across browser restarts, typically in localStorage.
-}
type alias Store =
    { inputs : Inputs }


defaultStore : Store
defaultStore =
    { inputs = Inputs.default }


decodeStore : Decoder Store
decodeStore =
    Decode.map Store
        (Decode.field "mass" Inputs.decode)


encodeStore : Store -> Encode.Value
encodeStore v =
    Encode.object
        [ ( "simulator", Inputs.encode v.inputs )
        ]


deserializeStore : String -> Store
deserializeStore =
    Decode.decodeString decodeStore >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0
