module Data.DefinitionTest exposing (..)

import Data.Impact.Definition as Definition
import Expect
import Set
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Impact.Definition"
        [ Definition.trigrams
            |> List.length
            |> Expect.equal 22
            |> asTest "There are 22 impact trigrams"
        , Definition.trigrams
            |> List.map (Definition.get >> .trigramString)
            |> Set.fromList
            |> Set.toList
            |> List.length
            |> Expect.equal (List.length Definition.trigrams)
            |> asTest "There are 22 unique impact definitions and trigrams"
        , Definition.trigrams
            |> List.map Definition.toString
            |> List.filterMap (Definition.toTrigram >> Result.toMaybe)
            |> List.length
            |> Expect.equal (List.length Definition.trigrams)
            |> asTest "There's a string for each trigram and a trigram for each string"
        ]
