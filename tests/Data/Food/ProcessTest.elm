module Data.Food.ProcessTest exposing (..)

import Data.Food.Process as Process
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Process"
        (\{ builderDb } ->
            [ describe "findByCode"
                [ Process.codeFromString "AGRIBALU000000003104412"
                    |> Process.findByIdentifier builderDb.processes
                    |> Result.map (.name >> Process.nameToString)
                    |> Expect.equal (Ok "Cull cow, organic, milk system number 1, at farm gate {FR} U")
                    |> asTest "should find a process by its identifier"
                ]
            ]
        )
