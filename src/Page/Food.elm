module Page.Food exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Autocomplete exposing (Autocomplete)
import Autocomplete.View as AutocompleteView
import Browser.Dom as Dom
import Browser.Events as BE
import Browser.Navigation as Navigation
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country as Country
import Data.Dataset as Dataset
import Data.Food.Db as FoodDb
import Data.Food.Ingredient as Ingredient exposing (Id, Ingredient)
import Data.Food.Ingredient.Category as IngredientCategory
import Data.Food.Origin as Origin
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process exposing (Process)
import Data.Food.Query as Query exposing (Query)
import Data.Food.Recipe as Recipe exposing (Recipe)
import Data.Food.Retail as Retail
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Length
import Ports
import Quantity
import Route
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.Bookmark as BookmarkView
import Views.Button as Button
import Views.Comparator as ComparatorView
import Views.Component.DownArrow as DownArrow
import Views.Component.MassInput as MassInput
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Link as Link
import Views.Modal as ModalView
import Views.Sidebar as SidebarView
import Views.Transport as TransportView


type alias Model =
    { db : FoodDb.Db
    , impact : Definition
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , modal : Modal
    , activeImpactsTab : ImpactTabs.Tab
    }


type Modal
    = NoModal
    | ComparatorModal
    | AddIngredientModal (Maybe Recipe.RecipeIngredient) (Autocomplete Ingredient)


type Msg
    = AddIngredient Ingredient
    | AddPackaging
    | AddPreparation
    | AddTransform
    | AddDistribution
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | DeleteIngredient Ingredient.Id
    | DeletePackaging Process.Identifier
    | DeletePreparation Preparation.Id
    | LoadQuery Query
    | NoOp
    | OnAutocomplete (Autocomplete.Msg Ingredient)
    | OnAutocompleteSelect
    | OpenComparator
    | ResetTransform
    | ResetDistribution
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateIngredient Id Query.IngredientQuery
    | UpdatePackaging Process.Identifier Query.ProcessQuery
    | UpdatePreparation Preparation.Id Preparation.Id
    | UpdateTransform Query.ProcessQuery
    | UpdateDistribution String


