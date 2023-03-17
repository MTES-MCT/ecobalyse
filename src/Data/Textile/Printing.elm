module Data.Textile.Printing exposing
    ( Kind(..)
    , Printing
    , decode
    , defaultRatio
    , encode
    , fromString
    , fromStringParam
    , kindLabel
    , toFullLabel
    , toString
    )

import Data.Split as Split exposing (Split)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
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
    Decode.map2 Printing
        (Decode.field "kind" decodeKind)
        (Decode.field "ratio" Split.decode)


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
        , ( "ratio", Split.encode v.ratio )
        ]


encodeKind : Kind -> Encode.Value
encodeKind =
    toString >> Encode.string


fromStringParam : String -> Result String Printing
fromStringParam string =
    let
        toRatio s =
            case String.toFloat s of
                Just float ->
                    if float > 0 && float <= 1 then
                        Split.fromFloat float

                    else
                        Err "Le ratio de surface d'impression doit être supérieur à zéro et inférieur à 1."

                Nothing ->
                    Err <| "Ratio de surface teinte invalide: " ++ s
    in
    case String.split ";" string of
        [ "pigment" ] ->
            Ok { kind = Pigment, ratio = defaultRatio }

        [ "substantive" ] ->
            Ok { kind = Substantive, ratio = defaultRatio }

        [ "pigment", str ] ->
            str |> toRatio |> Result.map (Printing Pigment)

        [ "substantive", str ] ->
            str |> toRatio |> Result.map (Printing Substantive)

        _ ->
            Err <| "Format de type et surface d'impression invalide: " ++ string


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
    kindLabel kind ++ " (" ++ Split.toPercentString ratio ++ "%)"


toString : Kind -> String
toString printing =
    case printing of
        Pigment ->
            "pigment"

        Substantive ->
            "substantive"
