module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation as Navigation
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country exposing (Country)
import Data.Food.Builder.Db as BuilderDb exposing (Db)
import Data.Food.Builder.Query as Query exposing (Query)
import Data.Food.Builder.Recipe as Recipe exposing (Recipe)
import Data.Food.Ingredient as Ingredient exposing (Id, Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact exposing (Impacts)
import Data.Session as Session exposing (Session)
import Data.Transport exposing (Distances)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Json.Encode as Encode
import Mass exposing (Mass)
import Page.Textile.Simulator.ViewMode as ViewMode
import Ports
import RemoteData exposing (WebData)
import Request.Common
import Request.Food.BuilderDb as RequestDb
import Route
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.Bookmark as BookmarkView
import Views.Component.MassInput as MassInput
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.CountrySelect
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Spinner as Spinner


type alias Model =
    { dbState : WebData Db
    , impact : Impact.Definition
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , selectedPackaging : Maybe SelectedProcess
    , selectedTransform : Maybe SelectedProcess
    }


type alias SelectedProcess =
    { code : Process.Code
    , mass : Mass
    }


type Msg
    = AddIngredient
    | AddPackaging SelectedProcess
    | CopyToClipBoard String
    | DbLoaded (WebData Db)
    | DeleteBookmark Bookmark
    | DeleteIngredient Query.IngredientQuery
    | DeletePackaging Process.Code
    | LoadQuery Query
    | NoOp
    | ResetTransform
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectPackaging (Maybe SelectedProcess)
    | SelectTransform (Maybe SelectedProcess)
    | SetTransform SelectedProcess
    | SwitchLinksTab BookmarkView.ActiveTab
    | SwitchImpact Impact.Trigram
    | UpdateBookmarkName String
    | UpdateIngredient Id Query.IngredientQuery
    | UpdatePackagingMass Process.Code (Maybe Mass)
    | UpdateTransformMass (Maybe Mass)


init : Session -> Impact.Trigram -> Maybe Query -> ( Model, Session, Cmd Msg )
init ({ db, builderDb, queries } as session) trigram maybeQuery =
    let
        impact =
            db.impacts
                |> Impact.getDefinition trigram
                |> Result.withDefault Impact.invalid

        query =
            maybeQuery
                |> Maybe.withDefault queries.food

        ( model, newSession, cmds ) =
            ( { dbState = RemoteData.Loading
              , impact = impact
              , bookmarkName = query |> findExistingBookmarkName session
              , bookmarkTab = BookmarkView.SaveTab
              , selectedTransform = Nothing
              , selectedPackaging = Nothing
              }
            , session |> Session.updateFoodQuery query
            , case maybeQuery of
                Nothing ->
                    Ports.scrollTo { x = 0, y = 0 }

                Just _ ->
                    Cmd.none
            )
    in
    if BuilderDb.isEmpty builderDb then
        ( model
        , newSession
        , Cmd.batch [ cmds, RequestDb.loadDb session DbLoaded ]
        )

    else
        ( { model | dbState = RemoteData.Success builderDb }
        , newSession
        , cmds
        )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ queries } as session) msg model =
    let
        query =
            queries.food
    in
    case msg of
        AddIngredient ->
            let
                firstIngredient =
                    session.builderDb.ingredients
                        |> Recipe.availableIngredients (List.map .id query.ingredients)
                        |> List.head
                        |> Maybe.map Recipe.ingredientQueryFromIngredient
            in
            ( model, session, Cmd.none )
                |> (case firstIngredient of
                        Just ingredient ->
                            updateQuery (Query.addIngredient ingredient query)

                        Nothing ->
                            identity
                   )

        AddPackaging { mass, code } ->
            ( { model | selectedPackaging = Nothing }, session, Cmd.none )
                |> updateQuery (Recipe.addPackaging mass code query)

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        DbLoaded dbState ->
            ( { model | dbState = dbState }
            , case dbState of
                RemoteData.Success db ->
                    { session | builderDb = db }

                _ ->
                    session
            , Cmd.none
            )

        DeleteIngredient ingredientQuery ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.deleteIngredient ingredientQuery query)

        DeleteBookmark bookmark ->
            updateQuery query
                ( model
                , session |> Session.deleteBookmark bookmark
                , Cmd.none
                )

        DeletePackaging code ->
            ( model, session, Cmd.none )
                |> updateQuery (Recipe.deletePackaging code query)

        NoOp ->
            ( model, session, Cmd.none )

        LoadQuery queryToLoad ->
            ( model, session, Cmd.none )
                |> updateQuery queryToLoad

        ResetTransform ->
            ( model, session, Cmd.none )
                |> updateQuery (Recipe.resetTransform query)

        SaveBookmark ->
            ( model
            , session
            , Time.now
                |> Task.perform
                    (SaveBookmarkWithTime model.bookmarkName
                        (Bookmark.Food query)
                    )
            )

        SaveBookmarkWithTime name foodQuery now ->
            ( model
            , session
                |> Session.saveBookmark
                    { name = String.trim name
                    , query = foodQuery
                    , created = now
                    }
            , Cmd.none
            )

        SelectPackaging selectedPackaging ->
            ( { model | selectedPackaging = selectedPackaging }, session, Cmd.none )

        SelectTransform Nothing ->
            ( { model | selectedTransform = Nothing }, session, Cmd.none )
                |> updateQuery { query | transform = Nothing }

        SelectTransform (Just { mass, code }) ->
            ( { model | selectedTransform = Nothing }, session, Cmd.none )
                |> updateQuery (Recipe.setTransform mass code query)

        SetTransform { mass, code } ->
            ( { model | selectedTransform = Nothing }, session, Cmd.none )
                |> updateQuery (Recipe.setTransform mass code query)

        SwitchImpact impact ->
            ( model
            , session
            , Just query
                |> Route.FoodBuilder impact
                |> Route.toString
                |> Navigation.pushUrl session.navKey
            )

        SwitchLinksTab bookmarkTab ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        UpdateBookmarkName recipeName ->
            ( { model | bookmarkName = recipeName }, session, Cmd.none )

        UpdateIngredient oldIngredientId newIngredient ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateIngredient oldIngredientId newIngredient query)

        UpdatePackagingMass code (Just mass) ->
            ( model, session, Cmd.none )
                |> updateQuery (Recipe.updatePackagingMass mass code query)

        UpdatePackagingMass _ Nothing ->
            ( model, session, Cmd.none )

        UpdateTransformMass (Just mass) ->
            ( model, session, Cmd.none )
                |> updateQuery (Recipe.updateTransformMass mass query)

        UpdateTransformMass Nothing ->
            ( model, session, Cmd.none )


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    ( { model | bookmarkName = query |> findExistingBookmarkName session }
    , session |> Session.updateFoodQuery query
    , msg
    )


