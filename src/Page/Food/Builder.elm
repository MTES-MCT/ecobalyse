module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Browser.Navigation as Navigation
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country as Country
import Data.Dataset as Dataset
import Data.Food.Builder.Db as BuilderDb exposing (Db)
import Data.Food.Builder.Query as Query exposing (Query)
import Data.Food.Builder.Recipe as Recipe exposing (Recipe)
import Data.Food.Category as Category
import Data.Food.Ingredient as Ingredient exposing (Id, Ingredient)
import Data.Food.Origin as Origin
import Data.Food.Process as Process exposing (Process)
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Key as Key
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Page.Textile.Simulator.ViewMode as ViewMode
import Ports
import Quantity
import RemoteData exposing (WebData)
import Request.Common
import Request.Food.BuilderDb as FoodRequestDb
import Route
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.Bookmark as BookmarkView
import Views.Comparator as ComparatorView
import Views.Component.MassInput as MassInput
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Link as Link
import Views.Modal as ModalView
import Views.Spinner as Spinner
import Views.Transport as TransportView


type alias Model =
    { dbState : WebData Db
    , category : Maybe Category.Id
    , impact : Impact.Definition
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonUnit : ComparatorView.FoodComparisonUnit
    , modal : Modal
    }


type Modal
    = NoModal
    | ComparatorModal


type Msg
    = AddIngredient
    | AddPackaging
    | AddTransform
    | CopyToClipBoard String
    | DbLoaded (WebData Db)
    | DeleteBookmark Bookmark
    | DeleteIngredient Query.IngredientQuery
    | DeletePackaging Process.Code
    | LoadQuery Query
    | NoOp
    | OpenComparator
    | ResetTransform
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SetCategory (Maybe String)
    | SetModal Modal
    | SwitchComparisonUnit ComparatorView.FoodComparisonUnit
    | SwitchLinksTab BookmarkView.ActiveTab
    | SwitchImpact Impact.Trigram
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateIngredient Id Query.IngredientQuery
    | UpdatePackaging Process.Code Query.ProcessQuery
    | UpdateTransform Query.ProcessQuery
    | UpdateConservation String


init : Session -> Impact.Trigram -> Maybe Query -> ( Model, Session, Cmd Msg )
init ({ db, builderDb, queries } as session) trigram maybeQuery =
    let
        impact =
            db.impacts
                |> Impact.getDefinition trigram
                |> Result.withDefault (Impact.invalid Scope.Food)

        query =
            maybeQuery
                |> Maybe.withDefault queries.food

        ( model, newSession, cmds ) =
            ( { dbState = RemoteData.Loading
              , category = Nothing
              , impact = impact
              , bookmarkName = query |> findExistingBookmarkName session
              , bookmarkTab = BookmarkView.SaveTab
              , comparisonUnit = ComparatorView.PerKgOfProduct
              , modal = NoModal
              }
            , session
                |> Session.updateFoodQuery query
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
        , Cmd.batch [ cmds, FoodRequestDb.loadDb session DbLoaded ]
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
                        |> List.sortBy .name
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

        AddPackaging ->
            let
                firstPackaging =
                    session.builderDb.processes
                        |> Recipe.availablePackagings (List.map .code query.packaging)
                        |> List.sortBy Process.getDisplayName
                        |> List.head
                        |> Maybe.map Recipe.processQueryFromProcess
            in
            ( model, session, Cmd.none )
                |> (case firstPackaging of
                        Just packaging ->
                            updateQuery (Query.addPackaging packaging query)

                        Nothing ->
                            identity
                   )

        AddTransform ->
            let
                defaultMass =
                    query.ingredients |> List.map .mass |> Quantity.sum

                firstTransform =
                    session.builderDb.processes
                        |> Process.listByCategory Process.Transform
                        |> List.sortBy Process.getDisplayName
                        |> List.head
                        |> Maybe.map
                            (Recipe.processQueryFromProcess
                                >> (\processQuery -> { processQuery | mass = defaultMass })
                            )
            in
            ( model, session, Cmd.none )
                |> (case firstTransform of
                        Just transform ->
                            updateQuery (Query.setTransform transform query)

                        Nothing ->
                            identity
                   )

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

        LoadQuery queryToLoad ->
            ( model, session, Cmd.none )
                |> updateQuery queryToLoad

        NoOp ->
            ( model, session, Cmd.none )

        OpenComparator ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

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

        SetCategory category ->
            ( { model | category = category }, session, Cmd.none )

        SetModal modal ->
            ( { model | modal = modal }, session, Cmd.none )

        SwitchImpact impact ->
            ( model
            , session
            , Just query
                |> Route.FoodBuilder impact
                |> Route.toString
                |> Navigation.pushUrl session.navKey
            )

        SwitchComparisonUnit comparisonUnit ->
            ( { model | comparisonUnit = comparisonUnit }
            , session
            , Cmd.none
            )

        SwitchLinksTab bookmarkTab ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        ToggleComparedSimulation bookmark checked ->
            ( model
            , session |> Session.toggleComparedSimulation bookmark checked
            , Cmd.none
            )

        UpdateBookmarkName recipeName ->
            ( { model | bookmarkName = recipeName }, session, Cmd.none )

        UpdateIngredient oldIngredientId newIngredient ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateIngredient oldIngredientId newIngredient query)

        UpdatePackaging code newPackaging ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updatePackaging code newPackaging query)

        UpdateTransform newTransform ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateTransform newTransform query)

        UpdateConservation newConservation ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateConservation newConservation query)


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    ( { model | bookmarkName = query |> findExistingBookmarkName session }
    , session |> Session.updateFoodQuery query
    , msg
    )


