module Views.Component.AmountInput exposing (view)

import Data.Food.Amount as Amount exposing (Amount)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { amount : Amount
    , onAmountChanged : Maybe Amount -> msg
    , fromUnit : Amount -> Float
    }


view : Config msg -> Html msg
view { amount, onAmountChanged, fromUnit } =
    div [ class "input-group input-group" ]
        [ input
            [ class "form-control text-end incdec-arrows-left"
            , type_ "number"
            , step "1"
            , amount
                |> fromUnit
                |> round
                |> String.fromInt
                |> value
            , title "Quantité en grammes"
            , onInput <|
                \str ->
                    onAmountChanged
                        (if str == "" then
                            Nothing

                         else
                            str
                                |> String.toFloat
                                |> Maybe.map (Amount.setFloat amount)
                        )
            , Attr.min "0"
            ]
            []
        , span [ class "input-group-text" ]
            [ amount
                |> Amount.toDisplayTuple
                |> Tuple.second
                |> text
            ]
        ]
