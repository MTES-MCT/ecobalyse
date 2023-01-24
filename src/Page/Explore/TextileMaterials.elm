module Page.Explore.TextileMaterials exposing (table)

import Data.Country as Country
import Data.Dataset as Dataset
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Category as Category
import Data.Unit as Unit
import Html exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Alert as Alert
import Views.Format as Format


table : Db -> { detailed : Bool } -> Table Material msg
table { countries } { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \material ->
                if detailed then
                    code [] [ text (Material.idToString material.id) ]

                else
                    a [ Route.href (Route.Explore (Dataset.TextileMaterials (Just material.id))) ]
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
    , { label = "Origine géographique"
      , toCell = .geographicOrigin >> text
      }
    , { label = "Pays de production et de filature par défaut"
      , toCell =
            \material ->
                case Country.findByCode material.defaultCountry countries of
                    Ok country ->
                        text country.name

                    Err error ->
                        Alert.simple
                            { level = Alert.Danger
                            , close = Nothing
                            , title = Nothing
                            , content = [ text error ]
                            }
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
