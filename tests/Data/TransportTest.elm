module Data.TransportTest exposing (..)

import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
import Data.Scope as Scope
import Data.Transport as Transport exposing (Transport)
import Dict.Any as AnyDict
import Expect
import Length
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
                            |> asTest ("Country " ++ Country.codeToString code ++ " should have transports data available")
                    )
                |> describe "transports data availability checks"
            , describe "getTransportBetween"
                [ db.distances
                    |> Transport.getTransportBetween Scope.Textile Impact.empty (Country.Code "FR") (Country.Code "CN")
                    |> Expect.equal (franceChina Impact.empty)
                    |> asTest "should retrieve distance between two countries"
                , db.distances
                    |> Transport.getTransportBetween Scope.Textile Impact.empty (Country.Code "CN") (Country.Code "FR")
                    |> Expect.equal (franceChina Impact.empty)
                    |> asTest "should retrieve distance between two swapped countries"
                , db.distances
                    |> Transport.getTransportBetween Scope.Textile Impact.empty (Country.Code "FR") (Country.Code "FR")
                    |> Expect.equal (Transport.defaultInland Scope.Textile Impact.empty)
                    |> asTest "should apply default inland transport when country is the same"
                ]
            ]
        )
