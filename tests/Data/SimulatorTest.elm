module Data.SimulatorTest exposing (..)

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


expectImpact : Float -> Inputs.Query -> Expectation
expectImpact cch query =
    case testDb |> Result.andThen (\db -> Simulator.compute db query) of
        Ok simulator ->
            simulator.impact
                |> Unit.impactToFloat
                |> Expect.within (Expect.Absolute 0.01) cch

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
                    |> setQueryImpact (Impact.Trigram "cch")
                    |> expectImpact (Unit.impactToFloat cch)
                    |> asTest "climate change"
                , query
                    |> setQueryImpact (Impact.Trigram "fwe")
                    |> expectImpact (Unit.impactToFloat fwe)
                    |> asTest "freshwater eutrophication"
                ]


suite : Test
suite =
    Sample.samples
        |> List.map convert
        |> describe "Data.Simulator"
