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
        [ describe "Unit.impactFromFloat"
            [ Unit.impactFromFloat 1
                |> Unit.impactToFloat
                |> Expect.equal 1
                |> asTest "should convert impact to float and the other way around"
            ]
        , describe "Unit.forKg"
            [ Mass.kilograms 0.17
                |> Unit.forKg (Unit.impactFromFloat 0.2)
                |> Expect.equal (Unit.impactFromFloat 0.034)
                |> asTest "should compute impact for mass"
            , Mass.grams 170
                |> Unit.forKg (Unit.impactFromFloat 0.2)
                |> Expect.equal (Unit.impactFromFloat 0.034)
                |> asTest "should compute impact for mass from other scale unit"
            , Mass.grams 170
                |> Unit.forKg (Unit.impactFromFloat -0.2)
                |> Expect.equal (Unit.impactFromFloat -0.034)
                |> asTest "should compute negative impact for mass"
            ]
        , describe "Unit.forKgAndDistance"
            [ Mass.kilograms 1
                |> Unit.forKgAndDistance (Unit.impactFromFloat 0.2) (Length.kilometers 2000)
                |> Expect.equal (Unit.impactFromFloat 0.4)
                |> asTest "should compute impact for mass and distance"
            ]
        , describe "Unit.forKWh"
            [ Energy.kilowattHours 1
                |> Unit.forKWh (Unit.impactFromFloat 0.2)
                |> expectImpactFloat 0.2
                |> asTest "should compute impact for energy expressed in KWh"
            ]
        , describe "Unit.forMJ"
            [ Energy.megajoules 1
                |> Unit.forMJ (Unit.impactFromFloat 0.2)
                |> expectImpactFloat 0.2
                |> asTest "should compute impact for energy expressed in MJ"
            ]
        , describe "Unit.ratioedForKg"
            [ Mass.kilograms 1
                |> Unit.ratioedForKg ( Unit.impactFromFloat 0.25, Unit.impactFromFloat 0.75 ) 0.5
                |> expectImpactFloat 0.5
                |> asTest "should compute impact from ratioed impact and mass"
            ]
        , describe "Unit.ratioedForKWh"
            [ Energy.kilowattHours 1
                |> Unit.ratioedForKWh ( Unit.impactFromFloat 0.25, Unit.impactFromFloat 0.75 ) 0.5
                |> expectImpactFloat 0.5
                |> asTest "should compute impact from ratioed impact and energy in KWh"
            ]
        , describe "Unit.ratioedForMJ"
            [ Energy.megajoules 1
                |> Unit.ratioedForMJ ( Unit.impactFromFloat 0.25, Unit.impactFromFloat 0.75 ) 0.5
                |> expectImpactFloat 0.5
                |> asTest "should compute impact from ratioed impact and energy in MJ"
            ]
        ]
