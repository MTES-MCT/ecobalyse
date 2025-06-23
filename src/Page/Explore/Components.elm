module Page.Explore.Components exposing (table)

import Data.Component as Component exposing (Component)
import Data.Dataset as Dataset
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Static.Db exposing (Db)
import Views.Alert as Alert
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table Component.Component String msg
table db { detailed, scope } =
    let
        scopedProcesses =
            db.processes
                |> Scope.anyOf [ scope ]
    in
    { filename = "components"
    , toId = .id >> Component.idToString
    , toRoute = .id >> Just >> Dataset.Components scope >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> Component.idToString
          , toCell =
                \component ->
                    if detailed then
                        code [] [ text (Component.idToString component.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.Components scope (Just component.id))) ]
                            [ code [] [ text (Component.idToString component.id) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue .name
          , toCell = .name >> text >> List.singleton >> strong []
          }
        , { label = "Éléments"
          , toValue =
                Table.StringValue <|
                    \{ elements } ->
                        case Component.expandElements db.processes elements of
                            Err _ ->
                                ""

                            Ok list ->
                                list
                                    |> List.map
                                        (\{ amount, material } ->
                                            String.fromFloat (Component.amountToFloat amount)
                                                ++ material.unit
                                                ++ " de "
                                                ++ Process.getDisplayName material
                                        )
                                    |> String.join ", "
          , toCell =
                \{ elements } ->
                    case Component.expandElements db.processes elements of
                        Err err ->
                            Alert.simple
                                { attributes = []
                                , close = Nothing
                                , content = [ text err ]
                                , level = Alert.Danger
                                , title = Nothing
                                }

                        Ok list ->
                            list
                                |> List.map
                                    (\{ amount, material, transforms } ->
                                        li []
                                            [ Format.amount material amount
                                            , text <| " de " ++ Process.getDisplayName material
                                            , transforms
                                                |> List.map (\transform -> li [] [ text <| Process.getDisplayName transform ])
                                                |> ul []
                                            ]
                                    )
                                |> ul [ class "m-0 px-2" ]
          }
        , { label = "Coût environnemental"
          , toValue = Table.FloatValue <| getComponentEcoscore scopedProcesses >> Result.withDefault 0
          , toCell =
                getComponentEcoscore db.processes
                    >> Result.map (Format.formatImpactFloat { decimals = 2, unit = "Pts par composant" })
                    >> Result.withDefault (text "N/A")
          }
        ]
    }


getComponentEcoscore : List Process -> Component -> Result String Float
getComponentEcoscore processes =
    Component.computeImpacts processes
        >> Result.map
            (Component.extractImpacts
                >> Impact.getImpact Definition.Ecs
                >> Unit.impactToFloat
            )
