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
import Views.Component.StagesBorder as StagesBorder
import Views.Table as Table


type Tab
    = DetailedImpactsTab
    | StagesImpactsTab
    | SubscoresTab


type alias Config msg =
    { activeImpactsTab : Tab
    , complementsImpact : Impact.ComplementsImpacts
    , impactDefinition : Definition
    , onStageClick : String -> msg
    , scoring : Scoring
    , session : Session
    , stagesImpacts : Impact.StagesImpacts
    , switchImpactsTab : Tab -> msg
    , total : Impacts
    }


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, complementsImpact, impactDefinition, onStageClick, scoring, session, stagesImpacts, switchImpactsTab, total } =
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

                StagesImpactsTab ->
                    [ { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.trims
                            , onClick <| onStageClick "trims-stage"
                            ]
                      , name = "Accessoires"
                      , value = stagesImpacts.trims
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.materials
                            , onClick <| onStageClick "materials-stage"
                            ]
                      , name = "Matières premières"
                      , value = stagesImpacts.materials
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.transform
                            , onClick <| onStageClick "transform-stage"
                            ]
                      , name = "Transformation"
                      , value = stagesImpacts.transform
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.packaging
                            , onClick <| onStageClick "packaging-stage"
                            ]
                      , name = "Emballage"
                      , value = stagesImpacts.packaging
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.transports
                            , onClick <| onStageClick "transport-stage"
                            ]
                      , name = "Transports"
                      , value = stagesImpacts.transports
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.distribution
                            , onClick <| onStageClick "distribution-stage"
                            ]
                      , name = "Distribution"
                      , value = stagesImpacts.distribution
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.usage
                            , onClick <| onStageClick "usage-stage"
                            ]
                      , name = "Utilisation"
                      , value = stagesImpacts.usage
                      }
                    , { entryAttributes =
                            [ StagesBorder.style Impact.stagesColors.endOfLife
                            , onClick <| onStageClick "end-of-life-stage"
                            ]
                      , name = "Fin de vie"
                      , value = stagesImpacts.endOfLife
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
                [ StagesImpactsTab
                , SubscoresTab
                , DetailedImpactsTab
                ]

             else
                [ StagesImpactsTab ]
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
createConfig session impactDefinition activeImpactsTab onStageClick switchImpactsTab =
    { activeImpactsTab = activeImpactsTab
    , complementsImpact = Impact.noComplementsImpacts
    , impactDefinition = impactDefinition
    , onStageClick = onStageClick
    , scoring = Scoring.empty
    , session = session
    , stagesImpacts = Impact.noStagesImpacts
    , switchImpactsTab = switchImpactsTab
    , total = Impact.empty
    }


forFood : Recipe.Results -> Config msg -> Config msg
forFood results config =
    { config
        | complementsImpact = results.recipe.totalComplementsImpact
        , scoring = results.scoring
        , stagesImpacts = Recipe.toStagesImpacts config.impactDefinition.trigram results
        , total = results.total
    }


forObject : Definitions -> Component.LifeCycle -> Config msg -> Config msg
forObject definitions lifeCycle config =
    { config
        | scoring = Component.computeScoring definitions lifeCycle
        , stagesImpacts =
            lifeCycle
                |> Component.stagesImpacts
                |> Impact.mapStages (Maybe.map (Impact.getImpact config.impactDefinition.trigram))
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
        , stagesImpacts =
            simulator
                |> TextileSimulator.toStagesImpacts config.impactDefinition.trigram
        , total = totalImpactsWithoutComplements
    }


tabToString : Tab -> String
tabToString tab =
    case tab of
        DetailedImpactsTab ->
            "Impacts"

        StagesImpactsTab ->
            "Étapes"

        SubscoresTab ->
            "Sous-scores"
