module Page.Explore.TextileMaterials exposing (table)

import Data.Country as Country
import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Static.Db exposing (Db)
import Views.Alert as Alert
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table Material String msg
table db { detailed, scope } =
    { toId = .id >> Material.idToString
    , toRoute = .id >> Just >> Dataset.TextileMaterials >> Route.Explore scope
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> Material.idToString
          , toCell =
                \material ->
                    if detailed then
                        code [] [ text (Material.idToString material.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.TextileMaterials (Just material.id))) ]
                            [ code [] [ text (Material.idToString material.id) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue <| .materialProcess >> .name
          , toCell = .materialProcess >> .name >> text
          }
        , { label = "Origine"
          , toValue = Table.StringValue <| .origin >> Origin.toLabel
          , toCell = .origin >> Origin.toLabel >> text
          }
        , { label = "Complément Microfibres"
          , toValue = Table.FloatValue <| .origin >> Origin.toMicrofibersComplement >> Unit.impactToFloat
          , toCell =
                \{ origin } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Origin.toMicrofibersComplement origin
                            |> Unit.impactToFloat
                            |> Format.formatImpactFloat { unit = "\u{202F}µPts/kg", decimals = 2 }
                        ]
          }
        , { label = "Procédé de fabrication du fil"
          , toValue = Table.StringValue <| .origin >> Origin.threadProcess
          , toCell = .origin >> Origin.threadProcess >> text
          }
        , { label = "Origine géographique"
          , toValue = Table.StringValue .geographicOrigin
          , toCell = .geographicOrigin >> text
          }
        , { label = "Pays de production et de filature par défaut"
          , toValue =
                Table.StringValue <|
                    .defaultCountry
                        >> (\maybeCountry -> Country.findByCode maybeCountry db.countries)
                        >> Result.map .name
                        >> Result.toMaybe
                        >> Maybe.withDefault "error"
          , toCell =
                \material ->
                    case Country.findByCode material.defaultCountry db.countries of
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
        ]
    }
