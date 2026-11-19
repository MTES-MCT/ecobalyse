module Data.UnitTest exposing (..)

import Data.Impact as Impact exposing (Impact)
import Data.Split as Split
import Data.Unit as Unit
import Energy
import Expect exposing (Expectation)
import Json.Decode as Decode
import Length
import Mass
import Test exposing (..)
import TestUtils exposing (asTest)


expectImpactFloat : Float -> Impact -> Expectation
expectImpactFloat value =
    Impact.impactToFloat >> Expect.within (Expect.Absolute 0.01) value


suite : Test
suite =
    describe "Data.Unit"
        [ describe "Impact"
            [ describe "Impact.impactFromFloat"
                [ Impact.impact 1
                    |> Impact.impactToFloat
                    |> Expect.equal 1
                    |> asTest "should convert impact to float and the other way around"
                ]
            , describe "Impact.impactAggregateScore"
                [ Impact.impact 1
                    |> Impact.impactAggregateScore (Impact.impact 1) Split.full
                    |> Expect.equal (Impact.impact 1000000)
                    |> asTest "should compute impact aggregate score (1, 1)"
                , Impact.impact 1
                    |> Impact.impactAggregateScore (Impact.impact 2) Split.half
                    |> Expect.equal (Impact.impact 250000)
                    |> asTest "should compute impact aggregate score (1, 0.5)"
                , Impact.impact 1
                    |> Impact.impactAggregateScore (Impact.impact 0.25) (Split.fromFloat 0.75 |> Result.withDefault Split.zero)
                    |> Expect.equal (Impact.impact 3000000)
                    |> asTest "should compute impact aggregate score (0.25, 0.75)"
                ]
            , describe "Unit.forKg"
                [ Mass.kilograms 0.17
                    |> Unit.forKg (Impact.impact 0.2)
                    |> Expect.equal (Impact.impact 0.034)
                    |> asTest "should compute impact for mass"
                , Mass.grams 170
                    |> Unit.forKg (Impact.impact 0.2)
                    |> Expect.equal (Impact.impact 0.034)
                    |> asTest "should compute impact for mass from other scale unit"
                , Mass.grams 170
                    |> Unit.forKg (Impact.impact -0.2)
                    |> Expect.equal (Impact.impact -0.034)
                    |> asTest "should compute negative impact for mass"
                ]
            , describe "Unit.forKgAndDistance"
                [ Mass.kilograms 1
                    |> Unit.forKgAndDistance (Impact.impact 0.2) (Length.kilometers 2000)
                    |> Expect.equal (Impact.impact 0.4)
                    |> asTest "should compute impact for mass and distance"
                ]
            , describe "Unit.forKWh"
                [ Energy.kilowattHours 1
                    |> Unit.forKWh (Impact.impact 0.2)
                    |> expectImpactFloat 0.2
                    |> asTest "should compute impact for energy expressed in KWh"
                ]
            , describe "Unit.forMJ"
                [ Energy.megajoules 1
                    |> Unit.forMJ (Impact.impact 0.2)
                    |> expectImpactFloat 0.2
                    |> asTest "should compute impact for energy expressed in MJ"
                ]
            , describe "Unit.ratioedForKg"
                [ Mass.kilograms 1
                    |> Unit.ratioedForKg ( Impact.impact 0.25, Impact.impact 0.75 ) (Unit.Ratio 0.5)
                    |> expectImpactFloat 0.5
                    |> asTest "should compute impact from ratioed impact and mass"
                ]
            , describe "Unit.ratioedForKWh"
                [ Energy.kilowattHours 1
                    |> Unit.ratioedForKWh ( Impact.impact 0.25, Impact.impact 0.75 ) (Unit.Ratio 0.5)
                    |> expectImpactFloat 0.5
                    |> asTest "should compute impact from ratioed impact and energy in KWh"
                ]
            , describe "Unit.ratioedForMJ"
                [ Energy.megajoules 1
                    |> Unit.ratioedForMJ ( Impact.impact 0.25, Impact.impact 0.75 ) (Unit.Ratio 0.5)
                    |> expectImpactFloat 0.5
                    |> asTest "should compute impact from ratioed impact and energy in MJ"
                ]
            , describe "Unit.decodeYarnSize"
                [ "27"
                    |> Decode.decodeString Unit.decodeYarnSize
                    |> Expect.equal (Ok (Unit.yarnSizeKilometersPerKg 27))
                    |> asTest "should decode an int yarnSize value"
                , "27.04"
                    |> Decode.decodeString Unit.decodeYarnSize
                    |> Expect.equal (Ok (Unit.yarnSizeKilometersPerKg 27.04))
                    |> asTest "should decode a float yarnSize value"
                ]
            ]
        ]
