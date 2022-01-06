module Page.Explore exposing (..)

import Data.Db as Db exposing (Db)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Countries as ExploreCountries
import Page.Explore.Impacts as ExploreImpacts
import Page.Explore.Materials as ExploreMaterials
import Page.Explore.Products as ExploreProducts
import Route
import Views.Alert as Alert
import Views.Container as Container


type alias Model =
    { dataset : Db.Dataset }


type Msg
    = NoOp


init : Maybe Db.Dataset -> Session -> ( Model, Session, Cmd Msg )
init dataset session =
    ( { dataset = dataset |> Maybe.withDefault Db.Countries }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


menu : Db.Dataset -> Html Msg
menu dataset =
    Db.datasets
        |> List.map
            (\ds ->
                a
                    [ class "nav-link"
                    , classList [ ( "active", ds == dataset ) ]
                    , Route.href (Route.Explore (Just ds))
                    ]
                    [ text (Db.datasetLabel ds) ]
            )
        |> nav [ class "nav nav-pills" ]


explore : Db -> Db.Dataset -> Html Msg
explore db dataset =
    case dataset of
        Db.Countries ->
            ExploreCountries.view db.countries

        Db.Impacts ->
            ExploreImpacts.view db.impacts

        Db.Products ->
            ExploreProducts.view db.products

        Db.Materials ->
            ExploreMaterials.view db.materials

        _ ->
            Alert.simple
                { level = Alert.Info
                , close = Nothing
                , title = Nothing
                , content = [ text "Cette vue n'est pas encore implémentée." ]
                }


view : Session -> Model -> ( String, List (Html Msg) )
view session { dataset } =
    ( Db.datasetLabel dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-5" ]
            [ div [ class "row" ]
                [ div [ class "col-sm-6" ]
                    [ h1 [ class "m-0" ]
                        [ text "Explorer "
                        , small [ class "text-muted" ]
                            [ text <| "les " ++ String.toLower (Db.datasetLabel dataset) ]
                        ]
                    ]
                , div [ class "col-sm-6 d-flex justify-content-end" ]
                    [ div [] [ menu dataset ]
                    ]
                ]
            , div [ class "py-3" ]
                [ explore session.db dataset
                ]
            ]
      ]
    )
