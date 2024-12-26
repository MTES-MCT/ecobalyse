module Page.Explore.Components exposing (table)

import Data.Component as Component
import Data.Dataset as Dataset
import Data.Process as Process
import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Static.Db as Db exposing (Db)
import Views.Alert as Alert
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table Component.Component String msg
table db { detailed, scope } =
    let
        expandProcesses =
            Component.expandProcessItems (Db.scopedProcesses scope db)
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
        , { label = "Procédés"
          , toValue =
                Table.StringValue <|
                    \{ processes } ->
                        case expandProcesses processes of
                            Err _ ->
                                ""

                            Ok list ->
                                list
                                    |> List.map
                                        (\( amount, process ) ->
                                            String.fromFloat (Component.amountToFloat amount)
                                                ++ process.unit
                                                ++ " de "
                                                ++ Process.getDisplayName process
                                        )
                                    |> String.join ", "
          , toCell =
                \{ processes } ->
                    case expandProcesses processes of
                        Err err ->
                            Alert.simple
                                { close = Nothing
                                , content = [ text err ]
                                , level = Alert.Danger
                                , title = Nothing
                                }

                        Ok list ->
                            list
                                |> List.map
                                    (\( amount, process ) ->
                                        li []
                                            [ Format.amount process amount
                                            , text <| " de " ++ Process.getDisplayName process
                                            ]
                                    )
                                |> List.intersperse (text ", ")
                                |> ul [ class "m-0 px-2" ]
          }
        ]
    }
