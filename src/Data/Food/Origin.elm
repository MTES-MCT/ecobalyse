module Data.Food.Origin exposing
    ( Origin(..)
    , decode
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


toCode : Origin -> String
toCode origin =
    case origin of
        FR ->
            "FR"

        REM ->
            "REM"

        REO ->
            "REO"

        RAS ->
            "RAS"

        RAF ->
            "RAF"

        RME ->
            "RME"

        RLA ->
            "RLA"

        RNA ->
            "RNA"

        ROC ->
            "ROC"

        OI ->
            "OI"


toLabel : Origin -> String
toLabel origin =
    case origin of
        FR ->
            "France"

        REM ->
            "Europe et Maghreb"

        REO ->
            "Europe de l'Ouest"

        RAS ->
            "Asie"

        RAF ->
            "Afrique"

        RME ->
            "Moyen-Orient"

        RLA ->
            "Amérique Latine"

        RNA ->
            "Amérique du Nord"

        ROC ->
            "Océanie"

        OI ->
            "Origine inconnue"
