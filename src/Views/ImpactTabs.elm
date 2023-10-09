module Views.ImpactTabs exposing
    ( Config
    , Tab(..)
    , createConfig
    , forFood
    , forTextile
    , view
    )

import Array
import Data.Food.Recipe as Recipe
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Scoring as Scoring exposing (Scoring)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Unit as Unit
import Html exposing (..)
import Views.CardTabs as CardTabs
import Views.Component.StepsBorder as StepsBorder
import Views.Table as Table


type Tab
    = DetailedImpactsTab
    | StepImpactsTab
    | SubscoresTab


type alias Config msg =
    { activeImpactsTab : Tab
    , complementsImpact : Impact.ComplementsImpacts
    , impactDefinition : Definition
    , scoring : Scoring
    , stepsImpacts : Impact.StepsImpacts
    , switchImpactsTab : Tab -> msg
    , total : Impacts
    }


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, impactDefinition, switchImpactsTab, total, complementsImpact, scoring, stepsImpacts } =
    CardTabs.view
        { tabs =
            (if impactDefinition.trigram == Definition.Ecs then
                [ ( SubscoresTab, "Sous-scores" )
                , ( DetailedImpactsTab, "Impacts" )
                , ( StepImpactsTab, "Étapes" )
                ]

             else
                [ ( StepImpactsTab, "Étapes" ) ]
            )
                |> List.map
                    (\( tab, label ) ->
                        { label = label
                        , onTabClick = switchImpactsTab tab
                        , active = activeImpactsTab == tab
                        }
                    )
        , content =
            [ case activeImpactsTab of
                DetailedImpactsTab ->
                    total
                        |> Impact.getAggregatedScoreData definitions .ecoscoreData
                        |> List.map (\{ name, value } -> { name = name, value = value, entryStyle = Nothing })
                        |> (++)
                            [ -- Food complements
                              { name = "Bonus de diversité agricole"
                              , value = -(Unit.impactToFloat complementsImpact.agroDiversity)
                              , entryStyle = Nothing
                              }
                            , { name = "Bonus d'infrastructures agro-écologiques"
                              , value = -(Unit.impactToFloat complementsImpact.agroEcology)
                              , entryStyle = Nothing
                              }
                            , { name = "Bonus conditions d'élevage"
                              , value = -(Unit.impactToFloat complementsImpact.animalWelfare)
                              , entryStyle = Nothing
                              }

                            -- Textile complements
                            , { name = "Complément fin de vie hors-Europe"
                              , value = -(Unit.impactToFloat complementsImpact.outOfEuropeEOL)
                              , entryStyle = Nothing
                              }
                            ]
                        |> List.sortBy .value
                        |> List.reverse
                        |> Table.percentageTable impactDefinition

                StepImpactsTab ->
                    [ { name = "Matières premières", value = stepsImpacts.materials, entryStyle = Just (StepsBorder.style Impact.stepsColors.materials) }
                    , { name = "Transformation", value = stepsImpacts.transform, entryStyle = Just (StepsBorder.style Impact.stepsColors.transform) }
                    , { name = "Emballage", value = stepsImpacts.packaging, entryStyle = Just (StepsBorder.style Impact.stepsColors.packaging) }
                    , { name = "Transports", value = stepsImpacts.transports, entryStyle = Just (StepsBorder.style Impact.stepsColors.transports) }
                    , { name = "Distribution", value = stepsImpacts.distribution, entryStyle = Just (StepsBorder.style Impact.stepsColors.distribution) }
                    , { name = "Utilisation", value = stepsImpacts.usage, entryStyle = Just (StepsBorder.style Impact.stepsColors.usage) }
                    , { name = "Fin de vie", value = stepsImpacts.endOfLife, entryStyle = Just (StepsBorder.style Impact.stepsColors.endOfLife) }
                    ]
                        |> List.map
                            (\{ name, value, entryStyle } ->
                                { name = name
                                , value =
                                    value
                                        |> Maybe.map Unit.impactToFloat
                                        |> Maybe.withDefault 0
                                , entryStyle = entryStyle
                                }
                            )
                        |> Table.percentageTable impactDefinition

                SubscoresTab ->
                    Table.percentageTable impactDefinition
                        [ { name = "Climat", value = Unit.impactToFloat scoring.climate, entryStyle = Nothing }
                        , { name = "Biodiversité", value = Unit.impactToFloat scoring.biodiversity, entryStyle = Nothing }
                        , { name = "Santé environnementale", value = Unit.impactToFloat scoring.health, entryStyle = Nothing }
                        , { name = "Ressource", value = Unit.impactToFloat scoring.resources, entryStyle = Nothing }
                        , { name = "Compléments", value = -(Unit.impactToFloat scoring.complements), entryStyle = Nothing }
                        ]
            ]
        }


createConfig : Definition -> Tab -> (Tab -> msg) -> Config msg
createConfig impactDefinition activeImpactsTab switchImpactsTab =
    { activeImpactsTab = activeImpactsTab
    , complementsImpact = Impact.noComplementsImpacts
    , impactDefinition = impactDefinition
    , scoring = Scoring.empty
    , stepsImpacts = Impact.noStepsImpacts
    , switchImpactsTab = switchImpactsTab
    , total = Impact.empty
    }


forFood : Recipe.Results -> Config msg -> Config msg
forFood results config =
    { config
        | total = results.total
        , complementsImpact = results.recipe.totalComplementsImpact
        , scoring = results.scoring
        , stepsImpacts = Recipe.toStepsImpacts config.impactDefinition.trigram results
    }


forTextile : Definitions -> Simulator -> Config msg -> Config msg
forTextile definitions simulator config =
    let
        totalImpactsWithoutComplements =
            simulator.lifeCycle
                |> Array.map .impacts
                |> Array.toList
                |> Impact.sumImpacts
    in
    { config
        | total = totalImpactsWithoutComplements
        , complementsImpact = simulator.complementsImpacts
        , scoring =
            totalImpactsWithoutComplements
                |> Scoring.compute definitions (Impact.getTotalComplementsImpacts simulator.complementsImpacts)
        , stepsImpacts =
            simulator
                |> Simulator.toStepsImpacts config.impactDefinition.trigram
    }
