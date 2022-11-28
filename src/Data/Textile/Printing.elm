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

import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Kind
    = Pigment
    | Substantive


type alias Printing =
    { kind : Kind
    , ratio : Unit.Ratio
    }


decode : Decoder Printing
decode =
    Decode.map2 Printing
        (Decode.field "kind" decodeKind)
        (Decode.field "ratio" Unit.decodeRatio)


decodeKind : Decoder Kind
decodeKind =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


defaultRatio : Unit.Ratio
defaultRatio =
    Unit.ratio 0.2


encode : Printing -> Encode.Value
encode v =
    Encode.object
        [ ( "kind", encodeKind v.kind )
        , ( "ratio", Unit.encodeRatio v.ratio )
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
                        Ok (Unit.ratio float)

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
    kindLabel kind ++ " (" ++ String.fromInt (round (Unit.ratioToFloat ratio * 100)) ++ "%)"


toString : Kind -> String
toString printing =
    case printing of
        Pigment ->
            "pigment"

        Substantive ->
            "substantive"
