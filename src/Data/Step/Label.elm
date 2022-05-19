module Data.Step.Label exposing
    ( Label(..)
    , toGitbookPath
    , toString
    )

import Data.Gitbook as Gitbook


type Label
    = Material -- Matière
    | Spinning -- Filature
    | Fabric -- Tissage ou Tricotage
    | Dyeing -- Teinture/Ennoblissement
    | Making -- Confection
    | Distribution -- Distribution
    | Use -- Utilisation
    | EndOfLife -- Fin de vie


toString : Label -> String
toString label =
    case label of
        Material ->
            "Matière"

        Spinning ->
            "Filature"

        Fabric ->
            "Tissage & Tricotage"

        Making ->
            "Confection"

        Dyeing ->
            "Teinture"

        Distribution ->
            "Distribution"

        Use ->
            "Utilisation"

        EndOfLife ->
            "Fin de vie"


toGitbookPath : Label -> Gitbook.Path
toGitbookPath label =
    case label of
        Material ->
            Gitbook.MaterialAndSpinning

        Spinning ->
            Gitbook.MaterialAndSpinning

        Fabric ->
            Gitbook.Fabric

        Dyeing ->
            Gitbook.Dyeing

        Making ->
            Gitbook.Making

        Distribution ->
            Gitbook.Distribution

        Use ->
            Gitbook.Use

        EndOfLife ->
            Gitbook.EndOfLife
