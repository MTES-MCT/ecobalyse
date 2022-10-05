module Data.Food.ProcessTest exposing (..)

import Data.Food.Process as Process
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Process"
        (\{ foodDb } ->
            [ describe "findByCode"
                [ Process.codeFromString "2e3f03c6de1e43900e09ae852182e9c7"
                    |> Process.findByCode foodDb.processes
                    |> Result.map (.name >> Process.nameToString)
                    |> Expect.equal (Ok "Mozzarella cheese, from cow's milk, at plant")
                    |> asTest "should find a process by code"
                ]
            ]
        )
