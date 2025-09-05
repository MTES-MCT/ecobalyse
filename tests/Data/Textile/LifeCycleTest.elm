module Data.Textile.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Query exposing (Query, tShirtCotonFrance)
import Expect
import Length
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


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
                    |> LifeCycle.fromQuery db
                    |> Result.andThen (lifeCycleToTransports db tShirtCotonFrance)
                    |> Result.map LifeCycle.computeTotalTransportImpacts
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 2500, 11961 ))
                    |> asTest "should compute default distances"
                , let
                    tShirtCotonEnnoblementIndia =
                        { tShirtCotonFrance
                            | countryFabric = Just (Country.Code "FR")
                            , countryDyeing = Just (Country.Code "IN") -- Ennoblement in India
                            , countryMaking = Just (Country.Code "FR")
                        }
                  in
                  tShirtCotonEnnoblementIndia
                    |> LifeCycle.fromQuery db
                    |> Result.andThen (lifeCycleToTransports db tShirtCotonEnnoblementIndia)
                    |> Result.map LifeCycle.computeTotalTransportImpacts
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 1500, 35883 ))
                    |> asTest "should compute custom distances"
                ]
            ]
        )
