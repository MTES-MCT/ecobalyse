module Data.Textile.Knitting exposing
    ( Knitting(..)
    , decode
    , encode
    , fromString
    , getMakingWaste
    , toLabel
    , toString
    )

import Data.Split as Split exposing (Split)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Knitting
    = Circular
    | FullyFashioned
    | Mix
    | Seamless
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

        "seamless" ->
            Ok Seamless

        "circular" ->
            Ok Circular

        "straight" ->
            Ok Straight

        _ ->
            Err <| "Procédé de tricotage inconnu: " ++ string


getMakingWaste : Split -> Knitting -> Split
getMakingWaste defaultWaste knitting =
    case knitting of
        FullyFashioned ->
            Split.fromFloat 0.02
                |> Result.toMaybe
                |> Maybe.withDefault defaultWaste

        Seamless ->
            Split.fromFloat 0
                |> Result.toMaybe
                |> Maybe.withDefault defaultWaste

        _ ->
            defaultWaste


toLabel : Knitting -> String
toLabel knittingProcess =
    case knittingProcess of
        Mix ->
            "Tricotage moyen (par défaut)"

        FullyFashioned ->
            "Fully fashioned"

        Seamless ->
            "Seamless"

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

        Seamless ->
            "seamless"

        Circular ->
            "circular"

        Straight ->
            "straight"
