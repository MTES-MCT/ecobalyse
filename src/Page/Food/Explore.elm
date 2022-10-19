module Page.Food.Explore exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Country as Country exposing (Country)
import Data.Food.Amount as Amount
import Data.Food.Db as FoodDb
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Product, ProductName)
import Data.Impact as Impact
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Dict.Any as AnyDict
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Length
import Mass exposing (Mass)
import Ports
import Quantity
import RemoteData exposing (WebData)
import Request.Food.Db as RequestDb
import Route
import Views.Component.AmountInput as AmountInput
import Views.Component.DownArrow as DownArrow
import Views.Component.ProcessSelector as ProcessSelector
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.CountrySelect
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Spinner as Spinner
import Volume


type alias CurrentProductInfo =
    { product : Product
    , original : Product
    }


type alias Model =
    { currentProductInfo : Maybe CurrentProductInfo
    , selectedProduct : ProductName
    , impact : Impact.Trigram
    , selectedIngredientProcess : Maybe Process
    , newIngredientMass : Mass
    , selectedCountry : Country.Code
    }


type Msg
    = AddIngredient
    | CountrySelected Country.Code
    | DbLoaded (WebData FoodDb.Db)
    | DeleteItem Product.Item
    | IngredientProcessSelected (Maybe Process)
    | IngredientMassChanged Product.Item (Maybe Mass)
    | NewIngredientMassChanged (Maybe Mass)
    | NoOp
    | ProductSelected ProductName
    | Reset
    | SwitchImpact Impact.Trigram


