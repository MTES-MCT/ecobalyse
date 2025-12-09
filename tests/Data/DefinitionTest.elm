module Data.DefinitionTest exposing (..)

import Data.Impact.Definition as Definition
import Expect
import Set
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sumDefinitions : Definition.Trigrams Int -> Int
sumDefinitions =
    Definition.foldl (\_ a b -> a + b) 0


suite : Test
suite =
    suiteWithDb "Data.Impact.Definition"
        (\db ->
            [ Definition.trigrams
                |> List.length
                |> Expect.equal 20
                |> asTest "There are 20 impact trigrams"
            , Definition.trigrams
                |> List.map ((\trigram -> Definition.get trigram db.definitions) >> .trigram >> Definition.toString)
                |> Set.fromList
                |> Set.size
                |> Expect.equal (List.length Definition.trigrams)
                |> asTest "There are 21 unique impact definitions and trigrams"
            , Definition.trigrams
                |> List.map Definition.toString
                |> List.filterMap (Definition.toTrigram >> Result.toMaybe)
                |> List.length
                |> Expect.equal (List.length Definition.trigrams)
                |> asTest "There's a string for each trigram and a trigram for each string"
            , Definition.init 0
                |> sumDefinitions
                |> Expect.equal 0
                |> asTest "init will set all the fields to the same value"
            , Definition.init 0
                |> Definition.map (\_ a -> a + 1)
                |> Expect.equal (Definition.init 1)
                |> asTest "map will apply a function to all the fields"
            , Definition.init 0
                |> Definition.update Definition.Acd ((+) 1)
                |> sumDefinitions
                |> Expect.equal 1
                |> asTest "update will change only one field"
            , Definition.init 0
                |> Definition.update Definition.Acd ((+) 1)
                |> (\definitions -> (\trigram -> Definition.get trigram definitions) Definition.Acd)
                |> Expect.equal 1
                |> asTest "get will retrive the value of a field"
            , Definition.init 1
                |> Definition.filter ((==) Definition.Acd) (always 0)
                |> sumDefinitions
                |> Expect.equal 1
                |> asTest "filter will zero all the values for fields filtered out"
            , Definition.toList db.definitions
                |> List.length
                |> Expect.equal 20
                |> asTest "there are 21 impacts in total"
            , Definition.init 1
                |> Definition.filter Definition.isAggregate (always 0)
                |> sumDefinitions
                |> Expect.equal 1
                |> asTest "There are exactly one aggregated scores"
            ]
        )
