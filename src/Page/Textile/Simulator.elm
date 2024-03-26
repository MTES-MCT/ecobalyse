module Page.Textile.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Array
import Autocomplete exposing (Autocomplete)
import Browser.Dom as Dom
import Browser.Events
import Browser.Navigation as Navigation
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country as Country
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Split exposing (Split)
import Data.Textile.Db as TextileDb
import Data.Textile.DyeingMedium exposing (DyeingMedium)
import Data.Textile.Economics as Economics
import Data.Textile.ExampleProduct as ExampleProduct exposing (ExampleProduct)
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning exposing (Spinning)
import Data.Textile.Printing exposing (Printing)
import Data.Textile.Product as Product
import Data.Textile.Query as Query exposing (MaterialQuery, Query)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.Step.Label exposing (Label)
import Data.Unit as Unit
import Duration exposing (Duration)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Ports
import Route
import Static.Db as Db exposing (Db)
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.AutocompleteSelector as AutocompleteSelector
import Views.Bookmark as BookmarkView
import Views.Button as Button
import Views.Comparator as ComparatorView
import Views.Component.DownArrow as DownArrow
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Modal as ModalView
import Views.Sidebar as SidebarView
import Views.Textile.Step as StepView


type alias Model =
    { simulator : Result String Simulator
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , initialQuery : Query
    , detailedStep : Maybe Int
    , impact : Definition
    , modal : Modal
    , activeImpactsTab : ImpactTabs.Tab
    }


type Modal
    = NoModal
    | ComparatorModal
    | AddMaterialModal (Maybe Inputs.MaterialInput) (Autocomplete Material)
    | SelectExampleModal (Autocomplete Query)
    | SelectProductModal (Autocomplete Product.Id)


type Msg
    = AddMaterial Material
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteMaterial (Autocomplete.Msg Material)
    | OnAutocompleteProduct (Autocomplete.Msg Product.Id)
    | OnAutocompleteSelect
    | OnStepClick String
    | OpenComparator
    | RemoveMaterial Material.Id
    | Reset
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | ToggleFading Bool
    | ToggleStep Label
    | ToggleStepDetails Int
    | UpdateAirTransportRatio (Maybe Split)
    | UpdateBookmarkName String
    | UpdateBusiness (Result String Economics.Business)
    | UpdateDyeingMedium DyeingMedium
    | UpdateEcotoxWeighting (Maybe Unit.Ratio)
    | UpdateFabricProcess Fabric
    | UpdateMakingComplexity MakingComplexity
    | UpdateMakingWaste (Maybe Split)
    | UpdateMakingDeadStock (Maybe Split)
    | UpdateMarketingDuration (Maybe Duration)
    | UpdateMassInput String
    | UpdateMaterial MaterialQuery MaterialQuery
    | UpdateMaterialSpinning Material Spinning
    | UpdateNumberOfReferences (Maybe Int)
    | UpdatePrice (Maybe Economics.Price)
    | UpdatePrinting (Maybe Printing)
    | UpdateStepCountry Label Country.Code
    | UpdateSurfaceMass (Maybe Unit.SurfaceMass)
    | UpdateTraceability Bool
    | UpdateYarnSize (Maybe Unit.YarnSize)


init : Definition.Trigram -> Maybe Query -> Session -> ( Model, Session, Cmd Msg )
init trigram maybeUrlQuery session =
    let
        initialQuery =
            -- If we received a serialized query from the URL, use it
            -- Otherwise, fallback to use session query
            maybeUrlQuery
                |> Maybe.withDefault session.queries.textile

        simulator =
            initialQuery
                |> Simulator.compute session.db
    in
    ( { simulator = simulator
      , bookmarkName = initialQuery |> findExistingBookmarkName session
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType =
            if Session.isAuthenticated session then
                ComparatorView.Subscores

            else
                ComparatorView.Steps
      , initialQuery = initialQuery
      , detailedStep = Nothing
      , impact = Definition.get trigram session.db.definitions
      , modal = NoModal
      , activeImpactsTab = ImpactTabs.StepImpactsTab
      }
    , session
        |> Session.updateTextileQuery initialQuery
        |> (case simulator of
                Err error ->
                    Session.notifyError "Erreur de récupération des paramètres d'entrée" error

                Ok _ ->
                    identity
           )
    , case maybeUrlQuery of
        -- If we don't have an URL query, we may be coming from another app page, so we should
        -- reposition the viewport at the top.
        Nothing ->
            Ports.scrollTo { x = 0, y = 0 }

        -- If we do have an URL query, we either come from a bookmark, a saved simulation click or
        -- we're tweaking params for the current simulation: we shouldn't reposition the viewport.
        Just _ ->
            Cmd.none
    )


