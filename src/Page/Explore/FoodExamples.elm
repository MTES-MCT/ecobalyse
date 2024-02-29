module Page.Explore.FoodExamples exposing (table)

import Data.Dataset as Dataset
import Data.Food.ExampleProduct exposing (ExampleProduct)
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope exposing (Scope)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Static.Db exposing (Db)
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table ExampleProduct String msg
table db { detailed, scope } =
    { toId = .name
    , toRoute = .name >> Just >> Dataset.FoodExamples >> Route.Explore scope
    , columns =
        [ { label = "Nom"
          , toValue = .name
          , toCell = .name >> text
          }
        , { label = "Coût environnemental"
          , toValue = getScore db >> Unit.impactToFloat >> String.fromFloat
          , toCell =
                \example ->
                    div [ classList [ ( "text-end", not detailed ) ] ]
                        [ getScore db example
                            |> Unit.impactToFloat
                            |> Format.formatImpactFloat db.definitions.ecs
                        ]
          }
        ]
    }


getScore : Db -> ExampleProduct -> Unit.Impact
getScore db =
    .query
        >> Recipe.compute db
        >> Result.map (Tuple.second >> .total >> Impact.getImpact Definition.Ecs)
        >> Result.withDefault (Unit.impact 0)
