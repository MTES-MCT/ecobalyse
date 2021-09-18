module Data.Session exposing
    ( Session
    , Store
    , deserializeStore
    , serializeStore
    )

import Browser.Navigation as Nav
import Data.Inputs as Inputs exposing (Inputs)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Session =
    { navKey : Nav.Key
    , clientUrl : String
    , store : Store
    }


{-| A serializable data structure holding session information you want to share
across browser restarts, typically in localStorage.
-}
type alias Store =
    { inputs : Inputs }


defaultStore : Store
defaultStore =
    { inputs = Inputs.defaults }


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
