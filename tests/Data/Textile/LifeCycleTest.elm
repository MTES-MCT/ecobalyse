module Data.Textile.LifeCycleTest exposing (..)

import Data.Country.Code as CountryCode
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Query exposing (Query)
import Expect
import Length
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb, tShirtCotonFrance)


lifeCycleToTransports : Db -> Query -> LifeCycle -> Result String LifeCycle
lifeCycleToTransports db query lifeCycle =
    query
        |> Inputs.fromQuery db
        |> Result.map
            (\materials ->
                LifeCycle.computeStepsTransport db materials lifeCycle
            )


suite : Test
suite =
    suiteWithDb "Data.LifeCycle"
        (\db ->
            [ describe "computeTransportSummary"
                [ tShirtCotonFrance
                    |> Result.andThen
                        (\query ->
                            query
                                |> LifeCycle.fromQuery db
                                |> Result.andThen (lifeCycleToTransports db query)
                                |> Result.map LifeCycle.computeTotalTransportImpacts
                                |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                        )
                    |> Expect.equal (Ok ( 2500, 21549 ))
                    |> asTest "should compute default distances"
                , let
                    tShirtCotonEnnoblementIndia =
                        tShirtCotonFrance
                            |> Result.map
                                (\query ->
                                    { query
                                        | countryFabric = Just (CountryCode.Code "FR")
                                        , countryDyeing = Just (CountryCode.Code "IN") -- Ennoblement in India
                                        , countryMaking = Just (CountryCode.Code "FR")
                                    }
                                )
                  in
                  tShirtCotonEnnoblementIndia
                    |> Result.andThen
                        (\query ->
                            query
                                |> LifeCycle.fromQuery db
                                |> Result.andThen (lifeCycleToTransports db query)
                                |> Result.map LifeCycle.computeTotalTransportImpacts
                                |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                        )
                    |> Expect.equal (Ok ( 1500, 45471 ))
                    |> asTest "should compute custom distances"
                ]
            ]
        )