init : Session -> Definition.Trigram -> Maybe Query -> ( Model, Session, Cmd Msg )
init ({ foodDb, queries } as session) trigram maybeQuery =
    let
        impact =
            Definition.get trigram foodDb.impactDefinitions

        query =
            maybeQuery
                |> Maybe.withDefault queries.food
    in
    ( { db = foodDb
      , impact = impact
      , bookmarkName = query |> findExistingBookmarkName session
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType = ComparatorView.Subscores
      , modal = NoModal
      , activeImpactsTab =
            if impact.trigram == Definition.Ecs then
                ImpactTabs.SubscoresTab

            else
                ImpactTabs.StepImpactsTab
      }
    , session |> Session.updateFoodQuery query
    , case maybeQuery of
        Nothing ->
            Ports.scrollTo { x = 0, y = 0 }

        Just _ ->
            Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ queries } as session) msg model =
    let
        query =
            queries.food
    in
    case msg of
        AddIngredient ingredient ->
            update session (SetModal NoModal) model
                |> updateQuery
                    (query
                        |> Query.addIngredient (Recipe.ingredientQueryFromIngredient ingredient)
                    )

        AddPackaging ->
            let
                firstPackaging =
                    model.db.processes
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

        AddPreparation ->
            let
                firstPreparation =
                    Preparation.all
                        |> Preparation.unused query.preparation
                        |> List.head
            in
            ( model, session, Cmd.none )
                |> (case firstPreparation of
                        Just { id } ->
                            updateQuery (Query.addPreparation id query)

                        Nothing ->
                            identity
                   )

        AddTransform ->
            let
                defaultMass =
                    query.ingredients |> List.map .mass |> Quantity.sum

                firstTransform =
                    model.db.processes
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

        AddDistribution ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.setDistribution Retail.ambient query)

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        DeleteBookmark bookmark ->
            updateQuery query
                ( model
                , session |> Session.deleteBookmark bookmark
                , Cmd.none
                )

        DeleteIngredient id ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.deleteIngredient id query)

        DeletePackaging code ->
            ( model, session, Cmd.none )
                |> updateQuery (Recipe.deletePackaging code query)

        DeletePreparation id ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.deletePreparation id query)

        LoadQuery queryToLoad ->
            ( model, session, Cmd.none )
                |> updateQuery queryToLoad

        NoOp ->
            ( model, session, Cmd.none )

        OnAutocomplete autocompleteMsg ->
            case model.modal of
                AddIngredientModal maybeOldIngredient autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = AddIngredientModal maybeOldIngredient newAutocompleteState }
                    , session
                    , Cmd.map OnAutocomplete autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteSelect ->
            case model.modal of
                AddIngredientModal maybeOldIngredient autocompleteState ->
                    Maybe.map2
                        (\oldIngredient newIngredient ->
                            -- Update an existing ingredient
                            let
                                ingredientQuery : Query.IngredientQuery
                                ingredientQuery =
                                    { id = newIngredient.id
                                    , mass = oldIngredient.mass
                                    , country = Nothing
                                    , planeTransport = Ingredient.byPlaneByDefault newIngredient
                                    , complements = Just oldIngredient.complements
                                    }
                            in
                            model
                                |> update session (SetModal NoModal)
                                |> updateQuery (Query.updateIngredient oldIngredient.ingredient.id ingredientQuery query)
                        )
                        maybeOldIngredient
                        (Autocomplete.selectedValue autocompleteState)
                        |> Maybe.withDefault
                            -- Add a new ingredient
                            (model
                                |> update session (SetModal NoModal)
                                |> selectIngredient autocompleteState
                            )

                _ ->
                    ( model, session, Cmd.none )

        OpenComparator ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        ResetDistribution ->
            ( model, session, Cmd.none )
                |> updateQuery (Recipe.resetDistribution query)

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

        SetModal modal ->
            ( { model | modal = modal }
            , session
            , case modal of
                NoModal ->
                    Ports.removeBodyClass "prevent-scrolling"

                ComparatorModal ->
                    Ports.addBodyClass "prevent-scrolling"

                AddIngredientModal _ _ ->
                    Cmd.batch
                        [ Ports.addBodyClass "prevent-scrolling"
                        , Dom.focus "ingredient-search"
                            |> Task.attempt (always NoOp)
                        ]
            )

        SwitchBookmarksTab bookmarkTab ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        SwitchComparisonType displayChoice ->
            ( { model | comparisonType = displayChoice }, session, Cmd.none )

        SwitchImpact (Ok impact) ->
            ( model
            , session
            , Just query
                |> Route.FoodBuilder impact
                |> Route.toString
                |> Navigation.pushUrl session.navKey
            )

        SwitchImpact (Err error) ->
            ( model
            , session |> Session.notifyError "Erreur de sélection d'impact: " error
            , Cmd.none
            )

        SwitchImpactsTab impactsTab ->
            ( { model | activeImpactsTab = impactsTab }
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

        UpdateDistribution newDistribution ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateDistribution newDistribution query)

        UpdateIngredient oldIngredientId newIngredient ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateIngredient oldIngredientId newIngredient query)

        UpdatePackaging code newPackaging ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updatePackaging code newPackaging query)

        UpdatePreparation oldId newId ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updatePreparation oldId newId query)

        UpdateTransform newTransform ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateTransform newTransform query)


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    ( { model | bookmarkName = query |> findExistingBookmarkName session }
    , session |> Session.updateFoodQuery query
    , msg
    )


findExistingBookmarkName : Session -> Query -> String
findExistingBookmarkName { foodDb, store } query =
    store.bookmarks
        |> Bookmark.findByFoodQuery query
        |> Maybe.map .name
        |> Maybe.withDefault
            (query
                |> Recipe.fromQuery foodDb
                |> Result.map Recipe.toString
                |> Result.withDefault ""
            )


selectIngredient : Autocomplete Ingredient -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectIngredient autocompleteState ( model, session, _ ) =
    let
        ingredient =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.map Just
                |> Maybe.withDefault (List.head (Autocomplete.choices autocompleteState))

        msg =
            ingredient
                |> Maybe.map AddIngredient
                |> Maybe.withDefault NoOp
    in
    update session msg model



-- Views


type alias AddProcessConfig msg =
    { isDisabled : Bool
    , event : msg
    , kind : String
    }


addProcessFormView : AddProcessConfig Msg -> Html Msg
addProcessFormView { isDisabled, event, kind } =
    li [ class "list-group-item p-0" ]
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
    , excluded : List Process.Identifier
    , processQuery : Query.ProcessQuery
    , impact : Html Msg
    , updateEvent : Query.ProcessQuery -> Msg
    , deleteEvent : Msg
    }


