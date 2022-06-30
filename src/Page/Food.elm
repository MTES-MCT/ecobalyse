module Page.Food exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Country as Country exposing (Country)
import Data.Food.Db as Db
import Data.Food.Product as Product
    exposing
        ( Amount
        , Process
        , ProcessName
        , Product
        , Step
        , WeightRatio
        , addIngredient
        , defaultCountry
        , filterIngredients
        , findProductByName
        , isIngredient
        , isProcessing
        , isTransport
        , isWaste
        , processNameToString
        , productNameToString
        , removeIngredient
        , stringToProductName
        , updateTransport
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
import Request.Food.Db as RequestDb
import Views.Container as Container
import Views.CountrySelect
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
    , ingredientsSelectChoice : String
    , countriesSelectChoice : Country.Code
    }


type Msg
    = IngredientSliderChanged ProcessName (Maybe Amount)
    | DbLoaded (WebData Db.Db)
    | Reset
    | ProductSelected String
    | SwitchImpact Impact.Trigram
    | IngredientSelected String
    | AddIngredient
    | DeleteIngredient ProcessName
    | CountrySelected Country.Code
    | NoOp


tunaPizza : String
tunaPizza =
    "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { selectedProduct = Nothing
      , productsSelectChoice = tunaPizza
      , impact = Impact.defaultTrigram
      , ingredientsSelectChoice = ""
      , countriesSelectChoice = defaultCountry
      }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ foodDb, db } as session) msg ({ selectedProduct } as model) =
    case ( msg, selectedProduct ) of
        ( IngredientSliderChanged name (Just newAmount), Just selected ) ->
            let
                { product, weightRatio } =
                    selected

                updatedProduct =
                    { product | plant = Product.updateAmount weightRatio name newAmount product.plant }
            in
            ( { model | selectedProduct = Just { selected | product = updatedProduct } }, session, Cmd.none )

        ( DbLoaded (RemoteData.Success loadedDb), _ ) ->
            let
                productResult =
                    findProductByName (stringToProductName tunaPizza) loadedDb.products
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
                    , { session | foodDb = loadedDb }
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
                    findProductByName (stringToProductName productSelected) foodDb.products
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

        ( IngredientSelected ingredientName, _ ) ->
            ( { model | ingredientsSelectChoice = ingredientName }
            , session
            , Cmd.none
            )

        ( AddIngredient, Just selected ) ->
            let
                productWithAddedIngredient =
                    selected.product
                        |> addIngredient selected.weightRatio foodDb.processes model.ingredientsSelectChoice

                productWithPefScore =
                    productWithAddedIngredient
                        |> Product.computePefImpact session.db.impacts
            in
            ( { model
                | selectedProduct = Just { selected | product = productWithPefScore }
              }
            , session
            , Cmd.none
            )

        ( DeleteIngredient processName, Just selected ) ->
            let
                productWithoutIngredient =
                    selected.product
                        |> removeIngredient selected.weightRatio processName

                productWithPefScore =
                    productWithoutIngredient
                        |> Product.computePefImpact session.db.impacts
            in
            ( { model
                | selectedProduct = Just { selected | product = productWithPefScore }
              }
            , session
            , Cmd.none
            )

        ( CountrySelected countryCode, Just selected ) ->
            let
                productWithUpdatedTransport =
                    selected.product
                        |> updateTransport selected.original.plant.transport foodDb.processes countryCode db.countries

                productWithPefScore =
                    productWithUpdatedTransport
                        |> Product.computePefImpact session.db.impacts
            in
            ( { model
                | selectedProduct = Just { selected | product = productWithPefScore }
                , countriesSelectChoice = countryCode
              }
            , session
            , Cmd.none
            )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view ({ foodDb, db } as session) { selectedProduct, productsSelectChoice, impact, ingredientsSelectChoice, countriesSelectChoice } =
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
                        (foodDb.products
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
                    , viewIngredients totalImpact impact product.plant
                    , div [ class "row py-3 gap-2 gap-sm-0" ]
                        [ div [ class "col-sm-10" ]
                            [ foodDb.products
                                |> filterIngredients
                                |> ingredientSelector IngredientSelected
                            ]
                        , div [ class "col-sm-2" ]
                            [ button
                                [ class "btn btn-primary w-100"
                                , onClick AddIngredient
                                , disabled (ingredientsSelectChoice == "")
                                ]
                                [ text "Ajouter un ingrédient" ]
                            ]
                        ]
                    , viewProcessing totalImpact impact product.plant
                    , viewTransport totalImpact impact product.plant countriesSelectChoice db.countries
                    , viewWaste totalImpact impact product.plant
                    , div [ class "row py-3 gap-2 gap-sm-0" ]
                        [ div [ class "col-sm-10 fw-bold" ]
                            [ text "Poids total avant perte (cuisson, invendus...) : "
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


viewHeader : Html Msg -> Html Msg -> List (Html Msg) -> Html Msg
viewHeader header1 header2 children =
    if List.length children > 0 then
        div []
            (div [ class "row" ]
                [ div [ class "col-lg-6" ]
                    [ h3 [] [ header1 ]
                    ]
                , div [ class "col-lg-6 d-none d-sm-block" ]
                    [ h3 [] [ header2 ] ]
                ]
                :: children
            )

    else
        text ""


viewIngredients : Float -> Impact.Trigram -> Step -> Html Msg
viewIngredients totalImpact impact step =
    step.ingredients
        |> AnyDict.toList
        |> List.filter (\( processName, _ ) -> isIngredient processName)
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
        |> viewHeader (text "Quantité de l'ingrédient") (text "Pourcentage de l'impact total")


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
                , disabled = not (isIngredient bar.name)
                , min = 0
                , max = 100
                }
            ]
        , div [ class "col-sm-6" ]
            [ barView bar
            ]
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


barView : Bar -> Html Msg
barView bar =
    div [ class "ps-3 py-1 border-top border-top-sm-0 border-start-0 border-start-sm d-flex" ]
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
        , div [ class "px-2 my-1" ] [ PieChart.view bar.percent ]
        , button
            [ class "btn"
            , onClick <| DeleteIngredient bar.name
            ]
            [ i [ class "icon icon-trash" ] [] ]
        ]


