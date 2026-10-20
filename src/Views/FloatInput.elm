module Views.FloatInput exposing
    ( Config
    , Draft
    , Edit
    , applyDraft
    , format
    , fromInput
    , view
    )

import Data.Text as Text
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP


type alias Config msg =
    { allowNegative : Bool
    , decimalSeparator : Char
    , draft : Maybe Draft
    , id : String
    , label : String
    , max : Maybe Float
    , min : Maybe Float
    , noOp : msg
    , onInput : Edit -> msg
    , step : Maybe Float
    , value : Float
    }


type alias Draft =
    { id : String
    , text : String
    }


type alias Edit =
    { draft : Maybe String
    , id : String
    , value : Maybe Float
    }


type alias Input =
    { allowNegative : Bool
    , current : Float
    , id : String
    , max : Maybe Float
    , min : Maybe Float
    , text : String
    }


applyDraft : Maybe Draft -> Edit -> Maybe Draft
applyDraft current { draft, id } =
    case draft of
        Just next ->
            Just { id = id, text = next }

        Nothing ->
            current
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
        , config.step |> Maybe.map (String.fromFloat >> step)
        ]


displayText : Config msg -> String
displayText ({ decimalSeparator, id, value } as config) =
    case config.draft of
        Just draft ->
            if draft.id == id then
                draft.text

            else
                format decimalSeparator value

        Nothing ->
            format decimalSeparator value


format : Char -> Float -> String
format separator float =
    String.fromFloat float
        |> String.replace "." (String.fromChar separator)


fromInput : Input -> Maybe Edit
fromInput { allowNegative, current, id, max, min, text } =
    if isLegalPrefix allowNegative text then
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
    Maybe.withDefault True <|
        Maybe.map2
            (\lower upper -> float >= lower && float <= upper)
            min
            max


isLegalPrefix : Bool -> String -> Bool
isLegalPrefix allowNegative text =
    case String.uncons text of
        Just ( '-', rest ) ->
            allowNegative && isUnsignedPrefix rest

        Just _ ->
            isUnsignedPrefix text

        Nothing ->
            True


isUnsignedPrefix : String -> Bool
isUnsignedPrefix text =
    case text |> String.replace "," "." |> String.split "." of
        [ int ] ->
            Text.isDigitsOnly int

        [ int, decimals ] ->
            Text.isDigitsOnly int && Text.isDigitsOnly decimals

        _ ->
            False


decodeBeforeInputEvent : Config msg -> Decoder ( msg, Bool )
decodeBeforeInputEvent { allowNegative, noOp } =
    -- https://developer.mozilla.org/en-US/docs/Web/API/Element/beforeinput_event
    Decode.succeed
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
                    (inputType == "insertText" || inputType == "insertFromPaste")
                        && not (isLegalPrefix allowNegative next)
                then
                    Decode.succeed ( noOp, True )

                else
                    Decode.fail "invalid input"
            )


{-| Float number parser, handling `,` as a decimal separator, `-` as negative sign and
intermediary typing states.
-}
parse : String -> Maybe Float
parse text =
    if
        -- empty field
        String.isEmpty text
            -- user started to type a negative number
            || (text == "-")
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
               , id config.id
               , attribute "aria-label" config.label
               , attribute "autocomplete" "off"
               , attribute "inputmode" "decimal"
               , spellcheck False
               , value (displayText config)
               , onInput <|
                    \text ->
                        fromInput
                            { allowNegative = config.allowNegative
                            , current = config.value
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
               , preventDefaultOn "beforeinput" <|
                    decodeBeforeInputEvent config
               ]
        )
        []
