module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Food.Db as FoodDb
import Data.Food.Process as Process
import Data.Food.Recipe as Recipe exposing (Recipe)
import Data.Impact as Impact exposing (Impacts)
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Mass exposing (Mass)
import Ports
import RemoteData exposing (WebData)
import Request.Common
import Request.Food.Db as RequestDb
import Route
import Views.Alert as Alert
import Views.Component.MassInput as MassInput
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
    = AddIngredient Mass Process.Code
    | DbLoaded (WebData FoodDb.Db)
    | DeleteIngredient Process.Code
    | LoadQuery Recipe.Query
    | NoOp
    | SwitchImpact Impact.Trigram
    | UpdateIngredientMass Process.Code (Maybe Mass)


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
        AddIngredient mass code ->
            ( { model
                | query =
                    model.query |> Recipe.addIngredient mass code
              }
            , session
            , Cmd.none
            )

        DbLoaded dbState ->
            ( { model | dbState = dbState }, session, Cmd.none )

        DeleteIngredient code ->
            ( { model
                | query =
                    model.query
                        |> Recipe.deleteIngredient code
              }
            , session
            , Cmd.none
            )

        NoOp ->
            ( model, session, Cmd.none )

        LoadQuery query ->
            ( { model | query = query }, session, Cmd.none )

        SwitchImpact impact ->
            ( { model | impact = impact }, session, Cmd.none )

        UpdateIngredientMass code (Just mass) ->
            ( { model
                | query =
                    model.query
                        |> Recipe.updateIngredientMass mass code
              }
            , session
            , Cmd.none
            )

        UpdateIngredientMass _ Nothing ->
            ( model, session, Cmd.none )



-- Views


debugQueryView : FoodDb.Db -> Recipe.Query -> Html Msg
debugQueryView foodDb query =
    let
        debugView =
            text >> List.singleton >> pre []
    in
    details []
        [ summary [] [ text "Debug" ]
        , div [ class "row" ]
            [ div [ class "col-7" ]
                [ query
                    |> Recipe.serialize
                    |> debugView
                ]
            , div [ class "col-5" ]
                [ query
                    |> Recipe.compute foodDb
                    |> Result.map (Impact.encodeImpacts >> Encode.encode 2)
                    |> Result.withDefault "Error serializing the impacts"
                    |> debugView
                ]
            ]
        ]


errorView : String -> Html Msg
errorView error =
    Alert.simple
        { level = Alert.Danger
        , content = [ text error ]
        , title = Nothing
        , close = Nothing
        }


ingredientListView : Recipe -> List (Html Msg)
ingredientListView recipe =
    [ div [ class "card-header" ] [ h6 [ class "mb-0" ] [ text "Ingrédients" ] ]
    , ul [ class "list-group list-group-flush" ]
        (if List.isEmpty recipe.ingredients then
            [ li [ class "list-group-item" ] [ text "Aucun ingrédient" ] ]

         else
            recipe.ingredients
                |> List.map
                    (\{ mass, process } ->
                        li [ class "list-group-item d-flex align-items-center gap-2" ]
                            [ span [ class "flex-shrink-1" ]
                                [ MassInput.view
                                    { mass = mass
                                    , onChange = UpdateIngredientMass process.code
                                    }
                                ]
                            , span [ class "w-100" ] [ text <| Process.nameToString process.name ]
                            , button
                                [ type_ "button"
                                , class "btn btn-outline-primary no-outline"
                                , title "Supprimer"
                                , onClick (DeleteIngredient process.code)
                                ]
                                [ Icon.trash ]
                            ]
                    )
        )
    ]


mainView : FoodDb.Db -> Model -> Html Msg
mainView foodDb model =
    div []
        [ div [ class "row gap-3 gap-lg-0" ]
            [ div [ class "col-lg-4 order-lg-2 d-flex flex-column gap-3" ]
                [ case Recipe.compute foodDb model.query of
                    Ok impacts ->
                        sidebarView foodDb model impacts

                    Err error ->
                        errorView error
                ]
            , div [ class "col-lg-8 order-lg-1 d-flex flex-column gap-3" ]
                [ menuView model.query
                , case Recipe.fromQuery foodDb model.query of
                    Ok recipe ->
                        stepListView recipe

                    Err error ->
                        errorView error
                , debugQueryView foodDb model.query
                ]
            ]
        ]


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


processingView : Recipe -> List (Html Msg)
processingView recipe =
    [ div [ class "card-header" ] [ h6 [ class "mb-0" ] [ text "Transformation" ] ]
    , div [ class "card-body" ]
        [ case recipe.processing of
            Just { process } ->
                text <| Process.nameToString process.name

            Nothing ->
                text "Aucun procédé de transformation mobilisé"
        ]
    ]


sidebarView : FoodDb.Db -> Model -> Impacts -> Html Msg
sidebarView foodDb model impacts =
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


stepListView : Recipe -> Html Msg
stepListView recipe =
    div [ class "d-flex flex-column gap-3" ]
        [ div [ class "card" ]
            (div [ class "card-header" ]
                [ h4 [ class "mb-0" ] [ text "Recette" ]
                ]
                :: List.concat
                    [ ingredientListView recipe
                    , processingView recipe
                    ]
            )
        , div [ class "card" ]
            [ div [ class "card-header" ]
                [ h4 [ class "mb-0" ] [ text "Conditionnement" ]
                ]
            , div [ class "card-body" ] [ text "TODO" ]
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
