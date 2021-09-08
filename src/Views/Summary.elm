module Views.Summary exposing (..)

import Data.LifeCycle as LifeCycle
import Data.Material as Material
import Data.Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Chart as Chart
import Views.Format as Format
import Views.Transport as Transport


view : Simulator -> Html msg
view simulator =
    div [ class "mb-3" ]
        [ div [ class "card mb-3" ]
            [ div [ class "card-header text-white bg-primary" ]
                [ strong [] [ text simulator.product.name ]
                , text " en "
                , em [] [ text <| Material.shortName simulator.material ]
                , text " de "
                , strong [] [ Format.kg simulator.mass ]
                ]
            , div [ class "card-body text-white bg-primary" ]
                [ div [ class "d-flex justify-content-center align-items-center mb-3" ]
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
                    |> LifeCycle.computeTransportSummary
                    |> Transport.view False
                ]
            , div [ class "card-body" ]
                [ Chart.view simulator
                ]
            ]
        ]
