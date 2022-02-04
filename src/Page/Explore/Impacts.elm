module Page.Explore.Impacts exposing (table)

import Data.Db as Db
import Data.Impact as Impact exposing (Definition)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format
import Views.Impact as ImpactView
import Views.Markdown as Markdown


table : { detailed : Bool } -> Table Definition msg
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \def ->
                if detailed then
                    code [] [ text (Impact.toString def.trigram) ]

                else
                    a [ Route.href (Route.Explore (Db.Impacts (Just def.trigram))) ]
                        [ code [] [ text (Impact.toString def.trigram) ] ]
      }
    , { label = "Nom"
      , toCell = \def -> text def.label
      }
    , { label = "Description"
      , toCell =
            \def ->
                if detailed then
                    def.description |> Markdown.simple []

                else
                    def.description
                        |> String.replace "*" ""
                        |> text
      }
    , { label = "Unité"
      , toCell = \def -> td [] [ code [] [ text def.unit ] ]
      }
    , { label = "Coéf. normalisation PEF"
      , toCell =
            \def ->
                def.pefData
                    |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                    |> Maybe.withDefault (text "N/A")
      }
    , { label = "Pondération PEF"
      , toCell =
            \def ->
                def.pefData
                    |> Maybe.map (.weighting >> Format.ratio)
                    |> Maybe.withDefault (text "N/A")
      }
    , { label = "Niveau de qualité"
      , toCell = \def -> ImpactView.impactQuality def.quality |> div []
      }
    ]
