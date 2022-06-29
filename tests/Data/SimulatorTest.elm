module Data.SimulatorTest exposing (..)

import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (..)
import Data.LifeCycle as LifeCycle
import Data.Simulator as Simulator
import Data.Step.Label as Label
import Data.Unit as Unit
import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getImpact : Db -> Impact.Trigram -> Inputs.Query -> Result String Float
getImpact db trigram =
    Simulator.compute db
        >> Result.map
            (.impacts
                >> Impact.getImpact trigram
                >> Unit.impactToFloat
            )


expectImpact : Db -> Impact.Trigram -> Float -> Inputs.Query -> Expectation
expectImpact db trigram value query =
    case getImpact db trigram query of
        Ok result ->
            result
                |> Expect.within (Expect.Absolute 0.01) value

        Err error ->
            Expect.fail error


suite : Test
suite =
    suiteWithDb "Data.Simulator"
        (\db ->
            [ describe "Simulator.compute"
                [ tShirtCotonFrance
                    |> expectImpact db (Impact.trg "cch") 5.070273292372325
                    |> asTest "should compute a simulation cch impact"
                , describe "disabled steps"
                    [ { tShirtCotonFrance | disabledSteps = [ Label.Dyeing ] }
                        |> Simulator.compute db
                        |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Dyeing .enabled True)
                        |> Expect.equal (Ok False)
                        |> asTest "should be handled from passed query"
                    , asTest "should handle disabled steps"
                        (case
                            ( getImpact db (Impact.trg "cch") tShirtCotonFrance
                            , getImpact db (Impact.trg "cch") { tShirtCotonFrance | disabledSteps = [ Label.Dyeing ] }
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
