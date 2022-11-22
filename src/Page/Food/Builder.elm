module Page.Food.Builder exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Food.Db as FoodDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Recipe as Recipe exposing (Recipe)
import Data.Impact as Impact exposing (Impacts)
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Json.Encode as Encode
import Mass exposing (Mass)
import Ports
import RemoteData exposing (WebData)
import Request.Common
import Request.Food.Db as RequestDb
import Result.Extra as RE
import Route
import Views.Alert as Alert
import Views.Component.MassInput as MassInput
import Views.Component.Summary as SummaryComp
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Spinner as Spinner



---- Query


type Variant
    = Default
    | Organic


type alias IngredientQuery =
    { name : Ingredient.Name
    , mass : Mass
    , variant : Variant
    }


emptyIngredientQuery : IngredientQuery
emptyIngredientQuery =
    { name = Ingredient.nameFromString ""
    , mass = Mass.grams 100
    , variant = Default
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe Recipe.TransformQuery
    , packaging : List Recipe.PackagingQuery
    }


emptyQuery : Query
emptyQuery =
    { ingredients = []
    , transform = Nothing
    , packaging = []
    }


carrotCake : Query
carrotCake =
    { ingredients =
        [ { name = Ingredient.nameFromString "oeuf"
          , mass = Mass.grams 120
          , variant = Default
          }
        , { name = Ingredient.nameFromString "blé tendre"
          , mass = Mass.grams 140
          , variant = Default
          }
        , { name = Ingredient.nameFromString "lait"
          , mass = Mass.grams 60
          , variant = Default
          }
        , { name = Ingredient.nameFromString "carotte"
          , mass = Mass.grams 225
          , variant = Default
          }
        ]
    , transform =
        Just
            { -- Cooking, industrial, 1kg of cooked product/ FR U
              code = Process.codeFromString "aded2490573207ec7ad5a3813978f6a4"
            , mass = Mass.grams 545
            }
    , packaging =
        [ { -- Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent
            code = Process.codeFromString "23b2754e5943bc77916f8f871edc53b6"
          , mass = Mass.grams 105
          }
        ]
    }


updateIngredient : Ingredient.Name -> IngredientQuery -> List IngredientQuery -> List IngredientQuery
updateIngredient oldIngredientName newIngredient ingredients =
    ingredients
        |> List.map
            (\ingredient ->
                if ingredient.name == oldIngredientName then
                    newIngredient

                else
                    ingredient
            )



---- Results


type alias RecipeIngredient =
    { ingredient : Ingredient
    , mass : Mass
    , variant : Variant
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Recipe.Transform
    , packaging : List Recipe.Packaging
    }


type alias Results =
    { impacts : Impacts
    , recipe :
        { ingredients : Impacts
        , transform : Impacts
        }
    , packaging : Impacts
    }


compute : FoodDb.Db -> Query -> Result String ( Recipe, Results )
compute db =
    fromQuery db
        >> Result.map
            (\({ ingredients, transform, packaging } as recipe) ->
                let
                    ingredientsImpacts =
                        ingredients
                            |> List.map computeIngredientImpacts

                    transformImpacts =
                        transform
                            |> Maybe.map computeProcessImpacts
                            |> Maybe.withDefault Impact.noImpacts

                    packagingImpacts =
                        packaging
                            |> List.map computeProcessImpacts
                in
                ( recipe
                , { impacts =
                        [ ingredientsImpacts
                        , List.singleton transformImpacts
                        , packagingImpacts
                        ]
                            |> List.concat
                            |> Impact.sumImpacts db.impacts
                  , recipe =
                        { ingredients = Impact.sumImpacts db.impacts ingredientsImpacts
                        , transform = transformImpacts
                        }
                  , packaging = Impact.sumImpacts db.impacts packagingImpacts
                  }
                )
            )


computeImpact : Mass -> Impact.Trigram -> Unit.Impact -> Unit.Impact
computeImpact mass _ impact =
    impact
        |> Unit.impactToFloat
        |> (*) (Mass.inKilograms mass)
        |> Unit.impact


computeProcessImpacts : { a | process : Process, mass : Mass } -> Impacts
computeProcessImpacts item =
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)


computeIngredientImpacts : RecipeIngredient -> Impacts
computeIngredientImpacts ingredient =
    let
        process =
            case ingredient.variant of
                Default ->
                    ingredient.ingredient.default

                Organic ->
                    ingredient.ingredient.variants.organic
                        |> Maybe.withDefault ingredient.ingredient.default
    in
    process.impacts
        |> Impact.mapImpacts (computeImpact ingredient.mass)


