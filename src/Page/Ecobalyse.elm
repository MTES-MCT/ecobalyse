module Page.Ecobalyse exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Ecobalyse.Db as Db
import Data.Ecobalyse.Process
    exposing
        ( Amount
        , Process
        , ProcessName
        , isUnit
        , processNameToString
        )
import Data.Ecobalyse.Product as Product
    exposing
        ( Product
        , Step
        , WeightRatio
        , productNameToString
        , stringToProductName
        )
import Data.Impact as Impact
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Decimal
import Dict.Any as AnyDict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Ecobalyse.Db as RequestDb
import Views.Container as Container
import Views.Format as Format
import Views.Impact exposing (impactSelector)
import Views.PieChart as PieChart
import Views.RangeSlider as RangeSlider


type alias SelectedProduct =
    { product : Product
    , original : Product
    , weightRatio : Maybe WeightRatio
    }


type alias Model =
    { selectedProduct : Maybe SelectedProduct
    , productsSelectChoice : String
    , impact : Impact.Trigram
    }


type Msg
    = IngredientSliderChanged ProcessName (Maybe Amount)
    | DbLoaded (WebData Db.Db)
    | Reset
    | ProductSelected String
    | SwitchImpact Impact.Trigram
    | NoOp


tunaPizza : String
tunaPizza =
    "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { selectedProduct = Nothing
      , productsSelectChoice = tunaPizza
      , impact = Impact.defaultTrigram
      }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ ecobalyseDb } as session) msg ({ selectedProduct } as model) =
    case ( msg, selectedProduct ) of
        ( NoOp, _ ) ->
            ( model, session, Cmd.none )

        ( IngredientSliderChanged name (Just newAmount), Just selected ) ->
            let
                { product, weightRatio } =
                    selected

                updatedProduct =
                    { product | plant = Product.updateAmount weightRatio name newAmount product.plant }
            in
            ( { model | selectedProduct = Just { selected | product = updatedProduct } }, session, Cmd.none )

        ( DbLoaded (RemoteData.Success db), _ ) ->
            let
                productResult =
                    Product.findByName (stringToProductName tunaPizza) db.products
            in
            case productResult of
                Ok product ->
                    let
                        productWithPefScore =
                            product
                                |> Product.computePefImpact session.db.impacts
                    in
                    ( { model
                        | selectedProduct =
                            Just
                                { product = productWithPefScore
                                , original = productWithPefScore
                                , weightRatio = Product.getWeightRatio product
                                }
                      }
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

        ( Reset, Just selected ) ->
            ( { model | selectedProduct = Just { selected | product = selected.original } }
            , session
            , Cmd.none
            )

        ( ProductSelected productSelected, _ ) ->
            let
                productResult =
                    Product.findByName (stringToProductName productSelected) ecobalyseDb.products
            in
            case productResult of
                Ok product ->
                    let
                        productWithPefScore =
                            product
                                |> Product.computePefImpact session.db.impacts
                    in
                    ( { model
                        | selectedProduct =
                            Just
                                { product = productWithPefScore
                                , original = productWithPefScore
                                , weightRatio = Product.getWeightRatio product
                                }
                        , productsSelectChoice = productSelected
                      }
                    , session
                    , Cmd.none
                    )

                Err error ->
                    ( model
                    , session |> Session.notifyError "Erreur lors du chargement du produit" error
                    , Cmd.none
                    )

        ( SwitchImpact impact, _ ) ->
            ( { model | impact = impact }, session, Cmd.none )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view ({ ecobalyseDb, db } as session) { selectedProduct, productsSelectChoice, impact } =
    ( "Simulateur de recettes"
    , [ Container.centered []
            (case selectedProduct of
                Just { product, original } ->
                    let
                        -- We want the impact "per kg", but the original weight isn't 1kg,
                        -- so we need to keep it in store to adapt the final total per kg
                        originalTotalWeight =
                            Product.getTotalWeight original.plant

                        totalImpact =
                            Product.getTotalImpact impact product.plant

                        totalWeight =
                            Product.getTotalWeight product.plant

                        impactPerKg =
                            totalImpact * originalTotalWeight / totalWeight
                    in
                    [ select
                        [ class "form-select"
                        , onInput ProductSelected
                        ]
                        (ecobalyseDb.products
                            |> AnyDict.keys
                            |> List.map
                                (\productName ->
                                    let
                                        name =
                                            productNameToString productName
                                    in
                                    option
                                        [ value name
                                        , selected (name == productsSelectChoice)
                                        ]
                                        [ text name ]
                                )
                        )
                    , div [ class "row align-items-center pt-3 pb-4" ]
                        [ div [ class "col-lg-6" ]
                            [ impactSelector
                                { impacts = session.db.impacts
                                , selectedImpact = impact
                                , switchImpact = SwitchImpact

                                -- We don't use the following two configs
                                , selectedFunctionalUnit = Unit.PerItem
                                , switchFunctionalUnit = always NoOp
                                , scope = Impact.Food
                                }
                            ]
                        , div [ class "col-lg-6" ]
                            [ h1 []
                                [ let
                                    definition =
                                        db.impacts
                                            |> Impact.getDefinition impact
                                            |> Result.withDefault Impact.invalid
                                  in
                                  impactPerKg
                                    |> Format.formatImpactFloat definition
                                ]
                            ]
                        ]
                    , div [ class "row" ]
                        [ div [ class "col-lg-6 d-none d-sm-block" ]
                            [ h3 [] [ text "Quantité de l'ingrédient" ]
                            ]
                        , div [ class "col-lg-6 d-none d-sm-block" ]
                            [ h3 [] [ text "Pourcentage de l'impact total" ] ]
                        ]
                    , viewIngredients totalImpact impact product.plant
                    , div [ class "row py-3 gap-2 gap-sm-0" ]
                        [ div [ class "col-sm-10 fw-bold" ]
                            [ text "Poids total avant cuisson : "
                            , totalWeight
                                |> floatToRoundedString -3
                                |> text
                            , text "kg"
                            ]
                        , div [ class "col-sm-2" ]
                            [ button
                                [ class "btn btn-primary w-100"
                                , onClick Reset
                                ]
                                [ text "Réinitialiser" ]
                            ]
                        ]
                    ]

                _ ->
                    [ text "Loading" ]
            )
      ]
    )


viewIngredients : Float -> Impact.Trigram -> Step -> Html Msg
viewIngredients totalImpact impact step =
    step
        |> AnyDict.toList
        |> List.map
            (\( name, process ) ->
                let
                    bar =
                        makeBar totalImpact impact name process
                in
                div [ class "card stacked-card" ]
                    [ div [ class "card-header" ] [ text <| processNameToString name ]
                    , viewIngredient bar
                    ]
            )
        |> div []


viewIngredient : Bar -> Html Msg
viewIngredient bar =
    let
        name =
            bar.name |> processNameToString
    in
    div [ class "row align-items-center" ]
        [ div [ class "col-sm-6 px-4 py-2 py-sm-0" ]
            [ span [ class "d-block d-sm-none fs-7 text-muted" ] [ text "Quantité de l'ingrédient :" ]
            , RangeSlider.ratio
                { id = "slider-" ++ name
                , update = IngredientSliderChanged bar.name
                , value = bar.amount
                , toString =
                    Unit.ratioToFloat
                        >> floatToRoundedString -3
                        >> (\mass -> mass ++ "kg")
                , disabled = isUnit bar.name
                , min = 0
                , max = 100
                }
            ]
        , div [ class "col-sm-6" ]
            [ barView bar ]
        ]


type alias Bar =
    { name : ProcessName
    , amount : Unit.Ratio
    , impact : Float
    , width : Float
    , percent : Float
    }


makeBar : Float -> Impact.Trigram -> ProcessName -> Process -> Bar
makeBar totalImpact trigram processName process =
    let
        impact =
            -- Product.getImpact trigram definitions impacts * Unit.ratioToFloat amount
            Impact.grabImpactFloat Unit.PerItem Product.unusedDuration trigram process * Unit.ratioToFloat process.amount

        percent =
            impact * toFloat 100 / totalImpact
    in
    { name = processName
    , amount = process.amount
    , impact = impact
    , width = clamp 0 100 percent
    , percent = percent
    }


barView : Bar -> Html msg
barView bar =
    div [ class "px-3 py-1 border-top border-top-sm-0 border-start-0 border-start-sm d-flex" ]
        [ div [ class "w-75 border my-2" ]
            [ div
                [ class "bg-primary"
                , style "height" "100%"
                , style "width" (String.fromFloat bar.width ++ "%")
                ]
                []
            ]
        , div [ class "text-end py-1 ps-2 text-truncate flex-fill" ]
            [ Format.percent bar.percent ]
        , div [ class "ps-2 my-1" ] [ PieChart.view bar.percent ]
        ]


floatToRoundedString : Int -> Float -> String
floatToRoundedString exponent float =
    float
        |> Decimal.fromFloat
        |> Decimal.roundTo exponent
        |> Decimal.toStringIn Decimal.Dec