tunaPizza : ProductName
tunaPizza =
    Product.nameFromString "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { currentProductInfo = Nothing
      , selectedProduct = tunaPizza
      , impact = Impact.defaultTrigram
      , selectedIngredientProcess = Nothing
      , newIngredientMass = Mass.grams 100
      , selectedCountry = Product.defaultCountry
      }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ foodDb, db } as session) msg ({ currentProductInfo, newIngredientMass } as model) =
    case ( msg, currentProductInfo ) of
        ( AddIngredient, Just selected ) ->
            case model.selectedIngredientProcess of
                Just selectedIngredientProcess ->
                    let
                        productWithAddedIngredient =
                            selected.product
                                |> Product.addIngredient selectedIngredientProcess newIngredientMass
                    in
                    ( { model
                        | currentProductInfo = Just { selected | product = productWithAddedIngredient }
                        , selectedIngredientProcess = Nothing
                      }
                    , session
                    , Cmd.none
                    )

                Nothing ->
                    ( model, session, Cmd.none )

        ( CountrySelected countryCode, Just selected ) ->
            let
                productWithUpdatedTransport =
                    selected.product
                        |> Product.updatePlantTransport selected.original foodDb.processes db.impacts countryCode db.transports
            in
            ( { model
                | currentProductInfo = Just { selected | product = productWithUpdatedTransport }
                , selectedCountry = countryCode
              }
            , session
            , Cmd.none
            )

        ( DeleteItem processName, Just selected ) ->
            let
                productWithoutItem =
                    selected.product
                        |> Product.removeIngredient processName
            in
            ( { model
                | currentProductInfo = Just { selected | product = productWithoutItem }
              }
            , session
            , Cmd.none
            )

        ( DbLoaded (RemoteData.Success loadedDb), _ ) ->
            case Product.findByName tunaPizza loadedDb.products of
                Ok product ->
                    ( { model
                        | currentProductInfo =
                            Just
                                { product = product
                                , original = product
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

        ( IngredientProcessSelected maybeProcess, _ ) ->
            ( { model | selectedIngredientProcess = maybeProcess }
            , session
            , Cmd.none
            )

        ( IngredientMassChanged item (Just newMass), Just ({ product } as selected) ) ->
            let
                updatedProduct =
                    Product.updateIngredientMass item newMass product
            in
            ( { model | currentProductInfo = Just { selected | product = updatedProduct } }, session, Cmd.none )

        ( NewIngredientMassChanged (Just newMass), _ ) ->
            ( { model | newIngredientMass = newMass }
            , session
            , Cmd.none
            )

        ( ProductSelected selectedProduct, _ ) ->
            case Product.findByName selectedProduct foodDb.products of
                Ok product ->
                    ( { model
                        | currentProductInfo =
                            Just
                                { product = product
                                , original = product
                                }
                        , selectedProduct = selectedProduct
                        , selectedCountry = Product.defaultCountry
                      }
                    , session
                    , Cmd.none
                    )

                Err error ->
                    ( model
                    , session |> Session.notifyError "Erreur lors du chargement du produit" error
                    , Cmd.none
                    )

        ( Reset, Just selected ) ->
            ( { model
                | currentProductInfo = Just { selected | product = selected.original }
                , selectedCountry = Product.defaultCountry
                , selectedIngredientProcess = Nothing
              }
            , session
            , Cmd.none
            )

        ( SwitchImpact impact, _ ) ->
            ( { model | impact = impact }, session, Cmd.none )

        _ ->
            ( model, session, Cmd.none )


viewSidebar : Session -> ItemViewDataConfig -> CurrentProductInfo -> Html Msg
viewSidebar session { definition, trigram, totalImpact } { original, product } =
    let
        originalWeight =
            Product.getWeightAtPlant original.plant

        amountRatio =
            Product.getAmountRatio originalWeight product

        -- The final weight is always 1kg when the recipe isn't modified...
        -- then apply the ratio for the modified recipe :
        --    modified recipe's final weight = original final weight * modified recipe amount ratio
        finalWeight =
            amountRatio

        impactPerKg =
            totalImpact / finalWeight

        totalImpactDisplay =
            if amountRatio /= 1 then
                [ h3 [ class "h6 m-0 mt-2" ]
                    [ text "Impact pour "
                    , strong []
                        [ finalWeight
                            |> Format.formatRichFloat 3 "kg"
                        ]
                    , text " de produit"
                    ]
                , div [ class "display-5 lh-1 text-center text-nowrap" ]
                    [ Format.formatImpactFloat definition 2 totalImpact ]
                ]

            else
                []
    in
    div
        [ class "d-flex flex-column gap-3 mb-3 sticky-md-top"
        , style "top" "7px"
        ]
        [ ImpactView.impactSelector
            { impacts = session.db.impacts
            , selectedImpact = trigram
            , switchImpact = SwitchImpact

            -- We don't use the following two configs
            , selectedFunctionalUnit = Unit.PerItem
            , switchFunctionalUnit = always NoOp
            , scope = Impact.Food
            }
        , SummaryComp.view
            { header = []
            , body =
                [ div [ class "d-flex flex-column m-auto gap-1 px-2" ]
                    (h2 [ class "h5 m-0" ] [ text "Impact par kg de produit" ]
                        :: div [ class "display-4 lh-1 text-center text-nowrap" ]
                            [ Format.formatImpactFloat definition 2 impactPerKg ]
                        :: totalImpactDisplay
                    )
                ]
            , footer = []
            }
        , viewStepsSummary trigram product
        , a [ class "btn btn-primary", Route.href Route.FoodBuilder ]
            [ text "Constructeur de recette" ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view ({ foodDb, db } as session) ({ selectedProduct, newIngredientMass, impact, selectedIngredientProcess, selectedCountry } as model) =
    ( "Simulateur de recettes"
    , [ case model.currentProductInfo of
            Just ({ original, product } as currentProductInfo) ->
                let
                    totalImpact =
                        Product.getTotalImpact impact product

                    definition =
                        db.impacts
                            |> Impact.getDefinition impact
                            |> Result.withDefault Impact.invalid

                    itemViewDataConfig =
                        { totalImpact = totalImpact
                        , trigram = impact
                        , definition = definition
                        }

                    originalWeight =
                        Product.getWeightAtPlant original.plant

                    finalWeight =
                        Product.getAmountRatio originalWeight product
                in
                Container.centered []
                    [ div [ class "row gap-3 gap-lg-0" ]
                        [ div [ class "col-lg-4 order-lg-2 d-flex flex-column gap-3" ]
                            [ currentProductInfo
                                |> viewSidebar session itemViewDataConfig
                            ]
                        , div [ class "col-lg-8 order-lg-1 d-flex flex-column" ]
                            [ viewProductSelector selectedProduct foodDb.products
                            , viewPlantIngredientsAndMaterials itemViewDataConfig product.plant
                            , ProcessSelector.view
                                { processes = foodDb.processes
                                , category = Process.Ingredient
                                , alreadyUsedProcesses =
                                    product.plant
                                        |> Product.filterItemByCategory Process.Ingredient
                                        |> List.map .process
                                , selectedProcess = selectedIngredientProcess
                                , onProcessSelected = IngredientProcessSelected
                                , amount = Amount.Mass newIngredientMass
                                , onAmountChanged =
                                    \maybeAmount ->
                                        maybeAmount
                                            |> Maybe.andThen
                                                (\amount ->
                                                    case amount of
                                                        Amount.Mass mass ->
                                                            Just mass

                                                        _ ->
                                                            Nothing
                                                )
                                            |> NewIngredientMassChanged
                                , onSubmit = AddIngredient
                                }
                            , viewPlantEnergy itemViewDataConfig product.plant
                            , viewPlantProcessing itemViewDataConfig product.plant
                            , viewPlantTransport itemViewDataConfig product.plant selectedCountry db.countries
                            , viewPlantWaste itemViewDataConfig product.plant
                            , button
                                [ class "btn btn-outline-primary w-100 mt-3"
                                , onClick Reset
                                ]
                                [ text "Réinitialiser" ]
                            , viewSteps itemViewDataConfig product
                            , DownArrow.standard
                            , div [ class "d-flex justify-content-center fs-7 mb-3" ]
                                [ span
                                    [ class "d-flex justify-content-center align-items-center border rounded-circle shadow-sm"
                                    , style "width" "70px"
                                    , style "height" "70px"
                                    ]
                                    [ finalWeight
                                        |> Format.formatRichFloat 3 "kg"
                                    ]
                                ]
                            ]
                        ]
                    ]

            _ ->
                Spinner.view
      ]
    )


viewProductSelector : ProductName -> Product.Products -> Html Msg
viewProductSelector selectedProduct =
    AnyDict.keys
        >> List.map
            (\productName ->
                let
                    name =
                        Product.nameToString productName
                in
                option
                    [ value name
                    , selected (productName == selectedProduct)
                    ]
                    [ text name ]
            )
        >> select
            [ class "form-select mb-3"
            , onInput (Product.nameFromString >> ProductSelected)
            ]


viewCategory : Html Msg -> List (Html Msg) -> Html Msg
viewCategory header1 children =
    if List.length children > 0 then
        section [ class "FoodStep mt-3" ]
            [ h3 [ class "h6" ] [ header1 ]

            -- Enclosing the children so the first stacked card has the
            -- :first-child css selector applied
            , div [ class "stacked-card" ] children
            ]

    else
        text ""


viewPlantProcess : { disabled : Bool } -> ItemViewData -> Html Msg
viewPlantProcess { disabled } ({ item, stepWeight } as itemViewData) =
    div [ class "card-body row align-items-center py-1" ]
        [ div [ class "col-sm-3" ]
            [ if disabled then
                item.amount
                    |> Amount.format stepWeight
                    |> text
                    |> List.singleton
                    |> span [ class "fs-7" ]

              else
                AmountInput.view
                    { amount = item.amount
                    , onAmountChanged =
                        \maybeAmount ->
                            maybeAmount
                                |> Maybe.andThen
                                    (\amount ->
                                        case amount of
                                            Amount.Mass mass ->
                                                Just mass

                                            _ ->
                                                Nothing
                                    )
                                |> IngredientMassChanged item

                    -- FIXME: This only deals with masses, in the future we
                    -- might want to use the ProcessSelector for other types
                    -- of processes with different units.
                    , fromUnit =
                        \amount ->
                            case amount of
                                Amount.Mass mass ->
                                    Mass.inGrams mass

                                _ ->
                                    Amount.toStandardFloat amount
                    , toUnit =
                        \float ->
                            case item.amount of
                                Amount.Mass _ ->
                                    Amount.Mass (Mass.grams float)

                                Amount.Volume _ ->
                                    Amount.Volume (Volume.liters float)

                                Amount.TonKilometer _ ->
                                    Amount.TonKilometer (Mass.metricTons float)

                                Amount.EnergyInKWh _ ->
                                    Amount.EnergyInKWh (Energy.kilowattHours float)

                                Amount.EnergyInMJ _ ->
                                    Amount.EnergyInMJ (Energy.megajoules float)

                                Amount.Length _ ->
                                    Amount.Length (Length.kilometers float)
                    }
            ]
        , div [ class "col-sm-9" ]
            [ itemView { disabled = disabled } itemViewData
            ]
        ]


type alias ItemViewData =
    { item : Product.Item
    , impact : Unit.Impact
    , width : Float
    , percent : Float
    , config : ItemViewDataConfig
    , stepWeight : Mass
    }


type alias ItemViewDataConfig =
    { totalImpact : Float
    , trigram : Impact.Trigram
    , definition : Impact.Definition
    }


makeItemViewData : ItemViewDataConfig -> Mass -> Product.Item -> ItemViewData
makeItemViewData ({ totalImpact, trigram } as config) stepWeight ({ amount, process } as item) =
    let
        impact =
            Impact.getImpact trigram process.impacts
                |> Quantity.multiplyBy (Amount.toStandardFloat amount)

        percent =
            Unit.impactToFloat impact * toFloat 100 / totalImpact
    in
    { item = item
    , impact = impact
    , width = clamp 0 100 percent
    , percent = percent
    , config = config
    , stepWeight = stepWeight
    }


toItemViewDataList : ItemViewDataConfig -> Mass -> List Product.Item -> List ItemViewData
toItemViewDataList itemViewDataConfig stepWeight items =
    items
        |> List.map (makeItemViewData itemViewDataConfig stepWeight)
        -- order by impacts…
        |> List.sortBy (.impact >> Unit.impactToFloat)
        -- … in descending order
        |> List.reverse


itemView : { disabled : Bool } -> ItemViewData -> Html Msg
itemView { disabled } { config, percent, impact, item, width } =
    div [ class "border-top border-top-sm-0 d-flex align-items-center gap-1" ]
        [ div [ class "w-50", style "max-width" "50%", style "min-width" "50%" ]
            [ div [ class "progress" ]
                [ div [ class "progress-bar", style "width" (String.fromFloat width ++ "%") ] []
                ]
            ]
        , div [ class "text-start py-1 ps-2 text-truncate flex-fill fs-7" ]
            [ impact
                |> Unit.impactToFloat
                |> Format.formatImpactFloat config.definition 2
            , text " ("
            , Format.percent percent
            , text ")"
            ]
        , if disabled then
            text ""

          else
            button
                [ class "btn p-0 text-primary"
                , Html.Attributes.disabled disabled
                , onClick <| DeleteItem item
                ]
                [ Icon.trash ]
        ]


viewPlantIngredientsAndMaterials : ItemViewDataConfig -> Product.Items -> Html Msg
viewPlantIngredientsAndMaterials itemViewDataConfig items =
    let
        stepWeight =
            Product.getWeightAtPlant items

        ingredients =
            items
                |> Product.filterItemByCategory Process.Ingredient

        materials =
            items
                |> Product.filterItemByCategory Process.Material
    in
    ingredients
        ++ materials
        -- FIXME : toItemViewDataList will order the items by impact, and we want that. But it's not ergonomic
        -- while we have range sliders (and changing the value makes the item jump around)
        -- So uncomment the following line and remove the next one when we finally remove the range sliders ;)
        -- |> toItemViewDataList itemViewDataConfig stepWeight
        |> List.map (makeItemViewData itemViewDataConfig stepWeight)
        --
        |> List.map
            (\({ item } as itemViewData) ->
                let
                    name =
                        Process.nameToString item.process.name
                in
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ div [ class "row" ]
                            [ div [ class "col-lg-8" ]
                                [ text name
                                ]
                            , div [ class "col-lg-4 text-truncate text-lg-end" ]
                                [ if item.comment /= "" then
                                    small
                                        [ class "text-muted"
                                        , style "cursor" "help"
                                        , title item.comment
                                        ]
                                        [ text item.comment ]

                                  else
                                    text ""
                                ]
                            ]
                        ]
                    , viewPlantProcess { disabled = False } itemViewData
                    ]
            )
        |> viewCategory (text "Ingrédients")


viewPlantEnergy : ItemViewDataConfig -> Product.Items -> Html Msg
viewPlantEnergy itemViewDataConfig items =
    let
        stepWeight =
            Product.getWeightAtPlant items
    in
    items
        |> Product.filterItemByCategory Process.Energy
        |> toItemViewDataList itemViewDataConfig stepWeight
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Process.nameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewCategory (text "Énergie")


viewPlantProcessing : ItemViewDataConfig -> Product.Items -> Html Msg
viewPlantProcessing itemViewDataConfig items =
    let
        stepWeight =
            Product.getWeightAtPlant items
    in
    items
        |> Product.filterItemByCategory Process.Processing
        |> toItemViewDataList itemViewDataConfig stepWeight
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Process.nameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewCategory (text "Procédé de transformation")


viewPlantTransport : ItemViewDataConfig -> Product.Items -> Country.Code -> List Country -> Html Msg
viewPlantTransport itemViewDataConfig items selectedCountry countries =
    let
        countrySelector =
            Views.CountrySelect.view
                { attributes = [ class "form-select w-50 d-inline" ]
                , selectedCountry = selectedCountry
                , onSelect = CountrySelected
                , countries = countries
                }

        header =
            span [ class "d-flex justify-content-between align-items-center gap-3" ]
                [ span [ class "text-truncate" ] [ text "Transport - pays d'origine : " ]
                , countrySelector
                ]

        stepWeight =
            Product.getWeightAtPlant items
    in
    items
        |> Product.filterItemByCategory Process.Transport
        |> toItemViewDataList itemViewDataConfig stepWeight
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Process.nameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewCategory header


viewPlantWaste : ItemViewDataConfig -> Product.Items -> Html Msg
viewPlantWaste itemViewDataConfig items =
    let
        stepWeight =
            Product.getWeightAtPlant items
    in
    items
        |> Product.filterItemByCategory Process.WasteTreatment
        |> toItemViewDataList itemViewDataConfig stepWeight
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Process.nameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewCategory (text "Déchets")


stepNames : Product.Product -> List ( String, Product.Step )
stepNames product =
    [ ( "Conditionnement", product.packaging )
    , ( "Stockage", product.distribution )
    , ( "Vente au détail", product.supermarket )
    , ( "Consommation", product.consumer )
    ]


viewStepsSummary : Impact.Trigram -> Product -> Html Msg
viewStepsSummary trigram product =
    let
        totalImpact =
            Product.getTotalImpact trigram product
    in
    div [ class "card fs-7" ]
        [ product
            |> stepNames
            |> List.map (\( label, step ) -> ( label, step.items ))
            |> (\steps -> ( "Recette", product.plant ) :: steps)
            |> List.map
                (\( label, items ) ->
                    let
                        impact =
                            Product.getItemsImpact trigram items

                        percent =
                            impact / totalImpact * 100
                    in
                    li [ class "list-group-item d-flex justify-content-between align-items-center gap-1" ]
                        [ span [ class "flex-fill w-33 text-truncate" ] [ text label ]
                        , span [ class "flex-fill w-50" ]
                            [ div [ class "progress", style "height" "13px" ]
                                [ div
                                    [ class "progress-bar"
                                    , style "width" (String.fromFloat percent ++ "%")
                                    ]
                                    []
                                ]
                            ]
                        , span [ class "flex-fill text-end", style "min-width" "62px" ]
                            [ Format.percent percent
                            ]
                        ]
                )
            |> ul [ class "list-group list-group-flush" ]
        ]


viewSteps : ItemViewDataConfig -> Product -> Html Msg
viewSteps itemViewDataConfig product =
    product
        |> stepNames
        |> List.map (\( label, step ) -> viewStep label itemViewDataConfig step)
        |> div []


viewStep : String -> ItemViewDataConfig -> Product.Step -> Html Msg
viewStep label ({ definition, trigram } as itemViewDataConfig) step =
    let
        stepImpact =
            Product.getItemsImpact trigram step.items

        stepTransport =
            Product.getStepTransports step
    in
    div []
        [ div [ class "d-flex align-items-center fs-7" ]
            [ span [ class "w-50 text-end p-2" ]
                [ step.mainItem.mass
                    |> Format.kg
                ]
            , span [ class "text-center" ]
                [ DownArrow.large ]
            , [ ( Icon.bus, .road, "Routier" )
              , ( Icon.boat, .sea, "Maritime" )
              , ( Icon.rail, .rail, "Féroviaire" )
              , ( Icon.plane, .air, "Aérien" )
              ]
                |> List.map
                    (\( icon, get, title ) ->
                        div [ attribute "aria-label" title ]
                            [ span [ class "text-primary me-1" ] [ icon ]
                            , Format.km (get stepTransport)
                            ]
                    )
                |> span
                    [ class "d-flex flex-column flex-sm-row justify-content-start gap-1 gap-sm-3"
                    , class "w-50 p-2"
                    ]
            ]
        , div
            [ class "card" ]
            [ div [ class "card-header" ]
                [ div [ class "row d-flex align-items-center" ]
                    [ div [ class "col-9" ]
                        [ h3 [ class "h6 m-0" ] [ text label ] ]
                    , div [ class "col-3 text-end h5 m-0 text-nowrap overflow-hidden" ]
                        [ Format.formatImpactFloat definition 0 stepImpact ]
                    ]
                , if String.isEmpty step.mainItem.comment then
                    div [ class "fs-7 text-muted mt-1" ] [ text step.mainItem.comment ]

                  else
                    text ""
                ]
            , step.items
                |> toItemViewDataList itemViewDataConfig step.mainItem.mass
                |> List.map viewItemDetails
                |> ul [ class "list-group list-group-flush" ]
            ]
        ]


viewItemDetails : ItemViewData -> Html Msg
viewItemDetails { config, item, impact, percent, stepWeight, width } =
    li [ class "list-group-item" ]
        [ div [ class "fs-7" ]
            [ viewComment item.comment
            , text " "
            , item.process.name
                |> Process.nameToString
                |> text
            ]
        , div [ class "progress my-2", style "height" "9px" ]
            [ div
                [ class "progress-bar"
                , style "width" (String.fromFloat width ++ "%")
                ]
                []
            ]
        , div [ class "d-flex flex-row justify-content-between fs-7" ]
            [ span [ class "w-33" ]
                [ item.amount
                    |> Amount.format stepWeight
                    |> text
                ]
            , span [ class "w-33" ]
                [ impact
                    |> Unit.impactToFloat
                    |> Format.formatImpactFloat config.definition 2
                ]
            , span [ class "w-33" ]
                [ Format.percent percent ]
            ]
        ]


viewComment : String -> Html Msg
viewComment comment =
    if comment /= "" then
        span
            [ class "d-inline-flex align-items-center fs-7 gap-1 py-1 text-muted cursor-help"
            , title comment
            ]
            [ Icon.question ]

    else
        text ""
