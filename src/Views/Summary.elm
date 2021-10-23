module Views.Summary exposing (..)

import Data.Inputs as Inputs
import Data.LifeCycle as LifeCycle
import Data.Material as Material
import Data.Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route(..))
import Views.BarChart as Chart
import Views.Format as Format
import Views.Transport as TransportView


summaryView : Bool -> Simulator -> Html msg
summaryView reusable simulator =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header text-white bg-primary d-flex justify-content-between" ]
            [ span [ class "text-nowrap" ] [ strong [] [ text simulator.inputs.product.name ] ]
            , span
                [ class "text-truncate", title simulator.inputs.material.name ]
                [ text <| "\u{00A0}" ++ Material.shortName simulator.inputs.material ++ "\u{00A0}" ]
            , span [ class "text-nowrap" ] [ strong [] [ Format.kg simulator.inputs.mass ] ]
            ]
        , div [ class "card-body px-1 d-grid gap-3 text-white bg-primary" ]
            [ div [ class "d-flex justify-content-center align-items-center" ]
                [ img
                    [ src <| "img/product/" ++ simulator.inputs.product.name ++ ".svg"
                    , alt <| simulator.inputs.product.name
                    , class "invert me-2"
                    , style "width" "3em"
                    , style "height" "3em"
                    ]
                    []
                , div [ class "display-5" ]
                    [ Format.kgCo2 2 simulator.co2 ]
                ]
            , simulator.inputs.countries
                |> List.map (\{ name } -> li [] [ span [] [ text name ] ])
                |> ul [ class "Chevrons" ]
            , simulator.lifeCycle
                |> LifeCycle.computeTransportSummary
                |> TransportView.view False
            ]
        , div [ class "d-none d-sm-block card-body px-2" ]
            -- TODO: render an horiz stacked barchart for smaller viewports?
            [ Chart.view simulator
            ]
        , if reusable then
            div [ class "card-footer text-center" ]
                [ a
                    [ class "btn btn-primary"
                    , Route.href (Route.Simulator (simulator.inputs |> Inputs.toQuery |> Just))
                    ]
                    [ text "Reprendre cette simulation" ]
                ]

          else
            text ""
        ]


view : Bool -> Result String Simulator -> Html msg
view reusable result =
    case result of
        Ok simulator ->
            summaryView reusable simulator

        Err error ->
            text <| "Error: " ++ error