updateProcessFormView : UpdateProcessConfig -> Html Msg
updateProcessFormView { processes, excluded, processQuery, impact, updateEvent, deleteEvent } =
    li [ class "IngredientFormWrapper list-group-item" ]
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
        , span [ class "text-end ImpactDisplay fs-7" ] [ impact ]
        , deleteItemButton deleteEvent
        ]


deleteItemButton : Msg -> Html Msg
deleteItemButton event =
    button
        [ type_ "button"
        , class "IngredientDelete d-flex justify-content-center align-items-center btn btn-outline-primary"
        , title "Supprimer cet ingrédient"
        , onClick event
        ]
        [ Icon.trash ]


type alias UpdateIngredientConfig =
    { excluded : List Id
    , db : FoodDb.Db
    , recipeIngredient : Recipe.RecipeIngredient
    , impact : Impact.Impacts
    , index : Int
    , selectedImpact : Definition
    , transportImpact : Html Msg
    }


updateIngredientFormView : UpdateIngredientConfig -> Html Msg
updateIngredientFormView { excluded, db, recipeIngredient, impact, index, selectedImpact, transportImpact } =
    let
        ingredientQuery : Query.IngredientQuery
        ingredientQuery =
            { id = recipeIngredient.ingredient.id
            , mass = recipeIngredient.mass
            , country = recipeIngredient.country |> Maybe.map .code
            , planeTransport = recipeIngredient.planeTransport
            , complements = Just recipeIngredient.complements
            }

        event =
            UpdateIngredient recipeIngredient.ingredient.id
    in
    li [ class "IngredientFormWrapper list-group-item" ]
        [ span [ class "MassInputWrapper" ]
            [ MassInput.view
                { mass = recipeIngredient.mass
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
                recipeIngredient
                excluded
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
                    [ text <| "Par défaut (" ++ Origin.toLabel recipeIngredient.ingredient.defaultOrigin ++ ")" ]
                )
            |> select
                [ class "form-select form-select CountrySelector"
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
        , span [ class "text-end ImpactDisplay fs-7" ]
            [ impact
                |> Format.formatImpact selectedImpact
            ]
        , deleteItemButton (DeleteIngredient ingredientQuery.id)
        , if selectedImpact.trigram == Definition.Ecs then
            let
                { complements, ingredient } =
                    recipeIngredient

                complementsImpacts =
                    impact
                        |> Recipe.computeIngredientComplementsImpacts db.impactDefinitions complements
            in
            details [ class "IngredientBonuses fs-7" ]
                [ summary []
                    [ div [ class "BonusesTable d-flex justify-content-between w-100" ]
                        [ span [ title "Cliquez pour plier/déplier" ] [ text "Bonus écologiques" ]
                        , span [ class "text-success text-end", title "Total des bonus" ]
                            [ Impact.getTotalComplementsImpacts complementsImpacts
                                |> Quantity.negate
                                |> Unit.impactToFloat
                                |> Format.formatImpactFloat selectedImpact
                            ]
                        ]
                    ]
                , ingredientComplementsView
                    { name = "Diversité agricole"
                    , title = Nothing
                    , domId = "agroDiversity_" ++ String.fromInt index
                    , complementImpact = complementsImpacts.agroDiversity
                    , complementSplit = complements.agroDiversity
                    , disabled = False
                    , selectedImpact = selectedImpact
                    , updateEvent =
                        \split ->
                            event { ingredientQuery | complements = Just { complements | agroDiversity = split } }
                    }
                , ingredientComplementsView
                    { name = "Infra. agro-éco."
                    , title = Just "Infrastructures agro-écologiques"
                    , domId = "agroEcology_" ++ String.fromInt index
                    , complementImpact = complementsImpacts.agroEcology
                    , complementSplit = complements.agroEcology
                    , disabled = False
                    , selectedImpact = selectedImpact
                    , updateEvent =
                        \split ->
                            event { ingredientQuery | complements = Just { complements | agroEcology = split } }
                    }
                , ingredientComplementsView
                    { name = "Cond. d'élevage"
                    , title = Nothing
                    , domId = "animalWelfare_" ++ String.fromInt index
                    , complementImpact = complementsImpacts.animalWelfare
                    , complementSplit = complements.animalWelfare
                    , disabled = not (IngredientCategory.fromAnimalOrigin ingredient.categories)
                    , selectedImpact = selectedImpact
                    , updateEvent =
                        \split ->
                            event { ingredientQuery | complements = Just { complements | animalWelfare = split } }
                    }
                ]

          else
            text ""
        , displayTransportDistances db recipeIngredient ingredientQuery event
        , span
            [ class "text-black-50 text-end IngredientTransportImpact fs-8"
            , title "Impact du transport pour cet ingrédient"
            ]
            [ text "(+ "
            , transportImpact
            , text ")"
            ]
        ]


type alias ComplementsViewConfig msg =
    { complementImpact : Unit.Impact
    , complementSplit : Split
    , disabled : Bool
    , domId : String
    , name : String
    , selectedImpact : Definition
    , title : Maybe String
    , updateEvent : Split -> msg
    }


ingredientComplementsView : ComplementsViewConfig Msg -> Html Msg
ingredientComplementsView { name, complementImpact, complementSplit, disabled, domId, selectedImpact, title, updateEvent } =
    div
        [ class "IngredientBonus"
        , title |> Maybe.withDefault name |> Attr.title
        ]
        [ label
            [ for domId
            , class "BonusName text-nowrap text-muted"
            ]
            [ text name ]
        , input
            [ type_ "range"
            , id domId
            , class "BonusRange form-range"
            , Attr.disabled disabled
            , Attr.min "0"
            , Attr.max "100"
            , step "1"
            , Attr.value <| Split.toPercentString complementSplit
            , onInput
                (String.toInt
                    >> Maybe.andThen (Split.fromPercent >> Result.toMaybe)
                    >> Maybe.withDefault Split.zero
                    >> updateEvent
                )
            ]
            []
        , div [ class "BonusValue d-flex justify-content-end align-items-center text-muted" ]
            [ Format.splitAsPercentage complementSplit
            , Button.smallPillLink
                [ href (Gitbook.publicUrlFromPath Gitbook.FoodComplements)
                , target "_blank"
                ]
                [ Icon.question ]
            ]
        , div
            [ class "BonusImpact text-end"
            , classList
                [ ( "text-black-50", disabled )
                , ( "text-muted", Unit.impactToFloat complementImpact <= 0 )
                , ( "text-success", Unit.impactToFloat complementImpact > 0 )
                ]
            ]
            [ complementImpact
                |> Quantity.negate
                |> Unit.impactToFloat
                |> Format.formatImpactFloat selectedImpact
            ]
        ]


displayTransportDistances : FoodDb.Db -> Recipe.RecipeIngredient -> Query.IngredientQuery -> (Query.IngredientQuery -> Msg) -> Html Msg
displayTransportDistances db ingredient ingredientQuery event =
    span [ class "text-muted d-flex fs-7 gap-3 justify-content-left IngredientTransportDistances" ]
        (if ingredient.planeTransport /= Ingredient.PlaneNotApplicable then
            let
                isByPlane =
                    ingredientQuery.planeTransport == Ingredient.ByPlane

                { road, roadCooled, air, sea, seaCooled } =
                    ingredient
                        |> Recipe.computeIngredientTransport db

                needsCooling =
                    ingredient.ingredient.transportCooling /= Ingredient.NoCooling
            in
            [ div [ class "IngredientPlaneOrBoatSelector" ]
                [ label [ class "PlaneSelector" ]
                    [ input
                        [ type_ "radio"
                        , attribute "role" "switch"
                        , checked isByPlane
                        , onInput <| always (event { ingredientQuery | planeTransport = Ingredient.ByPlane })
                        ]
                        []
                    , Icon.plane
                    ]
                , label [ class "BoatSelector" ]
                    [ input
                        [ type_ "radio"
                        , attribute "role" "switch"
                        , checked <| not isByPlane
                        , onInput <| always (event { ingredientQuery | planeTransport = Ingredient.NoPlane })
                        ]
                        []
                    , if needsCooling then
                        Icon.boatCooled

                      else
                        Icon.boat
                    ]
                , if isByPlane then
                    span [ class "ps-1 align-items-center gap-1", title "Tranport aérien" ]
                        [ Format.km air ]

                  else if needsCooling then
                    span [ class "ps-1 align-items-center gap-1", title "Tranport maritime réfrigéré" ]
                        [ Format.km seaCooled ]

                  else
                    span [ class "ps-1 align-items-center gap-1", title "Tranport maritime" ]
                        [ Format.km sea ]
                ]
            , if road /= Length.kilometers 0 then
                TransportView.entry { onlyIcons = False, distance = road, icon = Icon.bus, label = "Transport routier" }

              else
                text ""
            , if roadCooled /= Length.kilometers 0 then
                TransportView.entry { onlyIcons = False, distance = roadCooled, icon = Icon.busCooled, label = "Transport routier réfrigéré" }

              else
                text ""
            ]

         else
            ingredient
                |> Recipe.computeIngredientTransport db
                |> TransportView.viewDetails
                    { fullWidth = False
                    , hideNoLength = True
                    , onlyIcons = False
                    , airTransportLabel = Nothing
                    , seaTransportLabel = Nothing
                    , roadTransportLabel = Nothing
                    }
        )


debugQueryView : FoodDb.Db -> Query -> Html Msg
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
                    |> Query.serialize
                    |> debugView
                ]
            , div [ class "col-5" ]
                [ query
                    |> Recipe.compute db
                    |> Result.map (Tuple.second >> Recipe.encodeResults >> Encode.encode 2)
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


ingredientListView : FoodDb.Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
ingredientListView db selectedImpact recipe results =
    let
        availableIngredients =
            db.ingredients
                |> Recipe.availableIngredients (List.map (.ingredient >> .id) recipe.ingredients)

        autocompleteState =
            AutocompleteSelector.init availableIngredients
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 d-flex align-items-center mb-0" ]
            [ text "Ingrédients"
            , Link.smallPillExternal
                [ Route.href (Route.Explore Scope.Food (Dataset.FoodIngredients Nothing))
                , title "Explorer"
                , attribute "aria-label" "Explorer"
                ]
                [ Icon.search ]
            ]
        , results.recipe.ingredientsTotal
            |> Format.formatImpact selectedImpact
        ]
    , ul [ class "CardList list-group list-group-flush" ]
        ((if List.isEmpty recipe.ingredients then
            [ li [ class "list-group-item" ] [ text "Aucun ingrédient" ] ]

          else
            recipe.ingredients
                |> List.indexedMap
                    (\index ingredient ->
                        updateIngredientFormView
                            { excluded = recipe.ingredients |> List.map (.ingredient >> .id)
                            , db = db
                            , recipeIngredient = ingredient
                            , impact =
                                results.recipe.ingredients
                                    |> List.filter (\( recipeIngredient, _ ) -> recipeIngredient == ingredient)
                                    |> List.head
                                    |> Maybe.map Tuple.second
                                    |> Maybe.withDefault Impact.empty
                            , index = index
                            , selectedImpact = selectedImpact
                            , transportImpact =
                                ingredient
                                    |> Recipe.computeIngredientTransport db
                                    |> .impacts
                                    |> Format.formatImpact selectedImpact
                            }
                    )
         )
            ++ [ li [ class "list-group-item p-0" ]
                    [ button
                        [ class "btn btn-outline-primary"
                        , class "d-flex justify-content-center align-items-center"
                        , class " gap-1 w-100"
                        , disabled <| List.isEmpty availableIngredients
                        , onClick (SetModal (AddIngredientModal Nothing autocompleteState))
                        ]
                        [ i [ class "icon icon-plus" ] []
                        , text "Ajouter un ingrédient"
                        ]
                    ]
               ]
        )
    ]


