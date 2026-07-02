module Data.TransportTest exposing (..)

import Data.Component.Config as ComponentConfig
import Data.Country.Code as CountryCode
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport, getTransportBetweenLegacy)
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
    { road = km 9909
    , roadCooled = km 0
    , sea = km 19930
    , seaCooled = km 0
    , air = km 8598
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
                            |> asTest ("Country " ++ CountryCode.toString code ++ " should have transports data available")
                    )
                |> describe "transports data availability checks"
            , describe "applyTransportRatios"
                [ describe "without air transport"
                    [ it "should handle ratio with empty distances"
                        ({ road = 0, sea = 0, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 0, 0, 0 )
                        )
                    , it "should take 100% road distance below the 3000km threshold"
                        ({ road = 2800, sea = 4000, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 2800, 0, 0 )
                        )
                    , it "should take 100% sea distance at or above the 3000km threshold"
                        ({ road = 5000, sea = 10000, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 0, 10000, 0 )
                        )
                    , it "should take 100% sea distance when no road distance"
                        ({ road = 0, sea = 11310, air = 7300 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 0, 11310, 0 )
                        )
                    , it "should fall back to road past the threshold and no sea transport"
                        ({ road = 5000, sea = 0, air = 0 }
                            |> testTransportRatio Split.zero
                            |> Expect.equal ( 5000, 0, 0 )
                        )
                    ]
                , describe "with air transport"
                    [ let
                        transport =
                            { road = 1000, sea = 5000, air = 5000 }
                      in
                      Split.fromFloat 0.5
                        |> Result.map (\split -> testTransportRatio split transport)
                        |> Expect.equal (Ok ( 500, 0, 2500 ))
                        |> asTest "should handle air transport ratio"
                    ]
                ]
            , TestUtils.suiteFromResult "computeImpacts"
                (ComponentConfig.default db)
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
                    |> Transport.getTransportBetweenLegacy Impact.empty CountryCode.france CountryCode.china
                    |> Expect.equal chinaToFrance
                    |> asTest "should retrieve distance between two countries"
                , db.distances
                    |> Transport.getTransportBetweenLegacy Impact.empty CountryCode.china CountryCode.france
                    |> Expect.equal chinaToFrance
                    |> asTest "should retrieve distance between two swapped countries"
                , db.countries
                    |> List.map .code
                    |> LE.uniquePairs
                    |> List.map
                        (\( cA, cB ) ->
                            db.distances
                                |> getTransportBetweenLegacy Impact.empty cA cB
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
