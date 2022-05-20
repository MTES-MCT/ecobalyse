module Page.Ecobalyse exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Chart.Attributes exposing (amount)
import Data.Ecobalyse.Db as Db
import Data.Ecobalyse.Process exposing (Amount, Process, ProcessName)
import Data.Ecobalyse.Product as Product exposing (Product, ProductName)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Ecobalyse.Db as RequestDb
import Views.BarChart exposing (Bar)
import Views.Container as Container
import Views.Format as Format
import Views.PieChart as PieChart
import Views.RangeSlider as RangeSlider


type alias Model =
    { maybeProduct : Maybe Product }


type Msg
    = NoOp Never
    | IngredientSliderChanged ProductName (Maybe Amount)
    | DbLoaded (WebData Db.Db)


tunaPizza : ProductName
tunaPizza =
    "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { maybeProduct = Nothing }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ maybeProduct } as model) =
    case ( msg, maybeProduct ) of
        ( IngredientSliderChanged name (Just newAmount), Just product ) ->
            let
                updatedProduct =
                    { product | plant = Product.updateAmount name newAmount product.plant }
            in
            ( { model | maybeProduct = Just updatedProduct }, session, Cmd.none )

        ( DbLoaded (RemoteData.Success db), _ ) ->
            let
                productResult =
                    Product.findByName tunaPizza db.products
            in
            case productResult of
                Ok product ->
                    ( { model | maybeProduct = Just product }
                    , { session | ecobalyseDb = db }
                    , Cmd.none
                    )

                Err error ->
                    ( model
                    , session |> Session.notifyError "Erreur lors du chargement du produit" error
                    , Cmd.none
                    )

        ( DbLoaded (RemoteData.Failure httpError), _ ) ->
            ( model
            , session |> Session.notifyHttpError httpError
            , Cmd.none
            )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulateur de recettes"
    , [ Container.centered []
            (case model.maybeProduct of
                Just product ->
                    let
                        totalImpact =
                            Product.getTotalImpact product.plant
                    in
                    [ h1 [ class "mb-3" ] [ text "pizza au thon" ]
                    , h2 [ class "h3" ] [ text "Ingrédients" ]
                    , ul []
                        (Product.getIngredients product.plant
                            |> Dict.map (viewIngredient totalImpact)
                            |> Dict.values
                        )
                    ]

                _ ->
                    [ text "Loading" ]
            )
      ]
    )


viewIngredient : Float -> ProcessName -> Process -> Html Msg
viewIngredient totalImpact name ({ amount } as ingredient) =
    li []
        [ text name
        , text " : "
        , div [ class "row" ]
            [ div [ class "col-lg-6" ]
                [ RangeSlider.ratio
                    { id = "slider-" ++ name
                    , update = IngredientSliderChanged name
                    , value = amount
                    , toString = Unit.ratioToFloat >> String.fromFloat
                    , disabled = False
                    , min = 0
                    , max = 100
                    }
                ]
            , div [ class "col-lg-6" ]
                [ ingredient
                    |> makeBar name totalImpact
                    |> barView
                ]
            ]
        ]


makeBar : ProcessName -> Float -> Process -> Bar msg
makeBar name totalImpact { impacts } =
    let
        percent =
            impacts.cch * toFloat 100 / totalImpact
    in
    { label =
        span [] [ text name ]
    , score = impacts.cch
    , width = clamp 0 100 percent
    , percent = percent
    }


barView : Bar msg -> Html msg
barView bar =
    div [ class "fs-7 row" ]
        [ div [ class "col-lg-8 py-1" ]
            [ div
                [ class "bg-primary"
                , style "height" "1rem"
                , style "line-height" "1rem"
                , style "width" (String.fromFloat bar.width ++ "%")
                ]
                []
            ]
        , div [ class "col-lg-2 d-none d-sm-block text-end py-1 ps-2 text-truncate" ]
            [ Format.percent bar.percent ]
        , div [ class "col-lg-1 ps-2" ] [ PieChart.view bar.percent ]
        ]
