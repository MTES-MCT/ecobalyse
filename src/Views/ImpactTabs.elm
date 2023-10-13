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
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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
    , onStepClick : String -> msg
    , scoring : Scoring
    , stepsImpacts : Impact.StepsImpacts
    , switchImpactsTab : Tab -> msg
    , total : Impacts
    }


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, impactDefinition, switchImpactsTab, total, complementsImpact, onStepClick, scoring, stepsImpacts } =
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
                        |> List.map (\{ name, value } -> { name = name, value = value, entryAttributes = [] })
                        |> (++)
                            [ -- Food complements
                              { name = "Bonus de diversité agricole"
                              , value = -(Unit.impactToFloat complementsImpact.agroDiversity)
                              , entryAttributes = []
                              }
                            , { name = "Bonus d'infrastructures agro-écologiques"
                              , value = -(Unit.impactToFloat complementsImpact.agroEcology)
                              , entryAttributes = []
                              }
                            , { name = "Bonus conditions d'élevage"
                              , value = -(Unit.impactToFloat complementsImpact.animalWelfare)
                              , entryAttributes = []
                              }

                            -- Textile complements
                            , { name = "Complément fin de vie hors-Europe"
                              , value = -(Unit.impactToFloat complementsImpact.outOfEuropeEOL)
                              , entryAttributes = []
                              }
                            ]
                        |> List.sortBy .value
                        |> List.reverse
                        |> Table.percentageTable impactDefinition

                StepImpactsTab ->
                    [ { name = "Matières premières"
                      , value = stepsImpacts.materials
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.materials
                            , onClick <| onStepClick "materials-step"
                            ]
                      }
                    , { name = "Transformation"
                      , value = stepsImpacts.transform
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.transform
                            , onClick <| onStepClick "transform-step"
                            ]
                      }
                    , { name = "Emballage"
                      , value = stepsImpacts.packaging
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.packaging
                            , onClick <| onStepClick "packaging-step"
                            ]
                      }
                    , { name = "Transports"
                      , value = stepsImpacts.transports
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.transports
                            , onClick <| onStepClick "transport-step"
                            ]
                      }
                    , { name = "Distribution"
                      , value = stepsImpacts.distribution
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.distribution
                            , onClick <| onStepClick "distribution-step"
                            ]
                      }
                    , { name = "Utilisation"
                      , value = stepsImpacts.usage
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.usage
                            , onClick <| onStepClick "usage-step"
                            ]
                      }
                    , { name = "Fin de vie"
                      , value = stepsImpacts.endOfLife
                      , entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.endOfLife
                            , onClick <| onStepClick "end-of-life-step"
                            ]
                      }
                    ]
                        |> List.map
                            (\{ name, value, entryAttributes } ->
                                { name = name
                                , value =
                                    value
                                        |> Maybe.map Unit.impactToFloat
                                        |> Maybe.withDefault 0
                                , entryAttributes = style "cursor" "pointer" :: entryAttributes
                                }
                            )
                        |> Table.percentageTable impactDefinition

                SubscoresTab ->
                    Table.percentageTable impactDefinition
                        [ { name = "Climat", value = Unit.impactToFloat scoring.climate, entryAttributes = [] }
                        , { name = "Biodiversité", value = Unit.impactToFloat scoring.biodiversity, entryAttributes = [] }
                        , { name = "Santé environnementale", value = Unit.impactToFloat scoring.health, entryAttributes = [] }
                        , { name = "Ressource", value = Unit.impactToFloat scoring.resources, entryAttributes = [] }
                        , { name = "Compléments", value = -(Unit.impactToFloat scoring.complements), entryAttributes = [] }
                        ]
            ]
        }


createConfig : Definition -> Tab -> (String -> msg) -> (Tab -> msg) -> Config msg
createConfig impactDefinition activeImpactsTab onStepClick switchImpactsTab =
    { activeImpactsTab = activeImpactsTab
    , complementsImpact = Impact.noComplementsImpacts
    , impactDefinition = impactDefinition
    , onStepClick = onStepClick
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
