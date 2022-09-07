module Page.Food.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Country as Country exposing (Country)
import Data.Food.Db as Db
import Data.Food.Product as Product exposing (Product)
import Data.Impact as Impact
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Dict.Any as AnyDict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Ports
import Quantity
import RemoteData exposing (WebData)
import Request.Food.Db as RequestDb
import Views.Component.DownArrow as DownArrow
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.CountrySelect
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact exposing (impactSelector)
import Views.RangeSlider as RangeSlider
import Views.Spinner as Spinner


type alias CurrentProductInfo =
    { product : Product
    , original : Product
    , rawCookedRatioInfo : Maybe Product.RawCookedRatioInfo
    }


type alias Model =
    { currentProductInfo : Maybe CurrentProductInfo
    , selectedProduct : String
    , impact : Impact.Trigram
    , selectedItem : Maybe Product.ProcessName
    , selectedCountry : Country.Code
    }


type Msg
    = AddItem
    | CountrySelected Country.Code
    | DbLoaded (WebData Db.Db)
    | DeleteItem Product.Item
    | ItemSelected (Maybe Product.ProcessName)
    | ItemSliderChanged Product.Item (Maybe Unit.Ratio)
    | NoOp
    | ProductSelected String
    | Reset
    | SwitchImpact Impact.Trigram


