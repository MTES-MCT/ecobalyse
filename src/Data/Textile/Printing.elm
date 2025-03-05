module Data.Textile.Printing exposing
    ( Kind(..)
    , Printing
    , decode
    , defaultRatio
    , encode
    , fromString
    , kindLabel
    , toFullLabel
    , toString
    )

import Data.Split as Split exposing (Split)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type Kind
    = Pigment
    | Substantive


type alias Printing =
    { kind : Kind
    , ratio : Split
    }


decode : Decoder Printing
decode =
    Decode.succeed Printing
        |> JDP.required "kind" decodeKind
        |> JDP.optional "ratio" Split.decodeFloat defaultRatio


decodeKind : Decoder Kind
decodeKind =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


defaultRatio : Split
defaultRatio =
    Split.twenty


encode : Printing -> Encode.Value
encode v =
    Encode.object
        [ ( "kind", encodeKind v.kind )
        , ( "ratio", Split.encodeFloat v.ratio )
        ]


encodeKind : Kind -> Encode.Value
encodeKind =
    toString >> Encode.string


fromString : String -> Result String Kind
fromString string =
    case string of
        "pigment" ->
            Ok Pigment

        "substantive" ->
            Ok Substantive

        _ ->
            Err <| "Type d'impression inconnu: " ++ string


kindLabel : Kind -> String
kindLabel kind =
    case kind of
        Pigment ->
            "Pigmentaire"

        Substantive ->
            "Fixé-lavé"


toFullLabel : Printing -> String
toFullLabel { kind, ratio } =
    kindLabel kind ++ " (" ++ Split.toPercentString 0 ratio ++ "%)"


toString : Kind -> String
toString printing =
    case printing of
        Pigment ->
            "pigment"

        Substantive ->
            "substantive"
