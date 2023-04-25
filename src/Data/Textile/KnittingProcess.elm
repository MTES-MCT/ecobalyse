module Data.Textile.KnittingProcess exposing
    ( KnittingProcess(..)
    , decode
    , encode
    , fromString
    , toLabel
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type KnittingProcess
    = Mix
    | FullyFashioned
    | Seamless
    | Circular
    | Straight


decode : Decoder KnittingProcess
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : KnittingProcess -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String KnittingProcess
fromString string =
    case string of
        "knitting-mix" ->
            Ok Mix

        "knitting-fully-fashioned" ->
            Ok FullyFashioned

        "knitting-seamless" ->
            Ok Seamless

        "knitting-circular" ->
            Ok Circular

        "knitting-straight" ->
            Ok Straight

        _ ->
            Err <| "Procédé de tricotage inconnu: " ++ string


toLabel : KnittingProcess -> String
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


toString : KnittingProcess -> String
toString knittingProcess =
    case knittingProcess of
        Mix ->
            "knitting-mix"

        FullyFashioned ->
            "knitting-fully-fashioned"

        Seamless ->
            "knitting-seamless"

        Circular ->
            "knitting-circular"

        Straight ->
            "knitting-straight"
