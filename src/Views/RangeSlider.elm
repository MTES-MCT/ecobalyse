module Views.RangeSlider exposing
    ( percent
    , quality
    , reparability
    , surfaceMass
    , yarnSize
    )

import Data.Split as Split exposing (Split)
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


type alias PercentConfig msg =
    { id : String
    , update : Maybe Split -> msg
    , value : Split
    , toString : Split -> String
    , disabled : Bool
    , min : Int
    , max : Int
    }


percent : PercentConfig msg -> Html msg
percent config =
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toInt >> Maybe.andThen (Split.fromPercent >> Result.toMaybe) >> config.update)
            , Attr.min (String.fromInt config.min)
            , Attr.max (String.fromInt config.max)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "1"
            , value (String.fromInt (Split.toPercent config.value))
            , Attr.disabled config.disabled
            ]
        }


type alias SurfaceMassConfig msg =
    { id : String
    , update : Maybe Unit.SurfaceMass -> msg
    , value : Unit.SurfaceMass
    , toString : Unit.SurfaceMass -> String
    , disabled : Bool
    }


surfaceMass : SurfaceMassConfig msg -> Html msg
surfaceMass config =
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toInt >> Maybe.map Unit.gramsPerSquareMeter >> config.update)
            , Attr.min (String.fromInt (Unit.surfaceMassInGramsPerSquareMeters Unit.minSurfaceMass))
            , Attr.max (String.fromInt (Unit.surfaceMassInGramsPerSquareMeters Unit.maxSurfaceMass))
            , step "1"

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , value (String.fromInt (Unit.surfaceMassInGramsPerSquareMeters config.value))
            , Attr.disabled config.disabled
            ]
        }


type alias YarnSizeConfig msg =
    { id : String
    , update : Maybe Unit.YarnSize -> msg
    , value : Unit.YarnSize
    , toString : Unit.YarnSize -> String
    , disabled : Bool
    }


yarnSize : YarnSizeConfig msg -> Html msg
yarnSize config =
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toInt >> Maybe.map Unit.kilometersPerKg >> config.update)
            , Attr.min (String.fromInt (Unit.yarnSizeInKilometers Unit.minYarnSize))
            , Attr.max (String.fromInt (Unit.yarnSizeInKilometers Unit.maxYarnSize))

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "1"
            , value (String.fromInt (Unit.yarnSizeInKilometers config.value))
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
