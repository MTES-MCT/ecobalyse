module Data.FormulaTest exposing (..)

import Data.Formula as Formula
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
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
        , describe "Formula.materialRecycledWaste"
            [ kg 1
                |> Formula.materialRecycledWaste
                    { pristineWaste = kg 0.25
                    , recycledWaste = kg 0.5
                    , recycledRatio = Unit.Ratio 0.5
                    }
                |> Expect.equal { mass = kg 1.375, waste = kg 0.375 }
                |> asTest "should compute material waste from ratioed recycled material"
            ]
        , describe "Formula.makingWaste"
            [ kg 1
                |> Formula.makingWaste
                    { processWaste = kg 0.5
                    , pcrWaste = Unit.ratio 0.5
                    }
                |> Expect.equal { mass = kg 3, waste = kg 2 }
                |> asTest "should compute material waste from material and product waste data"
            ]
        , describe "Formula.makingImpact"
            (let
                res =
                    kg 1
                        |> Formula.makingImpacts
                            defaultImpacts
                            { makingProcess =
                                { noOpProcess
                                    | elec = Energy.megajoules 0.5
                                }
                            , countryElecProcess =
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
                |> Expect.within (Expect.Absolute 0.01) 0.07
                |> asTest "should compute Making step cch from process and country data"
             , res.impacts
                |> Impact.getImpact (Impact.trg "fwe")
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.208
                |> asTest "should compute Making step fwe from process and country data"
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
                        |> Formula.weavingImpacts
                            defaultImpacts
                            { elecPppm = 0.01
                            , countryElecProcess =
                                { noOpProcess
                                    | impacts =
                                        AnyDict.fromList Impact.toString
                                            [ ( Impact.trg "cch", Unit.impact 0.1 )
                                            , ( Impact.trg "fwe", Unit.impact 0.5 )
                                            ]
                                }
                            , ppm = 400
                            , grammage = 500
                            }
             in
             [ res.impacts
                |> Impact.getImpact (Impact.trg "cch")
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.8
                |> asTest "should compute KnittingWeaving step cch from process and product data"
             , res.impacts
                |> Impact.getImpact (Impact.trg "fwe")
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) 4
                |> asTest "should compute KnittingWeaving step fwe from process and product data"
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
                    |> testTransportRatio (Unit.ratio 0)
                    |> Expect.equal ( 0, 0, 0 )
                    |> asTest "should handle ratio with empty distances"
                , { road = 400, sea = 200, air = 0 }
                    |> testTransportRatio (Unit.ratio 0)
                    |> Expect.equal ( 400, 0, 0 )
                    |> asTest "should handle ratio for road < 500km"
                , { road = 900, sea = 1000, air = 0 }
                    |> testTransportRatio (Unit.ratio 0)
                    |> Expect.equal ( 810, 100, 0 )
                    |> asTest "should handle ratio for road < 1000km"
                , { road = 1800, sea = 1000, air = 0 }
                    |> testTransportRatio (Unit.ratio 0)
                    |> Expect.equal ( 900, 500, 0 )
                    |> asTest "should handle ratio for road < 2000km"
                , { road = 4000, sea = 10000, air = 0 }
                    |> testTransportRatio (Unit.ratio 0)
                    |> Expect.equal ( 1000, 7500, 0 )
                    |> asTest "should handle ratio for road > 2000km"
                , { road = 0, sea = 11310, air = 7300 }
                    |> testTransportRatio (Unit.ratio 0)
                    |> Expect.equal ( 0, 11310, 0 )
                    |> asTest "should handle case where road=0km"
                ]
            , describe "with air transport ratio"
                [ { road = 1000, sea = 5000, air = 5000 }
                    |> testTransportRatio (Unit.ratio 0.5)
                    |> Expect.equal ( 250, 1250, 2500 )
                    |> asTest "should handle air transport ratio"
                ]
            ]
        ]


testTransportRatio : Unit.Ratio -> { road : Float, sea : Float, air : Float } -> ( Int, Int, Int )
testTransportRatio airTransportRatio { road, sea, air } =
    { road = km road
    , sea = km sea
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
