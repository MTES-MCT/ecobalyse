module Data.Uuid exposing
    ( Uuid
    , decoder
    , encoder
    , fromString
    , toString
    )

import Json.Decode exposing (Decoder)
import Json.Encode as Encode
import Prng.Uuid as Uuid


type alias Uuid =
    Uuid.Uuid


decoder : Decoder Uuid
decoder =
    Uuid.decoder


encoder : Uuid -> Encode.Value
encoder =
    Uuid.encode


fromString : String -> Result String Uuid
fromString =
    Uuid.fromString
        >> Result.fromMaybe "UUIDinvalide"


toString : Uuid -> String
toString =
    Uuid.toString
