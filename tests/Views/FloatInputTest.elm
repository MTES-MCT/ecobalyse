module Views.FloatInputTest exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (it)
import Views.FloatInput as FloatInput


sample =
    { allowNegative = False
    , current = 1
    , id = "unit-mass-0"
    , max = Nothing
    , min = Just 0
    , text = ""
    }


suite : Test
suite =
    describe "Views.FloatInput"
        [ describe "format"
            [ it "uses the configured separator"
                (1.25
                    |> FloatInput.format ','
                    |> Expect.equal "1,25"
                )
            , it "keeps an integer without a decimal part"
                (1
                    |> FloatInput.format ','
                    |> Expect.equal "1"
                )
            , it "can display a dot separator"
                (1.5
                    |> FloatInput.format '.'
                    |> Expect.equal "1.5"
                )
            ]
        , describe "applyEdit"
            [ it "stores the state while typing"
                (Nothing
                    |> FloatInput.applyState { draft = Just "1,", id = "unit-mass-0", value = Nothing }
                    |> Expect.equal (Just { draft = Just "1,", id = "unit-mass-0", value = Nothing })
                )
            , it "clears the state of the blurred field"
                (Just { draft = Just "1,0", id = "unit-mass-0", value = Nothing }
                    |> FloatInput.applyState { draft = Nothing, id = "unit-mass-0", value = Nothing }
                    |> Expect.equal Nothing
                )
            , it "keeps the state of another field"
                (Just { draft = Just "1,0", id = "unit-mass-0", value = Nothing }
                    |> FloatInput.applyState { draft = Nothing, id = "unit-mass-1", value = Nothing }
                    |> Expect.equal (Just { draft = Just "1,0", id = "unit-mass-0", value = Nothing })
                )
            ]
        , describe "fromInput"
            [ it "keeps an empty field without resolving a value"
                (FloatInput.fromInput sample
                    |> expectState "" Nothing
                )
            , it "keeps a trailing separator"
                ({ sample | text = "1," }
                    |> FloatInput.fromInput
                    |> expectState "1," Nothing
                )
            , it "keeps a trailing zero when the float is unchanged"
                ({ sample | text = "1,0" }
                    |> FloatInput.fromInput
                    |> expectState "1,0" Nothing
                )
            , it "resolves a complete decimal"
                ({ sample | text = "1,01" }
                    |> FloatInput.fromInput
                    |> expectState "1,01" (Just 1.01)
                )
            , it "resolves a complete decimal with a dot separator"
                ({ sample | text = "1.01" }
                    |> FloatInput.fromInput
                    |> expectState "1.01" (Just 1.01)
                )
            , it "rejects a letter"
                ({ sample | text = "1a" }
                    |> FloatInput.fromInput
                    |> Expect.equal Nothing
                )
            , it "rejects a negative number when they are disabled"
                ({ sample | text = "-1" }
                    |> FloatInput.fromInput
                    |> Expect.equal Nothing
                )
            , it "resolves a negative number when they are enabled"
                ({ sample | allowNegative = True, min = Nothing, text = "-1,5" }
                    |> FloatInput.fromInput
                    |> expectState "-1,5" (Just -1.5)
                )
            , it "does not resolve a number above max"
                ({ sample | max = Just 10, text = "11" }
                    |> FloatInput.fromInput
                    |> expectState "11" Nothing
                )
            , it "resolves zero when min is zero"
                ({ sample | text = "0" }
                    |> FloatInput.fromInput
                    |> expectState "0" (Just 0)
                )
            ]
        ]


expectState : String -> Maybe Float -> Maybe FloatInput.State -> Expectation
expectState text expectedValue maybeState =
    case maybeState of
        Nothing ->
            Expect.fail "no available state"

        Just state ->
            state
                |> Expect.all
                    [ .draft >> Expect.equal (Just text)
                    , .id >> Expect.equal sample.id
                    , .value
                        >> (\actual ->
                                case ( expectedValue, actual ) of
                                    ( Nothing, Nothing ) ->
                                        Expect.pass

                                    ( Just expected, Just actualFloat ) ->
                                        Expect.within (Expect.Absolute 1.0e-9) expected actualFloat

                                    _ ->
                                        Expect.fail "resolved value did not match"
                           )
                    ]
