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
view _ _ =
    ( "Statistiques"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Statistiques" ]
            , div [ class "border border-top-0 rounded p-2" ]
                [ iframe
                    [ attribute "plausible-embed" ""
                    , src "https://s.ecobalyse.incubateur.net/share/ecobalyse.beta.gouv.fr?auth=aXIS5ZeXacdSbZuetgS6W&embed=true&theme=light&background=%23ffffff"
                    , attribute "scrolling" "no"
                    , attribute "frameborder" "0"
                    , attribute "loading" "lazy"
                    , style "width" "1px"
                    , style "min-width" "100%"
                    , style "height" "1600px"
                    ]
                    []
                , div
                    [ style "font-size" "14px"
                    , style "padding-bottom" "14px"
                    ]
                    [ text "Stats powered by "
                    , a
                        [ target "_blank"
                        , style "color" "#4F46E5"
                        , style "text-decoration" "underline"
                        , href "https://plausible.io"
                        ]
                        [ text "Plausible Analytics" ]
                    ]
                , node "script"
                    [ attribute "async" ""
                    , src "https://s.ecobalyse.incubateur.net/js/embed.host.js"
                    ]
                    []
                ]
            ]
      ]
    )
