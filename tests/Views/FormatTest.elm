module Views.FormatTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Views.Format as Format


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


suite : Test
suite =
    describe "Views.Format"
        [ describe "Format.formatFloat"
            [ 5
                |> Format.formatFloat 2
                |> Expect.equal "5,00"
                |> asTest "should format an int rendering a specific number of 0 decimals"
            , 5.02
                |> Format.formatFloat 2
                |> Expect.equal "5,02"
                |> asTest "should format a float rounding it at a specific number of decimals"
            , 0.502
                |> Format.formatFloat 2
                |> Expect.equal "0,50"
                |> asTest "should format a float < 1 rounding it at a specific number of decimals"
            , 0.0502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-1"
                |> asTest "should format a float < 0.1 rounding it at a specific number of decimals"
            , 0.00502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-2"
                |> asTest "should format a float < 0.01 rounding it at a specific number of decimals"
            , 0.000502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-3"
                |> asTest "should format a float < 0.001 in scientific notation (E-3)"
            , 0.000000502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-6"
                |> asTest "should format a float < 0.000001 in scientific notation (E-6)"
            , 0.000000000502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-9"
                |> asTest "should format a float < 0.000000001 in scientific notation (E-9)"
            ]
        ]
