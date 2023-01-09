module Views.Comparator exposing (comparator)

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Impact as Impact
import Data.Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Duration exposing (Duration)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Result.Extra as RE
import Set
import Views.Alert as Alert
import Views.Container as Container
import Views.Textile.ComparativeChart as TextileComparativeChart


type alias ComparatorConfig msg =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional
    , daysOfWear : Duration
    , scope : Scope
    , toggle : Bookmark -> Bool -> msg
    }


comparator : ComparatorConfig msg -> Html msg
comparator { session, impact, funit, daysOfWear, scope, toggle } =
    let
        currentlyCompared =
            Set.size session.store.comparedSimulations
    in
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
                                        |> Bookmark.toQueryDescription { foodDb = session.builderDb, textileDb = session.db }
                                    , Set.member (Bookmark.toId bookmark) session.store.comparedSimulations
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
                                    , disabled (not isCompared && currentlyCompared >= Session.maxComparedSimulations)
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
                        [ class "list-group list-group-flush overflow-y-scroll overflow-x-hidden"
                        , style "max-height" "520px"
                        ]
                ]
            , div [ class "col-lg-8 px-4 py-2 overflow-hidden", style "min-height" "500px" ]
                [ case getChartEntries session funit impact scope of
                    Ok [] ->
                        p
                            [ class "d-flex h-100 justify-content-center align-items-center"
                            ]
                            [ text "Merci de sélectionner des simulations à comparer" ]

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
            ]
        ]


getChartEntries :
    Session
    -> Unit.Functional
    -> Impact.Definition
    -> Scope
    -> Result String (List TextileComparativeChart.Entry)
getChartEntries { db, store } funit impact scope =
    let
        createEntry_ =
            TextileComparativeChart.createEntry db funit impact
    in
    store.bookmarks
        |> Bookmark.filterByScope scope
        |> List.filterMap
            (\bookmark ->
                if Set.member bookmark.name store.comparedSimulations then
                    case bookmark.query of
                        Bookmark.Food _ ->
                            -- FIXME: handle comparison for saved recipes
                            Nothing

                        Bookmark.Textile query ->
                            query
                                |> createEntry_ { highlight = True, label = bookmark.name }
                                |> Just

                else
                    Nothing
            )
        |> RE.combine
        |> Result.map (List.sortBy .score)
