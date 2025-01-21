module Page.Explore.TextileExamples exposing (table)

import Data.Component as Component
import Data.Dataset as Dataset
import Data.Example exposing (Example)
import Data.Scope exposing (Scope)
import Data.Textile.Query exposing (Query)
import Data.Uuid as Uuid
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table as Table exposing (Table)
import Result.Extra as RE
import Route
import Static.Db exposing (Db)
import Views.Icon as Icon


table :
    Db
    -> { maxScore : Float, maxPer100g : Float }
    -> { detailed : Bool, scope : Scope }
    -> Table ( Example Query, { score : Float, per100g : Float } ) String msg
table db { maxScore, maxPer100g } { detailed, scope } =
    { filename = "examples"
    , toId = Tuple.first >> .id >> Uuid.toString
    , toRoute = Tuple.first >> .id >> Just >> Dataset.TextileExamples >> Route.Explore scope
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
        , { label = "Accessoires"
          , toValue = Table.NoValue
          , toCell =
                \( example, _ ) ->
                    example.query.trims
                        |> List.map (Component.itemToString db)
                        |> RE.combine
                        |> Result.map
                            (String.join ", "
                                >> (\s ->
                                        if String.isEmpty s then
                                            text "Aucun"

                                        else
                                            span [ class "cursor-help", title s ] [ text s ]
                                   )
                            )
                        |> Result.withDefault (text "Aucun")
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
                        , Route.href <| Route.TextileSimulatorExample id
                        , title <| "Charger " ++ name
                        ]
                        [ Icon.search ]
          }
        ]
    }
