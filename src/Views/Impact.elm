module Views.Impact exposing
    ( impactQuality
    , selector
    )

import Data.Gitbook as Gitbook
import Data.Impact.Definition as Definition exposing (Definitions)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Button as Button
import Views.Icon as Icon


qualityDocumentationUrl : String
qualityDocumentationUrl =
    Gitbook.publicUrlFromPath Gitbook.ImpactQuality


impactQuality : Definition.Quality -> List (Html msg)
impactQuality quality =
    let
        maybeInfo =
            case quality of
                Definition.NotFinished ->
                    Just
                        { cls = "btn-danger"
                        , icon = Icon.build
                        , label = "N/A"
                        , help = "Impact en cours de construction"
                        }

                Definition.GoodQuality ->
                    Just
                        { cls = "btn-success"
                        , icon = Icon.checkCircle
                        , label = "I"
                        , help = "Qualité satisfaisante"
                        }

                Definition.AverageQuality ->
                    Just
                        { cls = "bg-info text-white"
                        , icon = Icon.info
                        , label = "II"
                        , help = "Qualité satisfaisante mais nécessitant des améliorations"
                        }

                Definition.BadQuality ->
                    Just
                        { cls = "btn-warning"
                        , icon = Icon.warning
                        , label = "III"
                        , help = "Donnée incomplète à utiliser avec prudence"
                        }

                Definition.UnknownQuality ->
                    Nothing
    in
    case maybeInfo of
        Just { cls, icon, label, help } ->
            [ a
                [ class <| Button.pillClasses ++ " fs-7 py-0 " ++ cls
                , target "_blank"
                , href qualityDocumentationUrl
                , title help
                ]
                [ icon
                , text "Qualité\u{00A0}: "
                , strong [] [ text label ]
                ]
            ]

        Nothing ->
            []


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
    div [ class "ImpactSelector input-group" ]
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
