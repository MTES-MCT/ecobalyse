module Data.FormulaTest exposing (..)

import Data.Formula as Formula
import Data.Process exposing (noOpProcess)
import Data.Unit as Unit
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
        , describe "Formula.makingImpacts"
            (let
                res =
                    kg 1
                        |> Formula.makingImpacts
                            { makingProcess =
                                { noOpProcess
                                    | elec = Energy.megajoules 0.5
                                }
                            , countryElecProcess =
                                { noOpProcess
                                    | climateChange = Unit.kgCo2e 0.5
                                    , freshwaterEutrophication = Unit.kgPe 0.5
                                }
                            }
             in
             [ res.co2
                |> Unit.inKgCo2e
                |> Expect.within (Expect.Absolute 0.01) 0.07
                |> asTest "should compute Making step co2 from process and country data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 0.138
                |> asTest "should compute Making step kwh from process and country data"
             , res.fwe
                |> Unit.inKgPe
                |> Expect.within (Expect.Absolute 0.01) 0.07
                |> asTest "should compute Making step fwe from process and country data"
             ]
            )
        , describe "Formula.weavingCo2"
            (let
                res =
                    kg 1
                        |> Formula.weavingCo2
                            { elecPppm = 0.01
                            , elecCC = Unit.kgCo2e 0.1
                            , ppm = 400
                            , grammage = 500
                            }
             in
             [ res.co2
                |> Unit.inKgCo2e
                |> Expect.within (Expect.Absolute 0.01) 0.8
                |> asTest "should compute KnittingWeaving step co2 from process and product data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 8
                |> asTest "should compute KnittingWeaving step kwh from process and product data"
             ]
            )
        , describe "Formula.knittingCo2"
            (let
                res =
                    kg 1
                        |> Formula.knittingCo2
                            { elec = Energy.kilowattHours 5
                            , elecCC = Unit.kgCo2e 0.2
                            }
             in
             [ res.co2
                |> Unit.inKgCo2e
                |> Expect.within (Expect.Absolute 0.01) 1
                |> asTest "should compute KnittingWeaving step co2 from process and product data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 5
                |> asTest "should compute KnittingWeaving step kwh from process and product data"
             ]
            )
        ]
