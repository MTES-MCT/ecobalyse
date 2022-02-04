module Page.Explore.Impacts exposing (details, view)

import Data.Db as Db exposing (Db)
import Data.Impact as Impact exposing (Definition)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Impact as ImpactView
import Views.Markdown as Markdown
import Views.Table as Table


table : { detailed : Bool } -> List { label : String, toCell : Definition -> Html msg }
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \def ->
                td []
                    [ if detailed then
                        code [] [ text (Impact.toString def.trigram) ]

                      else
                        a [ Route.href (Route.Explore (Db.Impacts (Just def.trigram))) ]
                            [ code [] [ text (Impact.toString def.trigram) ] ]
                    ]
      }
    , { label = "Nom"
      , toCell = \def -> td [] [ text def.label ]
      }
    , { label = "Description"
      , toCell =
            \def ->
                td []
                    [ if detailed then
                        def.description |> Markdown.simple []

                      else
                        def.description
                            |> String.replace "*" ""
                            |> text
                    ]
      }
    , { label = "Unité"
      , toCell = \def -> td [] [ code [] [ text def.unit ] ]
      }
    , { label = "Coéf. normalisation PEF"
      , toCell =
            \def ->
                td []
                    [ def.pefData
                        |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                        |> Maybe.withDefault (text "N/A")
                    ]
      }
    , { label = "Pondération PEF"
      , toCell =
            \def ->
                td []
                    [ def.pefData
                        |> Maybe.map (.weighting >> Format.ratio)
                        |> Maybe.withDefault (text "N/A")
                    ]
      }
    , { label = "Niveau de qualité"
      , toCell = \def -> ImpactView.impactQuality def.quality |> td []
      }
    ]


details : Db -> Definition -> Html msg
details _ def =
    Table.responsiveDefault [ class "view-details" ]
        [ table { detailed = True }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , toCell def
                        ]
                )
            |> tbody []
        ]


view : List Definition -> Html msg
view definitions =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ table { detailed = False }
                |> List.map (\{ label } -> th [] [ text label ])
                |> tr []
            ]
        , definitions
            |> List.map
                (\def ->
                    table { detailed = False }
                        |> List.map (\{ toCell } -> toCell def)
                        |> tr []
                )
            |> tbody []
        ]
