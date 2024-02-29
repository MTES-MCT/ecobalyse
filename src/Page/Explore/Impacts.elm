module Page.Explore.Impacts exposing (table)

import Data.Dataset as Dataset
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Scope exposing (Scope)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Format as Format
import Views.Impact as ImpactView
import Views.Markdown as Markdown


table : { detailed : Bool, scope : Scope } -> Table Definition String msg
table { detailed, scope } =
    { toId = .trigram >> Definition.toString
    , toRoute = .trigram >> Just >> Dataset.Impacts >> Route.Explore scope
    , columns =
        [ { label = "Code"
          , toValue = Table.StringValue <| .trigram >> Definition.toString
          , toCell =
                \def ->
                    if detailed then
                        code [] [ text (Definition.toString def.trigram) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.Impacts (Just def.trigram))) ]
                            [ code [] [ text (Definition.toString def.trigram) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue <| .label
          , toCell =
                \def ->
                    span [ title def.label ] [ text def.label ]
          }
        , { label = "Unité"
          , toValue = Table.StringValue <| .unit
          , toCell = \def -> code [] [ text def.unit ]
          }
        , { label = "Normalisation (PEF)"
          , toValue =
                Table.FloatValue <|
                    .pefData
                        >> Maybe.map (.normalization >> Unit.impactToFloat)
                        >> Maybe.withDefault 0
          , toCell =
                \def ->
                    def.pefData
                        |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                        |> Maybe.withDefault (text "N/A")
          }
        , { label = "Pondération (PEF)"
          , toValue =
                Table.FloatValue <|
                    .pefData
                        >> Maybe.map (.weighting >> Unit.ratioToFloat)
                        >> Maybe.withDefault 0
          , toCell = .pefData >> Maybe.map (.weighting >> Format.ratio) >> Maybe.withDefault (text "N/A")
          }
        , { label = "Normalisation (Sc. Imp.)"
          , toValue =
                Table.FloatValue <|
                    .ecoscoreData
                        >> Maybe.map (.normalization >> Unit.impactToFloat)
                        >> Maybe.withDefault 0
          , toCell =
                \def ->
                    def.ecoscoreData
                        |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                        |> Maybe.withDefault (text "N/A")
          }
        , { label = "Pondération (Sc. Imp.)"
          , toValue =
                Table.FloatValue <|
                    .ecoscoreData
                        >> Maybe.map (.weighting >> Unit.ratioToFloat)
                        >> Maybe.withDefault 0
          , toCell = .ecoscoreData >> Maybe.map (.weighting >> Format.ratio) >> Maybe.withDefault (text "N/A")
          }
        , { label = "Niveau de qualité"
          , toValue =
                Table.IntValue <|
                    \def ->
                        case def.quality of
                            Definition.NotFinished ->
                                0

                            Definition.GoodQuality ->
                                4

                            Definition.AverageQuality ->
                                3

                            Definition.BadQuality ->
                                2

                            Definition.UnknownQuality ->
                                1
          , toCell =
                \def ->
                    def.quality
                        |> ImpactView.impactQuality
                        |> div [ classList [ ( "text-center", not detailed ) ] ]
          }
        , { label = "Source"
          , toValue = Table.StringValue <| .source >> .label
          , toCell =
                \def ->
                    a
                        [ href def.source.url
                        , target "_blank"
                        ]
                        [ text def.source.label ]
          }
        , { label = "Description"
          , toValue = Table.StringValue .description
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
    }
