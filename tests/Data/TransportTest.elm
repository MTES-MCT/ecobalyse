module Data.TransportTest exposing (..)

import Data.Country as Country
import Data.Transport as Transport exposing (Transport)
import Expect
import Length
import Quantity
import Test exposing (..)
import TestDb exposing (testDb)


km =
    Length.kilometers


franceChina : Transport
franceChina =
    { road = km 0
    , sea = km 21548
    , air = km 8200
    , cch = Quantity.zero
    , fwe = Quantity.zero
    , impact = Quantity.zero
    }


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