findExistingBookmarkName : Session -> Query -> String
findExistingBookmarkName { builderDb, store } query =
    store.bookmarks
        |> Bookmark.findByFoodQuery query
        |> Maybe.map .name
        |> Maybe.withDefault
            (query
                |> Recipe.fromQuery builderDb
                |> Result.map Recipe.toString
                |> Result.withDefault ""
            )



-- Views


absoluteImpactView : Model -> Recipe.Results -> Html Msg
absoluteImpactView model results =
    SummaryComp.view
        { header = []
        , body =
            [ div [ class "d-flex flex-column m-auto gap-1 px-2 text-center text-nowrap" ]
                [ div [ class "display-3 lh-1" ]
                    [ results.perKg
                        |> Format.formatFoodSelectedImpactPerKg model.impact
                    ]
                ]
            ]
        , footer =
            [ div [ class "d-flex justify-content-center align-items-end gap-1 w-100" ]
                [ span [ class "fs-7" ]
                    [ text "Soit pour "
                    , Format.kg results.totalMass
                    , text "\u{00A0}:"
                    ]
                , span [ class "h5 m-0" ]
                    [ results.total
                        |> Format.formatFoodSelectedImpact model.impact
                    ]
                ]
            ]
        }


type alias AddProcessConfig msg =
    { isDisabled : Bool
    , event : msg
    , kind : String
    }


addProcessFormView : AddProcessConfig Msg -> Html Msg
addProcessFormView { isDisabled, event, kind } =
    li [ class "list-group-item px-3 py-2" ]
        [ button
            [ class "btn btn-outline-primary"
            , class "d-flex justify-content-center align-items-center"
            , class "gap-1 w-100"
            , disabled isDisabled
            , onClick event
            ]
            [ i [ class "icon icon-plus" ] []
            , text <| "Ajouter " ++ kind
            ]
        ]


type alias UpdateProcessConfig =
    { processes : List Process
    , excluded : List Process.Code
    , processQuery : Query.ProcessQuery
    , impact : Html Msg
    , updateEvent : Query.ProcessQuery -> Msg
    , deleteEvent : Msg
    }


updateProcessFormView : UpdateProcessConfig -> Html Msg
updateProcessFormView { processes, excluded, processQuery, impact, updateEvent, deleteEvent } =
    li [ class "IngredientFormWrapper" ]
        [ span [ class "MassInputWrapper" ]
            [ MassInput.view
                { mass = processQuery.mass
                , onChange =
                    \maybeMass ->
                        case maybeMass of
                            Just mass ->
                                updateEvent { processQuery | mass = mass }

                            _ ->
                                NoOp
                , disabled = False
                }
            ]
        , processes
            |> List.sortBy (.name >> Process.nameToString)
            |> processSelectorView
                processQuery.code
                (\code -> updateEvent { processQuery | code = code })
                excluded
        , span [ class "text-end ImpactDisplay" ]
            [ impact ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-outline-primary IngredientDelete"
            , title <| "Supprimer "
            , onClick deleteEvent
            ]
            [ Icon.trash ]
        ]


