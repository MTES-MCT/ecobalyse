module Data.Country.Code exposing
    ( Code
    , china
    , decode
    , encode
    , france
    , fromString
    , overseaFrance
    , toString
    , unknown
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Code
    = Code String


china : Code
china =
    fromString "CN"


decode : Decoder Code
decode =
    Decode.map Code Decode.string


encode : Code -> Encode.Value
encode =
    toString >> Encode.string


france : Code
france =
    fromString "FR"


fromString : String -> Code
fromString =
    Code


overseaFrance : Code
overseaFrance =
    fromString "ROF"


toString : Code -> String
toString (Code string) =
    string


unknown : Code
unknown =
    Code "---"
