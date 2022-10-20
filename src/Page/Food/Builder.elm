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
import Html.Events exposing (..)
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
    | LoadQuery Recipe.Query


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

        LoadQuery query ->
            ( { model | query = query }
            , session
            , Cmd.none
            )


menuView : Html Msg
menuView =
    div [ class "d-flex gap-2" ]
        [ a [ class "btn btn-primary", Route.href Route.FoodExplore ]
            [ text "«\u{00A0}Explorateur de recettes" ]
        , button [ class "btn btn-outline-primary", onClick (LoadQuery Recipe.empty) ]
            [ text "Empty recipe" ]
        , button [ class "btn btn-outline-primary", onClick (LoadQuery Recipe.tunaPizza) ]
            [ text "Tuna Pizza" ]
        ]


debugQueryView : FoodDb.Db -> Recipe.Query -> Html Msg
debugQueryView foodDb query =
    let
        debugView =
            text >> List.singleton >> pre []
    in
    div []
        [ h5 [ class "my-3" ] [ text "Debug" ]
        , div [ class "row" ]
            [ div [ class "col-6" ]
                [ query
                    |> Recipe.serialize
                    |> debugView
                ]
            , div [ class "col-6" ]
                [ query
                    |> Recipe.compute foodDb
                    -- |> Debug.toString
                    |> Result.map (Impact.encodeImpacts >> Encode.encode 2)
                    |> Result.withDefault "Error serializing the impacts"
                    |> debugView
                ]
            ]
        ]


mainView : FoodDb.Db -> Model -> Html Msg
mainView foodDb model =
    div []
        [ debugQueryView foodDb model.query
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ h1 [ class "h2" ] [ text "TODO" ]
            , menuView
            , case model.dbState of
                RemoteData.Success foodDb ->
                    mainView foodDb model

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
