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


getMakingComplexity : MakingComplexity -> Maybe MakingComplexity -> Maybe Fabric -> MakingComplexity
getMakingComplexity defaultComplexity maybeCustomComplexity maybeFabric =
    case ( maybeFabric, maybeCustomComplexity ) of
        ( _, Just customComplexity ) ->
            -- A custom complexity is provided: always takes priority
            customComplexity

        ( Just fabric, Nothing ) ->
            -- Specific fabric process provided: retrieve associated complexity
            case fabric of
                KnittingFullyFashioned ->
                    MakingComplexity.VeryLow

                KnittingIntegral ->
                    MakingComplexity.NotApplicable

                _ ->
                    defaultComplexity

        ( Nothing, Nothing ) ->
            -- No specific fabric process or complexity provided: fallback to defaults
            defaultComplexity


getMakingWaste : Split -> Maybe Split -> Maybe Fabric -> Split
getMakingWaste defaultWaste maybeCustomWaste maybeFabric =
    case ( maybeFabric, maybeCustomWaste ) of
        ( _, Just customWaste ) ->
            -- A custom waste is provided: always takes priority
            customWaste

        ( Just fabric, Nothing ) ->
            -- Specific fabric process provided: retrieve associated waste
            case fabric of
                KnittingFullyFashioned ->
                    -- Fully fashioned garments have 2% fabric waste
                    Split.two

                KnittingIntegral ->
                    -- Garments integrally knitted have no fabric waste at all
                    Split.zero

                _ ->
                    defaultWaste

        ( Nothing, Nothing ) ->
            -- No specific fabric process or waste provided: fallback to defaults
            defaultWaste


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
