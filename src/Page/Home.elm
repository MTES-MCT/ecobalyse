module Page.Home exposing (Model, Msg, init, update, view)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route


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
    ( "Home"
    , [ h2 [] [ text "Bienvenue sur Wikicarbone" ]
      , p [] [ text "Accélerer la mise en place de l'affichage environnemental" ]
      , a [ class "btn btn-primary me-2", Route.href (Route.Simulator Nothing) ] [ text "Faire une simulation" ]
      , a [ class "btn btn-secondary ms-2", Route.href Route.Examples ] [ text "voir des exemples" ]
      ]
    )
