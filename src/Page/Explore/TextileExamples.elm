module Page.Explore.TextileExamples exposing (table)

import Data.Dataset as Dataset
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope exposing (Scope)
import Data.Textile.ExampleProduct as ExampleProduct exposing (ExampleProduct)
import Data.Textile.Simulator as Simulator
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Static.Db exposing (Db)
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table ExampleProduct String msg
table db { detailed, scope } =
    { toId = .id >> ExampleProduct.uuidToString
    , toRoute = .id >> Just >> Dataset.TextileExamples >> Route.Explore scope
    , columns =
        [ { label = "Nom"
          , toValue = Table.StringValue .name
          , toCell = .name >> text
          }
        , { label = "Catégorie"
          , toValue = Table.StringValue .category
          , toCell = .category >> text
          }
        , { label = "Coût Environnemental"
          , toValue = Table.FloatValue <| getScore db >> Unit.impactToFloat
          , toCell =
                \example ->
                    let
                        score =
                            getScore db example |> Unit.impactToFloat

                        max =
                            db.textile.exampleProducts
                                |> List.map (getScore db >> Unit.impactToFloat)
                                |> List.maximum
                                |> Maybe.withDefault 0

                        percent =
                            score / max * 100
                    in
                    div [ class "d-flex justify-content-between align-items-center gap-2", style "min-width" "20vw" ]
                        [ div
                            [ classList [ ( "text-end", not detailed ) ]
                            , style "min-width" "80px"
                            ]
                            [ getScore db example
                                |> Unit.impactToFloat
                                |> Format.formatImpactFloat db.definitions.ecs
                            ]
                        , div [ class "progress", style "min-width" "calc(19vw - 80px)" ]
                            [ div
                                [ class "progress-bar bg-secondary"
                                , style "width" <| String.fromFloat percent ++ "%"
                                ]
                                []
                            ]
                        ]
          }
        ]
    }


getScore : Db -> ExampleProduct -> Unit.Impact
getScore db =
    .query
        >> Simulator.compute db
        >> Result.map (.impacts >> Impact.getImpact Definition.Ecs)
        >> Result.withDefault (Unit.impact 0)
