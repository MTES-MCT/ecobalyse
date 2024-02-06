module Page.Explore.TextileMaterials exposing (table)

import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Split as Split
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


recycledToString : Maybe Material.Id -> String
recycledToString maybeMaterialID =
    maybeMaterialID
        |> Maybe.map (always "oui")
        |> Maybe.withDefault "non"


table : { detailed : Bool, scope : Scope } -> Table Material String msg
table { detailed, scope } =
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
        , { label = "Procédé"
          , toValue = .materialProcess >> .name
          , toCell = .materialProcess >> .name >> text
          }
        , { label = "Origine"
          , toValue = .origin >> Origin.toLabel
          , toCell = .origin >> Origin.toLabel >> text
          }
        , { label = "Recyclée ?"
          , toValue = .recycledFrom >> recycledToString
          , toCell = .recycledFrom >> recycledToString >> text
          }
        , { label = "Complément Microfibres"
          , toValue = .origin >> Origin.toMicrofibersComplement >> Unit.impactToFloat >> String.fromFloat
          , toCell =
                \{ origin } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Origin.toMicrofibersComplement origin
                            |> Unit.impactToFloat
                            |> Format.formatImpactFloat { unit = "\u{202F}µPts/kg", decimals = 2 }
                        ]
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
