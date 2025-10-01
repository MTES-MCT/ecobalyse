module Page.Explore.TextileMaterials exposing (table)

import Data.Country as Country
import Data.Dataset as Dataset
import Data.Gitbook as Gitbook
import Data.Process as Process
import Data.Scope exposing (Scope)
import Data.Split as Split
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
import Views.Icon as Icon
import Views.Link as Link
import Data.Textile.Material exposing (Id)

recycledToString : Maybe Id -> String
recycledToString maybeMaterialID =
    maybeMaterialID
        |> Maybe.map (always "oui")
        |> Maybe.withDefault "non"


table : Db -> { detailed : Bool, scope : Scope } -> Table Material String msg
table db { detailed, scope } =
    let
        withPill url content =
            div
                [ classList [ ( "text-center", not detailed ) ] ]
                [ content, Link.smallPillExternal [ href (Gitbook.publicUrlFromPath url) ] [ Icon.question ] ]
    in
    { filename = "materials"
    , toId = .id >> Material.idToString
    , toRoute = .id >> Just >> Dataset.TextileMaterials >> Route.Explore scope
    , legend = []
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
          , toValue = Table.StringValue <| .name
          , toCell = .name >> text
          }
        , { label = "Procédé"
          , toValue = Table.StringValue <| .process >> Process.getDisplayName
          , toCell = .process >> Process.getDisplayName >> text
          }
        , { label = "Source"
          , toValue = Table.StringValue <| .process >> .source
          , toCell = .process >> .source >> text
          }
        , { label = "Origine"
          , toValue = Table.StringValue <| .origin >> Origin.toLabel
          , toCell = .origin >> Origin.toLabel >> text
          }
        , { label = "Recyclée ?"
          , toValue = Table.StringValue <| .recycledFrom >> recycledToString
          , toCell = .recycledFrom >> recycledToString >> text
          }
        , { label = "Complément Microfibres"
          , toValue = Table.FloatValue <| .origin >> Origin.toMicrofibersComplement >> Unit.impactToFloat
          , toCell =
                .origin
                    >> Origin.toMicrofibersComplement
                    >> Unit.impactToFloat
                    >> Format.formatImpactFloat { unit = "\u{202F}Pts/kg", decimals = 2 }
                    >> withPill Gitbook.TextileComplementMicrofibers
          }
        , { label = "Procédé de fabrication du fil"
          , toValue = Table.StringValue <| .origin >> Origin.threadProcess
          , toCell =
                .origin
                    >> Origin.threadProcess
                    >> text
                    >> withPill Gitbook.TextileSpinning
          }
        , { label = "Procédé de recyclage"
          , toValue = Table.StringValue <| .recycledProcess >> Maybe.map Process.getDisplayName >> Maybe.withDefault "N/A"
          , toCell = .recycledProcess >> Maybe.map (Process.getDisplayName >> text) >> Maybe.withDefault (text "N/A")
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
                        Err error ->
                            Alert.simple
                                { attributes = []
                                , level = Alert.Danger
                                , close = Nothing
                                , title = Nothing
                                , content = [ text error ]
                                }

                        Ok country ->
                            text country.name
          }
        , { label = "CFF: Coefficient d'allocation"
          , toValue =
                Table.FloatValue <|
                    .cffData
                        >> Maybe.map (.manufacturerAllocation >> Split.toFloat)
                        >> Maybe.withDefault 0
          , toCell =
                .cffData
                    >> Maybe.map
                        (.manufacturerAllocation
                            >> Format.splitAsFloat 1
                            >> withPill Gitbook.TextileCircularFootprintFormula
                        )
                    >> Maybe.withDefault (text "N/A")
          }
        , { label = "CFF: Rapport de qualité"
          , toValue =
                Table.FloatValue <|
                    .cffData
                        >> Maybe.map (.recycledQualityRatio >> Split.toFloat)
                        >> Maybe.withDefault 0
          , toCell =
                .cffData
                    >> Maybe.map
                        (.recycledQualityRatio
                            >> Format.splitAsFloat 1
                            >> withPill Gitbook.TextileCircularFootprintFormula
                        )
                    >> Maybe.withDefault (text "N/A")
          }
        ]
    }
