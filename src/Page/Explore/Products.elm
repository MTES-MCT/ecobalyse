module Page.Explore.Products exposing (details, view)

import Data.Db as Db exposing (Db)
import Data.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Table as Table


details : Db -> Product -> Html msg
details _ product =
    Table.responsiveDefault [ class "view-details" ]
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
                [ th [] [ text "Type de procédé" ]
                , td [] [ text product.fabricProcess.name ]
                ]
            , tr []
                [ th [] [ text "Confection" ]
                , td [] [ text product.makingProcess.name ]
                ]
            , tr []
                [ th [] [ text "Nombre de jours porté" ]
                , td [] [ Format.days product.daysOfWear ]
                ]
            , tr []
                [ th [] [ text "Nombre par défaut de cycles d'entretien" ]
                , td [] [ text (String.fromInt product.useDefaultNbCycles) ]
                ]
            , tr []
                [ th [] [ text "Procédé de repassage" ]
                , td [] [ text product.useIroningProcess.name ]
                ]
            , tr []
                [ th [] [ text "Procédé composite d'utilisation hors-repassage" ]
                , td [] [ text product.useNonIroningProcess.name ]
                ]
            , tr []
                [ th [] [ text "Ratio de séchage électrique" ]
                , td []
                    [ div [] [ Format.ratio product.useRatioDryer ]
                    , div [ class "text-muted fs-7" ]
                        [ span [ class "me-1" ] [ Icon.info ]
                        , text "Affichage pour information, valeur intégrée dans les précalculs de procédé"
                        ]
                    ]
                ]
            , tr []
                [ th [] [ text "Ratio de repassage" ]
                , td []
                    [ div [] [ Format.ratio product.useRatioIroning ]
                    , div [ class "text-muted fs-7" ]
                        [ span [ class "me-1" ] [ Icon.info ]
                        , text "Affichage pour information, valeur intégrée dans les précalculs de procédé"
                        ]
                    ]
                ]
            , tr []
                [ th [] [ text "Temps de repassage" ]
                , td []
                    [ div [] [ Format.hours product.useTimeIroning ]
                    , div [ class "text-muted fs-7" ]
                        [ span [ class "me-1" ] [ Icon.info ]
                        , text "Affichage pour information, valeur intégrée dans les précalculs de procédé"
                        ]
                    ]
                ]
            ]
        ]


view : List Product -> Html msg
view products =
    Table.responsiveDefault [ class "view-list" ]
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
                , th [] [ text "Nombre de jours porté" ]
                , th [] [ text "Cycles d'entretien (par défaut)" ]
                , th [] [ text "Repassage" ]
                , th [] [ text "Hors-repassage" ]
                , th [] [ text "Séchage électrique" ]
                , th [] [ text "Repassage (part)" ]
                , th [] [ text "Repassage (temps)" ]
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
        , td [ class "text-end" ] [ Format.days product.daysOfWear ]
        , td [ class "text-end" ] [ text (String.fromInt product.useDefaultNbCycles) ]
        , td [] [ text product.useIroningProcess.name ]
        , td [] [ text product.useNonIroningProcess.name ]
        , td [ class "text-end" ] [ Format.ratio product.useRatioDryer ]
        , td [ class "text-end" ] [ Format.ratio product.useRatioIroning ]
        , td [ class "text-end" ] [ Format.hours product.useTimeIroning ]
        ]
