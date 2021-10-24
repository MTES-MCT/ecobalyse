module Data.TransportTest exposing (..)

import Data.Country as Country
import Data.Transport as Transport exposing (Transport)
import Expect
import Test exposing (..)
import TestDb exposing (testDb)


franceChina : Transport
franceChina =
    { road = 0, sea = 21548, air = 8200 }


suite : Test
suite =
    case testDb of
        Ok db ->
            describe "Data.Transport"
                [ describe "getTransportBetween"
                    [ test "should retrieve distance between two countries" <|
                        \_ ->
                            db.transports
                                |> Transport.getTransportBetween (Country.Code "FR") (Country.Code "CN")
                                |> Expect.equal franceChina
                    , test "should retrieve distance between two swapped countries" <|
                        \_ ->
                            db.transports
                                |> Transport.getTransportBetween (Country.Code "CN") (Country.Code "FR")
                                |> Expect.equal franceChina
                    , test "should apply default inland transport when country is the same" <|
                        \_ ->
                            db.transports
                                |> Transport.getTransportBetween (Country.Code "FR") (Country.Code "FR")
                                |> Expect.equal Transport.defaultInland
                    ]
                ]

        Err error ->
            describe "Data.Transport"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