findExistingBookmarkName : Session -> Query -> String
findExistingBookmarkName { db, builderDb, store } query =
    store.bookmarks
        |> Bookmark.findByFoodQuery query
        |> Maybe.map .name
        |> Maybe.withDefault
            (query
                |> Recipe.fromQuery builderDb db.countries
                |> Result.map Recipe.toString
                |> Result.withDefault ""
            )



-- Views


type alias AddProcessConfig msg =
    { category : Process.Category
    , defaultMass : Mass
    , excluded : List Process.Code
    , db : Db
    , kind : String
    , noOp : msg
    , select : Maybe SelectedProcess -> msg
    , selectedProcess : Maybe SelectedProcess
    , submit : SelectedProcess -> msg
    }


addProcessFormView : AddProcessConfig Msg -> Html Msg
addProcessFormView { category, defaultMass, excluded, db, kind, noOp, select, selectedProcess, submit } =
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
            (db.processes
                |> Process.listByCategory category
                |> List.sortBy Process.getDisplayName
                |> List.filter (\{ code } -> not (List.member code excluded))
                |> processSelectorView kind
                    (Maybe.map .code selectedProcess)
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
                , class "btn btn-sm btn-primary"
                , title <| "Ajouter " ++ kind
                , disabled <| selectedProcess == Nothing
                ]
                [ Icon.plus ]
            )
        ]


