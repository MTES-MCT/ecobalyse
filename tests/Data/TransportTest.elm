module Data.TransportTest exposing (..)

import Data.Country.Code as CountryCode
import Data.Impact as Impact exposing (Impacts)
import Data.Transport as Transport exposing (Transport, getTransportBetween)
import Dict.Any as AnyDict
import Expect
import Length
import List.Extra as LE
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


km : Float -> Length.Length
km =
    Length.kilometers


franceChina : Impacts -> Transport
franceChina impacts =
    { road = km 9005
    , roadCooled = km 0
    , sea = km 21549
    , seaCooled = km 0
    , air = km 8189
    , impacts = impacts
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
            , describe "getTransportBetween"
                [ db.distances
                    |> Transport.getTransportBetween Impact.empty (CountryCode.Code "FR") (CountryCode.Code "CN")
                    |> Expect.equal (franceChina Impact.empty)
                    |> asTest "should retrieve distance between two countries"
                , db.distances
                    |> Transport.getTransportBetween Impact.empty (CountryCode.Code "CN") (CountryCode.Code "FR")
                    |> Expect.equal (franceChina Impact.empty)
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
