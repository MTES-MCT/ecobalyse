module Page.Examples exposing (..)

import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Container as Container
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


viewExamples : Session -> Html Msg
viewExamples session =
    div []
        [ div [ class "row mb-3" ]
            [ div [ class "col-md-7 col-lg-8 col-xl-9" ]
                [ h1 [ class "mb-3" ] [ text "Exemples de simulation" ]
                ]
            , div [ class "col-md-5 col-lg-4 col-xl-3 text-center text-md-end" ]
                [ a
                    [ Route.href (Route.Simulator Nothing)
                    , class "btn btn-primary w-100"
                    ]
                    [ text "Faire une simulation" ]
                ]
            ]
        , Inputs.presets Impact.defaultTrigram
            |> List.map
                (Simulator.compute session.db
                    >> SummaryView.view
                        { session = session
                        , impact = Impact.default
                        , reusable = True
                        }
                    >> (\v -> div [ class "col" ] [ v ])
                )
            |> div [ class "row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4" ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session _ =
    ( "Exemples"
    , [ Container.centered [ class "pb-5" ]
            [ viewExamples session
            ]
      ]
    )
