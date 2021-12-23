module Data.TransportTest exposing (..)

import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
import Data.Transport as Transport exposing (Transport)
import Expect
import Length
import Test exposing (..)
import TestDb exposing (testDb)


km =
    Length.kilometers


franceChina : Impacts -> Transport
franceChina impacts =
    { road = km 0
    , sea = km 21548
    , air = km 8200
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
                [ describe "getTransportBetween"
                    [ test "should retrieve distance between two countries" <|
                        \_ ->
                            db.transports
                                |> Transport.getTransportBetween defaultImpacts (Country.Code "FR") (Country.Code "CN")
                                |> Expect.equal (franceChina defaultImpacts)
                    , test "should retrieve distance between two swapped countries" <|
                        \_ ->
                            db.transports
                                |> Transport.getTransportBetween defaultImpacts (Country.Code "CN") (Country.Code "FR")
                                |> Expect.equal (franceChina defaultImpacts)
                    , test "should apply default inland transport when country is the same" <|
                        \_ ->
                            db.transports
                                |> Transport.getTransportBetween defaultImpacts (Country.Code "FR") (Country.Code "FR")
                                |> Expect.equal
                                    (Transport.defaultInland defaultImpacts)
                    ]
                ]

        Err error ->
            describe "Data.Transport"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
