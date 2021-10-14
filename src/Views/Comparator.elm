module Views.Comparator exposing (..)

import Data.Country exposing (..)
import Data.Material as Material
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


view : Simulator -> Html msg
view { inputs, co2 } =
    let
        good =
            Simulator.compute
                { inputs
                    | countries = [ China, France, France, France, France ]
                    , dyeingWeighting = Just 0
                    , airTransportRatio = Just 0
                }

        middle =
            Simulator.compute
                { inputs
                    | countries = [ China, Turkey, Turkey, Turkey, France ]
                    , dyeingWeighting = Just 0.5
                    , airTransportRatio = Just 0
                }

        bad =
            Simulator.compute
                { inputs
                    | countries = [ China, India, India, India, France ]
                    , dyeingWeighting = Just 1
                    , airTransportRatio = Just 1
                }

        scale =
            bad.co2 - good.co2

        point =
            co2 - good.co2

        p =
            point / scale * 100
    in
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ text <| "Comparaison pour " ++ inputs.product.name ++ " en " ++ Material.shortName inputs.material ++ " de "
            , Format.kg inputs.mass
            ]
        , div [ class "card-body" ]
            [ div [ class "progress" ]
                [ div
                    [ class "progress-bar progress-bar-animated"
                    , style "background-color" (pColor p)
                    , style "filter" "brightness(0.9)"
                    , style "filter" "saturate(1)"
                    , style "width" <| String.fromFloat p ++ "%"
                    ]
                    []
                ]
            , div [ class "d-flex justify-content-between fs-7" ]
                [ span [ class "text-center" ]
                    [ text "Circuit France"
                    , br [] []
                    , Format.kgCo2 2 good.co2
                    ]
                , span [ class "text-center" ]
                    [ text "Circuit Turquie moyen"
                    , br [] []
                    , Format.kgCo2 2 middle.co2
                    ]
                , span [ class "text-center" ]
                    [ text "Circuit Inde majorant"
                    , br [] []
                    , Format.kgCo2 2 bad.co2
                    ]
                ]
            ]
        ]


pColor : Float -> String
pColor p =
    List.take (ceiling (p / 5)) greenToRed
        |> List.reverse
        |> List.head
        |> Maybe.withDefault "ff0000"


greenToRed : List String
greenToRed =
    [ "#57bb8a"
    , "#63b682"
    , "#73b87e"
    , "#84bb7b"
    , "#94bd77"
    , "#a4c073"
    , "#b0be6e"
    , "#c4c56d"
    , "#d4c86a"
    , "#e2c965"
    , "#f5ce62"
    , "#f3c563"
    , "#e9b861"
    , "#e6ad61"
    , "#ecac67"
    , "#e9a268"
    , "#e79a69"
    , "#e5926b"
    , "#e2886c"
    , "#e0816d"
    , "#dd776e"
    ]