type alias UpdateIngredientConfig =
    { excluded : List Id
    , db : Db
    , ingredient : Recipe.RecipeIngredient
    , countries : List Country
    }


updateIngredientFormView : UpdateIngredientConfig -> Html Msg
updateIngredientFormView { excluded, db, ingredient, countries } =
    let
        ingredientQuery : Query.IngredientQuery
        ingredientQuery =
            { id = ingredient.ingredient.id
            , name = ingredient.ingredient.name
            , mass = ingredient.mass
            , variant = ingredient.variant
            , country = ingredient.country.code
            }

        event =
            UpdateIngredient ingredient.ingredient.id
    in
    rowTemplate
        (MassInput.view
            { mass =
                ingredient.mass
            , onChange =
                \maybeMass ->
                    case maybeMass of
                        Just mass ->
                            event { ingredientQuery | mass = mass }

                        _ ->
                            NoOp
            , disabled = False
            }
        )
        (db.ingredients
            |> List.sortBy .name
            |> ingredientSelectorView
                ingredient.ingredient.id
                excluded
                (\newIngredient ->
                    let
                        newVariant =
                            case ingredientQuery.variant of
                                Query.Default ->
                                    Query.Default

                                Query.Organic ->
                                    if newIngredient.variants.organic == Nothing then
                                        -- Fallback to "Default" if the new ingredient doesn't have an "organic" variant
                                        Query.Default

                                    else
                                        Query.Organic
                    in
                    event
                        { ingredientQuery
                            | id = newIngredient.id
                            , name = newIngredient.name
                            , variant = newVariant
                        }
                )
        )
        (span
            [ class "flex-grow-1 d-flex align-items-center gap-2"
            , classList [ ( "text-muted", ingredient.ingredient.variants.organic == Nothing ) ]
            ]
            [ label [ class "w-25" ]
                [ input
                    [ type_ "checkbox"
                    , class "form-check-input m-1"
                    , attribute "role" "switch"
                    , checked <| ingredient.variant == Query.Organic
                    , disabled <| ingredient.ingredient.variants.organic == Nothing
                    , onCheck
                        (\checked ->
                            { ingredientQuery
                                | variant =
                                    if checked then
                                        Query.Organic

                                    else
                                        Query.Default
                            }
                                |> event
                        )
                    ]
                    []
                , text "bio"
                ]
            , Views.CountrySelect.view
                { attributes = [ class "form-select form-select-sm" ]
                , onSelect =
                    \countryCode ->
                        event { ingredientQuery | country = countryCode }
                , selectedCountry = ingredientQuery.country
                , countries = countries
                }
            , button
                [ type_ "button"
                , class "btn btn-sm btn-outline-primary"
                , title <| "Supprimer "
                , onClick <| DeleteIngredient ingredientQuery
                ]
                [ Icon.trash ]
            ]
        )


