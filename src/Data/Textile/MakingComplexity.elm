module Data.Textile.MakingComplexity exposing
    ( MakingComplexity(..)
    , decode
    , fromString
    , toDuration
    , toLabel
    , toString
    )

import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type MakingComplexity
    = High
    | Low
    | Medium
    | NotApplicable
    | VeryHigh
    | VeryLow


toDuration : MakingComplexity -> Duration
toDuration makingComplexity =
    case makingComplexity of
        High ->
            Duration.minutes 60

        Low ->
            Duration.minutes 15

        Medium ->
            Duration.minutes 30

        NotApplicable ->
            Duration.minutes 0

        VeryHigh ->
            Duration.minutes 120

        VeryLow ->
            Duration.minutes 5


toLabel : MakingComplexity -> String
toLabel makingComplexity =
    case makingComplexity of
        High ->
            "Elevée"

        Low ->
            "Faible"

        Medium ->
            "Moyenne"

        NotApplicable ->
            "Non applicable"

        VeryHigh ->
            "Très élevée"

        VeryLow ->
            "Très faible"


toString : MakingComplexity -> String
toString makingComplexity =
    case makingComplexity of
        High ->
            "high"

        Low ->
            "low"

        Medium ->
            "medium"

        NotApplicable ->
            "non-applicable"

        VeryHigh ->
            "very-high"

        VeryLow ->
            "very-low"


fromString : String -> Result String MakingComplexity
fromString str =
    case str of
        "high" ->
            Ok High

        "low" ->
            Ok Low

        "medium" ->
            Ok Medium

        "not-applicable" ->
            Ok NotApplicable

        "very-high" ->
            Ok VeryHigh

        "very-low" ->
            Ok VeryLow

        _ ->
            Err ("Type de complexité de fabrication inconnu\u{00A0}: " ++ str)


decode : Decoder MakingComplexity
decode =
    Decode.string
        |> Decode.andThen
            (\complexityStr ->
                DE.fromResult (fromString complexityStr)
            )
