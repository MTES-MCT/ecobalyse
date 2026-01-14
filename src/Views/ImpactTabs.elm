module Views.ImpactTabs exposing
    ( Config
    , Tab(..)
    , createConfig
    , forFood
    , forObject
    , forTextile
    , tabToString
    , view
    )

import Data.Component as Component
import Data.Food.Recipe as Recipe
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Scoring as Scoring exposing (Scoring)
import Data.Session as Session exposing (Session)
import Data.Textile.Simulator as TextileSimulator exposing (Simulator)
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
    , session : Session
    , stepsImpacts : Impact.StepsImpacts
    , switchImpactsTab : Tab -> msg
    , total : Impacts
    }


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, complementsImpact, impactDefinition, onStepClick, scoring, session, stepsImpacts, switchImpactsTab, total } =
    CardTabs.view
        { attrs = []
        , content =
            [ case activeImpactsTab of
                DetailedImpactsTab ->
                    total
                        |> Impact.getAggregatedScoreData definitions .ecoscoreData
                        |> List.map (\{ name, value } -> { entryAttributes = [], name = name, value = value })
                        |> (++)
                            [ -- Food ecosystemic services
                              { entryAttributes = []
                              , name = "Services écosystémiques"
                              , value = -(Unit.impactToFloat (Impact.sumEcosystemicImpacts complementsImpact))
                              }

                            -- Textile complements
                            , { entryAttributes = []
                              , name = "Complément export hors-Europe"
                              , value = -(Unit.impactToFloat complementsImpact.outOfEuropeEOL)
                              }
                            , { entryAttributes = []
                              , name = "Complément microfibres"
                              , value = -(Unit.impactToFloat complementsImpact.microfibers)
                              }
                            ]
                        |> List.sortBy .value
                        |> List.reverse
                        |> Table.percentageTable impactDefinition

                StepImpactsTab ->
                    [ { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.trims
                            , onClick <| onStepClick "trims-step"
                            ]
                      , name = "Accessoires"
                      , value = stepsImpacts.trims
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.materials
                            , onClick <| onStepClick "materials-step"
                            ]
                      , name = "Matières premières"
                      , value = stepsImpacts.materials
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.transform
                            , onClick <| onStepClick "transform-step"
                            ]
                      , name = "Transformation"
                      , value = stepsImpacts.transform
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.packaging
                            , onClick <| onStepClick "packaging-step"
                            ]
                      , name = "Emballage"
                      , value = stepsImpacts.packaging
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.transports
                            , onClick <| onStepClick "transport-step"
                            ]
                      , name = "Transports"
                      , value = stepsImpacts.transports
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.distribution
                            , onClick <| onStepClick "distribution-step"
                            ]
                      , name = "Distribution"
                      , value = stepsImpacts.distribution
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.usage
                            , onClick <| onStepClick "usage-step"
                            ]
                      , name = "Utilisation"
                      , value = stepsImpacts.usage
                      }
                    , { entryAttributes =
                            [ StepsBorder.style Impact.stepsColors.endOfLife
                            , onClick <| onStepClick "end-of-life-step"
                            ]
                      , name = "Fin de vie"
                      , value = stepsImpacts.endOfLife
                      }
                    ]
                        |> List.map
                            (\{ entryAttributes, name, value } ->
                                { entryAttributes = style "cursor" "pointer" :: entryAttributes
                                , name = name
                                , value =
                                    value
                                        |> Maybe.map Unit.impactToFloat
                                        |> Maybe.withDefault 0
                                }
                            )
                        |> Table.percentageTable impactDefinition

                SubscoresTab ->
                    Table.percentageTable impactDefinition
                        [ { entryAttributes = [], name = "Climat", value = Unit.impactToFloat scoring.climate }
                        , { entryAttributes = [], name = "Biodiversité", value = Unit.impactToFloat scoring.biodiversity }
                        , { entryAttributes = [], name = "Santé environnementale", value = Unit.impactToFloat scoring.health }
                        , { entryAttributes = [], name = "Ressource", value = Unit.impactToFloat scoring.resources }
                        , { entryAttributes = [], name = "Compléments", value = -(Unit.impactToFloat scoring.complements) }
                        ]
            ]
        , tabs =
            (if impactDefinition.trigram == Definition.Ecs && Session.isAuthenticated session then
                [ StepImpactsTab
                , SubscoresTab
                , DetailedImpactsTab
                ]

             else
                [ StepImpactsTab ]
            )
                |> List.map
                    (\tab ->
                        { active = activeImpactsTab == tab
                        , label = text <| tabToString tab
                        , onTabClick = switchImpactsTab tab
                        }
                    )
        }


createConfig : Session -> Definition -> Tab -> (String -> msg) -> (Tab -> msg) -> Config msg
createConfig session impactDefinition activeImpactsTab onStepClick switchImpactsTab =
    { activeImpactsTab = activeImpactsTab
    , complementsImpact = Impact.noComplementsImpacts
    , impactDefinition = impactDefinition
    , onStepClick = onStepClick
    , scoring = Scoring.empty
    , session = session
    , stepsImpacts = Impact.noStepsImpacts
    , switchImpactsTab = switchImpactsTab
    , total = Impact.empty
    }


forFood : Recipe.Results -> Config msg -> Config msg
forFood results config =
    { config
        | complementsImpact = results.recipe.totalComplementsImpact
        , scoring = results.scoring
        , stepsImpacts = Recipe.toStepsImpacts config.impactDefinition.trigram results
        , total = results.total
    }


forObject : Definitions -> Component.LifeCycle -> Config msg -> Config msg
forObject definitions lifeCycle config =
    let
        stageStats =
            Component.stagesImpacts lifeCycle
    in
    { config
        | scoring = Component.computeScoring definitions lifeCycle
        , stepsImpacts =
            { distribution = Nothing
            , endOfLife =
                stageStats.endOfLife
                    |> Impact.getImpact config.impactDefinition.trigram
                    |> Just
            , materials =
                stageStats.material
                    |> Impact.getImpact config.impactDefinition.trigram
                    |> Just
            , packaging = Nothing
            , transform =
                stageStats.transformation
                    |> Impact.getImpact config.impactDefinition.trigram
                    |> Just
            , transports =
                stageStats.transports
                    |> Impact.getImpact config.impactDefinition.trigram
                    |> Just
            , trims = Nothing
            , usage =
                stageStats.use
                    |> Impact.getImpact config.impactDefinition.trigram
                    |> Just
            }
        , total = Component.sumLifeCycleImpacts lifeCycle
    }


forTextile : Definitions -> Simulator -> Config msg -> Config msg
forTextile definitions simulator config =
    let
        totalImpactsWithoutComplements =
            TextileSimulator.getTotalImpactsWithoutComplements simulator
    in
    { config
        | complementsImpact = simulator.complementsImpacts
        , scoring =
            totalImpactsWithoutComplements
                |> Scoring.compute definitions (Impact.getTotalComplementsImpacts simulator.complementsImpacts)
        , stepsImpacts =
            simulator
                |> TextileSimulator.toStepsImpacts config.impactDefinition.trigram
        , total = totalImpactsWithoutComplements
    }


tabToString : Tab -> String
tabToString tab =
    case tab of
        DetailedImpactsTab ->
            "Impacts"

        StepImpactsTab ->
            "Étapes"

        SubscoresTab ->
            "Sous-scores"
