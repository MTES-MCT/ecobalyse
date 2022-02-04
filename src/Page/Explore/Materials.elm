module Page.Explore.Materials exposing (table)

import Data.Country as Country
import Data.Db as Db
import Data.Material exposing (Material)
import Data.Material.Category as Category
import Data.Process as Process
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route


table : { detailed : Bool } -> Table Material msg
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
