module Data.ComponentTest exposing (..)

import Data.Component as Component
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Unit as Unit
import Expect
import Json.Decode as Decode
import Mass
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
                            |> Component.applyTransforms []
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.00001) 1
                        )
                    , asTest "should apply waste when one transform is passed"
                        (oneKilogramResults
                            |> Component.applyTransforms [ { weaving | waste = Split.half } ]
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.00001) 0.5
                        )
                    , asTest "should apply waste sequentially when multiple transforms are passed"
                        (oneKilogramResults
                            |> Component.applyTransforms [ { weaving | waste = Split.half }, { weaving | waste = Split.half } ]
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
                            |> Component.applyTransforms []
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 0
                        )
                    , asTest "should add impacts when one transform is passed"
                        (noImpactsResults
                            |> Component.applyTransforms
                                [ { fading
                                    | impacts =
                                        fading.impacts
                                            |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                                  }
                                ]
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 10
                        )
                    , asTest "should add impacts when multiple transforms are passed"
                        (noImpactsResults
                            |> Component.applyTransforms
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
                            |> Component.extractImpacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.within (Expect.Absolute 0.00001) 30
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
            ]
        )
