module Views.RangeSlider exposing
    ( generic
    , percent
    , physicalDurability
    , surfaceMass
    , yarnSize
    )

import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config unit msg =
    { disabled : Bool
    , fromString : String -> Result String unit
    , max : unit
    , min : unit
    , step : String
    , toString : unit -> String
    , update : Result String unit -> msg
    , value : unit
    }


generic : List (Attribute msg) -> Config unit msg -> Html msg
generic attrs config =
    rangeInput
        (attrs
            ++ [ onInput (config.fromString >> config.update)
               , Attr.min (config.toString config.min)
               , Attr.max (config.toString config.max)

               -- WARNING: be careful when reordering attributes: for obscure reasons,
               -- the `value` one MUST be set AFTER the `step` one.
               , step config.step
               , value <| config.toString config.value
               , Attr.disabled config.disabled
               ]
        )


type alias PercentConfig msg =
    { disabled : Bool
    , id : String
    , max : Int
    , min : Int
    , toString : Split -> String
    , update : Maybe Split -> msg
    , value : Split
    }


percent : PercentConfig msg -> Html msg
percent config =
    narrowLayout
        { attributes =
            [ onInput (String.toFloat >> Maybe.andThen (Split.fromPercent >> Result.toMaybe) >> config.update)
            , Attr.min (String.fromInt config.min)
            , Attr.max (String.fromInt config.max)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "1"
            , value (String.fromFloat (Split.toPercent config.value))
            , Attr.disabled config.disabled
            ]
        , id = config.id
        , label = config.toString config.value
        }


type alias SurfaceMassConfig msg =
    { disabled : Bool
    , id : String
    , toString : Unit.SurfaceMass -> String
    , update : Maybe Unit.SurfaceMass -> msg
    , value : Unit.SurfaceMass
    }


surfaceMass : SurfaceMassConfig msg -> Html msg
surfaceMass config =
    narrowLayout
        { attributes =
            [ onInput (String.toInt >> Maybe.map Unit.gramsPerSquareMeter >> config.update)
            , Attr.min (String.fromInt (Unit.surfaceMassInGramsPerSquareMeters Unit.minSurfaceMass))
            , Attr.max (String.fromInt (Unit.surfaceMassInGramsPerSquareMeters Unit.maxSurfaceMass))
            , step "1"

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , value (String.fromInt (Unit.surfaceMassInGramsPerSquareMeters config.value))
            , Attr.disabled config.disabled
            ]
        , id = config.id
        , label = config.toString config.value
        }


type alias YarnSizeConfig msg =
    { disabled : Bool
    , id : String
    , toString : Unit.YarnSize -> String
    , update : Maybe Unit.YarnSize -> msg
    , value : Unit.YarnSize
    }


yarnSize : YarnSizeConfig msg -> Html msg
yarnSize config =
    narrowLayout
        { attributes =
            [ onInput (String.toFloat >> Maybe.map Unit.yarnSizeKilometersPerKg >> config.update)
            , Attr.min (String.fromFloat (Unit.yarnSizeInKilometers Unit.minYarnSize))
            , Attr.max (String.fromFloat (Unit.yarnSizeInKilometers Unit.maxYarnSize))

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "1"
            , value (String.fromFloat (Unit.yarnSizeInKilometers config.value))
            , Attr.disabled config.disabled
            ]
        , id = config.id
        , label = config.toString config.value
        }


type alias PhysicalDurabilityConfig msg =
    { disabled : Bool
    , id : String
    , toString : Unit.PhysicalDurability -> String
    , update : Maybe Unit.PhysicalDurability -> msg
    , value : Unit.PhysicalDurability
    }


physicalDurability : PhysicalDurabilityConfig msg -> Html msg
physicalDurability config =
    wideLayout
        { attributes =
            [ onInput (String.toFloat >> Maybe.map Unit.physicalDurability >> config.update)
            , Attr.min (String.fromFloat (Unit.physicalDurabilityToFloat (Unit.minDurability Unit.PhysicalDurability)))
            , Attr.max (String.fromFloat (Unit.physicalDurabilityToFloat (Unit.maxDurability Unit.PhysicalDurability)))

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "0.01"
            , value (String.fromFloat (Unit.physicalDurabilityToFloat config.value))
            , Attr.disabled config.disabled
            ]
        , id = config.id
        , label = config.toString config.value
        }


narrowLayout : { attributes : List (Attribute msg), id : String, label : String } -> Html msg
narrowLayout { attributes, id, label } =
    div [ class "RangeSlider row" ]
        [ div [ class "col-xxl-6" ]
            [ Html.label [ for id, class "form-label text-nowrap fs-7 mb-0" ]
                [ text label ]
            ]
        , div [ class "col-xxl-6" ]
            [ rangeInput (Attr.id id :: style "margin-top" "2px" :: attributes) ]
        ]


wideLayout : { attributes : List (Attribute msg), id : String, label : String } -> Html msg
wideLayout { attributes, id, label } =
    div [ class "RangeSlider row", style "flex-grow" "1" ]
        [ div [ class "col-xxl-2" ]
            [ Html.label [ for id, class "form-label text-nowrap mb-0" ]
                [ text label ]
            ]
        , div [ class "col-xxl-10" ]
            [ rangeInput (Attr.id id :: style "margin-top" "2px" :: attributes) ]
        ]


rangeInput : List (Attribute msg) -> Html msg
rangeInput attributes =
    input (type_ "range" :: class "form-range" :: attributes) []
