module Data.DefinitionTest exposing (..)

import Data.Impact.Definition as Definition
import Data.Scope as Scope
import Expect
import Set
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sumDefinitions : Definition.Base Int -> Int
sumDefinitions =
    Definition.foldl (\_ a b -> a + b) 0


suite : Test
suite =
    suiteWithDb "Data.Impact.Definition"
        (\{ textileDb } ->
            [ Definition.trigrams
                |> List.length
                |> Expect.equal 22
                |> asTest "There are 22 impact trigrams"
            , Definition.trigrams
                |> List.map ((\trigram -> Definition.get trigram textileDb.impactDefinitions) >> .trigram >> Definition.toString)
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
            , Definition.forScope textileDb.impactDefinitions Scope.Textile
                |> List.length
                |> Expect.equal 14
                |> asTest "there are 14 impacts related to textile"
            , Definition.forScope textileDb.impactDefinitions Scope.Food
                |> List.length
                |> Expect.equal 22
                |> asTest "there are 22 impacts related to food"
            , Definition.init 1
                |> Definition.filter Definition.isAggregate (always 0)
                |> sumDefinitions
                |> Expect.equal 2
                |> asTest "There are exactly two aggregated scores"
            ]
        )
