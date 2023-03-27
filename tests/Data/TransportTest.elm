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
    { road = km 8169
    , roadCooled = km 0
    , sea = km 21549
    , seaCooled = km 0
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
                            |> Expect.equal True
                            |> asTest (Country.codeToString code ++ "should have transports data available")
                    )
                |> describe "transports data availability checks"
            , describe "getTransportBetween"
                [ textileDb.transports
                    |> Transport.getTransportBetween Scope.Textile defaultImpacts (Country.Code "FR") (Country.Code "CN")
                    |> Expect.equal (franceChina defaultImpacts)
                    |> asTest "should retrieve distance between two countries"
                , textileDb.transports
                    |> Transport.getTransportBetween Scope.Textile defaultImpacts (Country.Code "CN") (Country.Code "FR")
                    |> Expect.equal (franceChina defaultImpacts)
                    |> asTest "should retrieve distance between two swapped countries"
                , textileDb.transports
                    |> Transport.getTransportBetween Scope.Textile defaultImpacts (Country.Code "FR") (Country.Code "FR")
                    |> Expect.equal (Transport.defaultInland Scope.Textile defaultImpacts)
                    |> asTest "should apply default inland transport when country is the same"
                ]
            ]
        )