debugQueryView : Db -> Distances -> List Country -> Query -> Html Msg
debugQueryView db distances countries query =
    let
        debugView =
            text >> List.singleton >> pre []
    in
    details []
        [ summary [] [ text "Debug" ]
        , div [ class "row" ]
            [ div [ class "col-7" ]
                [ query
                    |> Recipe.serializeQuery
                    |> debugView
                ]
            , div [ class "col-5" ]
                [ query
                    |> Recipe.compute db distances countries
                    |> Result.map (Tuple.second >> Recipe.encodeResults db.impacts >> Encode.encode 2)
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


ingredientListView : Db -> List Country -> Impact.Definition -> Recipe -> Recipe.Results -> List (Html Msg)
ingredientListView db countries selectedImpact recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h6 [ class "mb-0" ] [ text "Ingrédients" ]
        , results.recipe.ingredients
            |> Format.formatFoodSelectedImpact selectedImpact
        ]
    , ul [ class "list-group list-group-flush" ]
        ((if List.isEmpty recipe.ingredients then
            [ li [ class "list-group-item" ] [ text "Aucun ingrédient" ] ]

          else
            recipe.ingredients
                |> List.map
                    (\ingredient ->
                        updateIngredientFormView
                            { excluded = recipe.ingredients |> List.map (.ingredient >> .id)
                            , db = db
                            , ingredient = ingredient
                            , countries = countries
                            }
                    )
         )
            ++ [ li [ class "list-group-item" ]
                    [ button
                        [ class "btn btn-outline-primary"
                        , class "d-flex justify-content-center align-items-center"
                        , class " gap-1 w-100"
                        , disabled <|
                            (db.ingredients
                                |> Recipe.availableIngredients (List.map (.ingredient >> .id) recipe.ingredients)
                                |> List.isEmpty
                            )
                        , onClick AddIngredient
                        ]
                        [ i [ class "icon icon-plus" ] []
                        , text "Ajouter un ingrédient"
                        ]
                    ]
               ]
        )
    ]


packagingListView : Db -> Impact.Definition -> Maybe SelectedProcess -> Recipe -> Recipe.Results -> List (Html Msg)
packagingListView db selectedImpact selectedProcess recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h5 [ class "mb-0" ] [ text "Emballage" ]
        , results.packaging
            |> Format.formatFoodSelectedImpact selectedImpact
        ]
    , ul [ class "list-group list-group-flush" ]
        (if List.isEmpty recipe.packaging then
            [ li [ class "list-group-item" ] [ text "Aucun emballage" ] ]

         else
            recipe.packaging
                |> List.map
                    (\({ mass, process } as packaging) ->
                        rowTemplate
                            (MassInput.view
                                { mass = mass
                                , onChange = UpdatePackagingMass process.code
                                , disabled = False
                                }
                            )
                            (small [] [ text <| Process.getDisplayName process ])
                            (div [ class "d-flex flex-nowrap align-items-center gap-2 fs-7 text-nowrap" ]
                                [ packaging
                                    |> Recipe.computeProcessImpacts db.impacts
                                    |> Format.formatFoodSelectedImpact selectedImpact
                                , button
                                    [ type_ "button"
                                    , class "btn btn-sm btn-outline-primary"
                                    , title "Supprimer"
                                    , onClick (DeletePackaging process.code)
                                    ]
                                    [ Icon.trash ]
                                ]
                            )
                    )
        )
    , addProcessFormView
        { category = Process.Packaging
        , defaultMass = Mass.grams 100
        , excluded = List.map (.process >> .code) recipe.packaging
        , db = db
        , kind = "un emballage"
        , noOp = NoOp
        , select = SelectPackaging
        , selectedProcess = selectedProcess
        , submit = AddPackaging
        }
    ]


mainView : Session -> Db -> Model -> Html Msg
mainView session db model =
    let
        computed =
            Recipe.compute db session.db.transports session.db.countries session.queries.food
    in
    div [ class "row gap-3 gap-lg-0" ]
        [ div [ class "col-lg-4 order-lg-2 d-flex flex-column gap-3" ]
            [ case computed of
                Ok ( _, results ) ->
                    sidebarView session db model results

                Err error ->
                    errorView error
            ]
        , div [ class "col-lg-8 order-lg-1 d-flex flex-column gap-3" ]
            [ menuView session.queries.food
            , case computed of
                Ok ( recipe, results ) ->
                    stepListView db session.db.countries model recipe results

                Err error ->
                    errorView error
            , debugQueryView db session.db.transports session.db.countries session.queries.food
            ]
        ]


menuView : Query -> Html Msg
menuView query =
    div [ class "d-flex gap-2" ]
        [ button
            [ class "btn btn-outline-primary"
            , classList [ ( "active", query == Query.carrotCake ) ]
            , onClick (LoadQuery Query.carrotCake)
            ]
            [ text "Carrot Cake" ]
        , button
            [ class "btn btn-outline-primary"
            , classList [ ( "active", query == Query.emptyQuery ) ]
            , onClick (LoadQuery Query.emptyQuery)
            ]
            [ text "Créer une nouvelle recette" ]
        ]


