module ReviewConfig exposing (config)

import CognitiveComplexity
import NoDebug.TodoOrToString
import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoRedundantCons
import NoUnsortedConstructors
import NoUnsortedRecordFields
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ -- CognitiveComplexity
      CognitiveComplexity.rule 15
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]

    -- NoDebug
    , NoDebug.TodoOrToString.rule
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
        |> Rule.ignoreErrorsForFiles [ "src/Views/Debug.elm" ]

    -- Common
    , NoExposingEverything.rule
        |> Rule.ignoreErrorsForFiles [ "src/Data/Color.elm" ]
        |> Rule.ignoreErrorsForFiles [ "src/Views/Icon.elm" ]
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
    , NoImportingEverything.rule
        [ "Html"
        , "Html.Attributes"
        , "Html.Events"
        , "Svg"
        , "Svg.Attributes"
        ]
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
    , NoMissingTypeAnnotation.rule
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
    , NoRedundantCons.rule
    , NoUnsortedRecordFields.rule
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
        |> Rule.ignoreErrorsForDirectories [ "src/Page" ]
        |> Rule.ignoreErrorsForFiles [ "src/Data/Component/Config.elm" ]
        |> Rule.ignoreErrorsForFiles [ "src/Data/Impact/Definition.elm" ]
    , NoUnsortedConstructors.rule
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
        |> Rule.ignoreErrorsForFiles [ "src/Data/Impact/Definition.elm" ]
        |> Rule.ignoreErrorsForFiles [ "src/Data/Impact/Definition.elm" ]

    -- NoUnused
    , NoUnused.CustomTypeConstructors.rule []
        |> Rule.ignoreErrorsForFiles [ "src/Views/Modal.elm" ]
        |> Rule.ignoreErrorsForFiles [ "src/Page/Home.elm" ]
    , NoUnused.CustomTypeConstructorArgs.rule
        |> Rule.ignoreErrorsForFiles [ "src/Server/Route.elm" ]
        |> Rule.ignoreErrorsForFiles [ "src/Views/Page.elm" ]
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule
        |> Rule.ignoreErrorsForFiles [ "src/Views/Button.elm" ]
        |> Rule.ignoreErrorsForFiles [ "src/Views/Debug.elm" ]
    , NoUnused.Modules.rule
        |> Rule.ignoreErrorsForFiles [ "src/Views/Debug.elm" ]
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule

    -- Simlify
    , Simplify.rule Simplify.defaults
    ]
