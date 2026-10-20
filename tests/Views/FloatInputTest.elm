module Views.FloatInputTest exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (asTest)
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
            [ 1.25
                |> FloatInput.format ','
                |> Expect.equal "1,25"
                |> asTest "uses the configured separator"
            , 1
                |> FloatInput.format ','
                |> Expect.equal "1"
                |> asTest "keeps an integer without a decimal part"
            , 1.5
                |> FloatInput.format '.'
                |> Expect.equal "1.5"
                |> asTest "can display a dot separator"
            ]
        , describe "applyDraft"
            [ FloatInput.applyDraft Nothing
                { draft = Just "1,"
                , id = "unit-mass-0"
                , value = Nothing
                }
                |> Expect.equal (Just { id = "unit-mass-0", text = "1," })
                |> asTest "stores the draft while typing"
            , FloatInput.applyDraft (Just { id = "unit-mass-0", text = "1,0" })
                { draft = Nothing
                , id = "unit-mass-0"
                , value = Nothing
                }
                |> Expect.equal Nothing
                |> asTest "clears the draft of the blurred field"
            , FloatInput.applyDraft (Just { id = "unit-mass-0", text = "1,0" })
                { draft = Nothing
                , id = "unit-mass-1"
                , value = Nothing
                }
                |> Expect.equal (Just { id = "unit-mass-0", text = "1,0" })
                |> asTest "keeps the draft of another field"
            ]
        , describe "fromInput"
            [ sample
                |> FloatInput.fromInput
                |> expectEdit "" Nothing
                |> asTest "keeps an empty field without resolving a value"
            , { sample | text = "1," }
                |> FloatInput.fromInput
                |> expectEdit "1," Nothing
                |> asTest "keeps a trailing separator"
            , { sample | text = "1,0" }
                |> FloatInput.fromInput
                |> expectEdit "1,0" Nothing
                |> asTest "keeps a trailing zero when the float is unchanged"
            , { sample | text = "1,01" }
                |> FloatInput.fromInput
                |> expectEdit "1,01" (Just 1.01)
                |> asTest "resolves a complete decimal"
            , { sample | text = "1.01" }
                |> FloatInput.fromInput
                |> expectEdit "1.01" (Just 1.01)
                |> asTest "also accepts a dot while typing"
            , { sample | text = "1a" }
                |> FloatInput.fromInput
                |> Expect.equal Nothing
                |> asTest "rejects a letter"
            , { sample | text = "-1" }
                |> FloatInput.fromInput
                |> Expect.equal Nothing
                |> asTest "rejects a negative number when they are disabled"
            , { sample | allowNegative = True, min = Nothing, text = "-1,5" }
                |> FloatInput.fromInput
                |> expectEdit "-1,5" (Just -1.5)
                |> asTest "resolves a negative number when they are enabled"
            , { sample | max = Just 10, text = "11" }
                |> FloatInput.fromInput
                |> expectEdit "11" Nothing
                |> asTest "does not resolve a number above max"
            , { sample | text = "0" }
                |> FloatInput.fromInput
                |> expectEdit "0" (Just 0)
                |> asTest "resolves zero when min is zero"
            ]
        ]


expectEdit : String -> Maybe Float -> Maybe FloatInput.Edit -> Expectation
expectEdit text expectedValue maybeEdit =
    case maybeEdit of
        Nothing ->
            Expect.fail "the text was rejected"

        Just edit ->
            Expect.all
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
                edit
