module Data.SplitTest exposing (..)

import Data.Split as Split
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Mass
import Quantity
import Result.Extra as RE
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Split"
        [ describe "fromFloat constructor"
            [ -0.1
                |> Split.fromFloat
                |> Expect.equal (Err "Cette proportion doit être comprise entre 0 et 1 inclus (ici\u{202F}: -0.1)")
                |> asTest "should return an error if the split is less than 0"
            , 1.1
                |> Split.fromFloat
                |> Expect.equal (Err "Cette proportion doit être comprise entre 0 et 1 inclus (ici\u{202F}: 1.1)")
                |> asTest "should return an error if the split is greater than 1"
            , 0.12
                |> Split.fromFloat
                |> Result.map Split.toFloat
                |> Expect.equal (Ok 0.12)
                |> asTest "should provide a float constructor and extractor"
            ]
        , describe "fromBoundedFloat constructor"
            [ 0.1
                |> Split.fromBoundedFloat 0.2 1
                |> Expect.equal (Err "Cette proportion doit être comprise entre 0.2 et 1 inclus (ici\u{202F}: 0.1)")
                |> asTest "should return an error if the split is greater than min possible value"
            , 0.9
                |> Split.fromBoundedFloat 0 0.8
                |> Expect.equal (Err "Cette proportion doit être comprise entre 0 et 0.8 inclus (ici\u{202F}: 0.9)")
                |> asTest "should return an error if the split is greater than max possible value"
            ]
        , describe "fromPercent constructor"
            [ 12
                |> Split.fromPercent
                |> Result.map Split.toPercent
                |> Expect.equal (Ok 12)
                |> asTest "should provide a percent constructor and extractor"
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
                |> Result.map (Split.toPercentString 0)
                |> Expect.equal (Ok "12")
                |> asTest "should return a percent string representation"
            , 0.1234
                |> Split.fromFloat
                |> Result.map (Split.toPercentString 2)
                |> Expect.equal (Ok "12,34")
                |> asTest "should return a percent string representation with decimals"
            , 0.12
                |> Split.fromFloat
                |> Result.map (Split.toPercentString 2)
                |> Expect.equal (Ok "12,00")
                |> asTest "should return a percent string representation with decimals and trailing zeroes"
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
                |> asTest "should return infinity when applying a 'zero' split"
            , Split.full
                |> Split.apply 123.45
                |> Expect.within (Expect.Absolute 0) 123.45
                |> asTest "should return the float when applying a 'full' split"
            , Split.fromFloat 0.5
                |> Result.map (Split.apply 123.45)
                |> Expect.equal (Ok 61.725)
                |> asTest "should return half of the float when applying a 0.5 split"
            ]
        , describe "applyToQuantity"
            [ Split.zero
                |> Split.applyToQuantity Mass.kilogram
                |> Expect.equal Quantity.zero
                |> asTest "should return an empty quantity when applying a 'zero' split"
            , Split.full
                |> Split.applyToQuantity Mass.kilogram
                |> Expect.equal Mass.kilogram
                |> asTest "should return the initial quantity when applying a 'full' split"
            , Split.half
                |> Split.applyToQuantity Mass.kilogram
                |> Expect.equal (Mass.kilograms 0.5)
                |> asTest "should return half of the quantity when applying a half split"
            ]
        , describe "assemble"
            [ [ Split.zero, Split.full ]
                |> Split.assemble
                |> Expect.ok
                |> asTest "should accept a list of splits summing to exactly 100%"
            , [ Split.zero, Split.tenth ]
                |> Split.assemble
                |> Expect.err
                |> asTest "should reject a list of splits < 100%"
            , [ Split.full, Split.full ]
                |> Split.assemble
                |> Expect.err
                |> asTest "should reject a list of splits exceeding 100%"
            , [ Split.fromFloat (1 / 3), Split.fromFloat (1 / 3), Split.fromFloat (1 / 3) ]
                |> RE.combine
                |> Result.andThen Split.assemble
                |> Expect.ok
                |> asTest "should accept a list of splits summing to 100% with float precision error"
            ]
        , describe "divideBy"
            [ Split.zero
                |> Split.divideBy 123.45
                |> isInfinite
                |> Expect.equal True
                |> asTest "should return infinity when dividing by a 'zero' split"
            , Split.full
                |> Split.divideBy 123.45
                |> Expect.within (Expect.Absolute 0) 123.45
                |> asTest "should return the float when dividing by a 'full' split"
            , Split.fromFloat 0.5
                |> Result.map (Split.divideBy 123.45)
                |> Expect.equal (Ok 246.9)
                |> asTest "should return double the float when dividing by a 0.5 split"
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
