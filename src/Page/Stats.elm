module Page.Stats exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Alert as Alert
import Views.Container as Container


type alias Model =
    {}


type Msg
    = NoOp Never


init : Session -> PageUpdate Model Msg
init session =
    App.createUpdate session {}
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session _ model =
    App.createUpdate session model


view : Session -> Model -> ( String, List (Html Msg) )
view _ _ =
    ( "Statistiques"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Statistiques" ]
            , Alert.simple
                { attributes = []
                , close = Nothing
                , content = [ text "Les statistiques sont temporairement indisponibles" ]
                , level = Alert.Info
                , title = Nothing
                }
            ]
      ]
    )
