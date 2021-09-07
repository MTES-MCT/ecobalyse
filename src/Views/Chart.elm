module Views.Chart exposing (..)

import Array
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


type alias Bar =
    { label : String
    , co2 : Float
    , percent : Float
    }


makeBars : Simulator -> List Bar
makeBars simulator =
    simulator.lifeCycle
        |> Array.toList
        |> List.filter (\{ label } -> label /= Step.Distribution)
        |> List.map
            (\step ->
                { label = Step.labelToString step.label
                , co2 = step.co2
                , percent = step.co2 / simulator.co2 * toFloat 100
                }
            )
        |> (::)
            { label = "Transport total"
            , co2 = simulator.transport.co2
            , percent = simulator.transport.co2 / simulator.co2 * toFloat 100
            }


barView : Bar -> Html msg
barView bar =
    tr [ class "fs-7" ]
        [ th [ class "text-end text-truncate py-1 pe-2" ] [ text bar.label ]
        , td [ class "d-none d-sm-block text-center py-1 ps-2 pe-3 text-truncate" ]
            [ bar.co2 |> Format.formatFloat "kg eq, CO₂" |> text ]
        , td [ class "w-100 py-1" ]
            [ div
                [ class "bg-primary"
                , style "height" "1rem"
                , style "line-height" "1rem"
                , style "width" (String.fromFloat bar.percent ++ "%")
                ]
                []
            ]
        , td [ class "d-none d-sm-block text-center py-1 ps-2 pe-3 text-truncate" ]
            [ bar.percent |> Format.formatFloat "%" |> text ]
        ]


view : Simulator -> Html msg
view simulator =
    div [ class "card mb-3" ]
        [ div [ class "card-body py-2" ]
            [ table [ class "mb-0" ]
                [ makeBars simulator
                    |> List.map barView
                    |> tbody []
                ]
            ]
        ]