encodeQuery : Query -> Encode.Value
encodeQuery q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "transform", q.transform |> Maybe.map Recipe.encodeTransform |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list Recipe.encodePackaging q.packaging )
        ]


fromQuery : FoodDb.Db -> Query -> Result String Recipe
fromQuery foodDb query =
    Result.map3 Recipe
        (ingredientListFromQuery foodDb query)
        (Recipe.transformFromQuery foodDb query)
        (Recipe.packagingListFromQuery foodDb query)


ingredientListFromQuery : FoodDb.Db -> Query -> Result String (List RecipeIngredient)
ingredientListFromQuery foodDb query =
    query.ingredients
        |> RE.combineMap (ingredientFromQuery foodDb)


ingredientFromQuery : FoodDb.Db -> IngredientQuery -> Result String RecipeIngredient
ingredientFromQuery { ingredients } ingredientQuery =
    Result.map3 RecipeIngredient
        (Ingredient.findByName ingredients ingredientQuery.name)
        (Ok ingredientQuery.mass)
        (Ok ingredientQuery.variant)


variantToString : Variant -> String
variantToString variant =
    case variant of
        Default ->
            "default"

        Organic ->
            "organic"


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient i =
    Encode.object
        [ ( "name", i.name |> Ingredient.nameToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms i.mass) )
        , ( "variant", variantToString i.variant |> Encode.string )
        ]


serializeQuery : Query -> String
serializeQuery =
    encodeQuery >> Encode.encode 2



----


type alias Model =
    { dbState : WebData FoodDb.Db
    , impact : Impact.Trigram
    , query : Query
    , selectedPackaging : Maybe SelectedProcess
    , selectedTransform : Maybe SelectedProcess
    }


type alias SelectedProcess =
    { code : Process.Code
    , mass : Mass
    }


type Msg
    = AddIngredient
    | AddPackaging SelectedProcess
    | DbLoaded (WebData FoodDb.Db)
    | DeleteIngredient IngredientQuery
    | DeletePackaging Process.Code
    | LoadQuery Query
    | NoOp
    | ResetTransform
    | SelectPackaging (Maybe SelectedProcess)
    | SelectTransform (Maybe SelectedProcess)
    | SetTransform SelectedProcess
    | SwitchImpact Impact.Trigram
    | UpdateIngredient Ingredient.Name IngredientQuery
    | UpdatePackagingMass Process.Code (Maybe Mass)
    | UpdateTransformMass (Maybe Mass)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    let
        model =
            { dbState = RemoteData.Loading
            , query = emptyQuery
            , impact = Impact.defaultTrigram
            , selectedTransform = Nothing
            , selectedPackaging = Nothing
            }
    in
    if FoodDb.isEmpty session.foodDb then
        ( model
        , session
        , Cmd.batch
            [ Ports.scrollTo { x = 0, y = 0 }
            , RequestDb.loadDb session DbLoaded
            ]
        )

    else
        ( { model
            | query = carrotCake
            , dbState = RemoteData.Success session.foodDb
          }
        , session
        , Ports.scrollTo { x = 0, y = 0 }
        )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        AddIngredient ->
            let
                query =
                    model.query
            in
            ( { model
                | query =
                    { query
                        | ingredients =
                            query.ingredients
                                ++ [ emptyIngredientQuery
                                   ]
                    }
              }
            , session
            , Cmd.none
            )

        AddPackaging { mass, code } ->
            ( { model
                | query =
                    model.query |> Recipe.addPackaging mass code
                , selectedPackaging = Nothing
              }
            , session
            , Cmd.none
            )

        DbLoaded dbState ->
            ( { model
                | dbState = dbState
                , query = carrotCake
              }
            , case dbState of
                RemoteData.Success foodDb ->
                    { session | foodDb = foodDb }

                _ ->
                    session
            , Cmd.none
            )

        DeleteIngredient ingredientQuery ->
            let
                query =
                    model.query
            in
            ( { model
                | query =
                    { query
                        | ingredients =
                            query.ingredients
                                |> List.filter ((/=) ingredientQuery)
                    }
              }
            , session
            , Cmd.none
            )

        DeletePackaging code ->
            ( { model
                | query =
                    model.query
                        |> Recipe.deletePackaging code
              }
            , session
            , Cmd.none
            )

        NoOp ->
            ( model, session, Cmd.none )

        LoadQuery query ->
            ( { model | query = query }, session, Cmd.none )

        ResetTransform ->
            ( { model
                | query =
                    model.query
                        |> Recipe.resetTransform
              }
            , session
            , Cmd.none
            )

        SelectPackaging selectedPackaging ->
            ( { model | selectedPackaging = selectedPackaging }, session, Cmd.none )

        SelectTransform selectedTransform ->
            ( { model | selectedTransform = selectedTransform }, session, Cmd.none )

        SetTransform { mass, code } ->
            ( { model
                | query =
                    model.query
                        |> Recipe.setTransform mass code
                , selectedTransform = Nothing
              }
            , session
            , Cmd.none
            )

        SwitchImpact impact ->
            ( { model | impact = impact }, session, Cmd.none )

        UpdateIngredient oldIngredientName newIngredient ->
            let
                query =
                    model.query
            in
            ( { model
                | query =
                    { query
                        | ingredients =
                            query.ingredients
                                |> updateIngredient oldIngredientName newIngredient
                    }
              }
            , session
            , Cmd.none
            )

        UpdatePackagingMass code (Just mass) ->
            ( { model
                | query =
                    model.query
                        |> Recipe.updatePackagingMass mass code
              }
            , session
            , Cmd.none
            )

        UpdatePackagingMass _ Nothing ->
            ( model, session, Cmd.none )

        UpdateTransformMass (Just mass) ->
            ( { model
                | query =
                    model.query
                        |> Recipe.updateTransformMass mass
              }
            , session
            , Cmd.none
            )

        UpdateTransformMass Nothing ->
            ( model, session, Cmd.none )



