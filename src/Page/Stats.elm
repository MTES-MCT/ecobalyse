module Page.Stats exposing (..)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Container as Container



-- import Views.ElmChartsBug as ElmChartsBug


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


view : Session -> Model -> ( String, List (Html Msg) )
view _ _ =
    ( "Statistiques"
    , [ Container.centered []
            [ h1 [ class "mb-3" ] [ text "Statistiques" ]

            -- , div [ style "width" "500px", style "height" "500px", class "my-5" ]
            --     [ ElmChartsBug.chart
            --     ]
            , div [ id "widgetIframe" ]
                [ iframe
                    [ attribute "frameborder" "0"
                    , attribute "height" "850"
                    , attribute "marginheight" "0"
                    , attribute "marginwidth" "0"
                    , attribute "scrolling" "yes"
                    , attribute "allowtransparency" "true"
                    , style "background-color" "#f8f9fa"
                    , src "https://stats.data.gouv.fr/index.php?module=Widgetize&action=iframe&containerId=VisitOverviewWithGraph&disableLink=0&widget=1&moduleToWidgetize=CoreHome&actionToWidgetize=renderWidgetContainer&idSite=196&period=day&date=yesterday&disableLink=1&widget=1"
                    , attribute "width" "100%"
                    ]
                    []
                ]
            ]
      ]
    )
