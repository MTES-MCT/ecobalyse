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
    = VeryHigh
    | High
    | Medium
    | Low
    | VeryLow
    | NotApplicable


toDuration : MakingComplexity -> Duration
toDuration makingComplexity =
    case makingComplexity of
        VeryHigh ->
            Duration.minutes 120

        High ->
            Duration.minutes 60

        Medium ->
            Duration.minutes 30

        Low ->
            Duration.minutes 15

        VeryLow ->
            Duration.minutes 5

        NotApplicable ->
            Duration.minutes 0


toLabel : MakingComplexity -> String
toLabel makingComplexity =
    case makingComplexity of
        VeryHigh ->
            "Très élevée"

        High ->
            "Elevée"

        Medium ->
            "Moyenne"

        Low ->
            "Faible"

        VeryLow ->
            "Très faible"

        NotApplicable ->
            "Non applicable"


toString : MakingComplexity -> String
toString makingComplexity =
    case makingComplexity of
        VeryHigh ->
            "very-high"

        High ->
            "high"

        Medium ->
            "medium"

        Low ->
            "low"

        VeryLow ->
            "very-low"

        NotApplicable ->
            "non-applicable"


fromString : String -> Result String MakingComplexity
fromString str =
    case str of
        "very-high" ->
            Ok VeryHigh

        "high" ->
            Ok High

        "medium" ->
            Ok Medium

        "low" ->
            Ok Low

        "very-low" ->
            Ok VeryLow

        "not-applicable" ->
            Ok NotApplicable

        _ ->
            Err ("Type de complexité de fabrication inconnu\u{00A0}: " ++ str)


decode : Decoder MakingComplexity
decode =
    Decode.string
        |> Decode.andThen
            (\complexityStr ->
                DE.fromResult (fromString complexityStr)
            )
