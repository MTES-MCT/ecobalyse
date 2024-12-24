module Data.ComponentTest exposing (..)

import Data.Component as Component
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Unit as Unit
import Expect
import Json.Decode as Decode
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getEcsImpact : Component.Results -> Float
getEcsImpact =
    Component.extractImpacts >> (Impact.getImpact Definition.Ecs >> Unit.impactToFloat)


sampleJsonComponentsItems : String
sampleJsonComponentsItems =
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
            [ describe "Component.compute"
                [ sampleJsonComponentsItems
                    |> Decode.decodeString (Decode.list Component.decodeComponentItem)
                    |> Result.mapError Decode.errorToString
                    |> Result.andThen (Component.compute db.object)
                    |> Result.map getEcsImpact
                    |> TestUtils.expectResultWithin (Expect.Absolute 1) 422
                    |> asTest "should compute results from decoded component items"
                ]
            ]
        )
