module Page.Home exposing (Model, Msg, init, update, view)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.HttpClient as HttpClient
import Route


type alias Model =
    ()


type Msg
    = NoOp


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( (), session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session _ model =
    ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ _ =
    ( "Home"
    , [ h2 [] [ text "Welcome to Wikicarbone" ]
      , p [] [ text "Simulate the environmental footprint of common textile products" ]
      , a [ class "btn btn-success", Route.href Route.Simulator ] [ text "Make a simulation" ]
      ]
    )