findExistingBookmarkName : Session -> Query -> String
findExistingBookmarkName { db, store } query =
    store.bookmarks
        |> Bookmark.findByTextileQuery query
        |> Maybe.map .name
        |> Maybe.withDefault
            (query
                |> Inputs.fromQuery db
                |> Result.map Inputs.toString
                |> Result.withDefault ""
            )


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, commands ) =
    ( { model
        | simulator = query |> Simulator.compute session.db
        , bookmarkName = query |> findExistingBookmarkName session
      }
    , session |> Session.updateTextileQuery query
    , commands
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ queries, navKey } as session) msg model =
    let
        query =
            queries.textile
    in
    case msg of
        AddMaterial material ->
            update session (SetModal NoModal) model
                |> updateQuery (Query.addMaterial material query)

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        DeleteBookmark bookmark ->
            ( model
            , session |> Session.deleteBookmark bookmark
            , Cmd.none
            )

        NoOp ->
            ( model, session, Cmd.none )

        OpenComparator ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        OnAutocompleteExample autocompleteMsg ->
            case model.modal of
                SelectExampleModal autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = SelectExampleModal newAutocompleteState }
                    , session
                    , Cmd.map OnAutocompleteExample autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteProduct autocompleteMsg ->
            case model.modal of
                SelectProductModal autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = SelectProductModal newAutocompleteState }
                    , session
                    , Cmd.map OnAutocompleteProduct autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteMaterial autocompleteMsg ->
            case model.modal of
                AddMaterialModal maybeOldMaterial autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = AddMaterialModal maybeOldMaterial newAutocompleteState }
                    , session
                    , Cmd.map OnAutocompleteMaterial autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteSelect ->
            case model.modal of
                AddMaterialModal maybeOldMaterial autocompleteState ->
                    updateMaterial query model session maybeOldMaterial autocompleteState

                SelectExampleModal autocompleteState ->
                    ( model, session, Cmd.none )
                        |> selectExample autocompleteState

                SelectProductModal autocompleteState ->
                    ( model, session, Cmd.none )
                        |> selectProduct autocompleteState

                _ ->
                    ( model, session, Cmd.none )

        OnStepClick stepId ->
            ( model
            , session
            , Ports.scrollIntoView stepId
            )

        RemoveMaterial materialId ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.removeMaterial materialId query)

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery model.initialQuery

        SaveBookmark ->
            ( model
            , session
            , Time.now
                |> Task.perform
                    (SaveBookmarkWithTime model.bookmarkName
                        (Bookmark.Textile query)
                    )
            )

        SaveBookmarkWithTime name foodQuery now ->
            ( model
            , session
                |> Session.saveBookmark
                    { name = String.trim name
                    , query = foodQuery
                    , created = now
                    }
            , Cmd.none
            )

        SelectAllBookmarks ->
            ( model, Session.selectAllBookmarks session, Cmd.none )

        SelectNoBookmarks ->
            ( model, Session.selectNoBookmarks session, Cmd.none )

        SetModal NoModal ->
            ( { model | modal = NoModal }
            , session
            , commandsForNoModal model.modal
            )

        SetModal ComparatorModal ->
            ( { model | modal = ComparatorModal }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

        SetModal (AddMaterialModal maybeOldMaterial autocomplete) ->
            ( { model | modal = AddMaterialModal maybeOldMaterial autocomplete }
            , session
            , Cmd.batch
                [ Ports.addBodyClass "prevent-scrolling"
                , Dom.focus "element-search"
                    |> Task.attempt (always NoOp)
                ]
            )

        SetModal (SelectExampleModal autocomplete) ->
            ( { model | modal = SelectExampleModal autocomplete }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

        SetModal (SelectProductModal autocomplete) ->
            ( { model | modal = SelectProductModal autocomplete }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

        SwitchBookmarksTab bookmarkTab ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        SwitchComparisonType displayChoice ->
            ( { model | comparisonType = displayChoice }, session, Cmd.none )

        SwitchImpact (Ok trigram) ->
            ( model
            , session
            , Just query
                |> Route.TextileSimulator trigram
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchImpact (Err error) ->
            ( model
            , session |> Session.notifyError "Erreur de sélection d'impact: " error
            , Cmd.none
            )

        SwitchImpactsTab impactsTab ->
            ( { model | activeImpactsTab = impactsTab }
            , session
            , Cmd.none
            )

        ToggleComparedSimulation bookmark checked ->
            ( model
            , session |> Session.toggleComparedSimulation bookmark checked
            , Cmd.none
            )

        ToggleFading fading ->
            ( model, session, Cmd.none )
                |> updateQuery { query | fading = Just fading }

        ToggleStep label ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.toggleStep label query)

        ToggleStepDetails index ->
            ( { model
                | detailedStep = toggleStepDetails index model.detailedStep
              }
            , session
            , Cmd.none
            )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        UpdateBookmarkName newName ->
            ( { model | bookmarkName = newName }, session, Cmd.none )

        UpdateBusiness (Ok business) ->
            ( model, session, Cmd.none )
                |> updateQuery { query | business = Just business }

        UpdateBusiness (Err error) ->
            ( model, session |> Session.notifyError "Erreur de type d'entreprise" error, Cmd.none )

        UpdateDyeingMedium dyeingMedium ->
            ( model, session, Cmd.none )
                |> updateQuery { query | dyeingMedium = Just dyeingMedium }

        UpdateEcotoxWeighting (Just ratio) ->
            let
                db =
                    session.db
            in
            ( model, { session | db = Db.updateEcotoxWeighting db ratio }, Cmd.none )
                -- triggers recompute
                |> updateQuery query

        UpdateEcotoxWeighting Nothing ->
            ( model, session, Cmd.none )

        UpdateFabricProcess fabricProcess ->
            ( model, session, Cmd.none )
                |> updateQuery
                    { query
                        | fabricProcess = fabricProcess
                        , makingWaste =
                            model.simulator
                                |> Result.map
                                    (\simulator ->
                                        Fabric.getMakingWaste simulator.inputs.product.making.pcrWaste fabricProcess
                                    )
                                |> Result.toMaybe
                        , makingComplexity =
                            model.simulator
                                |> Result.map
                                    (\simulator ->
                                        Fabric.getMakingComplexity simulator.inputs.product.making.complexity fabricProcess
                                    )
                                |> Result.toMaybe
                    }

        UpdateMakingComplexity makingComplexity ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingComplexity = Just makingComplexity }

        UpdateMakingWaste makingWaste ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingWaste = makingWaste }

        UpdateMakingDeadStock makingDeadStock ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingDeadStock = makingDeadStock }

        UpdateMarketingDuration marketingDuration ->
            ( model, session, Cmd.none )
                |> updateQuery { query | marketingDuration = marketingDuration }

        UpdateMassInput massInput ->
            case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                Just mass ->
                    ( model, session, Cmd.none )
                        |> updateQuery { query | mass = mass }

                Nothing ->
                    ( model, session, Cmd.none )

        UpdateMaterial oldMaterial newMaterial ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateMaterial oldMaterial.id newMaterial query)

        UpdateMaterialSpinning material spinning ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateMaterialSpinning material spinning query)

        UpdateNumberOfReferences numberOfReferences ->
            ( model, session, Cmd.none )
                |> updateQuery { query | numberOfReferences = numberOfReferences }

        UpdatePrice price ->
            ( model, session, Cmd.none )
                |> updateQuery { query | price = price }

        UpdatePrinting printing ->
            ( model, session, Cmd.none )
                |> updateQuery { query | printing = printing }

        UpdateStepCountry label code ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateStepCountry label code query)

        UpdateSurfaceMass surfaceMass ->
            ( model, session, Cmd.none )
                |> updateQuery { query | surfaceMass = surfaceMass }

        UpdateTraceability traceability ->
            ( model, session, Cmd.none )
                |> updateQuery { query | traceability = Just traceability }

        UpdateYarnSize yarnSize ->
            ( model, session, Cmd.none )
                |> updateQuery { query | yarnSize = yarnSize }


