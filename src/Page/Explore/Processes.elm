module Page.Explore.Processes exposing (table)

import Data.Complement as Complement
import Data.Country as Country
import Data.Dataset as Dataset
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Process as Process exposing (Process)
import Data.Process.Category as ProcessCategory
import Data.Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Split as Split
import Data.Unit as Unit
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Column, Table)
import Route
import Views.Format as Format


table : Session -> { detailed : Bool, scope : Scope } -> Table Process String msg
table session { detailed, scope } =
    { filename = "processes"
    , toId = .id >> Process.idToString
    , toRoute = .id >> Just >> Dataset.Processes scope >> Route.Explore scope
    , toSearchableWords = Process.getSearchableWords
    , facets =
        [ Table.Facet "Catégories" (.categories >> List.map ProcessCategory.toLabel)
        , Table.Facet "Unités" (.unit >> Process.unitToString >> List.singleton)
        , Table.Facet "Région"
            (.location
                >> Maybe.map
                    (\location ->
                        -- attempt decoding the region string as a an existing country code in the shared db
                        case session.db.countries |> Country.findByCode (Country.codeFromString location) of
                            Err _ ->
                                location

                            Ok { name } ->
                                name ++ " (" ++ location ++ ")"
                    )
                >> Maybe.withDefault "N/A"
                >> List.singleton
            )
        ]
    , legend = []
    , columns = baseColumns detailed scope ++ impactsColumns session ++ complementsColumns session
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
      , toCell = Process.getDisplayName >> tooltipedCell
      }
    , { label = "Nom technique"
      , toValue = Table.StringValue Process.getTechnicalName
      , toCell = Process.getTechnicalName >> tooltipedCell
      }
    , { label = "Source"
      , toValue = Table.StringValue <| .source
      , toCell = .source >> text
      }
    , { label = "Région"
      , toValue = Table.StringValue <| .location >> Maybe.withDefault "N/A"
      , toCell = .location >> Maybe.withDefault "N/A" >> text
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
                >> tooltipedCell
      }
    , { label = "Unité"
      , toValue = Table.StringValue <| .unit >> Process.unitToString
      , toCell = .unit >> Process.unitToString >> text
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
    , { label = "Masse par unité"
      , toValue = Table.StringValue <| .massPerUnit >> Maybe.map String.fromFloat >> Maybe.withDefault "N/A"
      , toCell = Format.massPerUnit
      }
    , { label = "Commentaire"
      , toValue = Table.StringValue .comment
      , toCell = .comment >> text
      }
    ]


complementsColumns : Session -> List (Column Process String msg)
complementsColumns { db } =
    let
        complementToMaybeFloat : (Complement.ComplementsImpacts -> Maybe Unit.Impact) -> Process -> Maybe Float
        complementToMaybeFloat accessor =
            .metadata
                >> Maybe.andThen .complements
                >> Maybe.andThen accessor
                >> Maybe.map Unit.impactToFloat
    in
    List.map2
        (\a b ->
            { label = b
            , toValue =
                Table.FloatValue <|
                    complementToMaybeFloat a
                        >> Maybe.withDefault 0
            , toCell =
                complementToMaybeFloat a
                    >> Maybe.map (Format.formatImpactFloat (Definition.get Definition.Ecs db.definitions))
                    >> Maybe.withDefault (text "N/A")
            }
        )
        Complement.allComplementsFields
        (Complement.labels |> Complement.allComplementsToList)


impactCell : Definitions -> Definition.Trigram -> Column Process String msg
impactCell definitions trigram =
    { label = Definition.toString trigram
    , toValue = Table.FloatValue <| .impacts >> Impact.getImpact trigram >> Unit.impactToFloat
    , toCell = .impacts >> Format.formatImpact (Definition.get trigram definitions)
    }


impactsColumns : Session -> List (Column Process String msg)
impactsColumns ({ db } as session) =
    if Session.isSuperuser session then
        Definition.trigrams
            |> List.map (impactCell db.definitions)

    else
        Definition.Ecs
            |> impactCell db.definitions
            |> List.singleton


tooltipedCell : String -> Html msg
tooltipedCell string =
    span [ class "cursor-help", title string ]
        [ text string ]
