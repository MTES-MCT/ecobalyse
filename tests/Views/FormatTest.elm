module Views.FormatTest exposing (..)

import Data.Split as Split
import Expect
import Html exposing (text)
import Mass
import Test exposing (..)
import TestUtils exposing (asTest)
import Views.Format as RichFormat


suite : Test
suite =
    describe "Views.Format"
        [ describe "Format.roundedMassShare"
            [ RichFormat.roundedMassShare 2 (Mass.kilograms 0.5) (Mass.kilograms 1)
                |> Expect.equal 50
                |> asTest "should be below 100 when the finished mass is lighter than the target"
            , RichFormat.roundedMassShare 2 (Mass.kilograms 1.5) (Mass.kilograms 1.5)
                |> Expect.equal 100
                |> asTest "should be 100 when the finished mass matches the target"
            , RichFormat.roundedMassShare 2 (Mass.kilograms 0.99996) (Mass.kilograms 1)
                |> Expect.equal 100
                |> asTest "should round 99.996 to 100 so the share matches the displayed percentage"
            , RichFormat.roundedMassShare 2 (Mass.kilograms 0.190809) (Mass.kilograms 0.191)
                |> Expect.equal 100
                |> asTest "should be 100 when both masses display as 0,191 kg"
            , RichFormat.roundedMassShare 2 (Mass.kilograms 1.5) (Mass.kilograms 1)
                |> Expect.equal 150
                |> asTest "should be above 100 when the finished mass is heavier than the target"
            , RichFormat.roundedMassShare 3 (Mass.kilograms 1.5) (Mass.kilograms 1)
                |> Expect.equal 150
                |> asTest "should be above 100 when the finished mass is heavier than the target 2"
            ]
        , describe "Format.percentage"
            [ 0.12
                |> Split.fromFloat
                |> Result.map (RichFormat.splitAsPercentage 0)
                |> Expect.equal (Ok (text "12\u{202F}%"))
                |> asTest "should properly format a Split as percentage"
            , 0.12
                |> Split.fromFloat
                |> Result.map (RichFormat.splitAsFloat 1)
                |> Expect.equal (Ok (text "0,1"))
                |> asTest "should properly format a Split as float"
            ]
        ]
