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
import Data.Food.Ingredient as Ingredient exposing (Id, Ingredient)
import Data.Food.Ingredient.Category as IngredientCategory
import Data.Food.Origin as Origin
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process exposing (Process)
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
import Page.Textile.Simulator.ViewMode as ViewMode
import Ports
import Quantity
import RemoteData exposing (WebData)
import Request.Food.BuilderDb as FoodRequestDb
import Route
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.Bookmark as BookmarkView
import Views.Button as Button
import Views.CardTabs as CardTabs
import Views.Comparator as ComparatorView
import Views.Component.DownArrow as DownArrow
import Views.Component.MassInput as MassInput
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Link as Link
import Views.Modal as ModalView
import Views.Table as Table
import Views.Textile.ComparativeChart as ComparativeChart
import Views.Transport as TransportView


type alias Model =
    { db : Db
    , impact : Definition
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonUnit : ComparatorView.FoodComparisonUnit
    , displayChoice : ComparatorView.DisplayChoice
    , modal : Modal
    , chartHovering : ComparativeChart.Stacks
    , activeImpactsTab : ImpactsTab
    }


type Modal
    = NoModal
    | ComparatorModal


type Msg
    = AddIngredient
    | AddPackaging
    | AddPreparation
    | AddTransform
    | AddDistribution
    | CopyToClipBoard String
    | DbLoaded (WebData Db)
    | DeleteBookmark Bookmark
    | DeleteIngredient Ingredient.Id
    | DeletePackaging Process.Code
    | DeletePreparation Preparation.Id
    | LoadQuery Query
    | NoOp
    | OnChartHover ComparativeChart.Stacks
    | OpenComparator
    | ResetTransform
    | ResetDistribution
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SetModal Modal
    | SwitchComparisonUnit ComparatorView.FoodComparisonUnit
    | SwitchDisplayChoice ComparatorView.DisplayChoice
    | SwitchLinksTab BookmarkView.ActiveTab
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactsTab
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateIngredient Id Query.IngredientQuery
    | UpdatePackaging Process.Code Query.ProcessQuery
    | UpdatePreparation Preparation.Id Preparation.Id
    | UpdateTransform Query.ProcessQuery
    | UpdateDistribution String


type ImpactsTab
    = DetailedImpactsTab
    | StepImpactsTab
    | SubscoresTab


