module Page.Explore.Impacts exposing (details, view)

import Data.Db as Db exposing (Db)
import Data.Impact as Impact exposing (Definition)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Markdown as Markdown
import Views.Table as Table


details : Db -> Definition -> Html msg
details _ def =
    Table.responsiveDefault []
        [ tbody []
            [ tr []
                [ th [] [ text "Trigramme" ]
                , td [] [ code [] [ text (Impact.toString def.trigram) ] ]
                ]
            , tr []
                [ th [] [ text "Nom" ]
                , td [] [ text def.label ]
                ]
            , tr []
                [ th [] [ text "Description" ]
                , td []
                    [ def.description
                        |> Markdown.simple []
                    ]
                ]
            , tr []
                [ th [] [ text "Unité" ]
                , td [] [ text def.unit ]
                ]
            , tr []
                [ th [] [ text "Coéf. normalisation PEF" ]
                , td []
                    [ def.pefData
                        |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                        |> Maybe.withDefault (text "N/A")
                    ]
                ]
            , tr []
                [ th [] [ text "Pondération PEF" ]
                , td []
                    [ def.pefData
                        |> Maybe.map (.weighting >> Format.ratio)
                        |> Maybe.withDefault (text "N/A")
                    ]
                ]
            ]
        ]


view : List Definition -> Html msg
view impacts =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Trigramme" ]
                , th [] [ text "Nom" ]
                , th [] [ text "Unité" ]
                , th [] [ text "Coéf. normalisation PEF" ]
                , th [] [ text "Pondération PEF" ]
                ]
            ]
        , impacts
            |> List.map row
            |> tbody []
        ]


row : Definition -> Html msg
row def =
    tr []
        [ td []
            [ a [ Route.href (Route.Explore (Db.Impacts (Just def.trigram))) ]
                [ code [] [ text (Impact.toString def.trigram) ] ]
            ]
        , td [] [ text def.label ]
        , td [] [ text def.unit ]
        , td []
            [ def.pefData
                |> Maybe.map (.normalization >> Unit.impactToFloat >> Format.formatRichFloat 2 def.unit)
                |> Maybe.withDefault (text "N/A")
            ]
        , td []
            [ def.pefData
                |> Maybe.map (.weighting >> Format.ratio)
                |> Maybe.withDefault (text "N/A")
            ]
        ]
