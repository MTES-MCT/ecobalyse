module Data.Food.PreparationTest exposing (..)

import Data.Food.Preparation as Preparation
import Data.Impact as Impact
import Data.Unit as Unit
import Energy
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Preparation"
        (\{ builderDb } ->
            [ describe "apply"
                [ { id = Preparation.Id "sample"
                  , name = "Sample"
                  , elec = ( Energy.kilowattHours 1, Unit.ratio 0.5 )
                  , heat = ( Energy.megajoules 1, Unit.ratio 0.5 )
                  , applyRawToCookedRatio = False
                  }
                    |> Preparation.apply builderDb (Mass.kilograms 1)
                    |> Result.map (Impact.getImpact (Impact.trg "cch") >> Unit.impactToFloat)
                    |> Result.withDefault 0
                    |> Expect.within (Expect.Absolute 0.001) 0.05
                    |> asTest "compute impacts from applying a consumption preparation technique"
                ]
            ]
        )