packagingListView : FoodDb.Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
packagingListView db selectedImpact recipe results =
    let
        availablePackagings =
            Recipe.availablePackagings (List.map (.process >> .code) recipe.packaging) db.processes
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Emballage" ]
        , results.packaging
            |> Format.formatImpact selectedImpact
        ]
    , ul [ class "CardList list-group list-group-flush" ]
        ((if List.isEmpty recipe.packaging then
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
                                    |> Recipe.computeProcessImpacts
                                    |> Format.formatImpact selectedImpact
                            , updateEvent = UpdatePackaging packaging.process.code
                            , deleteEvent = DeletePackaging packaging.process.code
                            }
                    )
         )
            ++ [ addProcessFormView
                    { isDisabled = availablePackagings == []
                    , event = AddPackaging
                    , kind = "un emballage"
                    }
               ]
        )
    ]


transportToTransformationView : Definition -> Recipe.Results -> Html Msg
transportToTransformationView selectedImpact results =
    DownArrow.view
        []
        [ div []
            [ text "Masse : "
            , Format.kg results.recipe.initialMass
            ]
        , div [ class "d-flex justify-content-between" ]
            [ div [ class "d-flex justify-content-between gap-3" ]
                (results.recipe.transports
                    |> TransportView.viewDetails
                        { fullWidth = False
                        , hideNoLength = True
                        , onlyIcons = True
                        , airTransportLabel = Nothing
                        , seaTransportLabel = Nothing
                        , roadTransportLabel = Nothing
                        }
                )
            , Format.formatImpact selectedImpact results.recipe.transports.impacts
            ]
        ]


