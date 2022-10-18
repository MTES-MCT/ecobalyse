module Views.Component.AmountInput exposing (view)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { amount : Float
    , onAmountChanged : Maybe Float -> msg
    , unit : String
    }


view : Config msg -> Html msg
view { amount, onAmountChanged, unit } =
    div [ class "input-group input-group" ]
        [ input
            [ class "form-control text-end incdec-arrows-left"
            , type_ "number"
            , step "1"
            , amount
                |> (\f -> f * 1000)
                |> round
                |> String.fromInt
                |> value
            , title "Quantité en grammes"
            , onInput <|
                \str ->
                    onAmountChanged
                        (if str == "" then
                            Just 0

                         else
                            str |> String.toFloat |> Maybe.map (\f -> f / 1000)
                        )
            , Attr.min "0"
            ]
            []
        , span [ class "input-group-text" ]
            [ text
                (case unit of
                    "kg" ->
                        "g"

                    "l" ->
                        "ml"

                    _ ->
                        "?"
                )
            ]
        ]
