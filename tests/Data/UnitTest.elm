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


expectKgCo2Float : Float -> Unit.Co2e -> Expectation
expectKgCo2Float value co2 =
    co2 |> Unit.inKgCo2e |> Expect.within (Expect.Absolute 0.01) value


suite : Test
suite =
    describe "Data.Unit"
        [ describe "Unit.inKgCo2e"
            [ Unit.kgCo2e 1
                |> Unit.inKgCo2e
                |> Expect.equal 1
                |> asTest "inKgCo2e should convert Kg"
            ]
        , describe "Unit.forKg"
            [ Mass.kilograms 0.17
                |> Unit.forKg (Unit.kgCo2e 0.2)
                |> Expect.equal (Unit.kgCo2e 0.034)
                |> asTest "should compute kgCo2e for mass"
            , Mass.grams 170
                |> Unit.forKg (Unit.kgCo2e 0.2)
                |> Expect.equal (Unit.kgCo2e 0.034)
                |> asTest "should compute kgCo2e for mass from other scale unit"
            , Mass.grams 170
                |> Unit.forKg (Unit.kgCo2e -0.2)
                |> Expect.equal (Unit.kgCo2e -0.034)
                |> asTest "should compute negative kgCo2e for mass"
            ]
        , describe "Unit.forKgAndDistance"
            [ Mass.kilograms 1
                |> Unit.forKgAndDistance (Unit.kgCo2e 0.2) (Length.kilometers 2000)
                |> Expect.equal (Unit.kgCo2e 0.4)
                |> asTest "should compute kgCo2e for mass and distance"
            ]
        , describe "Unit.forKWh"
            [ Energy.kilowattHours 1
                |> Unit.forKWh (Unit.kgCo2e 0.2)
                |> expectKgCo2Float 0.2
                |> asTest "should compute kgCo2e for energy expressed in KWh"
            ]
        , describe "Unit.forMJ"
            [ Energy.megajoules 1
                |> Unit.forMJ (Unit.kgCo2e 0.2)
                |> expectKgCo2Float 0.2
                |> asTest "should compute kgCo2e for energy expressed in MJ"
            ]
        , describe "Unit.ratioedForKg"
            [ Mass.kilograms 1
                |> Unit.ratioedForKg ( Unit.kgCo2e 0.25, Unit.kgCo2e 0.75 ) 0.5
                |> expectKgCo2Float 0.5
                |> asTest "should compute co2 from ratioed co2 impacts and mass"
            ]
        , describe "Unit.ratioedForKWh"
            [ Energy.kilowattHours 1
                |> Unit.ratioedForKWh ( Unit.kgCo2e 0.25, Unit.kgCo2e 0.75 ) 0.5
                |> expectKgCo2Float 0.5
                |> asTest "should compute co2 from ratioed co2 impacts and energy in KWh"
            ]
        , describe "Unit.ratioedForMJ"
            [ Energy.megajoules 1
                |> Unit.ratioedForMJ ( Unit.kgCo2e 0.25, Unit.kgCo2e 0.75 ) 0.5
                |> expectKgCo2Float 0.5
                |> asTest "should compute co2 from ratioed co2 impacts and energy in MJ"
            ]
        ]
