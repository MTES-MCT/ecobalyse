module Page.Explore.Impacts exposing (table)

import Data.Dataset as Dataset
import Data.Impact as Impact exposing (Definition)
import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format
import Views.Impact as ImpactView
import Views.Markdown as Markdown


table : { detailed : Bool, scope : Scope } -> Table Definition String msg
table { detailed, scope } =
    { label = "Code"
    , toValue = .trigram >> Impact.toString
    , toCell =
        \def ->
            if detailed then
                code [] [ text (Impact.toString def.trigram) ]

            else
                a [ Route.href (Route.Explore scope (Dataset.Impacts (Just def.trigram))) ]
                    [ code [] [ text (Impact.toString def.trigram) ] ]
    }
        :: { label = "Nom"
           , toValue = .label
           , toCell =
                \def ->
                    span [ title def.label ] [ text def.label ]
           }
        :: { label = "Unité"
           , toValue = .unit
           , toCell = \def -> code [] [ text def.unit ]
           }
        :: { label = "Données de calcul du score PEF"
           , toValue =
                \def ->
                    def.pefData
                        |> Maybe.map
                            (\data ->
                                let
                                    normalization =
                                        data.normalization
                                            |> Unit.impactToFloat
                                            |> Format.formatFloat 2

                                    weighting =
                                        data.weighting
                                            |> Unit.ratioToFloat
                                            |> Format.formatFloat 2
                                in
                                normalization ++ "/" ++ weighting
                            )
                        |> Maybe.withDefault "N/A"
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
        :: (if scope == Scope.Food then
                -- No "scope d'impacts" for textile
                [ { label = "Données de calcul du score d'impacts"
                  , toValue =
                        \def ->
                            def.ecoscoreData
                                |> Maybe.map
                                    (\data ->
                                        let
                                            normalization =
                                                data.normalization
                                                    |> Unit.impactToFloat
                                                    |> Format.formatFloat 2

                                            weighting =
                                                data.weighting
                                                    |> Unit.ratioToFloat
                                                    |> Format.formatFloat 2
                                        in
                                        normalization ++ "/" ++ weighting
                                    )
                                |> Maybe.withDefault "N/A"
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
                ]

            else
                []
           )
        ++ [ { label = "Niveau de qualité"
             , toValue =
                \def ->
                    case def.quality of
                        Impact.NotFinished ->
                            "0"

                        Impact.GoodQuality ->
                            "4"

                        Impact.AverageQuality ->
                            "3"

                        Impact.BadQuality ->
                            "2"

                        Impact.UnknownQuality ->
                            "1"
             , toCell =
                \def ->
                    def.quality
                        |> ImpactView.impactQuality
                        |> div [ classList [ ( "text-center", not detailed ) ] ]
             }
           , { label = "Source"
             , toValue = .source >> .label
             , toCell =
                \def ->
                    a
                        [ href def.source.url
                        , target "_blank"
                        ]
                        [ text def.source.label ]
             }
           , { label = "Domaines"
             , toValue = .scopes >> List.map Scope.toLabel >> String.join "/"
             , toCell = Common.scopesView
             }
           , { label = "Description"
             , toValue = .description
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
