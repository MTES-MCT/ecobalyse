module Views.RangeSlider exposing
    ( quality
    , ratio
    )

import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias QualityConfig msg =
    { id : String
    , update : Maybe Unit.Quality -> msg
    , value : Unit.Quality
    , toString : Unit.Quality -> String
    , disabled : Bool
    }


quality : QualityConfig msg -> Html msg
quality config =
    let
        fromFloat =
            Unit.qualityToFloat >> String.fromFloat
    in
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
                , onInput (String.toFloat >> Maybe.map Unit.quality >> config.update)
                , Attr.min (fromFloat Unit.minQuality)
                , Attr.max (fromFloat Unit.maxQuality)

                -- WARNING: be careful when reordering attributes: for obscure reasons,
                -- the `value` one MUST be set AFTER the `step` one.
                , step "0.01"
                , value (fromFloat config.value)
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
