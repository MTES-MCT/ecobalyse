module Data.Step.Label exposing
    ( Label(..)
    , decodeFromCode
    , encode
    , fromCodeString
    , toGitbookPath
    , toString
    )

import Data.Gitbook as Gitbook
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


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

        "dyeing" ->
            Ok Dyeing

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

        Dyeing ->
            "dyeing"

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


decodeFromCode : Decoder Label
decodeFromCode =
    Decode.string
        |> Decode.andThen
            (\str ->
                case fromCodeString str of
                    Ok decoded ->
                        Decode.succeed decoded

                    Err err ->
                        Decode.fail err
            )


encode : Label -> Encode.Value
encode label =
    label |> toCodeString |> Encode.string
