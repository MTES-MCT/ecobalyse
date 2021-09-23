module Views.Page exposing (..)

import Browser exposing (Document)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Container as Container


type ActivePage
    = Home
    | Simulator
    | Editorial String
    | Examples
    | Stats
    | Other


type alias Config =
    { session : Session
    , activePage : ActivePage
    }


frame : Config -> ( String, List (Html msg) ) -> Document msg
frame config ( title, content ) =
    { title = title ++ " | wikicarbone"
    , body =
        [ navbar config
        , main_ [ class "bg-white pt-5" ] content
        , pageFooter
        ]
    }


menuLinks : List ( ActivePage, Route.Route, String )
menuLinks =
    [ ( Home, Route.Home, "Accueil" )
    , ( Simulator, Route.Simulator Nothing, "Simulateur" )
    , ( Examples, Route.Examples, "Exemples" )
    , ( Editorial "methodologie", Route.Editorial "methodologie", "Méthodologie" )
    ]


navbar : Config -> Html msg
navbar { activePage } =
    nav [ class "Header navbar navbar-expand-lg navbar-dark bg-dark shadow" ]
        [ Container.centered []
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ img
                    [ class "d-inline-block align-text-bottom invert me-2"
                    , alt ""
                    , src "img/logo.svg"
                    , height 26
                    ]
                    []
                , span [ class "fs-3" ] [ text "wikicarbone" ]
                ]
            , menuLinks
                |> List.map
                    (\( page, route, label ) ->
                        if page == activePage then
                            a [ class "nav-link pe-1 active", Route.href route, attribute "aria-current" "page" ]
                                [ text label ]

                        else
                            a [ class "nav-link pe-1", Route.href route ]
                                [ text label ]
                    )
                |> div
                    [ class "MainMenu navbar-nav justify-content-between flex-row"
                    , style "overflow" "auto"
                    ]
            ]
        ]


pageFooter : Html msg
pageFooter =
    let
        appendList =
            \new list -> list ++ [ new ]
    in
    footer
        [ class "bg-dark text-light py-5 fs-7" ]
        [ Container.centered []
            [ div [ class "row d-flex align-items-center" ]
                [ div [ class "col" ]
                    [ h3 [] [ text "wikicarbone" ]
                    , menuLinks
                        |> List.map (\( _, r, l ) -> a [ class "text-light", Route.href r ] [ text l ])
                        |> appendList
                            (a [ class "text-light", Route.href Route.Stats ] [ text "Statistiques" ])
                        |> appendList
                            (a [ class "text-light", href "https://github.com/MTES-MCT/wikicarbone/" ] [ text "Code source" ])
                        |> List.map (List.singleton >> li [])
                        |> ul []
                    , p [ class "mb-0" ]
                        [ text "Un produit "
                        , a [ href "https://beta.gouv.fr/startups/wikicarbone.html", class "text-light" ]
                            [ img [ src "img/betagouv.svg", alt "beta.gouv.fr", style "width" "120px" ] [] ]
                        ]
                    ]
                , a
                    [ href "https://www.ecologique-solidaire.gouv.fr/"
                    , rel "noopener noreferrer"
                    , target "_blank"
                    , class "col text-center bg-light px-3 m-3"
                    ]
                    [ img
                        [ src "img/logo_mte.svg"
                        , alt "Ministère de la transition écologique et solidaire"
                        , attribute "width" "200"
                        , attribute "height" "200"
                        ]
                        []
                    ]
                , a
                    [ href "https://www.cohesion-territoires.gouv.fr/"
                    , rel "noopener noreferrer"
                    , target "_blank"
                    , class "col text-center bg-light px-3 m-3"
                    ]
                    [ img
                        [ src "img/logo_mct.svg"
                        , alt "Ministère de la Cohésion des territoires et des Relations avec les collectivités territoriales"
                        , attribute "width" "200"
                        , attribute "height" "200"
                        ]
                        []
                    ]
                , a
                    [ href "https://www.ecologique-solidaire.gouv.fr/fabrique-numerique"
                    , rel "noopener noreferrer"
                    , target "_blank"
                    , class "col text-center px-3 py-2"
                    ]
                    [ img
                        [ src "img/logo-fabriquenumerique.svg"
                        , alt "La Fabrique Numérique"
                        , attribute "width" "200"
                        , attribute "height" "200"
                        ]
                        []
                    ]
                ]
            ]
        ]


notFound : Html msg
notFound =
    Container.centered [ class "pb-5" ]
        [ h1 [ class "mb-3" ] [ text "Page non trouvée" ]
        , p [] [ text "La page que vous avez demandé n'existe pas." ]
        , a [ Route.href Route.Home ] [ text "Retour à l'accueil" ]
        ]
