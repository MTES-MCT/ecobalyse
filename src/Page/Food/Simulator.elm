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
import Views.Container as Container
import Views.CountrySelect
import Views.Format as Format
import Views.Impact exposing (impactSelector)
import Views.RangeSlider as RangeSlider


type alias CurrentProductInfo =
    { product : Product
    , original : Product
    , rawCookedRatioInfo : Maybe Product.RawCookedRatioInfo
    }


type alias Model =
    { currentProductInfo : Maybe CurrentProductInfo
    , selectedProduct : String
    , impact : Impact.Trigram
    , selectedIngredient : String
    , selectedCountry : Country.Code
    }


type Msg
    = AddIngredient
    | CountrySelected Country.Code
    | DbLoaded (WebData Db.Db)
    | DeleteIngredient Product.ProcessName
    | IngredientSelected String
    | IngredientSliderChanged Product.ProcessName (Maybe Unit.Ratio)
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
      , selectedIngredient = ""
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
        ( AddIngredient, Just selected ) ->
            let
                productWithAddedIngredient =
                    selected.product
                        |> Product.addMaterial selected.rawCookedRatioInfo foodDb.processes model.selectedIngredient

                productWithPefScore =
                    productWithAddedIngredient
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

        ( DeleteIngredient processName, Just selected ) ->
            let
                productWithoutIngredient =
                    selected.product
                        |> Product.removeMaterial selected.rawCookedRatioInfo processName

                productWithPefScore =
                    productWithoutIngredient
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

        ( IngredientSelected ingredientName, _ ) ->
            ( { model | selectedIngredient = ingredientName }
            , session
            , Cmd.none
            )

        ( IngredientSliderChanged name (Just newAmount), Just selected ) ->
            let
                { product, rawCookedRatioInfo } =
                    selected

                updatedProduct =
                    { product | plant = Product.updateAmount rawCookedRatioInfo name (Unit.ratioToFloat newAmount) product.plant }
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
view ({ foodDb, db } as session) { currentProductInfo, selectedProduct, impact, selectedIngredient, selectedCountry } =
    ( "Simulateur de recettes"
    , [ Container.centered []
            (case currentProductInfo of
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
                                [ impactPerKg
                                    |> Format.formatImpactFloat definition
                                , span [ class "fs-unit" ]
                                    [ text "/kg de produit"
                                    , text " (total : "
                                    , Format.formatImpactFloat definition totalImpact
                                    , text ")"
                                    ]
                                ]
                            ]
                        ]
                    , viewMaterial ratioToStringKg totalImpact impact definition product.plant
                    , div [ class "row py-3 gap-2 gap-sm-0" ]
                        [ div [ class "col-sm-10" ]
                            [ foodDb.products
                                |> Product.listIngredients
                                |> ingredientSelector IngredientSelected
                            ]
                        , div [ class "col-sm-2" ]
                            [ button
                                [ class "btn btn-primary w-100"
                                , onClick AddIngredient
                                , disabled (selectedIngredient == "")
                                ]
                                [ text "Ajouter un ingrédient" ]
                            ]
                        ]
                    , viewEnergy totalImpact impact definition product.plant
                    , viewProcessing totalImpact impact definition product.plant
                    , viewTransport totalWeight totalImpact impact definition product.plant selectedCountry db.countries
                    , viewWaste totalImpact impact definition product.plant
                    , div [ class "row py-3 gap-2 gap-sm-0" ]
                        [ div [ class "col-sm-10 fw-bold" ]
                            [ text "Poids total avant perte (cuisson, invendus...) : "
                            , totalWeight
                                |> Format.formatFloat 3
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


viewMaterial : (Unit.Ratio -> String) -> Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewMaterial toString totalImpact impact definition step =
    step.material
        |> AnyDict.toList
        |> List.map
            (\( name, ingredient ) ->
                let
                    bar =
                        makeBar totalImpact impact definition name ingredient
                in
                div [ class "card stacked-card" ]
                    [ div [ class "card-header" ] [ text <| Product.processNameToString name ]
                    , viewProcess toString False bar
                    ]
            )
        |> viewHeader (text "Ingrédients") (text "Pourcentage de l'impact total")


viewProcess : (Unit.Ratio -> String) -> Bool -> Bar -> Html Msg
viewProcess toString disabled bar =
    let
        name =
            bar.name |> Product.processNameToString
    in
    div [ class "row align-items-center" ]
        [ div [ class "col-sm-6 px-4 py-2 py-sm-0" ]
            [ span [ class "d-block d-sm-none fs-7 text-muted" ] [ text "Quantité de l'ingrédient :" ]
            , RangeSlider.ratio
                { id = "slider-" ++ name
                , update = IngredientSliderChanged bar.name
                , value = bar.amount
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
    { name : Product.ProcessName
    , definition : Impact.Definition
    , amount : Unit.Ratio
    , impact : Float
    , width : Float
    , percent : Float
    }


makeBar : Float -> Impact.Trigram -> Impact.Definition -> Product.ProcessName -> Product.Ingredient -> Bar
makeBar totalImpact trigram definition processName { amount, process } =
    let
        impact =
            Impact.grabImpactFloat Unit.PerItem Product.unusedDuration trigram process * amount

        percent =
            impact * toFloat 100 / totalImpact
    in
    { name = processName
    , definition = definition
    , amount = Unit.Ratio amount
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
            , onClick <| DeleteIngredient bar.name
            ]
            [ i [ class "icon icon-trash" ] [] ]
        ]


ingredientSelector : (String -> Msg) -> List String -> Html Msg
ingredientSelector event =
    List.map (\processName -> option [ value processName ] [ text processName ])
        >> (++) [ option [] [ text "-- Sélectionner un ingrédient dans la liste --" ] ]
        >> select [ class "form-select", onInput event ]


viewEnergy : Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewEnergy totalImpact impact definition step =
    step.energy
        |> AnyDict.toList
        |> List.map
            (\( name, process ) ->
                let
                    bar =
                        makeBar totalImpact impact definition name process
                in
                div [ class "card stacked-card" ]
                    [ div [ class "card-header" ] [ text <| Product.processNameToString name ]
                    , viewProcess ratioToStringKg True bar
                    ]
            )
        |> viewHeader (text "Énergie") (text "Pourcentage de l'impact total")


viewProcessing : Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewProcessing totalImpact impact definition step =
    step.processing
        |> AnyDict.toList
        |> List.map
            (\( name, process ) ->
                let
                    bar =
                        makeBar totalImpact impact definition name process
                in
                div [ class "card stacked-card" ]
                    [ div [ class "card-header" ] [ text <| Product.processNameToString name ]
                    , viewProcess ratioToStringKg True bar
                    ]
            )
        |> viewHeader (text "Procédé") (text "Pourcentage de l'impact total")


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
    div []
        [ step.transport
            |> AnyDict.toList
            |> List.map
                (\( name, process ) ->
                    let
                        bar =
                            makeBar totalImpact impact definition name process
                    in
                    div [ class "card stacked-card" ]
                        [ div [ class "card-header" ] [ text <| Product.processNameToString name ]
                        , viewProcess (ratioToStringKgKm totalWeight) True bar
                        ]
                )
            |> viewHeader header (text "Pourcentage de l'impact total")
        ]


viewWaste : Float -> Impact.Trigram -> Impact.Definition -> Product.Step -> Html Msg
viewWaste totalImpact impact definition step =
    step.wasteTreatment
        |> AnyDict.toList
        |> List.map
            (\( name, process ) ->
                let
                    bar =
                        makeBar totalImpact impact definition name process
                in
                div [ class "card stacked-card" ]
                    [ div [ class "card-header" ] [ text <| Product.processNameToString name ]
                    , viewProcess ratioToStringKg True bar
                    ]
            )
        |> viewHeader (text "Déchets") (text "Pourcentage de l'impact total")
