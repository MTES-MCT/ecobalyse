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
import Views.Container as Container


type alias Model =
    { dataset : Db.Dataset }


type Msg
    = NoOp


init : Db.Dataset -> Session -> ( Model, Session, Cmd Msg )
init dataset session =
    ( { dataset = dataset }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


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
        |> nav [ class "nav nav-pills flex-column flex-sm-row" ]


explore : Db -> Db.Dataset -> Html Msg
explore db dataset =
    case dataset of
        Db.Countries maybeId ->
            div []
                [ ExploreCountries.view db.countries
                , maybeId
                    |> Maybe.map (ExploreCountries.details db)
                    |> Maybe.withDefault (text "")
                ]

        Db.Impacts maybeId ->
            div []
                [ ExploreImpacts.view db.impacts
                , maybeId
                    |> Maybe.map (ExploreImpacts.details db)
                    |> Maybe.withDefault (text "")
                ]

        Db.Materials maybeId ->
            div []
                [ ExploreMaterials.view db.materials
                , maybeId
                    |> Maybe.map (ExploreMaterials.details db)
                    |> Maybe.withDefault (text "")
                ]

        Db.Products maybeId ->
            div []
                [ ExploreProducts.view db.products
                , maybeId
                    |> Maybe.map (ExploreProducts.details db)
                    |> Maybe.withDefault (text "")
                ]


view : Session -> Model -> ( String, List (Html Msg) )
view session { dataset } =
    ( Db.datasetLabel dataset ++ " | Explorer "
    , [ Container.centered [ class "pb-5" ]
            [ div [ class "row" ]
                [ div [ class "col-sm-6" ]
                    [ h1 [ class "m-0 mb-1" ]
                        [ text "Explorer "
                        , small [ class "text-muted" ]
                            [ text <| "les " ++ String.toLower (Db.datasetLabel dataset) ]
                        ]
                    ]
                , div [ class "col-sm-6 d-sm-flex justify-content-end" ]
                    [ div [] [ menu dataset ]
                    ]
                ]
            , div [ class "py-3" ]
                [ explore session.db dataset
                ]
            ]
      ]
    )