transportToPackagingView : Recipe -> Recipe.Results -> Html Msg
transportToPackagingView recipe results =
    DownArrow.view
        []
        [ div []
            [ text "Masse comestible\u{00A0}: "
            , Format.kg results.recipe.edibleMass
            , Link.smallPillExternal
                [ href (Gitbook.publicUrlFromPath Gitbook.FoodInediblePart)
                , title "Accéder à la documentation"
                , attribute "aria-label" "Accéder à la documentation"
                ]
                [ Icon.question ]
            ]
        , case recipe.transform of
            Just transform ->
                div []
                    [ span
                        [ title <| "(" ++ Process.nameToString transform.process.name ++ ")" ]
                        [ text "Masse après transformation : " ]
                    , Recipe.getTransformedIngredientsMass recipe
                        |> Format.kg
                    , Link.smallPillExternal
                        [ href (Gitbook.publicUrlFromPath Gitbook.FoodRawToCookedRatio)
                        , title "Accéder à la documentation"
                        , attribute "aria-label" "Accéder à la documentation"
                        ]
                        [ Icon.question ]
                    ]

            Nothing ->
                text ""
        ]


transportToDistributionView : Definition -> Recipe -> Recipe.Results -> Html Msg
transportToDistributionView selectedImpact recipe results =
    DownArrow.view
        []
        [ div []
            [ text "Masse : "
            , Recipe.getTransformedIngredientsMass recipe
                |> Format.kg
            , text " + Emballage : "
            , Recipe.getPackagingMass recipe
                |> Format.kg
            ]
        , div [ class "d-flex justify-content-between" ]
            [ div []
                (results.distribution.transports
                    |> TransportView.viewDetails
                        { fullWidth = False
                        , hideNoLength = True
                        , onlyIcons = False
                        , airTransportLabel = Nothing
                        , seaTransportLabel = Nothing
                        , roadTransportLabel = Nothing
                        }
                )
            , Format.formatImpact selectedImpact results.distribution.transports.impacts
            ]
        ]


