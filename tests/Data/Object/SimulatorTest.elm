module Data.Object.SimulatorTest exposing (..)

import Data.Example as Example
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Object.Query exposing (Query)
import Data.Object.Simulator as Simulator
import Data.Unit as Unit
import Expect
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getEcsImpact : Db -> Query -> Result String Float
getEcsImpact db =
    Simulator.compute db
        >> Result.map
            (Simulator.extractImpacts
                >> (Impact.getImpact Definition.Ecs >> Unit.impactToFloat)
            )


suite : Test
suite =
    suiteWithDb "Data.Object.Simulator"
        (\db ->
            [ describe "Simulator.compute"
                [ db.object.examples
                    |> Example.findByName "Chaise"
                    |> Result.andThen (.query >> getEcsImpact db)
                    |> Result.withDefault 0
                    |> Expect.within (Expect.Absolute 1) 649
                    |> asTest "should compute impact for an example chair"
                , db.object.examples
                    |> Example.findByName "Table"
                    |> Result.andThen (.query >> getEcsImpact db)
                    |> Result.withDefault 0
                    |> Expect.within (Expect.Absolute 1) 45
                    |> asTest "should compute impact for an example table"
                ]
            ]
        )
