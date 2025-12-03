module Page.Explore.ObjectExamples exposing (table)

{-| Note: This module is used to display both objects and veli examples.
-}

import Data.Component as Component
import Data.Dataset as Dataset
import Data.Example exposing (Example)
import Data.Scope as Scope exposing (Scope)
import Data.Uuid as Uuid
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Icon as Icon


table :
    { maxScore : Float }
    -> { detailed : Bool, scope : Scope }
    -> Table ( Example Component.Query, { score : Float } ) String msg
table { maxScore } { detailed, scope } =
    { filename = "examples"
    , toId = Tuple.first >> .id >> Uuid.toString
    , toRoute =
        Tuple.first
            >> .id
            >> Just
            >> (if scope == Scope.Veli then
                    Dataset.VeliExamples

                else
                    Dataset.ObjectExamples
               )
            >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Nom"
          , toValue = Table.StringValue (Tuple.first >> .name)
          , toCell = Tuple.first >> .name >> text
          }
        , { label = "Famille"
          , toValue = Table.StringValue (Tuple.first >> .scope >> Scope.toLabel)
          , toCell = Tuple.first >> .scope >> Scope.toLabel >> text
          }
        , { label = "Catégorie"
          , toValue = Table.StringValue (Tuple.first >> .category)
          , toCell =
                \( { category }, _ ) ->
                    if category == "" then
                        i [ class "text-muted" ] [ text "non-renseigné" ]

                    else
                        text category
          }
        , { label = "Coût Environnemental"
          , toValue = Table.FloatValue (Tuple.second >> .score)
          , toCell =
                \( _, { score } ) ->
                    Common.impactBarGraph detailed maxScore score
          }
        , { label = ""
          , toValue = Table.NoValue
          , toCell =
                \( example, _ ) ->
                    a
                        [ class "btn btn-light btn-sm w-100"

                        -- FIXME: multiple exlorer for Veli
                        , Route.href <| Route.ObjectSimulatorExample example.scope example.id
                        , title <| "Charger " ++ example.name
                        ]
                        [ Icon.search ]
          }
        ]
    }
