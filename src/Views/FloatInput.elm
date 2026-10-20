module Views.FloatInput exposing
    ( Config
    , Draft
    , Edit
    , applyDraft
    , format
    , fromInput
    , view
    )

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Events exposing (..)
import Json.Decode as Decode


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
    { draft : Maybe Draft
    , id : String
    , value : Maybe Float
    }


applyDraft : Maybe Draft -> Edit -> Maybe Draft
applyDraft current { draft, id } =
    case draft of
        Just next ->
            Just next

        Nothing ->
            current
                |> Maybe.andThen
                    (\stored ->
                        if stored.id == id then
                            Nothing

                        else
                            Just stored
                    )


blurEdit : Config msg -> Edit
blurEdit config =
    { draft = Nothing
    , id = config.id
    , value = Nothing
    }


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


fromInput :
    { allowNegative : Bool
    , current : Float
    , id : String
    , max : Maybe Float
    , min : Maybe Float
    , text : String
    }
    -> Maybe Edit
fromInput { allowNegative, current, id, max, min, text } =
    if isLegalPrefix allowNegative text then
        Just
            { draft = Just { id = id, text = text }
            , id = id
            , value =
                text
                    |> parse
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
    (min
        |> Maybe.map (\lower -> float >= lower)
        |> Maybe.withDefault True
    )
        && (max
                |> Maybe.map (\upper -> float <= upper)
                |> Maybe.withDefault True
           )


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
    let
        ( separators, otherCharacters ) =
            text
                |> String.toList
                |> List.partition (\char -> char == ',' || char == '.')
    in
    (List.length separators <= 1) && List.all Char.isDigit otherCharacters


onBeforeInput : Bool -> msg -> Attribute msg
onBeforeInput allowNegative noOp =
    Events.preventDefaultOn "beforeinput"
        (Decode.map5
            (\inputType data value start end ->
                ( inputType
                , String.left start value ++ data ++ String.dropLeft end value
                )
            )
            (Decode.field "inputType" Decode.string)
            (Decode.map (Maybe.withDefault "") (Decode.field "data" (Decode.nullable Decode.string)))
            (Decode.at [ "target", "value" ] Decode.string)
            (Decode.map (Maybe.withDefault 0) (Decode.at [ "target", "selectionStart" ] (Decode.nullable Decode.int)))
            (Decode.map (Maybe.withDefault 0) (Decode.at [ "target", "selectionEnd" ] (Decode.nullable Decode.int)))
            |> Decode.andThen
                (\( inputType, next ) ->
                    if (inputType == "insertText" || inputType == "insertFromPaste") && not (isLegalPrefix allowNegative next) then
                        Decode.succeed ( noOp, True )

                    else
                        Decode.fail "accepted"
                )
        )


parse : String -> Maybe Float
parse text =
    if String.isEmpty text || text == "-" || String.endsWith "," text || String.endsWith "." text then
        Nothing

    else
        text
            |> String.replace "," "."
            |> String.toFloat


view : Config msg -> Html msg
view config =
    input
        (boundAttributes config
            ++ [ attribute "aria-label" config.label
               , attribute "autocomplete" "off"
               , class "form-control form-control-sm text-end"
               , id config.id
               , attribute "inputmode" "decimal"
               , spellcheck False
               , type_ "text"
               , value (displayText config)
               , onInput
                    (\text ->
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
                    )
               , onBlur (config.onInput (blurEdit config))
               , onBeforeInput config.allowNegative config.noOp
               ]
        )
        []