toggleStepDetails : Int -> Maybe Int -> Maybe Int
toggleStepDetails index detailedStep =
    detailedStep
        |> Maybe.map
            (\current ->
                if index == current then
                    Nothing

                else
                    Just index
            )
        |> Maybe.withDefault (Just index)


commandsForNoModal : Modal -> Cmd Msg
commandsForNoModal modal =
    case modal of
        AddMaterialModal maybeOldMaterial _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus
                    -- This whole "node to focus" management is happening as a fallback
                    -- if the modal was closed without choosing anything.
                    -- If anything has been chosen, then the focus will be done in `OnAutocompleteSelect`
                    -- and overload any focus being done here.
                    (maybeOldMaterial
                        |> Maybe.map (.material >> .id >> Material.idToString >> (++) "selector-")
                        |> Maybe.withDefault "add-new-element"
                    )
                    |> Task.attempt (always NoOp)
                ]

        SelectExampleModal _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus "selector-example"
                    |> Task.attempt (always NoOp)
                ]

        SelectProductModal _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus "selector-product"
                    |> Task.attempt (always NoOp)
                ]

        _ ->
            Ports.removeBodyClass "prevent-scrolling"


updateExistingMaterial : Query -> Model -> Session -> Inputs.MaterialInput -> Material -> ( Model, Session, Cmd Msg )
updateExistingMaterial query model session oldMaterial newMaterial =
    let
        materialQuery : MaterialQuery
        materialQuery =
            { id = newMaterial.id
            , share = oldMaterial.share
            , spinning = Nothing
            , country = Nothing
            }
    in
    model
        |> update session (SetModal NoModal)
        |> updateQuery (Query.updateMaterial oldMaterial.material.id materialQuery query)
        |> focusNode ("selector-" ++ Material.idToString newMaterial.id)