-- Views


type alias AddProcessConfig msg =
    { category : Process.Category
    , defaultMass : Mass
    , excluded : List Process.Code
    , foodDb : FoodDb.Db
    , kind : String
    , noOp : msg
    , select : Maybe SelectedProcess -> msg
    , selectedProcess : Maybe SelectedProcess
    , submit : SelectedProcess -> msg
    }


addProcessFormView : AddProcessConfig Msg -> Html Msg
addProcessFormView { category, defaultMass, excluded, foodDb, kind, noOp, select, selectedProcess, submit } =
    Html.form
        [ class "list-group list-group-flush border-top-0"
        , onSubmit
            (case selectedProcess of
                Just selected ->
                    submit selected

                Nothing ->
                    noOp
            )
        ]
        [ rowTemplate
            (MassInput.view
                { mass =
                    selectedProcess
                        |> Maybe.map .mass
                        |> Maybe.withDefault defaultMass
                , onChange =
                    \maybeMass ->
                        select
                            (case ( maybeMass, selectedProcess ) of
                                ( Just mass, Just selected ) ->
                                    Just { selected | mass = mass }

                                _ ->
                                    Nothing
                            )
                , disabled = selectedProcess == Nothing
                }
            )
            (foodDb.processes
                |> Process.listByCategory category
                |> List.sortBy Process.getDisplayName
                |> List.filter (\{ code } -> not (List.member code excluded))
                |> processSelectorView kind
                    (Maybe.map .code selectedProcess)
                    (\maybeCode ->
                        case ( selectedProcess, maybeCode ) of
                            ( Just selected, Just code ) ->
                                select (Just { selected | code = code })

                            ( Nothing, Just code ) ->
                                select (Just { code = code, mass = defaultMass })

                            _ ->
                                select Nothing
                    )
            )
            (button
                [ type_ "submit"
                , class "btn btn-sm btn-primary no-outline"
                , title <| "Ajouter " ++ kind
                , disabled <| selectedProcess == Nothing
                ]
                [ Icon.plus ]
            )
        ]


type alias UpdateIngredientConfig =
    { excluded : List Ingredient.Name
    , foodDb : FoodDb.Db
    , ingredient : RecipeIngredient
    }


