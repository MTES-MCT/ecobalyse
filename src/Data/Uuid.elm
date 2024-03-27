module Data.Uuid exposing
    ( Uuid
    , decoder
    , fromString
    , toString
    )

import Json.Decode exposing (Decoder)
import Prng.Uuid as Uuid


type alias Uuid =
    Uuid.Uuid


decoder : Decoder Uuid
decoder =
    Uuid.decoder


fromString : String -> Maybe Uuid
fromString =
    Uuid.fromString


toString : Uuid -> String
toString =
    Uuid.toString
