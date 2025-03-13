module Views.Component.MassInput exposing (view)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass exposing (Mass)


type alias Config msg =
    { disabled : Bool
    , mass : Mass
    , onChange : Maybe Mass -> msg
    }


view : Config msg -> Html msg
view { disabled, mass, onChange } =
    div [ class "input-group" ]
        [ input
            [ class "form-control text-end incdec-arrows-left"
            , type_ "number"
            , step "1"
            , mass
                |> Mass.inGrams
                |> round
                |> String.fromInt
                |> value
            , title "Quantité en grammes"
            , onInput <|
                \str ->
                    onChange
                        (if str == "" then
                            Nothing

                         else
                            str
                                |> String.toFloat
                                |> Maybe.map Mass.grams
                        )
            , Attr.min "0"
            , Attr.disabled disabled
            ]
            []
        , span [ class "input-group-text", title "grammes" ]
            [ text "g"
            ]
        ]
