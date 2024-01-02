module Data.Textile.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs exposing (tShirtCotonFrance)
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Expect
import Length
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


km : Float -> Length.Length
km =
    Length.kilometers


lifeCycleToTransports : TextileDb.Db -> Inputs.Query -> LifeCycle -> Result String LifeCycle
lifeCycleToTransports textileDb query lifeCycle =
    query
        |> Inputs.fromQuery textileDb
        |> Result.map
            (\materials ->
                LifeCycle.computeStepsTransport textileDb materials lifeCycle
            )


suite : Test
suite =
    suiteWithDb "Data.LifeCycle"
        (\{ textileDb } ->
            [ describe "computeTransportSummary"
                [ tShirtCotonFrance
                    |> LifeCycle.fromQuery textileDb
                    |> Result.andThen (lifeCycleToTransports textileDb tShirtCotonFrance)
                    |> Result.map LifeCycle.computeTotalTransportImpacts
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 3000, 21549 ))
                    |> asTest "should compute default distances"
                , let
                    tShirtCotonEnnoblementIndia =
                        { tShirtCotonFrance
                            | countryFabric = Country.Code "FR"
                            , countryDyeing = Country.Code "IN" -- Ennoblement in India
                            , countryMaking = Country.Code "FR"
                        }
                  in
                  tShirtCotonEnnoblementIndia
                    |> LifeCycle.fromQuery textileDb
                    |> Result.andThen (lifeCycleToTransports textileDb tShirtCotonEnnoblementIndia)
                    |> Result.map LifeCycle.computeTotalTransportImpacts
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 2000, 45471 ))
                    |> asTest "should compute custom distances"
                ]
            ]
        )
