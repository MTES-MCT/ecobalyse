module Views.Impact exposing (selector)

import Data.Impact.Definition as Definition exposing (Definitions)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias SelectorConfig msg =
    { selectedImpact : Definition.Trigram
    , switchImpact : Result String Definition.Trigram -> msg
    }


selector : Definitions -> SelectorConfig msg -> Html msg
selector definitions { selectedImpact, switchImpact } =
    let
        toOption ({ trigram, label } as impact) =
            option
                [ Attr.selected (selectedImpact == impact.trigram)
                , value <| Definition.toString trigram
                ]
                [ text label ]
    in
    div [ class "ImpactSelector input-group", attribute "data-testid" "impact-selector" ]
        [ select
            [ class "form-select"
            , onInput (Definition.toTrigram >> switchImpact)
            ]
            [ Definition.toList definitions
                |> List.filter (.trigram >> Definition.isAggregate)
                |> List.map toOption
                |> optgroup [ attribute "label" "Impacts agrégés" ]
            , Definition.toList definitions
                |> List.filter (.trigram >> Definition.isAggregate >> not)
                |> List.sortBy .label
                |> List.map toOption
                |> optgroup [ attribute "label" "Impacts détaillés" ]
            ]
        ]
