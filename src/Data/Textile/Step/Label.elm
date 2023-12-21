module Data.Textile.Step.Label exposing
    ( Label(..)
    , all
    , decodeFromCode
    , encode
    , fromCodeString
    , toColor
    , toGitbookPath
    , toId
    , toName
    , toString
    )

import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Label
    = Material -- Matière
    | Spinning -- Filature
    | Fabric -- Tissage ou Tricotage
    | Ennobling -- Ennoblissement
    | Making -- Confection
    | Distribution -- Distribution
    | Use -- Utilisation
    | EndOfLife -- Fin de vie


all : List Label
all =
    [ Material
    , Spinning
    , Fabric
    , Ennobling
    , Making
    , Distribution
    , Use
    , EndOfLife
    ]


toColor : Label -> String
toColor label =
    case label of
        Material ->
            Impact.stepsColors.materials

        Spinning ->
            Impact.stepsColors.transform

        Fabric ->
            Impact.stepsColors.transform

        Making ->
            Impact.stepsColors.transform

        Ennobling ->
            Impact.stepsColors.transform

        Distribution ->
            Impact.stepsColors.distribution

        Use ->
            Impact.stepsColors.usage

        EndOfLife ->
            Impact.stepsColors.endOfLife


toId : Label -> String
toId label =
    case label of
        Material ->
            "materials-step"

        Spinning ->
            -- We only want a single "transform-step" id, as it's used for the Html `id` attribute
            -- and they are meant to be unique throughout the page.
            "transform-step"

        Fabric ->
            "transform-step-fabric"

        Making ->
            "transform-step-making"

        Ennobling ->
            "transform-step-ennobling"

        Distribution ->
            "distribution-step"

        Use ->
            "usage-step"

        EndOfLife ->
            "end-of-life-step"


toName : Label -> String
toName label =
    case label of
        Spinning ->
            "Transformation\u{00A0}- Filature"

        Fabric ->
            "Transformation\u{00A0}- Tissage / Tricotage"

        Making ->
            "Transformation\u{00A0}- Confection"

        Ennobling ->
            "Transformation\u{00A0}- Ennoblissement"

        _ ->
            toString label


toString : Label -> String
toString label =
    case label of
        Material ->
            "Matières premières"

        Spinning ->
            "Filature"

        Fabric ->
            "Tissage & Tricotage"

        Making ->
            "Confection"

        Ennobling ->
            "Ennoblissement"

        Distribution ->
            "Distribution"

        Use ->
            "Utilisation"

        EndOfLife ->
            "Fin de vie"


fromCodeString : String -> Result String Label
fromCodeString code =
    case code of
        "material" ->
            Ok Material

        "spinning" ->
            Ok Spinning

        "fabric" ->
            Ok Fabric

        "making" ->
            Ok Making

        "ennobling" ->
            Ok Ennobling

        "distribution" ->
            Ok Distribution

        "use" ->
            Ok Use

        "eol" ->
            Ok EndOfLife

        _ ->
            Err ("Code étape inconnu: " ++ code)


toCodeString : Label -> String
toCodeString label =
    case label of
        Material ->
            "material"

        Spinning ->
            "spinning"

        Fabric ->
            "fabric"

        Making ->
            "making"

        Ennobling ->
            "ennobling"

        Distribution ->
            "distribution"

        Use ->
            "use"

        EndOfLife ->
            "eol"


toGitbookPath : Label -> Gitbook.Path
toGitbookPath label =
    case label of
        Material ->
            Gitbook.TextileMaterial

        Spinning ->
            Gitbook.TextileSpinning

        Fabric ->
            Gitbook.TextileFabric

        Ennobling ->
            Gitbook.TextileEnnobling

        Making ->
            Gitbook.TextileMaking

        Distribution ->
            Gitbook.TextileDistribution

        Use ->
            Gitbook.TextileUse

        EndOfLife ->
            Gitbook.TextileEndOfLife


decodeFromCode : Decoder Label
decodeFromCode =
    Decode.string
        |> Decode.andThen (fromCodeString >> DE.fromResult)


encode : Label -> Encode.Value
encode =
    toCodeString >> Encode.string
