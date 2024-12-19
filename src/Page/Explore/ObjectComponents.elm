module Page.Explore.ObjectComponents exposing (table)

import Data.Dataset as Dataset
import Data.Object.Component as ObjectComponent
import Data.Process as Process
import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Static.Db exposing (Db)
import Views.Alert as Alert
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table ObjectComponent.Component String msg
table db { detailed, scope } =
    { filename = "components"
    , toId = .id >> ObjectComponent.idToString
    , toRoute = .id >> Just >> Dataset.ObjectComponents >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> ObjectComponent.idToString
          , toCell =
                \component ->
                    if detailed then
                        code [] [ text (ObjectComponent.idToString component.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.ObjectComponents (Just component.id))) ]
                            [ code [] [ text (ObjectComponent.idToString component.id) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue .name
          , toCell = .name >> text >> List.singleton >> strong []
          }
        , { label = "Procédés"
          , toValue =
                Table.StringValue <|
                    \{ processes } ->
                        case ObjectComponent.expandProcessItems db.object.processes processes of
                            Err _ ->
                                ""

                            Ok list ->
                                list
                                    |> List.map
                                        (\( amount, process ) ->
                                            String.fromFloat (ObjectComponent.amountToFloat amount)
                                                ++ process.unit
                                                ++ " de "
                                                ++ Process.getDisplayName process
                                        )
                                    |> String.join ", "
          , toCell =
                \{ processes } ->
                    case ObjectComponent.expandProcessItems db.object.processes processes of
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
