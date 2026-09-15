module Data.Textile.LifeCycleTest exposing (..)

import Data.Country.Code as CountryCode
import Data.Db exposing (Db)
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Query exposing (Query)
import Data.Textile.Stage.Label as Label
import Expect
import Json.Decode as Decode
import Length
import Test exposing (..)
import TestUtils
    exposing
        ( asTest
        , suiteFromResult
        , suiteWithDb
        , tShirtCotonFrance
        )


encodedStageLabels : Db -> Query -> Result String (List String)
encodedStageLabels db =
    Inputs.fromQuery db
        >> Result.andThen
            (\inputs ->
                inputs
                    |> LifeCycle.init db
                    |> LifeCycle.encode inputs
                    |> Decode.decodeValue (Decode.list (Decode.field "label" Decode.string))
                    |> Result.mapError Decode.errorToString
            )


lifeCycleToTransports : Db -> Query -> LifeCycle -> Result String LifeCycle
lifeCycleToTransports db query lifeCycle =
    query
        |> Inputs.fromQuery db
        |> Result.map
            (\materials ->
                LifeCycle.computeStagesTransport db materials lifeCycle
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
                    |> Expect.equal (Ok ( 2500, 19930 ))
                    |> asTest "should compute default distances"
                , let
                    tShirtCotonEnnoblementIndia =
                        tShirtCotonFrance
                            |> Result.map
                                (\query ->
                                    { query
                                        | countryFabric = Just CountryCode.france
                                        , countryDyeing = Just (CountryCode.fromString "IN") -- Ennoblement in India
                                        , countryMaking = Just CountryCode.france
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
                    |> Expect.equal (Ok ( 1500, 42138 ))
                    |> asTest "should compute custom distances"
                ]
            , describe "encode"
                [ suiteFromResult "should include all stages by default"
                    tShirtCotonFrance
                    (\query ->
                        [ encodedStageLabels db query
                            |> Expect.equal (Ok (List.map Label.toString Label.all))
                            |> asTest "include all stages by default"
                        ]
                    )
                , suiteFromResult "should hide disabled stages"
                    tShirtCotonFrance
                    (\query ->
                        [ encodedStageLabels db { query | disabledStages = [ Label.Ennobling ] }
                            |> Expect.equal
                                (Ok
                                    (Label.all
                                        |> List.filter ((/=) Label.Ennobling)
                                        |> List.map Label.toString
                                    )
                                )
                            |> asTest "hide disabled stages"
                        ]
                    )
                , suiteFromResult "should hide upcyclable stages when upcycled"
                    tShirtCotonFrance
                    (\query ->
                        [ encodedStageLabels db { query | upcycled = True }
                            |> Expect.equal
                                (Ok
                                    (Label.all
                                        |> List.filter (\label -> not (List.member label Label.upcyclables))
                                        |> List.map Label.toString
                                    )
                                )
                            |> asTest "hide upcyclable stages when upcycled"
                        ]
                    )
                , suiteFromResult "should hide extra disabled stages when upcycled"
                    tShirtCotonFrance
                    (\query ->
                        [ encodedStageLabels db { query | disabledStages = [ Label.Use ], upcycled = True }
                            |> Expect.equal
                                (Ok
                                    (Label.all
                                        |> List.filter (\label -> not (List.member label (Label.Use :: Label.upcyclables)))
                                        |> List.map Label.toString
                                    )
                                )
                            |> asTest "hide extra disabled stages when upcycled"
                        ]
                    )
                ]
            ]
        )
