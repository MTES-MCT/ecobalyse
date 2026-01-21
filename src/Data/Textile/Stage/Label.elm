module Data.Textile.Stage.Label exposing
    ( Label(..)
    , all
    , decodeFromCode
    , encode
    , toColor
    , toGitbookPath
    , toId
    , toName
    , toString
    , upcyclables
    )

import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Label
    = Distribution -- Distribution
    | EndOfLife -- Fin de vie
    | Ennobling -- Ennoblissement
    | Fabric -- Tissage ou Tricotage
    | Making -- Confection
    | Material -- Matière
    | Spinning -- Filature
    | Use -- Utilisation


all : List Label
all =
    [ Distribution, EndOfLife, Ennobling, Fabric, Making, Material, Spinning, Use ]


upcyclables : List Label
upcyclables =
    [ Material
    , Spinning
    , Fabric
    , Ennobling
    ]


toColor : Label -> String
toColor label =
    case label of
        Distribution ->
            Impact.stagesColors.distribution

        EndOfLife ->
            Impact.stagesColors.endOfLife

        Ennobling ->
            Impact.stagesColors.transform

        Fabric ->
            Impact.stagesColors.transform

        Making ->
            Impact.stagesColors.transform

        Material ->
            Impact.stagesColors.materials

        Spinning ->
            Impact.stagesColors.transform

        Use ->
            Impact.stagesColors.usage


toId : Label -> String
toId label =
    case label of
        Distribution ->
            "distribution-stage"

        EndOfLife ->
            "end-of-life-stage"

        Ennobling ->
            "transform-stage-ennobling"

        Fabric ->
            "transform-stage-fabric"

        Making ->
            "transform-stage-making"

        Material ->
            "materials-stage"

        Spinning ->
            -- We only want a single "transform-stage" id, as it's used for the Html `id` attribute
            -- and they are meant to be unique throughout the page.
            "transform-stage"

        Use ->
            "usage-stage"


toName : Label -> String
toName label =
    case label of
        Ennobling ->
            "Transformation\u{00A0}- Ennoblissement"

        Fabric ->
            "Transformation\u{00A0}- Tissage / Tricotage"

        Making ->
            "Transformation\u{00A0}- Confection"

        Spinning ->
            "Transformation\u{00A0}- Filature"

        _ ->
            toString label


toString : Label -> String
toString label =
    case label of
        Distribution ->
            "Distribution"

        EndOfLife ->
            "Fin de vie"

        Ennobling ->
            "Ennoblissement"

        Fabric ->
            "Tissage & Tricotage"

        Making ->
            "Confection"

        Material ->
            "Matières premières"

        Spinning ->
            "Filature"

        Use ->
            "Utilisation"


fromCodeString : String -> Result String Label
fromCodeString code =
    case code of
        "distribution" ->
            Ok Distribution

        "ennobling" ->
            Ok Ennobling

        "end-of-life" ->
            Ok EndOfLife

        "fabric" ->
            Ok Fabric

        "making" ->
            Ok Making

        "material" ->
            Ok Material

        "spinning" ->
            Ok Spinning

        "use" ->
            Ok Use

        _ ->
            Err ("Code étape inconnu: " ++ code)


toCodeString : Label -> String
toCodeString label =
    case label of
        Distribution ->
            "distribution"

        EndOfLife ->
            "end-of-life"

        Ennobling ->
            "ennobling"

        Fabric ->
            "fabric"

        Making ->
            "making"

        Material ->
            "material"

        Spinning ->
            "spinning"

        Use ->
            "use"


toGitbookPath : Label -> Gitbook.Path
toGitbookPath label =
    case label of
        Distribution ->
            Gitbook.TextileDistribution

        EndOfLife ->
            Gitbook.TextileEndOfLife

        Ennobling ->
            Gitbook.TextileEnnobling

        Fabric ->
            Gitbook.TextileFabric

        Making ->
            Gitbook.TextileMaking

        Material ->
            Gitbook.TextileMaterial

        Spinning ->
            Gitbook.TextileSpinning

        Use ->
            Gitbook.TextileUse


decodeFromCode : Decoder Label
decodeFromCode =
    Decode.string
        |> Decode.andThen (fromCodeString >> DE.fromResult)


encode : Label -> Encode.Value
encode =
    toCodeString >> Encode.string
