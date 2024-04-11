module TestUtils exposing
    ( asTest
    , expectImpactsEqual
    , suiteWithDb
    )

import ComputeAggregated exposing (fakeDetails)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Trigrams)
import Data.Unit as Unit
import Expect exposing (Expectation)
import Static.Db exposing (Db, db, processes)
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


suiteWithDb : String -> (Db -> List Test) -> Test
suiteWithDb name suite =
    case db processes of
        Ok ({ food, textile } as db) ->
            let
                -- The non detailed DB, accessible to all without authentication, will have all the
                -- non aggregated impacts set to 0. To still be able to spot computation changes
                -- we need those to be non zero. To do that, we change those non aggregated impacts
                -- in the DB.
                fakeDetailedDb =
                    { db
                        | food = { food | processes = fakeDetails food.processes }
                        , textile = { textile | processes = fakeDetails textile.processes }
                    }
            in
            describe name (suite fakeDetailedDb)

        Err error ->
            describe name
                [ test "should load static database" <|
                    \_ -> Expect.fail <| "Couldn't parse static database: " ++ error
                ]


expectImpactsEqual : Trigrams (Float -> Expectation) -> Impacts -> Expectation
expectImpactsEqual impacts subject =
    Definition.trigrams
        |> List.map
            (\trigram ->
                Impact.getImpact trigram >> Unit.impactToFloat >> Definition.get trigram impacts
            )
        |> (\expectations ->
                Expect.all expectations subject
           )