updateMaterial : Query -> Model -> Session -> Maybe Inputs.MaterialInput -> Autocomplete Material -> ( Model, Session, Cmd Msg )
updateMaterial query model session maybeOldMaterial autocompleteState =
    let
        maybeSelectedValue =
            Autocomplete.selectedValue autocompleteState
    in
    Maybe.map2
        (updateExistingMaterial query model session)
        maybeOldMaterial
        maybeSelectedValue
        |> Maybe.withDefault
            -- Add a new Material
            (model
                |> update session (SetModal NoModal)
                |> selectMaterial autocompleteState
                |> focusNode
                    (maybeSelectedValue
                        |> Maybe.map (\selectedValue -> "selector-" ++ Material.idToString selectedValue.id)
                        |> Maybe.withDefault "add-new-element"
                    )
            )


focusNode : String -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
focusNode node ( model, session, commands ) =
    ( model
    , session
    , Cmd.batch
        [ commands
        , Dom.focus node
            |> Task.attempt (always NoOp)
        ]
    )


selectExample : Autocomplete Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectExample autocompleteState ( model, session, _ ) =
    let
        example =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Query.default
    in
    update session (SetModal NoModal) { model | initialQuery = example }
        |> updateQuery example


selectProduct : Autocomplete Product.Id -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectProduct autocompleteState ( model, session, _ ) =
    let
        product =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Query.default.product

        currentQuery =
            session.queries.textile

        updatedQuery =
            { currentQuery | product = product }
    in
    update session (SetModal NoModal) model
        |> updateQuery updatedQuery


