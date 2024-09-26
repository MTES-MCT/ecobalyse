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
    = KnittingCircular
    | KnittingFullyFashioned
    | KnittingIntegral
    | KnittingMix
    | KnittingStraight
    | Weaving


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
        "knitting-circular" ->
            Ok KnittingCircular

        "knitting-fully-fashioned" ->
            Ok KnittingFullyFashioned

        "knitting-integral" ->
            Ok KnittingIntegral

        "knitting-mix" ->
            Ok KnittingMix

        "knitting-straight" ->
            Ok KnittingStraight

        "weaving" ->
            Ok Weaving

        _ ->
            Err <| "Procédé de tissage/tricotage inconnu: " ++ string


getMakingComplexity : MakingComplexity -> Maybe MakingComplexity -> Maybe Fabric -> MakingComplexity
getMakingComplexity defaultComplexity maybeCustomComplexity maybeFabric =
    case ( maybeFabric, maybeCustomComplexity ) of
        -- Custom complexity provided: always takes priority
        ( _, Just customComplexity ) ->
            customComplexity

        -- Specific fabric process provided: retrieve associated complexity
        ( Just KnittingFullyFashioned, Nothing ) ->
            MakingComplexity.VeryLow

        ( Just KnittingIntegral, Nothing ) ->
            MakingComplexity.NotApplicable

        _ ->
            defaultComplexity


getMakingWaste : Split -> Maybe Split -> Maybe Fabric -> Split
getMakingWaste defaultWaste maybeCustomWaste maybeFabric =
    case ( maybeFabric, maybeCustomWaste ) of
        -- Custom waste provided: always takes priority
        ( _, Just customWaste ) ->
            customWaste

        -- Specific fabric process provided: retrieve associated waste
        ( Just KnittingFullyFashioned, Nothing ) ->
            -- Fully fashioned garments have 2% fabric waste
            Split.two

        ( Just KnittingIntegral, Nothing ) ->
            -- Garments integrally knitted have no fabric waste at all
            Split.zero

        _ ->
            defaultWaste


getProcess : WellKnown -> Fabric -> Process
getProcess wellKnown fabric =
    case fabric of
        KnittingCircular ->
            wellKnown.knittingCircular

        KnittingFullyFashioned ->
            wellKnown.knittingFullyFashioned

        KnittingIntegral ->
            wellKnown.knittingSeamless

        KnittingMix ->
            wellKnown.knittingMix

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
        KnittingCircular ->
            "Tricotage Circulaire"

        KnittingFullyFashioned ->
            "Tricotage Fully fashioned / Seamless"

        KnittingIntegral ->
            "Tricotage Intégral / Whole garment"

        KnittingMix ->
            "Tricotage moyen (par défaut)"

        KnittingStraight ->
            "Tricotage Rectiligne"

        Weaving ->
            "Tissage"


toString : Fabric -> String
toString fabricProcess =
    case fabricProcess of
        KnittingCircular ->
            "knitting-circular"

        KnittingFullyFashioned ->
            "knitting-fully-fashioned"

        KnittingIntegral ->
            "knitting-integral"

        KnittingMix ->
            "knitting-mix"

        KnittingStraight ->
            "knitting-straight"

        Weaving ->
            "weaving"