init : Db -> Session -> Definition.Trigram -> Maybe Query -> ( Model, Session, Cmd Msg )
init db ({ builderDb, queries } as session) trigram maybeQuery =
    let
        impact =
            Definition.get db.impactDefinitions trigram

        query =
            maybeQuery
                |> Maybe.withDefault queries.food
    in
    ( { db = db
      , impact = impact
      , bookmarkName = query |> findExistingBookmarkName session
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonUnit = ComparatorView.PerKgOfProduct
      , displayChoice = ComparatorView.IndividualImpacts
      , modal = NoModal
      , chartHovering = []
      , activeImpactsTab =
            if impact.trigram == Definition.Ecs then
                SubscoresTab

            else
                StepImpactsTab
      }
    , session
        |> Session.updateFoodQuery query
    , Cmd.batch
        [ case maybeQuery of
            Nothing ->
                Ports.scrollTo { x = 0, y = 0 }

            Just _ ->
                Cmd.none
        , if builderDb == RemoteData.NotAsked then
            FoodRequestDb.loadDb session DbLoaded

          else
            Cmd.none
        ]
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
                    model.db.ingredients
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

        DbLoaded db ->
            ( model
            , { session | builderDb = db }
            , Cmd.none
            )

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

        OnChartHover chartHovering ->
            ( { model | chartHovering = chartHovering }
            , session
            , Cmd.none
            )

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
            ( { model | modal = modal }, session, Cmd.none )

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

        SwitchComparisonUnit comparisonUnit ->
            ( { model | comparisonUnit = comparisonUnit }
            , session
            , Cmd.none
            )

        SwitchDisplayChoice displayChoice ->
            ( { model | displayChoice = displayChoice }, session, Cmd.none )

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
findExistingBookmarkName { builderDb, store } query =
    case builderDb of
        RemoteData.Success db ->
            store.bookmarks
                |> Bookmark.findByFoodQuery query
                |> Maybe.map .name
                |> Maybe.withDefault
                    (query
                        |> Recipe.fromQuery db
                        |> Result.map Recipe.toString
                        |> Result.withDefault ""
                    )

        _ ->
            ""



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
            [ div [ class "w-100" ]
                [ div [ class "text-center" ]
                    [ text "Soit pour "
                    , Format.kg results.preparedMass
                    , text "\u{00A0}:\u{00A0}"
                    , results.total
                        |> Format.formatFoodSelectedImpact model.impact
                    ]
                , if model.impact.trigram == Definition.Ecs then
                    div [ class "text-center fs-7" ]
                        [ text " dont -"
                        , results.recipe.totalBonusesImpact.total
                            |> Unit.impactToFloat
                            |> Format.formatImpactFloat model.impact
                        , text " de bonus déduit"
                        ]

                  else
                    text ""
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
    , excluded : List Process.Code
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
    , db : Db
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
            , variant = recipeIngredient.variant
            , country = recipeIngredient.country |> Maybe.map .code
            , planeTransport = recipeIngredient.planeTransport
            , bonuses = Just recipeIngredient.bonuses
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
                recipeIngredient.ingredient.id
                excluded
                (\newIngredient ->
                    let
                        newVariant =
                            case ingredientQuery.variant of
                                Query.DefaultVariant ->
                                    Query.DefaultVariant

                                Query.Organic ->
                                    if newIngredient.variants.organic == Nothing then
                                        -- Fallback to "Default" if the new ingredient doesn't have an "organic" variant
                                        Query.DefaultVariant

                                    else
                                        Query.Organic
                    in
                    event
                        { ingredientQuery
                            | id = newIngredient.id
                            , variant = newVariant
                            , country = Nothing
                            , planeTransport = Ingredient.byPlaneByDefault newIngredient
                            , bonuses =
                                newVariant
                                    |> Query.updateBonusesFromVariant db.ingredients newIngredient.id
                                    |> Just
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
        , label
            [ class "BioCheckbox"
            , classList [ ( "text-muted", recipeIngredient.ingredient.variants.organic == Nothing ) ]
            ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input no-outline"
                , attribute "role" "switch"
                , checked <| recipeIngredient.variant == Query.Organic
                , disabled <| recipeIngredient.ingredient.variants.organic == Nothing
                , onCheck
                    (\checked ->
                        let
                            variant =
                                if checked then
                                    Query.Organic

                                else
                                    Query.DefaultVariant
                        in
                        event
                            { ingredientQuery
                                | variant = variant
                                , bonuses =
                                    variant
                                        |> Query.updateBonusesFromVariant db.ingredients recipeIngredient.ingredient.id
                                        |> Just
                            }
                    )
                ]
                []
            , text "bio"
            ]
        , span [ class "text-end ImpactDisplay fs-7" ]
            [ impact
                |> Format.formatFoodSelectedImpact selectedImpact
            ]
        , deleteItemButton (DeleteIngredient ingredientQuery.id)
        , if selectedImpact.trigram == Definition.Ecs then
            let
                { bonuses, ingredient } =
                    recipeIngredient

                bonusImpacts =
                    impact
                        |> Recipe.computeIngredientBonusesImpacts db.impactDefinitions bonuses
            in
            details [ class "IngredientBonuses fs-7" ]
                [ summary [] [ text "Bonus écologiques" ]
                , ingredientBonusView
                    { name = "Diversité agricole"
                    , title = Nothing
                    , domId = "agroDiversity_" ++ String.fromInt index
                    , bonusImpact = bonusImpacts.agroDiversity
                    , bonusSplit = bonuses.agroDiversity
                    , disabled = False
                    , selectedImpact = selectedImpact
                    , updateEvent =
                        \split ->
                            event { ingredientQuery | bonuses = Just { bonuses | agroDiversity = split } }
                    }
                , ingredientBonusView
                    { name = "Infra. agro-éco."
                    , title = Just "Infrastructures agro-écologiques"
                    , domId = "agroEcology_" ++ String.fromInt index
                    , bonusImpact = bonusImpacts.agroEcology
                    , bonusSplit = bonuses.agroEcology
                    , disabled = False
                    , selectedImpact = selectedImpact
                    , updateEvent =
                        \split ->
                            event { ingredientQuery | bonuses = Just { bonuses | agroEcology = split } }
                    }
                , ingredientBonusView
                    { name = "Cond. d'élevage"
                    , title = Nothing
                    , domId = "animalWelfare_" ++ String.fromInt index
                    , bonusImpact = bonusImpacts.animalWelfare
                    , bonusSplit = bonuses.animalWelfare
                    , disabled = ingredient.category /= IngredientCategory.AnimalProduct
                    , selectedImpact = selectedImpact
                    , updateEvent =
                        \split ->
                            event { ingredientQuery | bonuses = Just { bonuses | animalWelfare = split } }
                    }
                ]

          else
            text ""
        , displayTransportDistances db recipeIngredient ingredientQuery event
        , span
            [ class "text-muted text-end IngredientTransportImpact fs-7"
            , title "Impact du transport pour cet ingrédient"
            ]
            [ text "+ "
            , transportImpact
            ]
        ]


type alias BonusViewConfig msg =
    { bonusImpact : Unit.Impact
    , bonusSplit : Split
    , disabled : Bool
    , domId : String
    , name : String
    , selectedImpact : Definition
    , title : Maybe String
    , updateEvent : Split -> msg
    }


ingredientBonusView : BonusViewConfig Msg -> Html Msg
ingredientBonusView { name, bonusImpact, bonusSplit, disabled, domId, selectedImpact, title, updateEvent } =
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
            , Attr.value <| Split.toPercentString bonusSplit
            , onInput
                (String.toInt
                    >> Maybe.andThen (Split.fromPercent >> Result.toMaybe)
                    >> Maybe.withDefault Split.zero
                    >> updateEvent
                )
            ]
            []
        , div [ class "BonusValue d-flex align-items-center text-muted" ]
            [ Format.splitAsPercentage bonusSplit
            , Button.smallPillLink
                [ href (Gitbook.publicUrlFromPath Gitbook.FoodBonuses)
                , target "_blank"
                ]
                [ Icon.question ]
            ]
        , div [ class "BonusImpact text-end text-muted" ]
            [ bonusImpact
                |> Quantity.negate
                |> Unit.impactToFloat
                |> Format.formatImpactFloat selectedImpact
            ]
        ]


displayTransportDistances : Db -> Recipe.RecipeIngredient -> Query.IngredientQuery -> (Query.IngredientQuery -> Msg) -> Html Msg
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
                    |> Query.serialize
                    |> debugView
                ]
            , div [ class "col-5" ]
                [ query
                    |> Recipe.compute db
                    |> Result.map (Tuple.second >> Recipe.encodeResults db.impactDefinitions >> Encode.encode 2)
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


ingredientListView : Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
ingredientListView db selectedImpact recipe results =
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
            |> Format.formatFoodSelectedImpact selectedImpact
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
                                    |> Format.formatFoodSelectedImpact selectedImpact
                            }
                    )
         )
            ++ [ li [ class "list-group-item p-0" ]
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


packagingListView : Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
packagingListView db selectedImpact recipe results =
    let
        availablePackagings =
            Recipe.availablePackagings (List.map (.process >> .code) recipe.packaging) db.processes
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Emballage" ]
        , results.packaging
            |> Format.formatFoodSelectedImpact selectedImpact
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
                                    |> Format.formatFoodSelectedImpact selectedImpact
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


transportToTransformationView : Definition -> Recipe -> Recipe.Results -> Html Msg
transportToTransformationView selectedImpact recipe results =
    DownArrow.view
        []
        [ div []
            [ text "Masse\u{00A0}: "
            , recipe.ingredients
                |> Query.getIngredientMass
                |> Format.kg
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
            , Format.formatFoodSelectedImpact selectedImpact results.recipe.transports.impacts
            ]
        ]


transportToPackagingView : Recipe -> Html Msg
transportToPackagingView recipe =
    DownArrow.view
        []
        [ div []
            [ case recipe.transform of
                Just transform ->
                    span
                        [ title <| "(" ++ Process.nameToString transform.process.name ++ ")" ]
                        [ text "Masse du produit après transformation : " ]

                Nothing ->
                    text "Masse : "
            , Recipe.getTransformedIngredientsMass recipe
                |> Format.kg
            , Link.smallPillExternal
                [ href (Gitbook.publicUrlFromPath Gitbook.FoodRawToCookedRatio)
                , title "Accéder à la documentation"
                , attribute "aria-label" "Accéder à la documentation"
                ]
                [ Icon.question ]
            ]
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
            , Format.formatFoodSelectedImpact selectedImpact results.distribution.transports.impacts
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
                |> Format.formatFoodSelectedImpact selectedImpact
    in
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Distribution" ]
        , results.distribution.total
            |> Format.formatFoodSelectedImpact selectedImpact
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


consumptionView : BuilderDb.Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
consumptionView db selectedImpact recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Consommation" ]
        , results.preparation
            |> Format.formatFoodSelectedImpact selectedImpact
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
                                    |> Format.formatFoodSelectedImpact selectedImpact
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
        [ div [ class "col-lg-4 order-lg-2 d-flex flex-column gap-3" ]
            [ case computed of
                Ok ( _, results ) ->
                    sidebarView session model results

                Err error ->
                    errorView error
            ]
        , div [ class "col-lg-8 order-lg-1 d-flex flex-column gap-3" ]
            [ menuView session.queries.food
            , case computed of
                Ok ( recipe, results ) ->
                    stepListView model recipe results

                Err error ->
                    errorView error
            , session.queries.food
                |> debugQueryView model.db
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


ingredientSelectorView : Id -> List Id -> (Ingredient -> Msg) -> List Ingredient -> Html Msg
ingredientSelectorView selectedIngredient excluded event ingredients =
    select
        [ class "form-select form-select IngredientSelector"
        , onInput
            (\ingredientId ->
                ingredients
                    |> Ingredient.findByID (Ingredient.idFromString ingredientId)
                    |> Result.map event
                    |> Result.withDefault NoOp
            )
        ]
        (ingredients
            |> Ingredient.groupCategories
            |> List.map
                (\( category, categoryIngredients ) ->
                    categoryIngredients
                        |> List.map
                            (\ingredient ->
                                option
                                    [ selected <| selectedIngredient == ingredient.id
                                    , disabled <| List.member ingredient.id excluded
                                    , value <| Ingredient.idToString ingredient.id
                                    ]
                                    [ text ingredient.name ]
                            )
                        |> optgroup [ category |> IngredientCategory.toLabel |> attribute "label" ]
                )
        )


sidebarView : Session -> Model -> Recipe.Results -> Html Msg
sidebarView session model results =
    div
        [ class "d-flex flex-column gap-3 mb-3 sticky-md-top"
        , style "top" "7px"
        ]
        [ ImpactView.impactSelector
            session.db.impactDefinitions
            { scope = Scope.Food
            , selectedImpact = model.impact.trigram
            , switchImpact = SwitchImpact

            -- FIXME: We don't use the following two textile configs
            , selectedFunctionalUnit = Unit.PerItem
            , switchFunctionalUnit = always NoOp
            }
        , absoluteImpactView model results
        , impactTabsView model results
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


impactTabsView : Model -> Recipe.Results -> Html Msg
impactTabsView model results =
    CardTabs.view
        { tabs =
            (if model.impact.trigram == Definition.Ecs then
                [ ( SubscoresTab, "Sous-scores" )
                , ( DetailedImpactsTab, "Impacts" )
                , ( StepImpactsTab, "Étapes" )
                ]

             else
                [ ( StepImpactsTab, "Étapes" ) ]
            )
                |> List.map
                    (\( tab, label ) ->
                        { label = label
                        , onTabClick = SwitchImpactsTab tab
                        , active = model.activeImpactsTab == tab
                        }
                    )
        , content =
            [ case model.activeImpactsTab of
                DetailedImpactsTab ->
                    results.total
                        |> Impact.getAggregatedScoreData model.db.impactDefinitions .ecoscoreData
                        |> List.map (\{ name, value } -> ( name, value ))
                        |> (++)
                            [ ( "Bonus de diversité agricole"
                              , -(Unit.impactToFloat results.recipe.totalBonusesImpact.agroDiversity)
                              )
                            , ( "Bonus d'infrastructures agro-écologiques"
                              , -(Unit.impactToFloat results.recipe.totalBonusesImpact.agroEcology)
                              )
                            , ( "Bonus conditions d'élevage"
                              , -(Unit.impactToFloat results.recipe.totalBonusesImpact.animalWelfare)
                              )
                            ]
                        |> List.sortBy Tuple.second
                        |> List.reverse
                        |> Table.percentageTable

                StepImpactsTab ->
                    let
                        toFloat =
                            Impact.getImpact model.impact.trigram >> Unit.impactToFloat
                    in
                    Table.percentageTable
                        [ ( "Ingrédients", toFloat results.recipe.ingredientsTotal )
                        , ( "Transformation", toFloat results.recipe.transform )
                        , ( "Emballage", toFloat results.packaging )
                        , ( "Transports", toFloat results.transports.impacts )
                        , ( "Distribution", toFloat results.distribution.total )
                        , ( "Consommation", toFloat results.preparation )
                        ]

                SubscoresTab ->
                    Table.percentageTable
                        [ ( "Climat", Unit.impactToFloat results.scoring.climate )
                        , ( "Biodiversité", Unit.impactToFloat results.scoring.biodiversity )
                        , ( "Santé environnementale", Unit.impactToFloat results.scoring.health )
                        , ( "Ressource", Unit.impactToFloat results.scoring.resources )
                        , ( "Bonus", -(Unit.impactToFloat results.scoring.bonuses) )
                        ]
            ]
        }


stepListView : Model -> Recipe -> Recipe.Results -> Html Msg
stepListView { db, impact } recipe results =
    div []
        [ div [ class "card shadow-sm" ]
            (ingredientListView db impact recipe results)
        , transportToTransformationView impact recipe results
        , div [ class "card shadow-sm" ]
            (transformView db impact recipe results)
        , transportToPackagingView recipe
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


transformView : Db -> Definition -> Recipe -> Recipe.Results -> List (Html Msg)
transformView db selectedImpact recipe results =
    let
        impact =
            results.recipe.transform
                |> Format.formatFoodSelectedImpact selectedImpact
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
                        , formAction = Nothing
                        , content =
                            [ ComparatorView.comparator
                                { session = session
                                , impact = model.impact
                                , options =
                                    ComparatorView.foodOptions
                                        { comparisonUnit = model.comparisonUnit
                                        , switchComparisonUnit = SwitchComparisonUnit
                                        , displayChoice = model.displayChoice
                                        , switchDisplayChoice = SwitchDisplayChoice
                                        , db = model.db
                                        }
                                , toggle = ToggleComparedSimulation
                                , chartHovering = model.chartHovering
                                , onChartHover = OnChartHover
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

        _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
