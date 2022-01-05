module Views.Impact exposing (..)

import Data.Impact as Impact
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { impacts : List Impact.Definition
    , selected : Impact.Trigram
    , switch : Impact.Trigram -> msg
    }


selector : Config msg -> Html msg
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
