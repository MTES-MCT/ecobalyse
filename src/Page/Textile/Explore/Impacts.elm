module Page.Textile.Explore.Impacts exposing (table)

import Data.Impact as Impact exposing (Definition)
import Data.Scope as Scope
import Data.Textile.Db as Db
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Textile.Explore.Table exposing (Table)
import Route
import Views.Format as Format
import Views.Impact as ImpactView
import Views.Markdown as Markdown


table : { detailed : Bool } -> Table Definition msg
table { detailed } =
    [ { label = "Code"
      , toCell =
            \def ->
                if detailed then
                    code [] [ text (Impact.toString def.trigram) ]

                else
                    a [ Route.href (Route.TextileExplore (Db.Impacts (Just def.trigram))) ]
                        [ code [] [ text (Impact.toString def.trigram) ] ]
      }
    , { label = "Nom"
      , toCell =
            \def ->
                span [ title def.label ] [ text def.label ]
      }
    , { label = "Unité"
      , toCell = \def -> code [] [ text def.unit ]
      }
    , { label = "Données de calcul du score PEF"
      , toCell =
            \def ->
                case def.pefData of
                    Just pefData ->
                        div [ class "d-flex gap-2" ]
                            [ span [ class "d-flex flex-column" ]
                                [ text "Normalisation"
                                , pefData.normalization |> Unit.impactToFloat |> Format.formatRichFloat 2 def.unit
                                ]
                            , span [ class "d-flex flex-column" ]
                                [ text "Pondération"
                                , pefData.weighting |> Format.ratio
                                ]
                            ]

                    Nothing ->
                        text "N/A"
      }
    , { label = "Données de calcul du score d'impacts"
      , toCell =
            \def ->
                case def.ecoscoreData of
                    Just ecoscoreData ->
                        div [ class "d-flex gap-2" ]
                            [ span [ class "d-flex flex-column" ]
                                [ text "Normalisation"
                                , ecoscoreData.normalization |> Unit.impactToFloat |> Format.formatRichFloat 2 def.unit
                                ]
                            , span [ class "d-flex flex-column" ]
                                [ text "Pondération"
                                , ecoscoreData.weighting |> Format.ratio
                                ]
                            ]

                    Nothing ->
                        text "N/A"
      }
    , { label = "Niveau de qualité"
      , toCell =
            \def ->
                def.quality
                    |> ImpactView.impactQuality
                    |> div [ classList [ ( "text-center", not detailed ) ] ]
      }
    , { label = "Source"
      , toCell =
            \def ->
                a
                    [ href def.source.url
                    , target "_blank"
                    ]
                    [ text def.source.label ]
      }
    , { label = "Domaines"
      , toCell =
            .scopes
                >> List.map
                    (\scope ->
                        span
                            [ class "badge"
                            , classList
                                [ ( "bg-success", scope == Scope.Food )
                                , ( "bg-info", scope == Scope.Textile )
                                ]
                            ]
                            [ text <| Scope.toLabel scope ]
                    )
                >> div [ class "d-flex gap-1" ]
      }
    , { label = "Description"
      , toCell =
            \def ->
                if detailed then
                    Markdown.simple [] def.description

                else
                    span [ title def.description ]
                        [ def.description
                            |> String.replace "*" ""
                            |> text
                        ]
      }
    ]
