module Page.Home exposing (Model, Msg, init, update, view)

import Data.Inputs as Inputs
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Summary as SummaryView


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
    ( "Accueil"
    , [ div [ class "row align-items-center" ]
            [ div [ class "col-lg-7 text-center" ]
                [ h2 [ class "display-5" ]
                    [ text "Bienvenue sur Wikicarbone" ]
                , p [ class "fs-4 text-muted my-5" ]
                    [ text "Accélerer la mise en place de l'affichage environnemental" ]
                , div [ class "row mb-4" ]
                    [ div [ class "col-md-6 text-center text-md-end py-2" ]
                        [ a [ class "btn btn-lg btn-primary", Route.href (Route.Simulator Nothing) ]
                            [ text "Faire une simulation" ]
                        ]
                    , div [ class "col-md-6 text-center text-md-start py-2" ]
                        [ a [ class "btn btn-lg btn-secondary", Route.href Route.Examples ]
                            [ text "voir des exemples" ]
                        ]
                    ]
                ]
            , div [ class "col-lg-5" ]
                [ Inputs.tShirtCotonFrance
                    |> Simulator.compute
                    |> SummaryView.view False
                ]
            ]
      ]
    )
