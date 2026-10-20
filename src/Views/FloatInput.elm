module Views.FloatInput exposing
    ( Config
    , State
    , applyState
    , format
    , fromInput
    , isValidDraft
    , view
    )

import Data.Text as Text
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP


type alias Config msg =
    { decimalSeparator : Char
    , id : String
    , label : String
    , max : Maybe Float
    , min : Maybe Float
    , noOp : msg
    , onInput : State -> msg
    , state : Maybe State
    , value : Float
    }


type alias Input =
    { current : Float
    , id : String
    , max : Maybe Float
    , min : Maybe Float
    , text : String
    }


type alias State =
    { draft : Maybe String
    , id : String
    , value : Maybe Float
    }


applyState : State -> Maybe State -> Maybe State
applyState ({ draft, id } as newState) currentState =
    case draft of
        Just _ ->
            Just newState

        Nothing ->
            currentState
                |> Maybe.andThen
                    (\stored ->
                        if stored.id == id then
                            Nothing

                        else
                            Just stored
                    )


boundAttributes : Config msg -> List (Attribute msg)
boundAttributes config =
    List.filterMap identity
        [ config.max |> Maybe.map (String.fromFloat >> Attr.max)
        , config.min |> Maybe.map (String.fromFloat >> Attr.min)
        ]


onBeforeInput : Config msg -> Attribute msg
onBeforeInput { noOp } =
    preventDefaultOn "beforeinput" <|
        -- https://developer.mozilla.org/en-US/docs/Web/API/Element/beforeinput_event
        (Decode.succeed
            (\inputType data value start end ->
                ( inputType
                , String.left start value ++ data ++ String.dropLeft end value
                )
            )
            |> JDP.required "inputType" Decode.string
            |> JDP.optional "data" Decode.string ""
            |> JDP.requiredAt [ "target", "value" ] Decode.string
            |> JDP.optionalAt [ "target", "selectionStart" ] Decode.int 0
            |> JDP.optionalAt [ "target", "selectionEnd" ] Decode.int 0
            |> Decode.andThen
                (\( inputType, next ) ->
                    if
                        -- user typed a character or pasted text
                        (inputType == "insertText" || inputType == "insertFromPaste")
                            -- the field would no longer be a number they are allowed to enter
                            && not (isLegalPrefix next)
                    then
                        -- drop the keystroke or paste, so the field stays unchanged
                        Decode.succeed ( noOp, True )

                    else
                        -- note: failing on preventDefault *keeps* the edit
                        Decode.fail "accepted input"
                )
        )


displayText : Config msg -> String
displayText ({ decimalSeparator, id, value } as config) =
    case config.state of
        Just state ->
            if state.id == id then
                state.draft
                    |> Maybe.withDefault (format decimalSeparator value)

            else
                format decimalSeparator value

        Nothing ->
            format decimalSeparator value


format : Char -> Float -> String
format separator float =
    String.fromFloat float
        |> String.replace "." (String.fromChar separator)


fromInput : Input -> Maybe State
fromInput { current, id, max, min, text } =
    if isLegalPrefix text then
        Just
            { draft = Just text
            , id = id
            , value =
                parse text
                    |> Maybe.andThen
                        (\float ->
                            if inRange min max float && float /= current then
                                Just float

                            else
                                Nothing
                        )
            }

    else
        Nothing


inRange : Maybe Float -> Maybe Float -> Float -> Bool
inRange min max float =
    (min |> Maybe.map (\lower -> float > lower) |> Maybe.withDefault True)
        && (max |> Maybe.map (\upper -> float <= upper) |> Maybe.withDefault True)


isValidDraft : Config msg -> Bool
isValidDraft ({ id, max, min } as config) =
    case config.state of
        Just state ->
            if state.id == id then
                case state.draft of
                    Just text ->
                        case parse text of
                            Just float ->
                                inRange min max float

                            Nothing ->
                                False

                    Nothing ->
                        True

            else
                True

        Nothing ->
            True


isLegalPrefix : String -> Bool
isLegalPrefix text =
    case text |> String.replace "," "." |> String.split "." of
        [ int ] ->
            Text.isDigitsOnly int

        [ int, decimals ] ->
            Text.isDigitsOnly int && Text.isDigitsOnly decimals

        _ ->
            False


{-| Float number parser, handling `,` as a decimal separator and intermediary typing states.
-}
parse : String -> Maybe Float
parse text =
    if
        -- empty field
        String.isEmpty text
            -- user is about to enter a decimal
            || String.endsWith "," text
            || String.endsWith "." text
    then
        Nothing

    else
        text |> String.replace "," "." |> String.toFloat


view : Config msg -> Html msg
view config =
    input
        (boundAttributes config
            ++ [ type_ "text"
               , class "form-control form-control-sm text-end"
               , classList [ ( "bg-warning", not <| isValidDraft config ) ]
               , id config.id
               , attribute "aria-label" config.label
               , attribute "autocomplete" "off"
               , attribute "inputmode" "decimal"
               , spellcheck False
               , value (displayText config)
               , onInput <|
                    \text ->
                        fromInput
                            { current = config.value
                            , id = config.id
                            , max = config.max
                            , min = config.min
                            , text = text
                            }
                            |> Maybe.map config.onInput
                            |> Maybe.withDefault config.noOp

               -- reset state when input loses focus
               , onBlur <|
                    config.onInput { draft = Nothing, id = config.id, value = Nothing }

               -- catch and validate text insertions
               , onBeforeInput config
               ]
        )
        []
