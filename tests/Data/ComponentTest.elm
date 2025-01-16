module Data.ComponentTest exposing (..)

import Data.Component as Component
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process
import Data.Split as Split
import Data.Unit as Unit
import Expect
import Json.Decode as Decode
import Mass
import Static.Db as Db
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getEcsImpact : Component.Results -> Float
getEcsImpact =
    Component.extractImpacts >> (Impact.getImpact Definition.Ecs >> Unit.impactToFloat)


sampleJsonItems : String
sampleJsonItems =
    """
    [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
    , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
    , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
    ]
    """


suite : Test
suite =
    suiteWithDb "Data.Component"
        (\db ->
            let
                allProcesses =
                    Db.allProcesses db

                ( fading, weaving ) =
                    ( db.textile.wellKnown.fading
                    , db.textile.wellKnown.weaving
                    )
            in
            [ describe "applyTransforms"
                [ let
                    oneKilogramResults =
                        Component.Results { impacts = Impact.empty, items = [], mass = Mass.kilogram }
                  in
                  describe "waste"
                    [ asTest "should not apply any waste when no transforms are passed"
                        (oneKilogramResults
                            |> Component.applyTransforms allProcesses []
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.00001) 1
                        )
                    , asTest "should apply waste when one transform is passed"
                        (oneKilogramResults
                            |> Component.applyTransforms allProcesses [ { weaving | waste = Split.half } ]
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.00001) 0.5
                        )
                    , asTest "should apply waste sequentially when multiple transforms are passed"
                        (oneKilogramResults
                            |> Component.applyTransforms allProcesses [ { weaving | waste = Split.half }, { weaving | waste = Split.half } ]
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.00001) 0.25
                        )
                    ]
                , let
                    noImpactsResults =
                        Component.Results { impacts = Impact.empty, items = [], mass = Mass.kilogram }
                  in
                  describe "impacts"
                    [ asTest "should not add impacts when no transforms are passed"
                        (noImpactsResults
                            |> Component.applyTransforms allProcesses []
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 0
                        )
                    , asTest "should add impacts when one transform is passed"
                        (noImpactsResults
                            |> Component.applyTransforms allProcesses
                                [ { fading
                                    | impacts =
                                        fading.impacts
                                            |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                                  }
                                ]
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 10
                        )
                    , asTest "should add impacts when multiple transforms are passed"
                        (noImpactsResults
                            |> Component.applyTransforms allProcesses
                                [ { fading
                                    | impacts =
                                        fading.impacts
                                            |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                                  }
                                , { fading
                                    | impacts =
                                        fading.impacts
                                            |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 20)
                                  }
                                ]
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 30
                        )
                    ]
                , let
                    results =
                        Component.Results
                            { impacts = Impact.empty |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 100)
                            , items = []
                            , mass = Mass.kilogram
                            }
                            |> Component.applyTransforms allProcesses
                                [ { fading
                                    | waste = Split.half
                                    , impacts =
                                        fading.impacts
                                            |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                                  }
                                , { fading
                                    | waste = Split.half
                                    , impacts =
                                        fading.impacts
                                            |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 20)
                                  }
                                ]
                  in
                  describe "impacts & waste"
                    -- Note: impacts are always computed from input mass
                    -- 100 + (1kg * 10) + (0.5kg * 20) = 120
                    [ asTest "should handle impacts+waste when applying transforms: impacts"
                        (results
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 120
                        )

                    -- (1kg * 0.5) * 0.5 == 0.25
                    , asTest "should handle impacts+waste when applying transforms: mass"
                        (results
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.00001) 0.25
                        )
                    ]
                ]
            , describe "compute"
                [ asTest "should compute results from decoded component items"
                    (sampleJsonItems
                        |> Decode.decodeString (Decode.list Component.decodeItem)
                        |> Result.mapError Decode.errorToString
                        |> Result.andThen (Component.compute db.object)
                        |> Result.map getEcsImpact
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 422
                    )
                ]
            , describe "computeElementResults"
                [ asTest "should compute a material-only element results"
                    (case Process.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84" of
                        Just cottonId ->
                            -- 1kg of cotton, weaved then faded
                            { amount = Component.Amount 1
                            , material = cottonId
                            , transforms = [ weaving.id, fading.id ]
                            }
                                |> Component.computeElementResults allProcesses
                                |> Result.map
                                    (\res ->
                                        ( Component.extractImpacts res |> Impact.getImpact Definition.Ecs |> Unit.impactToFloat |> round
                                        , Component.extractMass res |> Mass.inKilograms
                                        )
                                    )
                                |> Result.withDefault ( 0, 0 )
                                |> Expect.equal ( 1654, 0.93747 )

                        Nothing ->
                            Expect.fail "Invalid cotton process id"
                    )
                ]
            ]
        )
