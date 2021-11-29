module Data.SimulatorTest exposing (..)

import Data.Co2 as Co2
import Data.Inputs as Inputs exposing (..)
import Data.Sample as Sample
import Data.Simulator as Simulator
import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectCo2 : Float -> Inputs.Query -> Expectation
expectCo2 co2 query =
    case testDb |> Result.andThen (\db -> Simulator.compute db query) of
        Ok simulator ->
            simulator.co2
                |> Co2.inKgCo2e
                |> Expect.within (Expect.Absolute 0.01) co2

        Err error ->
            Expect.fail error


convert : Sample.SectionOrSample -> Test
convert sectionOrSample =
    case sectionOrSample of
        Sample.Section title samples ->
            describe title (List.map convert samples)

        Sample.Sample title { query, expected } ->
            query
                |> expectCo2 (Co2.inKgCo2e expected)
                |> asTest title


suite : Test
suite =
    Sample.samples
        |> List.map convert
        |> describe "Data.Simulator"
