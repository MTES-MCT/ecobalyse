module Page.Explore.FoodExamples exposing (table)

import Data.Dataset as Dataset
import Data.Food.ExampleProduct as ExampleProduct exposing (ExampleProduct)
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope exposing (Scope)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table as Table exposing (Column, Table)
import Route
import Static.Db exposing (Db)


table : Db -> { detailed : Bool, scope : Scope } -> Table ExampleProduct String msg
table db { detailed, scope } =
    { toId = .id >> ExampleProduct.uuidToString
    , toRoute = .id >> Just >> Dataset.FoodExamples >> Route.Explore scope
    , columns =
        [ { label = "Nom"
          , toValue = Table.StringValue .name
          , toCell = .name >> text
          }
        , { label = "Catégorie"
          , toValue = Table.StringValue .category
          , toCell = .category >> text
          }
        , scoreCell db "Coût Environnemental" detailed (getScore db)
        , scoreCell db "Coût Environnemental/100g" detailed (getScorePer100g db)
        , { label = ""
          , toValue = Table.NoValue
          , toCell =
                \{ query } ->
                    a
                        [ class "btn btn-primary btn-sm w-100"
                        , Route.href <| Route.FoodBuilder Definition.Ecs (Just query)
                        ]
                        [ text "Ouvrir" ]
          }
        ]
    }


getScore : Db -> ExampleProduct -> Unit.Impact
getScore db =
    .query
        >> Recipe.compute db
        >> Result.map (Tuple.second >> .total >> Impact.getImpact Definition.Ecs)
        >> Result.withDefault (Unit.impact 0)


getScorePer100g : Db -> ExampleProduct -> Unit.Impact
getScorePer100g db =
    .query
        >> Recipe.compute db
        >> Result.map
            (Tuple.second
                >> .perKg
                >> Impact.getImpact Definition.Ecs
                >> (\x -> Unit.impact (Unit.impactToFloat x / 10))
            )
        >> Result.withDefault (Unit.impact 0)


scoreCell : Db -> String -> Bool -> (ExampleProduct -> Unit.Impact) -> Column ExampleProduct comparable msg
scoreCell db label detailed scoreGetter =
    { label = label
    , toValue = Table.FloatValue <| scoreGetter >> Unit.impactToFloat
    , toCell =
        \example ->
            let
                score =
                    scoreGetter example
                        |> Unit.impactToFloat

                max =
                    db.food.exampleProducts
                        |> List.map (scoreGetter >> Unit.impactToFloat)
                        |> List.maximum
                        |> Maybe.withDefault 0
            in
            Common.impactBarGraph detailed max score
    }