updateIngredientFormView : UpdateIngredientConfig -> Html Msg
updateIngredientFormView { excluded, foodDb, ingredient } =
    let
        ingredientName =
            ingredient.ingredient.name

        ingredientQuery : IngredientQuery
        ingredientQuery =
            { name = ingredient.ingredient.name
            , mass = ingredient.mass
            , variant = ingredient.variant
            }

        event =
            UpdateIngredient ingredientName
    in
    Html.form
        [ class "list-group list-group-flush border-top-0" ]
        [ rowTemplate
            (MassInput.view
                { mass =
                    ingredient.mass
                , onChange =
                    \maybeMass ->
                        case maybeMass of
                            Just mass ->
                                event { ingredientQuery | mass = mass }

                            _ ->
                                NoOp
                , disabled = False
                }
            )
            (foodDb.ingredients
                |> List.sortBy (.name >> Ingredient.nameToString)
                |> ingredientSelectorView
                    ingredientName
                    excluded
                    (\newIngredient ->
                        event { ingredientQuery | name = newIngredient.name }
                    )
            )
            (span [ class "w-25 d-flex align-items-center gap-2" ]
                [ label [ class "flex-grow-1" ]
                    [ input
                        [ type_ "checkbox"
                        , class "form-check-input no-outline m-1"
                        , attribute "role" "switch"
                        , checked <| ingredient.variant == Organic
                        , onCheck
                            (\checked ->
                                { ingredientQuery
                                    | variant =
                                        if checked then
                                            Organic

                                        else
                                            Default
                                }
                                    |> event
                            )
                        ]
                        []
                    , text "bio"
                    ]
                , button
                    [ type_ "submit"
                    , class "btn btn-sm btn-outline-primary no-outline"
                    , title <| "Supprimer "
                    , onClick <| DeleteIngredient ingredientQuery
                    ]
                    [ Icon.trash ]
                ]
            )
        ]


debugQueryView : FoodDb.Db -> Query -> Html Msg
debugQueryView foodDb query =
    let
        debugView =
            text >> List.singleton >> pre []
    in
    details []
        [ summary [] [ text "Debug" ]
        , div [ class "row" ]
            [ div [ class "col-7" ]
                [ query
                    |> serializeQuery
                    |> debugView
                ]
            , div [ class "col-5" ]
                [ query
                    |> compute foodDb
                    |> Result.map (Tuple.second >> Recipe.encodeResults >> Encode.encode 2)
                    |> Result.withDefault "Error serializing the impacts"
                    |> debugView
                ]
            ]
        ]


errorView : String -> Html Msg
errorView error =
    Alert.simple
        { level = Alert.Danger
        , content = [ text error ]
        , title = Nothing
        , close = Nothing
        }


formatImpact : FoodDb.Db -> Impact.Trigram -> Impact.Impacts -> Html Msg
formatImpact foodDb selectedImpact impacts =
    case Impact.getDefinition selectedImpact foodDb.impacts of
        Ok definition ->
            impacts
                |> Impact.getImpact selectedImpact
                |> Unit.impactToFloat
                |> Format.formatImpactFloat definition 2

        Err error ->
            span [ class "d-flex align-items-center gap-1 bg-white text-danger" ]
                [ Icon.warning
                , text error
                ]


ingredientListView : FoodDb.Db -> Impact.Trigram -> Recipe -> Results -> List (Html Msg)
ingredientListView foodDb selectedImpact recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h6 [ class "mb-0" ] [ text "Ingrédients" ]
        , results.recipe.ingredients
            |> formatImpact foodDb selectedImpact
        ]
    , ul [ class "list-group list-group-flush" ]
        (if List.isEmpty recipe.ingredients then
            [ li [ class "list-group-item" ] [ text "Aucun ingrédient" ] ]

         else
            recipe.ingredients
                |> List.map
                    (\ingredient ->
                        updateIngredientFormView
                            { excluded = recipe.ingredients |> List.map (.ingredient >> .name)
                            , foodDb = foodDb
                            , ingredient = ingredient
                            }
                    )
        )
    ]


packagingListView : FoodDb.Db -> Impact.Trigram -> Maybe SelectedProcess -> Recipe -> Results -> List (Html Msg)
packagingListView foodDb selectedImpact selectedProcess recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h5 [ class "mb-0" ] [ text "Emballage" ]
        , results.packaging
            |> formatImpact foodDb selectedImpact
        ]
    , ul [ class "list-group list-group-flush" ]
        (if List.isEmpty recipe.packaging then
            [ li [ class "list-group-item" ] [ text "Aucun emballage" ] ]

         else
            recipe.packaging
                |> List.map
                    (\({ mass, process } as packaging) ->
                        rowTemplate
                            (MassInput.view
                                { mass = mass
                                , onChange = UpdatePackagingMass process.code
                                , disabled = False
                                }
                            )
                            (small [] [ text <| Process.getDisplayName process ])
                            (div [ class "d-flex flex-nowrap align-items-center gap-2 fs-7 text-nowrap" ]
                                [ Recipe.computeProcessImpacts packaging
                                    |> formatImpact foodDb selectedImpact
                                , button
                                    [ type_ "button"
                                    , class "btn btn-sm btn-outline-primary no-outline"
                                    , title "Supprimer"
                                    , onClick (DeletePackaging process.code)
                                    ]
                                    [ Icon.trash ]
                                ]
                            )
                    )
        )
    , addProcessFormView
        { category = Process.Packaging
        , defaultMass = Mass.grams 100
        , excluded = List.map (.process >> .code) recipe.packaging
        , foodDb = foodDb
        , kind = "un emballage"
        , noOp = NoOp
        , select = SelectPackaging
        , selectedProcess = selectedProcess
        , submit = AddPackaging
        }
    ]


