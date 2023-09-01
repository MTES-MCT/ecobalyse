module Data.Textile.HeatSource exposing
    ( HeatSource(..)
    , decode
    , encode
    , fromString
    , toLabelWithZone
    , toString
    )

import Data.Zone as Zone exposing (Zone)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type HeatSource
    = NaturalGas
    | Other


decode : Decoder HeatSource
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : HeatSource -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String HeatSource
fromString string =
    case string of
        "other" ->
            Ok Other

        "coal" ->
            Ok Other

        "heavyfuel" ->
            Ok Other

        "lightfuel" ->
            Ok Other

        "naturalgas" ->
            Ok NaturalGas

        _ ->
            Err <| "Source de production de vapeur inconnue: " ++ string


toLabel : HeatSource -> String
toLabel source =
    case source of
        Other ->
            "Autre"

        NaturalGas ->
            "Gaz naturel"


toLabelWithZone : Zone -> HeatSource -> String
toLabelWithZone zone heatSource =
    let
        zoneLabel =
            case zone of
                Zone.Europe ->
                    " (Europe)"

                _ ->
                    " (hors Europe)"
    in
    toLabel heatSource ++ zoneLabel


toString : HeatSource -> String
toString source =
    case source of
        Other ->
            "other"

        NaturalGas ->
            "naturalgas"
