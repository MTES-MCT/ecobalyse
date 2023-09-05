module Views.Comparator exposing
    ( DisplayChoice(..)
    , FoodComparisonUnit(..)
    , comparator
    , foodOptions
    , textileOptions
    )

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Db as FoodDb
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Dict
import Duration exposing (Duration)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Result.Extra as RE
import Set
import Views.Alert as Alert
import Views.Container as Container
import Views.Textile.ComparativeChart as TextileComparativeChart


type alias Config msg =
    { session : Session
    , impact : Definition
    , options : Options msg
    , toggle : Bookmark -> Bool -> msg
    , chartHovering : TextileComparativeChart.Stacks
    , onChartHover : TextileComparativeChart.Stacks -> msg
    }


type Options msg
    = Food (FoodOptions msg)
    | Textile TextileOptions


type FoodComparisonUnit
    = PerItem
    | PerKgOfProduct


type DisplayChoice
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


type alias FoodOptions msg =
    { comparisonUnit : FoodComparisonUnit
    , switchComparisonUnit : FoodComparisonUnit -> msg
    , displayChoice : DisplayChoice
    , switchDisplayChoice : DisplayChoice -> msg
    , db : FoodDb.Db
    }


type alias TextileOptions =
    { funit : Unit.Functional
    , daysOfWear : Duration
    }


foodOptions : FoodOptions msg -> Options msg
foodOptions =
    Food


textileOptions : TextileOptions -> Options msg
textileOptions =
    Textile


