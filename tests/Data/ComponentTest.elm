module Data.ComponentTest exposing (..)

import Data.Component as Component
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Expect
import Json.Decode as Decode
import Mass
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getEcsImpact : Component.Results -> Float
getEcsImpact =
    Component.extractImpacts
        >> (Impact.getImpact Definition.Ecs >> Unit.impactToFloat)


suite : Test
suite =
    suiteWithDb "Data.Component"
        (\db ->
            let
                -- these will be adapted and used as test transform processes
                ( fading, weaving ) =
                    ( db.textile.wellKnown.fading
                    , db.textile.wellKnown.weaving
                    )
            in
            [ describe "applyTransforms"
                [ let
                    getTestMass transforms =
                        Component.Results { impacts = Impact.empty, items = [], mass = Mass.kilogram }
                            |> Component.applyTransforms db.processes transforms
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                  in
                  describe "waste"
                    [ asTest "should not apply any waste when no transforms are passed"
                        (getTestMass []
                            |> Expect.within (Expect.Absolute 0.00001) 1
                        )
                    , asTest "should apply waste when one transform is passed"
                        (getTestMass [ { weaving | waste = Split.half } ]
                            |> Expect.within (Expect.Absolute 0.00001) 0.5
                        )
                    , asTest "should apply waste sequentially when multiple transforms are passed"
                        (getTestMass [ { weaving | waste = Split.half }, { weaving | waste = Split.half } ]
                            |> Expect.within (Expect.Absolute 0.00001) 0.25
                        )
                    ]
                , let
                    getTestEcsImpact transforms =
                        Component.Results { impacts = Impact.empty, items = [], mass = Mass.kilogram }
                            |> Component.applyTransforms db.processes transforms
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                  in
                  describe "impacts"
                    [ asTest "should not add impacts when no transforms are passed"
                        (getTestEcsImpact []
                            |> Expect.within (Expect.Absolute 0.00001) 0
                        )
                    , asTest "should add impacts when one transform is passed (no elec, no heat)"
                        (getTestEcsImpact
                            [ fading
                                |> resetProcessElecAndHeat
                                |> setProcessEcsImpact (Unit.impact 10)
                            ]
                            |> Expect.within (Expect.Absolute 1) 10
                        )
                    , asTest "should add impacts when one transform is passed (including elec and heat)"
                        (getTestEcsImpact
                            [ { fading
                                | impacts =
                                    fading.impacts
                                        |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                              }
                            ]
                            |> Expect.within (Expect.Absolute 1) 391
                        )
                    , asTest "should add impacts when multiple transforms are passed (no elec, no heat)"
                        (getTestEcsImpact
                            [ fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 10)
                            , fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 20)
                            ]
                            |> Expect.within (Expect.Absolute 1) 30
                        )
                    , asTest "should add impacts when multiple transforms are passed (including elec and heat)"
                        (getTestEcsImpact
                            [ fading |> setProcessEcsImpact (Unit.impact 10)
                            , fading |> setProcessEcsImpact (Unit.impact 20)
                            ]
                            |> Expect.within (Expect.Absolute 1) 793
                        )
                    ]
                , let
                    getTestResults transforms =
                        Component.Results
                            { impacts = Impact.empty |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 100)
                            , items = []
                            , mass = Mass.kilogram
                            }
                            |> Component.applyTransforms db.processes transforms
                            |> Result.withDefault Component.emptyResults
                  in
                  describe "impacts & waste"
                    [ let
                        noElecAndNoHeat =
                            getTestResults
                                [ fading
                                    |> resetProcessElecAndHeat
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 10)
                                , fading
                                    |> resetProcessElecAndHeat
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 20)
                                ]
                      in
                      describe "excluding elec and heat"
                        [ -- Note: impacts are always computed from input mass
                          -- 100 + (1kg * 10) + (0.5kg * 20) = 120
                          asTest "should handle impacts+waste when applying transforms: impacts"
                            (noElecAndNoHeat
                                |> Component.extractImpacts
                                |> Impact.getImpact Definition.Ecs
                                |> Unit.impactToFloat
                                |> Expect.within (Expect.Absolute 1) 120
                            )

                        -- (1kg * 0.5) * 0.5 == 0.25
                        , asTest "should handle impacts+waste when applying transforms: mass"
                            (noElecAndNoHeat
                                |> Component.extractMass
                                |> Mass.inKilograms
                                |> Expect.within (Expect.Absolute 0.01) 0.25
                            )
                        ]
                    , let
                        withElecAndHeat =
                            getTestResults
                                [ fading
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 10)
                                , fading
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 20)
                                ]
                      in
                      describe "including elec and heat"
                        [ asTest "should handle impacts+waste when applying transforms: impacts"
                            (withElecAndHeat
                                |> Component.extractImpacts
                                |> Impact.getImpact Definition.Ecs
                                |> Unit.impactToFloat
                                |> Expect.within (Expect.Absolute 1) 692
                            )
                        , asTest "should handle impacts+waste when applying transforms: mass"
                            (withElecAndHeat
                                |> Component.extractMass
                                |> Mass.inKilograms
                                |> Expect.within (Expect.Absolute 0.01) 0.25
                            )
                        ]
                    ]
                ]
            , describe "compute"
                [ asTest "should compute results from decoded component items"
                    (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                         , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                         , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                         ]"""
                        |> Decode.decodeString (Decode.list Component.decodeItem)
                        |> Result.mapError Decode.errorToString
                        |> Result.andThen (Component.compute db)
                        |> Result.map getEcsImpact
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 422
                    )
                , asTest "should compute results from decoded component items with custom component elements"
                    (""" [ {
                             "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                             "quantity": 4,
                             "custom": {
                               "elements": [
                                 {
                                   "amount": 0.00044,
                                   "material": "07e9e916-e02b-45e2-a298-2b5084de6242",
                                   "transforms": []
                                 }
                               ]
                             }
                           }
                         , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                         , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                         ]"""
                        |> Decode.decodeString (Decode.list Component.decodeItem)
                        |> Result.mapError Decode.errorToString
                        |> Result.andThen (Component.compute db)
                        |> Result.map getEcsImpact
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 443
                    )
                ]
            , describe "computeElementResults"
                (case Process.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84" of
                    Ok cottonId ->
                        let
                            elementResults =
                                Component.computeElementResults db.processes
                                    { amount = Component.Amount 1
                                    , material = cottonId
                                    , transforms = [ weaving.id, fading.id ]
                                    }
                        in
                        [ asTest "should compute element impacts"
                            (elementResults
                                |> Result.map
                                    (Component.extractImpacts
                                        >> Impact.getImpact Definition.Ecs
                                        >> Unit.impactToFloat
                                    )
                                |> Result.withDefault 0
                                |> Expect.within (Expect.Absolute 1) 2012
                            )
                        , asTest "should compute element mass"
                            (elementResults
                                |> Result.map (Component.extractMass >> Mass.inKilograms)
                                |> Result.withDefault 0
                                |> Expect.within (Expect.Absolute 0.01) 0.94
                            )
                        ]

                    Err err ->
                        [ Expect.fail err
                            |> asTest "should load cotton data"
                        ]
                )
            ]
        )


resetProcessElecAndHeat : Process -> Process
resetProcessElecAndHeat process =
    { process
        | elec = Quantity.zero
        , heat = Quantity.zero
    }


setProcessEcsImpact : Unit.Impact -> Process -> Process
setProcessEcsImpact ecs process =
    { process
        | impacts =
            process.impacts
                |> Impact.insertWithoutAggregateComputation Definition.Ecs ecs
    }


setProcessWaste : Split -> Process -> Process
setProcessWaste waste process =
    { process | waste = waste }
