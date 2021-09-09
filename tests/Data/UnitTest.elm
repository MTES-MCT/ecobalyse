module Data.UnitTest exposing (..)

import Data.Unit as Unit
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Data.Unit"
        [ describe "kgOp"
            [ test "add 2 members" <|
                \_ -> Unit.kgOp (+) (Unit.Kg 1) (Unit.Kg 2) |> Expect.equal (Unit.Kg 3)
            , test "add 2 members swapped" <|
                \_ -> Unit.kgOp (+) (Unit.Kg 2) (Unit.Kg 1) |> Expect.equal (Unit.Kg 3)
            , test "substract 2 members" <|
                \_ -> Unit.kgOp (-) (Unit.Kg 1) (Unit.Kg 2) |> Expect.equal (Unit.Kg -1)
            , test "substract 2 members swapped" <|
                \_ -> Unit.kgOp (-) (Unit.Kg 2) (Unit.Kg 1) |> Expect.equal (Unit.Kg 1)
            ]
        ]
