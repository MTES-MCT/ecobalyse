module Page.Explore.FoodExamples exposing (table)

import Data.Dataset as Dataset
import Data.Example exposing (Example)
import Data.Food.Query exposing (Query)
import Data.Scope exposing (Scope)
import Data.Uuid as Uuid
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Icon as Icon


table :
    { maxScore : Float, maxPer100g : Float }
    -> { detailed : Bool, scope : Scope }
    -> Table ( Example Query, { score : Float, per100g : Float } ) String msg
table { maxScore, maxPer100g } { detailed, scope } =
    { filename = "examples"
    , toId = Tuple.first >> .id >> Uuid.toString
    , toRoute = Tuple.first >> .id >> Just >> Dataset.FoodExamples >> Route.Explore scope

    -- TODO
    , toSearchableString = always ""
    , legend = []
    , columns =
        [ { label = "Nom"
          , toValue = Table.StringValue (Tuple.first >> .name)
          , toCell = Tuple.first >> .name >> text
          }
        , { label = "Catégorie"
          , toValue = Table.StringValue (Tuple.first >> .category)
          , toCell = Tuple.first >> .category >> text
          }
        , { label = "Coût Environnemental"
          , toValue = Table.FloatValue (Tuple.second >> .score)
          , toCell =
                \( _, { score } ) ->
                    Common.impactBarGraph detailed maxScore score
          }
        , { label = "Coût Environnemental/100g"
          , toValue = Table.FloatValue (Tuple.second >> .per100g)
          , toCell =
                \( _, { per100g } ) ->
                    Common.impactBarGraph detailed maxPer100g per100g
          }
        , { label = ""
          , toValue = Table.NoValue
          , toCell =
                \( { id, name }, _ ) ->
                    a
                        [ class "btn btn-light btn-sm w-100"
                        , Route.href <| Route.FoodBuilderExample id
                        , title <| "Charger " ++ name
                        ]
                        [ Icon.search ]
          }
        ]
    }