selectMaterial : Autocomplete Material -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectMaterial autocompleteState ( model, session, _ ) =
    let
        material =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.map Just
                |> Maybe.withDefault (List.head (Autocomplete.choices autocompleteState))

        msg =
            material
                |> Maybe.map AddMaterial
                |> Maybe.withDefault NoOp
    in
    update session msg model


exampleProductField : List ExampleProduct -> Query -> Html Msg
exampleProductField exampleProducts query =
    let
        autocompleteState =
            exampleProducts
                |> List.map .query
                |> AutocompleteSelector.init (ExampleProduct.toName exampleProducts)
    in
    div [ class "d-flex flex-column" ]
        [ label [ for "selector-example", class "form-label fw-bold text-truncate" ]
            [ text "Exemples" ]
        , div [ class "d-flex" ]
            [ button
                [ class "form-select ElementSelector text-start"
                , id "selector-example"
                , title "Les simulations proposées ici constituent des exemples. Elles doivent être adaptées pour chaque produit modélisé"
                , onClick (SetModal (SelectExampleModal autocompleteState))
                ]
                [ text <| ExampleProduct.toName exampleProducts query ]
            , span [ class "input-group-text" ]
                [ a
                    [ class "text-secondary text-decoration-none p-0"
                    , href (Gitbook.publicUrlFromPath Gitbook.TextileExamples)
                    , target "_blank"
                    ]
                    [ Icon.info ]
                ]
            ]
        ]


productCategoryField : TextileDb.Db -> Query -> Html Msg
productCategoryField { products } query =
    let
        nameFromProductId default id =
            Product.findById id products
                |> Result.map .name
                |> Result.withDefault default

        autocompleteState =
            AutocompleteSelector.init (nameFromProductId "") (List.map .id products)
    in
    div [ class "row align-items-center g-2" ]
        [ label
            [ for "selector-product"
            , class "col-sm-4 col-form-label text-truncate"
            ]
            [ text "Catégorie" ]
        , button
            [ class "col-sm-8 flex-fill form-select ElementSelector text-start w-auto"
            , id "selector-product"
            , onClick (SetModal (SelectProductModal autocompleteState))
            ]
            [ query.product
                |> nameFromProductId (Product.idToString query.product)
                |> text
            ]
        ]


numberOfReferencesField : Int -> Html Msg
numberOfReferencesField numberOfReferences =
    div [ class "row align-items-center g-2" ]
        [ label
            [ for "number-of-references"
            , class "col-sm-7 col-form-label text-truncate"
            ]
            [ text "Nombre de références" ]
        , div [ class "col-sm-5" ]
            [ input
                [ type_ "number"
                , id "number-of-references"
                , class "form-control"

                -- WARNING: be careful when reordering attributes: for obscure reasons,
                -- the `value` one MUST be set AFTER the `step` one.
                , Attr.min <| String.fromInt <| Economics.minNumberOfReferences
                , Attr.max <| String.fromInt <| Economics.maxNumberOfReferences
                , step "100"
                , value (String.fromInt numberOfReferences)
                , onInput (String.toInt >> UpdateNumberOfReferences)
                ]
                []
            ]
        ]


productPriceField : Economics.Price -> Html Msg
productPriceField productPrice =
    div [ class "row align-items-center g-2" ]
        [ label
            [ for "product-price"
            , class "col-sm-4 col-form-label text-truncate"
            ]
            [ text "Prix neuf" ]
        , div [ class "col-sm-8" ]
            [ div [ class "input-group" ]
                [ input
                    [ type_ "number"
                    , id "product-price"
                    , class "form-control"
                    , Attr.min <| String.fromFloat <| Economics.priceToFloat <| Economics.minPrice
                    , Attr.max <| String.fromFloat <| Economics.priceToFloat <| Economics.maxPrice
                    , productPrice |> Economics.priceToFloat |> String.fromFloat |> value
                    , onInput (String.toFloat >> Maybe.map Economics.priceFromFloat >> UpdatePrice)
                    ]
                    []
                , span [ class "input-group-text" ] [ text "€" ]
                ]
            ]
        ]