transportToConsumptionView : Recipe -> Html Msg
transportToConsumptionView recipe =
    DownArrow.view
        []
        [ text <| "Masse : "
        , Recipe.getTransformedIngredientsMass recipe
            |> Format.kg
        , text " + Emballage : "
        , Recipe.getPackagingMass recipe
            |> Format.kg
        ]


transportAfterConsumptionView : Recipe -> Recipe.Results -> Html Msg
transportAfterConsumptionView recipe result =
    DownArrow.view
        []
        [ text <| "Masse : "
        , Format.kg result.preparedMass
        , text " + Emballage : "
        , Recipe.getPackagingMass recipe
            |> Format.kg
        ]


distributionView : Definition -> Recipe -> Recipe.Results -> List (Html Msg)
distributionView selectedImpact recipe results =
    let
        impact =
            results.distribution.total
                |> Format.formatImpact selectedImpact
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Distribution" ]
        , results.distribution.total
            |> Format.formatImpact selectedImpact
        ]
    , ul [ class "CardList list-group list-group-flush border-top-0 border-bottom-0" ]
        (case recipe.distribution of
            Just distribution ->
                [ li [ class "IngredientFormWrapper list-group-item" ]
                    [ select
                        [ class "form-select form-select"
                        , onInput UpdateDistribution
                        ]
                        (Retail.all
                            |> List.map
                                (\distrib ->
                                    option
                                        [ selected (recipe.distribution == Just distrib)
                                        , value (Retail.toString distrib)
                                        ]
                                        [ text (Retail.toDisplay distrib) ]
                                )
                        )
                    , span [ class "text-end ImpactDisplay fs-7" ] [ impact ]
                    , deleteItemButton ResetDistribution
                    ]
                , li
                    [ class "list-group-item fs-7" ]
                    [ distribution
                        |> Retail.displayNeeds
                        |> text
                    ]
                ]

            Nothing ->
                [ addProcessFormView
                    { isDisabled = False
                    , event = AddDistribution
                    , kind = "un mode de distribution"
                    }
                ]
        )
    ]


