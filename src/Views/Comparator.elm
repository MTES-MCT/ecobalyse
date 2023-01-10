module Views.Comparator exposing (comparator)

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
                [ text ""
                , case scope of
                    Scope.Food ->
                        foodComparatorView session

                    Scope.Textile ->
                        textileComparatorView session funit daysOfWear impact
                ]
            ]
        ]


foodComparatorView : Session -> Html msg
foodComparatorView { builderDb, store } =
    let
        scores =
            store.bookmarks
                |> Bookmark.toFoodQueries
                |> List.filterMap
                    (\( id, label, foodQuery ) ->
                        if Set.member id store.comparedSimulations then
                            foodQuery
                                |> Recipe.compute builderDb
                                |> Result.map (Tuple.second >> .total >> (\i -> ( label, i )))
                                |> Just

                        else
                            Nothing
                    )
                |> RE.combine

        tmp =
            scores
                -- FIXME: handle error
                |> Result.withDefault []
                |> Debug.toString

        json =
            """
        {
        labels: ["Recette*1", "Recette*2", "Recette*3", "Recette*4", "Recette*5"],
        series: [
          {
            // XXX: Impact name here
            name: "Acidification des sols",
            // XXX: impact values for each product here
            data: [4, 4, 6, 15, 12],
          },
          {
            name: "Biodiversité",
            data: [5, 3, 12, 6, 11],
          },
          {
            name: "Changement climatique",
            data: [5, 15, 8, 5, 8],
          },
        ],
      }
            """
    in
    div []
        [ pre [] [ text tmp ]

        -- , node "chart-food-comparator"
        --     [ json
        --         |> attribute "data"
        --     ]
        --     []
        ]


textileComparatorView : Session -> Unit.Functional -> Duration -> Impact.Definition -> Html msg
textileComparatorView session funit daysOfWear impact =
    div []
        [ case getTextileChartEntries session funit impact of
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
