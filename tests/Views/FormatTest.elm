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
            [ 0.502
                |> Format.formatFloat 2
                |> Expect.equal "0,50"
                |> asTest "should format a float rounding it at a specific number of decimals"
            , 0.000502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-3"
                |> asTest "should format a float in scientific notation (E-3)"
            , 0.000000502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-6"
                |> asTest "should format a float in scientific notation (E-6)"
            , 0.000000000502
                |> Format.formatFloat 2
                |> Expect.equal "0,50E-9"
                |> asTest "should format a float in scientific notation (E-9)"
            ]
        ]
