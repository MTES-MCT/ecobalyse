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
import Data.Food.Ingredient as Ingredient
import Data.Impact as Impact
import Data.Key as Key
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Countries as ExploreCountries
import Page.Explore.FoodIngredients as FoodIngredients
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.Table as Table
import Page.Explore.TextileMaterials as TextileMaterials
import Page.Explore.TextileProducts as TextileProducts
import Ports
import RemoteData exposing (WebData)
import Request.Food.BuilderDb as FoodRequestDb
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Modal as ModalView


type alias Model =
    { dataset : Dataset
    , scope : Scope
    }


type Msg
    = NoOp
    | CloseModal
    | FoodDbLoaded (WebData BuilderDb.Db)


init : Scope -> Dataset -> Session -> ( Model, Session, Cmd Msg )
init scope dataset session =
    ( { dataset = dataset, scope = scope }
    , session
    , Cmd.batch
        [ if BuilderDb.isEmpty session.builderDb then
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


datasetsMenuView : Model -> Html Msg
datasetsMenuView { scope, dataset } =
    Dataset.datasets scope
        |> List.map
            (\ds ->
                a
                    [ class "nav-link"
                    , classList [ ( "active", Dataset.same ds dataset ) ]
                    , Route.href (Route.Explore scope ds)
                    ]
                    [ text (Dataset.label ds) ]
            )
        |> nav
            [ class "nav nav-pills d-flex justify-content-start align-items-center gap-0 gap-sm-2"
            ]


scopesMenuView : Model -> Html Msg
scopesMenuView model =
    [ Scope.Food, Scope.Textile ]
        |> List.map
            (\scope ->
                a
                    [ class "nav-link"
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
            [ class "nav nav-pills d-flex justify-content-end align-items-center gap-0 gap-sm-2"
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


countriesExplorer : Scope -> Maybe Country.Code -> List Country -> List (Html Msg)
countriesExplorer scope maybeCode countries =
    [ countries
        |> List.filter (.scopes >> List.member scope)
        |> Table.viewList scope ExploreCountries.table
    , case maybeCode of
        Just code ->
            detailsModal
                (case Country.findByCode code countries of
                    Ok country ->
                        country
                            |> Table.viewDetails scope ExploreCountries.table

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


impactsExplorer : Scope -> Maybe Impact.Trigram -> List Impact.Definition -> List (Html Msg)
impactsExplorer scope maybeTrigram definitions =
    [ definitions
        |> List.filter (.scopes >> List.member scope)
        |> List.sortBy (.trigram >> Impact.toString)
        |> Table.viewList scope ExploreImpacts.table
    , case maybeTrigram of
        Just trigram ->
            detailsModal
                (case Impact.getDefinition trigram definitions of
                    Ok definition ->
                        definition
                            |> Table.viewDetails scope ExploreImpacts.table

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


foodIngredientsExplorer : Maybe Ingredient.Id -> BuilderDb.Db -> List (Html Msg)
foodIngredientsExplorer maybeId db =
    [ db.ingredients
        |> List.sortBy .name
        |> Table.viewList Scope.Food (FoodIngredients.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Ingredient.findByID id db.ingredients of
                    Ok ingredient ->
                        ingredient
                            |> Table.viewDetails Scope.Food (FoodIngredients.table db)

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


textileProductsExplorer : Maybe Product.Id -> Db -> List (Html Msg)
textileProductsExplorer maybeId db =
    [ db.products
        |> Table.viewList Scope.Textile (TextileProducts.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Product.findById id db.products of
                    Ok product ->
                        product
                            |> Table.viewDetails Scope.Textile (TextileProducts.table db)

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


textileMaterialsExplorer : Maybe Material.Id -> Db -> List (Html Msg)
textileMaterialsExplorer maybeId db =
    [ db.materials
        |> Table.viewList Scope.Textile (TextileMaterials.table db)
    , case maybeId of
        Just id ->
            detailsModal
                (case Material.findById id db.materials of
                    Ok material ->
                        material
                            |> Table.viewDetails Scope.Textile (TextileMaterials.table db)

                    Err error ->
                        alert error
                )

        Nothing ->
            text ""
    ]


explore : Session -> Model -> List (Html Msg)
explore { db, builderDb } { scope, dataset } =
    case dataset of
        Dataset.Countries maybeCode ->
            db.countries |> countriesExplorer scope maybeCode

        Dataset.Impacts maybeTrigram ->
            db.impacts |> impactsExplorer scope maybeTrigram

        Dataset.FoodIngredients maybeId ->
            builderDb |> foodIngredientsExplorer maybeId

        Dataset.TextileMaterials maybeId ->
            db |> textileMaterialsExplorer maybeId

        Dataset.TextileProducts maybeId ->
            db |> textileProductsExplorer maybeId


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( Dataset.label model.dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "row d-flex align-items-center gap-2 gap-lg-0" ]
                [ h1 [ class "col-lg-4 m-0" ] [ text "Explorer " ]
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