floatToRoundedString : Int -> Float -> String
floatToRoundedString exponent float =
    float
        |> Decimal.fromFloat
        |> Decimal.roundTo exponent
        |> Decimal.toStringIn Decimal.Dec


ingredientSelector : (String -> Msg) -> List String -> Html Msg
ingredientSelector event processes =
    select
        [ class "form-select"
        , onInput event
        ]
        (option [] [ text "-- Sélectionner un ingrédient dans la liste --" ]
            :: (processes
                    |> List.map
                        (\processName ->
                            option [ value processName ] [ text processName ]
                        )
               )
        )


viewProcessing : Float -> Impact.Trigram -> Step -> Html Msg
viewProcessing totalImpact impact step =
    step.processing
        |> AnyDict.toList
        |> List.filter (\( processName, _ ) -> isProcessing processName)
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
        |> viewHeader (text "Processus") (text "Pourcentage de l'impact total")


viewTransport : Float -> Impact.Trigram -> Step -> Country.Code -> List Country -> Html Msg
viewTransport totalImpact impact step selectedCountry countries =
    let
        countrySelector =
            countries
                |> Views.CountrySelect.view
                    [ class "form-select w-25 d-inline" ]
                    selectedCountry
                    CountrySelected

        header =
            span []
                [ text "Transport - pays d'origine : "
                , countrySelector
                ]
    in
    div []
        [ step.transport
            |> AnyDict.toList
            |> List.filter (\( processName, _ ) -> isTransport processName)
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
            |> viewHeader header (text "Pourcentage de l'impact total")
        ]


viewWaste : Float -> Impact.Trigram -> Step -> Html Msg
viewWaste totalImpact impact step =
    step.waste
        |> AnyDict.toList
        |> List.filter (\( processName, _ ) -> isWaste processName)
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
        |> viewHeader (text "Déchets") (text "Pourcentage de l'impact total")
