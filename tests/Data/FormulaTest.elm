module Data.FormulaTest exposing (..)

import Data.Formula as Formula
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
            [ Formula.genericWaste (kg 0.5) (kg 1)
                |> Expect.equal { mass = kg 1.5, waste = kg 0.5 }
                |> asTest "genericWaste should compute material waste"
            ]
        , describe "Formula.materialRecycledWaste"
            [ Formula.materialRecycledWaste (kg 0.25) (kg 0.5) 0.5 (kg 1)
                |> Expect.equal { mass = kg 1.375, waste = kg 0.375 }
                |> asTest "materialRecycledWaste should compute material waste from ratioed recycled material"
            ]
        , describe "Formula.makingWaste"
            [ Formula.makingWaste (kg 0.5) 0.5 (kg 1)
                |> Expect.equal { mass = kg 3, waste = kg 2 }
                |> asTest "makingWaste should compute material waste from material and product waste data"
            ]
        , describe "Formula.materialCo2"
            [ Formula.materialCo2 0.5 (kg 1)
                |> Expect.within (Expect.Absolute 0.01) 0.5
                |> asTest "materialCo2 should compute co2 from climate change process data"
            ]
        , describe "Formula.materialRecycledCo2"
            [ Formula.materialRecycledCo2 0.25 0.75 0.5 (kg 1)
                |> Expect.within (Expect.Absolute 0.01) 0.5
                |> asTest "materialRecycledCo2 should compute co2 from ratioed recycled material"
            ]
        ]
