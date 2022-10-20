module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Food.Db as FoodDb
import Data.Food.Recipe as Recipe
import Data.Impact as Impact exposing (Impacts)
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Ports
import RemoteData exposing (WebData)
import Request.Common
import Request.Food.Db as RequestDb
import Route
import Views.Alert as Alert
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Spinner as Spinner


type alias Model =
    { dbState : WebData FoodDb.Db
    , query : Recipe.Query
    , impact : Impact.Trigram
    }


type Msg
    = DbLoaded (WebData FoodDb.Db)
    | LoadQuery Recipe.Query
    | NoOp
    | SwitchImpact Impact.Trigram


init : Session -> ( Model, Session, Cmd Msg )
init session =
    let
        model =
            { dbState = RemoteData.Loading
            , query = Recipe.tunaPizza
            , impact = Impact.defaultTrigram
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
            ( { model | dbState = dbState }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        LoadQuery query ->
            ( { model | query = query }, session, Cmd.none )

        SwitchImpact impact ->
            ( { model | impact = impact }, session, Cmd.none )


menuView : Recipe.Query -> Html Msg
menuView query =
    div [ class "d-flex gap-2" ]
        [ button
            [ class "btn btn-outline-primary"
            , classList [ ( "active", query == Recipe.tunaPizza ) ]
            , onClick (LoadQuery Recipe.tunaPizza)
            ]
            [ text "Pizza au Thon" ]
        , button
            [ class "btn btn-outline-primary"
            , classList [ ( "active", query == Recipe.empty ) ]
            , onClick (LoadQuery Recipe.empty)
            ]
            [ text "Créer une nouvelle recette" ]
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
            [ div [ class "col-7" ]
                [ query
                    |> Recipe.serialize
                    |> debugView
                ]
            , div [ class "col-5" ]
                [ query
                    |> Recipe.compute foodDb
                    -- |> Debug.toString
                    |> Result.map (Impact.encodeImpacts >> Encode.encode 2)
                    |> Result.withDefault "Error serializing the impacts"
                    |> debugView
                ]
            ]
        ]


viewSidebar : FoodDb.Db -> Model -> Impacts -> Html Msg
viewSidebar foodDb model impacts =
    let
        definition =
            foodDb.impacts
                |> Impact.getDefinition model.impact
                |> Result.withDefault Impact.invalid
    in
    div
        [ class "d-flex flex-column gap-3 mb-3 sticky-md-top"
        , style "top" "7px"
        ]
        [ ImpactView.impactSelector
            { impacts = foodDb.impacts
            , selectedImpact = model.impact
            , switchImpact = SwitchImpact

            -- We don't use the following two configs
            , selectedFunctionalUnit = Unit.PerItem
            , switchFunctionalUnit = always NoOp
            , scope = Impact.Food
            }
        , SummaryComp.view
            { header = []
            , body =
                [ div [ class "d-flex flex-column m-auto gap-1 px-2" ]
                    [ div [ class "display-4 lh-1 text-center text-nowrap" ]
                        [ impacts
                            |> Impact.getImpact model.impact
                            |> Unit.impactToFloat
                            |> Format.formatImpactFloat definition 2
                        ]
                    , small [ class "d-flex align-items-center gap-1" ]
                        [ Icon.warning
                        , text "Attention, ces résultats sont partiels"
                        ]
                    ]
                ]
            , footer = []
            }
        , a [ class "btn btn-primary", Route.href Route.FoodExplore ]
            [ text "Explorateur de recettes" ]
        ]


mainView : FoodDb.Db -> Model -> Html Msg
mainView foodDb model =
    div []
        [ div [ class "row gap-3 gap-lg-0" ]
            [ div [ class "col-lg-4 order-lg-2 d-flex flex-column gap-3" ]
                [ case Recipe.compute foodDb model.query of
                    Ok impacts ->
                        viewSidebar foodDb model impacts

                    Err error ->
                        Alert.simple
                            { level = Alert.Danger
                            , content = [ text error ]
                            , title = Nothing
                            , close = Nothing
                            }
                ]
            , div [ class "col-lg-8 order-lg-1 d-flex flex-column" ]
                [ menuView model.query
                , debugQueryView foodDb model.query
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ case model.dbState of
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
