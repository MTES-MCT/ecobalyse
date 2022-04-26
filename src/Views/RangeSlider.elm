module Views.RangeSlider exposing
    ( picking
    , quality
    , ratio
    , reparability
    , surfaceDensity
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
        , attributes =
            [ onInput (String.toFloat >> Maybe.map Unit.quality >> config.update)
            , Attr.min (fromFloat Unit.minQuality)
            , Attr.max (fromFloat Unit.maxQuality)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "0.01"
            , value (fromFloat config.value)
            , Attr.disabled config.disabled
            ]
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
        , attributes =
            [ onInput (String.toFloat >> Maybe.map Unit.reparability >> config.update)
            , Attr.min (fromFloat Unit.minReparability)
            , Attr.max (fromFloat Unit.maxReparability)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "0.01"
            , value (fromFloat config.value)
            , Attr.disabled config.disabled
            ]
        }


type alias RatioConfig msg =
    { id : String
    , update : Maybe Unit.Ratio -> msg
    , value : Unit.Ratio
    , toString : Unit.Ratio -> String
    , disabled : Bool
    , min : Int
    , max : Int
    }


ratio : RatioConfig msg -> Html msg
ratio config =
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toInt >> Maybe.map (\x -> Unit.ratio (toFloat x / 100)) >> config.update)
            , Attr.min (String.fromInt config.min)
            , Attr.max (String.fromInt config.max)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "1"
            , value (String.fromInt (round (Unit.ratioToFloat config.value * 100)))
            , Attr.disabled config.disabled
            ]
        }


type alias PickingConfig msg =
    { id : String
    , update : Maybe Unit.PickPerMeter -> msg
    , value : Unit.PickPerMeter
    , toString : Unit.PickPerMeter -> String
    , disabled : Bool
    }


picking : PickingConfig msg -> Html msg
picking config =
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toInt >> Maybe.map Unit.pickPerMeter >> config.update)
            , Attr.min (String.fromInt (Unit.pickPerMeterToInt Unit.minPickPerMeter))
            , Attr.max (String.fromInt (Unit.pickPerMeterToInt Unit.maxPickPerMeter))

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "1"
            , value (String.fromInt (Unit.pickPerMeterToInt config.value))
            , Attr.disabled config.disabled
            ]
        }


type alias SurfaceDensityConfig msg =
    { id : String
    , update : Maybe Unit.SurfaceDensity -> msg
    , value : Unit.SurfaceDensity
    , toString : Unit.SurfaceDensity -> String
    , disabled : Bool
    }


surfaceDensity : SurfaceDensityConfig msg -> Html msg
surfaceDensity config =
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toInt >> Maybe.map Unit.surfaceDensity >> config.update)
            , Attr.min (String.fromInt (Unit.surfaceDensityToInt Unit.minSurfaceDensity))
            , Attr.max (String.fromInt (Unit.surfaceDensityToInt Unit.maxSurfaceDensity))
            , step "1"

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , value (String.fromInt (Unit.surfaceDensityToInt config.value))
            , Attr.disabled config.disabled
            ]
        }


layout : { id : String, label : String, attributes : List (Attribute msg) } -> Html msg
layout { id, label, attributes } =
    div [ class "RangeSlider row" ]
        [ div [ class "col-xxl-6" ]
            [ Html.label [ for id, class "form-label text-nowrap fs-7 mb-0" ]
                [ text label ]
            ]
        , div [ class "col-xxl-6" ]
            [ input
                (type_ "range"
                    :: class "d-block form-range"
                    :: style "margin-top" "2px"
                    :: Attr.id id
                    :: attributes
                )
                []
            ]
        ]
