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
import Data.Object.Query as ObjectQuery
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
import Table as SortableTable
import Views.Alert as Alert
import Views.Container as Container
import Views.Modal as ModalView


type alias Model =
    { dataset : Dataset
    , scope : Scope
    , tableState : SortableTable.State
    }


type Msg
    = CloseModal
    | NoOp
    | OpenDetail Route
    | ScopeChange Scope
    | SetTableState SortableTable.State


init : Scope -> Dataset -> Session -> ( Model, Session, Cmd Msg )
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
    in
    ( { dataset = dataset
      , scope = scope
      , tableState = SortableTable.initialSort initialSort
      }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        CloseModal ->
            ( model
            , session
            , model.dataset
                |> Dataset.reset
                |> Route.Explore model.scope
                |> Route.toString
                |> Nav.pushUrl session.navKey
            )

        NoOp ->
            ( model, session, Cmd.none )

        OpenDetail route ->
            ( model
            , session
            , route
                |> Route.toString
                |> Nav.pushUrl session.navKey
            )

        ScopeChange scope ->
            ( { model | scope = scope }
            , session
            , (case model.dataset of
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
                            -- FIXME: meubles examples only
                            Dataset.ObjectExamples Nothing

                        Scope.Textile ->
                            Dataset.TextileExamples Nothing

                        Scope.Veli ->
                            -- FIXME: veli examples only
                            Dataset.ObjectExamples Nothing
              )
                |> Route.Explore scope
                |> Route.toString
                |> Nav.pushUrl session.navKey
            )

        SetTableState tableState ->
            ( { model | tableState = tableState }
            , session
            , Cmd.none
            )


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
    [ ( Scope.Food, enabledSections.food )
    , ( Scope.Object, enabledSections.objects )
    , ( Scope.Textile, True )
    ]
        |> List.filter Tuple.second
        |> List.map
            (\( scope, _ ) ->
                label []
                    [ input
                        [ class "form-check-input ms-1 ms-sm-3 me-1"
                        , type_ "radio"
                        , classList [ ( "active", model.scope == scope ) ]
                        , checked <| model.scope == scope
                        , onCheck (always (ScopeChange scope))
                        ]
                        []
                    , text (Scope.toLabel scope)
                    ]
            )
        |> (::) (strong [ class "d-block d-sm-inline" ] [ text "Secteur d'activité" ])
        |> nav []


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
            { level = Alert.Danger
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
            db.components
                |> Scope.anyOf [ scope ]
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
    Db
    -> Table.Config ( Example ObjectQuery.Query, { score : Float } ) Msg
    -> SortableTable.State
    -> Maybe Uuid
    -> List (Html Msg)
objectExamplesExplorer db tableConfig tableState maybeId =
    let
        scoredExamples =
            db.object.examples
                |> List.map (\example -> ( example, { score = getObjectScore db example } ))
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
        |> List.filter (Tuple.first >> .query >> (/=) ObjectQuery.default)
        |> List.sortBy (Tuple.first >> .name)
        |> Table.viewList OpenDetail tableConfig tableState Scope.Object (ObjectExamples.table max)
    , case maybeId of
        Just id ->
            detailsModal
                (case Example.findByUuid id db.object.examples of
                    Err error ->
                        alert error

                    Ok example ->
                        ( example, { score = getObjectScore db example } )
                            |> Table.viewDetails Scope.Object (ObjectExamples.table max)
                )

        Nothing ->
            text ""
    ]


textileExamplesExplorer :
    Db
    -> Table.Config ( Example TextileQuery.Query, { score : Float, per100g : Float } ) Msg
    -> SortableTable.State
    -> Maybe Uuid
    -> List (Html Msg)
textileExamplesExplorer db tableConfig tableState maybeId =
    let
        scoredExamples =
            db.textile.examples
                |> List.map
                    (\example ->
                        ( example
                        , { score = getTextileScore db example
                          , per100g = getTextileScorePer100g db example
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
        |> Table.viewList OpenDetail tableConfig tableState Scope.Textile (TextileExamples.table db max)
    , case maybeId of
        Just id ->
            detailsModal
                (case Example.findByUuid id db.textile.examples of
                    Err error ->
                        alert error

                    Ok example ->
                        Table.viewDetails Scope.Textile
                            (TextileExamples.table db max)
                            ( example
                            , { score = getTextileScore db example
                              , per100g = getTextileScorePer100g db example
                              }
                            )
                )

        Nothing ->
            text ""
    ]


textileProductsExplorer :
    Db
    -> Table.Config Product Msg
    -> SortableTable.State
    -> Maybe Product.Id
    -> List (Html Msg)
textileProductsExplorer db tableConfig tableState maybeId =
    [ db.textile.products
        |> Table.viewList OpenDetail tableConfig tableState Scope.Textile (TextileProducts.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Product.findById id db.textile.products of
                    Err error ->
                        alert error

                    Ok product ->
                        Table.viewDetails Scope.Textile (TextileProducts.table db) product
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


getObjectScore : Db -> Example ObjectQuery.Query -> Float
getObjectScore db =
    .query
        >> ObjectSimulator.compute db
        >> Result.map (Component.extractImpacts >> Impact.getImpact Definition.Ecs >> Unit.impactToFloat)
        >> Result.withDefault 0


getTextileScore : Db -> Example TextileQuery.Query -> Float
getTextileScore db =
    .query
        >> Simulator.compute db
        >> Result.map (.impacts >> Impact.getImpact Definition.Ecs >> Unit.impactToFloat)
        >> Result.withDefault 0


getTextileScorePer100g : Db -> Example TextileQuery.Query -> Float
getTextileScorePer100g db { query } =
    query
        |> Simulator.compute db
        |> Result.map
            (.impacts
                >> Impact.per100grams query.mass
                >> Impact.getImpact Definition.Ecs
                >> Unit.impactToFloat
            )
        |> Result.withDefault 0


explore : Session -> Model -> List (Html Msg)
explore ({ db } as session) { scope, dataset, tableState } =
    let
        defaultCustomizations =
            SortableTable.defaultCustomizations

        tableConfig =
            { toId = always "" -- Placeholder
            , toMsg = SetTableState
            , columns = []
            , customizations =
                { defaultCustomizations
                    | tableAttrs = [ class "table table-striped table-hover table-responsive mb-0 view-list cursor-pointer" ]
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
            objectExamplesExplorer db tableConfig tableState maybeId

        Dataset.Processes scope_ maybeId ->
            processesExplorer session scope_ tableConfig tableState maybeId

        Dataset.TextileExamples maybeId ->
            textileExamplesExplorer db tableConfig tableState maybeId

        Dataset.TextileMaterials maybeId ->
            textileMaterialsExplorer db tableConfig tableState maybeId

        Dataset.TextileProducts maybeId ->
            textileProductsExplorer db tableConfig tableState maybeId


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( Dataset.label model.dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-3" ]
            [ div []
                [ h1 [ class "mb-0" ] [ text "Explorateur" ]
                , div [ class "row d-flex align-items-stretch mt-1 mx-0 g-0" ]
                    [ div [ class "col-12 col-lg-5 d-flex align-items-center pb-2 pb-lg-0 mb-4 mb-lg-0 border-bottom ps-0 ms-0" ]
                        [ scopesMenuView session model ]
                    , div [ class "col-12 col-lg-7 pe-0 me-0" ]
                        [ datasetsMenuView model ]
                    ]
                ]
            , explore session model
                |> div [ class "mt-3" ]
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { dataset } =
    if Dataset.isDetailed dataset then
        Browser.Events.onKeyDown (Key.escape CloseModal)

    else
        Sub.none
