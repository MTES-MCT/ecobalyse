module Data.SimulatorTest exposing (..)

import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (..)
import Data.Sample as Sample
import Data.Simulator as Simulator
import Data.Unit as Unit
import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


expectImpact : Db -> Float -> Impact.Trigram -> Float -> Inputs.Query -> Expectation
expectImpact db precision trigram cch query =
    case Simulator.compute db query of
        Ok simulator ->
            simulator.impacts
                |> Impact.getImpact trigram
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute precision) cch

        Err error ->
            Expect.fail error


convertToTests : Db -> Sample.SectionOrSample -> Test
convertToTests db sectionOrSample =
    case sectionOrSample of
        Sample.Section title samples ->
            describe title (List.map (convertToTests db) samples)

        Sample.Sample title { query, fwe, cch } ->
            describe title
                [ query
                    |> expectImpact db 0.01 (Impact.trg "cch") (Unit.impactToFloat cch)
                    |> asTest "climate change"
                , query
                    |> expectImpact db 0.00001 (Impact.trg "fwe") (Unit.impactToFloat fwe)
                    |> asTest "freshwater eutrophication"
                ]


suite : Test
suite =
    suiteWithDb "Data.Simulator"
        (\db ->
            Sample.samples
                |> List.map (convertToTests db)
        )
