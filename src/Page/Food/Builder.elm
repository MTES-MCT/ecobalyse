module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Food.Db as FoodDb
import Data.Food.Process as Process exposing (Process)
import Data.Food.Recipe as Recipe exposing (Recipe)
import Data.Impact as Impact exposing (Impacts)
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
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
    , selectedIngredient : Maybe SelectedProcess
    , selectedTransform : Maybe SelectedProcess
    }


type alias SelectedProcess =
    { code : Process.Code
    , mass : Mass
    }


type Msg
    = AddIngredient SelectedProcess
    | DbLoaded (WebData FoodDb.Db)
    | DeleteIngredient Process.Code
    | LoadQuery Recipe.Query
    | NoOp
    | ResetTransform
    | SelectIngredient (Maybe SelectedProcess)
    | SelectTransform (Maybe SelectedProcess)
    | SetTransform SelectedProcess
    | SwitchImpact Impact.Trigram
    | UpdateIngredientMass Process.Code (Maybe Mass)
    | UpdateTransformMass (Maybe Mass)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    let
        model =
            { dbState = RemoteData.Loading
            , query = Recipe.tunaPizza
            , impact = Impact.defaultTrigram
            , selectedIngredient = Nothing
            , selectedTransform = Nothing
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
        AddIngredient { mass, code } ->
            ( { model
                | query =
                    model.query |> Recipe.addIngredient mass code
                , selectedIngredient = Nothing
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

        ResetTransform ->
            ( { model
                | query =
                    model.query
                        |> Recipe.resetTransform
              }
            , session
            , Cmd.none
            )

        SelectIngredient selectedIngredient ->
            ( { model | selectedIngredient = selectedIngredient }, session, Cmd.none )

        SelectTransform selectedTransform ->
            ( { model | selectedTransform = selectedTransform }, session, Cmd.none )

        SetTransform { mass, code } ->
            ( { model
                | query =
                    model.query
                        |> Recipe.setTransform mass code
                , selectedTransform = Nothing
              }
            , session
            , Cmd.none
            )

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

        UpdateTransformMass (Just mass) ->
            ( { model
                | query =
                    model.query
                        |> Recipe.updateTransformMass mass
              }
            , session
            , Cmd.none
            )

        UpdateTransformMass Nothing ->
            ( model, session, Cmd.none )



-- Views


type alias AddProcessConfig msg =
    { category : Process.Category
    , defaultMass : Mass
    , excluded : List Process.Code
    , foodDb : FoodDb.Db
    , noOp : msg
    , select : Maybe SelectedProcess -> msg
    , selectedProcess : Maybe SelectedProcess
    , submit : SelectedProcess -> msg
    }


addProcessFormView : AddProcessConfig Msg -> Html Msg
addProcessFormView { category, defaultMass, excluded, foodDb, noOp, select, selectedProcess, submit } =
    Html.form
        [ class "list-group list-group-flush border-top-0"
        , onSubmit
            (case selectedProcess of
                Just selected ->
                    submit selected

                Nothing ->
                    noOp
            )
        ]
        [ rowTemplate
            (MassInput.view
                { mass =
                    selectedProcess
                        |> Maybe.map .mass
                        |> Maybe.withDefault defaultMass
                , onChange =
                    \maybeMass ->
                        select
                            (case ( maybeMass, selectedProcess ) of
                                ( Just mass, Just selected ) ->
                                    Just { selected | mass = mass }

                                _ ->
                                    Nothing
                            )
                , disabled = selectedProcess == Nothing
                }
            )
            (foodDb.processes
                |> Process.listByCategory category
                |> List.sortBy (.name >> Process.nameToString)
                |> List.filter (\{ code } -> not (List.member code excluded))
                |> ingredientSelectorView (Maybe.map .code selectedProcess)
                    (\maybeCode ->
                        case ( selectedProcess, maybeCode ) of
                            ( Just selected, Just code ) ->
                                select (Just { selected | code = code })

                            ( Nothing, Just code ) ->
                                select (Just { code = code, mass = defaultMass })

                            _ ->
                                select Nothing
                    )
            )
            (button
                [ type_ "submit"
                , class "btn btn-primary no-outline"
                , title "Ajouter"
                , disabled <| selectedProcess == Nothing
                ]
                [ Icon.plus ]
            )
        ]


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


rowTemplate : Html Msg -> Html Msg -> Html Msg -> Html Msg
rowTemplate input content action =
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ span [ class "flex-shrink-1" ] [ input ]
        , span [ class "w-100" ] [ content ]
        , action
        ]


ingredientListView : FoodDb.Db -> Maybe SelectedProcess -> Recipe -> List (Html Msg)
ingredientListView foodDb selectedProcess recipe =
    [ div [ class "card-header" ] [ h6 [ class "mb-0" ] [ text "Ingrédients" ] ]
    , ul [ class "list-group list-group-flush" ]
        (if List.isEmpty recipe.ingredients then
            [ li [ class "list-group-item" ] [ text "Aucun ingrédient" ] ]

         else
            recipe.ingredients
                |> List.map
                    (\{ mass, process } ->
                        rowTemplate
                            (MassInput.view
                                { mass = mass
                                , onChange = UpdateIngredientMass process.code
                                , disabled = False
                                }
                            )
                            (text <| Process.nameToString process.name)
                            (button
                                [ type_ "button"
                                , class "btn btn-outline-primary no-outline"
                                , title "Supprimer"
                                , onClick (DeleteIngredient process.code)
                                ]
                                [ Icon.trash ]
                            )
                    )
        )
    , addProcessFormView
        { category = Process.Ingredient
        , defaultMass = Mass.grams 100
        , excluded = List.map (.process >> .code) recipe.ingredients
        , foodDb = foodDb
        , noOp = NoOp
        , select = SelectIngredient
        , selectedProcess = selectedProcess
        , submit = AddIngredient
        }
    ]


ingredientSelectorView : Maybe Process.Code -> (Maybe Process.Code -> msg) -> List Process -> Html msg
ingredientSelectorView selectedCode event =
    List.map
        (\{ code, name } ->
            let
                label =
                    Process.nameToString name
            in
            ( label
            , option
                [ selected <| selectedCode == Just code
                , value <| Process.codeToString code
                ]
                [ text label ]
            )
        )
        >> List.sortBy Tuple.first
        >> (++)
            [ ( "-- Sélectionner un ingrédient dans la liste --"
              , option [ Attr.selected <| selectedCode == Nothing ]
                    [ text "-- Sélectionnez un ingrédient et cliquez sur le bouton + pour l'ajouter" ]
              )
            ]
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        >> Keyed.node "select"
            [ class "form-select"
            , onInput
                (\str ->
                    event
                        (if str == "" then
                            Nothing

                         else
                            Just (Process.codeFromString str)
                        )
                )
            ]


mainView : FoodDb.Db -> Model -> Html Msg
mainView foodDb ({ selectedIngredient, selectedTransform } as model) =
    div [ class "row gap-3 gap-lg-0" ]
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
                    stepListView foodDb
                        { selectedIngredient = selectedIngredient
                        , selectedTransform = selectedTransform
                        }
                        recipe

                Err error ->
                    errorView error
            , debugQueryView foodDb model.query
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


processingView : FoodDb.Db -> Maybe SelectedProcess -> Recipe -> List (Html Msg)
processingView foodDb selectedProcess recipe =
    [ div [ class "card-header" ] [ h6 [ class "mb-0" ] [ text "Transformation" ] ]
    , case recipe.processing of
        Just { process, mass } ->
            ul [ class "list-group list-group-flush border-top-0" ]
                [ rowTemplate
                    (MassInput.view
                        { mass = mass
                        , onChange = UpdateTransformMass
                        , disabled = False
                        }
                    )
                    (text <| Process.nameToString process.name)
                    (button
                        [ type_ "button"
                        , class "btn btn-outline-primary no-outline"
                        , title "Supprimer"
                        , onClick ResetTransform
                        ]
                        [ Icon.trash ]
                    )
                ]

        Nothing ->
            addProcessFormView
                { category = Process.Transformation
                , defaultMass = Mass.grams 0
                , excluded = List.map (.process >> .code) recipe.ingredients
                , foodDb = foodDb
                , noOp = NoOp
                , select = SelectTransform
                , selectedProcess = selectedProcess
                , submit = SetTransform
                }
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


stepListView : FoodDb.Db -> { selectedIngredient : Maybe SelectedProcess, selectedTransform : Maybe SelectedProcess } -> Recipe -> Html Msg
stepListView foodDb { selectedIngredient, selectedTransform } recipe =
    div [ class "d-flex flex-column gap-3" ]
        [ div [ class "card" ]
            (div [ class "card-header" ]
                [ h5 [ class "mb-0" ] [ text "Recette" ]
                ]
                :: List.concat
                    [ ingredientListView foodDb selectedIngredient recipe
                    , processingView foodDb selectedTransform recipe
                    ]
            )
        , div [ class "card" ]
            [ div [ class "card-header" ]
                [ h5 [ class "mb-0" ] [ text "Conditionnement" ]
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
