module Data.Food.ComsumptionTest exposing (..)

import Data.Food.Comsumption as Comsumption
import Data.Impact as Impact
import Data.Unit as Unit
import Energy
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Consumption"
        (\{ builderDb } ->
            [ describe "applyTechnique"
                [ { name = "Sample"
                  , elec = ( Energy.kilowattHours 1, Unit.ratio 0.5 )
                  , heat = ( Energy.megajoules 1, Unit.ratio 0.5 )
                  }
                    |> Comsumption.applyTechnique builderDb (Mass.kilograms 1)
                    |> Result.map (Impact.getImpact (Impact.trg "cch") >> Unit.impactToFloat)
                    |> Result.withDefault 0
                    |> Expect.within (Expect.Absolute 0.001) 0.069
                    |> asTest "compute impacts from applying a consumption preparation technique"
                ]
            ]
        )