consumptionView : FoodDb.Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
consumptionView db selectedImpact recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Consommation" ]
        , results.preparation
            |> Format.formatImpact selectedImpact
        ]
    , ul [ class "CardList list-group list-group-flush" ]
        ((if List.isEmpty recipe.preparation then
            [ li [ class "list-group-item" ] [ text "Aucune préparation" ] ]

          else
            recipe.preparation
                |> List.map
                    (\usedPreparation ->
                        li [ class "list-group-item d-flex justify-content-between align-items-center gap-2 pb-3" ]
                            [ Preparation.all
                                |> List.sortBy .name
                                |> List.map
                                    (\{ id, name } ->
                                        option
                                            [ selected <| usedPreparation.id == id
                                            , value <| Preparation.idToString id
                                            , disabled <| List.member id (List.map .id recipe.preparation)
                                            ]
                                            [ text name ]
                                    )
                                |> select
                                    [ class "form-select form-select w-50"
                                    , onInput (Preparation.Id >> UpdatePreparation usedPreparation.id)
                                    ]
                            , span [ class "w-50 text-end" ]
                                [ usedPreparation
                                    |> Preparation.apply db results.recipe.transformedMass
                                    |> Format.formatImpact selectedImpact
                                ]
                            , deleteItemButton (DeletePreparation usedPreparation.id)
                            ]
                    )
         )
            ++ [ addProcessFormView
                    { isDisabled = List.length recipe.preparation == 2
                    , event = AddPreparation
                    , kind = "une technique de préparation"
                    }
               ]
        )
    ]


mainView : Session -> Model -> Html Msg
mainView session model =
    let
        computed =
            session.queries.food
                |> Recipe.compute model.db
    in
    div [ class "row gap-3 gap-lg-0" ]
        [ div [ class "col-lg-8 d-flex flex-column gap-3" ]
            [ menuView session.queries.food
            , case computed of
                Ok ( recipe, results ) ->
                    stepListView model recipe results

                Err error ->
                    errorView error
            , session.queries.food
                |> debugQueryView model.db
            ]
        , div [ class "col-lg-4 d-flex flex-column gap-3" ]
            [ case computed of
                Ok ( _, results ) ->
                    sidebarView session model results

                Err error ->
                    errorView error
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


processSelectorView :
    Process.Identifier
    -> (Process.Identifier -> msg)
    -> List Process.Identifier
    -> List Process
    -> Html msg
processSelectorView selectedCode event excluded processes =
    select
        [ class "form-select form-select"
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


ingredientSelectorView : Recipe.RecipeIngredient -> List Id -> List Ingredient -> Html Msg
ingredientSelectorView selectedIngredient excluded ingredients =
    let
        availableIngredients =
            ingredients
                |> Recipe.availableIngredients excluded

        autocompleteState =
            AutocompleteSelector.init availableIngredients
    in
    div
        [ class "form-select IngredientSelector"
        , style "overflow" "hidden"
        , style "white-space" "nowrap"
        , onClick (SetModal (AddIngredientModal (Just selectedIngredient) autocompleteState))
        ]
        [ span
            [ style "display" "block"
            , style "overflow" "hidden"
            ]
            [ text selectedIngredient.ingredient.name ]
        ]


sidebarView : Session -> Model -> Recipe.Results -> Html Msg
sidebarView session model results =
    SidebarView.view
        { session = session
        , scope = Scope.Food

        -- Impact selector
        , selectedImpact = model.impact
        , switchImpact = SwitchImpact

        -- Score
        , productMass = results.preparedMass
        , totalImpacts = results.total

        -- Impacts tabs
        , impactTabsConfig =
            SwitchImpactsTab
                |> ImpactTabs.createConfig model.impact model.activeImpactsTab
                |> ImpactTabs.forFood results

        -- Bookmarks
        , activeBookmarkTab = model.bookmarkTab
        , bookmarkName = model.bookmarkName
        , copyToClipBoard = CopyToClipBoard
        , compareBookmarks = OpenComparator
        , deleteBookmark = DeleteBookmark
        , saveBookmark = SaveBookmark
        , updateBookmarkName = UpdateBookmarkName
        , switchBookmarkTab = SwitchBookmarksTab
        }


stepListView : Model -> Recipe -> Recipe.Results -> Html Msg
stepListView { db, impact } recipe results =
    div []
        [ div [ class "card shadow-sm" ]
            (ingredientListView db impact recipe results)
        , transportToTransformationView impact results
        , div [ class "card shadow-sm" ]
            (transformView db impact recipe results)
        , transportToPackagingView recipe results
        , div [ class "card shadow-sm" ]
            (packagingListView db impact recipe results)
        , transportToDistributionView impact recipe results
        , div [ class "card shadow-sm" ]
            (distributionView impact recipe results)
        , transportToConsumptionView recipe
        , div [ class "card shadow-sm" ]
            (consumptionView db impact recipe results)
        , transportAfterConsumptionView recipe results
        ]


transformView : FoodDb.Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
transformView db selectedImpact recipe results =
    let
        impact =
            results.recipe.transform
                |> Format.formatImpact selectedImpact
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Transformation" ]
        , impact
        ]
    , ul [ class "CardList list-group list-group-flush border-top-0 border-bottom-0" ]
        [ case recipe.transform of
            Just transform ->
                updateProcessFormView
                    { processes =
                        db.processes
                            |> Process.listByCategory Process.Transform
                    , excluded = [ transform.process.code ]
                    , processQuery = { code = transform.process.code, mass = transform.mass }
                    , impact = impact
                    , updateEvent = UpdateTransform
                    , deleteEvent = ResetTransform
                    }

            Nothing ->
                addProcessFormView
                    { isDisabled = False
                    , event = AddTransform
                    , kind = "une transformation"
                    }
        ]
    ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ mainView session model
            , case model.modal of
                NoModal ->
                    text ""

                ComparatorModal ->
                    ModalView.view
                        { size = ModalView.ExtraLarge
                        , close = SetModal NoModal
                        , noOp = NoOp
                        , title = "Comparateur de simulations sauvegardées"
                        , subTitle = Just "en score d'impact, par produit ⚠️\u{00A0}Attention, ces résultats sont provisoires"
                        , formAction = Nothing
                        , content =
                            [ ComparatorView.view
                                { session = session
                                , impact = model.impact
                                , comparisonType = model.comparisonType
                                , switchComparisonType = SwitchComparisonType
                                , toggle = ToggleComparedSimulation
                                }
                            ]
                        , footer = []
                        }

                AddIngredientModal _ autocompleteState ->
                    ingredientAutocompleteView autocompleteState
            ]
      ]
    )


