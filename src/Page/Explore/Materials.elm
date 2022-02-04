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


table : { detailed : Bool } -> List { label : String, toCell : Material -> Html msg }
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \material ->
                if detailed then
                    code [] [ text (Process.uuidToString material.uuid) ]

                else
                    a [ Route.href (Route.Explore (Db.Materials (Just material.uuid))) ]
                        [ code [] [ text (Process.uuidToString material.uuid) ] ]
      }
    , { label = "Nom"
      , toCell = \material -> text material.name
      }
    , { label = "Catégorie"
      , toCell = \material -> material.category |> Category.toString |> text
      }
    , { label = "Procédé"
      , toCell = \material -> text material.materialProcess.name
      }
    , { label = "Procédé de recyclage"
      , toCell = \material -> material.recycledProcess |> Maybe.map (.name >> text) |> Maybe.withDefault (text "N/A")
      }
    , { label = "Primaire"
      , toCell =
            \material ->
                if material.primary then
                    text "Oui"

                else
                    text "Non"
      }
    , { label = "Continent"
      , toCell = \material -> text material.continent
      }
    , { label = "Pays par défaut"
      , toCell = \material -> material.defaultCountry |> Country.codeToString |> text
      }
    ]


details : Db -> Material -> Html msg
details _ material =
    Table.responsiveDefault [ class "view-details" ]
        [ table { detailed = True }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ toCell material ]
                        ]
                )
            |> tbody []
        ]


view : List Material -> Html msg
view materials =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ table { detailed = False }
                |> List.map (\{ label } -> th [] [ text label ])
                |> tr []
            ]
        , materials
            |> List.map
                (\material ->
                    table { detailed = False }
                        |> List.map (\{ toCell } -> td [] [ toCell material ])
                        |> tr []
                )
            |> tbody []
        ]
