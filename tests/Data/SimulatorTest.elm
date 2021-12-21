module Data.SimulatorTest exposing (..)

import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (..)
import Data.Sample as Sample
import Data.Simulator as Simulator
import Data.Unit as Unit
import Dict.Any as AnyDict
import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectImpact : Db -> Float -> Inputs.Query -> Expectation
expectImpact db cch query =
    case Simulator.compute db query of
        Ok simulator ->
            simulator.impact
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) cch

        Err error ->
            Expect.fail error


convertToTests : Db -> Sample.SectionOrSample -> Test
convertToTests db sectionOrSample =
    case sectionOrSample of
        Sample.Section title samples ->
            describe title (List.map (convertToTests db) samples)

        Sample.Sample title { query, cch, fwe } ->
            describe title
                [ query
                    |> setQueryImpact (Impact.trg "cch")
                    |> expectImpact db (Unit.impactToFloat cch)
                    |> asTest "climate change"
                , query
                    |> setQueryImpact (Impact.trg "fwe")
                    |> expectImpact db (Unit.impactToFloat fwe)
                    |> asTest "freshwater eutrophication"
                ]


suite : Test
suite =
    case testDb of
        Ok db ->
            describe "Data.Simulator"
                [ describe "compute"
                    (List.map (convertToTests db) Sample.samples)
                , describe "computeAll"
                    [ case Simulator.computeAll db (tShirtCotonFrance Impact.defaultTrigram) of
                        Ok impacts ->
                            impacts
                                |> Expect.equal
                                    ([ ( "acd", 0.04087232487157366 )
                                     , ( "ccb", 0.0023542122880000006 )
                                     , ( "ccf", 4.411684570966434 )
                                     , ( "cch", 4.4140271789664345 )
                                     , ( "ccl", 0 )
                                     , ( "fru", 67.54087637525184 )
                                     , ( "fwe", 0.0003521486305115451 )
                                     , ( "ior", 5.0240353144037995 )
                                     , ( "ldu", 148.98128632 )
                                     , ( "mru", 0.000009440002792840951 )
                                     , ( "ozd", 3.751134829991774e-7 )
                                     , ( "pco", 0.015357882059077762 )
                                     , ( "pma", 7.148316338708138e-7 )
                                     , ( "swe", 0.024686641632321656 )
                                     , ( "tre", 0.0979951577206528 )
                                     ]
                                        |> List.map (Tuple.mapBoth Impact.trg Unit.impactFromFloat)
                                        |> AnyDict.fromList Impact.toString
                                    )
                                |> asTest "should compute all impacts"

                        Err err ->
                            test "should compute all impacts" <|
                                \_ -> Expect.fail <| "Failure: " ++ err
                    ]
                ]

        Err error ->
            describe "Data.Simulator"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