ingredientAutocompleteView : Autocomplete Ingredient -> Html Msg
ingredientAutocompleteView autocompleteState =
    ModalView.view
        { size = ModalView.Large
        , close = SetModal NoModal
        , noOp = NoOp
        , title = "Sélectionnez un ingrédient"
        , subTitle = Nothing
        , formAction = Nothing
        , content =
            let
                { query, choices, selectedIndex } =
                    Autocomplete.viewState autocompleteState

                { inputEvents, choiceEvents } =
                    AutocompleteView.events
                        { onSelect = OnAutocompleteSelect
                        , mapHtml = OnAutocomplete
                        }

                renderChoice : (Int -> List (Attribute Msg)) -> Maybe Int -> Int -> Ingredient -> Html Msg
                renderChoice events selectedIndex_ index ingredient =
                    let
                        selected =
                            Autocomplete.isSelected selectedIndex_ index
                    in
                    button
                        (events index
                            ++ [ class "IngredientAutocompleteChoice"
                               , class "d-flex justify-content-between align-items-center gap-1 w-100"
                               , class "btn btn-outline-primary border-0 border-bottom text-start no-outline"
                               , classList [ ( "btn-primary selected", selected ) ]
                               , attribute "role" "option"
                               , attribute "aria-selected"
                                    (if selected then
                                        "true"

                                     else
                                        "false"
                                    )
                               ]
                        )
                        [ span [ class "text-nowrap" ] [ text ingredient.name ]
                        , span [ class "text-muted fs-8 text-truncate" ]
                            [ ingredient.categories
                                |> List.head
                                |> Maybe.map (IngredientCategory.toLabel >> text)
                                |> Maybe.withDefault (text "")
                            ]
                        ]
            in
            [ input
                (inputEvents
                    ++ [ type_ "search"
                       , id "ingredient-search"
                       , class "form-control"
                       , autocomplete False
                       , attribute "role" "combobox"
                       , attribute "aria-autocomplete" "list"
                       , attribute "aria-owns" "ingredients-autocomplete-choices"
                       , placeholder "tapez ici le nom de l'ingrédient pour le rechercher"
                       , value query
                       ]
                )
                []
            , choices
                |> List.indexedMap (renderChoice choiceEvents selectedIndex)
                |> div [ class "IngredientAutocomplete", id "ingredients-autocomplete-choices" ]
            ]
        , footer = []
        }


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        _ ->
            BE.onKeyDown (Key.escape (SetModal NoModal))
