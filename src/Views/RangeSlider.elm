module Views.RangeSlider exposing
    ( durability
    , durability2
    , percent
    , reparability
    , surfaceMass
    , yarnSize
    )

import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Format as Format


type alias DurabilityConfig msg =
    { id : String
    , update : Maybe Unit.Durability -> msg
    , value : Unit.Durability
    , toString : Unit.Durability -> String
    , disabled : Bool
    }


durability : DurabilityConfig msg -> Html msg
durability config =
    let
        fromFloat =
            Unit.durabilityToFloat >> String.fromFloat
    in
    layout
        { id = config.id
        , label = config.toString config.value
        , attributes =
            [ onInput (String.toFloat >> Maybe.map Unit.durability >> config.update)
            , Attr.min (fromFloat Unit.minDurability)
            , Attr.max (fromFloat Unit.maxDurability)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "0.01"
            , value (fromFloat config.value)
            , Attr.disabled config.disabled
            ]
        }


durability2 : Html msg
durability2 =
    let
        fromFloat dur =
            dur |> Unit.durabilityToFloat |> String.fromFloat
    in
    div []
        [ label
            [ for "durability-field"
            , class "form-label fw-bold text-truncate"
            ]
            [ text "Durabilité" ]
        , div [ class "d-flex justify-content-between gap-3 mt-2" ]
            [ input
                [ type_ "range"
                , class "d-block form-range"

                --onInput (String.toFloat >> Maybe.map Unit.durability >> config.update)
                , Attr.min (fromFloat Unit.minDurability)
                , Attr.max (fromFloat Unit.maxDurability)

                -- WARNING: be careful when reordering attributes: for obscure reasons,
                -- the `value` one MUST be set AFTER the `step` one.
                , step "0.01"
                , value (fromFloat (Unit.durability 1))
                ]
                []
            , span [ class "text-muted" ] [ text <| Format.formatFloat 2 (Unit.durabilityToFloat (Unit.durability 1)) ]
            ]
        ]


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
            [ onInput (String.toInt >> Maybe.map Unit.yarnSizeKilometersPerKg >> config.update)
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
