module Views.ImpactTabs exposing
    ( Config
    , Tab(..)
    , createConfig
    , forFood
    , forGeneric
    , forTextile
    , tabToString
    , view
    )

import Data.Complement as Complement
import Data.Component as Component
import Data.Food.Recipe as Recipe
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Scoring as Scoring exposing (Scoring)
import Data.Session as Session exposing (Session)
import Data.Stages as Stages
import Data.Textile.Simulator as TextileSimulator exposing (Simulator)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Views.CardTabs as CardTabs
import Views.Component.StagesBorder as StagesBorder
import Views.Table as Table


type Tab
    = DetailedImpactsTab
    | StagesImpactsTab
    | SubscoresTab


type alias Config msg =
    { activeImpactsTab : Tab
    , complementsImpact : Complement.ComplementsImpacts
    , impactDefinition : Definition
    , onStageClick : String -> msg
    , scoring : Scoring
    , session : Session
    , stagesImpacts : Impact.StagesImpacts
    , switchImpactsTab : Tab -> msg
    , total : Impacts
    }


detailedAccessNotice : Session -> String -> Html msg
detailedAccessNotice session notice =
    div [ class "card-body fs-7" ]
        [ p [ class "text-muted" ]
            [ text notice ]
        , p [ class "fw-bold" ]
            [ text "Comment y accéder\u{00A0}?" ]
        , ol [ class "ps-3" ]
            [ li [] [ text "S’identifier ou se créer un compte." ]
            , li [] [ text "Depuis votre compte, accepter les conditions d’utilisation des données Base empreinte et Ecoinvent." ]
            , li [] [ text "Revenir sur votre simulation en étant connecté et avec les conditions d’utilisation acceptées." ]
            ]
        , div [ class "text-center" ]
            [ if Session.isAuthenticated session then
                a [ class "btn btn-sm btn-outline-primary", Route.href Route.Auth ] [ text "Accéder à mon compte" ]

              else
                a [ class "btn btn-sm btn-outline-primary", Route.href Route.AuthSignup ] [ text "Créer un compte" ]
            ]
        ]


visibleTabs : Definition -> List Tab
visibleTabs impactDefinition =
    if impactDefinition.trigram == Definition.Ecs then
        [ StagesImpactsTab
        , SubscoresTab
        , DetailedImpactsTab
        ]

    else
        [ StagesImpactsTab ]


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, complementsImpact, impactDefinition, onStageClick, scoring, session, stagesImpacts, switchImpactsTab, total } =
    CardTabs.view
        { attrs = []
        , content =
            [ case activeImpactsTab of
                DetailedImpactsTab ->
                    if not <| Session.hasAccessToDetailedImpacts session then
                        detailedAccessNotice session "Les impacts détaillés ne sont pas accessibles."

                    else
                        total
                            |> Impact.getAggregatedScoreData definitions .ecoscoreData
                            |> List.map (\{ name, value } -> { entryAttributes = [], name = name, value = value })
                            |> (++)
                                [ -- Food ecosystemic services
                                  { entryAttributes = []
                                  , name = "Services écosystémiques"
                                  , value = Unit.impactToFloat (Complement.sumEcosystemicImpacts complementsImpact)
                                  }

                                -- Textile complements
                                , { entryAttributes = []
                                  , name = "Complément " ++ String.toLower Complement.labels.outOfEuropeEOL
                                  , value =
                                        complementsImpact.outOfEuropeEOL
                                            |> Maybe.withDefault Unit.noImpacts
                                            |> Unit.impactToFloat
                                  }
                                , { entryAttributes = []
                                  , name = "Complément " ++ String.toLower Complement.labels.microfibers
                                  , value =
                                        complementsImpact.microfibers
                                            |> Maybe.withDefault Unit.noImpacts
                                            |> Unit.impactToFloat
                                  }
                                , { entryAttributes = []
                                  , name = "Complément " ++ String.toLower Complement.labels.forest
                                  , value =
                                        complementsImpact.forest
                                            |> Maybe.withDefault Unit.noImpacts
                                            |> Unit.impactToFloat
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
                            [ StagesBorder.style Impact.stagesColors.assembly
                            , onClick <| onStageClick "assembly-stage"
                            ]
                      , name = "Assemblage"
                      , value = stagesImpacts.assembly
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
                    if not <| Session.hasAccessToDetailedImpacts session then
                        detailedAccessNotice session "Les sous-scores ne sont pas accessibles."

                    else
                        Table.percentageTable impactDefinition
                            [ { entryAttributes = [], name = "Climat", value = Unit.impactToFloat scoring.climate }
                            , { entryAttributes = [], name = "Biodiversité", value = Unit.impactToFloat scoring.biodiversity }
                            , { entryAttributes = [], name = "Santé environnementale", value = Unit.impactToFloat scoring.health }
                            , { entryAttributes = [], name = "Ressource", value = Unit.impactToFloat scoring.resources }
                            , { entryAttributes = []
                              , name = "Compléments"
                              , value = Unit.impactToFloat scoring.complements
                              }
                            ]
            ]
        , tabs =
            visibleTabs impactDefinition
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
    , complementsImpact = Complement.noComplementsImpacts
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


forGeneric : Definitions -> Component.LifeCycle -> Config msg -> Config msg
forGeneric definitions lifeCycle config =
    { config
        | complementsImpact =
            lifeCycle.production
                |> Component.extractComplementsImpacts
                |> Complement.mapComplements (Maybe.map (Impact.getImpact config.impactDefinition.trigram))
        , scoring = Component.computeScoring definitions lifeCycle
        , stagesImpacts =
            lifeCycle
                |> Component.stagesImpacts
                |> Stages.map (Maybe.map (Impact.getImpact config.impactDefinition.trigram))
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
                |> Scoring.compute definitions (Complement.getTotalComplementsImpacts simulator.complementsImpacts)
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
