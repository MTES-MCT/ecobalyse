module Data.SimulatorTest exposing (..)

import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (..)
import Data.Simulator as Simulator
import Data.Unit as Unit
import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


expectImpact : Db -> Impact.Trigram -> Float -> Inputs.Query -> Expectation
expectImpact db trigram value query =
    case Simulator.compute db query of
        Ok simulator ->
            simulator.impacts
                |> Impact.getImpact trigram
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) value

        Err error ->
            Expect.fail error


suite : Test
suite =
    suiteWithDb "Data.Simulator"
        (\db ->
            [ describe "Simulator.compute"
                [ tShirtCotonFrance
                    |> expectImpact db (Impact.trg "cch") 5.086507233728058
                    |> asTest "should compute a simulation cch impact"
                ]
            ]
        )
