module Data.TransportTest exposing (..)

import Data.Country exposing (..)
import Data.Transport as Transport exposing (Transport)
import Expect
import Test exposing (..)


franceChina : Transport
franceChina =
    { road = 0, sea = 21548, air = 8200 }


suite : Test
suite =
    describe "Data.Transport"
        [ describe "getTransportBetween"
            [ test "should retrieve distance between two countries" <|
                \_ ->
                    Transport.getTransportBetween France China
                        |> Expect.equal franceChina
            , test "should retrieve distance between two swapped countries" <|
                \_ ->
                    Transport.getTransportBetween China France
                        |> Expect.equal franceChina
            , test "should apply default inland transport when country is the same" <|
                \_ ->
                    Transport.getTransportBetween France France
                        |> Expect.equal Transport.defaultInland
            ]
        ]
