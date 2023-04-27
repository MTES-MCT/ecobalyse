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


getMakingComplexity : Maybe MakingComplexity -> MakingComplexity -> Knitting -> MakingComplexity
getMakingComplexity makingComplexity productDefaultMakingComplexity knitting =
    let
        defaultMakingComplexity =
            makingComplexity
                |> Maybe.withDefault productDefaultMakingComplexity
    in
    case knitting of
        FullyFashioned ->
            MakingComplexity.VeryLow

        Seamless ->
            MakingComplexity.NotApplicable

        _ ->
            defaultMakingComplexity


getMakingWaste : Maybe Split -> Split -> Knitting -> Split
getMakingWaste makingWaste productDefaultWaste knitting =
    let
        defaultWaste =
            makingWaste
                |> Maybe.withDefault productDefaultWaste
    in
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
