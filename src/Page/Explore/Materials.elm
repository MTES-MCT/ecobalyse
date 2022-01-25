module Page.Explore.Materials exposing (details, view)

import Data.Country as Country
import Data.Db as Db exposing (Db)
import Data.Material exposing (Material)
import Data.Material.Category as Category
import Data.Process as Process
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Table as Table


details : Db -> Material -> Html msg
details _ material =
    Table.responsiveDefault [ class "view-details" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Identifiant" ]
                , td [] [ code [] [ text (Process.uuidToString material.uuid) ] ]
                ]
            , tr []
                [ th [] [ text "Nom" ]
                , td [] [ text material.name ]
                ]
            , tr []
                [ th [] [ text "Catégorie" ]
                , td [] [ material.category |> Category.toString |> text ]
                ]
            , tr []
                [ th [] [ text "Procédé" ]
                , td [] [ text material.materialProcess.name ]
                ]
            , tr []
                [ th [] [ text "Procédé de recyclage" ]
                , td [] [ material.recycledProcess |> Maybe.map (.name >> text) |> Maybe.withDefault (text "N/A") ]
                ]
            , tr []
                [ th [] [ text "Primaire" ]
                , td []
                    [ if material.primary then
                        text "Oui"

                      else
                        text "Non"
                    ]
                ]
            , tr []
                [ th [] [ text "Continent" ]
                , td [] [ text material.continent ]
                ]
            , tr []
                [ th [] [ text "Pays par défaut" ]
                , td [] [ material.defaultCountry |> Country.codeToString |> text ]
                ]
            ]
        ]


view : List Material -> Html msg
view materials =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ tr []
                [ th [] [ text "Identifiant" ]
                , th [] [ text "Nom" ]
                , th [] [ text "Catégorie" ]
                , th [] [ text "Procédé" ]
                , th [] [ text "Procédé de recyclage" ]
                , th [] [ text "Primaire" ]
                , th [] [ text "Continent" ]
                , th [] [ text "Pays par défaut" ]
                ]
            ]
        , materials
            |> List.map row
            |> tbody []
        ]


row : Material -> Html msg
row material =
    tr []
        [ td []
            [ a [ Route.href (Route.Explore (Db.Materials (Just material.uuid))) ]
                [ code [] [ text (Process.uuidToString material.uuid) ] ]
            ]
        , td [] [ text material.name ]
        , td [] [ material.category |> Category.toString |> text ]
        , td [] [ text material.materialProcess.name ]
        , td [] [ material.recycledProcess |> Maybe.map (.name >> text) |> Maybe.withDefault (text "N/A") ]
        , td []
            [ if material.primary then
                text "Oui"

              else
                text "Non"
            ]
        , td [] [ text material.continent ]
        , td [] [ material.defaultCountry |> Country.codeToString |> text ]
        ]
