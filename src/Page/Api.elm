module Page.Api exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = NoOp Never


type alias News =
    { date : String
    , level : String
    , md : String
    }


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( (), session, Ports.scrollTo { x = 0, y = 0 } )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session _ model =
    ( model, session, Cmd.none )


getApiServerUrl : Session -> String
getApiServerUrl { clientUrl } =
    clientUrl ++ "api"


changelog : List News
changelog =
    [ { date = "2 juin 2022"
      , level = "major"
      , md =
            """Le format de définition de la liste des matières a évolué\u{00A0};
            là où vous définissiez une liste de matières en y incluant le pourcentage de matière
            recyclée, par ex. `materials[]=coton;0.3;0.5&…` pour *30% coton à 50% recyclé*,
            vous devez désormais écrire `materials[]=coton;0.15&materials[]=coton-rdp;0.15&…`
            (soit *15% coton, 15% coton recyclé*, ce qui revient au même)."""
      }
    ]


apiBrowser : Session -> Html Msg
apiBrowser session =
    node "rapi-doc"
        -- RapiDoc options: https://mrin9.github.io/RapiDoc/api.html
        [ attribute "spec-url" (getApiServerUrl session)
        , attribute "server-url" (getApiServerUrl session)
        , attribute "default-api-server" (getApiServerUrl session)
        , attribute "theme" "light"
        , attribute "font-size" "largest"
        , attribute "load-fonts" "false"
        , attribute "layout" "column"
        , attribute "show-info" "false"
        , attribute "update-route" "false"
        , attribute "render-style" "view"
        , attribute "show-header" "false"
        , attribute "show-components" "true"
        , attribute "schema-description-expanded" "true"
        , attribute "allow-authentication" "false"
        , attribute "allow-server-selection" "false"
        , attribute "allow-api-list-style-selection" "false"
        ]
        []


view : Session -> Model -> ( String, List (Html Msg) )
view session _ =
    ( "API"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "API Ecobalyse" ]
            , div [ class "row" ]
                [ div [ class "col-xl-8" ]
                    [ Alert.simple
                        { level = Alert.Info
                        , close = Nothing
                        , title = Nothing
                        , content =
                            [ div [ class "fs-7" ]
                                [ """Cette API est en version *alpha*, l'implémentation et le contrat d'interface sont susceptibles
                             de changer à tout moment. Vous êtes vivement invité à **ne pas exploiter cette API en production**."""
                                    |> Markdown.simple []
                                ]
                            ]
                        }
                    , p [ class "fw-bold" ]
                        [ text "L'API HTTP Ecobalyse permet de calculer les impacts environnementaux des produits textiles." ]
                    , p []
                        [ text "Elle est accessible à l'adresse "
                        , code [] [ text (getApiServerUrl session) ]
                        , text " et "
                        , a [ href (getApiServerUrl session), target "_blank" ] [ text "documentée" ]
                        , text " au format "
                        , a [ href "https://swagger.io/specification/", target "_blank" ] [ text "OpenAPI" ]
                        , text "."
                        ]
                    , div [] [ apiBrowser session ]
                    ]
                , div [ class "col-xl-4" ]
                    [ div [ class "card" ]
                        [ div [ class "card-header" ] [ text "Dernières mises à jour" ]
                        , changelog
                            |> List.map
                                (\{ date, level, md } ->
                                    li [ class "list-group-item" ]
                                        [ div [ class "d-flex justify-content-between align-items-center" ]
                                            [ text date
                                            , span [ class "badge bg-danger" ] [ text level ]
                                            ]
                                        , Markdown.simple [ class "fs-7" ] md
                                        ]
                                )
                            |> ul [ class "list-group list-group-flush" ]
                        ]
                    ]
                ]
            ]
      ]
    )
