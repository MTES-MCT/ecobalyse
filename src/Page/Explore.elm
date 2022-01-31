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
import Data.Country as Country
import Data.Db as Db exposing (Db)
import Data.Impact as Impact
import Data.Key as Key
import Data.Material as Material
import Data.Product as Product
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Countries as ExploreCountries
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.Materials as ExploreMaterials
import Page.Explore.Products as ExploreProducts
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
                        Route.toString <| Route.Explore (Db.Countries Nothing)

                    Db.Impacts _ ->
                        Route.toString <| Route.Explore (Db.Impacts Nothing)

                    Db.Products _ ->
                        Route.toString <| Route.Explore (Db.Products Nothing)

                    Db.Materials _ ->
                        Route.toString <| Route.Explore (Db.Materials Nothing)
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
                    , Route.href (Route.Explore ds)
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


explore : Db -> Db.Dataset -> List (Html Msg)
explore db dataset =
    case dataset of
        Db.Countries maybeId ->
            [ ExploreCountries.view db.countries
            , case maybeId of
                Just code ->
                    case Country.findByCode code db.countries of
                        Ok country ->
                            country
                                |> ExploreCountries.details db
                                |> detailsModal

                        Err error ->
                            alert error

                Nothing ->
                    text ""
            ]

        Db.Impacts maybeId ->
            [ ExploreImpacts.view db.impacts
            , case maybeId of
                Just trigram ->
                    case Impact.getDefinition trigram db.impacts of
                        Ok definition ->
                            definition
                                |> ExploreImpacts.details db
                                |> detailsModal

                        Err error ->
                            alert error

                Nothing ->
                    text ""
            ]

        Db.Materials maybeId ->
            [ ExploreMaterials.view db.materials
            , case maybeId of
                Just uuid ->
                    case Material.findByUuid uuid db.materials of
                        Ok material ->
                            material
                                |> ExploreMaterials.details db
                                |> detailsModal

                        Err error ->
                            alert error

                Nothing ->
                    text ""
            ]

        Db.Products maybeId ->
            [ ExploreProducts.view db.products
            , case maybeId of
                Just id ->
                    case Product.findById id db.products of
                        Ok product ->
                            product
                                |> ExploreProducts.details db
                                |> detailsModal

                        Err error ->
                            alert error

                Nothing ->
                    text ""
            ]


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
