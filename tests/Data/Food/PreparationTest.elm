module Data.Food.PreparationTest exposing (..)

import Data.Food.Preparation as Preparation
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Unit as Unit
import Energy
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Preparation"
        (\{ food } ->
            [ describe "apply"
                [ { id = Preparation.Id "sample"
                  , name = "Sample"
                  , elec = ( Energy.kilowattHours 1, Split.half )
                  , heat = ( Energy.megajoules 1, Split.half )
                  , applyRawToCookedRatio = False
                  }
                    |> Preparation.apply food.wellKnown (Mass.kilograms 1)
                    |> Impact.getImpact Definition.Ecs
                    |> Unit.impactToFloat
                    |> Expect.within (Expect.Absolute 0.001) 11.604
                    |> asTest "compute impacts from applying a consumption preparation technique"
                ]
            ]
        )
