module Data.Textile.SimulatorTest exposing (..)

import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Query exposing (Query, tShirtCotonFrance)
import Data.Textile.Simulator as Simulator
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Expect exposing (Expectation)
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getImpact : Db -> Definition.Trigram -> Query -> Result String Float
getImpact db trigram =
    Simulator.compute db
        >> Result.map
            (.impacts
                >> Impact.getImpact trigram
                >> Unit.impactToFloat
            )


expectImpact : Db -> Definition.Trigram -> Float -> Query -> Expectation
expectImpact db trigram value query =
    case getImpact db trigram query of
        Ok result ->
            result
                |> Expect.within (Expect.Absolute 0.01) value

        Err error ->
            Expect.fail error


cch : Definition.Trigram
cch =
    Definition.Cch


suite : Test
suite =
    suiteWithDb "Data.Simulator"
        (\db ->
            [ describe "Simulator.compute"
                [ { tShirtCotonFrance
                    | countrySpinning = Nothing
                  }
                    |> expectImpact db cch 4.582286466348852
                    |> asTest "should compute a simulation cch impact"
                , describe "disabled steps"
                    [ { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                        |> Simulator.compute db
                        |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Ennobling .enabled True)
                        |> Expect.equal (Ok False)
                        |> asTest "should be handled from passed query"
                    , asTest "should handle disabled steps"
                        (case
                            ( getImpact db cch tShirtCotonFrance
                            , getImpact db cch { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                            )
                         of
                            ( Ok full, Ok partial ) ->
                                full |> Expect.greaterThan partial

                            _ ->
                                Expect.fail "bogus simulator results"
                        )
                    , asTest "should allow disabling steps"
                        (case
                            ( getImpact db cch tShirtCotonFrance
                            , getImpact db cch { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                            )
                         of
                            ( Ok full, Ok partial ) ->
                                full |> Expect.greaterThan partial

                            _ ->
                                Expect.fail "bogus simulator results"
                        )
                    ]
                ]
            ]
        )
