module Views.Page exposing (ActivePage(..), Config, frame)

import Browser exposing (Document)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route


type ActivePage
    = Home
    | Simulator
    | Editorial String
    | Examples
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
        , div [ class "alert alert-info mb-0" ]
            [ div [ class "container" ]
                [ text "Ce site n'est pas encore opérationnel… Work in progress." ]
            ]
        , div [ class "bg-light", style "min-height" "52vh" ]
            [ main_ [ class "container py-5" ] content
            ]
        , pageFooter config
        ]
    }


menuLinks : ActivePage -> List (Html msg)
menuLinks activePage =
    let
        linkIf page route caption =
            if page == activePage then
                text caption

            else
                a [ class "text-light", Route.href route ] [ text caption ]
    in
    [ linkIf Home Route.Home "Accueil"
    , linkIf Simulator (Route.Simulator Nothing) "Simulateur"
    , linkIf Examples Route.Examples "Exemples"
    , linkIf (Editorial "methodology") (Route.Editorial "methodology") "Méthodologie"
    , a [ class "text-light", href "https://github.com/MTES-MCT/wikicarbone/" ] [ text "Code source" ]
    ]


navbar : Config -> Html msg
navbar { activePage } =
    header [ class "navbar navbar-dark bg-dark text-light shadow-sm" ]
        [ div [ class "container" ]
            [ h1 [ class "display-5 fw-bold" ] [ a [ class "text-light text-decoration-none", Route.href Route.Home ] [ text "wikicarbone" ] ]
            , menuLinks activePage
                |> List.intersperse (text " | ")
                |> nav []
            ]
        ]


pageFooter : Config -> Html msg
pageFooter { activePage } =
    footer
        [ class "bg-dark text-light py-5 fs-7" ]
        [ div [ class "container" ]
            [ div [ class "row d-flex align-items-center" ]
                [ div [ class "col" ]
                    [ h3 [] [ text "wikicarbone" ]
                    , menuLinks activePage
                        |> List.map (\l -> li [] [ l ])
                        |> ul []
                    , p [ class "mb-0" ]
                        [ text "Un produit "
                        , a [ href "https://beta.gouv.fr/", class "text-light", rel "noopener noreferrer", target "_blank" ]
                            [ text "beta.gouv.fr" ]
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
