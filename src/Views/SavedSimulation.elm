module Views.SavedSimulation exposing (view)

import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Session exposing (SavedSimulation, Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Simulator.ViewMode as ViewMode
import Route
import Views.Icon as Icon


type alias Config msg =
    { session : Session
    , query : Inputs.Query
    , simulationName : String
    , impact : Impact.Definition
    , funit : Unit.Functional
    , savedSimulations : List SavedSimulation

    -- Messages
    , delete : SavedSimulation -> msg
    , save : msg
    , update : String -> msg
    }


view : Config msg -> Html msg
view ({ query, simulationName, savedSimulations } as config) =
    let
        alreadySaved =
            savedSimulations
                |> List.member (SavedSimulation simulationName query)
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
        , savedSimulationsView config
        ]


savedSimulationsView : Config msg -> Html msg
savedSimulationsView ({ savedSimulations } as config) =
    div []
        [ div [ class "card-header border-top" ] [ text "Simulations sauvegardées" ]
        , if List.length savedSimulations == 0 then
            div [ class "card-body form-text fs-7 pt-2" ]
                [ text "Pas de simulations sauvegardées sur cet ordinateur" ]

          else
            savedSimulations
                |> List.map (savedSimulationView config)
                |> ul
                    [ class "list-group list-group-flush overflow-scroll"
                    , style "max-height" "50vh"
                    ]
        ]


savedSimulationView : Config msg -> SavedSimulation -> Html msg
savedSimulationView { session, impact, funit, delete } ({ name, query } as savedSimulation) =
    let
        simulationLink =
            Just query
                |> Route.Simulator impact.trigram funit ViewMode.Simple
                |> Route.toString
                |> (++) session.clientUrl
    in
    li [ class "list-group-item d-flex justify-content-between align-items-center" ]
        [ a
            [ class "text-truncate"
            , href simulationLink
            , title name
            ]
            [ text name ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-danger"
            , onClick (delete savedSimulation)
            ]
            [ text "Supprimer" ]
        ]
