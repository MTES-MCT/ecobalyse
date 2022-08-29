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
import Ports
import RemoteData exposing (WebData)
import Request.Food.Db as RequestDb
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.CountrySelect
import Views.Format as Format
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
    , selectedItem : String
    , selectedCountry : Country.Code
    }


type Msg
    = AddItem
    | CountrySelected Country.Code
    | DbLoaded (WebData Db.Db)
    | DeleteItem Product.Item
    | ItemSelected String
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
      , selectedItem = ""
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
            let
                productWithAddedItem =
                    selected.product
                        |> Product.addMaterial selected.rawCookedRatioInfo foodDb.processes model.selectedItem

                productWithPefScore =
                    productWithAddedItem
                        |> Result.map (Product.computePefImpact session.db.impacts)
            in
            case productWithPefScore of
                Ok updatedProduct ->
                    ( { model
                        | currentProductInfo = Just { selected | product = updatedProduct }
                      }
                    , session
                    , Cmd.none
                    )

                Err message ->
                    ( model
                    , session
                        |> Session.notifyError "Erreur lors de l'ajout de l'ingrédient" message
                    , Cmd.none
                    )

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
                in
                Container.centered []
                    [ div [ class "row" ]
                        [ div [ class "col-sm-8" ]
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
                                , viewMaterial ratioToStringKg totalImpact impact definition product.plant
                                , div [ class "row py-3 gap-2 gap-sm-0" ]
                                    [ div [ class "col-sm-10" ]
                                        [ foodDb.products
                                            |> Product.listItems
                                            |> itemselector ItemSelected
                                        ]
                                    , div [ class "col-sm-2" ]
                                        [ button
                                            [ class "btn btn-primary w-100"
                                            , onClick AddItem
                                            , disabled (selectedItem == "")
                                            ]
                                            [ text "Ajouter un ingrédient" ]
                                        ]
                                    ]
                                , viewEnergy totalImpact impact definition product.plant
                                , viewProcessing totalImpact impact definition product.plant
                                , viewTransport totalWeight totalImpact impact definition product.plant selectedCountry db.countries
                                , viewWaste totalImpact impact definition product.plant
                                , div [ class "py-3 col-sm-2" ]
                                    [ button
                                        [ class "btn btn-primary w-100"
                                        , onClick Reset
                                        ]
                                        [ text "Réinitialiser" ]
                                    ]
                                ]
                            ]
                        , div [ class "col-sm-4" ]
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
                                    [ div [ class "d-flex flex-column justify-content-end m-auto gap-2" ]
                                        [ div []
                                            [ h2 [ class "h5 m-0" ] [ text "Impact normalisé" ]
                                            , div [ class "display-4 text-center text-nowrap" ]
                                                [ Format.formatImpactFloat definition impactPerKg ]
                                            , div [ class "fs-7 text-end" ] [ text "par kg de produit" ]
                                            ]
                                        , div []
                                            [ h3 [ class "h6 m-0" ] [ text "Impact total" ]
                                            , div [ class "display-5 text-center text-nowrap" ]
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
                                    ]
                                , footer = []
                                }
                            ]
                        ]
                    ]

            _ ->
                Spinner.view
      ]
    )


ratioToStringKg : Unit.Ratio -> String
ratioToStringKg =
    Unit.ratioToFloat
        >> Format.formatFloat 3
        >> (\mass -> mass ++ "kg")


ratioToStringKgKm : Float -> Unit.Ratio -> String
ratioToStringKgKm totalWeight amount =
    let
        -- amount is in Ton.Km for the total weight. We instead want the total number of km.
        amountAsFloat =
            Unit.ratioToFloat amount

        perKg =
            amountAsFloat / totalWeight

        distanceInKm =
            perKg * 1000
    in
    Format.formatFloat 0 distanceInKm
        ++ " km ("
        ++ Format.formatFloat 2 (amountAsFloat * 1000)
        ++ " kg.km)"


viewHeader : Html Msg -> Html Msg -> List (Html Msg) -> Html Msg
viewHeader header1 header2 children =
    if List.length children > 0 then
        div [ class "mt-3" ]
            [ div [ class "row" ]
                [ div [ class "col-lg-6" ]
                    [ h3 [ class "h5" ] [ header1 ]
                    ]
                , div [ class "col-lg-6 d-none d-sm-block" ]
                    [ h3 [ class "h5" ] [ header2 ] ]
                ]

            -- Enclosing the children so the first stacked card has the
            -- :first-child css selector applied
            , div [ class "stacked-card" ] children
            ]

    else
        text ""


