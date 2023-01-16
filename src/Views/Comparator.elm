module Views.Comparator exposing
    ( ComparisonUnit(..)
    , comparator
    )

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Builder.Recipe as Recipe
import Data.Impact as Impact
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
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


type alias ComparatorConfig msg =
    { session : Session
    , impact : Impact.Definition
    , foodComparisonUnit : ComparisonUnit
    , funit : Unit.Functional
    , daysOfWear : Duration
    , scope : Scope
    , switchFoodComparisonUnit : ComparisonUnit -> msg
    , toggle : Bookmark -> Bool -> msg
    }


type ComparisonUnit
    = PerItem
    | PerKgOfProduct


comparator : ComparatorConfig msg -> Html msg
comparator ({ session, impact, funit, daysOfWear, scope, toggle } as config) =
    Container.fluid []
        [ div [ class "row" ]
            [ div [ class "col-lg-4 border-end fs-7 p-0" ]
                [ p [ class "p-2 ps-3 pb-1 mb-0 text-muted" ]
                    [ text "Sélectionnez jusqu'à "
                    , strong [] [ text (String.fromInt Session.maxComparedSimulations) ]
                    , text " simulations pour les comparer\u{00A0}:"
                    ]
                , session.store.bookmarks
                    |> Bookmark.filterByScope scope
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
                , case scope of
                    Scope.Food ->
                        foodComparatorView config

                    Scope.Textile ->
                        textileComparatorView session funit daysOfWear impact
                ]
            ]
        ]


foodComparatorView : ComparatorConfig msg -> Html msg
foodComparatorView { session, foodComparisonUnit, switchFoodComparisonUnit } =
    let
        { builderDb, store } =
            session

        charts =
            store.bookmarks
                |> Bookmark.toFoodQueries
                |> List.filterMap
                    (\( id, label, foodQuery ) ->
                        if Set.member id store.comparedSimulations then
                            foodQuery
                                |> Recipe.compute builderDb
                                |> Result.map
                                    (\( _, results ) ->
                                        results.total
                                            |> (case foodComparisonUnit of
                                                    PerItem ->
                                                        identity

                                                    PerKgOfProduct ->
                                                        Impact.perKg results.totalMass
                                               )
                                            |> (\i -> ( label, i ))
                                    )
                                |> Just

                        else
                            Nothing
                    )
                |> RE.combine
                |> Result.map
                    (List.map
                        (Tuple.mapSecond
                            (Impact.getAggregatedScoreData builderDb.impacts .ecoscoreData
                                >> List.sortBy .name
                                >> List.reverse
                            )
                        )
                    )

        radio caption current to =
            label [ class "form-check-label d-flex align-items-center gap-1" ]
                [ input
                    [ type_ "radio"
                    , class "form-check-input"
                    , name "unit"
                    , checked <| current == to
                    , onInput <| always (switchFoodComparisonUnit to)
                    ]
                    []
                , text caption
                ]
    in
    div []
        [ h2 [ class "h5 text-center" ] [ text "Comparaison des compositions du score d'impact des recettes sélectionnées" ]
        , div [ class "d-flex justify-content-center align-items-center gap-3" ]
            [ radio "par produit" foodComparisonUnit PerItem
            , radio "par kg de produit" foodComparisonUnit PerKgOfProduct
            ]
        , case charts of
            Ok [] ->
                emptyChartsMessage

            Ok chartsData ->
                div [ class "h-100" ]
                    [ node "chart-food-comparator"
                        [ chartsData
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


textileComparatorView : Session -> Unit.Functional -> Duration -> Impact.Definition -> Html msg
textileComparatorView session funit daysOfWear impact =
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
