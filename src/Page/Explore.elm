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
import Data.Impact as Impact
import Data.Key as Key
import Data.Session exposing (Session)
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Countries as ExploreCountries
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.Table as Table
import Page.Explore.TextileMaterials as TextileMaterials
import Page.Explore.TextileProducts as TextileProducts
import Ports
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Modal as ModalView


type alias Model =
    { dataset : Dataset }


type Msg
    = NoOp
    | CloseModal


init : Dataset -> Session -> ( Model, Session, Cmd Msg )
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
            , (case model.dataset of
                Dataset.Countries _ ->
                    Dataset.Countries Nothing

                Dataset.Impacts _ ->
                    Dataset.Impacts Nothing

                Dataset.TextileProducts _ ->
                    Dataset.TextileProducts Nothing

                Dataset.TextileMaterials _ ->
                    Dataset.TextileMaterials Nothing
              )
                |> Route.Explore
                |> Route.toString
                |> Nav.pushUrl session.navKey
            )


isActive : Dataset -> Dataset -> Bool
isActive a b =
    case ( a, b ) of
        ( Dataset.Countries _, Dataset.Countries _ ) ->
            True

        ( Dataset.Impacts _, Dataset.Impacts _ ) ->
            True

        ( Dataset.TextileProducts _, Dataset.TextileProducts _ ) ->
            True

        ( Dataset.TextileMaterials _, Dataset.TextileMaterials _ ) ->
            True

        _ ->
            False


modalOpened : Dataset -> Bool
modalOpened dataset =
    case dataset of
        Dataset.Countries (Just _) ->
            True

        Dataset.Impacts (Just _) ->
            True

        Dataset.TextileProducts (Just _) ->
            True

        Dataset.TextileMaterials (Just _) ->
            True

        _ ->
            False


menu : Dataset -> Html Msg
menu dataset =
    Dataset.datasets
        |> List.map
            (\ds ->
                a
                    [ class "nav-link"
                    , classList [ ( "active", isActive ds dataset ) ]
                    , Route.href (Route.Explore ds)
                    ]
                    [ text (Dataset.label ds) ]
            )
        |> nav
            [ class "nav nav-pills d-flex justify-content-between"
            , class "justify-content-sm-end align-items-center gap-0 gap-sm-2"
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
        |> Table.viewList (TextileMaterials.table db)
    , case maybeId of
        Just id ->
            case Material.findById id db.materials of
                Ok material ->
                    material
                        |> Table.viewDetails (TextileMaterials.table db)
                        |> detailsModal

                Err error ->
                    alert error

        Nothing ->
            text ""
    ]


productsExplorer : Maybe Product.Id -> Db -> List (Html Msg)
productsExplorer maybeId db =
    [ db.products
        |> Table.viewList (TextileProducts.table db)
    , case maybeId of
        Just id ->
            case Product.findById id db.products of
                Ok product ->
                    product
                        |> Table.viewDetails (TextileProducts.table db)
                        |> detailsModal

                Err error ->
                    alert error

        Nothing ->
            text ""
    ]


explore : Db -> Dataset -> List (Html Msg)
explore db dataset =
    case dataset of
        Dataset.Countries maybeCode ->
            db.countries |> countriesExplorer maybeCode

        Dataset.Impacts maybeTrigram ->
            db.impacts |> impactsExplorer maybeTrigram

        Dataset.TextileMaterials maybeId ->
            db |> materialsExplorer maybeId

        Dataset.TextileProducts maybeId ->
            db |> productsExplorer maybeId


view : Session -> Model -> ( String, List (Html Msg) )
view session { dataset } =
    ( Dataset.label dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "d-block d-sm-flex justify-content-between align-items-center" ]
                [ h1 []
                    [ text "Explorer "
                    , small [ class "text-muted" ]
                        [ text <| "les " ++ String.toLower (Dataset.label dataset) ]
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
