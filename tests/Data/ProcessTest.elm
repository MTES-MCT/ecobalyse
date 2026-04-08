module Data.ProcessTest exposing (..)

import Data.Country as Country
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process
import Data.Unit as Unit
import Energy
import Expect
import Test exposing (..)
import TestUtils exposing (it, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Process"
        (\db ->
            [ TestUtils.suiteFromResult2 "impactsPerUnit"
                -- setup
                (db.processes |> List.head |> Result.fromMaybe "Empty processes db")
                (Country.findByCode (Country.Code "FR") db.countries)
                -- test
                (\process france ->
                    [ it "should compute impacts per unit"
                        ({ process
                            | elec = Energy.kilowattHours 1
                            , heat = Energy.megajoules 1
                            , impacts = Impact.empty |> Impact.updateImpact db.definitions Definition.Ecs (Unit.impact 1)
                         }
                            |> Process.impactsPerUnit france
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.greaterThan 0
                        )
                    ]
                )
            ]
        )