tunaPizza : String
tunaPizza =
    "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { currentProductInfo = Nothing
      , selectedProduct = tunaPizza
      , impact = Impact.defaultTrigram
      , selectedItem = Nothing
      , selectedCountry = Product.defaultCountry
      }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ foodDb, db } as session) msg ({ currentProductInfo } as model) =
    case ( msg, currentProductInfo ) of
        ( AddItem, Just selected ) ->
            case model.selectedItem of
                Just selectedItem ->
                    let
                        productWithAddedItem =
                            selected.product
                                |> Product.addMaterial selected.rawCookedRatioInfo foodDb.processes selectedItem

                        productWithPefScore =
                            productWithAddedItem
                                |> Result.map (Product.computePefImpact session.db.impacts)
                    in
                    case productWithPefScore of
                        Ok updatedProduct ->
                            ( { model
                                | currentProductInfo = Just { selected | product = updatedProduct }
                                , selectedItem = Nothing
                              }
                            , session
                            , Cmd.none
                            )

                        Err message ->
                            ( { model | selectedItem = Nothing }
                            , session
                                |> Session.notifyError "Erreur lors de l'ajout de l'ingrédient" message
                            , Cmd.none
                            )

                Nothing ->
                    ( model, session, Cmd.none )

        ( CountrySelected countryCode, Just selected ) ->
            let
                productWithUpdatedTransport =
                    selected.product
                        |> Product.updateTransport selected.original.plant.transport foodDb.processes db.impacts countryCode db.transports

                productWithPefScore =
                    productWithUpdatedTransport
                        |> Product.computePefImpact session.db.impacts
            in
            ( { model
                | currentProductInfo = Just { selected | product = productWithPefScore }
                , selectedCountry = countryCode
              }
            , session
            , Cmd.none
            )

        ( DeleteItem processName, Just selected ) ->
            let
                productWithoutItem =
                    selected.product
                        |> Product.removeMaterial selected.rawCookedRatioInfo processName

                productWithPefScore =
                    productWithoutItem
                        |> Product.computePefImpact session.db.impacts
            in
            ( { model
                | currentProductInfo = Just { selected | product = productWithPefScore }
              }
            , session
            , Cmd.none
            )

        ( DbLoaded (RemoteData.Success loadedDb), _ ) ->
            case Product.findProductByName (Product.stringToProductName tunaPizza) loadedDb.products of
                Ok product ->
                    let
                        productWithPefScore =
                            product
                                |> Product.computePefImpact session.db.impacts
                    in
                    ( { model
                        | currentProductInfo =
                            Just
                                { product = productWithPefScore
                                , original = productWithPefScore
                                , rawCookedRatioInfo = Product.getRawCookedRatioInfo product
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

        ( ItemSelected itemName, _ ) ->
            ( { model | selectedItem = itemName }
            , session
            , Cmd.none
            )

        ( ItemSliderChanged item (Just newAmount), Just selected ) ->
            let
                { product, rawCookedRatioInfo } =
                    selected

                updatedProduct =
                    { product | plant = Product.updateAmount rawCookedRatioInfo item (Unit.ratioToFloat newAmount) product.plant }
            in
            ( { model | currentProductInfo = Just { selected | product = updatedProduct } }, session, Cmd.none )

        ( ProductSelected productSelected, _ ) ->
            case Product.findProductByName (Product.stringToProductName productSelected) foodDb.products of
                Ok product ->
                    let
                        productWithPefScore =
                            product
                                |> Product.computePefImpact session.db.impacts
                    in
                    ( { model
                        | currentProductInfo =
                            Just
                                { product = productWithPefScore
                                , original = productWithPefScore
                                , rawCookedRatioInfo = Product.getRawCookedRatioInfo product
                                }
                        , selectedProduct = productSelected
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
                , selectedItem = Nothing
              }
            , session
            , Cmd.none
            )

        ( SwitchImpact impact, _ ) ->
            ( { model | impact = impact }, session, Cmd.none )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view ({ foodDb, db } as session) { currentProductInfo, selectedProduct, impact, selectedItem, selectedCountry } =
    ( "Simulateur de recettes"
    , [ case currentProductInfo of
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

                    definition =
                        db.impacts
                            |> Impact.getDefinition impact
                            |> Result.withDefault Impact.invalid

                    itemViewDataConfig =
                        { totalImpact = totalImpact
                        , totalWeight = totalWeight
                        , trigram = impact
                        , definition = definition
                        }
                in
                Container.centered []
                    [ div [ class "row gap-3 gap-lg-0" ]
                        [ div [ class "col-lg-4 order-lg-2" ]
                            [ div [ class "mb-3" ]
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
                            , SummaryComp.view
                                { header = []
                                , body =
                                    [ div [ class "d-flex flex-column m-auto gap-1 px-1" ]
                                        [ h2 [ class "h5 m-0" ] [ text "Impact normalisé" ]
                                        , div [ class "display-4 lh-1 text-center text-nowrap" ]
                                            [ Format.formatImpactFloat definition impactPerKg ]
                                        , div [ class "fs-7 text-end" ] [ text "par kg de produit" ]
                                        , h3 [ class "h6 m-0 mt-2" ] [ text "Impact total" ]
                                        , div [ class "display-5 lh-1 text-center text-nowrap" ]
                                            [ Format.formatImpactFloat definition totalImpact ]
                                        , div [ class "fs-7 text-end" ]
                                            [ text " pour un poids total de "
                                            , strong []
                                                [ totalWeight |> Format.formatFloat 3 |> text
                                                , text "\u{00A0}kg"
                                                ]
                                            ]
                                        ]
                                    ]
                                , footer = []
                                }
                            ]
                        , div [ class "col-lg-8 order-lg-1" ]
                            [ div []
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
                                                        Product.productNameToString productName
                                                in
                                                option
                                                    [ value name
                                                    , selected (name == selectedProduct)
                                                    ]
                                                    [ text name ]
                                            )
                                    )
                                , viewMaterial itemViewDataConfig product.plant
                                , viewIngredientSelector selectedItem product foodDb.products
                                , viewEnergy itemViewDataConfig product.plant
                                , viewProcessing itemViewDataConfig product.plant
                                , viewTransport itemViewDataConfig product.plant selectedCountry db.countries
                                , viewWaste itemViewDataConfig product.plant
                                , button
                                    [ class "btn btn-outline-primary w-100 my-3"
                                    , onClick Reset
                                    ]
                                    [ text "Réinitialiser" ]
                                , viewSteps itemViewDataConfig product
                                ]
                            ]
                        ]
                    ]

            _ ->
                Spinner.view
      ]
    )


viewIngredientSelector : Maybe Product.ProcessName -> Product.Product -> Product.Products -> Html Msg
viewIngredientSelector selectedItem product products =
    div [ class "row py-3 gap-2 gap-md-0" ]
        [ div [ class "col-md-8" ]
            [ products
                |> Product.listIngredients
                |> List.filter
                    (\processName ->
                        -- Exclude already used materials
                        product.plant.material
                            |> List.map (.process >> .name)
                            |> List.member processName
                            |> not
                    )
                |> itemSelector selectedItem ItemSelected
            ]
        , div [ class "col-md-4" ]
            [ button
                [ class "btn btn-primary w-100 text-truncate"
                , onClick AddItem
                , disabled (selectedItem == Nothing)
                , title "Ajouter un ingrédient"
                ]
                [ text "Ajouter un ingrédient" ]
            ]
        ]


