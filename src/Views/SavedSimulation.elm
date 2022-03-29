module Views.SavedSimulation exposing (comparator, manager)

import Data.Impact as Impact
import Data.Session exposing (SavedSimulation, Session)
import Data.Simulator exposing (Simulator)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Simulator.ViewMode as ViewMode
import Route
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
        alreadySaved =
            session.store.savedSimulations
                |> List.map .query
                |> List.member session.query
    in
    div []
        [ div [ class "card-body" ]
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
                        , classList [ ( "disabled", alreadySaved ) ]
                        , title "Sauvegarder la simulation dans le stockage local au navigateur"
                        , disabled alreadySaved
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
                    [ class "list-group list-group-flush overflow-scroll"
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
            , title name
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


type alias ComparatorConfig =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional

    -- FIXME: pass wuery instead
    , simulator : Simulator
    , savedSimulations : List SavedSimulation
    }


comparator : ComparatorConfig -> Html msg
comparator { session, impact, funit, simulator } =
    div [ class "row" ]
        [ div [ class "col-sm-4" ]
            [ session.store.savedSimulations
                |> List.map
                    (\{ name } ->
                        label [ class "form-check-label list-group-item text-nowrap fs-7 ps-2" ]
                            [ input [ type_ "checkbox", class "form-check-input" ] []
                            , span [ class "ps-2" ] [ text name ]
                            ]
                    )
                |> ul
                    [ class "list-group list-group-flush border-end"
                    , class "h-100 overflow-scroll"
                    ]
            ]
        , div [ class "col-sm-8 pt-3 pb-5 pe-4" ]
            [ ComparatorView.view
                { session = session
                , impact = impact
                , funit = funit
                , simulator = simulator
                }
            ]
        ]
