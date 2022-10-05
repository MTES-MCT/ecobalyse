module Data.TransportTest exposing (..)

import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
import Data.Transport as Transport exposing (Transport)
import Dict.Any as AnyDict
import Expect
import Length
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


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
    suiteWithDb "Data.Transport"
        (\{ textileDb } ->
            let
                defaultImpacts =
                    Impact.impactsFromDefinitons textileDb.impacts
            in
            [ textileDb.countries
                |> List.map
                    (\{ code } ->
                        AnyDict.keys textileDb.transports
                            |> List.member code
                            |> Expect.true (Country.codeToString code ++ " has no transports data available")
                            |> asTest (Country.codeToString code)
                    )
                |> describe "transports data availability checks"
            , describe "getTransportBetween"
                [ textileDb.transports
                    |> Transport.getTransportBetween defaultImpacts (Country.Code "FR") (Country.Code "CN")
                    |> Expect.equal (franceChina defaultImpacts)
                    |> asTest "should retrieve distance between two countries"
                , textileDb.transports
                    |> Transport.getTransportBetween defaultImpacts (Country.Code "CN") (Country.Code "FR")
                    |> Expect.equal (franceChina defaultImpacts)
                    |> asTest "should retrieve distance between two swapped countries"
                , textileDb.transports
                    |> Transport.getTransportBetween defaultImpacts (Country.Code "FR") (Country.Code "FR")
                    |> Expect.equal (Transport.defaultInland defaultImpacts)
                    |> asTest "should apply default inland transport when country is the same"
                ]
            ]
        )