type alias UpdateIngredientConfig =
    { excluded : List Id
    , db : Db
    , ingredient : Recipe.RecipeIngredient
    , impact : Html Msg
    , transportImpact : Html Msg
    }


updateIngredientFormView : UpdateIngredientConfig -> List (Html Msg)
updateIngredientFormView { excluded, db, ingredient, impact, transportImpact } =
    let
        ingredientQuery : Query.IngredientQuery
        ingredientQuery =
            { id = ingredient.ingredient.id
            , name = ingredient.ingredient.name
            , mass = ingredient.mass
            , variant = ingredient.variant
            , country = ingredient.country |> Maybe.map .code
            , byPlane = ingredient.byPlane
            }

        event =
            UpdateIngredient ingredient.ingredient.id
    in
    [ li [ class "IngredientFormWrapper" ]
        [ span [ class "MassInputWrapper" ]
            [ MassInput.view
                { mass = ingredient.mass
                , onChange =
                    \maybeMass ->
                        case maybeMass of
                            Just mass ->
                                event { ingredientQuery | mass = mass }

                            _ ->
                                NoOp
                , disabled = False
                }
            ]
        , db.ingredients
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
                            , country = Nothing
                            , byPlane = Ingredient.byPlaneByDefault newIngredient
                        }
                )
        , db.countries
            |> Scope.only Scope.Food
            |> List.sortBy .name
            |> List.map
                (\{ code, name } ->
                    option
                        [ selected (ingredientQuery.country == Just code)
                        , value <| Country.codeToString code
                        ]
                        [ text name ]
                )
            |> (::)
                (option
                    [ value ""
                    , selected (ingredientQuery.country == Nothing)
                    ]
                    [ text <| "Par défaut (" ++ Origin.toLabel ingredient.ingredient.defaultOrigin ++ ")" ]
                )
            |> select
                [ class "form-select form-select-sm CountrySelector"
                , onInput
                    (\val ->
                        event
                            { ingredientQuery
                                | country =
                                    if val /= "" then
                                        Just (Country.codeFromString val)

                                    else
                                        Nothing
                            }
                    )
                ]
        , label
            [ class "BioCheckbox"
            , classList [ ( "text-muted", ingredient.ingredient.variants.organic == Nothing ) ]
            ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input no-outline"
                , attribute "role" "switch"
                , checked <| ingredient.variant == Query.Organic
                , disabled <| ingredient.ingredient.variants.organic == Nothing
                , onCheck
                    (\checked ->
                        event
                            { ingredientQuery
                                | variant =
                                    if checked then
                                        Query.Organic

                                    else
                                        Query.Default
                            }
                    )
                ]
                []
            , text "bio"
            ]
        , span [ class "text-end ImpactDisplay" ]
            [ impact ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-outline-primary IngredientDelete"
            , title <| "Supprimer "
            , onClick <| DeleteIngredient ingredientQuery
            ]
            [ Icon.trash ]
        , span [ class "text-muted IngredientTransportLabel fs-7" ]
            [ text "Transport pour cet ingrédient"
            , if ingredient.byPlane /= Nothing then
                label
                    [ class "PlaneCheckbox ps-2" ]
                    [ text "("
                    , input
                        [ type_ "checkbox"
                        , class "form-check-input no-outline"
                        , attribute "role" "switch"
                        , checked <| ingredientQuery.byPlane == Just True
                        , disabled <| ingredient.country == Nothing
                        , onCheck
                            (\checked ->
                                event { ingredientQuery | byPlane = Just checked }
                            )
                        ]
                        []
                    , text " par avion)"
                    ]

              else
                text ""
            ]
        , ingredient
            |> Recipe.computeIngredientTransport db
            |> TransportView.viewDetails
                { fullWidth = False
                , airTransportLabel = Nothing
                , seaTransportLabel = Nothing
                , roadTransportLabel = Nothing
                }
            |> span [ class "text-muted d-flex fs-7 gap-3 justify-content-left IngredientTransportDistances" ]
        , span [ class "text-muted text-end IngredientTransportImpact fs-7" ]
            [ transportImpact ]
        ]
    ]


debugQueryView : Db -> Query -> Html Msg
debugQueryView db query =
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
                    |> Recipe.compute db
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


