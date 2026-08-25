module Page.Explore exposing
    ( Model
    , Msg
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
import Csv.Encode as EncodeCsv exposing (Csv)
import Data.Component as Component exposing (Component)
import Data.Component.ProductCategory as ProductCategory exposing (ProductCategory)
import Data.Country as Country exposing (Country)
import Data.Country.Code as CountryCode
import Data.Dataset as Dataset exposing (Dataset)
import Data.Db exposing (Db)
import Data.Example as Example exposing (Example)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Generic.Simulator as GenericSimulator
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Key as Key
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as TextileQuery
import Data.Textile.Simulator as Simulator
import Data.Unit as Unit
import Data.Uuid exposing (Uuid)
import Dict
import File.Download as Download
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Explore.Components as Components
import Page.Explore.Countries as ExploreCountries
import Page.Explore.FoodExamples as FoodExamples
import Page.Explore.FoodIngredients as FoodIngredients
import Page.Explore.GenericExamples as GenericExamples
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.Processes as Processes
import Page.Explore.ProductCategories as ProductCategories
import Page.Explore.Table as Table
import Page.Explore.TextileExamples as TextileExamples
import Page.Explore.TextileMaterials as TextileMaterials
import Page.Explore.TextileProducts as TextileProducts
import Ports
import Route
import Table as SortableTable exposing (defaultCustomizations)
import Views.Alert as Alert
import Views.Container as Container
import Views.Modal as ModalView


type alias Model =
    { dataset : Dataset
    , facetValues : Table.Facets
    , scope : Scope
    , search : String
    , tableState : SortableTable.State
    }


type Msg
    = CloseModal
    | DownloadCsv String Csv
    | NoOp
    | OpenDetail String
    | ScopeChange Scope
    | SetTableState SortableTable.State
    | ToggleFacetValue String String Bool
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

                Dataset.GenericExamples _ _ ->
                    "Coût Environnemental"

                Dataset.Impacts _ ->
                    "Code"

                Dataset.Processes _ _ ->
                    "Nom"

                Dataset.ProductCategory _ _ ->
                    "Catégorie de produit"

                Dataset.TextileExamples _ ->
                    "Coût Environnemental"

                Dataset.TextileMaterials _ ->
                    "Identifiant"

                Dataset.TextileProducts _ ->
                    "Identifiant"
    in
    createPageUpdate session
        { dataset = dataset
        , facetValues = Dict.empty
        , scope = scope
        , search = ""
        , tableState = SortableTable.initialSort initialSort
        }


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        CloseModal ->
            createPageUpdate session { model | dataset = model.dataset |> Dataset.reset }

        DownloadCsv filename csv ->
            createPageUpdate session model
                |> App.withCmds [ Download.string filename "text/csv" (csv |> EncodeCsv.toString) ]

        NoOp ->
            createPageUpdate session model

        OpenDetail id ->
            createPageUpdate session { model | dataset = model.dataset |> Dataset.setIdFromString id }

        ScopeChange scope ->
            { model | facetValues = Dict.empty, scope = scope }
                |> createPageUpdate session
                |> App.withCmds
                    [ (case model.dataset of
                        -- Try selecting the most appropriate tab when switching scope.
                        Dataset.Countries _ ->
                            Dataset.Countries Nothing

                        Dataset.Impacts _ ->
                            Dataset.Impacts Nothing

                        Dataset.Processes _ _ ->
                            Dataset.Processes scope Nothing

                        Dataset.ProductCategory _ _ ->
                            case Scope.toGenericScope scope of
                                Just newGenericScope ->
                                    Dataset.ProductCategory newGenericScope Nothing

                                Nothing ->
                                    Dataset.defaultDatasetFor scope

                        _ ->
                            Dataset.defaultDatasetFor scope
                      )
                        |> Route.Explore scope
                        |> Route.toString
                        |> Nav.pushUrl session.navKey
                    ]

        SetTableState tableState ->
            createPageUpdate session { model | tableState = tableState }

        ToggleFacetValue key value checked ->
            { model | facetValues = model.facetValues |> Table.updateFacets key value checked }
                |> createPageUpdate session
                |> App.withCmds
                    [ if checked then
                        -- scroll the facet card DOM element to top when it is checked
                        """[data-scroll-id="{key}"] label:first-child"""
                            |> String.replace "{key}" key
                            |> Ports.scrollIntoView

                      else
                        Cmd.none
                    ]

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
          , ( Scope.Generic Scope.Food2, enabledSections.food2 )
          , ( Scope.Generic Scope.Object, enabledSections.objects )
          , ( Scope.Textile, True )
          , ( Scope.Generic Scope.Veli, enabledSections.veli )
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
    -> Maybe CountryCode.Code
    -> List (Html Msg)
countriesExplorer { distances, countries } tableConfig tableState scope maybeCode =
    [ countries
        |> List.filter (.scopes >> List.member scope)
        |> Table.viewList (.code >> CountryCode.toString >> OpenDetail)
            tableConfig
            tableState
            scope
            (ExploreCountries.table distances countries)
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
        |> Table.viewList (.trigram >> Definition.toString >> OpenDetail)
            tableConfig
            tableState
            scope
            ExploreImpacts.table
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
        |> Table.viewList (Tuple.first >> .id >> Data.Uuid.toString >> OpenDetail)
            tableConfig
            tableState
            Scope.Food
            (FoodExamples.table max)
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
        |> Table.viewList (.id >> Ingredient.idToString >> OpenDetail)
            tableConfig
            tableState
            Scope.Food
            FoodIngredients.table
    , case maybeId of
        Just id ->
            detailsModal
                (case Ingredient.findById id food.ingredients of
                    Err error ->
                        alert error

                    Ok ingredient ->
                        foodIngredientDetails ingredient
                )

        Nothing ->
            text ""
    ]


foodIngredientDetails : Ingredient -> Html msg
foodIngredientDetails =
    Table.viewDetails Scope.Food FoodIngredients.table


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
        |> Table.viewList (.id >> Process.idToString >> OpenDetail)
            tableConfig
            tableState
            scope
            (Processes.table session)
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
    Session
    -> Scope
    -> Table.Config Component Msg
    -> SortableTable.State
    -> Maybe Component.Id
    -> List (Html Msg)
componentsExplorer session scope tableConfig tableState maybeId =
    let
        scopedComponents =
            session.db.components |> List.filter (.scope >> (==) scope)
    in
    [ scopedComponents
        |> List.sortBy .name
        |> Table.viewList
            -- @FIXME: the need for a Maybe.withDefault here looks bad
            (.id >> Maybe.map Component.idToString >> Maybe.withDefault "" >> OpenDetail)
            tableConfig
            tableState
            scope
            (Components.table session)
    , case maybeId of
        Just id ->
            detailsModal
                (case Component.findById id scopedComponents of
                    Err error ->
                        alert error

                    Ok component ->
                        component
                            |> Table.viewDetails scope (Components.table session)
                )

        Nothing ->
            text ""
    ]


genericExamplesExplorer :
    Session
    -> Table.Config ( Example Component.Query, { score : Float, per100g : Float } ) Msg
    -> SortableTable.State
    -> Scope.GenericScope
    -> Maybe Uuid
    -> List (Html Msg)
genericExamplesExplorer session tableConfig tableState genericScope maybeId =
    let
        scope =
            Scope.Generic genericScope

        scoredExamples =
            session.db.generic.examples
                |> List.filter (\example -> example.scope == scope)
                |> List.map
                    (\example ->
                        ( example
                        , { score = getGenericScore session scope example
                          , per100g = getGenericScorePer100g session scope example
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
        |> List.filter (Tuple.first >> .query >> (/=) Component.emptyQuery)
        |> List.sortBy (Tuple.first >> .name)
        |> Table.viewList (Tuple.first >> .id >> Data.Uuid.toString >> OpenDetail)
            tableConfig
            tableState
            scope
            (GenericExamples.table max genericScope)
    , case maybeId of
        Just id ->
            detailsModal
                (case Example.findByUuid id session.db.generic.examples of
                    Err error ->
                        alert error

                    Ok example ->
                        ( example
                        , { score = getGenericScore session scope example
                          , per100g = getGenericScorePer100g session scope example
                          }
                        )
                            |> Table.viewDetails scope (GenericExamples.table max genericScope)
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
        |> Table.viewList (Tuple.first >> .id >> Data.Uuid.toString >> OpenDetail)
            tableConfig
            tableState
            Scope.Textile
            (TextileExamples.table session max)
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
        |> Table.viewList (.id >> Product.idToString >> OpenDetail)
            tableConfig
            tableState
            Scope.Textile
            (TextileProducts.table session)
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


productCategoriesExplorer :
    Session
    -> Scope.GenericScope
    -> Table.Config ProductCategory Msg
    -> SortableTable.State
    -> Maybe ProductCategory.Id
    -> List (Html Msg)
productCategoriesExplorer session genericScope tableConfig tableState maybeId =
    let
        scope =
            Scope.Generic genericScope
    in
    [ session.db.products
        |> ProductCategory.findByScope genericScope
        |> Table.viewList (.id >> ProductCategory.idToString >> OpenDetail)
            tableConfig
            tableState
            scope
            (ProductCategories.table session genericScope)
    , case maybeId of
        Just id ->
            detailsModal
                (case ProductCategory.findById id session.db.products of
                    Err error ->
                        alert error

                    Ok product ->
                        Table.viewDetails scope (ProductCategories.table session genericScope) product
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
        |> Table.viewList (.id >> Material.idToString >> OpenDetail) tableConfig tableState Scope.Textile (TextileMaterials.table db)
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


getGenericScore : Session -> Scope -> Example Component.Query -> Float
getGenericScore { componentConfig, db } scope { query } =
    query
        |> GenericSimulator.compute { config = componentConfig, db = db, scope = scope }
        |> Result.map
            (Component.sumLifeCycleImpacts
                >> Impact.getImpact Definition.Ecs
                >> Unit.impactToFloat
            )
        |> Result.withDefault 0


getGenericScorePer100g : Session -> Scope -> Example Component.Query -> Float
getGenericScorePer100g { componentConfig, db } scope { query } =
    query
        |> GenericSimulator.compute { config = componentConfig, db = db, scope = scope }
        |> Result.map
            (\lifeCycle ->
                lifeCycle
                    |> Component.sumLifeCycleImpacts
                    |> Impact.per100grams lifeCycle.productMass
                    |> Impact.getImpact Definition.Ecs
                    |> Unit.impactToFloat
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
exploreView ({ db } as session) { facetValues, scope, dataset, tableState, search } =
    let
        tableConfig =
            { toId = always "" -- Placeholder
            , toMsg = SetTableState
            , onFacetToggle = ToggleFacetValue
            , search = search
            , selectedFacets = facetValues
            , columns = []
            , customizations =
                { defaultCustomizations
                    | tableAttrs = [ class "table table-striped table-hover mb-0 view-list cursor-pointer" ]
                }
            , downloadCsv = DownloadCsv
            }
    in
    case dataset of
        Dataset.Components scope_ maybeId ->
            componentsExplorer session scope_ tableConfig tableState maybeId

        Dataset.Countries maybeCode ->
            countriesExplorer db tableConfig tableState scope maybeCode

        Dataset.FoodExamples maybeId ->
            foodExamplesExplorer db tableConfig tableState maybeId

        Dataset.FoodIngredients maybeId ->
            foodIngredientsExplorer db tableConfig tableState maybeId

        Dataset.GenericExamples genericScope maybeId ->
            genericExamplesExplorer session tableConfig tableState genericScope maybeId

        Dataset.Impacts maybeTrigram ->
            impactsExplorer db.definitions tableConfig tableState scope maybeTrigram

        Dataset.Processes scope_ maybeId ->
            processesExplorer session scope_ tableConfig tableState maybeId

        Dataset.ProductCategory genericScope maybeId ->
            productCategoriesExplorer session genericScope tableConfig tableState maybeId

        Dataset.TextileExamples maybeId ->
            textileExamplesExplorer session tableConfig tableState maybeId

        Dataset.TextileMaterials maybeId ->
            textileMaterialsExplorer db tableConfig tableState maybeId

        Dataset.TextileProducts maybeId ->
            textileProductsExplorer session tableConfig tableState maybeId


searchInputView : Model -> Html Msg
searchInputView { search } =
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
                    [ searchInputView model ]
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
