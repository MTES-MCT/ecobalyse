module Views.RangeSlider exposing (int, ratio)

import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias IntConfig msg =
    { id : String
    , min : Int
    , max : Int
    , step : Int
    , update : Maybe Int -> msg
    , value : Int
    , toString : Int -> String
    , disabled : Bool
    }


int : IntConfig msg -> Html msg
int config =
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
                , onInput (String.toInt >> config.update)
                , value (String.fromInt config.value)
                , Attr.min (String.fromInt config.min)
                , Attr.max (String.fromInt config.max)
                , step (String.fromInt config.step)
                , Attr.disabled config.disabled
                ]
                []
            ]
        ]


type alias RatioConfig msg =
    { id : String
    , update : Maybe Unit.Ratio -> msg
    , value : Unit.Ratio
    , toString : Unit.Ratio -> String
    , disabled : Bool
    }


ratio : RatioConfig msg -> Html msg
ratio config =
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
                , onInput (String.toInt >> Maybe.map (\x -> Unit.ratio (toFloat x / 100)) >> config.update)
                , value (String.fromInt (round (Unit.ratioToFloat config.value * 100)))
                , Attr.min "0"
                , Attr.max "100"
                , step "1"
                , Attr.disabled config.disabled
                ]
                []
            ]
        ]