viewHeader : Html Msg -> Html Msg -> List (Html Msg) -> Html Msg
viewHeader header1 header2 children =
    if List.length children > 0 then
        div [ class "mt-3" ]
            [ div [ class "row" ]
                [ div [ class "col-12 col-lg-6 d-block d-lg-flex align-items-center" ]
                    [ h3 [ class "h6" ] [ header1 ]
                    ]
                , div [ class "col-0 col-lg-6 d-none d-lg-flex align-items-center justify-content-center" ]
                    [ h3 [ class "h6" ] [ header2 ] ]
                ]

            -- Enclosing the children so the first stacked card has the
            -- :first-child css selector applied
            , div [ class "stacked-card" ] children
            ]

    else
        text ""


viewPlantProcess : { disabled : Bool } -> ItemViewData -> Html Msg
viewPlantProcess { disabled } ({ item, config } as itemViewData) =
    let
        name =
            item.process.name |> Product.processNameToString
    in
    div [ class "row align-items-center" ]
        [ div [ class "col-sm-6 px-4 py-2 py-sm-0" ]
            [ span [ class "d-block d-sm-none fs-7 text-muted" ] [ text "Quantité de l'ingrédient :" ]
            , if disabled then
                item
                    |> Product.formatItem config.totalWeight
                    |> text
                    |> List.singleton
                    |> span [ class "fs-7" ]

              else
                RangeSlider.ratio
                    { id = "slider-" ++ name
                    , update = ItemSliderChanged item
                    , value = Unit.Ratio item.amount
                    , toString =
                        \ratio ->
                            ratio
                                |> Unit.ratioToFloat
                                |> Product.formatAmount config.totalWeight item.process.unit
                    , disabled = disabled
                    , min = 0
                    , max = 100
                    }
            ]
        , div [ class "col-sm-6" ]
            [ itemView { disabled = disabled } itemViewData
            ]
        ]


type alias ItemViewData =
    { item : Product.Item
    , impact : Unit.Impact
    , width : Float
    , percent : Float
    , config : ItemViewDataConfig
    }


type alias ItemViewDataConfig =
    { totalImpact : Float
    , totalWeight : Float
    , trigram : Impact.Trigram
    , definition : Impact.Definition
    }


makeItemViewData : ItemViewDataConfig -> Product.Item -> ItemViewData
makeItemViewData ({ totalImpact, trigram } as config) ({ amount, process } as item) =
    let
        impact =
            Impact.getImpact trigram process.impacts
                |> Quantity.multiplyBy amount

        percent =
            Unit.impactToFloat impact * toFloat 100 / totalImpact
    in
    { item = item
    , impact = impact
    , width = clamp 0 100 percent
    , percent = percent
    , config = config
    }


toItemViewDataList : ItemViewDataConfig -> List Product.Item -> List ItemViewData
toItemViewDataList itemViewDataConfig =
    List.map (makeItemViewData itemViewDataConfig)
        -- order by impacts…
        >> List.sortBy (.impact >> Unit.impactToFloat)
        -- … in descending order
        >> List.reverse


itemView : { disabled : Bool } -> ItemViewData -> Html Msg
itemView { disabled } itemViewData =
    div [ class "px-3 py-1 border-top border-top-sm-0 border-start-0 border-start-sm d-flex align-items-center gap-1" ]
        [ div [ class "w-50", style "max-width" "50%", style "min-width" "50%" ]
            [ div [ class "progress" ]
                [ div [ class "progress-bar", style "width" (String.fromFloat itemViewData.width ++ "%") ] []
                ]
            ]
        , div [ class "text-start py-1 ps-2 text-truncate flex-fill fs-7" ]
            [ itemViewData.impact
                |> Unit.impactToFloat
                |> Format.formatImpactFloat itemViewData.config.definition
            , text " ("
            , Format.percent itemViewData.percent
            , text ")"
            ]
        , if disabled then
            text ""

          else
            button
                [ class "btn p-0 text-primary"
                , Html.Attributes.disabled disabled
                , onClick <| DeleteItem itemViewData.item
                ]
                [ i [ class "icon icon-trash" ] [] ]
        ]


maybeToProcessName : String -> Maybe Product.ProcessName
maybeToProcessName string =
    if string == "" then
        Nothing

    else
        Just (Product.stringToProcessName string)


itemSelector : Maybe Product.ProcessName -> (Maybe Product.ProcessName -> Msg) -> List Product.ProcessName -> Html Msg
itemSelector maybeSelectedItem event =
    List.map
        (\processName ->
            let
                string =
                    Product.processNameToString processName
            in
            ( string, option [ selected <| maybeSelectedItem == Just processName ] [ text string ] )
        )
        >> (++)
            [ ( "-- Sélectionner un ingrédient dans la liste --"
              , option [ selected <| maybeSelectedItem == Nothing ] [ text "-- Sélectionner un ingrédient dans la liste --" ]
              )
            ]
        >> Html.Keyed.node "select" [ class "form-select", onInput (maybeToProcessName >> event) ]


