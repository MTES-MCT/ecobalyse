module Page.Explore.Impacts exposing (table)

import Data.Dataset as Dataset
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Scope exposing (Scope)
import Data.Split as Split
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Format as Format
import Views.Markdown as Markdown


table : { detailed : Bool, scope : Scope } -> Table Definition String msg
table { detailed, scope } =
    { filename = "impacts"
    , toId = .trigram >> Definition.toString
    , toRoute = .trigram >> Just >> Dataset.Impacts >> Route.Explore scope
    , legend = []
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
        , { label = "Normalisation (Coût Evt)"
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
        , { label = "Pondération (Coût Evt)"
          , toValue =
                Table.FloatValue <|
                    .ecoscoreData
                        >> Maybe.map (.weighting >> Split.toFloat)
                        >> Maybe.withDefault 0
          , toCell = .ecoscoreData >> Maybe.map (.weighting >> Format.splitAsPercentage 2) >> Maybe.withDefault (text "N/A")
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
