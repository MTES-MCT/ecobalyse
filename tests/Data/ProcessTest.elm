module Data.ProcessTest exposing (..)

import Data.Country as Country
import Data.Country.Code as CountryCode
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process
import Data.Unit as Unit
import Dict
import Energy
import Expect
import Test exposing (..)
import TestUtils exposing (expectResultErrorContains, it, suiteFromResult, suiteWithDb)


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
                            , impacts = Impact.empty |> Impact.updateImpact db.definitions Definition.Ecs (Unit.impact 1)
                         }
                            |> Process.impactsPerUnit france
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat
                            |> Expect.greaterThan 0
                        )
                    ]
                )
            , suiteFromResult "applyImpactDetails"
                (db.processes |> List.head |> Result.fromMaybe "Empty processes db")
                (\testProcess ->
                    let
                        -- create detailed impacts for the test process
                        sampleDetailedImpacts =
                            Dict.fromList
                                [ ( Process.idToString testProcess.id
                                  , Impact.empty |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 42)
                                  )
                                ]

                        -- apply detailed impacts to the processes
                        updatedProcesses =
                            db.processes |> Process.applyImpactDetails sampleDetailedImpacts
                    in
                    [ it "should override impacts of matching processes"
                        (updatedProcesses
                            |> List.head
                            |> Maybe.map (Process.getImpact Definition.Cch >> Unit.impactToFloat)
                            |> Expect.equal (Just 42)
                        )
                    ]
                )
            , suiteFromResult "validateImpactDetails"
                (db.processes |> List.head |> Result.fromMaybe "Empty processes db")
                (\testProcess ->
                    let
                        processId =
                            Process.idToString testProcess.id

                        matchingDetailedImpacts =
                            Dict.fromList
                                [ ( processId
                                  , Impact.empty |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 42)
                                  )
                                ]
                    in
                    [ it "should reject detailed impacts missing base process ids"
                        (db.processes
                            |> Process.validateImpactDetails matchingDetailedImpacts
                            |> expectResultErrorContains "Impacts détaillés manquants pour les procédés suivants"
                        )
                    , it "should reject detailed impacts with unknown ids"
                        (db.processes
                            |> Process.validateImpactDetails
                                (Dict.fromList
                                    [ ( processId
                                      , Impact.empty |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 42)
                                      )
                                    , ( "00000000-0000-0000-0000-000000000099"
                                      , Impact.empty |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 99)
                                      )
                                    ]
                                )
                            |> expectResultErrorContains "Impacts détaillés inconnus pour les procédés suivants"
                        )
                    ]
                )
            ]
        )