processSelectorView : String -> Maybe Process.Code -> (Maybe Process.Code -> msg) -> List Process -> Html msg
processSelectorView kind selectedCode event =
    List.map
        (\process ->
            let
                label =
                    Process.getDisplayName process
            in
            ( label
            , option
                [ selected <| selectedCode == Just process.code
                , value <| Process.codeToString process.code
                ]
                [ text label ]
            )
        )
        >> List.sortBy Tuple.first
        >> (++)
            [ ( ""
              , option [ Attr.selected <| selectedCode == Nothing, value "" ]
                    [ text <| "-- Sélectionnez " ++ kind ++ " et cliquez sur le bouton + pour l'ajouter" ]
              )
            ]
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        >> Keyed.node "select"
            [ class "form-select form-select-sm"
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


ingredientSelectorView : Id -> List Id -> (Ingredient -> Msg) -> List Ingredient -> Html Msg
ingredientSelectorView selectedIngredient excluded event ingredients =
    ingredients
        |> List.map
            (\ingredient ->
                ( ingredient.name
                , option
                    [ selected <| selectedIngredient == ingredient.id
                    , disabled <| List.member ingredient.id excluded
                    , value <| Ingredient.idToString ingredient.id
                    ]
                    [ text ingredient.name ]
                )
            )
        |> List.sortBy Tuple.first
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        |> Keyed.node "select"
            [ class "form-select form-select-sm flex-grow-1"
            , onInput
                (\ingredientId ->
                    case Ingredient.findByID (Ingredient.idFromString ingredientId) ingredients of
                        Ok newIngredient ->
                            event newIngredient

                        Err _ ->
                            NoOp
                )
            ]


rowTemplate : Html Msg -> Html Msg -> Html Msg -> Html Msg
rowTemplate input content action =
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ span [ class "MassInputWrapper flex-shrink-1" ] [ input ]
        , span [ class "flex-grow-1" ] [ content ]
        , action
        ]


sidebarView : Session -> Db -> Model -> Recipe.Results -> Html Msg
sidebarView session db model results =
    div
        [ class "d-flex flex-column gap-3 mb-3 sticky-md-top"
        , style "top" "7px"
        ]
        [ ImpactView.impactSelector
            { impacts = db.impacts
            , selectedImpact = model.impact.trigram
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
                        [ results.impacts
                            |> Format.formatFoodSelectedImpact model.impact
                        ]
                    , small [ class "d-flex align-items-center gap-1" ]
                        [ Icon.warning
                        , text "Attention, ce résultat est partiel"
                        ]
                    ]
                ]
            , footer = []
            }
        , stepResultsView db model results
        , protectionAreaView session results.impacts
        , BookmarkView.view
            { session = session
            , activeTab = model.bookmarkTab
            , bookmarkName = model.bookmarkName
            , impact = model.impact
            , funit = Unit.PerItem
            , scope = BookmarkView.Food
            , viewMode = ViewMode.Simple
            , copyToClipBoard = CopyToClipBoard
            , compare = NoOp
            , delete = DeleteBookmark
            , save = SaveBookmark
            , update = UpdateBookmarkName
            , switchTab = SwitchLinksTab
            }
        , a [ class "btn btn-primary", Route.href Route.FoodExplore ]
            [ text "Explorateur de recettes" ]
        ]


protectionAreaView : Session -> Impacts -> Html Msg
protectionAreaView { db } impacts =
    let
        protectionAreaScores =
            impacts
                |> Impact.toProtectionAreas db.impacts

        ecoscoreDefinition =
            db.impacts
                |> Impact.getDefinition (Impact.trg "ecs")
                |> Result.withDefault Impact.invalid
    in
    div [ class "card" ]
        [ div [ class "card-header" ] [ text "Aires de protection" ]
        , [ ( "Climat", protectionAreaScores.climate )
          , ( "Biodiversité", protectionAreaScores.biodiversity )
          , ( "Santé environnementale", protectionAreaScores.health )
          , ( "Ressource", protectionAreaScores.resources )
          ]
            |> List.map
                (\( label, score ) ->
                    li [ class "list-group-item d-flex justify-content-between align-items-center gap-1" ]
                        [ text label
                        , Format.formatImpact ecoscoreDefinition score
                        ]
                )
            |> ul [ class "list-group list-group-flush fs-7" ]
        ]


