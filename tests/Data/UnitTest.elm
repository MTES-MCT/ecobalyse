module Data.UnitTest exposing (..)

import Data.Unit as Unit
import Energy
import Expect exposing (Expectation)
import Length
import Mass
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectImpactFloat : Float -> Unit.Impact -> Expectation
expectImpactFloat value =
    Unit.impactToFloat >> Expect.within (Expect.Absolute 0.01) value


suite : Test
suite =
    describe "Data.Unit"
        [ describe "Impact"
            [ describe "Unit.impactFromFloat"
                [ Unit.impact 1
                    |> Unit.impactToFloat
                    |> Expect.equal 1
                    |> asTest "should convert impact to float and the other way around"
                ]
            , describe "Unit.impactPefScore"
                [ Unit.impact 1
                    |> Unit.impactPefScore (Unit.impact 1) (Unit.ratio 1)
                    |> Expect.equal (Unit.impact 1000)
                    |> asTest "should compute impact PEF score (1, 1)"
                , Unit.impact 1
                    |> Unit.impactPefScore (Unit.impact 2) (Unit.ratio 0.5)
                    |> Expect.equal (Unit.impact 250)
                    |> asTest "should compute impact PEF score (1, 0.5)"
                , Unit.impact 1
                    |> Unit.impactPefScore (Unit.impact 0.25) (Unit.ratio 0.75)
                    |> Expect.equal (Unit.impact 3000)
                    |> asTest "should compute impact PEF score (0.25, 0.75)"
                ]
            , describe "Unit.forKg"
                [ Mass.kilograms 0.17
                    |> Unit.forKg (Unit.impact 0.2)
                    |> Expect.equal (Unit.impact 0.034)
                    |> asTest "should compute impact for mass"
                , Mass.grams 170
                    |> Unit.forKg (Unit.impact 0.2)
                    |> Expect.equal (Unit.impact 0.034)
                    |> asTest "should compute impact for mass from other scale unit"
                , Mass.grams 170
                    |> Unit.forKg (Unit.impact -0.2)
                    |> Expect.equal (Unit.impact -0.034)
                    |> asTest "should compute negative impact for mass"
                ]
            , describe "Unit.forKgAndDistance"
                [ Mass.kilograms 1
                    |> Unit.forKgAndDistance (Unit.impact 0.2) (Length.kilometers 2000)
                    |> Expect.equal (Unit.impact 0.4)
                    |> asTest "should compute impact for mass and distance"
                ]
            , describe "Unit.forKWh"
                [ Energy.kilowattHours 1
                    |> Unit.forKWh (Unit.impact 0.2)
                    |> expectImpactFloat 0.2
                    |> asTest "should compute impact for energy expressed in KWh"
                ]
            , describe "Unit.forMJ"
                [ Energy.megajoules 1
                    |> Unit.forMJ (Unit.impact 0.2)
                    |> expectImpactFloat 0.2
                    |> asTest "should compute impact for energy expressed in MJ"
                ]
            , describe "Unit.ratioedForKg"
                [ Mass.kilograms 1
                    |> Unit.ratioedForKg ( Unit.impact 0.25, Unit.impact 0.75 ) (Unit.Ratio 0.5)
                    |> expectImpactFloat 0.5
                    |> asTest "should compute impact from ratioed impact and mass"
                ]
            , describe "Unit.ratioedForKWh"
                [ Energy.kilowattHours 1
                    |> Unit.ratioedForKWh ( Unit.impact 0.25, Unit.impact 0.75 ) (Unit.Ratio 0.5)
                    |> expectImpactFloat 0.5
                    |> asTest "should compute impact from ratioed impact and energy in KWh"
                ]
            , describe "Unit.ratioedForMJ"
                [ Energy.megajoules 1
                    |> Unit.ratioedForMJ ( Unit.impact 0.25, Unit.impact 0.75 ) (Unit.Ratio 0.5)
                    |> expectImpactFloat 0.5
                    |> asTest "should compute impact from ratioed impact and energy in MJ"
                ]
            ]
        ]
