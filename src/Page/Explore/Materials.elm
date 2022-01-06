module Page.Explore.Materials exposing (..)

import Data.Country as Country
import Data.Material exposing (Material)
import Data.Material.Category as Category
import Data.Process as Process
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Table as Table


view : List Material -> Html msg
view materials =
    Table.responsiveDefault []
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
        [ td [] [ code [] [ text (Process.uuidToString material.uuid) ] ]
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
