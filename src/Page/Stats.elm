module Page.Stats exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Matomo as Matomo
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Common as RequestCommon
import Request.Matomo
import Views.Alert as Alert
import Views.Container as Container
import Views.Spinner as Spinner


type alias Model =
    { apiStats : WebData (List Matomo.Stat)
    , webStats : WebData (List Matomo.Stat)
    , mode : Mode
    }


type Msg
    = ApiStats (WebData (List Matomo.Stat))
    | ToggleMode Mode
    | WebStats (WebData (List Matomo.Stat))


type Mode
    = Advanced
    | Simple


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { apiStats = RemoteData.NotAsked
      , webStats = RemoteData.NotAsked
      , mode = Simple
      }
    , session
    , Cmd.batch
        [ Request.Matomo.getApiStats session ApiStats
        , Request.Matomo.getWebStats session WebStats
        , Ports.scrollTo { x = 0, y = 0 }
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ApiStats apiStats ->
            ( { model | apiStats = apiStats }, session, Cmd.none )

        ToggleMode mode ->
            ( { model | mode = mode }, session, Cmd.none )

        WebStats webStats ->
            ( { model | webStats = webStats }, session, Cmd.none )


viewStats : { heading : String, unit : String } -> WebData (List Matomo.Stat) -> Html Msg
viewStats { heading, unit } webData =
    case webData of
        RemoteData.Failure err ->
            Alert.serverError <| RequestCommon.errorToString err

        RemoteData.Loading ->
            Spinner.view

        RemoteData.NotAsked ->
            text ""

        RemoteData.Success stats ->
            node "chart-stats"
                [ attribute "heading" heading
                , attribute "unit" unit
                , attribute "height" "300"
                , attribute "data" (Matomo.encodeStats stats)
                ]
                []


view : Session -> Model -> ( String, List (Html Msg) )
view { matomo } { mode, apiStats, webStats } =
    ( "Statistiques"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Statistiques" ]
            , ul [ class "nav nav-tabs" ]
                [ li [ class "nav-item" ]
                    [ button
                        [ class "nav-link"
                        , classList [ ( "active", mode == Simple ) ]
                        , onClick (ToggleMode Simple)
                        ]
                        [ text "Simples" ]
                    ]
                , li [ class "nav-item" ]
                    [ button
                        [ class "nav-link"
                        , classList [ ( "active", mode == Advanced ) ]
                        , onClick (ToggleMode Advanced)
                        ]
                        [ text "Avancées" ]
                    ]
                ]
            , div [ class "border border-top-0 rounded p-2" ]
                [ case mode of
                    Advanced ->
                        let
                            matomoBaseUrl =
                                "https://" ++ matomo.host ++ "/index.php?"
                        in
                        div []
                            [ div [ class "widgetIframe" ]
                                [ iframe
                                    [ attribute "crossorigin" "anonymous"
                                    , attribute "frameborder" "0"
                                    , attribute "height" "800"
                                    , attribute "marginheight" "0"
                                    , attribute "marginwidth" "0"
                                    , attribute "scrolling" "yes"
                                    , attribute "allowtransparency" "true"
                                    , style "background-color" "#f8f9fa"
                                    , [ ( "module", "Widgetize" )
                                      , ( "action", "iframe" )
                                      , ( "containerId", "VisitOverviewWithGraph" )
                                      , ( "disableLink", "0" )
                                      , ( "widget", "1" )
                                      , ( "moduleToWidgetize", "CoreHome" )
                                      , ( "actionToWidgetize", "renderWidgetContainer" )
                                      , ( "idSite", matomo.siteId )
                                      , ( "period", "day" )
                                      , ( "date", "yesterday" )
                                      , ( "disableLink", "1" )
                                      , ( "widget", "1" )
                                      ]
                                        |> List.map (\( key, val ) -> key ++ "=" ++ val)
                                        |> String.join "&"
                                        |> (++) matomoBaseUrl
                                        |> src
                                    , attribute "width" "100%"
                                    ]
                                    []
                                ]
                            , h2 [ class "h3" ] [ text "Traffic sur l'API" ]
                            , div [ class "widgetIframe" ]
                                [ iframe
                                    [ attribute "crossorigin" "anonymous"
                                    , attribute "frameborder" "0"
                                    , attribute "height" "450"
                                    , attribute "marginheight" "0"
                                    , attribute "marginwidth" "0"
                                    , attribute "scrolling" "yes"
                                    , attribute "allowtransparency" "true"
                                    , style "background-color" "#f8f9fa"
                                    , [ ( "module", "Widgetize" )
                                      , ( "action", "iframe" )
                                      , ( "containerId", "Goal_1" )
                                      , ( "disableLink", "0" )
                                      , ( "widget", "1" )
                                      , ( "moduleToWidgetize", "CoreHome" )
                                      , ( "actionToWidgetize", "renderWidgetContainer" )
                                      , ( "idSite", matomo.siteId )
                                      , ( "period", "day" )
                                      , ( "date", "yesterday" )
                                      , ( "disableLink", "1" )
                                      , ( "widget", "1" )
                                      ]
                                        |> List.map (\( key, val ) -> key ++ "=" ++ val)
                                        |> String.join "&"
                                        |> (++) matomoBaseUrl
                                        |> src
                                    , attribute "width" "100%"
                                    ]
                                    []
                                ]
                            ]

                    Simple ->
                        div []
                            [ webStats
                                |> viewStats { heading = "Fréquentation", unit = "visite" }
                            , apiStats
                                |> viewStats { heading = "Traffic sur l'API", unit = "requête" }
                            ]
                ]
            ]
      ]
    )
