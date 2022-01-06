module Page.Explore.Products exposing (..)

import Data.Db as Db
import Data.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


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
