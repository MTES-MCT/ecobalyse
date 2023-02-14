module Views.FormatTest exposing (..)

import Expect
import Test exposing (..)
import TestUtils exposing (asTest)
import Views.Format as Format


suite : Test
suite =
    describe "Views.Format"
        [ describe "Format.formatFloat"
            [ 0
                |> Format.formatFloat 99
                |> Expect.equal "0"
                |> asTest "should format zero"
            , 5
                |> Format.formatFloat 2
                |> Expect.equal "5,00"
                |> asTest "should not format an int rendering a specific number of 0 decimals"
            , 5.02
                |> Format.formatFloat 2
                |> Expect.equal "5,02"
                |> asTest "should not format a float rounding it at a specific number of decimals"
            , 0.502
                |> Format.formatFloat 2
                |> Expect.equal "0,50"
                |> asTest "should not format a float < 1 rounding it at a specific number of decimals"
            , 0.0502
                |> Format.formatFloat 2
                |> Expect.equal "0,05"
                |> asTest "should not format a float < 0.1 rounding it at a specific number of decimals"
            , 0.00502
                |> Format.formatFloat 2
                |> Expect.equal "5,02e-3"
                |> asTest "should format a float < 0.01 rounding it at a specific number of decimals"
            , 0.000502
                |> Format.formatFloat 2
                |> Expect.equal "5,02e-4"
                |> asTest "should format a float < 0.001 in scientific notation (E-3)"
            , 0.000000502
                |> Format.formatFloat 2
                |> Expect.equal "5,02e-7"
                |> asTest "should format a float < 0.000001 in scientific notation (E-6)"
            , 0.000000000502
                |> Format.formatFloat 2
                |> Expect.equal "5,02e-10"
                |> asTest "should format a float < 0.000000001 in scientific notation (E-9)"
            , -5.02
                |> Format.formatFloat 2
                |> Expect.equal "-5,02"
                |> asTest "should not format a negative float in scientific notation"
            , -0.000000000502
                |> Format.formatFloat 2
                |> Expect.equal "-5,02e-10"
                |> asTest "should format a negative float in scientific notation"
            , 105
                |> Format.formatFloat 2
                |> Expect.equal "105"
                |> asTest "should not format a number > 100 to provided decimal precision"
            ]
        ]
