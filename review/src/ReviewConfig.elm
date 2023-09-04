module ReviewConfig exposing (config)


import NoDebug.TodoOrToString
import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoRedundantConcat
import NoRedundantCons
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
import CognitiveComplexity


config : List Rule
config =
    [ -- CognitiveComplexity
      CognitiveComplexity.rule 15
      -- NoDebug
    , NoDebug.TodoOrToString.rule
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
    , NoRedundantConcat.rule
    , NoRedundantCons.rule
      -- NoUnused
    , NoUnused.CustomTypeConstructors.rule []
        |> Rule.ignoreErrorsForFiles [ "src/Views/Modal.elm" ]
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
