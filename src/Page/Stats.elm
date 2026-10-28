module Page.Stats exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Container as Container
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = NoOp Never


init : Session -> PageUpdate Model Msg
init session =
    App.createUpdate session ()
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        NoOp _ ->
            App.createUpdate session model


view : Session -> Model -> ( String, List (Html Msg) )
view { plausible } _ =
    ( "Statistiques"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Statistiques" ]
            , div [ class "border rounded p-2" ] <|
                case plausible.host of
                    Just plausibleHost ->
                        [ iframe
                            [ attribute "plausible-embed" ""
                            , src <| "https://" ++ plausibleHost ++ "/share/ecobalyse.beta.gouv.fr?auth=x5YPtaLjZQymaV_F4p8NF&embed=true&theme=light"
                            , attribute "scrolling" "no"
                            , attribute "frameborder" "0"
                            , attribute "loading" "lazy"
                            , style "width" "1px"
                            , style "min-width" "100%"
                            , style "height" "2000px"
                            ]
                            [ div [ class "alert alert-info" ]
                                [ "Votre adblocker est activé. Veuillez le désactiver ou whitelister *https://"
                                    ++ plausibleHost
                                    ++ "* pour voir les statistiques."
                                    |> Markdown.simple []
                                ]
                            ]
                        , node "script"
                            [ attribute "async" ""
                            , src <| plausibleHost ++ "/js/embed.host.js"
                            ]
                            []
                        ]

                    Nothing ->
                        [ div [ class "alert alert-info" ]
                            [ text "⚠️ Le service de statistiques n’est pas configuré, affichage impossible." ]
                        ]
            ]
      ]
    )
