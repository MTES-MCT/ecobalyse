module Data.Textile.LifeCycleTest exposing (..)

import Data.Country as Country
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Query exposing (Query, tShirtCotonFrance)
import Data.Textile.Step.Label as Label exposing (Label)
import Expect
import Json.Decode as Decode
import Length
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


encodedStepLabels : Db -> Query -> Result String (List String)
encodedStepLabels db =
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
                LifeCycle.computeStepsTransport db materials lifeCycle
            )


{-| Pipeline order used by `LifeCycle.init`.
-}
stepLabelsInOrder : List Label
stepLabelsInOrder =
    [ Label.Material
    , Label.Spinning
    , Label.Fabric
    , Label.Ennobling
    , Label.Making
    , Label.Distribution
    , Label.Use
    , Label.EndOfLife
    ]


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
                    |> Expect.equal (Ok ( 2500, 21549 ))
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
                    |> Expect.equal (Ok ( 1500, 45471 ))
                    |> asTest "should compute custom distances"
                ]
            , describe "encode"
                [ encodedStepLabels db tShirtCotonFrance
                    |> Expect.equal (Ok (List.map Label.toString stepLabelsInOrder))
                    |> asTest "should include all steps by default"
                , encodedStepLabels db { tShirtCotonFrance | disabledSteps = [ Label.Ennobling ] }
                    |> Expect.equal
                        (Ok
                            (stepLabelsInOrder
                                |> List.filter ((/=) Label.Ennobling)
                                |> List.map Label.toString
                            )
                        )
                    |> asTest "should hide disabled steps"
                , encodedStepLabels db { tShirtCotonFrance | upcycled = True }
                    |> Expect.equal
                        (Ok
                            (stepLabelsInOrder
                                |> List.filter (\label -> not (List.member label Label.upcyclables))
                                |> List.map Label.toString
                            )
                        )
                    |> asTest "should hide upcyclable steps when upcycled"
                , encodedStepLabels db { tShirtCotonFrance | disabledSteps = [ Label.Use ], upcycled = True }
                    |> Expect.equal
                        (Ok
                            (stepLabelsInOrder
                                |> List.filter (\label -> not (List.member label (Label.Use :: Label.upcyclables)))
                                |> List.map Label.toString
                            )
                        )
                    |> asTest "should hide extra disabled steps when upcycled"
                ]
            ]
        )
