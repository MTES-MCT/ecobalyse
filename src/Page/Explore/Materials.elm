module Page.Explore.Materials exposing (table)

import Data.Country as Country
import Data.Db as Db
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category
import Data.Unit as Unit
import Html exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


table : { detailed : Bool } -> Table Material msg
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \material ->
                if detailed then
                    code [] [ text (Material.idToString material.id) ]

                else
                    a [ Route.href (Route.Explore (Db.Materials (Just material.id))) ]
                        [ code [] [ text (Material.idToString material.id) ] ]
      }
    , { label = "Nom"
      , toCell = .name >> text
      }
    , { label = "Catégorie"
      , toCell = \material -> material.category |> Category.toString |> text
      }
    , { label = "Procédé"
      , toCell = .materialProcess >> .name >> text
      }
    , { label = "Procédé de recyclage"
      , toCell = .recycledProcess >> Maybe.map (.name >> text) >> Maybe.withDefault (text "N/A")
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
      , toCell = .continent >> text
      }
    , { label = "Pays par défaut"
      , toCell = .defaultCountry >> Country.codeToString >> text
      }
    , { label = "CFF: Coefficient d'allocation"
      , toCell =
            \{ cffData } ->
                case cffData of
                    Just { manufacturerAllocation } ->
                        manufacturerAllocation
                            |> Unit.ratioToFloat
                            |> Format.formatFloat 1
                            |> text

                    Nothing ->
                        text "N/A"
      }
    , { label = "CFF: Rapport de qualité"
      , toCell =
            \{ cffData } ->
                case cffData of
                    Just { recycledQualityRatio } ->
                        recycledQualityRatio
                            |> Unit.ratioToFloat
                            |> Format.formatFloat 1
                            |> text

                    Nothing ->
                        text "N/A"
      }
    ]
