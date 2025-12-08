module Data.TransportTest exposing (..)

import Data.Component.Config as ComponentConfig
import Data.Country as Country
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport, getTransportBetween)
import Data.Unit as Unit
import Dict.Any as AnyDict
import Expect
import Length
import List.Extra as LE
import Mass
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, it, suiteWithDb)


km : Float -> Length.Length
km =
    Length.kilometers


chinaToFrance : Transport
chinaToFrance =
    { road = km 9005
    , roadCooled = km 0
    , sea = km 21549
    , seaCooled = km 0
    , air = km 8189
    , impacts = Impact.empty
    }


suite : Test
suite =
    suiteWithDb "Data.Transport"
        (\db ->
            [ db.countries
                |> List.map
                    (\{ code } ->
                        AnyDict.keys db.distances
                            |> List.member code
                            |> Expect.equal True
                            |> asTest ("Country " ++ Country.codeToString code ++ " should have transports data available")
                    )
                |> describe "transports data availability checks"
            , describe "applyTransportRatios"
                [ describe "without air transport"
                    [ it "should handle ratio with empty distances"
                        ({ road = 0, sea = 0, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 0, 0, 0 )
                        )
                    , it "should handle ratio for road < 500km"
                        ({ road = 400, sea = 200, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 400, 0, 0 )
                        )
                    , it "should handle ratio for road < 1000km"
                        ({ road = 900, sea = 1000, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 810, 100, 0 )
                        )
                    , it "should handle ratio for road < 2000km"
                        ({ road = 1800, sea = 1000, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 900, 500, 0 )
                        )
                    , it "should handle ratio for road < 3000km"
                        ({ road = 2800, sea = 4000, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 700, 3000, 0 )
                        )
                    , it "should handle ratio for road > 3000km"
                        ({ road = 5000, sea = 10000, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 0, 10000, 0 )
                        )
                    , it "should handle case where road=0km"
                        ({ road = 0, sea = 11310, air = 7300 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 0, 11310, 0 )
                        )
                    ]
                , describe "with air transport"
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
            , TestUtils.suiteFromResult "computeImpacts"
                (ComponentConfig.default db.processes db.countries)
                (\{ transports } ->
                    [ it "should compute transport impacts"
                        (chinaToFrance
                            |> Transport.computeImpacts transports.modeProcesses Mass.kilogram
                            |> .impacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.greaterThan 0
                        )
                    ]
                )
            , describe "getTransportBetween"
                [ db.distances
                    |> Transport.getTransportBetween Impact.empty (Country.Code "FR") (Country.Code "CN")
                    |> Expect.equal chinaToFrance
                    |> asTest "should retrieve distance between two countries"
                , db.distances
                    |> Transport.getTransportBetween Impact.empty (Country.Code "CN") (Country.Code "FR")
                    |> Expect.equal chinaToFrance
                    |> asTest "should retrieve distance between two swapped countries"
                , db.countries
                    |> List.map .code
                    |> LE.uniquePairs
                    |> List.map
                        (\( cA, cB ) ->
                            db.distances
                                |> getTransportBetween Impact.empty cA cB
                        )
                    |> List.filter
                        (\{ road, sea, air } ->
                            Quantity.sum [ road, sea, air ] == Quantity.zero
                        )
                    |> List.length
                    |> Expect.equal 0
                    |> asTest "should always give a distance greater than 0 between two countries"
                ]
            ]
        )


testTransportRatio : Split -> { road : Float, sea : Float, air : Float } -> ( Int, Int, Int )
testTransportRatio airTransportRatio { road, sea, air } =
    { road = km road
    , roadCooled = km 0
    , sea = km sea
    , seaCooled = km 0
    , air = km air
    , impacts = Impact.empty
    }
        |> Transport.applyTransportRatios airTransportRatio
        |> (\t ->
                ( t.road |> Length.inKilometers |> round
                , t.sea |> Length.inKilometers |> round
                , t.air |> Length.inKilometers |> round
                )
           )
