module Page.Explore.FoodIngredients exposing (table)

import Data.Dataset as Dataset
import Data.Food.Db as FoodDb
import Data.Food.EcosystemicServices as EcosystemicServices
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
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


table : FoodDb.Db -> { detailed : Bool, scope : Scope } -> Table Ingredient String msg
table _ { detailed, scope } =
    { toId = .id >> Ingredient.idToString
    , toRoute = .id >> Just >> Dataset.FoodIngredients >> Route.Explore scope
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> Ingredient.idToString
          , toCell =
                \ingredient ->
                    if detailed then
                        code [] [ text (Ingredient.idToString ingredient.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.FoodIngredients (Just ingredient.id))) ]
                            [ code [] [ text (Ingredient.idToString ingredient.id) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue .name
          , toCell = .name >> text
          }
        , { label = "Catégories"
          , toValue = Table.StringValue <| .categories >> List.map IngredientCategory.toLabel >> String.join ","
          , toCell = .categories >> List.map (\c -> li [] [ text (IngredientCategory.toLabel c) ]) >> ul [ class "mb-0" ]
          }
        , { label = "Origine par défaut"
          , toValue = Table.StringValue <| .defaultOrigin >> Origin.toLabel
          , toCell = .defaultOrigin >> Origin.toLabel >> text
          }
        , { label = "Part non-comestible"
          , toValue = Table.FloatValue <| .inediblePart >> Split.toPercent
          , toCell =
                \{ inediblePart } ->
                    div [ classList [ ( "text-end", not detailed ) ] ]
                        [ inediblePart
                            |> Split.toPercent
                            |> Format.percent
                        , Link.smallPillExternal
                            [ href (Gitbook.publicUrlFromPath Gitbook.FoodInediblePart) ]
                            [ Icon.question ]
                        ]
          }
        , { label = "Rapport cru/cuit"
          , toValue = Table.FloatValue <| .rawToCookedRatio >> Unit.ratioToFloat
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
        , { label = "Procédé"
          , toValue = Table.StringValue <| .default >> .name >> Process.nameToString
          , toCell =
                \{ default } ->
                    div []
                        [ code [] [ text <| Process.codeToString default.code ]
                        , div [ class "cursor-help", title <| Process.nameToString default.name ]
                            [ text <| Process.nameToString default.name ]
                        , case default.comment of
                            Just comment ->
                                em [ class "cursor-help", title comment ] [ text comment ]

                            Nothing ->
                                text ""
                        ]
          }
        , { label = "Services écosystémiques"
          , toValue = Table.StringValue <| always "N/A"
          , toCell =
                \{ ecosystemicServices } ->
                    div [ class "overflow-scroll" ]
                        [ [ ( EcosystemicServices.labels.hedges, ecosystemicServices.hedges )
                          , ( EcosystemicServices.labels.plotSize, ecosystemicServices.plotSize )
                          , ( EcosystemicServices.labels.cropDiversity, ecosystemicServices.cropDiversity )
                          , ( EcosystemicServices.labels.permanentPasture, ecosystemicServices.permanentPasture )
                          , ( EcosystemicServices.labels.livestockDensity, ecosystemicServices.livestockDensity )
                          ]
                            |> List.map
                                (\( label, impact ) ->
                                    span []
                                        [ text <| label ++ ": "
                                        , Unit.impactToFloat impact
                                            |> Format.formatImpactFloat { unit = "Pts/kg", decimals = 2 }
                                        ]
                                )
                            |> div [ class "d-flex gap-2" ]
                        ]
          }
        ]
    }
