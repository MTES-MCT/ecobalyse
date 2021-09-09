module Views.Summary exposing (..)

import Data.LifeCycle as LifeCycle
import Data.Material as Material
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route(..))
import Views.Chart as Chart
import Views.Format as Format
import Views.Transport as TransportView


view : Bool -> Simulator -> Html msg
view reusable simulator =
    div [ class "mb-3" ]
        [ div [ class "card mb-3" ]
            [ div [ class "card-header text-white bg-primary d-flex justify-content-between" ]
                [ span [ class "text-nowrap" ] [ strong [] [ text simulator.product.name ] ]
                , span
                    [ class "text-truncate", title simulator.material.name ]
                    [ text <| "\u{00A0}" ++ Material.shortName simulator.material ++ "\u{00A0}" ]
                , span [ class "text-nowrap" ] [ strong [] [ Format.kg simulator.mass ] ]
                ]
            , div [ class "card-body text-white bg-primary" ]
                [ div [ class "d-flex justify-content-center align-items-center mb-2" ]
                    [ img
                        [ src <| "img/product/" ++ simulator.product.name ++ "-inv.png"
                        , class "mx-2"
                        , style "width" "3em"
                        , style "height" "3em"
                        ]
                        []
                    , div [ class "display-5 text-center" ]
                        [ Format.kgCo2 simulator.co2 ]
                    ]
                , simulator.lifeCycle
                    |> LifeCycle.stepCountryLabels
                    |> List.map (\label -> span [ class "badge bg-light text-primary" ] [ text label ])
                    |> List.intersperse (text " → ")
                    |> div [ class "text-center my-2 mb-3" ]
                , simulator.lifeCycle
                    |> LifeCycle.computeTransportSummary
                    |> TransportView.view False
                ]
            , div [ class "card-body px-2" ]
                [ Chart.view simulator
                ]
            , if reusable then
                div [ class "card-footer text-center" ]
                    [ a
                        [ class "btn btn-primary"
                        , Route.href (Route.Simulator (Just (Simulator.toInputs simulator)))
                        ]
                        [ text "Reprendre cette simulation" ]
                    ]

              else
                text ""
            ]
        ]
