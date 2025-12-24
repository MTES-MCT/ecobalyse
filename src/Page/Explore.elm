module Page.Explore exposing
    ( Model
    , Msg(..)
    , foodIngredientDetails
    , init
    , subscriptions
    , textileMaterialDetails
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Browser.Events
import Browser.Navigation as Nav
import Data.Component as Component exposing (Component)
import Data.Country as Country exposing (Country)
import Data.Dataset as Dataset exposing (Dataset)
import Data.Example as Example exposing (Example)
import Data.Food.Db as FoodDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Key as Key
import Data.Object.Simulator as ObjectSimulator
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as TextileQuery
import Data.Textile.Simulator as Simulator
import Data.Unit as Unit
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Explore.Components as Components
import Page.Explore.Countries as ExploreCountries
import Page.Explore.FoodExamples as FoodExamples
import Page.Explore.FoodIngredients as FoodIngredients
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.ObjectExamples as ObjectExamples
import Page.Explore.Processes as Processes
import Page.Explore.Table as Table
import Page.Explore.TextileExamples as TextileExamples
import Page.Explore.TextileMaterials as TextileMaterials
import Page.Explore.TextileProducts as TextileProducts
import Ports
import Route exposing (Route)
import Static.Db exposing (Db)
import Table as SortableTable exposing (defaultCustomizations)
import Views.Alert as Alert
import Views.Container as Container
import Views.Modal as ModalView


type alias Model =
    { dataset : Dataset
    , scope : Scope
    , search : String
    , tableState : SortableTable.State
    }


type Msg
    = CloseModal
    | NoOp
    | OpenDetail Route
    | ScopeChange Scope
    | SetTableState SortableTable.State
    | UpdateSearch String


init : Scope -> Dataset -> Session -> PageUpdate Model Msg
init scope dataset session =
    let
        initialSort =
            case dataset of
                Dataset.Components _ _ ->
                    "Nom"

                Dataset.Countries _ ->
                    "Nom"

                Dataset.FoodExamples _ ->
                    "Coût Environnemental"

                Dataset.FoodIngredients _ ->
                    "Identifiant"

                Dataset.Impacts _ ->
                    "Code"

                Dataset.ObjectExamples _ ->
                    "Coût Environnemental"

                Dataset.Processes _ _ ->
                    "Nom"

                Dataset.TextileExamples _ ->
                    "Coût Environnemental"

                Dataset.TextileMaterials _ ->
                    "Identifiant"

                Dataset.TextileProducts _ ->
                    "Identifiant"

                Dataset.VeliExamples _ ->
                    "Coût Environnemental"
    in
    createPageUpdate session
        { dataset = dataset
        , scope = scope
        , search = ""
        , tableState = SortableTable.initialSort initialSort
        }


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        CloseModal ->
            createPageUpdate session model
                |> App.withCmds
                    [ model.dataset
                        |> Dataset.reset
                        |> Route.Explore model.scope
                        |> Route.toString
                        |> Nav.pushUrl session.navKey
                    ]

        NoOp ->
            createPageUpdate session model

        OpenDetail route ->
            createPageUpdate session model
                |> App.withCmds
                    [ route
                        |> Route.toString
                        |> Nav.pushUrl session.navKey
                    ]

        ScopeChange scope ->
            createPageUpdate session { model | scope = scope }
                |> App.withCmds
                    [ (case model.dataset of
                        -- Try selecting the most appropriate tab when switching scope.
                        Dataset.Countries _ ->
                            Dataset.Countries Nothing

                        Dataset.Impacts _ ->
                            Dataset.Impacts Nothing

                        _ ->
                            case scope of
                                Scope.Food ->
                                    Dataset.FoodExamples Nothing

                                Scope.Object ->
                                    Dataset.ObjectExamples Nothing

                                Scope.Textile ->
                                    Dataset.TextileExamples Nothing

                                Scope.Veli ->
                                    Dataset.VeliExamples Nothing
                      )
                        |> Route.Explore scope
                        |> Route.toString
                        |> Nav.pushUrl session.navKey
                    ]

        SetTableState tableState ->
            createPageUpdate session { model | tableState = tableState }

        UpdateSearch search ->
            createPageUpdate session { model | search = search }


{-| Create a page update preventing the body to be scrollable when one or more modals are opened.
-}
createPageUpdate : Session -> Model -> PageUpdate Model Msg
createPageUpdate session model =
    App.createUpdate session model
        |> App.withCmds
            [ if Dataset.isDetailed model.dataset then
                Ports.addBodyClass "prevent-scrolling"

              else
                Ports.removeBodyClass "prevent-scrolling"
            ]


datasetsMenuView : Model -> Html Msg
datasetsMenuView { scope, dataset } =
    Dataset.datasets scope
        |> List.map
            (\ds ->
                a
                    [ class "TabsTab nav-link"
                    , classList [ ( "active", Dataset.same ds dataset ) ]
                    , Route.href (Route.Explore scope ds)
                    ]
                    [ text (Dataset.label ds) ]
            )
        |> nav
            [ class "Tabs nav nav-tabs d-flex justify-content-end align-items-center gap-0 gap-sm-2"
            ]


scopesMenuView : Session -> Model -> Html Msg
scopesMenuView { enabledSections } model =
    div [ class "d-flex align-items-center gap-3" ]
        [ label [ class "fw-bold d-none d-sm-block", for "scope-selector" ]
            [ text "Secteur" ]
        , [ ( Scope.Food, enabledSections.food )
          , ( Scope.Object, enabledSections.objects )
          , ( Scope.Textile, True )
          , ( Scope.Veli, enabledSections.veli )
          ]
            |> List.filter Tuple.second
            |> List.map
                (\( scope, _ ) ->
                    option
                        [ selected <| model.scope == scope
                        , value <| Scope.toString scope
                        ]
                        [ text <| Scope.toLabel scope ]
                )
            |> select
                [ class "form-select"
                , id "scope-selector"
                , onInput
                    (Scope.fromString
                        >> Result.toMaybe
                        >> Maybe.withDefault Scope.Textile
                        >> ScopeChange
                    )
                ]
        ]


detailsModal : Html Msg -> Html Msg
detailsModal content =
    ModalView.view
        { size = ModalView.Large
        , close = CloseModal
        , noOp = NoOp
        , title = "Détail de l'enregistrement"
        , subTitle = Nothing
        , formAction = Nothing
        , content = [ content ]
        , footer = []
        }


alert : String -> Html Msg
alert error =
    div [ class "p-3 pb-0" ]
        [ Alert.simple
            { attributes = []
            , level = Alert.Danger
            , content = [ text error ]
            , title = Just "Erreur"
            , close = Nothing
            }
        ]


countriesExplorer :
    Db
    -> Table.Config Country Msg
    -> SortableTable.State
    -> Scope
    -> Maybe Country.Code
    -> List (Html Msg)
countriesExplorer { distances, countries } tableConfig tableState scope maybeCode =
    [ countries
        |> List.filter (.scopes >> List.member scope)
        |> Table.viewList OpenDetail tableConfig tableState scope (ExploreCountries.table distances countries)
    , case maybeCode of
        Just code ->
            detailsModal
                (case Country.findByCode code countries of
                    Err error ->
                        alert error

                    Ok country ->
                        country
                            |> Table.viewDetails scope (ExploreCountries.table distances countries)
                )

        Nothing ->
            text ""
    ]


impactsExplorer :
    Definitions
    -> Table.Config Definition Msg
    -> SortableTable.State
    -> Scope
    -> Maybe Definition.Trigram
    -> List (Html Msg)
impactsExplorer definitions tableConfig tableState scope maybeTrigram =
    [ Definition.toList definitions
        |> List.sortBy (.trigram >> Definition.toString)
        |> Table.viewList OpenDetail tableConfig tableState scope ExploreImpacts.table
    , maybeTrigram
        |> Maybe.map (\trigram -> Definition.get trigram definitions)
        |> Maybe.map (Table.viewDetails scope ExploreImpacts.table)
        |> Maybe.map detailsModal
        |> Maybe.withDefault (text "")
    ]


foodExamplesExplorer :
    Db
    -> Table.Config ( Example FoodQuery.Query, { score : Float, per100g : Float } ) Msg
    -> SortableTable.State
    -> Maybe Uuid
    -> List (Html Msg)
foodExamplesExplorer db tableConfig tableState maybeId =
    let
        scoredExamples =
            db.food.examples
                |> List.map
                    (\example ->
                        ( example
                        , { score = getFoodScore db example
                          , per100g = getFoodScorePer100g db example
                          }
                        )
                    )
                |> List.sortBy (Tuple.first >> .name)

        max =
            { maxScore =
                scoredExamples
                    |> List.map (Tuple.second >> .score)
                    |> List.maximum
                    |> Maybe.withDefault 0
            , maxPer100g =
                scoredExamples
                    |> List.map (Tuple.second >> .per100g)
                    |> List.maximum
                    |> Maybe.withDefault 0
            }
    in
    [ scoredExamples
        |> List.filter (Tuple.first >> .query >> (/=) FoodQuery.empty)
        |> List.sortBy (Tuple.first >> .name)
        |> Table.viewList OpenDetail tableConfig tableState Scope.Food (FoodExamples.table max)
    , case maybeId of
        Just id ->
            detailsModal
                (case Example.findByUuid id db.food.examples of
                    Err error ->
                        alert error

                    Ok example ->
                        Table.viewDetails Scope.Food
                            (FoodExamples.table max)
                            ( example
                            , { score = getFoodScore db example
                              , per100g = getFoodScorePer100g db example
                              }
                            )
                )

        Nothing ->
            text ""
    ]


foodIngredientsExplorer :
    Db
    -> Table.Config Ingredient Msg
    -> SortableTable.State
    -> Maybe Ingredient.Id
    -> List (Html Msg)
foodIngredientsExplorer { food } tableConfig tableState maybeId =
    [ food.ingredients
        |> List.sortBy .name
        |> Table.viewList OpenDetail tableConfig tableState Scope.Food (FoodIngredients.table food)
    , case maybeId of
        Just id ->
            detailsModal
                (case Ingredient.findById id food.ingredients of
                    Err error ->
                        alert error

                    Ok ingredient ->
                        foodIngredientDetails food ingredient
                )

        Nothing ->
            text ""
    ]


foodIngredientDetails : FoodDb.Db -> Ingredient -> Html msg
foodIngredientDetails foodDb =
    Table.viewDetails Scope.Food (FoodIngredients.table foodDb)


processesExplorer :
    Session
    -> Scope
    -> Table.Config Process Msg
    -> SortableTable.State
    -> Maybe Process.Id
    -> List (Html Msg)
processesExplorer session scope tableConfig tableState maybeId =
    let
        scopedProcesses =
            session.db.processes
                |> Scope.anyOf [ scope ]
    in
    [ scopedProcesses
        |> List.sortBy Process.getDisplayName
        |> Table.viewList OpenDetail tableConfig tableState scope (Processes.table session)
    , case maybeId of
        Just id ->
            detailsModal
                (case Process.findById id scopedProcesses of
                    Err error ->
                        alert error

                    Ok process ->
                        process
                            |> Table.viewDetails scope (Processes.table session)
                )

        Nothing ->
            text ""
    ]


componentsExplorer :
    Db
    -> Scope
    -> Table.Config Component Msg
    -> SortableTable.State
    -> Maybe Component.Id
    -> List (Html Msg)
componentsExplorer db scope tableConfig tableState maybeId =
    let
        scopedComponents =
            db.components |> List.filter (.scope >> (==) scope)
    in
    [ scopedComponents
        |> List.sortBy .name
        |> Table.viewList OpenDetail tableConfig tableState scope (Components.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Component.findById id scopedComponents of
                    Err error ->
                        alert error

                    Ok component ->
                        component
                            |> Table.viewDetails scope (Components.table db)
                )

        Nothing ->
            text ""
    ]


objectExamplesExplorer :
    Session
    -> Table.Config ( Example Component.Query, { score : Float } ) Msg
    -> SortableTable.State
    -> Scope
    -> Maybe Uuid
    -> List (Html Msg)
objectExamplesExplorer session tableConfig tableState scope maybeId =
    let
        scoredExamples =
            session.db.object.examples
                |> List.filter (\example -> example.scope == scope)
                |> List.map (\example -> ( example, { score = getObjectScore session scope example } ))
                |> List.sortBy (Tuple.first >> .name)

        max =
            { maxScore =
                scoredExamples
                    |> List.map (Tuple.second >> .score)
                    |> List.maximum
                    |> Maybe.withDefault 0
            }
    in
    [ scoredExamples
        |> List.filter (Tuple.first >> .query >> (/=) Component.emptyQuery)
        |> List.sortBy (Tuple.first >> .name)
        |> Table.viewList OpenDetail tableConfig tableState scope (ObjectExamples.table max)
    , case maybeId of
        Just id ->
            detailsModal
                (case Example.findByUuid id session.db.object.examples of
                    Err error ->
                        alert error

                    Ok example ->
                        ( example, { score = getObjectScore session scope example } )
                            |> Table.viewDetails scope (ObjectExamples.table max)
                )

        Nothing ->
            text ""
    ]


textileExamplesExplorer :
    Session
    -> Table.Config ( Example TextileQuery.Query, { score : Float, per100g : Float } ) Msg
    -> SortableTable.State
    -> Maybe Uuid
    -> List (Html Msg)
textileExamplesExplorer session tableConfig tableState maybeId =
    let
        scoredExamples =
            session.db.textile.examples
                |> List.map
                    (\example ->
                        ( example
                        , { score = getTextileScore session example
                          , per100g = getTextileScorePer100g session example
                          }
                        )
                    )
                |> List.sortBy (Tuple.first >> .name)

        max =
            { maxScore =
                scoredExamples
                    |> List.map (Tuple.second >> .score)
                    |> List.maximum
                    |> Maybe.withDefault 0
            , maxPer100g =
                scoredExamples
                    |> List.map (Tuple.second >> .per100g)
                    |> List.maximum
                    |> Maybe.withDefault 0
            }
    in
    [ scoredExamples
        |> List.sortBy (Tuple.first >> .name)
        |> Table.viewList OpenDetail tableConfig tableState Scope.Textile (TextileExamples.table session max)
    , case maybeId of
        Just id ->
            detailsModal
                (case Example.findByUuid id session.db.textile.examples of
                    Err error ->
                        alert error

                    Ok example ->
                        Table.viewDetails Scope.Textile
                            (TextileExamples.table session max)
                            ( example
                            , { score = getTextileScore session example
                              , per100g = getTextileScorePer100g session example
                              }
                            )
                )

        Nothing ->
            text ""
    ]


textileProductsExplorer :
    Session
    -> Table.Config Product Msg
    -> SortableTable.State
    -> Maybe Product.Id
    -> List (Html Msg)
textileProductsExplorer session tableConfig tableState maybeId =
    [ session.db.textile.products
        |> Table.viewList OpenDetail tableConfig tableState Scope.Textile (TextileProducts.table session)
    , case maybeId of
        Just id ->
            detailsModal
                (case Product.findById id session.db.textile.products of
                    Err error ->
                        alert error

                    Ok product ->
                        Table.viewDetails Scope.Textile (TextileProducts.table session) product
                )

        Nothing ->
            text ""
    ]


textileMaterialsExplorer :
    Db
    -> Table.Config Material Msg
    -> SortableTable.State
    -> Maybe Material.Id
    -> List (Html Msg)
textileMaterialsExplorer db tableConfig tableState maybeId =
    [ db.textile.materials
        |> Table.viewList OpenDetail tableConfig tableState Scope.Textile (TextileMaterials.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Material.findById id db.textile.materials of
                    Err error ->
                        alert error

                    Ok material ->
                        textileMaterialDetails db material
                )

        Nothing ->
            text ""
    ]


textileMaterialDetails : Db -> Material -> Html msg
textileMaterialDetails db =
    Table.viewDetails Scope.Textile (TextileMaterials.table db)


getFoodScore : Db -> Example FoodQuery.Query -> Float
getFoodScore db =
    .query
        >> Recipe.compute db
        >> Result.map
            (Tuple.second
                >> .total
                >> Impact.getImpact Definition.Ecs
                >> Unit.impactToFloat
            )
        >> Result.withDefault 0


getFoodScorePer100g : Db -> Example FoodQuery.Query -> Float
getFoodScorePer100g db =
    .query
        >> Recipe.compute db
        >> Result.map
            (Tuple.second
                >> .perKg
                >> Impact.getImpact Definition.Ecs
                >> (\x -> Unit.impactToFloat x / 10)
            )
        >> Result.withDefault 0


getObjectScore : Session -> Scope -> Example Component.Query -> Float
getObjectScore { componentConfig, db } scope { query } =
    query
        |> ObjectSimulator.compute { config = componentConfig, db = db, scope = scope }
        |> Result.map
            (Component.sumLifeCycleImpacts
                >> Impact.getImpact Definition.Ecs
                >> Unit.impactToFloat
            )
        |> Result.withDefault 0


getTextileScore : Session -> Example TextileQuery.Query -> Float
getTextileScore { componentConfig, db } { query } =
    query
        |> Simulator.compute db componentConfig
        |> Result.map (.impacts >> Impact.getImpact Definition.Ecs >> Unit.impactToFloat)
        |> Result.withDefault 0


getTextileScorePer100g : Session -> Example TextileQuery.Query -> Float
getTextileScorePer100g { componentConfig, db } { query } =
    query
        |> Simulator.compute db componentConfig
        |> Result.map
            (.impacts
                >> Impact.per100grams query.mass
                >> Impact.getImpact Definition.Ecs
                >> Unit.impactToFloat
            )
        |> Result.withDefault 0


exploreView : Session -> Model -> List (Html Msg)
exploreView ({ db } as session) { scope, dataset, tableState, search } =
    let
        tableConfig =
            { toId = always "" -- Placeholder
            , toMsg = SetTableState
            , search = search
            , columns = []
            , customizations =
                { defaultCustomizations
                    | tableAttrs = [ class "table table-striped table-hover mb-0 view-list cursor-pointer" ]
                }
            }
    in
    case dataset of
        Dataset.Components scope_ maybeId ->
            componentsExplorer db scope_ tableConfig tableState maybeId

        Dataset.Countries maybeCode ->
            countriesExplorer db tableConfig tableState scope maybeCode

        Dataset.FoodExamples maybeId ->
            foodExamplesExplorer db tableConfig tableState maybeId

        Dataset.FoodIngredients maybeId ->
            foodIngredientsExplorer db tableConfig tableState maybeId

        Dataset.Impacts maybeTrigram ->
            impactsExplorer db.definitions tableConfig tableState scope maybeTrigram

        Dataset.ObjectExamples maybeId ->
            objectExamplesExplorer session tableConfig tableState Scope.Object maybeId

        Dataset.Processes scope_ maybeId ->
            processesExplorer session scope_ tableConfig tableState maybeId

        Dataset.TextileExamples maybeId ->
            textileExamplesExplorer session tableConfig tableState maybeId

        Dataset.TextileMaterials maybeId ->
            textileMaterialsExplorer db tableConfig tableState maybeId

        Dataset.TextileProducts maybeId ->
            textileProductsExplorer session tableConfig tableState maybeId

        Dataset.VeliExamples maybeId ->
            objectExamplesExplorer session tableConfig tableState Scope.Veli maybeId


searchInputView : Session -> Model -> Html Msg
searchInputView _ { search } =
    div [ class "d-flex justify-content-start align-items-center gap-2" ]
        [ label [ for "search-field", class "visually-hidden" ] [ text "Rechercher" ]
        , input
            [ type_ "search"
            , class "form-control mb-1"
            , id "search-field"
            , placeholder "Rechercher"
            , value search
            , onInput UpdateSearch
            ]
            []
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( Dataset.label model.dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "row d-flex align-item-end" ]
                [ div [ class "col-sm-8 mb-1" ] [ h1 [] [ text "Explorateur" ] ]
                , div [ class "col-sm-4 mt-2" ] [ scopesMenuView session model ]
                ]
            , div [ class "row d-flex align-items-end mt-1 mx-0 g-0" ]
                [ div [ class "col-12 col-xl-3 col-xxl-4 border-bottom" ]
                    [ searchInputView session model ]
                , div [ class "col-12 col-xl-9 col-xxl-8 pe-0 me-0" ]
                    [ datasetsMenuView model ]
                ]
            , div [ class "mt-3" ] <|
                exploreView session model
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { dataset } =
    if Dataset.isDetailed dataset then
        Browser.Events.onKeyDown (Key.escape CloseModal)

    else
        Sub.none
