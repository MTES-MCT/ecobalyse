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
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectImpact : Db -> Impact.Trigram -> Float -> Inputs.Query -> Expectation
expectImpact db trigram cch query =
    case Simulator.compute db query of
        Ok simulator ->
            simulator.impacts
                |> Impact.getImpact trigram
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) cch

        Err error ->
            Expect.fail error


convertToTests : Db -> Sample.SectionOrSample -> Test
convertToTests db sectionOrSample =
    case sectionOrSample of
        Sample.Section title samples ->
            describe title (List.map (convertToTests db) samples)

        Sample.Sample title { query, fwe } ->
            describe title
                [ -- FIXME: update samples and uncomment
                  --     query
                  --     |> expectImpact db (Impact.trg "cch") (Unit.impactToFloat cch)
                  --     |> asTest "climate change"
                  query
                    |> expectImpact db (Impact.trg "fwe") (Unit.impactToFloat fwe)
                    |> asTest "freshwater eutrophication"
                ]


suite : Test
suite =
    describe "Data.Simulator"
        [ case testDb of
            Ok db ->
                describe "compute"
                    (List.map (convertToTests db) Sample.samples)

            Err error ->
                test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
        ]
