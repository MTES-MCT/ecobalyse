module Page.Explore.TextileMaterials exposing (table)

import Data.Country as Country
import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Split as Split
import Data.Textile.Db as TextileDb
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Html exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Alert as Alert
import Views.Format as Format


recycledToString : Maybe Material.Id -> String
recycledToString maybeMaterialID =
    maybeMaterialID
        |> Maybe.map (always "oui")
        |> Maybe.withDefault "non"


table : TextileDb.Db -> { detailed : Bool, scope : Scope } -> Table Material String msg
table { countries } { detailed, scope } =
    { toId = .id >> Material.idToString
    , toRoute = .id >> Just >> Dataset.TextileMaterials >> Route.Explore scope
    , rows =
        [ { label = "Identifiant"
          , toValue = .id >> Material.idToString
          , toCell =
                \material ->
                    if detailed then
                        code [] [ text (Material.idToString material.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.TextileMaterials (Just material.id))) ]
                            [ code [] [ text (Material.idToString material.id) ] ]
          }
        , { label = "Nom"
          , toValue = .name
          , toCell = .name >> text
          }
        , { label = "Origine"
          , toValue = .origin >> Origin.toString
          , toCell = .origin >> Origin.toString >> text
          }
        , { label = "Recyclée ?"
          , toValue = .recycledFrom >> recycledToString
          , toCell = .recycledFrom >> recycledToString >> text
          }
        , { label = "Procédé"
          , toValue = .materialProcess >> .name
          , toCell = .materialProcess >> .name >> text
          }
        , { label = "Procédé de fabrication du fil"
          , toValue = .origin >> Origin.threadProcess
          , toCell = .origin >> Origin.threadProcess >> text
          }
        , { label = "Procédé de recyclage"
          , toValue = .recycledProcess >> Maybe.map .name >> Maybe.withDefault "N/A"
          , toCell = .recycledProcess >> Maybe.map (.name >> text) >> Maybe.withDefault (text "N/A")
          }
        , { label = "Origine géographique"
          , toValue = .geographicOrigin
          , toCell = .geographicOrigin >> text
          }
        , { label = "Pays de production et de filature par défaut"
          , toValue = .defaultCountry >> (\maybeCountry -> Country.findByCode maybeCountry countries) >> Result.map .name >> Result.toMaybe >> Maybe.withDefault "error"
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
          , toValue = .cffData >> Maybe.map (.manufacturerAllocation >> Split.toFloatString) >> Maybe.withDefault "N/A"
          , toCell =
                \{ cffData } ->
                    case cffData of
                        Just { manufacturerAllocation } ->
                            manufacturerAllocation
                                |> Format.splitAsFloat 1

                        Nothing ->
                            text "N/A"
          }
        , { label = "CFF: Rapport de qualité"
          , toValue = .cffData >> Maybe.map (.recycledQualityRatio >> Split.toFloatString) >> Maybe.withDefault "N/A"
          , toCell =
                \{ cffData } ->
                    case cffData of
                        Just { recycledQualityRatio } ->
                            recycledQualityRatio
                                |> Format.splitAsFloat 1

                        Nothing ->
                            text "N/A"
          }
        ]
    }
