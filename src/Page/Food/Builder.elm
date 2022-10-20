module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Food.Db as FoodDb
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Ports
import RemoteData exposing (WebData)
import Request.Common
import Request.Food.Db as RequestDb
import Route
import Views.Container as Container
import Views.Spinner as Spinner


type alias Model =
    { dbState : WebData FoodDb.Db
    , query : Recipe.Query
    }


type Msg
    = DbLoaded (WebData FoodDb.Db)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    let
        model =
            { dbState = RemoteData.Loading
            , query = Recipe.empty
            }
    in
    if FoodDb.isEmpty session.foodDb then
        ( model
        , session
        , Cmd.batch
            [ Ports.scrollTo { x = 0, y = 0 }
            , RequestDb.loadDb session DbLoaded
            ]
        )

    else
        ( { model | dbState = RemoteData.Success session.foodDb }
        , session
        , Ports.scrollTo { x = 0, y = 0 }
        )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        DbLoaded dbState ->
            ( { model | dbState = dbState }
            , session
            , Cmd.none
            )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    let
        debugView : String -> Html Msg
        debugView =
            text >> List.singleton >> pre []
    in
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ h1 [ class "h2" ] [ text "TODO" ]
            , a [ class "btn btn-primary", Route.href Route.FoodExplore ] [ text "Explorateur de recettes" ]
            , h5 [ class "my-3" ] [ text "Debug" ]
            , case model.dbState of
                RemoteData.Success foodDb ->
                    div [ class "row" ]
                        [ div [ class "col-6" ]
                            [ Recipe.tunaPizza
                                |> Recipe.serialize
                                |> debugView
                            ]
                        , div [ class "col-6" ]
                            [ Recipe.tunaPizza
                                |> Recipe.compute foodDb
                                -- |> Debug.toString
                                |> Result.map (Impact.encodeImpacts >> Encode.encode 2)
                                |> Result.withDefault "Error serializing the impacts"
                                |> debugView
                            ]
                        ]

                RemoteData.Loading ->
                    Spinner.view

                RemoteData.Failure error ->
                    error
                        |> Request.Common.errorToString
                        |> text
                        |> List.singleton
                        |> div [ class "alert alert-danger" ]

                RemoteData.NotAsked ->
                    text "Shouldn't happen"
            ]
      ]
    )
