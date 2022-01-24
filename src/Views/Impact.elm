module Views.Impact exposing (selector, viewDefinition)

import Data.Impact as Impact
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Icon as Icon
import Views.Markdown as Markdown


qualityDocumentationUrl : String
qualityDocumentationUrl =
    "https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/impacts-consideres#niveaux-de-recommandation"


viewDefinition : Impact.Definition -> Html msg
viewDefinition { label, description, quality } =
    div [ class "ImpactDefinition d-none d-sm-block card shadow-sm text-dark bg-light px-2 py-1 mb-3" ]
        [ div [ class "row" ]
            [ div [ class "col-9" ]
                [ h2 [ class "fs-6 text-muted fw-bold my-1" ]
                    [ span [ class "me-1" ] [ Icon.info ]
                    , text "Impact étudié\u{00A0}: "
                    , text label
                    ]
                ]
            , quality
                |> impactQuality
                |> div [ class "col-3 text-end" ]
            ]
        , div [ class "text-muted fs-7" ]
            [ Markdown.simple [ class "mb-1" ] description ]
        ]


impactQuality : Impact.Quality -> List (Html msg)
impactQuality quality =
    let
        maybeInfo =
            case quality of
                Impact.GoodQuality ->
                    Just ( "success", "I", "Qualité satisfaisante" )

                Impact.AverageQuality ->
                    Just ( "info", "II", "Qualité satisfaisante mais nécessitant des améliorations" )

                Impact.BadQuality ->
                    Just ( "warning text-dark", "III", "Donnée incomplète à utiliser avec prudence" )

                Impact.UnknownQuality ->
                    Nothing
    in
    case maybeInfo of
        Just ( level, label, description ) ->
            [ a
                [ class <| "badge rounded-pill text-white bg-" ++ level ++ " text-decoration-none"
                , target "_blank"
                , href qualityDocumentationUrl
                , title description
                ]
                [ text "Qualité\u{00A0}: "
                , text label
                ]
            ]

        Nothing ->
            []


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
