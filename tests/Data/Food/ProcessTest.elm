module Data.Food.ProcessTest exposing (..)

import Data.Food.Process as Process
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Process"
        (\{ food } ->
            [ describe "findByCode"
                [ food.processes
                    |> Process.findByIdentifier (Process.codeFromString "AGRIBALU000000003102585")
                    |> Result.map (.name >> Process.nameToString)
                    |> Expect.equal (Ok "Carrot, consumption mix {FR} U")
                    |> asTest "should find a process by its identifier"
                ]
            ]
        )
