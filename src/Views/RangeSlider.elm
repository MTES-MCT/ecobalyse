module Views.RangeSlider exposing
    ( quality
    , ratio
    , reparability
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
    layout
        { id = config.id
        , label = config.toString config.value
        , field =
            input
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
        }


type alias ReparabilityConfig msg =
    { id : String
    , update : Maybe Unit.Reparability -> msg
    , value : Unit.Reparability
    , toString : Unit.Reparability -> String
    , disabled : Bool
    }


reparability : ReparabilityConfig msg -> Html msg
reparability config =
    let
        fromFloat =
            Unit.reparabilityToFloat >> String.fromFloat
    in
    layout
        { id = config.id
        , label = config.toString config.value
        , field =
            input
                [ type_ "range"
                , class "d-block form-range"
                , style "margin-top" "2px"
                , id config.id
                , onInput (String.toFloat >> Maybe.map Unit.reparability >> config.update)
                , Attr.min (fromFloat Unit.minReparability)
                , Attr.max (fromFloat Unit.maxReparability)

                -- WARNING: be careful when reordering attributes: for obscure reasons,
                -- the `value` one MUST be set AFTER the `step` one.
                , step "0.01"
                , value (fromFloat config.value)
                , Attr.disabled config.disabled
                ]
                []
        }


type alias RatioConfig msg =
    { id : String
    , update : Maybe Unit.Ratio -> msg
    , value : Unit.Ratio
    , toString : Unit.Ratio -> String
    , disabled : Bool
    }


ratio : RatioConfig msg -> Html msg
ratio config =
    layout
        { id = config.id
        , label = config.toString config.value
        , field =
            input
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
        }


layout : { id : String, label : String, field : Html msg } -> Html msg
layout { id, label, field } =
    div [ class "RangeSlider row" ]
        [ div [ class "col-xxl-6" ]
            [ Html.label [ for id, class "form-label text-nowrap fs-7 mb-0" ]
                [ text label ]
            ]
        , div [ class "col-xxl-6" ]
            [ field
            ]
        ]
