module Page.Food.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Country as Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Food.Product as Product exposing (ProcessName, Product, ProductName)
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
import Views.Impact as ImpactView
import Views.Spinner as Spinner


type alias CurrentProductInfo =
    { product : Product
    , original : Product
    }


type alias Model =
    { currentProductInfo : Maybe CurrentProductInfo
    , selectedProduct : ProductName
    , impact : Impact.Trigram
    , selectedItem : Maybe ProcessName
    , selectedCountry : Country.Code
    }


type Msg
    = AddItem
    | CountrySelected Country.Code
    | DbLoaded (WebData FoodDb.Db)
    | DeleteItem Product.Item
    | ItemSelected (Maybe ProcessName)
    | ItemAmountChanged Product.Item (Maybe Float)
    | NoOp
    | ProductSelected ProductName
    | Reset
    | SwitchImpact Impact.Trigram


tunaPizza : ProductName
tunaPizza =
    Product.stringToProductName "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


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
                                |> Product.addMaterial foodDb.processes selectedItem

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
                        |> Product.updatePlantTransport selected.original foodDb.processes db.impacts countryCode db.transports

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
                        |> Product.removeMaterial processName

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
            case Product.findProductByName tunaPizza loadedDb.products of
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

        ( ItemAmountChanged item (Just newAmount), Just ({ product } as selected) ) ->
            let
                updatedProduct =
                    Product.updateMaterialAmount item newAmount product
            in
            ( { model | currentProductInfo = Just { selected | product = updatedProduct } }, session, Cmd.none )

        ( ProductSelected selectedProduct, _ ) ->
            case Product.findProductByName selectedProduct foodDb.products of
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
                , selectedItem = Nothing
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

        -- Product.getWeightAtStep product.consumer
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
                    ([ h2 [ class "h5 m-0" ] [ text "Impact par kg de produit" ]
                     , div [ class "display-4 lh-1 text-center text-nowrap" ]
                        [ Format.formatImpactFloat definition 2 impactPerKg ]
                     ]
                        ++ totalImpactDisplay
                    )
                ]
            , footer = []
            }
        , viewStepsSummary trigram product
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view ({ foodDb, db } as session) ({ selectedProduct, impact, selectedItem, selectedCountry } as model) =
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
                            , viewMaterial itemViewDataConfig product.plant
                            , viewIngredientSelector selectedItem product foodDb.products
                            , viewEnergy itemViewDataConfig product.plant
                            , viewProcessing itemViewDataConfig product.plant
                            , viewTransport itemViewDataConfig product.plant selectedCountry db.countries
                            , viewWaste itemViewDataConfig product.plant
                            , button
                                [ class "btn btn-outline-primary w-100 mt-3"
                                , onClick Reset
                                ]
                                [ text "Réinitialiser" ]
                            , viewSteps itemViewDataConfig product
                            , div [ class "mb-3" ]
                                [ div [ class "d-flex align-items-center fs-7" ]
                                    [ span [ class "w-50 text-end p-2" ]
                                        [ finalWeight
                                            |> Format.formatRichFloat 3 "kg"
                                        ]
                                    , span [ class "text-center" ]
                                        [ DownArrow.large ]
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
                        Product.productNameToString productName
                in
                option
                    [ value name
                    , selected (productName == selectedProduct)
                    ]
                    [ text name ]
            )
        >> select
            [ class "form-select mb-3"
            , onInput (Product.stringToProductName >> ProductSelected)
            ]


viewIngredientSelector : Maybe ProcessName -> Product.Product -> Product.Products -> Html Msg
viewIngredientSelector selectedItem product products =
    div [ class "row pt-3 gap-2 gap-md-0" ]
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
    let
        name =
            item.process.name |> Product.processNameToString
    in
    div [ class "card-body row align-items-center py-1" ]
        [ div [ class "col-sm-3" ]
            [ if disabled then
                item
                    |> Product.formatItem stepWeight
                    |> text
                    |> List.singleton
                    |> span [ class "fs-7" ]

              else
                div [ class "input-group input-group-sm my-2" ]
                    [ input
                        [ id <| "slider-" ++ name
                        , class "form-control text-end incdec-arrows-left"
                        , type_ "number"
                        , step "1"
                        , item.amount
                            |> (\f -> f * 1000)
                            |> round
                            |> String.fromInt
                            |> value
                        , title "Quantité en grammes"
                        , onInput <|
                            \str ->
                                ItemAmountChanged item
                                    (if str == "" then
                                        Just 0

                                     else
                                        str |> String.toFloat |> Maybe.map (\f -> f / 1000)
                                    )
                        , Html.Attributes.min "0"
                        ]
                        []
                    , span [ class "input-group-text" ] [ text "g" ]
                    ]
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
    , stepWeight : Float
    }


type alias ItemViewDataConfig =
    { totalImpact : Float
    , trigram : Impact.Trigram
    , definition : Impact.Definition
    }


makeItemViewData : ItemViewDataConfig -> Float -> Product.Item -> ItemViewData
makeItemViewData ({ totalImpact, trigram } as config) stepWeight ({ amount, process } as item) =
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
    , stepWeight = stepWeight
    }


toItemViewDataList : ItemViewDataConfig -> Float -> List Product.Item -> List ItemViewData
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


maybeToProcessName : String -> Maybe ProcessName
maybeToProcessName string =
    if string == "" then
        Nothing

    else
        Just (Product.stringToProcessName string)


itemSelector : Maybe ProcessName -> (Maybe ProcessName -> Msg) -> List ProcessName -> Html Msg
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
    let
        stepWeight =
            Product.getWeightAtPlant step
    in
    step.material
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
                        Product.processNameToString item.process.name
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


viewEnergy : ItemViewDataConfig -> Product.Step -> Html Msg
viewEnergy itemViewDataConfig step =
    let
        stepWeight =
            Product.getWeightAtPlant step
    in
    step.energy
        |> toItemViewDataList itemViewDataConfig stepWeight
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
        |> viewCategory (text "Énergie")


viewProcessing : ItemViewDataConfig -> Product.Step -> Html Msg
viewProcessing itemViewDataConfig step =
    let
        stepWeight =
            Product.getWeightAtPlant step
    in
    step.processing
        |> toItemViewDataList itemViewDataConfig stepWeight
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
        |> viewCategory (text "Procédé")


viewTransport : ItemViewDataConfig -> Product.Step -> Country.Code -> List Country -> Html Msg
viewTransport itemViewDataConfig step selectedCountry countries =
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
            Product.getWeightAtPlant step
    in
    step.transport
        |> toItemViewDataList itemViewDataConfig stepWeight
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
        |> viewCategory header


viewWaste : ItemViewDataConfig -> Product.Step -> Html Msg
viewWaste itemViewDataConfig step =
    let
        stepWeight =
            Product.getWeightAtPlant step
    in
    step.wasteTreatment
        |> toItemViewDataList itemViewDataConfig stepWeight
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
        |> viewCategory (text "Déchets")


stepNames : Product.Product -> List ( String, Product.Step )
stepNames product =
    [ ( "Recette", product.plant )
    , ( "Conditionnement", product.packaging )
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
            |> List.map
                (\( label, step ) ->
                    let
                        impact =
                            Product.getStepImpact trigram step

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
        -- Exclude the first Recipe step
        |> List.drop 1
        |> List.map (\( label, step ) -> viewStep label itemViewDataConfig step)
        |> div []


viewStep : String -> ItemViewDataConfig -> Product.Step -> Html Msg
viewStep label ({ definition, trigram } as itemViewDataConfig) step =
    let
        stepWeight =
            Product.getWeightAtStep step

        stepImpact =
            Product.getStepImpact trigram step

        stepTransport =
            Product.getStepTransports step
    in
    div []
        [ div [ class "d-flex align-items-center fs-7" ]
            [ span [ class "w-50 text-end p-2" ]
                [ stepWeight
                    |> Format.formatRichFloat 3 "kg"
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
                , case Product.getMainItemComment step of
                    Just comment ->
                        div [ class "fs-7 text-muted mt-1" ] [ text comment ]

                    Nothing ->
                        text ""
                ]
            , step
                |> Product.stepToItems
                |> List.filter (.mainItem >> not)
                |> toItemViewDataList itemViewDataConfig stepWeight
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
                    |> Product.formatItem stepWeight
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
