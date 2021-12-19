module Data.FormulaTest exposing (..)

import Data.Formula as Formula
import Data.Impact as Impact
import Data.Process exposing (noOpProcess)
import Data.Unit as Unit
import Dict.Any as AnyDict
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
        , describe "Formula.makingImpact"
            (let
                res =
                    kg 1
                        |> Formula.makingImpact
                            Impact.defaultTrigram
                            { makingProcess =
                                { noOpProcess
                                    | elec = Energy.megajoules 0.5
                                }
                            , countryElecProcess =
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impactFromFloat 0.5 )
                                            , ( Impact.trg "fwe", Unit.impactFromFloat 0.5 )
                                            ]
                                }
                            }
             in
             [ res.impact
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.07
                |> asTest "should compute Making step cch from process and country data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 0.138
                |> asTest "should compute Making step kwh from process and country data"
             ]
            )
        , describe "Formula.weavingImpact"
            (let
                res =
                    kg 1
                        |> Formula.weavingImpact
                            Impact.defaultTrigram
                            { elecPppm = 0.01
                            , countryElecProcess =
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impactFromFloat 0.1 )
                                            , ( Impact.trg "fwe", Unit.impactFromFloat 0.5 )
                                            ]
                                }
                            , ppm = 400
                            , grammage = 500
                            }
             in
             [ res.impact
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.8
                |> asTest "should compute KnittingWeaving step cch from process and product data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 8
                |> asTest "should compute KnittingWeaving step kwh from process and product data"
             ]
            )
        , describe "Formula.knittingImpact"
            (let
                res =
                    kg 1
                        |> Formula.knittingImpact
                            Impact.defaultTrigram
                            { elec = Energy.kilowattHours 5
                            , countryElecProcess =
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impactFromFloat 0.2 )
                                            , ( Impact.trg "fwe", Unit.impactFromFloat 0.5 )
                                            ]
                                }
                            }
             in
             [ res.impact
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 1
                |> asTest "should compute KnittingWeaving step cch from process and product data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 5
                |> asTest "should compute KnittingWeaving step kwh from process and product data"
             ]
            )
        ]
