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
import Data.Impact.Definition as Definition exposing (Definition, Definitions, Trigram)
import Data.Scoring as Scoring exposing (Scoring)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Unit as Unit
import Html exposing (..)
import Views.CardTabs as CardTabs
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
    , trigram : Trigram
    }


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, impactDefinition, switchImpactsTab, trigram, total, complementsImpact, scoring, stepsImpacts } =
    CardTabs.view
        { tabs =
            (if trigram == Definition.Ecs then
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
                        |> List.map (\{ name, value } -> ( name, value ))
                        |> (++)
                            [ -- Food complements
                              ( "Bonus de diversité agricole"
                              , -(Unit.impactToFloat complementsImpact.agroDiversity)
                              )
                            , ( "Bonus d'infrastructures agro-écologiques"
                              , -(Unit.impactToFloat complementsImpact.agroEcology)
                              )
                            , ( "Bonus conditions d'élevage"
                              , -(Unit.impactToFloat complementsImpact.animalWelfare)
                              )

                            -- Textile complements
                            , ( "Complément fin de vie hors-Europe"
                              , -(Unit.impactToFloat complementsImpact.outOfEuropeEOL)
                              )
                            ]
                        |> List.sortBy Tuple.second
                        |> List.reverse
                        |> Table.percentageTable impactDefinition

                StepImpactsTab ->
                    [ ( "Matières premières", stepsImpacts.materials )
                    , ( "Transformation", stepsImpacts.transform )
                    , ( "Emballage", stepsImpacts.packaging )
                    , ( "Transports", stepsImpacts.transports )
                    , ( "Distribution", stepsImpacts.distribution )
                    , ( "Utilisation", stepsImpacts.usage )
                    , ( "Fin de vie", stepsImpacts.endOfLife )
                    ]
                        |> List.filterMap
                            (\( label, maybeValue ) ->
                                maybeValue
                                    |> Maybe.map (\value -> Just ( label, Unit.impactToFloat value ))
                                    |> Maybe.withDefault Nothing
                            )
                        |> Table.percentageTable impactDefinition

                SubscoresTab ->
                    Table.percentageTable impactDefinition
                        [ ( "Climat", Unit.impactToFloat scoring.climate )
                        , ( "Biodiversité", Unit.impactToFloat scoring.biodiversity )
                        , ( "Santé environnementale", Unit.impactToFloat scoring.health )
                        , ( "Ressource", Unit.impactToFloat scoring.resources )
                        , ( "Compléments", -(Unit.impactToFloat scoring.complements) )
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
    , trigram = Definition.Ecs
    }


forFood : Definition.Trigram -> Recipe.Results -> Config msg -> Config msg
forFood trigram results config =
    { config
        | trigram = trigram
        , total = results.total
        , complementsImpact = results.recipe.totalComplementsImpact
        , scoring = results.scoring
        , stepsImpacts = Recipe.toStepsImpacts trigram results
    }


forTextile : Definitions -> Definition.Trigram -> Simulator -> Config msg -> Config msg
forTextile definitions trigram simulator config =
    let
        totalImpactsWithoutComplements =
            simulator.lifeCycle
                |> Array.map .impacts
                |> Array.toList
                |> Impact.sumImpacts
    in
    { config
        | trigram = trigram
        , total = totalImpactsWithoutComplements
        , complementsImpact = simulator.complementsImpacts
        , scoring =
            totalImpactsWithoutComplements
                |> Scoring.compute definitions (Impact.getTotalComplementsImpacts simulator.complementsImpacts)
        , stepsImpacts = simulator |> Simulator.toStepsImpacts trigram
    }