comparator : Config msg -> Html msg
comparator ({ session, options, toggle } as config) =
    Container.fluid []
        [ div [ class "row" ]
            [ div [ class "col-lg-4 border-end fs-7 p-0" ]
                [ p [ class "p-2 ps-3 pb-1 mb-0 text-muted" ]
                    [ text "Sélectionnez jusqu'à "
                    , strong [] [ text (String.fromInt Session.maxComparedSimulations) ]
                    , text " simulations pour les comparer\u{00A0}:"
                    ]
                , session.store.bookmarks
                    |> List.map
                        (\bookmark ->
                            let
                                ( description, isCompared ) =
                                    ( bookmark
                                        |> Bookmark.toQueryDescription
                                            { foodDb = session.foodDb, textileDb = session.textileDb }
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
                                    , disabled
                                        (not isCompared
                                            && Set.size session.store.comparedSimulations
                                            >= Session.maxComparedSimulations
                                        )
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
                    |> div
                        [ class "list-group list-group-flush overflow-x-hidden"
                        ]
                ]
            , div [ class "col-lg-8 px-4 py-2 overflow-hidden", style "min-height" "500px" ]
                [ case options of
                    Food foodOptions_ ->
                        foodComparatorView config foodOptions_

                    Textile textileOptions_ ->
                        textileComparatorView config textileOptions_
                ]
            ]
        ]


foodComparatorView : Config msg -> FoodOptions msg -> Html msg
foodComparatorView { session } { comparisonUnit, switchComparisonUnit, displayChoice, switchDisplayChoice, db } =
    let
        addToComparison ( id, label, foodQuery ) =
            if Set.member id session.store.comparedSimulations then
                foodQuery
                    |> Recipe.compute db
                    |> Result.map
                        (\( _, { perKg, recipe, total, totalMass } as results ) ->
                            let
                                stepsImpactsPerProduct =
                                    results
                                        |> Recipe.toStepsImpacts Definition.Ecs
                            in
                            case comparisonUnit of
                                PerItem ->
                                    { label = label
                                    , impacts = total
                                    , complementsImpact = recipe.totalComplementsImpact
                                    , stepsImpacts = stepsImpactsPerProduct
                                    }

                                PerKgOfProduct ->
                                    { label = label
                                    , impacts = perKg
                                    , complementsImpact = recipe.totalComplementsImpactPerKg
                                    , stepsImpacts =
                                        stepsImpactsPerProduct
                                            |> Impact.stepsImpactsPerKg totalMass
                                    }
                        )
                    |> Just

            else
                Nothing

        charts =
            session.store.bookmarks
                |> Bookmark.toFoodQueries
                |> List.filterMap addToComparison
                |> RE.combine

        unitChoiceRadio caption current to =
            label [ class "form-check-label d-flex align-items-center gap-1 fs-8" ]
                [ input
                    [ type_ "radio"
                    , class "form-check-input"
                    , name "unit"
                    , checked <| current == to
                    , onInput <| always (switchComparisonUnit to)
                    ]
                    []
                , text caption
                ]
    in
    div []
        [ h2 [ class "h5 text-center" ]
            [ text "Composition du score d'impact des recettes sélectionnées" ]
        , div [ class "row gap-2 gap-lg-0" ]
            [ div [ class "col-xl-5" ]
                [ div [ class "d-flex align-items-center gap-2 lh-lg pt-2" ]
                    [ strong [] [ text "Unité" ]
                    , unitChoiceRadio "produit" comparisonUnit PerItem
                    , unitChoiceRadio "kg de produit" comparisonUnit PerKgOfProduct
                    ]
                ]
            , div [ class "col-xl-7" ]
                [ [ ( "Sous-scores", Subscores )
                  , ( "Impacts", IndividualImpacts )
                  , ( "Étapes", Steps )
                  , ( "Total", Total )
                  ]
                    |> List.map
                        (\( label, toDisplayChoice ) ->
                            li [ class "TabsTab nav-item", classList [ ( "active", displayChoice == toDisplayChoice ) ] ]
                                [ button
                                    [ class "nav-link no-outline border-top-0 py-1"
                                    , classList [ ( "active", displayChoice == toDisplayChoice ) ]
                                    , onClick (switchDisplayChoice toDisplayChoice)
                                    ]
                                    [ text label ]
                                ]
                        )
                    |> ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-3 mt-2 px-2" ]
                ]
            ]
        , case charts of
            Ok [] ->
                emptyChartsMessage

            Ok chartsData ->
                let
                    data =
                        case displayChoice of
                            IndividualImpacts ->
                                dataForIndividualImpacts session.foodDb.impactDefinitions chartsData

                            Subscores ->
                                dataForSubscoresImpacts session.foodDb.impactDefinitions chartsData

                            Steps ->
                                dataForSteps chartsData

                            Total ->
                                dataForTotalImpacts chartsData
                in
                div
                    [ class "h-100"
                    , class
                        (case displayChoice of
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
            (\{ label, impacts, complementsImpact } ->
                let
                    totalImpact =
                        impacts
                            |> Impact.getImpact Definition.Ecs
                            |> Unit.impactToFloat

                    complementImpacts =
                        Impact.totalComplementsImpactAsChartEntry complementsImpact
                            |> (\entry ->
                                    -- In this particular case we want the bonus as a positive value, displayed "on top" of the bar
                                    -- in white
                                    { entry | value = -entry.value, color = "#ffffff" }
                               )

                    entries =
                        List.reverse
                            [ { name = "Impact total", color = "#333333", value = totalImpact }
                            , complementImpacts
                            ]
                in
                Encode.object
                    [ ( "label", Encode.string label )
                    , ( "data", Encode.list Impact.encodeAggregatedScoreChartEntry entries )
                    ]
            )
        |> Encode.list identity
        |> Encode.encode 0


textileComparatorView : Config msg -> TextileOptions -> Html msg
textileComparatorView { session, impact, chartHovering, onChartHover } { funit, daysOfWear } =
    div []
        [ case getTextileChartEntries session funit impact of
            Ok [] ->
                emptyChartsMessage

            Ok entries ->
                entries
                    |> TextileComparativeChart.chart
                        { funit = funit
                        , impact = impact
                        , daysOfWear = daysOfWear
                        , size = Just ( 700, 500 )
                        , margins = Just { top = 22, bottom = 40, left = 40, right = 20 }
                        , chartHovering = chartHovering
                        , onChartHover = onChartHover
                        }

            Err error ->
                Alert.simple
                    { level = Alert.Danger
                    , close = Nothing
                    , title = Just "Erreur"
                    , content = [ text error ]
                    }
        , div [ class "fs-7 text-end text-muted" ]
            [ text impact.label
            , text ", "
            , funit |> Unit.functionalToString |> text
            ]
        ]


emptyChartsMessage : Html msg
emptyChartsMessage =
    p
        [ class "d-flex h-100 justify-content-center align-items-center"
        ]
        [ text "Merci de sélectionner des simulations à comparer" ]


getTextileChartEntries :
    Session
    -> Unit.Functional
    -> Definition
    -> Result String (List TextileComparativeChart.Entry)
getTextileChartEntries { textileDb, store } funit impact =
    store.bookmarks
        |> Bookmark.toTextileQueries
        |> List.filterMap
            (\( id, label, textileQuery ) ->
                if Set.member id store.comparedSimulations then
                    textileQuery
                        |> TextileComparativeChart.createEntry textileDb funit impact { highlight = True, label = label }
                        |> Just

                else
                    Nothing
            )
        |> RE.combine
        |> Result.map (List.sortBy .score)