viewMaterial : ItemViewDataConfig -> Product.Step -> Html Msg
viewMaterial itemViewDataConfig step =
    step.material
        |> toItemViewDataList itemViewDataConfig
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ div [ class "row" ]
                            [ div [ class "col-lg-8" ]
                                [ text <| Product.processNameToString item.process.name
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
        |> viewHeader (text "Ingrédients") (text "% de l'impact total")


viewEnergy : ItemViewDataConfig -> Product.Step -> Html Msg
viewEnergy itemViewDataConfig step =
    step.energy
        |> toItemViewDataList itemViewDataConfig
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewHeader (text "Énergie") (text "% de l'impact total")


viewProcessing : ItemViewDataConfig -> Product.Step -> Html Msg
viewProcessing itemViewDataConfig step =
    step.processing
        |> toItemViewDataList itemViewDataConfig
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewHeader (text "Procédé") (text "% de l'impact total")


viewTransport : ItemViewDataConfig -> Product.Step -> Country.Code -> List Country -> Html Msg
viewTransport itemViewDataConfig step selectedCountry countries =
    let
        countrySelector =
            Views.CountrySelect.view
                { attributes = [ class "form-select w-25 d-inline" ]
                , selectedCountry = selectedCountry
                , onSelect = CountrySelected
                , countries = countries
                }

        header =
            span [ class "d-flex justify-content-between align-items-center" ]
                [ span [ class "text-truncate" ] [ text "Transport - pays d'origine : " ]
                , countrySelector
                ]
    in
    step.transport
        |> toItemViewDataList itemViewDataConfig
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewHeader header (text "% de l'impact total")


viewWaste : ItemViewDataConfig -> Product.Step -> Html Msg
viewWaste itemViewDataConfig step =
    step.wasteTreatment
        |> toItemViewDataList itemViewDataConfig
        |> List.map
            (\({ item } as itemViewData) ->
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewPlantProcess { disabled = True } itemViewData
                    ]
            )
        |> viewHeader (text "Déchets") (text "% de l'impact total")


viewSteps : ItemViewDataConfig -> Product -> Html Msg
viewSteps itemViewDataConfig product =
    [ ( "Conditionnement", product.packaging )
    , ( "Distribution", product.distribution )
    , ( "Supermarché", product.supermarket )
    , ( "Chez le consommateur", product.consumer )
    ]
        |> List.map (\( label, step ) -> viewStep label itemViewDataConfig step)
        |> List.intersperse DownArrow.view
        |> div [ class "mb-3" ]


viewStep : String -> ItemViewDataConfig -> Product.Step -> Html Msg
viewStep label itemViewDataConfig step =
    div [ class "card" ]
        (case step.mainItem of
            Just mainItem ->
                let
                    totalImpact =
                        Product.getTotalImpact itemViewDataConfig.trigram step

                    totalWeight =
                        Product.getTotalWeight step

                    mainItemImpact =
                        mainItem.process.impacts
                            |> Impact.getImpact itemViewDataConfig.trigram
                            |> Unit.impactToFloat
                            |> (*) mainItem.amount

                    stepImpact =
                        totalImpact - mainItemImpact

                    stepConfig =
                        { itemViewDataConfig | totalImpact = totalImpact }
                in
                [ div [ class "card-header" ]
                    [ div [ class "row" ]
                        [ div [ class "col-6" ]
                            [ text label ]
                        , div [ class "col-6 text-end" ]
                            [ Format.formatImpactFloat stepConfig.definition stepImpact ]
                        ]
                    ]
                , step
                    |> Product.stepToItems
                    |> toItemViewDataList stepConfig
                    |> List.map (viewItemDetails totalWeight)
                    |> ul [ class "list-group list-group-flush" ]
                ]

            Nothing ->
                [ text "Procédé introuvable" ]
        )


viewItemDetails : Float -> ItemViewData -> Html Msg
viewItemDetails totalWeight { config, item, impact, percent, width } =
    li [ class "list-group-item" ]
        [ div [ class "fs-7" ]
            [ viewComment item.comment
            , text " "
            , item.process.name
                |> Product.processNameToString
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
                [ item
                    |> Product.formatItem totalWeight
                    |> text
                ]
            , span [ class "w-33" ]
                [ impact
                    |> Unit.impactToFloat
                    |> Format.formatImpactFloat config.definition
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
