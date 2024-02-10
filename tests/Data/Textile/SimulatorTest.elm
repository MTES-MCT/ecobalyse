module Data.Textile.SimulatorTest exposing (..)

import Data.Country exposing (Country)
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.Db as Textile
import Data.Textile.Inputs as Inputs exposing (..)
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Simulator as Simulator
import Data.Textile.Step.Label as Label
import Data.Transport exposing (Distances)
import Data.Unit as Unit
import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getImpact : Distances -> List Country -> Textile.Db -> Definition.Trigram -> Inputs.Query -> Result String Float
getImpact distances countries db trigram =
    Simulator.compute distances countries db
        >> Result.map
            (.impacts
                >> Impact.getImpact trigram
                >> Unit.impactToFloat
            )


expectImpact : Distances -> List Country -> Textile.Db -> Definition.Trigram -> Float -> Inputs.Query -> Expectation
expectImpact distances countries db trigram value query =
    case getImpact distances countries db trigram query of
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
        (\{ textile, distances, countries } ->
            [ describe "Simulator.compute"
                [ { tShirtCotonFrance
                    | countrySpinning = Nothing
                  }
                    |> expectImpact distances countries textile cch 8.803982880812638
                    |> asTest "should compute a simulation cch impact"
                , describe "disabled steps"
                    [ { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                        |> Simulator.compute distances countries textile
                        |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Ennobling .enabled True)
                        |> Expect.equal (Ok False)
                        |> asTest "should be handled from passed query"
                    , asTest "should handle disabled steps"
                        (case
                            ( getImpact distances countries textile cch tShirtCotonFrance
                            , getImpact distances countries textile cch { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                            )
                         of
                            ( Ok full, Ok partial ) ->
                                full |> Expect.greaterThan partial

                            _ ->
                                Expect.fail "bogus simulator results"
                        )
                    , asTest "should allow disabling steps"
                        (case
                            ( getImpact distances countries textile cch tShirtCotonFrance
                            , getImpact distances countries textile cch { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
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
