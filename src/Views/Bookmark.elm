module Views.Bookmark exposing
    ( comparator
    , manager
    )

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Impact as Impact
import Data.Session as Session exposing (Session)
import Data.Textile.Inputs as Inputs
import Data.Unit as Unit
import Duration exposing (Duration)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode exposing (ViewMode)
import Result.Extra as RE
import Route
import Set
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Textile.Comparator as ComparatorView


type alias ManagerConfig msg =
    { session : Session
    , bookmarks : List Bookmark
    , bookmarkName : String
    , currentQuery : Bookmark.Query
    , impact : Impact.Definition
    , funit : Unit.Functional
    , viewMode : ViewMode

    -- Messages
    , compare : msg
    , delete : Bookmark -> msg
    , save : msg
    , update : String -> msg
    }


manager : ManagerConfig msg -> Html msg
manager ({ bookmarks, bookmarkName, currentQuery } as config) =
    let
        ( queryExists, nameExists ) =
            ( bookmarks
                |> List.map .query
                |> List.member currentQuery
            , bookmarks
                |> List.map .name
                |> List.member bookmarkName
            )
    in
    div []
        [ div [ class "card-body pb-2" ]
            [ Html.form [ onSubmit config.save ]
                [ div [ class "input-group" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , onInput config.update
                        , placeholder "Nom de la simulation"
                        , value bookmarkName
                        , required True
                        , pattern "^(?!\\s*$).+"
                        ]
                        []
                    , button
                        [ type_ "submit"
                        , class "btn btn-primary"
                        , title "Sauvegarder la simulation dans le stockage local au navigateur"
                        , disabled (queryExists || nameExists)
                        ]
                        [ Icon.plus ]
                    ]
                ]
            , div [ class "form-text fs-7 pb-0" ]
                [ text "Donnez un nom à cette simulation pour la retrouver plus tard" ]
            ]
        , bookmarksView config
        ]


bookmarksView : ManagerConfig msg -> Html msg
bookmarksView ({ bookmarks, compare } as config) =
    div []
        [ div [ class "card-header border-top d-flex justify-content-between align-items-center" ]
            [ span [] [ text "Simulations sauvegardées" ]
            , button
                [ class "btn btn-sm btn-primary"
                , title "Comparer vos simulations sauvegardées"
                , disabled (List.length bookmarks < 2)
                , onClick compare
                ]
                [ span [ class "me-1" ] [ Icon.stats ]
                , text "Comparer"
                ]
            ]
        , if List.length bookmarks == 0 then
            div [ class "card-body form-text fs-7 pt-2" ]
                [ text "Pas de simulations sauvegardées sur cet ordinateur" ]

          else
            bookmarks
                |> List.map (bookmarkView config)
                |> ul
                    [ class "list-group list-group-flush rounded-bottom overflow-auto"
                    , style "max-height" "50vh"
                    ]
        ]


bookmarkView : ManagerConfig msg -> Bookmark -> Html msg
bookmarkView { currentQuery, impact, funit, viewMode, delete, session } ({ name, query } as bookmark) =
    let
        bookmarkRoute =
            case query of
                Bookmark.Food foodQuery ->
                    Just foodQuery
                        |> Route.FoodBuilder impact.trigram

                Bookmark.Textile textileQuery ->
                    Just textileQuery
                        |> Route.TextileSimulator impact.trigram funit viewMode
    in
    li
        [ class "list-group-item d-flex justify-content-between align-items-center gap-1 fs-7"
        , classList [ ( "active", query == currentQuery ) ]
        ]
        [ a
            [ class "text-truncate"
            , classList [ ( "active text-white", query == currentQuery ) ]
            , title (detailsTooltip session bookmark)
            , bookmarkRoute
                |> Route.toString
                |> (++) session.clientUrl
                |> href
            ]
            [ text name ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-danger"
            , onClick (delete bookmark)
            ]
            [ span [ class "me-1" ] [ Icon.trash ]
            , text "Supprimer"
            ]
        ]


type alias ComparatorConfig msg =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional
    , daysOfWear : Duration
    , toggle : String -> Bool -> msg
    }


getChartEntries :
    Session
    -> Unit.Functional
    -> Impact.Definition
    -> Result String (List ComparatorView.Entry)
getChartEntries { db, store } funit impact =
    let
        createEntry_ =
            ComparatorView.createEntry db funit impact
    in
    store.bookmarks
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


comparator : ComparatorConfig msg -> Html msg
comparator { session, impact, funit, daysOfWear, toggle } =
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
                    |> List.map
                        (\saved ->
                            let
                                ( description, isCompared ) =
                                    ( detailsTooltip session saved
                                    , Set.member saved.name session.store.comparedSimulations
                                    )
                            in
                            label
                                [ class "form-check-label list-group-item text-nowrap ps-3"
                                , title description
                                ]
                                [ input
                                    [ type_ "checkbox"
                                    , class "form-check-input"
                                    , onCheck (toggle saved.name)
                                    , checked isCompared
                                    , disabled (not isCompared && currentlyCompared >= Session.maxComparedSimulations)
                                    ]
                                    []
                                , span [ class "ps-2" ]
                                    [ span [ class "me-2 fw-500" ] [ text saved.name ]
                                    , if description /= saved.name then
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
                [ case getChartEntries session funit impact of
                    Ok [] ->
                        p
                            [ class "d-flex h-100 justify-content-center align-items-center"
                            ]
                            [ text "Merci de sélectionner des simulations à comparer" ]

                    Ok entries ->
                        entries
                            |> ComparatorView.chart
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


detailsTooltip : Session -> Bookmark -> String
detailsTooltip session bookmark =
    case bookmark.query of
        Bookmark.Food _ ->
            -- FIXME: description textuelle détaillée de la recette
            ""

        Bookmark.Textile query ->
            Inputs.fromQuery session.db query
                |> Result.map Inputs.toString
                |> Result.withDefault bookmark.name
