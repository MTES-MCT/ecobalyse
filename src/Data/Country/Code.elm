module Data.Country.Code exposing
    ( Code(..)
    , decode
    , encode
    , fromString
    , toString
    , unknown
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Code
    = Code String


decode : Decoder Code
decode =
    Decode.map Code Decode.string


encode : Code -> Encode.Value
encode (Code string) =
    Encode.string string


fromString : String -> Code
fromString =
    Code


toString : Code -> String
toString (Code string) =
    string


unknown : Code
unknown =
    Code "---"
