module Data.ValidationTest exposing (..)

import Data.Validation as Validation
import Dict
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


type alias TestSimple =
    { x : Int, y : Int }


type alias TestMaybe =
    { x : Int, y : Maybe Int }


type alias TestList =
    { list : List Int }


suite : Test
suite =
    describe "Validation"
        [ describe "accept"
            [ Ok TestSimple
                |> Validation.accept "x" 1
                |> Validation.accept "y" 2
                |> Expect.equal (Ok { x = 1, y = 2 })
                |> asTest "should accept direct values"
            ]
        , describe "boundedList"
            [ Ok TestList
                |> Validation.boundedList 2 Nothing "list" [ 1 ] Ok
                |> Expect.equal (Err (Dict.fromList [ ( "list", "La liste 'list' doit contenir 2 élément(s) minimum." ) ]))
                |> asTest "should reject a list with a required minimum number of elements"
            , Ok TestList
                |> Validation.boundedList 0 (Just 2) "list" [ 1, 2, 3 ] Ok
                |> Expect.equal (Err (Dict.fromList [ ( "list", "La liste 'list' doit contenir 2 élément(s) maximum." ) ]))
                |> asTest "should reject a list with a required maximum number of elements"
            , Ok TestList
                |> Validation.boundedList 1 (Just 2) "list" [ 1, 2, 3 ] Ok
                |> Expect.equal (Err (Dict.fromList [ ( "list", "La liste 'list' doit contenir entre 1 et 2 élément(s) maximum." ) ]))
                |> asTest "should reject a list with a required minimum and maximum number of elements"
            , Ok TestList
                |> Validation.boundedList 1 (Just 2) "list" [ 1, 2 ] Ok
                |> Expect.equal (Ok { list = [ 1, 2 ] })
                |> asTest "should accept a list matching size requirements"
            ]
        , describe "list"
            [ Ok TestList
                |> Validation.list "list" [ 1 ] Ok
                |> Expect.equal (Ok { list = [ 1 ] })
                |> asTest "should accept a valid list"
            , Ok TestList
                |> Validation.list "list"
                    [ 1, 2 ]
                    (\int ->
                        if int > 1 then
                            Err <| String.fromInt int ++ " is too high"

                        else
                            Ok int
                    )
                |> Expect.equal (Err (Dict.fromList [ ( "list", "2 is too high" ) ]))
                |> asTest "should reject an invalid list"
            ]
        , describe "maybe"
            [ Ok TestMaybe
                |> Validation.validate "x" (Ok 1)
                |> Validation.maybe "y" (Just 2) Ok
                |> Expect.equal (Ok { x = 1, y = Just 2 })
                |> asTest "should accept an optional value"
            , Ok TestMaybe
                |> Validation.validate "x" (Ok 1)
                |> Validation.maybe "y" Nothing (always <| Err "y is bad")
                |> Expect.equal (Ok { x = 1, y = Nothing })
                |> asTest "should reject an invalid optional value"
            ]
        , describe "nonEmptyList"
            [ Ok TestList
                |> Validation.nonEmptyList "x" [ 1 ] Ok
                |> Expect.equal (Ok { list = [ 1 ] })
                |> asTest "should accept a non-empty list"
            , Ok TestList
                |> Validation.nonEmptyList "x" [] Ok
                |> Expect.equal (Err (Dict.fromList [ ( "x", "La liste 'x' ne peut pas être vide." ) ]))
                |> asTest "should reject an empty list"
            ]
        , describe "validate"
            [ Ok TestSimple
                |> Validation.validate "x" (Ok 1)
                |> Validation.validate "y" (Ok 2)
                |> Expect.equal (Ok { x = 1, y = 2 })
                |> asTest "should accept an Ok result"
            , Ok TestSimple
                |> Validation.validate "x" (Ok 1)
                |> Validation.validate "y" (Err "y is bad")
                |> Expect.equal (Err (Dict.fromList [ ( "y", "y is bad" ) ]))
                |> asTest "should reject with a single error"
            , Ok TestSimple
                |> Validation.validate "x" (Err "x is bad")
                |> Validation.validate "y" (Ok 2)
                |> Expect.equal (Err (Dict.fromList [ ( "x", "x is bad" ) ]))
                |> asTest "should reject with a single error, whatever the failure order is"
            , Ok TestSimple
                |> Validation.validate "x" (Err "x is bad")
                |> Validation.validate "y" (Err "y is bad")
                |> Expect.equal (Err (Dict.fromList [ ( "x", "x is bad" ), ( "y", "y is bad" ) ]))
                |> asTest "should reject with multiple errors"
            ]
        ]
