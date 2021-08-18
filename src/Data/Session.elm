module Data.Session exposing
    ( Session
    , Store
    , deserializeStore
    , serializeStore
    )

import Browser.Navigation as Nav
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
    { mass : Float }


defaultStore : Store
defaultStore =
    { mass = 0.2 }


decodeStore : Decoder Store
decodeStore =
    Decode.map Store
        (Decode.field "mass" Decode.float)


encodeStore : Store -> Encode.Value
encodeStore v =
    Encode.object
        [ ( "mass", Encode.float v.mass )
        ]


deserializeStore : String -> Store
deserializeStore =
    Decode.decodeString decodeStore >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0
