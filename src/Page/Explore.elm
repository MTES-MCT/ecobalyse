module Page.Explore exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Browser.Navigation as Nav
import Data.Country as Country exposing (Country)
import Data.Dataset as Dataset exposing (Dataset)
import Data.Food.Builder.Db as BuilderDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Impact as Impact exposing (Definition)
import Data.Key as Key
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process
import Data.Textile.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Countries as ExploreCountries
import Page.Explore.FoodIngredients as FoodIngredients
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.Table as Table
import Page.Explore.TextileMaterials as TextileMaterials
import Page.Explore.TextileProcesses as TextileProcesses
import Page.Explore.TextileProducts as TextileProducts
import Ports
import RemoteData exposing (WebData)
import Request.Food.BuilderDb as FoodRequestDb
import Route
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
    = NoOp
    | CloseModal
    | FoodDbLoaded (WebData BuilderDb.Db)
    | SetTableState SortableTable.State


init : Scope -> Dataset -> Session -> ( Model, Session, Cmd Msg )
init scope dataset session =
    let
        initialSort =
            case dataset of
                Dataset.Countries _ ->
                    "Nom"

                Dataset.Impacts _ ->
                    "Code"

                Dataset.FoodIngredients _ ->
                    "Identifiant"

                Dataset.TextileProducts _ ->
                    "Identifiant"

                Dataset.TextileMaterials _ ->
                    "Identifiant"

                Dataset.TextileProcesses _ ->
                    "Nom"
    in
    ( { dataset = dataset, scope = scope, tableState = SortableTable.initialSort initialSort }
    , session
    , Cmd.batch
        [ if scope == Scope.Food && BuilderDb.isEmpty session.builderDb then
            FoodRequestDb.loadDb session FoodDbLoaded

          else
            Cmd.none
        , Ports.scrollTo { x = 0, y = 0 }
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )

        CloseModal ->
            ( model
            , session
            , model.dataset
                |> Dataset.reset
                |> Route.Explore model.scope
                |> Route.toString
                |> Nav.pushUrl session.navKey
            )

        FoodDbLoaded dbState ->
            ( model
            , case dbState of
                RemoteData.Success builderDb ->
                    { session | builderDb = builderDb }

                _ ->
                    session
            , Cmd.none
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
            [ class "Tabs nav nav-tabs d-flex justify-content-start align-items-center gap-0 gap-sm-2"
            ]


scopesMenuView : Model -> Html Msg
scopesMenuView model =
    [ Scope.Food, Scope.Textile ]
        |> List.map
            (\scope ->
                a
                    [ class "TabsTab nav-link"
                    , classList [ ( "active", model.scope == scope ) ]
                    , Route.href
                        (case model.dataset of
                            Dataset.Countries _ ->
                                Route.Explore scope (Dataset.Countries Nothing)

                            _ ->
                                Route.Explore scope (Dataset.Impacts Nothing)
                        )
                    ]
                    [ text (Scope.toLabel scope) ]
            )
        |> nav
            [ class "Tabs nav nav-tabs d-flex justify-content-end align-items-center gap-0 gap-sm-2"
            ]


detailsModal : Html Msg -> Html Msg
detailsModal content =
    ModalView.view
        { size = ModalView.Large
        , close = CloseModal
        , noOp = NoOp
        , title = "Détail de l'enregistrement"
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


countriesExplorer : Table.Config Country Msg -> SortableTable.State -> Scope -> Maybe Country.Code -> List Country -> List (Html Msg)
countriesExplorer tableConfig tableState scope maybeCode countries =
    let
        config =
            { tableConfig | toId = .code >> Country.codeToString }
    in
    [ countries
        |> List.filter (.scopes >> List.member scope)
        |> Table.viewListWithOrdering config tableState scope ExploreCountries.table
    , case maybeCode of
        Just code ->
            detailsModal
                (case Country.findByCode code countries of
                    Ok country ->
                        country
                            |> Table.viewDetailsWithOrdering scope ExploreCountries.table

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


impactsExplorer : Table.Config Definition Msg -> SortableTable.State -> Scope -> Maybe Impact.Trigram -> List Impact.Definition -> List (Html Msg)
impactsExplorer tableConfig tableState scope maybeTrigram definitions =
    let
        config =
            { tableConfig | toId = .trigram >> Impact.toString }
    in
    [ definitions
        |> List.filter (.scopes >> List.member scope)
        |> List.sortBy (.trigram >> Impact.toString)
        |> Table.viewListWithOrdering config tableState scope ExploreImpacts.table
    , case maybeTrigram of
        Just trigram ->
            detailsModal
                (case Impact.getDefinition trigram definitions of
                    Ok definition ->
                        definition
                            |> Table.viewDetailsWithOrdering scope ExploreImpacts.table

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


foodIngredientsExplorer : Table.Config Ingredient Msg -> SortableTable.State -> Maybe Ingredient.Id -> BuilderDb.Db -> List (Html Msg)
foodIngredientsExplorer tableConfig tableState maybeId db =
    let
        config =
            { tableConfig | toId = .id >> Ingredient.idToString }
    in
    [ db.ingredients
        |> List.sortBy .name
        |> Table.viewListWithOrdering config tableState Scope.Food (FoodIngredients.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Ingredient.findByID id db.ingredients of
                    Ok ingredient ->
                        ingredient
                            |> Table.viewDetailsWithOrdering Scope.Food (FoodIngredients.table db)

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


textileProductsExplorer : Table.Config Product Msg -> SortableTable.State -> Maybe Product.Id -> Db -> List (Html Msg)
textileProductsExplorer tableConfig tableState maybeId db =
    let
        config =
            { tableConfig | toId = .id >> Product.idToString }
    in
    [ db.products
        |> Table.viewListWithOrdering config tableState Scope.Textile (TextileProducts.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Product.findById id db.products of
                    Ok product ->
                        product
                            |> Table.viewDetailsWithOrdering Scope.Textile (TextileProducts.table db)

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


textileMaterialsExplorer : Table.Config Material Msg -> SortableTable.State -> Maybe Material.Id -> Db -> List (Html Msg)
textileMaterialsExplorer tableConfig tableState maybeId db =
    let
        config =
            { tableConfig | toId = .id >> Material.idToString }
    in
    [ db.materials
        |> Table.viewListWithOrdering config tableState Scope.Textile (TextileMaterials.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Material.findById id db.materials of
                    Ok material ->
                        material
                            |> Table.viewDetailsWithOrdering Scope.Textile (TextileMaterials.table db)

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


textileProcessesExplorer : Table.Config Process.Process Msg -> SortableTable.State -> Maybe Process.Uuid -> Db -> List (Html Msg)
textileProcessesExplorer tableConfig tableState maybeId db =
    let
        config =
            { tableConfig | toId = .uuid >> Process.uuidToString }
    in
    [ db.processes
        |> Table.viewListWithOrdering config tableState Scope.Textile TextileProcesses.table
    , case maybeId of
        Just id ->
            detailsModal
                (case Process.findByUuid id db.processes of
                    Ok process ->
                        process
                            |> Table.viewDetailsWithOrdering Scope.Textile TextileProcesses.table

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


explore : Session -> Model -> List (Html Msg)
explore { db, builderDb } { scope, dataset, tableState } =
    let
        defaultCustomizations =
            SortableTable.defaultCustomizations

        tableConfig =
            { toId = always "" -- Placeholder
            , toMsg = SetTableState
            , columns = []
            , customizations =
                { defaultCustomizations
                    | tableAttrs = [ class "table table-striped table-hover table-responsive mb-0 view-list" ]
                }
            }
    in
    case dataset of
        Dataset.Countries maybeCode ->
            db.countries |> countriesExplorer tableConfig tableState scope maybeCode

        Dataset.Impacts maybeTrigram ->
            db.impacts |> impactsExplorer tableConfig tableState scope maybeTrigram

        Dataset.FoodIngredients maybeId ->
            builderDb |> foodIngredientsExplorer tableConfig tableState maybeId

        Dataset.TextileMaterials maybeId ->
            db |> textileMaterialsExplorer tableConfig tableState maybeId

        Dataset.TextileProducts maybeId ->
            db |> textileProductsExplorer tableConfig tableState maybeId

        Dataset.TextileProcesses maybeId ->
            db |> textileProcessesExplorer tableConfig tableState maybeId


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( Dataset.label model.dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "row d-flex align-items-center" ]
                [ h1 [ class "col-lg-4" ] [ text "Explorer" ]
                , div [ class "col-lg-5" ] [ datasetsMenuView model ]
                , div [ class "col-lg-3" ] [ scopesMenuView model ]
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
