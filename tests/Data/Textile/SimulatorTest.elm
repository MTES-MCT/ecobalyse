module Data.Textile.SimulatorTest exposing (..)

import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs exposing (..)
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Simulator as Simulator
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getImpact : TextileDb.Db -> Definition.Trigram -> Inputs.Query -> Result String Float
getImpact db trigram =
    Simulator.compute db
        >> Result.map
            (.impacts
                >> Impact.getImpact trigram
                >> Unit.impactToFloat
            )


expectImpact : TextileDb.Db -> Definition.Trigram -> Float -> Inputs.Query -> Expectation
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
        (\{ textileDb } ->
            [ describe "Simulator.compute"
                [ tShirtCotonFrance
                    |> expectImpact textileDb cch 5.632753469638849
                    |> asTest "should compute a simulation cch impact"
                , describe "disabled steps"
                    [ { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                        |> Simulator.compute textileDb
                        |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Ennobling .enabled True)
                        |> Expect.equal (Ok False)
                        |> asTest "should be handled from passed query"
                    , asTest "should handle disabled steps"
                        (case
                            ( getImpact textileDb cch tShirtCotonFrance
                            , getImpact textileDb cch { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                            )
                         of
                            ( Ok full, Ok partial ) ->
                                full |> Expect.greaterThan partial

                            _ ->
                                Expect.fail "bogus simulator results"
                        )
                    , asTest "should compute disabled steps accurately"
                        (case
                            ( Simulator.compute textileDb tShirtCotonFrance
                            , getImpact textileDb cch { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                            )
                         of
                            ( Ok full, Ok partialTotalImpacts ) ->
                                case LifeCycle.getStep Label.Ennobling full.lifeCycle of
                                    Just dyeingStep ->
                                        let
                                            asCchFloat =
                                                Impact.getImpact cch >> Unit.impactToFloat

                                            fullTotalImpact =
                                                asCchFloat full.impacts

                                            nonTransportsImpacts =
                                                asCchFloat dyeingStep.impacts

                                            transportsImpacts =
                                                asCchFloat dyeingStep.transport.impacts

                                            dyeingImpact =
                                                nonTransportsImpacts + transportsImpacts
                                        in
                                        partialTotalImpacts
                                            |> Expect.within (Expect.Absolute 0.0000000001) (fullTotalImpact - dyeingImpact)

                                    Nothing ->
                                        Expect.fail "Missing step"

                            _ ->
                                Expect.fail "bogus simulator results"
                        )
                    ]
                ]
            ]
        )
