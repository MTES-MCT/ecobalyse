module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Food.Recipe as Recipe
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Route
import Views.Container as Container


type alias Model =
    ()


type Msg
    = NoOp Never


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( ()
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session _ model =
    ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ _ =
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ h1 [ class "h2" ] [ text "TODO" ]
            , a [ class "btn btn-primary", Route.href Route.FoodExplore ] [ text "Explorateur de recettes" ]
            , h5 [ class "my-3" ] [ text "Debug" ]
            , Recipe.example
                |> Recipe.serialize
                -- |> Debug.toString
                |> text
                |> List.singleton
                |> pre []
            ]
      ]
    )
