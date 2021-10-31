module Data.Co2Test exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Energy
import Expect exposing (Expectation)
import Mass
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectKgCo2Float : Float -> Co2e -> Expectation
expectKgCo2Float value co2 =
    co2 |> Co2.inKgCo2e |> Expect.within (Expect.Absolute 0.01) value


suite : Test
suite =
    describe "Data.Co2"
        [ describe "Co2.inGramsCo2e"
            [ Co2.kgCo2e 1
                |> Co2.inGramsCo2e
                |> Expect.equal 1000
                |> asTest "inGramsCo2e should convert Grams"
            ]
        , describe "Co2.inKgCo2e"
            [ Co2.kgCo2e 1
                |> Co2.inKgCo2e
                |> Expect.equal 1
                |> asTest "inKgCo2e should convert Kg"
            ]
        , describe "Co2.inTonsCo2e"
            [ Co2.kgCo2e 1
                |> Co2.inTonsCo2e
                |> Expect.within (Expect.Absolute 0.0001) 0.001
                |> asTest "inTonsCo2e should convert Tons"
            ]
        , describe "Co2.co2ePerMass"
            [ Mass.kilograms 0.17
                |> Co2.co2ePerMass (Co2.kgCo2e 0.2)
                |> Expect.equal (Co2.kgCo2e 0.034)
                |> asTest "should compute kgCo2e per kg"
            , Mass.grams 170
                |> Co2.co2ePerMass (Co2.kgCo2e 0.2)
                |> Expect.equal (Co2.kgCo2e 0.034)
                |> asTest "should compute kgCo2e per kg from other mass input unit"
            , Mass.grams 170
                |> Co2.co2ePerMass (Co2.kgCo2e -0.2)
                |> Expect.equal (Co2.kgCo2e -0.034)
                |> asTest "should compute negative kgCo2e per kg"
            ]
        , describe "Co2.co2ePerKWh"
            [ Energy.kilowattHours 1
                |> Co2.co2ePerKWh (Co2.kgCo2e 0.2)
                |> expectKgCo2Float 0.2
                |> asTest "should compute kgCo2e per KWh"
            ]
        , describe "Co2.ratioedCo2ePerMass"
            [ Mass.kilograms 1
                |> Co2.ratioedCo2ePerMass ( Co2.kgCo2e 0.25, Co2.kgCo2e 0.75 ) 0.5
                |> expectKgCo2Float 0.5
                |> asTest "should compute co2 from ratioed co2 impacts and mass"
            ]
        , describe "Co2.ratioedCo2ePerKWh"
            [ Energy.kilowattHours 1
                |> Co2.ratioedCo2ePerKWh ( Co2.kgCo2e 0.25, Co2.kgCo2e 0.75 ) 0.5
                |> expectKgCo2Float 0.5
                |> asTest "should compute co2 from ratioed co2 impacts and energy"
            ]
        ]