marketingDurationField : Duration -> Html Msg
marketingDurationField marketingDuration =
    div [ class "row align-items-center g-2" ]
        [ label
            [ for "marketing-duration"
            , class "col-sm-7 col-form-label text-truncate"
            ]
            [ text "Durée de commercialisation" ]
        , div [ class "col-sm-5" ]
            [ div [ class "input-group" ]
                [ input
                    [ type_ "number"
                    , id "marketing-duration"
                    , class "form-control"
                    , Attr.min <| String.fromFloat <| Duration.inDays <| Economics.minMarketingDuration
                    , Attr.max <| String.fromFloat <| Duration.inDays <| Economics.maxMarketingDuration

                    -- WARNING: be careful when reordering attributes: for obscure reasons,
                    -- the `value` one MUST be set AFTER the `step` one.
                    , step "1"
                    , marketingDuration |> Duration.inDays |> String.fromFloat |> value
                    , onInput (String.toInt >> Maybe.map (toFloat >> Duration.days) >> UpdateMarketingDuration)
                    ]
                    []
                , span [ class "input-group-text", title "jours" ] [ text "j." ]
                ]
            ]
        ]


businessField : Economics.Business -> Html Msg
businessField business =
    div [ class "row align-items-center g-2" ]
        [ label
            [ for "business"
            , class "col-sm-3 col-form-label text-truncate"
            ]
            [ text "Entreprise" ]
        , div [ class "col-sm-9" ]
            [ [ Economics.SmallBusiness
              , Economics.LargeBusinessWithoutServices
              , Economics.LargeBusinessWithServices
              ]
                |> List.map
                    (\b ->
                        option [ value (Economics.businessToString b), selected (business == b) ]
                            [ text (Economics.businessToLabel b) ]
                    )
                |> select
                    [ id "business"
                    , class "form-select"
                    , onInput (Economics.businessFromString >> UpdateBusiness)
                    ]
            ]
        ]


traceabilityField : Bool -> Html Msg
traceabilityField traceability =
    div [ class "form-check align-items-center g-2 pt-2" ]
        [ input
            [ type_ "checkbox"
            , id "traceability"
            , class "form-check-input"
            , onCheck UpdateTraceability
            , checked traceability
            ]
            []
        , label [ for "traceability", class "form-check-label text-truncate" ]
            [ text "Traçabilité affichée" ]
        ]


