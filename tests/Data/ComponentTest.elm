module Data.ComponentTest exposing (..)

import Data.Component as Component
import Expect
import Json.Decode as Decode
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sampleJsonComponentsItems : String
sampleJsonComponentsItems =
    """[
        {
          "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
          "quantity": 4
        },
        {
          "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973",
          "quantity": 1
        },
        {
          "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6",
          "quantity": 1
        }
      ]
      """


suite : Test
suite =
    suiteWithDb "Data.Component"
        (\db ->
            let
                { components, processes } =
                    db.object
            in
            [ describe "Component.compute"
                [ sampleJsonComponentsItems
                    |> Decode.decodeString (Decode.list Component.decodeComponentItem)
                    |> Result.mapError Decode.errorToString
                    |> Result.andThen (Component.compute components processes)
                    |> Expect.ok
                    |> asTest "should compute results from decoded component items"
                ]
            ]
        )