ingredientListView : Db -> Impact.Definition -> Recipe -> Recipe.Results -> List (Html Msg)
ingredientListView db selectedImpact recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h5 [ class "d-flex align-items-center mb-0" ]
            [ text "Ingrédients"
            , Link.smallPillExternal
                [ Route.href (Route.Explore Scope.Food (Dataset.FoodIngredients Nothing)) ]
                [ Icon.search ]
            ]
        , results.recipe.ingredientsTotal
            |> Format.formatFoodSelectedImpact selectedImpact
        ]
    , ul [ class "list-group list-group-flush" ]
        ((if List.isEmpty recipe.ingredients then
            [ li [ class "list-group-item" ] [ text "Aucun ingrédient" ] ]

          else
            recipe.ingredients
                |> List.concatMap
                    (\ingredient ->
                        updateIngredientFormView
                            { excluded = recipe.ingredients |> List.map (.ingredient >> .id)
                            , db = db
                            , ingredient = ingredient
                            , impact =
                                results.recipe.ingredients
                                    |> List.filter (\( recipeIngredient, _ ) -> recipeIngredient == ingredient)
                                    |> List.head
                                    |> Maybe.map Tuple.second
                                    |> Maybe.withDefault Impact.noImpacts
                                    |> Format.formatFoodSelectedImpact selectedImpact
                            , transportImpact =
                                ingredient
                                    |> Recipe.computeIngredientTransport db
                                    |> .impacts
                                    |> Format.formatFoodSelectedImpact selectedImpact
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


packagingListView : Db -> Impact.Definition -> Recipe -> Recipe.Results -> List (Html Msg)
packagingListView db selectedImpact recipe results =
    let
        availablePackagings =
            Recipe.availablePackagings (List.map (.process >> .code) recipe.packaging) db.processes
    in
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
                    (\packaging ->
                        updateProcessFormView
                            { processes =
                                db.processes
                                    |> Process.listByCategory Process.Packaging
                            , excluded = recipe.packaging |> List.map (.process >> .code)
                            , processQuery = { code = packaging.process.code, mass = packaging.mass }
                            , impact =
                                packaging
                                    |> Recipe.computeProcessImpacts db.impacts
                                    |> Format.formatFoodSelectedImpact selectedImpact
                            , updateEvent = UpdatePackaging packaging.process.code
                            , deleteEvent = DeletePackaging packaging.process.code
                            }
                    )
        )
    , addProcessFormView
        { isDisabled = availablePackagings == []
        , event = AddPackaging
        , kind = "un emballage"
        }
    ]


distributionView : Db -> Impact.Definition -> Recipe -> Recipe.Results -> List (Html Msg)
distributionView db impact recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h5 [ class "mb-0" ] [ text "Stockage et distribution" ]
        , text "TODO impact"
        ]
    , div []
        [ ul [ class "list-group list-group-flush border-top-0 border-bottom-0" ]
            [ li [ class "IngredientFormWrapper" ]
                [ select
                    [ class "form-select form-select-sm"
                    , onInput UpdateConservation
                    ]
                    (Query.conservationTypes
                        |> List.map
                            (\type_ ->
                                option
                                    [ selected <| (recipe.conservation |> Maybe.map (.type_ >> (==) type_) |> Maybe.withDefault False)
                                    , value <| Query.conservationTypetoString type_
                                    ]
                                    [ text <| Query.conservationTypetoString type_ ]
                            )
                    )
                ]
            ]
        , div
            [ class "card-body d-flex justify-content-between align-items-center gap-1"
            , class "border-top-0 text-muted py-2 fs-7"
            ]
            []
        ]
    ]


mainView : Session -> Db -> Model -> Html Msg
mainView session db model =
    let
        computed =
            session.queries.food
                |> Recipe.compute db
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
                    stepListView db model recipe results

                Err error ->
                    errorView error
            , session.queries.food
                |> debugQueryView db
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


processSelectorView : Process.Code -> (Process.Code -> msg) -> List Process.Code -> List Process -> Html msg
processSelectorView selectedCode event excluded processes =
    select
        [ class "form-select form-select-sm"
        , onInput (Process.codeFromString >> event)
        ]
        (processes
            |> List.sortBy (\process -> Process.getDisplayName process)
            |> List.map
                (\process ->
                    option
                        [ selected <| selectedCode == process.code
                        , value <| Process.codeToString process.code
                        , disabled <| List.member process.code excluded
                        ]
                        [ text <| Process.getDisplayName process ]
                )
        )