mainView : FoodDb.Db -> Model -> Html Msg
mainView foodDb model =
    let
        computed =
            compute foodDb model.query
    in
    div [ class "row gap-3 gap-lg-0" ]
        [ div [ class "col-lg-4 order-lg-2 d-flex flex-column gap-3" ]
            [ case computed of
                Ok ( _, results ) ->
                    sidebarView foodDb model results

                Err error ->
                    errorView error
            ]
        , div [ class "col-lg-8 order-lg-1 d-flex flex-column gap-3" ]
            [ menuView model.query
            , case computed of
                Ok ( recipe, results ) ->
                    stepListView foodDb model recipe results

                Err error ->
                    errorView error
            , debugQueryView foodDb model.query
            ]
        ]


menuView : Query -> Html Msg
menuView query =
    div [ class "d-flex gap-2" ]
        [ button
            [ class "btn btn-outline-primary"
            , classList [ ( "active", query == carrotCake ) ]
            , onClick (LoadQuery carrotCake)
            ]
            [ text "Carrot Cake" ]
        , button
            [ class "btn btn-outline-primary"
            , classList [ ( "active", query == emptyQuery ) ]
            , onClick (LoadQuery emptyQuery)
            ]
            [ text "Créer une nouvelle recette" ]
        ]


processSelectorView : String -> Maybe Process.Code -> (Maybe Process.Code -> msg) -> List Process -> Html msg
processSelectorView kind selectedCode event =
    List.map
        (\process ->
            let
                label =
                    Process.getDisplayName process
            in
            ( label
            , option
                [ selected <| selectedCode == Just process.code
                , value <| Process.codeToString process.code
                ]
                [ text label ]
            )
        )
        >> List.sortBy Tuple.first
        >> (++)
            [ ( ""
              , option [ Attr.selected <| selectedCode == Nothing, value "" ]
                    [ text <| "-- Sélectionnez " ++ kind ++ " et cliquez sur le bouton + pour l'ajouter" ]
              )
            ]
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        >> Keyed.node "select"
            [ class "form-select form-select-sm"
            , onInput
                (\str ->
                    event
                        (if str == "" then
                            Nothing

                         else
                            Just (Process.codeFromString str)
                        )
                )
            ]


ingredientSelectorView : Ingredient.Name -> List Ingredient.Name -> (Ingredient -> msg) -> List Ingredient -> Html msg
ingredientSelectorView selectedIngredient excluded event ingredients =
    ingredients
        |> List.map
            (\ingredient ->
                let
                    label =
                        Ingredient.nameToString ingredient.name
                in
                ( label
                , option
                    [ selected <| selectedIngredient == ingredient.name
                    , disabled <| List.member ingredient.name excluded
                    , value <| label
                    ]
                    [ text label ]
                )
            )
        |> List.sortBy Tuple.first
        |> (++)
            [ ( ""
              , option [ Attr.selected <| selectedIngredient == Ingredient.nameFromString "", value "" ]
                    [ text <| "-- Sélectionnez un ingrédient" ]
              )
            ]
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        |> Keyed.node "select"
            [ class "form-select form-select-sm"
            , onInput
                (\ingredientName ->
                    let
                        newIngredient =
                            Ingredient.nameFromString ingredientName
                                |> Ingredient.findByName ingredients
                                |> Result.withDefault Ingredient.empty
                    in
                    event newIngredient
                )
            ]


rowTemplate : Html Msg -> Html Msg -> Html Msg -> Html Msg
rowTemplate input content action =
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ span [ class "MassInputWrapper flex-shrink-1" ] [ input ]
        , span [ class "w-100" ] [ content ]
        , action
        ]