stepListView : Db -> List Country -> Model -> Recipe -> Recipe.Results -> Html Msg
stepListView db countries { impact, selectedPackaging, selectedTransform } recipe results =
    div [ class "d-flex flex-column gap-3" ]
        [ div [ class "card" ]
            (div [ class "card-header d-flex align-items-center justify-content-between" ]
                [ h5 [ class "mb-0" ] [ text "Recette" ]
                , Recipe.recipeStepImpacts db results
                    |> Format.formatFoodSelectedImpact impact
                    |> List.singleton
                    |> span [ class "fw-bold" ]
                ]
                :: List.concat
                    [ ingredientListView db countries impact recipe results
                    , transformView db impact selectedTransform recipe results
                    ]
            )
        , div [ class "card" ]
            (packagingListView db impact selectedPackaging recipe results)
        ]


stepResultsView : Db -> Model -> Recipe.Results -> Html Msg
stepResultsView db model results =
    let
        toFloat =
            Impact.getImpact model.impact.trigram >> Unit.impactToFloat

        stepsData =
            [ { label = "Recette"
              , impact = toFloat <| Recipe.recipeStepImpacts db results
              }
            , { label = "Emballage"
              , impact = toFloat results.packaging
              }
            ]

        totalImpact =
            toFloat results.impacts
    in
    div [ class "card" ]
        [ div [ class "card-header" ] [ text "Étapes du cycle de vie" ]
        , stepsData
            |> List.map
                (\{ label, impact } ->
                    let
                        percent =
                            if totalImpact /= 0 then
                                impact / totalImpact * 100

                            else
                                0
                    in
                    li [ class "list-group-item d-flex justify-content-between align-items-center gap-1" ]
                        [ span [ class "flex-fill w-33 text-truncate" ] [ text label ]
                        , span [ class "flex-fill w-50" ]
                            [ div [ class "progress", style "height" "13px" ]
                                [ div
                                    [ class "progress-bar"
                                    , style "width" (String.fromFloat percent ++ "%")
                                    ]
                                    []
                                ]
                            ]
                        , span [ class "flex-fill text-end", style "min-width" "62px" ]
                            [ Format.percent percent
                            ]
                        ]
                )
            |> ul [ class "list-group list-group-flush fs-7" ]
        ]


transformView : Db -> Impact.Definition -> Maybe SelectedProcess -> Recipe -> Recipe.Results -> List (Html Msg)
transformView db selectedImpact selectedProcess recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h6 [ class "mb-0" ] [ text "Transformation" ]
        , results.recipe.transform
            |> Format.formatFoodSelectedImpact selectedImpact
        ]
    , case recipe.transform of
        Just ({ process, mass } as transform) ->
            ul [ class "list-group list-group-flush border-top-0" ]
                [ rowTemplate
                    (MassInput.view
                        { mass = mass
                        , onChange = UpdateTransformMass
                        , disabled = False
                        }
                    )
                    (small [] [ text <| Process.getDisplayName process ])
                    (div [ class "d-flex flex-nowrap align-items-center gap-2 fs-7 text-nowrap" ]
                        [ transform
                            |> Recipe.computeProcessImpacts db.impacts
                            |> Format.formatFoodSelectedImpact selectedImpact
                        , button
                            [ type_ "button"
                            , class "btn btn-sm btn-outline-primary"
                            , title "Supprimer"
                            , onClick ResetTransform
                            ]
                            [ Icon.trash ]
                        ]
                    )
                ]

        Nothing ->
            addProcessFormView
                { category = Process.Transform
                , defaultMass = Recipe.sumMasses recipe.ingredients
                , excluded =
                    recipe.transform
                        |> Maybe.map (.process >> .code >> List.singleton)
                        |> Maybe.withDefault []
                , db = db
                , kind = "une transformation"
                , noOp = NoOp
                , select = SelectTransform
                , selectedProcess = selectedProcess
                , submit = SetTransform
                }
    , div [ class "card-body d-flex align-items-center gap-1 text-muted py-2" ]
        [ Icon.info
        , small [] [ text "Entrez la masse totale mobilisée par le procédé de transformation sélectionné" ]
        ]
    ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ case model.dbState of
                RemoteData.Success db ->
                    mainView session db model

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


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
