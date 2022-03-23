module Data.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Inputs exposing (tShirtCotonFrance)
import Data.LifeCycle as LifeCycle
import Expect
import Length
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


km =
    Length.kilometers


suite : Test
suite =
    suiteWithDb "Data.LifeCycle"
        (\db ->
            [ describe "computeTransportSummary"
                [ tShirtCotonFrance
                    |> LifeCycle.fromQuery db
                    |> Result.andThen (LifeCycle.computeStepsTransport db)
                    |> Result.map (LifeCycle.computeTotalTransportImpacts db)
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 4542.25, 16161.75 ))
                    |> asTest "should compute default distances"
                , LifeCycle.fromQuery db
                    { tShirtCotonFrance
                        | countryFabric = Country.Code "FR"
                        , countryDyeing = Country.Code "IN" -- Ennoblement in India
                        , countryMaking = Country.Code "FR"
                    }
                    |> Result.andThen (LifeCycle.computeStepsTransport db)
                    |> Result.map (LifeCycle.computeTotalTransportImpacts db)
                    |> Result.map (\{ road, sea } -> ( Length.inKilometers road, Length.inKilometers sea ))
                    |> Expect.equal (Ok ( 7182.75, 34103.25 ))
                    |> asTest "should compute custom distances"
                ]
            ]
        )