sidebarView : FoodDb.Db -> Model -> Results -> Html Msg
sidebarView foodDb model results =
    div
        [ class "d-flex flex-column gap-3 mb-3 sticky-md-top"
        , style "top" "7px"
        ]
        [ ImpactView.impactSelector
            { impacts = foodDb.impacts
            , selectedImpact = model.impact
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
                    [ div [ class "display-4 lh-1 text-center text-nowrap" ]
                        [ results.impacts
                            |> formatImpact foodDb model.impact
                        ]
                    , small [ class "d-flex align-items-center gap-1" ]
                        [ Icon.warning
                        , text "Attention, ces résultats sont partiels"
                        ]
                    ]
                ]
            , footer = []
            }
        , stepResultsView foodDb model results
        , a [ class "btn btn-primary", Route.href Route.FoodExplore ]
            [ text "Explorateur de recettes" ]
        ]


stepListView : FoodDb.Db -> Model -> Recipe -> Results -> Html Msg
stepListView foodDb { impact, selectedPackaging, selectedTransform } recipe results =
    div [ class "d-flex flex-column gap-3" ]
        [ div [ class "card" ]
            (div [ class "card-header d-flex align-items-center justify-content-between" ]
                [ h5 [ class "mb-0" ] [ text "Recette" ]
                , Recipe.recipeStepImpacts foodDb results
                    |> formatImpact foodDb impact
                    |> List.singleton
                    |> span [ class "fw-bold" ]
                ]
                :: List.concat
                    [ ingredientListView foodDb impact recipe results
                    , transformView foodDb impact selectedTransform recipe results
                    ]
            )
        , div [ class "card" ]
            (packagingListView foodDb impact selectedPackaging recipe results)
        ]


stepResultsView : FoodDb.Db -> Model -> Results -> Html Msg
stepResultsView foodDb model results =
    let
        toFloat =
            Impact.getImpact model.impact >> Unit.impactToFloat

        stepsData =
            [ { label = "Recette"
              , impact = toFloat <| Recipe.recipeStepImpacts foodDb results
              }
            , { label = "Emballage"
              , impact = toFloat results.packaging
              }
            ]

        totalImpact =
            toFloat results.impacts
    in
    div [ class "card fs-7" ]
        [ stepsData
            |> List.map
                (\{ label, impact } ->
                    let
                        percent =
                            if totalImpact /= 0 then
                                impact / totalImpact * 100

                            else
                                0
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


transformView : FoodDb.Db -> Impact.Trigram -> Maybe SelectedProcess -> Recipe -> Results -> List (Html Msg)
transformView foodDb selectedImpact selectedProcess recipe results =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h6 [ class "mb-0" ] [ text "Transformation" ]
        , results.recipe.transform
            |> formatImpact foodDb selectedImpact
        ]
    , case recipe.transform of
        Just ({ process, mass } as transform) ->
            ul [ class "list-group list-group-flush border-top-0" ]
                [ rowTemplate
                    (MassInput.view
                        { mass = mass
                        , onChange = UpdateTransformMass
                        , disabled = False
                        }
                    )
                    (small [] [ text <| Process.getDisplayName process ])
                    (div [ class "d-flex flex-nowrap align-items-center gap-2 fs-7 text-nowrap" ]
                        [ Recipe.computeProcessImpacts transform
                            |> formatImpact foodDb selectedImpact
                        , button
                            [ type_ "button"
                            , class "btn btn-sm btn-outline-primary no-outline"
                            , title "Supprimer"
                            , onClick ResetTransform
                            ]
                            [ Icon.trash ]
                        ]
                    )
                ]

        Nothing ->
            addProcessFormView
                { category = Process.Transform
                , defaultMass = Recipe.sumMasses recipe.ingredients
                , excluded =
                    recipe.transform
                        |> Maybe.map (.process >> .code >> List.singleton)
                        |> Maybe.withDefault []
                , foodDb = foodDb
                , kind = "une transformation"
                , noOp = NoOp
                , select = SelectTransform
                , selectedProcess = selectedProcess
                , submit = SetTransform
                }
    , div [ class "card-body d-flex align-items-center gap-1 text-muted py-2" ]
        [ Icon.info
        , small [] [ text "Entrez la masse totale mobilisée par le procédé de transformation sélectionné" ]
        ]
    ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Constructeur de recette"
    , [ Container.centered [ class "pb-3" ]
            [ case model.dbState of
                RemoteData.Success foodDb ->
                    mainView foodDb model

                RemoteData.Loading ->
                    Spinner.view

                RemoteData.Failure error ->
                    error
                        |> Request.Common.errorToString
                        |> text
                        |> List.singleton
                        |> div [ class "alert alert-danger" ]

                RemoteData.NotAsked ->
                    text "Shouldn't happen"
            ]
      ]
    )
