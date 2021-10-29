module Data.FormulaTest exposing (..)

import Data.Formula as Formula
import Energy
import Expect exposing (Expectation)
import Mass exposing (Mass)
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


kg : Float -> Mass
kg =
    Mass.kilograms


suite : Test
suite =
    describe "Data.Formula"
        [ describe "Formula.genericWaste"
            [ kg 1
                |> Formula.genericWaste (kg 0.5)
                |> Expect.equal { mass = kg 1.5, waste = kg 0.5 }
                |> asTest "should compute material waste"
            ]
        , describe "Formula.materialRecycledWaste"
            [ kg 1
                |> Formula.materialRecycledWaste
                    { pristineWaste = kg 0.25
                    , recycledWaste = kg 0.5
                    , recycledRatio = 0.5
                    }
                |> Expect.equal { mass = kg 1.375, waste = kg 0.375 }
                |> asTest "should compute material waste from ratioed recycled material"
            ]
        , describe "Formula.makingWaste"
            [ kg 1
                |> Formula.makingWaste
                    { processWaste = kg 0.5
                    , pcrWaste = 0.5
                    }
                |> Expect.equal { mass = kg 3, waste = kg 2 }
                |> asTest "should compute material waste from material and product waste data"
            ]
        , describe "Formula.materialCo2"
            [ kg 1
                |> Formula.materialCo2 0.5
                |> Expect.within (Expect.Absolute 0.01) 0.5
                |> asTest "should compute co2 from climate change process data"
            ]
        , describe "Formula.materialRecycledCo2"
            [ kg 1
                |> Formula.materialRecycledCo2
                    { pristineClimateChange = 0.25
                    , recycledClimateChange = 0.75
                    , recycledRatio = 0.5
                    }
                |> Expect.within (Expect.Absolute 0.01) 0.5
                |> asTest "should compute co2 from ratioed recycled material"
            ]
        , describe "Formula.makingCo2"
            (let
                res =
                    kg 1
                        |> Formula.makingCo2
                            { makingClimateChange = 0.5
                            , makingElec = Energy.megajoules 0.5
                            , countryElecClimateChange = 0.5
                            }
             in
             [ res.co2
                |> Expect.within (Expect.Absolute 0.01) 0.57
                |> asTest "should compute Making step co2 from process and country data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 0.138
                |> asTest "should compute Making step kwh from process and country data"
             ]
            )
        ]
