module Data.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs exposing (tShirtCotonFrance)
import Data.LifeCycle as LifeCycle
import Expect
import Length
import Test exposing (..)
import TestDb exposing (testDb)


km =
    Length.kilometers


suite_ : Db -> List Test
suite_ db =
    let
        defaultImpacts =
            Impact.impactsFromDefinitons db.impacts
    in
    [ describe "computeTransportSummary"
        [ test "should compute default distances" <|
            \_ ->
                tShirtCotonFrance
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
        , test "should compute custom distances" <|
            \_ ->
                let
                    query =
                        tShirtCotonFrance
                in
                LifeCycle.fromQuery db
                    { query
                        | countries =
                            [ Country.Code "CN"
                            , Country.Code "FR"
                            , Country.Code "IN" -- Ennoblement in India
                            , Country.Code "FR"
                            , Country.Code "FR"
                            , Country.Code "FR"
                            ]
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
        ]
    ]


suite : Test
suite =
    describe "Data.LifeCycle"
        (case testDb of
            Ok db ->
                suite_ db

            Err error ->
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
        )
