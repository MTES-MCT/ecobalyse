module Data.Textile.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Textile.Inputs exposing (tShirtCotonFrance)
import Data.Textile.LifeCycle as LifeCycle
import Expect
import Length
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


km =
    Length.kilometers


suite : Test
suite =
    suiteWithDb "Data.LifeCycle"
        (\{ textileDb } ->
            [ describe "computeTransportSummary"
                [ tShirtCotonFrance
                    |> LifeCycle.fromQuery textileDb
                    |> Result.andThen (LifeCycle.computeStepsTransport textileDb)
                    |> Result.map (LifeCycle.computeTotalTransportImpacts textileDb)
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 3000, 21549 ))
                    |> asTest "should compute default distances"
                , LifeCycle.fromQuery textileDb
                    { tShirtCotonFrance
                        | countryFabric = Country.Code "FR"
                        , countryDyeing = Country.Code "IN" -- Ennoblement in India
                        , countryMaking = Country.Code "FR"
                    }
                    |> Result.andThen (LifeCycle.computeStepsTransport textileDb)
                    |> Result.map (LifeCycle.computeTotalTransportImpacts textileDb)
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 2000, 45471 ))
                    |> asTest "should compute custom distances"
                ]
            ]
        )
