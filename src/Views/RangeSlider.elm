module Views.RangeSlider exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { id : String
    , update : Maybe Float -> msg
    , value : Float
    , toString : Float -> String
    , disabled : Bool
    }


view : Config msg -> Html msg
view config =
    div [ class "RangeSlider row" ]
        [ div [ class "col-xxl-6" ]
            [ label [ for config.id, class "form-label text-nowrap fs-7 mb-0" ]
                [ text <| config.toString config.value ]
            ]
        , div [ class "col-xxl-6" ]
            [ input
                [ type_ "range"
                , class "d-block form-range"
                , style "margin-top" "2px"
                , id config.id
                , onInput (String.toInt >> Maybe.map (\x -> toFloat x / 100) >> config.update)
                , value (String.fromInt (round (config.value * 100)))
                , Attr.min "0"
                , Attr.max "100"
                , step "1"
                , Attr.disabled config.disabled
                ]
                []
            ]
        ]
