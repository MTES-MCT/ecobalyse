module Data.SimulatorTest exposing (..)

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


expectCo2 : Float -> Inputs.Query -> Expectation
expectCo2 cch query =
    case testDb |> Result.andThen (\db -> Simulator.compute db query) of
        Ok simulator ->
            simulator.cch
                |> Unit.inKgCo2e
                |> Expect.within (Expect.Absolute 0.01) cch

        Err error ->
            Expect.fail error


expectFwE : Float -> Inputs.Query -> Expectation
expectFwE fwe query =
    case testDb |> Result.andThen (\db -> Simulator.compute db query) of
        Ok simulator ->
            simulator.fwe
                |> Unit.inKgPe
                |> Expect.within (Expect.Absolute 0.000001) fwe

        Err error ->
            Expect.fail error


convert : Sample.SectionOrSample -> Test
convert sectionOrSample =
    case sectionOrSample of
        Sample.Section title samples ->
            describe title (List.map convert samples)

        Sample.Sample title { query, cch, fwe } ->
            describe title
                [ query
                    |> expectCo2 (Unit.inKgCo2e cch)
                    |> asTest "climate change"
                , query
                    |> expectFwE (Unit.inKgPe fwe)
                    |> asTest "freshwater eutrophication"
                ]


suite : Test
suite =
    Sample.samples
        |> List.map convert
        |> describe "Data.Simulator"
