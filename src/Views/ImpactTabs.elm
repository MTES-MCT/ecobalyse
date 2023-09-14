module Views.ImpactTabs exposing
    ( Config
    , Tab(..)
    , configForFood
    , configForTextile
    , createConfig
    , view
    )

import Array
import Data.Food.Recipe as Recipe
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions, Trigram)
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
    , scoring : Scoring
    , steps : Impact.StepsImpacts
    , switchImpactsTab : Tab -> msg
    , total : Impacts
    , totalComplementsImpact : Impact.ComplementsImpacts
    , trigram : Trigram
    }


view : Definitions -> Config msg -> Html msg
view definitions { activeImpactsTab, switchImpactsTab, trigram, total, totalComplementsImpact, scoring, steps } =
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
                            [ ( "Bonus de diversité agricole"
                              , -(Unit.impactToFloat totalComplementsImpact.agroDiversity)
                              )
                            , ( "Bonus d'infrastructures agro-écologiques"
                              , -(Unit.impactToFloat totalComplementsImpact.agroEcology)
                              )
                            , ( "Bonus conditions d'élevage"
                              , -(Unit.impactToFloat totalComplementsImpact.animalWelfare)
                              )
                            ]
                        |> List.sortBy Tuple.second
                        |> List.reverse
                        |> Table.percentageTable

                StepImpactsTab ->
                    [ ( "Matières premières", steps.materials )
                    , ( "Transformation", steps.transform )
                    , ( "Emballage", steps.packaging )
                    , ( "Transports", steps.transports )
                    , ( "Distribution", steps.distribution )
                    , ( "Utilisation", steps.usage )
                    , ( "Fin de vie", steps.endOfLife )
                    ]
                        |> List.filterMap
                            (\( label, maybeValue ) ->
                                maybeValue
                                    |> Maybe.map (\value -> Just ( label, Unit.impactToFloat value ))
                                    |> Maybe.withDefault Nothing
                            )
                        |> Table.percentageTable

                SubscoresTab ->
                    Table.percentageTable
                        [ ( "Climat", Unit.impactToFloat scoring.climate )
                        , ( "Biodiversité", Unit.impactToFloat scoring.biodiversity )
                        , ( "Santé environnementale", Unit.impactToFloat scoring.health )
                        , ( "Ressource", Unit.impactToFloat scoring.resources )
                        , ( "Bonus", -(Unit.impactToFloat scoring.complements) )
                        ]
            ]
        }


createConfig : Tab -> (Tab -> msg) -> Config msg
createConfig activeImpactsTab switchImpactsTab =
    { activeImpactsTab = activeImpactsTab
    , switchImpactsTab = switchImpactsTab
    , trigram = Definition.Ecs
    , total = Impact.empty
    , totalComplementsImpact = Impact.noComplementsImpacts
    , scoring = Scoring.empty
    , steps = Impact.noStepsImpacts
    }


configForFood : Definition.Trigram -> Recipe.Results -> Config msg -> Config msg
configForFood trigram results config =
    { config
        | trigram = trigram
        , total = results.total
        , totalComplementsImpact = results.recipe.totalComplementsImpact
        , scoring = results.scoring
        , steps = Recipe.toStepsImpacts trigram results
    }


configForTextile : Definitions -> Definition.Trigram -> Simulator -> Config msg -> Config msg
configForTextile definitions trigram simulator config =
    let
        -- TODO: compute the complements once we have them in the database
        totalComplementsImpact =
            Impact.noComplementsImpacts

        totalImpactsWithoutComplements =
            simulator.lifeCycle
                |> Array.map .impacts
                |> Array.toList
                |> Impact.sumImpacts
    in
    { config
        | trigram = trigram
        , total = totalImpactsWithoutComplements
        , totalComplementsImpact = totalComplementsImpact
        , scoring =
            totalImpactsWithoutComplements
                |> Scoring.compute definitions totalComplementsImpact.total
        , steps = Simulator.toStepsImpacts trigram simulator
    }
