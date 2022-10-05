module Data.Food.ProcessTest exposing (..)

import Data.Food.Process as Process
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithFoodDb)


suite : Test
suite =
    suiteWithFoodDb "Data.Food.Process"
        (\db ->
            [ describe "findByCode"
                [ Process.codeFromString "2e3f03c6de1e43900e09ae852182e9c7"
                    |> Process.findByCode db.processes
                    |> Result.map (.name >> Process.nameToString)
                    |> Expect.equal (Ok "Mozzarella cheese, from cow's milk, at plant")
                    |> asTest "should find a process by code"
                ]
            ]
        )
