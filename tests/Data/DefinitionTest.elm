module Data.DefinitionTest exposing (..)

import Data.Impact.Definition as Definition
import Expect
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
            |> List.filterMap Definition.get
            |> List.length
            |> Expect.equal (List.length Definition.trigrams)
            |> asTest "There are 22 impact definitions"
        , Definition.trigrams
            |> List.map Definition.toString
            |> List.filterMap Definition.toTrigram
            |> List.length
            |> Expect.equal (List.length Definition.trigrams)
            |> asTest "There's a string for each trigram and a trigram for each string"
        ]
