module Views.Impact exposing (selector, viewDefinition)

import Data.Impact as Impact
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Icon as Icon
import Views.Markdown as Markdown


viewDefinition : Impact.Definition -> Html msg
viewDefinition { label, description } =
    div [ class "ImpactDefinition d-none d-sm-block card shadow-sm text-dark bg-light px-2 py-1 mb-3" ]
        [ h2 [ class "fs-6 text-muted fw-bold my-1" ]
            [ span [ class "me-1" ] [ Icon.info ]
            , text "Impact étudié\u{00A0}: "
            , text label
            ]
        , div [ class "text-muted fs-7" ]
            [ Markdown.simple [ class "mb-1" ] description ]
        ]


type alias SelectorConfig msg =
    { impacts : List Impact.Definition
    , selected : Impact.Trigram
    , switch : Impact.Trigram -> msg
    }


selector : SelectorConfig msg -> Html msg
selector { impacts, selected, switch } =
    let
        toOption ({ trigram, label } as impact) =
            option
                [ Attr.selected (selected == impact.trigram)
                , value <| Impact.toString trigram
                ]
                [ text label ]
    in
    select
        [ class "form-select"
        , onInput (Impact.trg >> switch)
        ]
        [ impacts
            |> List.filter (\{ trigram } -> trigram == Impact.trg "pef")
            |> List.map toOption
            |> optgroup [ attribute "label" "Impacts agrégés" ]
        , impacts
            |> List.filter (\{ trigram } -> trigram /= Impact.trg "pef")
            |> List.sortBy .label
            |> List.map toOption
            |> optgroup [ attribute "label" "Impacts détaillés" ]
        ]
