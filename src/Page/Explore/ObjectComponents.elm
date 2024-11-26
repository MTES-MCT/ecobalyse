module Page.Explore.ObjectComponents exposing (table)

import Data.Dataset as Dataset
import Data.Object.Component as ObjectComponent
import Data.Scope exposing (Scope)
import Html exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route


table : { detailed : Bool, scope : Scope } -> Table ObjectComponent.Component String msg
table { detailed, scope } =
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
          , toCell = .name >> text
          }
        ]
    }
