module Data.Food.IngredientID exposing
    ( ID
    , decode
    , encode
    , fromString
    , toString
    )

import Json.Decode as Decode
import Json.Encode as Encode


type ID
    = ID String


decode : Decode.Decoder ID
decode =
    Decode.string
        |> Decode.map fromString


encode : ID -> Encode.Value
encode (ID str) =
    Encode.string str


fromString : String -> ID
fromString str =
    ID str


toString : ID -> String
toString (ID str) =
    str
