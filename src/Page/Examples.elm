module Page.Examples exposing (..)

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
    ( "Exemples"
    , [ div [ class "row mb-3" ]
            [ div [ class "col-md-7 col-lg-8 col-xl-9" ]
                [ h2 [] [ text "Exemples de simulation" ]
                ]
            , div [ class "col-md-5 col-lg-4 col-xl-3 text-center text-md-end" ]
                [ a
                    [ Route.href (Route.Simulator Nothing)
                    , class "btn btn-primary w-100"
                    ]
                    [ text "Faire une simulation" ]
                ]
            ]
      , Inputs.presets
            |> List.map (Simulator.fromInputs >> SummaryView.view True >> (\v -> div [ class "col" ] [ v ]))
            |> div [ class "row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4" ]
      , a [ Route.href Route.Home ] [ text "« Retour à l'accueil" ]
      ]
    )
