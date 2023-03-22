module Views.Comparator exposing
    ( FoodComparisonUnit(..)
    , comparator
    , foodOptions
    , textileOptions
    )

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Builder.Recipe as Recipe
import Data.Impact as Impact
import Data.Scope as Scope exposing (Scope)
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
    , impact : Impact.Definition
    , options : Options msg
    , toggle : Bookmark -> Bool -> msg
    }


type Options msg
    = Food (FoodOptions msg)
    | Textile TextileOptions


type FoodComparisonUnit
    = PerItem
    | PerKgOfProduct


type alias FoodOptions msg =
    { comparisonUnit : FoodComparisonUnit
    , switchComparisonUnit : FoodComparisonUnit -> msg
    , groupByProtectionAreas : Bool
    , updateGroupByProtectionAreas : Bool -> msg
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
                    |> Bookmark.filterByScope (optionsScope options)
                    |> List.map
                        (\bookmark ->
                            let
                                ( description, isCompared ) =
                                    ( bookmark
                                        |> Bookmark.toQueryDescription
                                            { foodDb = session.builderDb, textileDb = session.db }
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
                [ text ""
                , case options of
                    Food foodOptions_ ->
                        foodComparatorView config foodOptions_

                    Textile textileOptions_ ->
                        textileComparatorView config textileOptions_
                ]
            ]
        ]


foodComparatorView : Config msg -> FoodOptions msg -> Html msg
foodComparatorView { session } { comparisonUnit, switchComparisonUnit, groupByProtectionAreas, updateGroupByProtectionAreas } =
    let
        { builderDb, store } =
            session

        addToComparison ( id, label, foodQuery ) =
            if Set.member id store.comparedSimulations then
                foodQuery
                    |> Recipe.compute builderDb
                    |> Result.map
                        (\( _, { total, perKg } ) ->
                            case comparisonUnit of
                                PerItem ->
                                    ( label, total )

                                PerKgOfProduct ->
                                    ( label, perKg )
                        )
                    |> Just

            else
                Nothing

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

        charts =
            store.bookmarks
                |> Bookmark.toFoodQueries
                |> List.filterMap addToComparison
                |> RE.combine

        unitChoiceRadio caption current to =
            label [ class "form-check-label d-flex align-items-center gap-1" ]
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

        groupByProtectionAreasCheckbox =
            label [ class "form-check-label d-flex align-items-center gap-1" ]
                [ input
                    [ type_ "checkbox"
                    , class "form-check-input"
                    , name "groupByProtectionAreas"
                    , checked groupByProtectionAreas
                    , onCheck updateGroupByProtectionAreas
                    ]
                    []
                , text "Grouper les impacts par sous-scores"
                ]
    in
    div []
        [ h2 [ class "h5 text-center" ]
            [ text "Comparaison des compositions du score d'impact des recettes sélectionnées" ]
        , div [ class "d-flex justify-content-center align-items-center gap-3" ]
            [ unitChoiceRadio "par produit" comparisonUnit PerItem
            , unitChoiceRadio "par kg de produit" comparisonUnit PerKgOfProduct
            , groupByProtectionAreasCheckbox
            ]
        , case charts of
            Ok [] ->
                emptyChartsMessage

            Ok chartsData ->
                div [ class "h-100" ]
                    [ node "chart-food-comparator"
                        [ if not groupByProtectionAreas then
                            chartsData
                                |> List.map
                                    (Tuple.mapSecond
                                        (Impact.getAggregatedScoreData builderDb.impacts .ecoscoreData
                                            >> List.sortWith labelComparison
                                            >> List.reverse
                                        )
                                    )
                                |> Encode.list
                                    (\( name, entries ) ->
                                        Encode.object
                                            [ ( "label", Encode.string name )
                                            , ( "data", Encode.list Impact.encodeAggregatedScoreChartEntry entries )
                                            ]
                                    )
                                |> Encode.encode 0
                                |> attribute "data"

                          else
                            chartsData
                                |> List.map
                                    (Tuple.mapSecond
                                        (Impact.toProtectionAreas builderDb.impacts
                                            >> (\protectionAreas ->
                                                    [ { name = "Climat", color = "#7f7f7f", value = Unit.impactToFloat protectionAreas.climate }
                                                    , { name = "Biodiversité", color = "#00b050", value = Unit.impactToFloat protectionAreas.biodiversity }
                                                    , { name = "Santé environnementale", color = "#ffc000", value = Unit.impactToFloat protectionAreas.health }
                                                    , { name = "Ressource", color = "#0070c0", value = Unit.impactToFloat protectionAreas.resources }
                                                    ]
                                                        |> List.reverse
                                               )
                                        )
                                    )
                                |> Encode.list
                                    (\( name, entries ) ->
                                        Encode.object
                                            [ ( "label", Encode.string name )
                                            , ( "data", Encode.list Impact.encodeAggregatedScoreChartEntry entries )
                                            ]
                                    )
                                |> Encode.encode 0
                                |> attribute "data"
                        ]
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


textileComparatorView : Config msg -> TextileOptions -> Html msg
textileComparatorView { session, impact } { funit, daysOfWear } =
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
    -> Impact.Definition
    -> Result String (List TextileComparativeChart.Entry)
getTextileChartEntries { db, store } funit impact =
    store.bookmarks
        |> Bookmark.toTextileQueries
        |> List.filterMap
            (\( id, label, textileQuery ) ->
                if Set.member id store.comparedSimulations then
                    textileQuery
                        |> TextileComparativeChart.createEntry db funit impact { highlight = True, label = label }
                        |> Just

                else
                    Nothing
            )
        |> RE.combine
        |> Result.map (List.sortBy .score)


optionsScope : Options msg -> Scope
optionsScope options =
    case options of
        Food _ ->
            Scope.Food

        Textile _ ->
            Scope.Textile