viewMaterial : (Unit.Ratio -> String) -> Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewMaterial toString totalImpact impact definition step =
    step.material
        |> List.map
            (\item ->
                let
                    bar =
                        makeBar totalImpact impact definition item
                in
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
                    , viewProcess toString { disabled = False } bar
                    ]
            )
        |> viewHeader (text "Ingrédients") (text "% de l'impact total")


viewProcess : (Unit.Ratio -> String) -> { disabled : Bool } -> Bar -> Html Msg
viewProcess toString { disabled } bar =
    let
        name =
            bar.item.process.name |> Product.processNameToString
    in
    div [ class "row align-items-center" ]
        [ div [ class "col-sm-6 px-4 py-2 py-sm-0" ]
            [ span [ class "d-block d-sm-none fs-7 text-muted" ] [ text "Quantité de l'ingrédient :" ]
            , RangeSlider.ratio
                { id = "slider-" ++ name
                , update = ItemSliderChanged bar.item
                , value = Unit.Ratio bar.item.amount
                , toString = toString
                , disabled = disabled
                , min = 0
                , max = 100
                }
            ]
        , div [ class "col-sm-6" ]
            [ barView bar
            ]
        ]


type alias Bar =
    { item : Product.Item
    , definition : Impact.Definition
    , impact : Float
    , width : Float
    , percent : Float
    }


makeBar : Float -> Impact.Trigram -> Impact.Definition -> Product.Item -> Bar
makeBar totalImpact trigram definition ({ amount, process } as item) =
    let
        impact =
            Impact.grabImpactFloat Unit.PerItem Product.unusedDuration trigram process * amount

        percent =
            impact * toFloat 100 / totalImpact
    in
    { item = item
    , definition = definition
    , impact = impact
    , width = clamp 0 100 percent
    , percent = percent
    }


barView : Bar -> Html Msg
barView bar =
    div [ class "ps-3 py-1 border-top border-top-sm-0 border-start-0 border-start-sm d-flex" ]
        [ div [ class "w-50 border my-2" ]
            [ div
                [ class "bg-primary"
                , style "height" "100%"
                , style "width" (String.fromFloat bar.width ++ "%")
                ]
                []
            ]
        , div [ class "text-end py-1 ps-2 text-truncate flex-fill" ]
            [ Format.formatImpactFloat bar.definition bar.impact
            , text " ("
            , Format.percent bar.percent
            , text ")"
            ]
        , button
            [ class "btn"
            , onClick <| DeleteItem bar.item
            ]
            [ i [ class "icon icon-trash" ] [] ]
        ]


itemselector : (String -> Msg) -> List String -> Html Msg
itemselector event =
    List.map (\processName -> option [ value processName ] [ text processName ])
        >> (++) [ option [] [ text "-- Sélectionner un ingrédient dans la liste --" ] ]
        >> select [ class "form-select", onInput event ]


viewEnergy : Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewEnergy totalImpact impact definition step =
    step.energy
        |> List.map
            (\item ->
                let
                    bar =
                        makeBar totalImpact impact definition item
                in
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewProcess ratioToStringKg { disabled = True } bar
                    ]
            )
        |> viewHeader (text "Énergie") (text "% de l'impact total")


viewProcessing : Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewProcessing totalImpact impact definition step =
    step.processing
        |> List.map
            (\item ->
                let
                    bar =
                        makeBar totalImpact impact definition item
                in
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewProcess ratioToStringKg { disabled = True } bar
                    ]
            )
        |> viewHeader (text "Procédé") (text "% de l'impact total")


viewTransport : Float -> Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Country.Code -> List Country -> Html Msg
viewTransport totalWeight totalImpact impact definition step selectedCountry countries =
    let
        countrySelector =
            Views.CountrySelect.view
                { attributes = [ class "form-select w-25 d-inline" ]
                , selectedCountry = selectedCountry
                , onSelect = CountrySelected
                , countries = countries
                }

        header =
            span []
                [ text "Transport - pays d'origine : "
                , countrySelector
                ]
    in
    step.transport
        |> List.map
            (\item ->
                let
                    bar =
                        makeBar totalImpact impact definition item
                in
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewProcess (ratioToStringKgKm totalWeight) { disabled = True } bar
                    ]
            )
        |> viewHeader header (text "% de l'impact total")


viewWaste : Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewWaste totalImpact impact definition step =
    step.wasteTreatment
        |> List.map
            (\item ->
                let
                    bar =
                        makeBar totalImpact impact definition item
                in
                div [ class "card" ]
                    [ div [ class "card-header" ]
                        [ text <| Product.processNameToString item.process.name
                        , text item.comment
                        ]
                    , viewProcess ratioToStringKg { disabled = True } bar
                    ]
            )
        |> viewHeader (text "Déchets") (text "% de l'impact total")
