module Data.ProcessTest exposing (..)

import Data.Country as Country
import Data.Country.Code as CountryCode
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Impacts as Impacts
import Data.Process as Process
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
                (Country.findByCode CountryCode.france db.countries)
                -- test
                (\process france ->
                    [ it "should compute impacts per unit"
                        ({ process
                            | elec = Energy.kilowattHours 1
                            , heat = Energy.megajoules 1
                            , impacts = Impacts.empty |> Impacts.updateImpact db.definitions Definition.Ecs (Impact.impact 1)
                         }
                            |> Process.impactsPerUnit france
                            |> Impacts.getImpact Definition.Ecs
                            |> Impact.impactToFloat
                            |> Expect.greaterThan 0
                        )
                    ]
                )
            ]
        )
