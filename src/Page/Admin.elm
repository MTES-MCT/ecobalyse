module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import List.Extra as LE
import Ports
import RemoteData exposing (WebData)
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown
import Views.Spinner as Spinner


type alias Model =
    {}


type Msg
    = NoOp


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( {}
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "admin", [ text "Hello world" ] )
