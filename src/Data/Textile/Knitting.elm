module Data.Textile.Knitting exposing
    ( Knitting(..)
    , decode
    , encode
    , fromString
    , getMakingComplexity
    , getMakingWaste
    , toLabel
    , toString
    )

import Data.Split as Split exposing (Split)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Knitting
    = Circular
    | FullyFashioned
    | Mix
    | Integral
    | Straight


decode : Decoder Knitting
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : Knitting -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String Knitting
fromString string =
    case string of
        "mix" ->
            Ok Mix

        "fully-fashioned" ->
            Ok FullyFashioned

        "integral" ->
            Ok Integral

        "circular" ->
            Ok Circular

        "straight" ->
            Ok Straight

        _ ->
            Err <| "Procédé de tricotage inconnu: " ++ string


getMakingComplexity : MakingComplexity -> Knitting -> MakingComplexity
getMakingComplexity productDefaultMakingComplexity knitting =
    case knitting of
        FullyFashioned ->
            MakingComplexity.VeryLow

        Integral ->
            MakingComplexity.NotApplicable

        _ ->
            productDefaultMakingComplexity


getMakingWaste : Split -> Knitting -> Split
getMakingWaste productDefaultWaste knitting =
    case knitting of
        FullyFashioned ->
            Split.fromFloat 0.02
                |> Result.toMaybe
                |> Maybe.withDefault productDefaultWaste

        Integral ->
            Split.fromFloat 0
                |> Result.toMaybe
                |> Maybe.withDefault productDefaultWaste

        _ ->
            productDefaultWaste


toLabel : Knitting -> String
toLabel knittingProcess =
    case knittingProcess of
        Mix ->
            "Tricotage moyen (par défaut)"

        FullyFashioned ->
            "Fully fashioned / Seamless"

        Integral ->
            "Intégral / Whole garment"

        Circular ->
            "Circulaire"

        Straight ->
            "Rectiligne"


toString : Knitting -> String
toString knittingProcess =
    case knittingProcess of
        Mix ->
            "mix"

        FullyFashioned ->
            "fully-fashioned"

        Integral ->
            "integral"

        Circular ->
            "circular"

        Straight ->
            "straight"
