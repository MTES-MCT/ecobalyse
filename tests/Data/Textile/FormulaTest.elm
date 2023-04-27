module Data.Textile.FormulaTest exposing (..)

import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Textile.Formula as Formula
import Data.Textile.MakingComplexity as MakingComplexity
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Dict.Any as AnyDict
import Energy
import Expect
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest)


kg : Float -> Mass
kg =
    Mass.kilograms


km : Float -> Length
km =
    Length.kilometers


defaultImpacts : Impacts
defaultImpacts =
    AnyDict.fromList Impact.toString
        [ ( Impact.trg "cch", Quantity.zero )
        , ( Impact.trg "fwe", Quantity.zero )
        ]


noOpProcess : Process
noOpProcess =
    { name = "Default"
    , info = ""
    , unit = ""
    , uuid = Process.Uuid ""
    , impacts = Impact.noImpacts
    , heat = Energy.megajoules 0
    , elec_pppm = 0
    , elec = Energy.megajoules 0
    , waste = Mass.kilograms 0
    , alias = Nothing
    }


suite : Test
suite =
    describe "Data.Formula"
        [ describe "Formula.genericWaste"
            [ kg 1
                |> Formula.genericWaste (kg 0.5)
                |> Expect.equal { mass = kg 1.5, waste = kg 0.5 }
                |> asTest "should compute material waste"
            ]
        , describe "Formula.makingWaste"
            [ kg 1
                |> Formula.makingWaste Split.half
                |> Expect.equal { mass = kg 2, waste = kg 1 }
                |> asTest "should compute material waste from material and product waste data"
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
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impact 0.5 )
                                            , ( Impact.trg "fwe", Unit.impact 1.5 )
                                            ]
                                }
                            , countryHeatProcess =
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impact 0.5 )
                                            , ( Impact.trg "fwe", Unit.impact 1.5 )
                                            ]
                                }
                            }
             in
             [ res.impacts
                |> Impact.getImpact (Impact.trg "cch")
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.435
                |> asTest "should compute Making step cch from process and country data"
             , res.impacts
                |> Impact.getImpact (Impact.trg "fwe")
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
                            { noOpProcess
                                | impacts =
                                    AnyDict.fromList Impact.toString
                                        [ ( Impact.trg "cch", Unit.impact 8.13225e-2 )
                                        , ( Impact.trg "fwe", Unit.impact 3.26897e-8 )
                                        ]
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
             --     |> Impact.getImpact (Impact.trg "cch")
             --     |> Unit.impactToFloat
             --     |> Expect.within (Expect.Absolute 0.01) 0.8
             --     |> asTest "should compute Fabric step cch impact"
             --  , res.impacts
             --     |> Impact.getImpact (Impact.trg "fwe")
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
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impact 0.2 )
                                            , ( Impact.trg "fwe", Unit.impact 0.5 )
                                            ]
                                }
                            }
             in
             [ res.impacts
                |> Impact.getImpact (Impact.trg "cch")
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 1
                |> asTest "should compute KnittingWeaving step cch from process and product data"
             , res.impacts
                |> Impact.getImpact (Impact.trg "fwe")
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 2.5
                |> asTest "should compute KnittingWeaving step fwe from process and product data"
             , res.kwh
                |> Energy.inKilowattHours
                |> Expect.within (Expect.Absolute 0.01) 5
                |> asTest "should compute KnittingWeaving step kwh from process and product data"
             ]
            )
        , describe "Formula.transportRatio"
            [ describe "no air transport ratio"
                [ { road = 0, sea = 0, air = 0 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 0, 0, 0 )
                    |> asTest "should handle ratio with empty distances"
                , { road = 400, sea = 200, air = 0 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 400, 0, 0 )
                    |> asTest "should handle ratio for road < 500km"
                , { road = 900, sea = 1000, air = 0 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 810, 100, 0 )
                    |> asTest "should handle ratio for road < 1000km"
                , { road = 1800, sea = 1000, air = 0 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 900, 500, 0 )
                    |> asTest "should handle ratio for road < 2000km"
                , { road = 2800, sea = 4000, air = 0 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 700, 3000, 0 )
                    |> asTest "should handle ratio for road < 3000km"
                , { road = 5000, sea = 10000, air = 0 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 0, 10000, 0 )
                    |> asTest "should handle ratio for road > 3000km"
                , { road = 0, sea = 11310, air = 7300 }
                    |> testTransportRatio Split.zero
                    |> Expect.equal ( 0, 11310, 0 )
                    |> asTest "should handle case where road=0km"
                ]
            , describe "with air transport ratio"
                [ let
                    transport =
                        { road = 1000, sea = 5000, air = 5000 }
                  in
                  Split.fromFloat 0.5
                    |> Result.map (\split -> testTransportRatio split transport)
                    |> Expect.equal (Ok ( 250, 1250, 2500 ))
                    |> asTest "should handle air transport ratio"
                ]
            ]
        ]


testTransportRatio : Split -> { road : Float, sea : Float, air : Float } -> ( Int, Int, Int )
testTransportRatio airTransportRatio { road, sea, air } =
    { road = km road
    , roadCooled = km 0
    , sea = km sea
    , seaCooled = km 0
    , air = km air
    , impacts = defaultImpacts
    }
        |> Formula.transportRatio airTransportRatio
        |> (\t ->
                ( t.road |> Length.inKilometers |> round
                , t.sea |> Length.inKilometers |> round
                , t.air |> Length.inKilometers |> round
                )
           )