massField : String -> Html Msg
massField massInput =
    div [ class "d-flex flex-column" ]
        [ label [ for "mass", class "form-label text-truncate" ]
            [ text "Masse du produit fini" ]
        , div
            [ class "input-group" ]
            [ input
                [ type_ "number"
                , class "form-control"
                , id "mass"
                , Attr.min "0.05"
                , step "0.05"
                , value massInput
                , onInput UpdateMassInput
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        ]


durabilityField : Unit.Durability -> Html Msg
durabilityField durability =
    let
        fromFloat =
            Unit.durabilityToFloat >> String.fromFloat
    in
    div [ class "d-flex justify-content-center gap-3" ]
        [ input
            [ type_ "range"
            , id "durability-field"
            , class "form-range form-range w-auto"
            , Attr.min (fromFloat Unit.minDurability)
            , Attr.max (fromFloat Unit.maxDurability)

            -- WARNING: be careful when reordering attributes: for obscure reasons,
            -- the `value` one MUST be set AFTER the `step` one.
            , step "0.01"
            , value (fromFloat durability)
            , disabled True
            ]
            []
        , durability
            |> Unit.durabilityToFloat
            |> Format.formatFloat 2
            |> text
        ]


lifeCycleStepsView : Db -> Model -> Simulator -> Html Msg
lifeCycleStepsView db { detailedStep, impact } simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { db = db
                    , current = current
                    , daysOfWear = simulator.daysOfWear
                    , useNbCycles = simulator.useNbCycles
                    , detailedStep = detailedStep
                    , index = index
                    , inputs = simulator.inputs
                    , next = LifeCycle.getNextEnabledStep current.label simulator.lifeCycle
                    , selectedImpact = impact

                    -- Events
                    , addMaterialModal = AddMaterialModal
                    , deleteMaterial = .id >> RemoveMaterial
                    , setModal = SetModal
                    , toggleFading = ToggleFading
                    , toggleStep = ToggleStep
                    , toggleStepDetails = ToggleStepDetails
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingMedium = UpdateDyeingMedium
                    , updateMaterial = UpdateMaterial
                    , updateMaterialSpinning = UpdateMaterialSpinning
                    , updateFabricProcess = UpdateFabricProcess
                    , updatePrinting = UpdatePrinting
                    , updateMakingComplexity = UpdateMakingComplexity
                    , updateMakingWaste = UpdateMakingWaste
                    , updateMakingDeadStock = UpdateMakingDeadStock
                    , updateSurfaceMass = UpdateSurfaceMass
                    , updateYarnSize = UpdateYarnSize
                    }
            )
        |> Array.toList
        |> List.concatMap
            (\{ step, transport } ->
                [ step
                , DownArrow.view [] [ transport ]
                ]
            )
        -- Drop the very last item, which is the last arrow showing the mass out of the end of life step
        -- which doesn't really make sense
        |> (List.reverse >> List.drop 1 >> List.reverse)
        |> div [ class "pt-1" ]


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView session model ({ inputs, impacts } as simulator) =
    div [ class "row" ]
        [ div [ class "col-lg-8" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "row align-items-start flex-md-columns mb-3" ]
                [ div [ class "col-md-9" ]
                    [ Inputs.toQuery inputs
                        |> exampleProductField session.db.textile.exampleProducts
                    ]
                , div [ class "col-md-3" ] [ massField (String.fromFloat (Mass.inKilograms inputs.mass)) ]
                ]
            , div [ class "card shadow-sm pb-2 mb-3" ]
                [ div [ class "card-header d-flex justify-content-between align-items-center" ]
                    [ h2 [ class "h5 mb-1" ] [ text "Durabilité non-physique" ]
                    , div [ class "d-flex gap-2" ]
                        [ durabilityField simulator.durability
                        , Button.docsPillLink
                            [ class "bg-secondary"
                            , style "height" "24px"
                            , href (Gitbook.publicUrlFromPath Gitbook.TextileDurability)
                            , title "Documentation"
                            , target "_blank"
                            ]
                            [ Icon.question ]
                        ]
                    ]
                , div [ class "card-body pt-3 py-2 row g-3 align-items-start flex-md-columns" ]
                    [ div [ class "col-md-6" ]
                        [ productCategoryField session.db.textile (Inputs.toQuery inputs)
                        ]
                    , div [ class "col-md-6" ]
                        [ inputs.numberOfReferences
                            |> Maybe.withDefault inputs.product.economics.numberOfReferences
                            |> numberOfReferencesField
                        ]
                    ]
                , div [ class "card-body py-2 row g-3 align-items-start flex-md-columns" ]
                    [ div [ class "col-md-6" ]
                        [ inputs.price
                            |> Maybe.withDefault inputs.product.economics.price
                            |> productPriceField
                        ]
                    , div [ class "col-md-6" ]
                        [ inputs.marketingDuration
                            |> Maybe.withDefault inputs.product.economics.marketingDuration
                            |> marketingDurationField
                        ]
                    ]
                , div [ class "card-body py-2 row g-3 align-items-start flex-md-columns" ]
                    [ div [ class "col-md-8" ]
                        [ inputs.business
                            |> Maybe.withDefault inputs.product.economics.business
                            |> businessField
                        ]
                    , div [ class "col-md-4" ]
                        [ inputs.traceability
                            |> Maybe.withDefault inputs.product.economics.traceability
                            |> traceabilityField
                        ]
                    ]
                , div [ class "card-body py-2 row g-3 align-items-start flex-md-columns" ]
                    [ div [ class "col-md-2" ] [ text "Matières" ]
                    , div [ class "col-md-10" ]
                        [ div [ class "fw-bold" ]
                            [ Inputs.getMaterialsOriginShares inputs.materials
                                |> Economics.computeMaterialsOriginIndex
                                |> Tuple.second
                                |> text
                            ]
                        , small [ class "text-muted fs-8 lh-sm" ]
                            [ text "Le type de matière retenu dépend de la composition du vêtement détaillée ci-dessous" ]
                        ]
                    ]
                ]
            , div []
                [ lifeCycleStepsView session.db model simulator
                , div [ class "d-flex align-items-center justify-content-between mt-3 mb-5" ]
                    [ a [ Route.href Route.Home ]
                        [ text "« Retour à l'accueil" ]
                    , button
                        [ class "btn btn-secondary"
                        , onClick Reset
                        , disabled (session.queries.textile == model.initialQuery)
                        ]
                        [ text "Réinitialiser le produit" ]
                    ]
                ]
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ SidebarView.view
                { session = session
                , scope = Scope.Textile

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo =
                    Just
                        (small []
                            [ text "Hors modulation durabilité\u{00A0}: "
                            , impacts
                                |> Impact.multiplyBy (Unit.durabilityToFloat simulator.durability)
                                |> Format.formatImpact model.impact
                            ]
                        )
                , productMass = inputs.mass
                , totalImpacts = impacts

                -- Ecotox weighting customization
                , updateEcotoxWeighting = UpdateEcotoxWeighting

                -- Impacts tabs
                , impactTabsConfig =
                    SwitchImpactsTab
                        |> ImpactTabs.createConfig session model.impact model.activeImpactsTab OnStepClick
                        |> ImpactTabs.forTextile session.db.definitions simulator

                -- Bookmarks
                , activeBookmarkTab = model.bookmarkTab
                , bookmarkName = model.bookmarkName
                , copyToClipBoard = CopyToClipBoard
                , compareBookmarks = OpenComparator
                , deleteBookmark = DeleteBookmark
                , saveBookmark = SaveBookmark
                , updateBookmarkName = UpdateBookmarkName
                , switchBookmarkTab = SwitchBookmarksTab
                }
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator pb-3" ]
            (case model.simulator of
                Ok simulator ->
                    [ simulatorView session model simulator
                    , case model.modal of
                        NoModal ->
                            text ""

                        ComparatorModal ->
                            ModalView.view
                                { size = ModalView.ExtraLarge
                                , close = SetModal NoModal
                                , noOp = NoOp
                                , title = "Comparateur de simulations sauvegardées"
                                , subTitle = Just "en score d'impact, par produit"
                                , formAction = Nothing
                                , content =
                                    [ ComparatorView.view
                                        { session = session
                                        , impact = model.impact
                                        , comparisonType = model.comparisonType
                                        , selectAll = SelectAllBookmarks
                                        , selectNone = SelectNoBookmarks
                                        , switchComparisonType = SwitchComparisonType
                                        , toggle = ToggleComparedSimulation
                                        }
                                    ]
                                , footer = []
                                }

                        AddMaterialModal _ autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteMaterial
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom de la matière première pour la rechercher"
                                , title = "Sélectionnez une matière première"
                                , toLabel = .shortName
                                , toCategory = .origin >> Origin.toLabel
                                }

                        SelectExampleModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteExample
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom du produit pour le rechercher"
                                , title = "Sélectionnez un produit"
                                , toLabel = ExampleProduct.toName session.db.textile.exampleProducts
                                , toCategory = ExampleProduct.toCategory session.db.textile.exampleProducts
                                }

                        SelectProductModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteProduct
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici l'utilisation du produit pour le rechercher"
                                , title = "Sélectionnez une utilisation de produit"
                                , toLabel =
                                    \productId ->
                                        Product.findById productId session.db.textile.products
                                            |> Result.map .name
                                            |> Result.withDefault (Product.idToString productId)
                                , toCategory = always ""
                                }
                    ]

                Err error ->
                    [ Alert.simple
                        { level = Alert.Danger
                        , close = Nothing
                        , title = Just "Erreur"
                        , content = [ text error ]
                        }
                    ]
            )
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        ComparatorModal ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))

        AddMaterialModal _ _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))

        SelectExampleModal _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))

        SelectProductModal _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
