module Page.Textile.Explore.Impacts exposing (table)

import Data.Impact as Impact exposing (Definition)
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
    , { label = "Unité"
      , toCell = \def -> code [] [ text def.unit ]
      }
    , { label = "Normalisation PEF"
      , toCell =
            \def ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ def.pefData
                        |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                        |> Maybe.withDefault (text "N/A")
                    ]
      }
    , { label = "Pondération PEF"
      , toCell =
            \def ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ def.pefData
                        |> Maybe.map (.weighting >> Format.ratio)
                        |> Maybe.withDefault (text "N/A")
                    ]
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
                                [ ( "bg-success", scope == Impact.Food )
                                , ( "bg-info", scope == Impact.Textile )
                                ]
                            ]
                            [ text <| Impact.scopeToString scope ]
                    )
                >> div [ class "d-flex gap-1" ]
      }
    ]
