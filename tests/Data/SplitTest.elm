module Data.SplitTest exposing (..)

import Data.Split as Split
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Split"
        [ describe "zero"
            [ Split.zero
                |> Split.toPercent
                |> Expect.equal 0
                |> asTest "should have a 'zero' constructor"
            ]
        , describe "full"
            [ Split.full
                |> Split.toPercent
                |> Expect.equal 100
                |> asTest "should have a 'hundred' constructor"
            ]
        , describe "tenth"
            [ Split.tenth
                |> Split.toPercent
                |> Expect.equal 10
                |> asTest "should have a 'tenth' constructor"
            ]
        , describe "twenty"
            [ Split.twenty
                |> Split.toPercent
                |> Expect.equal 20
                |> asTest "should have a 'twenty' constructor"
            ]
        , describe "fourty"
            [ Split.fourty
                |> Split.toPercent
                |> Expect.equal 40
                |> asTest "should have a 'fourty' constructor"
            ]
        , describe "half"
            [ Split.half
                |> Split.toPercent
                |> Expect.equal 50
                |> asTest "should have a 'half' constructor"
            ]
        , describe "quarter"
            [ Split.quarter
                |> Split.toPercent
                |> Expect.equal 25
                |> asTest "should have a 'quarter' constructor"
            ]
        , describe "fromFloat constructor"
            [ -0.1
                |> Split.fromFloat
                |> Expect.equal (Err "Une part (en nombre flottant) doit être comprise entre 0 et 1 inclus (ici: -0.1)")
                |> asTest "should return an error if the split is less than 0"
            , 1.1
                |> Split.fromFloat
                |> Expect.equal (Err "Une part (en nombre flottant) doit être comprise entre 0 et 1 inclus (ici: 1.1)")
                |> asTest "should return an error if the split is greater than 1"
            , 0.12
                |> Split.fromFloat
                |> Result.map Split.toFloat
                |> Expect.equal (Ok 0.12)
                |> asTest "should provide a float constructor and extractor"
            ]
        , describe "fromPercent constructor"
            [ 12
                |> Split.fromPercent
                |> Result.map Split.toPercent
                |> Expect.equal (Ok 12)
                |> asTest "should provide a percent constructor and extractor"
            ]
        , describe "full percents (round up)"
            [ 0.119
                |> Split.fromFloat
                |> Expect.equal (Split.fromFloat 0.12)
                |> asTest "should only store full percents, rounded to the closest percent (up)"
            ]
        , describe "full percents (round down)"
            [ 0.121
                |> Split.fromFloat
                |> Expect.equal (Split.fromFloat 0.12)
                |> asTest "should only store full percents, rounded to the closest percent (down)"
            ]
        , describe "toFloatString"
            [ 0.12
                |> Split.fromFloat
                |> Result.map Split.toFloatString
                |> Expect.equal (Ok "0.12")
                |> asTest "should return a float string representation"
            ]
        , describe "toPercentString"
            [ 0.12
                |> Split.fromFloat
                |> Result.map Split.toPercentString
                |> Expect.equal (Ok "12")
                |> asTest "should return a percent string representation"
            ]
        , describe "complement"
            [ Split.zero
                |> Split.complement
                |> Expect.equal Split.full
                |> asTest "should find the complement of a '0' split is '1'"
            , Split.full
                |> Split.complement
                |> Expect.equal Split.zero
                |> asTest "should find the complement of a '1' split is '0'"
            , Split.fromFloat 0.3
                |> Result.map Split.complement
                |> Expect.equal (Split.fromFloat 0.7)
                |> asTest "should find the complement of a '0.3' split is '0.7'"
            ]
        , describe "apply"
            [ Split.zero
                |> Split.apply 123.45
                |> Expect.equal 0
                |> asTest "should return 0 when applying a 'zero' split"
            , Split.full
                |> Split.apply 123.45
                |> Expect.within (Expect.Absolute 0) 123.45
                |> asTest "should return the float when applying a 'full' split"
            , Split.fromFloat 0.5
                |> Result.map (Split.apply 123.45)
                |> Expect.equal (Ok 61.725)
                |> asTest "should return half of the float when applying a 0.5 split"
            ]
        , describe "decoder"
            [ "0.12"
                |> Decode.decodeString Split.decodeFloat
                |> Result.mapError Decode.errorToString
                |> Expect.equal (Split.fromFloat 0.12)
                |> asTest "should provide a decoder"
            ]
        , describe "encode"
            [ Split.fromFloat 0.12
                |> Result.map Split.encodeFloat
                |> Result.map (Encode.encode 0)
                |> Expect.equal (Ok "0.12")
                |> asTest "should provide an encoder"
            ]
        ]
