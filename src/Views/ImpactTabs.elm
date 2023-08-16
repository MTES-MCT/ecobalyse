module Views.ImpactTabs exposing (Config, Tab(..), view)

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions, Trigram)
import Data.Scoring exposing (Scoring)
import Data.Unit as Unit
import Html exposing (..)
import Views.CardTabs as CardTabs
import Views.Table as Table


type Tab
    = DetailedImpactsTab
    | StepImpactsTab
    | SubscoresTab


type alias Config =
    { trigram : Trigram
    , total : Impacts
    , totalComplementsImpact : Impact.ComplementsImpacts
    , scoring : Scoring
    , steps : Steps
    }


type alias Steps =
    { materials : Unit.Impact
    , transform : Unit.Impact
    , packaging : Unit.Impact
    , transports : Unit.Impact
    , distribution : Unit.Impact
    , usage : Unit.Impact
    , endOfLife : Unit.Impact
    }


view : Definitions -> Tab -> (Tab -> msg) -> Config -> Html msg
view definitions activeImpactsTab switchImpactsTab { trigram, total, totalComplementsImpact, scoring, steps } =
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
                    let
                        toFloat =
                            Unit.impactToFloat
                    in
                    Table.percentageTable
                        [ ( "Matières premières", toFloat steps.materials )
                        , ( "Transformation", toFloat steps.transform )
                        , ( "Emballage", toFloat steps.packaging )
                        , ( "Transports", toFloat steps.transports )
                        , ( "Distribution", toFloat steps.distribution )
                        , ( "Utilisation", toFloat steps.usage )
                        , ( "Fin de vie", toFloat steps.endOfLife )
                        ]

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
