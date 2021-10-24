module Data.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Inputs exposing (tShirtCotonFrance)
import Data.LifeCycle as LifeCycle
import Expect
import Test exposing (..)
import TestDb exposing (testDb)


suite : Test
suite =
    case testDb of
        Ok db ->
            describe "Data.LifeCycle"
                [ describe "computeTransportSummary"
                    [ test "should compute default distances" <|
                        \_ ->
                            tShirtCotonFrance
                                |> LifeCycle.fromQuery db
                                |> Result.andThen (LifeCycle.computeTransportSummaries db)
                                |> Result.map LifeCycle.computeTransportSummary
                                |> Expect.equal
                                    (Ok { air = 0, road = 4500, sea = 25548, co2 = 0 })
                    , test "should compute custom distances" <|
                        \_ ->
                            LifeCycle.fromQuery db
                                { tShirtCotonFrance
                                    | countries =
                                        [ Country.Code "CN"
                                        , Country.Code "FR"
                                        , Country.Code "IN" -- Ennoblement in India
                                        , Country.Code "FR"
                                        , Country.Code "FR"
                                        ]
                                }
                                |> Result.andThen (LifeCycle.computeTransportSummaries db)
                                |> Result.map LifeCycle.computeTransportSummary
                                |> Expect.equal
                                    (Ok { air = 0, road = 3000, sea = 61428, co2 = 0 })
                    ]
                ]

        Err error ->
            describe "Data.LifeCycle"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
