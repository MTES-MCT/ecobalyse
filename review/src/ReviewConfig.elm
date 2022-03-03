module ReviewConfig exposing (config)

import NoExposingEverything
import NoImportingEverything
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)


config : List Rule
config =
    [ -- Common
      NoExposingEverything.rule
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
        |> Rule.ignoreErrorsForFiles [ "src/Views/Icon.elm" ]
    , NoImportingEverything.rule
        [ "Html"
        , "Html.Attributes"
        , "Html.Events"
        , "Svg"
        , "Svg.Attributes"
        ]
        |> Rule.ignoreErrorsForDirectories [ "tests/" ]
      -- NoUnused
    , NoUnused.CustomTypeConstructors.rule []
        |> Rule.ignoreErrorsForFiles [ "src/Views/Modal.elm" ]
    , NoUnused.CustomTypeConstructorArgs.rule
        |> Rule.ignoreErrorsForFiles [ "src/Server/Route.elm" ]
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule
        |> Rule.ignoreErrorsForFiles [ "src/Views/Button.elm" ]
    , NoUnused.Modules.rule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    ]
