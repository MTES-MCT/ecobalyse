module Views.Comparator exposing
    ( ComparisonType(..)
    , view
    )

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Session as Session exposing (Session)
import Data.Textile.Simulator as Simulator
import Data.Unit as Unit
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Result.Extra as RE
import Set
import Views.Alert as Alert
import Views.Container as Container


type alias Config msg =
    { comparisonType : ComparisonType
    , impact : Definition
    , selectAll : msg
    , selectNone : msg
    , session : Session
    , switchComparisonType : ComparisonType -> msg
    , toggle : Bookmark -> Bool -> msg
    }


type ComparisonType
    = IndividualImpacts
    | Steps
    | Subscores
    | Total


type alias ChartsData =
    { label : String
    , impacts : Impact.Impacts
    , complementsImpact : Impact.ComplementsImpacts
    , stepsImpacts : Impact.StepsImpacts
    }


view : Config msg -> Html msg
view config =
    Container.fluid []
        [ div [ class "row" ]
            [ sidebarView config
                |> div [ class "col-lg-4 border-end fs-7 p-0" ]
            , comparatorView config
                |> div [ class "col-lg-8 px-4 py-2 overflow-hidden", style "min-height" "500px" ]
            ]
        ]


sidebarView : Config msg -> List (Html msg)
sidebarView { session, toggle, selectAll, selectNone } =
    [ div [ class "p-2 ps-3 mb-0 text-muted" ]
        [ text "Sélectionnez des simulations pour les comparer"
        ]
    , div [ class "text-center" ]
        [ button [ class "btn btn-sm btn-link pt-0", onClick selectAll ] [ text "tout sélectionner" ]
        , button [ class "btn btn-sm btn-link pt-0", onClick selectNone ] [ text "tout désélectionner" ]
        ]
    , session.store.bookmarks
        |> List.map
            (\bookmark ->
                let
                    ( description, isCompared ) =
                        ( bookmark
                            |> Bookmark.toQueryDescription session.db
                        , session.store.comparedSimulations
                            |> Set.member (Bookmark.toId bookmark)
                        )
                in
                label
                    [ class "form-check-label list-group-item text-nowrap ps-3"
                    , title description
                    ]
                    [ input
                        [ type_ "checkbox"
                        , class "form-check-input"
                        , onCheck (toggle bookmark)
                        , checked isCompared
                        ]
                        []
                    , span [ class "ps-2" ]
                        [ span [ class "me-2 fw-500" ] [ text bookmark.name ]
                        , if description /= bookmark.name then
                            span [ class "text-muted fs-7" ] [ text description ]

                          else
                            text ""
                        ]
                    ]
            )
        |> div [ class "list-group list-group-flush overflow-x-hidden" ]
    ]


addToComparison : Session -> String -> Bookmark.Query -> Result String ChartsData
addToComparison session label query =
    case query of
        Bookmark.Food foodQuery ->
            foodQuery
                |> Recipe.compute session.db
                |> Result.map
                    (\( _, { recipe, total } as results ) ->
                        { label = label
                        , impacts = total
                        , complementsImpact = recipe.totalComplementsImpact
                        , stepsImpacts =
                            results
                                |> Recipe.toStepsImpacts Definition.Ecs
                        }
                    )

        Bookmark.Textile textileQuery ->
            textileQuery
                |> Simulator.compute session.db
                |> Result.map
                    (\simulator ->
                        { label = label
                        , impacts = simulator.impacts
                        , complementsImpact = simulator.complementsImpacts
                        , stepsImpacts =
                            simulator
                                |> Simulator.toStepsImpacts Definition.Ecs
                                |> Impact.divideStepsImpactsBy (Unit.durabilityToFloat simulator.durability)
                        }
                    )


comparatorView : Config msg -> List (Html msg)
comparatorView config =
    let
        charts =
            config.session.store.bookmarks
                |> List.filterMap
                    (\bookmark ->
                        if Set.member (Bookmark.toId bookmark) config.session.store.comparedSimulations then
                            Just (addToComparison config.session bookmark.name bookmark.query)

                        else
                            Nothing
                    )
                |> RE.combine
    in
    [ ((if Session.isAuthenticated config.session then
            [ ( "Sous-scores", Subscores )
            , ( "Impacts", IndividualImpacts )
            ]

        else
            []
       )
        ++ [ ( "Étapes", Steps )
           , ( "Total", Total )
           ]
      )
        |> List.map
            (\( label, toComparisonType ) ->
                li [ class "TabsTab nav-item", classList [ ( "active", config.comparisonType == toComparisonType ) ] ]
                    [ button
                        [ class "nav-link no-outline border-top-0 py-1"
                        , classList [ ( "active", config.comparisonType == toComparisonType ) ]
                        , onClick (config.switchComparisonType toComparisonType)
                        ]
                        [ text label ]
                    ]
            )
        |> ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-3 mt-2 px-2" ]
    , case charts of
        Ok [] ->
            p [ class "d-flex h-100 justify-content-center align-items-center pb-5" ]
                [ text "Sélectionnez une ou plusieurs simulations pour les comparer" ]

        Ok chartsData ->
            let
                data =
                    case config.comparisonType of
                        IndividualImpacts ->
                            dataForIndividualImpacts config.session.db.definitions chartsData

                        Subscores ->
                            dataForSubscoresImpacts config.session.db.definitions chartsData

                        Steps ->
                            dataForSteps chartsData

                        Total ->
                            dataForTotalImpacts chartsData
            in
            div
                [ class "h-100"
                , class
                    (case config.comparisonType of
                        IndividualImpacts ->
                            "individual-impacts"

                        Subscores ->
                            "grouped-impacts"

                        Steps ->
                            "steps-impacts"

                        Total ->
                            "total-impacts"
                    )
                ]
                [ node "chart-food-comparator"
                    [ attribute "data" data ]
                    []
                ]

        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = Just "Erreur"
                , content = [ text error ]
                }
    ]


