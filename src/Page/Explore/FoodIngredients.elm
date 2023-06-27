module Page.Explore.FoodIngredients exposing (table)

import Data.Dataset as Dataset
import Data.Food.Builder.Db as BuilderDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Ingredient.Category as IngredientCategory
import Data.Food.Origin as Origin
import Data.Food.Process as Process
import Data.Gitbook as Gitbook
import Data.Scope exposing (Scope)
import Data.Split as Split
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


table : BuilderDb.Db -> { detailed : Bool, scope : Scope } -> Table Ingredient String msg
table _ { detailed, scope } =
    { toId = .id >> Ingredient.idToString
    , toRoute = .id >> Just >> Dataset.FoodIngredients >> Route.Explore scope
    , rows =
        [ { label = "Identifiant"
          , toValue = .id >> Ingredient.idToString
          , toCell =
                \ingredient ->
                    if detailed then
                        code [] [ text (Ingredient.idToString ingredient.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.FoodIngredients (Just ingredient.id))) ]
                            [ code [] [ text (Ingredient.idToString ingredient.id) ] ]
          }
        , { label = "Nom"
          , toValue = .name
          , toCell = .name >> text
          }
        , { label = "Catégorie"
          , toValue = .category >> IngredientCategory.toLabel
          , toCell = .category >> IngredientCategory.toLabel >> text
          }
        , { label = "Origine par défaut"
          , toValue = .defaultOrigin >> Origin.toLabel
          , toCell = .defaultOrigin >> Origin.toLabel >> text
          }
        , { label = "Part non-comestible"
          , toValue = .inediblePart >> Split.toPercentString
          , toCell =
                \{ inediblePart } ->
                    div [ classList [ ( "text-end", not detailed ) ] ]
                        [ inediblePart
                            |> Split.toPercent
                            |> toFloat
                            |> Format.percent
                        , Link.smallPillExternal
                            [ href (Gitbook.publicUrlFromPath Gitbook.FoodInediblePart) ]
                            [ Icon.question ]
                        ]
          }
        , { label = "Rapport cru/cuit"
          , toValue = .rawToCookedRatio >> Unit.ratioToFloat >> String.fromFloat
          , toCell =
                \{ rawToCookedRatio } ->
                    div [ classList [ ( "text-end", not detailed ) ] ]
                        [ rawToCookedRatio
                            |> Unit.ratioToFloat
                            |> String.fromFloat
                            |> text
                        , Link.smallPillExternal
                            [ href (Gitbook.publicUrlFromPath Gitbook.FoodRawToCookedRatio) ]
                            [ Icon.question ]
                        ]
          }
        , { label = "Procédé conventionnel"
          , toValue = .default >> .name >> Process.nameToString
          , toCell = .default >> .name >> Process.nameToString >> text
          }
        , { label = "Procédé biologique"
          , toValue = .variants >> .organic >> Maybe.map (.process >> .name >> Process.nameToString) >> Maybe.withDefault "N/A"
          , toCell =
                \ingredient ->
                    div [ class "overflow-scroll" ]
                        [ p []
                            [ ingredient.variants.organic
                                |> Maybe.map (.process >> .name >> Process.nameToString)
                                |> Maybe.withDefault "N/A"
                                |> text
                            ]
                        , [ ( "Bonus agro-diversité", .agroDiversity )
                          , ( "Bonus agro-ecologie", .agroEcology )
                          , ( "Bonus conditions d'élevage", .animalWelfare )
                          ]
                            |> List.filterMap
                                (\( label, getter ) ->
                                    ingredient.variants.organic
                                        |> Maybe.map
                                            (.defaultBonuses
                                                >> getter
                                                >> (\split ->
                                                        span []
                                                            [ text <| label ++ ": "
                                                            , Format.splitAsPercentage split
                                                            ]
                                                   )
                                            )
                                )
                            |> div [ class "d-flex gap-2" ]
                        ]
          }
        ]
    }
