module Page.Explore.Products exposing (..)

import Data.Db as Db exposing (Db)
import Data.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


details : Db -> Product -> Html msg
details _ product =
    Table.responsiveDefault []
        [ tbody []
            [ tr []
                [ th [] [ text "Identifiant" ]
                , td [] [ code [] [ text (Product.idToString product.id) ] ]
                ]
            , tr []
                [ th [] [ text "Nom" ]
                , td [] [ text product.name ]
                ]
            , tr []
                [ th [] [ text "Masse par défaut" ]
                , td [] [ Format.kg product.mass ]
                ]
            , tr []
                [ th [] [ text "Taux de perte (PCR)" ]
                , td [] [ Format.ratio product.pcrWaste ]
                ]
            , tr []
                [ th [] [ text "Type de procédé" ]
                , td []
                    [ if product.knitted then
                        text "Tricotage"

                      else
                        text "Tissage"
                    ]
                ]
            , tr []
                [ th [] [ text "Pick-per-meter" ]
                , td []
                    [ if product.knitted then
                        text "N/A"

                      else
                        text <| Format.formatInt "picks-per-meter" product.ppm
                    ]
                ]
            , tr []
                [ th [] [ text "Grammage" ]
                , td []
                    [ if product.knitted then
                        text "N/A"

                      else
                        text <| Format.formatInt "gr. per kg" product.grammage
                    ]
                ]
            , tr []
                [ th [] [ text "Procédé" ]
                , td [] [ text product.fabricProcess.name ]
                ]
            , tr []
                [ th [] [ text "Confection" ]
                , td [] [ text product.makingProcess.name ]
                ]
            ]
        ]


view : List Product -> Html msg
view products =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Identifiant" ]
                , th [] [ text "Nom" ]
                , th [] [ text "Masse par défaut" ]
                , th [] [ text "Taux de perte (PCR)" ]
                , th [] [ text "Type de procédé" ]
                , th [] [ text "Pick-per-meter" ]
                , th [] [ text "Grammage" ]
                , th [] [ text "Procédé" ]
                , th [] [ text "Confection" ]
                ]
            ]
        , products
            |> List.map row
            |> tbody []
        ]


row : Product -> Html msg
row product =
    tr []
        [ td []
            [ a [ Route.href (Route.Explore (Db.Products (Just product.id))) ]
                [ code [] [ text (Product.idToString product.id) ] ]
            ]
        , td [] [ text product.name ]
        , td [] [ Format.kg product.mass ]
        , td [] [ Format.ratio product.pcrWaste ]
        , td []
            [ if product.knitted then
                text "Tricotage"

              else
                text "Tissage"
            ]
        , td []
            [ if product.knitted then
                text "N/A"

              else
                text <| Format.formatInt "picks-per-meter" product.ppm
            ]
        , td []
            [ if product.knitted then
                text "N/A"

              else
                text <| Format.formatInt "gr. per kg" product.grammage
            ]
        , td [] [ text product.fabricProcess.name ]
        , td [] [ text product.makingProcess.name ]
        ]
