module Views.FloatInput exposing
    ( Config
    , State
    , WriteAccess(..)
    , applyState
    , format
    , fromInput
    , isValidDraft
    , view
    )

{-| A controlled text input to handle positive, greater than zero floating point numbers.
Accepts either `,` or `.` as decimal separator.
-}

import Data.Text as Text
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP


type alias Config msg =
    { id : String
    , label : String
    , noOp : msg
    , onInput : State -> msg
    , state : Maybe State
    , value : Float
    , writeAccess : WriteAccess
    }


type alias State =
    { draft : Maybe String
    , id : String
    , value : Maybe Float
    }


type WriteAccess
    = ReadOnly String
    | Writeable


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


displayText : Config msg -> String
displayText ({ id, value } as config) =
    case config.state of
        Just state ->
            if state.id == id then
                state.draft
                    |> Maybe.withDefault (format value)

            else
                format value

        Nothing ->
            format value


format : Float -> String
format float =
    String.fromFloat float
        |> String.replace "." ","


fromInput : Config msg -> String -> Maybe State
fromInput { id, value } text =
    if isLegalPrefix text then
        Just
            { draft = Just text
            , id = id
            , value =
                parse text
                    |> Maybe.andThen
                        (\float ->
                            if float > 0 && float /= value then
                                Just float

                            else
                                Nothing
                        )
            }

    else
        Nothing


getAttributes : Config msg -> List (Attribute msg)
getAttributes config =
    case config.writeAccess of
        ReadOnly readonlyTitle ->
            [ class "cursor-not-allowed"
            , readonly True
            , title readonlyTitle
            , value (format config.value)
            ]

        Writeable ->
            [ classList [ ( "bg-warning-subtle", not <| isValidDraft config ) ]
            , value (displayText config)
            , onInput <|
                \text ->
                    fromInput config text
                        |> Maybe.map config.onInput
                        |> Maybe.withDefault config.noOp

            -- reset state when input loses focus
            , onBlur <| config.onInput (resetState config.id)

            -- catch and validate text insertions
            , onBeforeInput config
            ]


isValidDraft : Config msg -> Bool
isValidDraft config =
    case config.state of
        Just state ->
            if state.id == config.id then
                case state.draft of
                    Just text ->
                        case parse text of
                            Just float ->
                                float > 0

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


parse : String -> Maybe Float
parse text =
    let
        normalized =
            String.replace "," "." text
    in
    if
        -- empty field
        String.isEmpty normalized
            -- user is about to enter a decimal
            || String.endsWith "." normalized
            -- missing integer part
            || String.startsWith "." normalized
    then
        Nothing

    else
        String.toFloat normalized


resetState : String -> State
resetState id =
    { draft = Nothing
    , id = id
    , value = Nothing
    }


view : Config msg -> Html msg
view config =
    input
        (getAttributes config
            ++ [ type_ "text"
               , class "form-control form-control-sm text-end"
               , id config.id
               , attribute "aria-label" config.label
               , attribute "autocomplete" "off"
               , attribute "inputmode" "decimal"
               , spellcheck False
               ]
        )
        []
