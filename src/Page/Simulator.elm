module Page.Simulator exposing (Model, Msg, init, update, view)

import Data.Session exposing (Session, Store)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Route


type alias Model =
    Store


type Msg
    = UpdateMass Float


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( session.store, session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ store } as session) msg model =
    case msg of
        UpdateMass mass ->
            ( { model | mass = mass }
            , session
            , Cmd.none
            )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulator"
    , [ h1 [] [ text "Simulator" ]
      , div
            [ class "mb-3" ]
            [ label [ for "mass", class "form-label" ] [ text "Mass" ]
            , input
                [ type_ "number"
                , class "form-control"
                , id "mass"
                , Attr.min "0.1"
                , step "0.1"
                , value <| String.fromFloat model.mass
                , onInput (String.toFloat >> Maybe.withDefault 0 >> UpdateMass)
                ]
                []
            , div
                [ class "form-text" ]
                [ text "Mass of raw material, in kilograms" ]
            ]
      , p [] [ a [ Route.href Route.Home ] [ text "Back home" ] ]
      ]
    )
