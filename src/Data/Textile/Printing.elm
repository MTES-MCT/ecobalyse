module Data.Textile.Printing exposing
    ( Printing(..)
    , decode
    , encode
    , fromString
    , toLabel
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Printing
    = Pigment
    | Substantive


decode : Decoder Printing
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : Printing -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String Printing
fromString string =
    case string of
        "pigment" ->
            Ok Pigment

        "substantive" ->
            Ok Substantive

        _ ->
            Err <| "Type d'impression inconnu: " ++ string


toLabel : Printing -> String
toLabel printing =
    case printing of
        Pigment ->
            "Pigmentaire"

        Substantive ->
            "Fixé-lavé"


toString : Printing -> String
toString printing =
    case printing of
        Pigment ->
            "pigment"

        Substantive ->
            "substantive"
