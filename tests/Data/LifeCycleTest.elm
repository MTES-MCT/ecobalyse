module Data.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Impact as Impact
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
            let
                defaultImpacts =
                    Impact.impactsFromDefinitons db.impacts
            in
            [ describe "computeTransportSummary"
                [ tShirtCotonFrance
                    |> LifeCycle.fromQuery db
                    |> Result.andThen (LifeCycle.computeStepsTransport db)
                    |> Result.map (LifeCycle.computeTotalTransportImpacts db)
                    |> Expect.equal
                        (Ok
                            { road = km 2500
                            , sea = km 21548
                            , air = km 0
                            , impacts = defaultImpacts
                            }
                        )
                    |> asTest "should compute default distances"
                , LifeCycle.fromQuery db
                    { tShirtCotonFrance
                        | countryFabric = Country.Code "FR"
                        , countryDyeing = Country.Code "IN" -- Ennoblement in India
                        , countryMaking = Country.Code "FR"
                    }
                    |> Result.andThen (LifeCycle.computeStepsTransport db)
                    |> Result.map (LifeCycle.computeTotalTransportImpacts db)
                    |> Expect.equal
                        (Ok
                            { road = km 1500
                            , sea = km 45468
                            , air = km 0
                            , impacts = defaultImpacts
                            }
                        )
                    |> asTest "should compute custom distances"
                ]
            ]
        )
