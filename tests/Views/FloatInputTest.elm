module Views.FloatInputTest exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import TestUtils exposing (it)
import Views.FloatInput as FloatInput


sample =
    { id = "unit-mass-0"
    , label = "Masse unitaire"
    , max = Nothing
    , min = Just 0
    , noOp = ()
    , onInput = \_ -> ()
    , state = Nothing
    , value = 1
    , writeAccess = FloatInput.Writeable
    }


suite : Test
suite =
    describe "Views.FloatInput"
        [ describe "format"
            [ it "displays a comma as the decimal separator"
                (1.25
                    |> FloatInput.format
                    |> Expect.equal "1,25"
                )
            , it "keeps an integer without a decimal part"
                (1
                    |> FloatInput.format
                    |> Expect.equal "1"
                )
            ]
        , describe "applyState"
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
                (FloatInput.fromInput sample ""
                    |> expectState "" Nothing
                )
            , it "keeps a trailing separator"
                (FloatInput.fromInput sample "1,"
                    |> expectState "1," Nothing
                )
            , it "keeps a trailing zero when the float is unchanged"
                (FloatInput.fromInput sample "1,0"
                    |> expectState "1,0" Nothing
                )
            , it "resolves a complete decimal"
                (FloatInput.fromInput sample "1,01"
                    |> expectState "1,01" (Just 1.01)
                )
            , it "resolves a complete decimal with a dot separator"
                (FloatInput.fromInput sample "1.01"
                    |> expectState "1.01" (Just 1.01)
                )
            , it "does not resolve a decimal without an integer part"
                (FloatInput.fromInput sample ",2"
                    |> expectState ",2" Nothing
                )
            , it "does not resolve a dot decimal without an integer part"
                (FloatInput.fromInput sample ".2"
                    |> expectState ".2" Nothing
                )
            , it "rejects a letter"
                (FloatInput.fromInput sample "1a"
                    |> Expect.equal Nothing
                )
            , it "rejects a negative number"
                (FloatInput.fromInput sample "-1"
                    |> Expect.equal Nothing
                )
            , it "does not resolve a number above max"
                (FloatInput.fromInput { sample | max = Just 10 } "11"
                    |> expectState "11" Nothing
                )
            , it "does not resolve zero when it is not above the minimum"
                (FloatInput.fromInput sample "0"
                    |> expectState "0" Nothing
                )
            ]
        , let
            setSampleText text =
                { sample | state = Just { draft = Just text, id = sample.id, value = Nothing } }
          in
          describe "isValidDraft"
            [ it "is true when the field is not being edited"
                (FloatInput.isValidDraft sample
                    |> Expect.equal True
                )
            , it "is true when another field is being edited"
                (FloatInput.isValidDraft
                    { sample | state = Just { draft = Just "1,", id = "other", value = Nothing } }
                    |> Expect.equal True
                )
            , it "is false when the draft is not a complete number"
                (FloatInput.isValidDraft (setSampleText "1,")
                    |> Expect.equal False
                )
            , it "is false when the draft has no integer part"
                (FloatInput.isValidDraft (setSampleText ",2")
                    |> Expect.equal False
                )
            , it "is true when the draft resolves to the current value"
                (FloatInput.isValidDraft (setSampleText "1,0")
                    |> Expect.equal True
                )
            , it "is true when the draft resolves to a new value"
                (FloatInput.isValidDraft (setSampleText "1,5")
                    |> Expect.equal True
                )
            , it "is false when the draft is not above the minimum"
                (FloatInput.isValidDraft (setSampleText "0")
                    |> Expect.equal False
                )
            , it "is false when the draft is outside the allowed range"
                (FloatInput.isValidDraft
                    { sample
                        | max = Just 10
                        , state = Just { draft = Just "11", id = sample.id, value = Nothing }
                    }
                    |> Expect.equal False
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
