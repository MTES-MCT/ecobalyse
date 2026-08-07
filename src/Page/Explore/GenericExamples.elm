module Page.Explore.GenericExamples exposing (table)

{-| Note: This module is used to display object, veli and food2 examples.
-}

import Data.Component as Component
import Data.Dataset as Dataset
import Data.Example as Example exposing (Example)
import Data.Scope as Scope exposing (Scope)
import Data.Text as Text
import Data.Uuid as Uuid
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Icon as Icon



-- TODO: add score per 100g column for all examples


table :
    { maxScore : Float }
    -> { detailed : Bool, scope : Scope }
    -> Table ( Example Component.Query, { score : Float } ) String msg
table { maxScore } { detailed, scope } =
    { filename = Scope.toString scope ++ "-examples"
    , toId = Tuple.first >> .id >> Uuid.toString
    , toRoute =
        \example ->
            let
                maybeId =
                    example |> Tuple.first |> .id |> Just

                genericScope =
                    scope |> Scope.toGenericScope |> Maybe.withDefault Scope.Object
            in
            Route.Explore scope (Dataset.GenericExamples genericScope maybeId)
    , toSearchableWords = Tuple.first >> Example.toSearchableString >> Text.toWords
    , facets = []
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

        -- FIXME: this column should eventually be replaced with the product category
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
                        , Route.href <| Route.GenericSimulatorExample example.scope example.id
                        , title <| "Charger " ++ example.name
                        ]
                        [ Icon.search ]
          }
        ]
    }
