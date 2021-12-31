module Page.Api exposing (..)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = NoOp


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( (), session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


getApiServerUrl : Session -> String
getApiServerUrl { clientUrl } =
    -- If we're using local parcel dev server, use the ExpressJS API server
    if String.contains ":1234" clientUrl then
        "http://localhost:3000/api"

    else
        clientUrl ++ "api"


apiBrowser : Session -> Html Msg
apiBrowser session =
    node "rapi-doc"
        -- RapiDoc options: https://mrin9.github.io/RapiDoc/api.html
        [ attribute "spec-url" (session.clientUrl ++ "data/openapi.yaml")
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
            [ h1 [ class "mb-3" ] [ text "API Wikicarbone" ]
            , Alert.simple
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
                [ text "L'API HTTP Wikicarbone permet de calculer les impacts environnementaux des produits textiles." ]
            , p []
                [ text "Elle est accessible à l'adresse "
                , code [] [ text <| getApiServerUrl session ]
                , text " et documentée au format "
                , a [ href "/data/openapi.yaml", target "_blank" ] [ text "OpenAPI" ]
                , text "."
                ]
            , apiBrowser session
            ]
      ]
    )
