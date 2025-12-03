module Data.Textile.FormulaTest exposing (..)

import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Textile.Formula as Formula
import Data.Textile.MakingComplexity as MakingComplexity
import Data.Unit as Unit
import Energy
import Expect
import Mass exposing (Mass)
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


kg : Float -> Mass
kg =
    Mass.kilograms


suite : Test
suite =
    suiteWithDb "Data.Formula"
        (\db ->
            let
                sampleProcess =
                    db.textile.wellKnown.fading

                defaultImpacts =
                    Impact.empty
                        |> Impact.updateImpact db.definitions Definition.Cch Quantity.zero
                        |> Impact.updateImpact db.definitions Definition.Fwe Quantity.zero
            in
            [ describe "Formula.genericWaste"
                [ kg 1
                    |> Formula.genericWaste Split.half
                    |> Expect.equal { mass = kg 2, waste = kg 1 }
                    |> asTest "should compute generic waste using input waste ratio"
                ]
            , describe "Formula.makingDeadStock"
                [ kg 1
                    |> Formula.makingDeadStock Split.half
                    |> Expect.equal { mass = kg 2, deadstock = kg 1 }
                    |> asTest "should compute deadstock from deadstock data"
                ]
            , describe "Formula.makingImpact"
                (let
                    res =
                        kg 1
                            |> Formula.makingImpacts
                                defaultImpacts
                                { makingComplexity = MakingComplexity.Medium
                                , fadingProcess = Nothing
                                , countryElecProcess =
                                    { sampleProcess
                                        | impacts =
                                            Impact.empty
                                                |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 0.5)
                                                |> Impact.updateImpact db.definitions Definition.Fwe (Unit.impact 1.5)
                                    }
                                , countryHeatProcess =
                                    { sampleProcess
                                        | impacts =
                                            Impact.empty
                                                |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 0.5)
                                                |> Impact.updateImpact db.definitions Definition.Fwe (Unit.impact 1.5)
                                    }
                                }
                 in
                 [ res.impacts
                    |> Impact.getImpact Definition.Cch
                    |> Unit.impactToFloat
                    |> Expect.within (Expect.Absolute 0.01) 0.435
                    |> asTest "should compute Making step cch from process and country data"
                 , res.impacts
                    |> Impact.getImpact Definition.Fwe
                    |> Unit.impactToFloat
                    |> Expect.within (Expect.Absolute 0.01) 1.305
                    |> asTest "should compute Making step fwe from process and country data"
                 , res.kwh
                    |> Energy.inKilowattHours
                    |> Expect.within (Expect.Absolute 0.01) 0.87
                    |> asTest "should compute Making step kwh from process and country data"
                 ]
                )
            , describe "Formula.weavingImpact"
                (let
                    res =
                        Formula.weavingImpacts
                            defaultImpacts
                            { countryElecProcess =
                                { sampleProcess
                                    | impacts =
                                        Impact.empty
                                            |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 8.13225e-2)
                                            |> Impact.updateImpact db.definitions Definition.Fwe (Unit.impact 3.26897e-8)
                                }
                            , outputMass = kg 0.478
                            , pickingElec = 1
                            , surfaceMass = Unit.gramsPerSquareMeter 180
                            , yarnSize = Unit.yarnSizeKilometersPerKg 45
                            }
                 in
                 [ res.picking
                    |> Expect.equal (Just (Unit.pickPerMeter 9958))
                    |> asTest "should compute Fabric step picking"

                 --  , res.impacts
                 --     |> Impact.getImpact (Definition.Cch)
                 --     |> Unit.impactToFloat
                 --     |> Expect.within (Expect.Absolute 0.01) 0.8
                 --     |> asTest "should compute Fabric step cch impact"
                 --  , res.impacts
                 --     |> Impact.getImpact (Definition.Fwe)
                 --     |> Unit.impactToFloat
                 --     |> Expect.within (Expect.Absolute 0.01) 4
                 --     |> asTest "should compute Fabric step fwe impact"
                 --  , res.kwh
                 --     |> Energy.inKilowattHours
                 --     |> Expect.within (Expect.Absolute 0.01) 8
                 --     |> asTest "should compute Fabric step elec"
                 ]
                )
            , describe "Formula.knittingImpact"
                (let
                    res =
                        kg 1
                            |> Formula.knittingImpacts
                                defaultImpacts
                                { elec = Energy.kilowattHours 5
                                , countryElecProcess =
                                    { sampleProcess
                                        | impacts =
                                            Impact.empty
                                                |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 0.2)
                                                |> Impact.updateImpact db.definitions Definition.Fwe (Unit.impact 0.5)
                                    }
                                }
                 in
                 [ res.impacts
                    |> Impact.getImpact Definition.Cch
                    |> Unit.impactToFloat
                    |> Expect.within (Expect.Absolute 0.01) 1
                    |> asTest "should compute KnittingWeaving step cch from process and product data"
                 , res.impacts
                    |> Impact.getImpact Definition.Fwe
                    |> Unit.impactToFloat
                    |> Expect.within (Expect.Absolute 0.01) 2.5
                    |> asTest "should compute KnittingWeaving step fwe from process and product data"
                 , res.kwh
                    |> Energy.inKilowattHours
                    |> Expect.within (Expect.Absolute 0.01) 5
                    |> asTest "should compute KnittingWeaving step kwh from process and product data"
                 ]
                )
            ]
        )