ingredientSelectorView : Id -> List Id -> (Ingredient -> Msg) -> List Ingredient -> Html Msg
ingredientSelectorView selectedIngredient excluded event ingredients =
    select
        [ class "form-select form-select-sm IngredientSelector"
        , onInput
            (\ingredientId ->
                ingredients
                    |> Ingredient.findByID (Ingredient.idFromString ingredientId)
                    |> Result.map event
                    |> Result.withDefault NoOp
            )
        ]
        (ingredients
            |> List.sortBy .name
            |> List.map
                (\ingredient ->
                    option
                        [ selected <| selectedIngredient == ingredient.id
                        , disabled <| List.member ingredient.id excluded
                        , value <| Ingredient.idToString ingredient.id
                        ]
                        [ text ingredient.name ]
                )
        )


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
            , scope = Scope.Food
            }
        , absoluteImpactView model results
        , if Impact.trg "ecs" == model.impact.trigram then
            -- We only compute and render subscores for ecs
            scoresView session model results

          else
            text ""
        , stepResultsView model results
        , BookmarkView.view
            { session = session
            , activeTab = model.bookmarkTab
            , bookmarkName = model.bookmarkName
            , impact = model.impact
            , funit = Unit.PerItem
            , scope = Scope.Food
            , viewMode = ViewMode.Simple
            , copyToClipBoard = CopyToClipBoard
            , compare = OpenComparator
            , delete = DeleteBookmark
            , save = SaveBookmark
            , update = UpdateBookmarkName
            , switchTab = SwitchLinksTab
            }
        , a [ class "btn btn-primary", Route.href Route.FoodExplore ]
            [ text "Explorateur de recettes" ]
        ]


scoresView : Session -> Model -> Recipe.Results -> Html Msg
scoresView { builderDb } model { perKg } =
    let
        score =
            case model.category of
                Just category ->
                    perKg
                        |> Impact.getImpact (Impact.trg "ecs")
                        |> Impact.getAggregatedCategoryScoreOutOf100 .all category

                Nothing ->
                    perKg
                        |> Impact.getAggregatedScoreOutOf100 model.impact
                        |> Ok

        subScores =
            perKg
                |> Impact.toProtectionAreas builderDb.impacts

        letterView letter =
            span [ class <| "ScoreLetter ScoreLetter" ++ letter ]
                [ text letter
                ]
    in
    div [ class "card bg-primary shadow-sm" ]
        [ div [ class "card-header text-white d-flex justify-content-between gap-1" ]
            [ div [ class "d-flex justify-content-between align-items-center gap-3 w-100" ]
                [ Category.all
                    |> Dict.toList
                    |> List.sortBy (Tuple.second >> .name)
                    |> List.map
                        (\( category, { name } ) ->
                            option
                                [ value category
                                , selected <| model.category == Just category
                                ]
                                [ text name ]
                        )
                    |> (::)
                        (option
                            [ value ""
                            , selected <| model.category == Nothing
                            ]
                            [ text "Toutes catégories" ]
                        )
                    |> select
                        [ class "form-select form-select-sm w-50"
                        , onInput
                            (\s ->
                                SetCategory
                                    (if s == "" then
                                        Nothing

                                     else
                                        Just s
                                    )
                            )
                        ]
                , div [ class "d-flex justify-content-center align-items-end gap-1 text-nowrap h4 m-0 text-center" ]
                    (case score of
                        Ok score_ ->
                            let
                                scoreLetter =
                                    Impact.getAggregatedScoreLetter score_
                            in
                            [ span []
                                [ text (String.fromInt score_)
                                , span [ class "fs-7" ] [ text "/100" ]
                                ]
                            , letterView scoreLetter
                            ]

                        Err error ->
                            [ span [ class "badge bg-danger" ] [ text error ] ]
                    )
                ]
            ]
        , div [ class "card-body py-2" ]
            [ [ ( "Climat", subScores.climate, .climate )
              , ( "Biodiversité", subScores.biodiversity, .biodiversity )
              , ( "Santé environnementale", subScores.health, .health )
              , ( "Ressource", subScores.resources, .resources )
              ]
                |> List.map
                    (\( label, subScore, getter ) ->
                        let
                            subScore100 =
                                case model.category of
                                    Just category ->
                                        subScore
                                            |> Impact.getAggregatedCategoryScoreOutOf100 getter category

                                    Nothing ->
                                        perKg
                                            |> Impact.getAggregatedScoreOutOf100 model.impact
                                            |> Ok
                        in
                        tr []
                            [ th [] [ text label ]
                            , td [ class "text-end" ]
                                [ strong []
                                    [ subScore100
                                        |> Result.map String.fromInt
                                        |> Result.withDefault "N/A"
                                        |> text
                                    ]
                                , small [] [ text "/100" ]
                                ]
                            , td
                                [ class "text-end align-middle ps-1"
                                , style "width" "1%"
                                , subScore
                                    |> Unit.impactToFloat
                                    |> Format.formatFloat 2
                                    |> (\x -> x ++ "\u{202F}µPts/kg")
                                    |> title
                                ]
                                [ subScore100
                                    |> Result.map Impact.getAggregatedScoreLetter
                                    |> Result.withDefault "?"
                                    |> letterView
                                ]
                            ]
                    )
                |> table [ class "w-100 text-white m-0" ]
            ]
        ]


