module Page.Textile.Explore exposing
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
import Data.Impact as Impact
import Data.Key as Key
import Data.Session exposing (Session)
import Data.Textile.Db as Db exposing (Db)
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Textile.Explore.Countries as ExploreCountries
import Page.Textile.Explore.Impacts as ExploreImpacts
import Page.Textile.Explore.Materials as ExploreMaterials
import Page.Textile.Explore.Products as ExploreProducts
import Page.Textile.Explore.Table as Table
import Ports
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Modal as ModalView


type alias Model =
    { dataset : Db.Dataset }


type Msg
    = NoOp
    | CloseModal


init : Db.Dataset -> Session -> ( Model, Session, Cmd Msg )
init dataset session =
    ( { dataset = dataset }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )

        CloseModal ->
            ( model
            , session
            , Nav.pushUrl session.navKey
                (case model.dataset of
                    Db.Countries _ ->
                        Route.toString <| Route.TextileExplore (Db.Countries Nothing)

                    Db.Impacts _ ->
                        Route.toString <| Route.TextileExplore (Db.Impacts Nothing)

                    Db.Products _ ->
                        Route.toString <| Route.TextileExplore (Db.Products Nothing)

                    Db.Materials _ ->
                        Route.toString <| Route.TextileExplore (Db.Materials Nothing)
                )
            )


isActive : Db.Dataset -> Db.Dataset -> Bool
isActive a b =
    case ( a, b ) of
        ( Db.Countries _, Db.Countries _ ) ->
            True

        ( Db.Impacts _, Db.Impacts _ ) ->
            True

        ( Db.Products _, Db.Products _ ) ->
            True

        ( Db.Materials _, Db.Materials _ ) ->
            True

        _ ->
            False


modalOpened : Db.Dataset -> Bool
modalOpened dataset =
    case dataset of
        Db.Countries (Just _) ->
            True

        Db.Impacts (Just _) ->
            True

        Db.Products (Just _) ->
            True

        Db.Materials (Just _) ->
            True

        _ ->
            False


menu : Db.Dataset -> Html Msg
menu dataset =
    Db.datasets
        |> List.map
            (\ds ->
                a
                    [ class "nav-link"
                    , classList [ ( "active", isActive ds dataset ) ]
                    , Route.href (Route.TextileExplore ds)
                    ]
                    [ text (Db.datasetLabel ds) ]
            )
        |> nav [ class "nav nav-pills d-flex justify-content-between justify-content-sm-end align-items-center gap-0 gap-sm-2" ]


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
    Alert.simple
        { level = Alert.Danger
        , content = [ text error ]
        , title = Just "Erreur"
        , close = Nothing
        }


countriesExplorer : Maybe Country.Code -> List Country -> List (Html Msg)
countriesExplorer maybeCode countries =
    [ countries
        |> Table.viewList ExploreCountries.table
    , case maybeCode of
        Just code ->
            case Country.findByCode code countries of
                Ok country ->
                    country
                        |> Table.viewDetails ExploreCountries.table
                        |> detailsModal

                Err error ->
                    alert error

        Nothing ->
            text ""
    ]


impactsExplorer : Maybe Impact.Trigram -> List Impact.Definition -> List (Html Msg)
impactsExplorer maybeTrigram definitions =
    [ definitions
        |> List.sortBy (.trigram >> Impact.toString)
        |> Table.viewList ExploreImpacts.table
    , case maybeTrigram of
        Just trigram ->
            case Impact.getDefinition trigram definitions of
                Ok definition ->
                    definition
                        |> Table.viewDetails ExploreImpacts.table
                        |> detailsModal

                Err error ->
                    alert error

        Nothing ->
            text ""
    ]


materialsExplorer : Maybe Material.Id -> Db -> List (Html Msg)
materialsExplorer maybeId db =
    [ db.materials
        |> Table.viewList (ExploreMaterials.table db)
    , case maybeId of
        Just id ->
            case Material.findById id db.materials of
                Ok material ->
                    material
                        |> Table.viewDetails (ExploreMaterials.table db)
                        |> detailsModal

                Err error ->
                    alert error

        Nothing ->
            text ""
    ]


productsExplorer : Maybe Product.Id -> Db -> List (Html Msg)
productsExplorer maybeId db =
    [ db.products
        |> Table.viewList (ExploreProducts.table db)
    , case maybeId of
        Just id ->
            case Product.findById id db.products of
                Ok product ->
                    product
                        |> Table.viewDetails (ExploreProducts.table db)
                        |> detailsModal

                Err error ->
                    alert error

        Nothing ->
            text ""
    ]


explore : Db -> Db.Dataset -> List (Html Msg)
explore db dataset =
    case dataset of
        Db.Countries maybeCode ->
            db.countries |> countriesExplorer maybeCode

        Db.Impacts maybeTrigram ->
            db.impacts |> impactsExplorer maybeTrigram

        Db.Materials maybeId ->
            db |> materialsExplorer maybeId

        Db.Products maybeId ->
            db |> productsExplorer maybeId


view : Session -> Model -> ( String, List (Html Msg) )
view session { dataset } =
    ( Db.datasetLabel dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "d-block d-sm-flex justify-content-between align-items-center" ]
                [ h1 []
                    [ text "Explorer "
                    , small [ class "text-muted" ]
                        [ text <| "les " ++ String.toLower (Db.datasetLabel dataset) ]
                    ]
                , menu dataset
                ]
            , explore session.db dataset
                |> div [ class "mt-3" ]
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { dataset } =
    if modalOpened dataset then
        Browser.Events.onKeyDown (Key.escape CloseModal)

    else
        Sub.none