dataForIndividualImpacts : Definitions -> List ChartsData -> String
dataForIndividualImpacts definitions chartsData =
    let
        labelToOrder =
            [ "Changement climatique"
            , "Biodiversité locale"
            , "Acidification"
            , "Eutrophisation terrestre"
            , "Eutrophisation eaux douces"
            , "Eutrophisation marine"
            , "Écotoxicité de l'eau douce, corrigée"
            , "Utilisation des sols"
            , "Appauvrissement de la couche d'ozone"
            , "Radiations ionisantes"
            , "Formation d'ozone photochimique"
            , "Toxicité humaine - non-cancer, corrigée"
            , "Toxicité humaine - cancer, corrigée"
            , "Particules"
            , "Utilisation de ressources en eau"
            , "Utilisation de ressources fossiles"
            , "Utilisation de ressources minérales et métalliques"
            ]
                |> List.indexedMap (\index label -> ( label, index ))
                |> Dict.fromList

        labelComparison entry1 entry2 =
            let
                getOrder entry =
                    Dict.get entry.name labelToOrder

                label1Order =
                    getOrder entry1

                label2Order =
                    getOrder entry2
            in
            case ( label1Order, label2Order ) of
                ( Just index1, Just index2 ) ->
                    if index1 > index2 then
                        GT

                    else
                        LT

                _ ->
                    EQ
    in
    chartsData
        |> List.map
            (\{ label, impacts, complementsImpact } ->
                let
                    complementImpacts =
                        Impact.complementsImpactAsChartEntries complementsImpact

                    entries =
                        impacts
                            |> Impact.getAggregatedScoreData definitions .ecoscoreData
                            |> List.sortWith labelComparison

                    reversed =
                        complementImpacts
                            ++ entries
                            |> List.reverse
                in
                Encode.object
                    [ ( "label", Encode.string label )
                    , ( "data", Encode.list Impact.encodeAggregatedScoreChartEntry reversed )
                    ]
            )
        |> Encode.list identity
        |> Encode.encode 0


dataForSubscoresImpacts : Definitions -> List ChartsData -> String
dataForSubscoresImpacts definitions chartsData =
    chartsData
        |> List.map
            (\{ label, impacts, complementsImpact } ->
                let
                    complementImpacts =
                        Impact.totalComplementsImpactAsChartEntry complementsImpact

                    entries =
                        impacts
                            |> Impact.toProtectionAreas definitions
                            |> (\{ climate, biodiversity, health, resources } ->
                                    List.reverse
                                        [ complementImpacts
                                        , { name = "Climat", color = "#9025be", value = Unit.impactToFloat climate }
                                        , { name = "Biodiversité", color = "#00b050", value = Unit.impactToFloat biodiversity }
                                        , { name = "Santé environnementale", color = "#ffc000", value = Unit.impactToFloat health }
                                        , { name = "Ressource", color = "#0070c0", value = Unit.impactToFloat resources }
                                        ]
                               )
                in
                Encode.object
                    [ ( "label", Encode.string label )
                    , ( "data", Encode.list Impact.encodeAggregatedScoreChartEntry entries )
                    ]
            )
        |> Encode.list identity
        |> Encode.encode 0


dataForSteps : List ChartsData -> String
dataForSteps chartsData =
    chartsData
        |> List.map
            (\{ label, stepsImpacts } ->
                Encode.object
                    [ ( "label", Encode.string label )
                    , ( "data"
                      , stepsImpacts
                            |> Impact.stepsImpactsAsChartEntries
                            |> List.reverse
                            |> Encode.list Impact.encodeAggregatedScoreChartEntry
                      )
                    ]
            )
        |> Encode.list identity
        |> Encode.encode 0


dataForTotalImpacts : List ChartsData -> String
dataForTotalImpacts chartsData =
    chartsData
        |> List.map
            (\{ label, impacts } ->
                Encode.object
                    [ ( "label", Encode.string label )
                    , ( "data"
                      , Encode.list Impact.encodeAggregatedScoreChartEntry
                            [ { name = "Impact total"
                              , color = "#333333"
                              , value =
                                    impacts
                                        |> Impact.getImpact Definition.Ecs
                                        |> Unit.impactToFloat
                              }
                            ]
                      )
                    ]
            )
        |> Encode.list identity
        |> Encode.encode 0
