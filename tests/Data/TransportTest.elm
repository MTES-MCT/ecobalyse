module Data.TransportTest exposing (..)

import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
import Data.Transport as Transport exposing (Transport)
import Dict.Any as AnyDict
import Expect
import Length
import Test exposing (..)
import TestDb exposing (testDb)
import TestUtils exposing (asTest)


km =
    Length.kilometers


franceChina : Impacts -> Transport
franceChina impacts =
    { road = km 8169
    , sea = km 21549
    , air = km 8189
    , impacts = impacts
    }


suite : Test
suite =
    case testDb of
        Ok db ->
            let
                defaultImpacts =
                    Impact.impactsFromDefinitons db.impacts
            in
            describe "Data.Transport"
                [ db.countries
                    |> List.map
                        (\{ code } ->
                            AnyDict.keys db.transports
                                |> List.member code
                                |> Expect.true (Country.codeToString code ++ " has no transports data available")
                                |> asTest (Country.codeToString code)
                        )
                    |> describe "transports data availability checks"
                , describe "getTransportBetween"
                    [ db.transports
                        |> Transport.getTransportBetween defaultImpacts (Country.Code "FR") (Country.Code "CN")
                        |> Expect.equal (franceChina defaultImpacts)
                        |> asTest "should retrieve distance between two countries"
                    , db.transports
                        |> Transport.getTransportBetween defaultImpacts (Country.Code "CN") (Country.Code "FR")
                        |> Expect.equal (franceChina defaultImpacts)
                        |> asTest "should retrieve distance between two swapped countries"
                    , db.transports
                        |> Transport.getTransportBetween defaultImpacts (Country.Code "FR") (Country.Code "FR")
                        |> Expect.equal (Transport.defaultInland defaultImpacts)
                        |> asTest "should apply default inland transport when country is the same"
                    ]
                ]

        Err error ->
            describe "Data.Transport"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
