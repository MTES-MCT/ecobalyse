module Data.Textile.Fabric exposing
    ( Fabric(..)
    , decode
    , default
    , encode
    , fabricProcesses
    , fromString
    , getMakingComplexity
    , getMakingWaste
    , getProcess
    , isKnitted
    , toLabel
    , toString
    )

import Data.Split as Split exposing (Split)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Process exposing (Process)
import Data.Textile.WellKnown exposing (WellKnown)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Fabric
    = Weaving
    | KnittingCircular
    | KnittingFullyFashioned
    | KnittingMix
    | KnittingIntegral
    | KnittingStraight


decode : Decoder Fabric
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : Fabric -> Encode.Value
encode =
    toString >> Encode.string


default : Fabric
default =
    KnittingMix


fabricProcesses : List Fabric
fabricProcesses =
    [ KnittingMix
    , KnittingFullyFashioned
    , KnittingIntegral
    , KnittingCircular
    , KnittingStraight
    , Weaving
    ]


fromString : String -> Result String Fabric
fromString string =
    case string of
        "knitting-mix" ->
            Ok KnittingMix

        "knitting-fully-fashioned" ->
            Ok KnittingFullyFashioned

        "knitting-integral" ->
            Ok KnittingIntegral

        "knitting-circular" ->
            Ok KnittingCircular

        "knitting-straight" ->
            Ok KnittingStraight

        "weaving" ->
            Ok Weaving

        _ ->
            Err <| "Procédé de tissage/tricotage inconnu: " ++ string


getMakingComplexity : MakingComplexity -> Fabric -> MakingComplexity
getMakingComplexity productDefaultMakingComplexity fabric =
    case fabric of
        KnittingFullyFashioned ->
            MakingComplexity.VeryLow

        KnittingIntegral ->
            MakingComplexity.NotApplicable

        _ ->
            productDefaultMakingComplexity


getMakingWaste : Split -> Fabric -> Split
getMakingWaste productDefaultWaste fabric =
    case fabric of
        KnittingFullyFashioned ->
            Split.fromFloat 0.02
                |> Result.toMaybe
                |> Maybe.withDefault productDefaultWaste

        KnittingIntegral ->
            Split.fromFloat 0
                |> Result.toMaybe
                |> Maybe.withDefault productDefaultWaste

        _ ->
            productDefaultWaste


getProcess : WellKnown -> Fabric -> Process
getProcess wellKnown fabric =
    case fabric of
        KnittingMix ->
            wellKnown.knittingMix

        KnittingFullyFashioned ->
            wellKnown.knittingFullyFashioned

        KnittingIntegral ->
            wellKnown.knittingSeamless

        KnittingCircular ->
            wellKnown.knittingCircular

        KnittingStraight ->
            wellKnown.knittingStraight

        Weaving ->
            wellKnown.weaving


isKnitted : Fabric -> Bool
isKnitted fabric =
    case fabric of
        Weaving ->
            False

        _ ->
            True


toLabel : Fabric -> String
toLabel fabricProcess =
    case fabricProcess of
        KnittingMix ->
            "Tricotage moyen (par défaut)"

        KnittingFullyFashioned ->
            "Tricotage Fully fashioned / Seamless"

        KnittingIntegral ->
            "Tricotage Intégral / Whole garment"

        KnittingCircular ->
            "Tricotage Circulaire"

        KnittingStraight ->
            "Tricotage Rectiligne"

        Weaving ->
            "Tissage"


toString : Fabric -> String
toString fabricProcess =
    case fabricProcess of
        KnittingMix ->
            "knitting-mix"

        KnittingFullyFashioned ->
            "knitting-fully-fashioned"

        KnittingIntegral ->
            "knitting-integral"

        KnittingCircular ->
            "knitting-circular"

        KnittingStraight ->
            "knitting-straight"

        Weaving ->
            "weaving"
