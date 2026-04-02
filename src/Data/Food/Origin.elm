module Data.Food.Origin exposing
    ( Origin
    , all
    , decode
    , fromCode
    , toCode
    , toLabel
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = FR
    | OI
    | RAF
    | RAS
    | REM
    | REO
    | RLA
    | RME
    | RNA
    | ROC


decode : Decoder Origin
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String Origin
fromString string =
    case string of
        "FR" ->
            Ok FR

        "REM" ->
            Ok REM

        "REO" ->
            Ok REO

        "RAS" ->
            Ok RAS

        "RAF" ->
            Ok RAF

        "RME" ->
            Ok RME

        "RLA" ->
            Ok RLA

        "RNA" ->
            Ok RNA

        "ROC" ->
            Ok ROC

        "OI" ->
            Ok OI

        _ ->
            Err <| "Origine géographique inconnue : " ++ string


all : List Origin
all =
    [ FR, OI, RAF, RAS, REM, REO, RLA, RME, RNA, ROC ]


fromCode : String -> Maybe Origin
fromCode =
    fromString >> Result.toMaybe


toCode : Origin -> String
toCode origin =
    case origin of
        FR ->
            "FR"

        OI ->
            "OI"

        RAF ->
            "RAF"

        RAS ->
            "RAS"

        REM ->
            "REM"

        REO ->
            "REO"

        RLA ->
            "RLA"

        RME ->
            "RME"

        RNA ->
            "RNA"

        ROC ->
            "ROC"


toLabel : Origin -> String
toLabel origin =
    case origin of
        FR ->
            "France"

        OI ->
            "Origine inconnue"

        RAF ->
            "Afrique"

        RAS ->
            "Asie"

        REM ->
            "Europe et Maghreb"

        REO ->
            "Europe de l'Ouest"

        RLA ->
            "Amérique Latine"

        RME ->
            "Moyen-Orient"

        RNA ->
            "Amérique du Nord"

        ROC ->
            "Océanie"
