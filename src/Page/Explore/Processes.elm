module Page.Explore.Processes exposing (table)

import Data.Dataset as Dataset
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Process.Category as ProcessCategory
import Data.Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Split as Split
import Data.Unit as Unit
import Energy
import Html exposing (..)
import Page.Explore.Table as Table exposing (Column, Table)
import Route
import Views.Format as Format


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
    , { label = "Nom technique"
      , toValue = Table.StringValue Process.getTechnicalName
      , toCell = Process.getTechnicalName >> text
      }
    , { label = "Source"
      , toValue = Table.StringValue <| .source
      , toCell = .source >> text
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
    , { label = "Unité"
      , toValue = Table.StringValue <| .unit
      , toCell = .unit >> text
      }
    , { label = "Électricité"
      , toValue = Table.FloatValue <| .elec >> Energy.inKilowattHours
      , toCell = .elec >> Format.kilowattHours
      }
    , { label = "Chaleur"
      , toValue = Table.FloatValue <| .heat >> Energy.inMegajoules
      , toCell = .heat >> Format.megajoules
      }
    , { label = "Pertes"
      , toValue = Table.FloatValue <| .waste >> Split.toPercent
      , toCell = .waste >> Format.splitAsPercentage 2
      }
    , { label = "Densité"
      , toValue = Table.FloatValue .density
      , toCell = Format.density
      }
    , { label = "Commentaire"
      , toValue = Table.StringValue .comment
      , toCell = .comment >> text
      }
    ]


impactsColumns : Session -> List (Column Process String msg)
impactsColumns { db, store } =
    case store.auth of
        Session.Authenticated { staff } ->
            if staff then
                -- User is admin: add columns for detailed impacts
                Definition.trigrams
                    |> List.map
                        (\trigram ->
                            { label = Definition.toString trigram
                            , toValue = Table.FloatValue <| .impacts >> Impact.getImpact trigram >> Unit.impactToFloat
                            , toCell = .impacts >> Format.formatImpact (Definition.get trigram db.definitions)
                            }
                        )

            else
                []

        Session.NotAuthenticated ->
            []