stepListView : Db -> Model -> Recipe -> Recipe.Results -> Html Msg
stepListView db { impact } recipe results =
    div [ class "d-flex flex-column gap-3" ]
        [ div [ class "card" ]
            (ingredientListView db impact recipe results)
        , div [ class "card" ]
            (transformView db impact recipe results)
        , div [ class "card" ]
            (packagingListView db impact recipe results)
        , div [ class "card" ]
            (distributionView db impact recipe results)
        ]


stepResultsView : Model -> Recipe.Results -> Html Msg
stepResultsView model results =
    let
        toFloat =
            Impact.getImpact model.impact.trigram >> Unit.impactToFloat

        stepsData =
            [ { label = "Ingrédients"
              , impact = toFloat results.recipe.ingredientsTotal
              }
            , { label = "Transformation"
              , impact = toFloat results.recipe.transform
              }
            , { label = "Emballage"
              , impact = toFloat results.packaging
              }
            , { label = "Transports"
              , impact = toFloat results.transports.impacts
              }
            ]

        totalImpact =
            toFloat results.total
    in
    div [ class "card" ]
        [ div [ class "card-header" ] [ text "Détail des postes" ]
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


transformView : Db -> Impact.Definition -> Recipe -> Recipe.Results -> List (Html Msg)
transformView db selectedImpact recipe results =
    let
        impact =
            results.recipe.transform
                |> Format.formatFoodSelectedImpact selectedImpact
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h5 [ class "mb-0" ] [ text "Transformation" ]
        , impact
        ]
    , case recipe.transform of
        Just transform ->
            div []
                [ ul [ class "list-group list-group-flush border-top-0 border-bottom-0" ]
                    [ updateProcessFormView
                        { processes =
                            db.processes
                                |> Process.listByCategory Process.Transform
                        , excluded = [ transform.process.code ]
                        , processQuery = { code = transform.process.code, mass = transform.mass }
                        , impact = impact
                        , updateEvent = UpdateTransform
                        , deleteEvent = ResetTransform
                        }
                    ]
                , div
                    [ class "card-body d-flex justify-content-between align-items-center gap-1"
                    , class "border-top-0 text-muted py-2 fs-7"
                    ]
                    [ div [ class "text-truncate" ]
                        [ text <|
                            "Masse du produit après transformation ("
                                ++ Process.nameToString transform.process.name
                                ++ ")"
                        ]
                    , span [ class "d-flex" ]
                        [ Recipe.getTransformedIngredientsMass recipe
                            |> Format.kg
                        , Link.smallPillExternal
                            [ href (Gitbook.publicUrlFromPath Gitbook.FoodRawToCookedRatio) ]
                            [ Icon.question ]
                        ]
                    ]
                ]

        Nothing ->
            addProcessFormView
                { isDisabled = False
                , event = AddTransform
                , kind = "une transformation"
                }
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
            , case model.modal of
                NoModal ->
                    text ""

                ComparatorModal ->
                    ModalView.view
                        { size = ModalView.ExtraLarge
                        , close = SetModal NoModal
                        , noOp = NoOp
                        , title = "Comparateur de simulations sauvegardées"
                        , formAction = Nothing
                        , content =
                            [ ComparatorView.comparator
                                { session = session
                                , impact = model.impact
                                , options =
                                    ComparatorView.foodOptions
                                        { comparisonUnit = model.comparisonUnit
                                        , switchComparisonUnit = SwitchComparisonUnit
                                        }
                                , toggle = ToggleComparedSimulation
                                }
                            ]
                        , footer = []
                        }
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        ComparatorModal ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
