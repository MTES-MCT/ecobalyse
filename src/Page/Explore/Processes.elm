module Page.Explore.Processes exposing (table)

import Data.Dataset as Dataset
import Data.Process as Process exposing (Process)
import Data.Process.Category as ProcessCategory
import Data.Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Page.Explore.Table as Table exposing (Column, Table)
import Route


table : Session -> { detailed : Bool, scope : Scope } -> Table Process String msg
table session { detailed, scope } =
    { filename = "processes"
    , toId = .id >> Process.idToString
    , toRoute = .id >> Just >> Dataset.Processes scope >> Route.Explore scope
    , legend = []
    , columns = baseColumns detailed scope ++ impactsColumns session
    }


baseColumns : Bool -> Scope -> List (Column Process String msg)
baseColumns detailed scope =
    [ { label = "Identifiant"
      , toValue = Table.StringValue <| .id >> Process.idToString
      , toCell =
            \process ->
                if detailed then
                    code [] [ text (Process.idToString process.id) ]

                else
                    a [ Route.href (Route.Explore scope (Dataset.Processes scope (Just process.id))) ]
                        [ code [] [ text (Process.idToString process.id) ] ]
      }
    , { label = "Nom"
      , toValue = Table.StringValue Process.getDisplayName
      , toCell = Process.getDisplayName >> text
      }
    , { label = "Catégories"
      , toValue =
            Table.StringValue <|
                .categories
                    >> List.map ProcessCategory.toLabel
                    >> String.join ", "
      , toCell =
            .categories
                >> List.map ProcessCategory.toLabel
                >> String.join ", "
                >> text
      }
    , { label = "Nom technique"
      , toValue = Table.StringValue .name
      , toCell = .name >> text
      }
    , { label = "Source"
      , toValue = Table.StringValue <| .source
      , toCell = .source >> text
      }
    , { label = "Identifiant dans la source"
      , toValue = Table.StringValue <| .sourceId >> Maybe.map Process.sourceIdToString >> Maybe.withDefault ""
      , toCell = .sourceId >> Maybe.map (Process.sourceIdToString >> text >> List.singleton >> code []) >> Maybe.withDefault (text "")
      }
    , { label = "Alias"
      , toValue = Table.StringValue <| .alias >> Maybe.withDefault ""
      , toCell = .alias >> Maybe.map (text >> List.singleton >> em []) >> Maybe.withDefault (text "")
      }
    , { label = "Unité"
      , toValue = Table.StringValue <| .unit
      , toCell = .unit >> text
      }
    , { label = "Commentaire"
      , toValue = Table.StringValue .comment
      , toCell = .comment >> text
      }
    ]


impactsColumns : Session -> List (Column data comparable msg)
impactsColumns { store } =
    case store.auth of
        Session.Authenticated { staff } ->
            if staff then
                -- Detailed impacts
                [ { label = "Details des impacts"
                  , toValue = Table.NoValue
                  , toCell = always (text "ok")
                  }
                ]

            else
                []

        Session.NotAuthenticated ->
            []
