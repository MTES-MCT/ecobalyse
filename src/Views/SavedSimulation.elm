module Views.SavedSimulation exposing (comparator, manager)

import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Session exposing (SavedSimulation, Session)
import Data.Unit as Unit
import Duration exposing (Duration)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Simulator.ViewMode as ViewMode
import Result.Extra as RE
import Route
import Set
import Views.Alert as Alert
import Views.Comparator as ComparatorView
import Views.Icon as Icon


type alias ManagerConfig msg =
    { session : Session
    , simulationName : String
    , impact : Impact.Definition
    , funit : Unit.Functional

    -- Messages
    , compareAll : msg
    , delete : SavedSimulation -> msg
    , save : msg
    , update : String -> msg
    }


manager : ManagerConfig msg -> Html msg
manager ({ session, simulationName } as config) =
    let
        ( queryExists, nameExists ) =
            ( session.store.savedSimulations
                |> List.map .query
                |> List.member session.query
            , session.store.savedSimulations
                |> List.map .name
                |> List.member simulationName
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
                        , value simulationName
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
                [ text "Nommez cette simulation pour vous aider à la retrouver dans la liste" ]
            ]
        , savedSimulationListView config
        ]


savedSimulationListView : ManagerConfig msg -> Html msg
savedSimulationListView ({ compareAll, session } as config) =
    div []
        [ div [ class "card-header border-top d-flex justify-content-between align-items-center" ]
            [ span [] [ text "Simulations sauvegardées" ]
            , button
                [ class "btn btn-sm btn-primary"
                , title "Comparer toutes vos simulations sauvegardées"
                , disabled (List.length session.store.savedSimulations < 2)
                , onClick compareAll
                ]
                [ span [ class "me-1" ] [ Icon.stats ]
                , text "Comparer"
                ]
            ]
        , if List.length session.store.savedSimulations == 0 then
            div [ class "card-body form-text fs-7 pt-2" ]
                [ text "Pas de simulations sauvegardées sur cet ordinateur" ]

          else
            session.store.savedSimulations
                |> List.map (savedSimulationView config)
                |> ul
                    [ class "list-group list-group-flush rounded-bottom overflow-scroll"
                    , style "max-height" "50vh"
                    ]
        ]


savedSimulationView : ManagerConfig msg -> SavedSimulation -> Html msg
savedSimulationView { session, impact, funit, delete } ({ name, query } as savedSimulation) =
    let
        simulationLink =
            Just query
                |> Route.Simulator impact.trigram funit ViewMode.Simple
                |> Route.toString
                |> (++) session.clientUrl
    in
    li
        [ class "list-group-item d-flex justify-content-between align-items-center gap-1"
        , classList [ ( "active", query == session.query ) ]
        ]
        [ a
            [ class "text-truncate"
            , classList [ ( "active text-white", query == session.query ) ]
            , href simulationLink
            , title (detailsTooltip session savedSimulation)
            ]
            [ text name ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-danger"
            , onClick (delete savedSimulation)
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
    , toggle : Int -> Bool -> msg
    }


getChartEntries :
    Session
    -> Unit.Functional
    -> Impact.Definition
    -> Result String (List ComparatorView.Entry)
getChartEntries { db, query, store } funit impact =
    let
        createEntry_ =
            ComparatorView.createEntry db funit impact
    in
    -- TODO: if current simulation query exactly matches the one from a saved simulation,
    --       assume current simulation name is the saved one
    createEntry_ True "Simulation en cours" query
        :: (store.savedSimulations
                |> List.indexedMap Tuple.pair
                |> List.filterMap
                    (\( index, saved ) ->
                        if Set.member index store.comparedSimulations then
                            Just saved

                        else
                            Nothing
                    )
                |> List.map (\saved -> createEntry_ False saved.name saved.query)
           )
        |> RE.combine
        |> Result.map (List.sortBy .score)


comparator : ComparatorConfig msg -> Html msg
comparator { session, impact, funit, daysOfWear, toggle } =
    div [ class "row" ]
        [ div [ class "col-sm-4 border-end" ]
            [ p [ class "p-2 pb-0 mb-0 fs-7 text-muted" ]
                [ text "Sélectionnez les simulations sauvegardées que vous souhaitez comparer\u{00A0}:" ]
            , session.store.savedSimulations
                |> List.indexedMap
                    (\index saved ->
                        label
                            [ class "form-check-label list-group-item text-nowrap fs-7 ps-2"
                            , title (detailsTooltip session saved)
                            ]
                            [ input
                                [ type_ "checkbox"
                                , class "form-check-input"
                                , onCheck (toggle index)
                                , checked (Set.member index session.store.comparedSimulations)
                                ]
                                []
                            , span [ class "ps-2" ] [ text saved.name ]
                            ]
                    )
                |> ul
                    [ class "list-group list-group-flush"
                    , class "h-100 overflow-scroll"
                    ]
            ]
        , div [ class "col-sm-8 px-4 py-2" ]
            [ case getChartEntries session funit impact of
                Ok entries ->
                    entries
                        |> ComparatorView.chart
                            { funit = funit
                            , impact = impact
                            , daysOfWear = daysOfWear
                            , size = Just ( 700, 500 )
                            , margins = Just { top = 22, bottom = 40, left = 40, right = 0 }
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


detailsTooltip : Session -> SavedSimulation -> String
detailsTooltip session saved =
    saved.query
        |> Inputs.fromQuery session.db
        |> Result.map Inputs.toString
        |> Result.withDefault saved.name
