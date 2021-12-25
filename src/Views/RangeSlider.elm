module Views.RangeSlider exposing (..)

import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { id : String
    , update : Maybe Unit.Ratio -> msg
    , value : Unit.Ratio
    , toString : Unit.Ratio -> String
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
