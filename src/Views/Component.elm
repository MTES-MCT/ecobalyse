module Views.Component exposing
    ( Config
    , Context(..)
    , createMaterialProcessAutocomplete
    , editorView
    , elementEditModalView
    )

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Complement as Complement
import Data.Component as Component
    exposing
        ( Component
        , EndOfLifeMaterialImpacts
        , ExpandedElement
        , ExpandedItem
        , ExpandedLocalizedProcess
        , ExpandedQuantifiedProcess
        , Index
        , LifeCycle
        , Quantity
        , Query
        , Requirements
        , ResultedElement
        , Results
        , TargetElement
        , TargetItem
        )
import Data.Component.Amount as Amount exposing (Amount)
import Data.Component.Config as Config
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Transport exposing (Transport)
import Data.Unit as Unit
import Dict.Any as AnyDict
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Route exposing (Route)
import Views.Alert as Alert
import Views.Button as Button
import Views.Component.DownArrow as DownArrow
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link
import Views.Transport as TransportView


type alias Config db msg =
    { addLabel : String
    , componentConfig : Component.Config
    , context : Context
    , db : Component.DataContainer db
    , debug : Bool
    , detailed : List Index
    , docsUrl : Maybe String
    , explorerRoute : Maybe Route
    , impact : Definition
    , lifeCycle : Result String LifeCycle
    , noOp : msg
    , openCreateComponentModal : msg
    , openEditElementModal : Component -> TargetElement -> msg
    , openSelectComponentModal : Autocomplete Component -> msg
    , openSelectConsumptionModal : Autocomplete Process -> msg
    , openSelectPackagingModal : Autocomplete Process -> msg
    , openSelectProcessModal : Category -> TargetItem -> Maybe Index -> Autocomplete Process -> msg
    , query : Query
    , removeConsumption : Index -> msg
    , removeElement : TargetElement -> msg
    , removeElementTransform : TargetElement -> Index -> msg
    , removeItem : Index -> msg
    , removePackaging : Index -> msg
    , scope : Scope
    , setDetailed : List Index -> msg
    , title : String
    , toggleTransportByAir : Split -> msg
    , toggleTransportCooling : Bool -> msg
    , updateAssemblyCountry : Maybe Country.Code -> msg
    , updateConsumptionAmount : Index -> Maybe Amount -> msg
    , updateDistribution : Result String Process.Id -> msg
    , updateElementAmount : TargetElement -> Maybe Amount -> msg
    , updateElementMaterialCountry : TargetElement -> Maybe Country.Code -> msg
    , updateElementTransformCountry : TargetElement -> Index -> Maybe Country.Code -> msg
    , updateItemName : TargetItem -> String -> msg
    , updateItemQuantity : Index -> Quantity -> msg
    , updatePackagingAmount : Index -> Maybe Amount -> msg
    , updateRecyclable : Bool -> msg
    }


type Context
    = AdminContext
    | GenericContext
    | TextileTrimsContext


{-| Extract the requirements from the config

FIXME: maybe the config should use Requirements directly instead

-}
requirementsFromConfig : Config db msg -> Requirements db
requirementsFromConfig config =
    { config = config.componentConfig
    , db = config.db
    , scope = config.scope
    }


addComponentButton : Config db msg -> Html msg
addComponentButton { addLabel, db, openSelectComponentModal, scope } =
    let
        availableComponents =
            db.components
                |> List.filter (not << Component.isEmpty)
                |> List.filter (.scope >> (==) scope)

        autocompleteState =
            AutocompleteSelector.init .name availableComponents
    in
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , disabled <| List.isEmpty availableComponents
        , onClick <| openSelectComponentModal autocompleteState
        ]
        [ Icon.plus
        , text addLabel
        ]


createComponentButton : Config db msg -> Html msg
createComponentButton config =
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , onClick config.openCreateComponentModal
        , listAvailableProcesses config Category.Material
            |> List.isEmpty
            |> disabled
        ]
        [ Icon.plus
        , text "Créer un nouveau composant"
        ]


addElementButton : Config db msg -> TargetItem -> Html msg
addElementButton config targetItem =
    button
        [ type_ "button"
        , class "btn btn-link text-decoration-none"
        , class "d-flex justify-content-end align-items-center"
        , class "gap-2 w-100 p-0 pb-1 text-end fs-7"
        , createMaterialProcessAutocomplete config.db config.scope
            |> config.openSelectProcessModal Category.Material targetItem Nothing
            |> onClick
        ]
        [ Icon.puzzle
        , text "Ajouter un élément"
        ]


addPackagingButton : Config db msg -> Html msg
addPackagingButton ({ query } as config) =
    let
        availableTransformProcesses =
            listAvailableProcesses config Category.Packaging
                |> List.filter
                    (\{ id } ->
                        query.packagings
                            |> List.map Component.getPackagingProcessId
                            |> List.member id
                            |> not
                    )

        autocompleteState =
            availableTransformProcesses
                |> AutocompleteSelector.init Process.getDisplayName
    in
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , onClick <| config.openSelectPackagingModal autocompleteState
        , disabled <| List.isEmpty availableTransformProcesses
        ]
        [ Icon.plus
        , text "Ajouter un emballage"
        ]


createMaterialProcessAutocomplete : Component.DataContainer db -> Scope -> Autocomplete Process
createMaterialProcessAutocomplete db scope =
    listAvailableProcesses { db = db, scope = scope } Category.Material
        |> AutocompleteSelector.init Process.getDisplayName


addElementTransformButton : Config db msg -> Process -> TargetElement -> Html msg
addElementTransformButton { db, openSelectProcessModal, query, scope } material ( targetItem, elementIndex ) =
    let
        availableTransformProcesses =
            db.processes
                |> Scope.anyOf [ scope ]
                |> Process.listAvailableMaterialTransforms material
                |> List.sortBy Process.getDisplayName
                |> Process.available (Component.elementTransforms ( targetItem, elementIndex ) query.items)

        autocompleteState =
            availableTransformProcesses
                |> AutocompleteSelector.init Process.getDisplayName
    in
    button
        [ type_ "button"
        , class "btn btn-link btn-sm w-100 text-decoration-none"
        , class "d-flex justify-content-start align-items-center"
        , class "gap-1 w-100 ps-0"
        , disabled <| List.isEmpty availableTransformProcesses
        , autocompleteState
            |> openSelectProcessModal Category.Transform targetItem (Just elementIndex)
            |> onClick
        ]
        [ Icon.plus
        , text "Ajouter une transformation"
        ]


componentView : Config db msg -> Index -> ExpandedItem -> Results -> List (Html msg)
componentView config itemIndex ({ component, elements, quantity } as expandedItem) itemResults =
    let
        collapsed =
            config.detailed
                |> List.member itemIndex
                |> not
    in
    List.concat
        [ [ tbody
                (if itemIndex > 0 then
                    -- Better visually separate components items when they're stacked and opened
                    [ style "border-top" "1px solid #777" ]

                 else
                    []
                )
                [ if config.scope /= Scope.Textile then
                    tr []
                        [ th [] []
                        , th [ class "pb-0 fs-8 fw-normal text-muted" ] [ text "Quantité" ]
                        , th [ class "pb-0 fs-8 fw-normal text-muted", colspan 2 ]
                            [ span [] [ text "Nom du composant" ] ]
                        , th [ colspan 3 ] []
                        ]

                  else
                    tr [] [ td [ colspan 7 ] [] ]
                , tr [ class "border-bottom" ]
                    [ th [ class "ps-2 pt-0 pb-2 align-middle", scope "col" ]
                        [ if config.context /= TextileTrimsContext then
                            button
                                [ type_ "button"
                                , class "btn btn-link text-muted text-decoration-none font-monospace fs-5 p-0 m-0"
                                , onClick <|
                                    config.setDetailed <|
                                        if collapsed && not (List.member itemIndex config.detailed) then
                                            LE.unique <| itemIndex :: config.detailed

                                        else
                                            List.filter ((/=) itemIndex) config.detailed
                                ]
                                [ if collapsed then
                                    text "▶"

                                  else
                                    text "▼"
                                ]

                          else
                            text ""
                        ]
                    , td [ class "ps-0 pt-0 pb-2 align-middle" ]
                        [ quantity |> quantityInput config itemIndex
                        ]
                    , td [ class "pt-0 pb-2 align-middle text-truncate w-100", colspan 2 ]
                        [ if config.context == GenericContext then
                            div [ class "d-flex flex-column gap-1" ]
                                [ div [ class "d-flex gap-2" ]
                                    [ input
                                        [ type_ "text"
                                        , class "form-control"
                                        , onInput (config.updateItemName ( component, itemIndex ))
                                        , placeholder "Nom du composant"
                                        , value component.name
                                        ]
                                        []
                                    ]
                                ]

                          else
                            span [ class "fw-bold" ] [ text component.name ]
                        ]
                    , td [ class "pt-0 pb-2 text-end align-middle text-nowrap fs-7" ]
                        [ Component.extractMass itemResults
                            |> Format.kg
                        ]
                    , td [ class "pt-0 pb-2 text-end align-middle text-nowrap fs-7" ]
                        [ Component.getTotalImpacts itemResults
                            |> Format.formatImpact config.impact
                        ]
                    , td [ class "pe-3 pt-0 pb-2 text-end align-middle text-nowrap" ]
                        [ if config.context == AdminContext then
                            text ""

                          else
                            button
                                [ type_ "button"
                                , class "btn btn-outline-secondary"
                                , onClick (config.removeItem itemIndex)
                                ]
                                [ Icon.trash ]
                        ]
                    ]
                ]
          ]
        , if not collapsed then
            componentDetailedView config elements itemIndex expandedItem itemResults

          else
            []
        ]


componentDetailedView : Config db msg -> List ExpandedElement -> Index -> ExpandedItem -> Results -> List (Html msg)
componentDetailedView config elements itemIndex expandedItem itemResults =
    List.concat
        [ [ tr [ class "bg-light border-bottom" ]
                [ th [] []
                , th [ class "pb-1", colspan 6 ] [ text "Composition" ]
                ]
          ]
        , if List.isEmpty elements then
            [ tr []
                [ th [] []
                , td [] [ text "Aucun élément" ]
                ]
            ]

          else
            List.map3
                (elementView config ( expandedItem.component, itemIndex ))
                (List.range 0 (List.length elements - 1))
                elements
                (Component.extractItems itemResults)
        , [ tr [ class "border-top" ]
                [ td [ colspan 7, class "pe-3" ]
                    [ addElementButton config ( expandedItem.component, itemIndex )
                    ]
                ]
          ]
        ]


viewDebug : Query -> LifeCycle -> Html msg
viewDebug query lifeCycle =
    div []
        [ details [ class "card-body py-2" ]
            [ summary [] [ text "Debug" ]
            , div [ class "row g-2" ]
                [ div [ class "col-6" ]
                    [ h5 [] [ text "Query" ]
                    , pre [ class "bg-light p-2 mb-0" ]
                        [ query
                            |> Component.encodeQuery
                            |> Encode.encode 2
                            |> text
                        ]
                    ]
                , div [ class "col-6" ]
                    [ h5 [] [ text "Results" ]
                    , pre [ class "p-2 bg-light" ]
                        [ lifeCycle
                            |> Component.encodeLifeCycle (Just Definition.Ecs)
                            |> Encode.encode 2
                            |> text
                        ]
                    ]
                ]
            ]
        ]


editorView : Config db msg -> Html msg
editorView config =
    case config.lifeCycle of
        Err error ->
            error |> simpleError (Just "Erreur de chargement du calculateur")

        Ok lifeCycle ->
            lifeCycleView config lifeCycle


simpleError : Maybe String -> String -> Html msg
simpleError title message =
    Alert.simple
        { attributes = []
        , close = Nothing
        , content = [ text message ]
        , level = Alert.Danger
        , title = title
        }


lifeCycleView : Config db msg -> LifeCycle -> Html msg
lifeCycleView ({ db, docsUrl, explorerRoute, impact, query, scope, title } as config) lifeCycle =
    div [ class "d-flex flex-column" ]
        [ div [ class "d-flex justify-content-end mb-2" ]
            [ div [ class "form-check form-switch" ]
                [ label [ class "form-check-label", for "transportCoolingSwitch" ]
                    [ text "Transport réfrigéré" ]
                , input
                    [ type_ "checkbox"
                    , class "form-check-input"
                    , id "transportCoolingSwitch"
                    , attribute "role" "switch"
                    , attribute "switch" ""
                    , onCheck config.toggleTransportCooling
                    , checked query.transportOptions.cooling
                    ]
                    []
                ]
            ]
        , div [ class "card shadow-sm" ]
            [ div [ class "card-header d-flex align-items-center justify-content-between" ]
                [ h2 [ class "h5 mb-0" ]
                    [ text title
                    , case explorerRoute of
                        Just route ->
                            Link.smallPillExternal
                                [ Route.href route
                                , Attr.title "Explorer"
                                , attribute "aria-label" "Explorer"
                                ]
                                [ Icon.search ]

                        Nothing ->
                            text ""
                    ]
                , div [ class "d-flex align-items-center gap-2" ]
                    [ span [ class "cursor-help", Attr.title "Hors transports" ]
                        [ lifeCycle.production
                            |> Component.getTotalImpacts
                            |> Format.formatImpact config.impact
                        ]
                    , case docsUrl of
                        Just url ->
                            Button.docsPillLink
                                [ href url, target "_blank", style "height" "24px" ]
                                [ Icon.question ]

                        Nothing ->
                            text ""
                    ]
                ]
            , if List.isEmpty query.items then
                div [ class "card-body" ] [ text "Aucun élément." ]

              else
                case Component.expandItems db query.items of
                    Err error ->
                        error |> simpleError (Just "Erreur")

                    Ok expandedItems ->
                        div [ class "table-responsive" ]
                            [ table [ class "table table-sm table-borderless mb-0" ]
                                ((if config.context == AdminContext then
                                    thead []
                                        [ tr [ class "fs-7 text-muted" ]
                                            [ th [] []
                                            , th [ class "ps-0", Attr.scope "col" ] [ text "Quantité" ]
                                            , th [ Attr.scope "col", colspan 2 ] [ text "Composant" ]
                                            , th [ Attr.scope "col" ] [ text "Masse" ]
                                            , th [ Attr.scope "col" ] [ text "Impact" ]
                                            , th [ Attr.scope "col" ] []
                                            ]
                                        ]

                                  else
                                    text ""
                                 )
                                    :: List.concat
                                        (List.map3 (componentView config)
                                            (List.range 0 (List.length query.items - 1))
                                            expandedItems
                                            (Component.extractItems lifeCycle.production)
                                        )
                                )
                            ]
            , case config.context of
                AdminContext ->
                    createComponentButton config

                GenericContext ->
                    div [ class "d-flex gap-1" ]
                        [ addComponentButton config
                        , createComponentButton config
                        ]

                TextileTrimsContext ->
                    addComponentButton config
            ]
        , if Scope.isGeneric scope && List.length query.items > 1 then
            div []
                [ DownArrow.view
                    [ div [ class "d-flex justify-content-end align-items-center gap-1" ]
                        [ text "Transport", span [] [ Icon.package, Icon.forkWay, Icon.package ] ]
                    ]
                    [ div [ class "d-flex gap-2" ]
                        [ lifeCycle.transports.toAssembly.impacts
                            |> Format.formatImpact impact
                        , text "(détails en dépliant les composants ci-dessus)"
                        ]
                    ]
                , assemblyView config
                ]

          else
            text ""
        , if config.context == GenericContext && not (List.isEmpty query.items) then
            genericContextStagesView config lifeCycle

          else
            text ""
        , if config.debug then
            viewDebug query lifeCycle

          else
            text ""
        ]


packagingView : Config db msg -> LifeCycle -> Html msg
packagingView ({ query } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Emballage" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ lifeCycle.packaging
                    |> Impact.sumImpacts
                    |> Format.formatImpact config.impact
                ]
            ]
        , query.packagings
            |> quantifiedProcessList config
                { deletionLabel = "Supprimer cet emballage"
                , emptyListLabel = "Aucun emballage"
                , expandFn = Component.expandPackagings
                , impactsList = lifeCycle.packaging
                , removeFn = config.removePackaging
                , updateAmount = config.updatePackagingAmount
                }
        , addPackagingButton config
        ]


{-| A generic view config to render a list of QuantifiedProcess, with update
and removal inputs, as well as detailed impacts.
-}
type alias QuantifiedProcessListConfig quantified msg =
    { deletionLabel : String
    , emptyListLabel : String
    , expandFn : List Process -> List quantified -> Result String (List ExpandedQuantifiedProcess)
    , impactsList : List Impacts
    , removeFn : Index -> msg
    , updateAmount : Index -> Maybe Amount -> msg
    }


quantifiedProcessList : Config db msg -> QuantifiedProcessListConfig quantified msg -> List quantified -> Html msg
quantifiedProcessList { db, impact } listConfig quantifiedProcesses =
    if List.isEmpty quantifiedProcesses then
        div [ class "card-body" ]
            [ text listConfig.emptyListLabel ]

    else
        div [ class "QuantifiedProcessList table-responsive table-scroll position-relative" ]
            [ table [ class "table table-hover mb-0" ]
                [ case quantifiedProcesses |> listConfig.expandFn db.processes of
                    Err error ->
                        simpleError Nothing error

                    Ok expanded ->
                        expanded
                            |> List.indexedMap
                                (\index { amount, process } ->
                                    tr []
                                        [ td [ class "ps-3 align-middle text-nowrap", style "min-width" "160px" ]
                                            [ amountInput (listConfig.updateAmount index) process.unit amount ]
                                        , td
                                            [ class "align-middle w-66 text-truncate cursor-help"
                                            , [ Process.getDisplayName process
                                              , Process.getTechnicalName process
                                              ]
                                                |> String.join "\n"
                                                |> title
                                            ]
                                            [ text <| Process.getDisplayName process ]
                                        , td [ class "text-end text-nowrap" ]
                                            [ listConfig.impactsList
                                                |> LE.getAt index
                                                |> Maybe.withDefault Impact.empty
                                                |> Format.formatImpact impact
                                            ]
                                        , td [ class "pe-3 pt-2 align-middle" ]
                                            [ button
                                                [ type_ "button"
                                                , class "btn btn-sm btn-outline-secondary"
                                                , title listConfig.deletionLabel
                                                , onClick (listConfig.removeFn index)
                                                ]
                                                [ Icon.trash ]
                                            ]
                                        ]
                                )
                            |> tbody []
                ]
            ]


genericContextStagesView : Config db msg -> LifeCycle -> Html msg
genericContextStagesView config lifeCycle =
    div []
        [ noTransportView
        , packagingView config lifeCycle
        , lifeCycle.transports.toDistribution
            |> transportToDistributionView config (Component.extractMass lifeCycle.production)
        , distributionView config lifeCycle
        , noTransportView
        , useStageView config lifeCycle
        , noTransportView
        , endOfLifeView config lifeCycle
        ]


transportToDistributionView : Config db msg -> Mass -> Transport -> Html msg
transportToDistributionView ({ componentConfig, impact, scope } as config) mass transport =
    let
        -- if no plane transport process is available in current scope, disable
        airTransportAvailable =
            componentConfig.transports.modeProcesses.plane.scopes
                |> List.member scope
    in
    DownArrow.view
        [ div [ class "d-flex justify-content-end align-items-center gap-2" ]
            [ text "Transport"
            , Icon.package
            , Format.kg mass
            , if airTransportAvailable then
                airTransportToggler config

              else
                text ""
            ]
        ]
        [ div [ class "d-flex align-items-center gap-2" ]
            [ transport
                |> TransportView.viewDetails
                    { airTransportLabel = Just "avion"
                    , fullWidth = True
                    , hideNoLength = True
                    , onlyIcons = False
                    , roadTransportLabel = Nothing
                    , seaTransportLabel = Nothing
                    }
                |> div [ class "d-flex gap-2" ]
            , transport.impacts
                |> Format.formatImpact impact
            ]
        ]


airTransportToggler : Config db msg -> Html msg
airTransportToggler ({ query } as config) =
    div [ class "d-flex justify-content-end align-items-center gap-2" ]
        [ input
            [ type_ "checkbox"
            , class "form-check-input"
            , id "transportByAirSwitch"

            -- Note: for now, the toggler only switches between full and zero air transport, though
            --       we'll probably want to introduce a rangeslider for textile scope compliance next
            , checked (query.transportOptions.byAir == Split.full)
            , onCheck
                (\enabled ->
                    config.toggleTransportByAir <|
                        if enabled then
                            Split.full

                        else
                            Split.zero
                )
            ]
            []
        , label [ class "form-check-label", for "transportByAirSwitch" ]
            [ text "par avion" ]
        ]


noTransportView : Html msg
noTransportView =
    DownArrow.view [] []


amountInput : (Maybe Amount -> msg) -> Process.Unit -> Amount -> Html msg
amountInput toMsg unit amount =
    let
        stringAmount =
            Amount.toString amount

        stepValue =
            case String.split "." stringAmount of
                -- This is an integer, increment by .1 for convenience
                [ _ ] ->
                    "0.1"

                -- This is a float, increment at the precision of the float
                [ _, decimals ] ->
                    "0." ++ String.padLeft (String.length decimals) '0' "1"

                -- Should not happen, but who knows?
                _ ->
                    "0.01"
    in
    div [ class "AmountInput input-group" ]
        [ input
            [ type_ "number"
            , class "form-control form-control-sm text-end incdec-arrows-left"
            , value stringAmount
            , Attr.min "0"
            , step stepValue
            , onInput <| Amount.fromString >> toMsg
            ]
            []
        , small [ class "input-group-text fs-8" ]
            [ text <| Process.unitToString unit ]
        ]


type alias CountrySelector msg =
    { countries : List Country
    , domId : String
    , scope : Scope
    , select : Maybe Country.Code -> msg
    , selected : Maybe Country.Code
    }


countrySelector : CountrySelector msg -> Html msg
countrySelector config =
    config.countries
        |> Scope.anyOf [ config.scope ]
        |> List.sortBy .name
        |> List.map (\{ code, name } -> ( name, Just code ))
        |> (::) ( "Inconnu", Nothing )
        |> List.map
            (\( name, maybeCode ) ->
                option
                    [ maybeCode
                        |> Maybe.map Country.codeToString
                        |> Maybe.withDefault ""
                        |> value
                    , selected <| config.selected == maybeCode
                    ]
                    [ text name ]
            )
        |> select
            [ class "form-select w-33"
            , id config.domId
            , autocomplete False
            , onInput <|
                \str ->
                    config.select <|
                        if String.isEmpty str then
                            Nothing

                        else
                            Just <| Country.codeFromString str
            ]


elementView : Config db msg -> TargetItem -> Index -> ExpandedElement -> Results -> Html msg
elementView config (( component, _ ) as targetItem) elementIndex { amount, material, transforms } elementResults =
    let
        materialLabel { country, process } =
            String.join " "
                [ Process.getDisplayName process
                , "(" ++ (country |> Maybe.map .name |> Maybe.withDefault "Inconnu") ++ ")"
                ]
    in
    tbody []
        [ tr [ class "fs-7 border-top" ]
            [ td [] []
            , td [ class "ps-0 align-start text-end text-nowrap" ]
                [ Format.amount material.process amount ]
            , td
                [ colspan 2
                , class "align-middle text-truncate"
                , style "max-width" "10vw"
                ]
                [ div [ class "d-flex flex-column" ]
                    [ button
                        [ type_ "button"
                        , class "btn btn-sm btn-link text-decoration-none p-0 text-start"
                        , onClick (config.openEditElementModal component ( targetItem, elementIndex ))
                        , title <| materialLabel material
                        ]
                        [ span [ class "ComponentElementIcon" ] [ Icon.material ]
                        , text <| materialLabel material
                        ]
                    , div
                        [ class "d-flex align-items-center gap-1 text-muted"
                        , title <| Component.transformListToString transforms
                        ]
                        [ span [ class "ComponentElementIcon me-0" ] [ Icon.transform ]
                        , if List.isEmpty transforms then
                            text "Aucune transformation"

                          else
                            text <| Component.transformListToString transforms
                        ]
                    ]
                ]
            , td [ class "align-middle text-end text-nowrap", colspan 2 ]
                [ Component.getTotalImpacts elementResults
                    |> Format.formatImpact config.impact
                ]
            , td [ class "pe-3 align-middle text-end text-nowrap" ]
                [ div [ class "btn-group btn-group-sm" ]
                    [ button
                        [ type_ "button"
                        , class "btn btn-outline-secondary"
                        , attribute "aria-label" "Modifier l’élément"
                        , onClick (config.openEditElementModal component ( targetItem, elementIndex ))
                        ]
                        [ Icon.pencil ]
                    , button
                        [ type_ "button"
                        , class "btn btn-outline-secondary"
                        , attribute "aria-label" "Supprimer l’élément"
                        , onClick (config.removeElement ( targetItem, elementIndex ))
                        ]
                        [ Icon.trash ]
                    ]
                ]
            ]
        ]


getEditedResultedElement : Config db msg -> TargetElement -> Query -> Result String ResultedElement
getEditedResultedElement { db, lifeCycle } ( ( _, itemIndex ), elementIndex ) query =
    Result.map2 (Component.getResultedElement ( itemIndex, elementIndex ))
        (Result.map .production lifeCycle)
        (Component.expandItems db query.items)
        |> RE.join


elementEditModalView : Config db msg -> TargetElement -> Html msg
elementEditModalView ({ query } as config) (( _, elementIndex ) as targetElement) =
    case query |> getEditedResultedElement config targetElement of
        Err error ->
            div [ class "alert alert-danger" ] [ text error ]

        Ok ( { amount, material, transforms } as expandedElement, elementResults ) ->
            let
                stageItems =
                    Component.extractItems elementResults

                materialResults =
                    stageItems
                        |> List.filter (Component.extractStage >> (==) (Just Component.MaterialStage))
                        |> List.head
                        |> Maybe.withDefault Component.emptyResults

                transformsResults =
                    stageItems
                        |> List.filter (Component.extractStage >> (==) (Just Component.TransformStage))
            in
            div [ class "table-responsive p-2" ]
                [ table [ class "table table-sm table-borderless mb-0" ]
                    [ tbody []
                        (tr [ class "fs-7 text-muted" ]
                            [ th [] []
                            , th [ class "align-middle ps-0", scope "col" ]
                                [ if material.process.unit == Process.Kilogram then
                                    text "Masse finale"

                                  else
                                    text "Quantité finale"
                                ]
                            , th [ class "align-middle", scope "col" ]
                                [ text <| "Élément #" ++ String.fromInt (elementIndex + 1) ]
                            , th [ class "align-middle text-center", scope "col" ]
                                [ text "Pays/Région" ]
                            , th [ class "align-middle", scope "col" ]
                                [ text "Pertes" ]
                            , th [ class "align-middle text-truncate", scope "col" ]
                                [ material.process.unit |> Process.unitLabel |> text ]
                            , th [ class "align-middle text-end", scope "col" ]
                                [ Component.getTotalImpacts elementResults
                                    |> Format.formatImpact config.impact
                                ]
                            , th [] []
                            ]
                            :: elementMaterialView config targetElement materialResults material amount
                            ++ elementTransformsView config targetElement materialResults material.country transformsResults transforms
                            ++ [ LE.last transformsResults
                                    |> Maybe.map Component.extractMass
                                    |> Maybe.withDefault (Component.extractMass materialResults)
                                    |> finalElementTransportView config (Component.getFinalElementCountry expandedElement)
                               , tr [ class "border-top" ]
                                    [ td [ colspan 2 ] []
                                    , td [ colspan 6 ]
                                        [ addElementTransformButton config material.process targetElement ]
                                    ]
                               ]
                        )
                    ]
                ]


{-| Render transports from last transform step to assembly or distribution stage
-}
finalElementTransportView : Config db msg -> Maybe Country -> Mass -> Html msg
finalElementTransportView ({ componentConfig, db, query, scope } as config) elementCountry mass =
    let
        maybeDestinationCountryCode =
            case ( List.length query.items > 1, query.assemblyCountry ) of
                -- multiple items and an assembly country: transport to assembly country
                ( True, Just assemblyCountryCode ) ->
                    Just assemblyCountryCode

                -- single item and no assembly country: transport to default distribution country
                ( False, Nothing ) ->
                    Just componentConfig.distribution.country.code

                -- fallback to unknown destination
                _ ->
                    Nothing
    in
    db.countries
        |> Scope.anyOf [ scope ]
        |> Country.resolveMaybe maybeDestinationCountryCode
        |> Result.map (elementTransportView config [ class "subdued" ] False mass elementCountry)
        |> Result.withDefault (text "")


listAvailableProcesses :
    { config | db : Component.DataContainer db, scope : Scope }
    -> Category
    -> List Process
listAvailableProcesses { db, scope } category =
    db.processes
        |> Scope.anyOf [ scope ]
        |> Process.listByCategory category
        |> List.sortBy Process.getDisplayName


selectMaterialButton : Config db msg -> TargetElement -> Process -> Html msg
selectMaterialButton config ( targetItem, elementIndex ) material =
    button
        [ type_ "button"
        , class "btn btn-sm btn-link text-decoration-none p-0"
        , listAvailableProcesses config Category.Material
            |> AutocompleteSelector.init Process.getDisplayName
            |> config.openSelectProcessModal Category.Material targetItem (Just elementIndex)
            |> onClick
        ]
        [ span [ class "ComponentElementIcon" ] [ Icon.material ]
        , text <| Process.getDisplayName material
        ]


elementMaterialView :
    Config db msg
    -> TargetElement
    -> Results
    -> ExpandedLocalizedProcess
    -> Amount
    -> List (Html msg)
elementMaterialView config targetElement materialResults material amount =
    let
        complementsImpacts =
            Component.extractComplementsImpacts materialResults
    in
    [ tr [ class "fs-7" ]
        [ td [] []
        , td [ class "text-end align-middle text-nowrap ps-0", style "min-width" "130px" ]
            [ if config.scope == Scope.Textile then
                Format.amount material.process amount

              else
                amountInput (config.updateElementAmount targetElement) material.process.unit amount
            ]
        , td
            [ class "align-middle text-truncate"
            , title <| Process.getDisplayName material.process
            ]
            [ selectMaterialButton config targetElement material.process
            ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ regionSelector
                { countries = config.db.countries
                , domId = "material-country-" ++ Component.targetElementToString targetElement
                , scope = config.scope
                , select = config.updateElementMaterialCountry targetElement
                , selected = material.country |> Maybe.map .code
                }
            ]
        , td [ class "text-end align-middle text-nowrap" ]
            []
        , td [ class "text-end align-middle text-nowrap" ]
            [ Component.extractAmount materialResults
                |> Format.amount material.process
            ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Component.getTotalImpacts materialResults
                |> Format.formatImpact config.impact
            ]
        , td [ class "pe-3 text-nowrap" ] []
        ]
    , if complementsImpacts /= Complement.emptyComplementsResultsImpacts then
        tr [ class "fs-7" ]
            [ td [] []
            , td [ class "text-end align-middle text-nowrap ps-0", style "min-width" "130px" ]
                []
            , td
                [ class "align-middle text-truncate w-100 text-muted cursor-help ps-4 fs-8"
                , title (Format.formatComplementsResultsImpactsToString config.impact complementsImpacts)
                ]
                [ span [ class "ComponentElementIcon" ] [ Icon.calculator ], text "Dont compléments" ]
            , td [ class "text-end align-middle text-nowrap", colspan 3 ]
                []
            , td [ class "text-end align-middle text-nowrap" ]
                [ complementsImpacts
                    |> Complement.mergeComplementsResultsImpacts
                    |> Format.formatImpact config.impact
                ]
            , td [ class "pe-3 text-nowrap" ]
                []
            ]

      else
        text ""
    ]


elementTransportView : Config db msg -> List (Attribute msg) -> Bool -> Mass -> Maybe Country -> Maybe Country -> Html msg
elementTransportView ({ query } as config) attributes noAirTransport transportedMass maybeFrom maybeTo =
    let
        { transportOptions } =
            query

        -- ALtered transport options for local rendering purpose only
        displayTransportOptions =
            if List.length query.items > 1 || noAirTransport then
                -- multiple components: remove all air transports (they're removed in Component.computeTransports)
                { transportOptions | byAir = Split.zero }

            else
                -- single component: preserve air transport
                transportOptions

        displayElementTransport =
            transportedMass
                |> Component.computeTransportedMassImpacts (requirementsFromConfig config)
                    displayTransportOptions
                    maybeFrom
                    maybeTo
    in
    case displayElementTransport of
        Err error ->
            tr []
                [ td [ class "p-2", colspan 7 ]
                    [ error |> simpleError (Just "Erreur de calcul de distance")
                    ]
                ]

        Ok transport ->
            let
                renderCountry =
                    Maybe.map .name >> Maybe.withDefault "Région inconnue"

                renderModeIfAny icon distance =
                    if distance |> Quantity.greaterThan Quantity.zero then
                        [ icon, Format.km distance ]

                    else
                        []
            in
            tr (class "fs-7 text-muted" :: attributes)
                [ td [ colspan 2 ] []
                , td []
                    [ text <| "Transport " ++ renderCountry maybeFrom ++ " → " ++ renderCountry maybeTo ]
                , td [ class "text-end align-middle d-flex justify-content-end align-items-center gap-2 text-nowrap" ] <|
                    -- Note: it's supposed for now that a plane can transport either cooled or non-cooled stuff
                    renderModeIfAny Icon.plane transport.air
                        ++ (if query.transportOptions.cooling then
                                renderModeIfAny Icon.boatCooled transport.seaCooled

                            else
                                renderModeIfAny Icon.boat transport.sea
                           )
                        ++ (if query.transportOptions.cooling then
                                renderModeIfAny Icon.busCooled transport.roadCooled

                            else
                                renderModeIfAny Icon.bus transport.road
                           )
                        ++ [ Icon.package
                           , Format.kg transportedMass
                           ]
                , td [ colspan 2 ] []
                , td [ class "text-end align-middle text-nowrap" ]
                    [ transport.impacts
                        |> Format.formatImpact config.impact
                    ]
                , td [] []
                ]


elementTransformsView :
    Config db msg
    -> TargetElement
    -> Results
    -> Maybe Country
    -> List Results
    -> List ExpandedLocalizedProcess
    -> List (Html msg)
elementTransformsView config targetElement materialResults materialCountry transformsResults transforms =
    transforms
        |> List.indexedMap
            (\transformIndex transform ->
                let
                    transformResult =
                        transformsResults
                            |> LE.getAt transformIndex
                            |> Maybe.withDefault Component.emptyResults

                    ( previousMass, previousCountry ) =
                        case transformIndex of
                            0 ->
                                ( Component.extractMass materialResults
                                , materialCountry
                                )

                            index ->
                                ( transformsResults
                                    |> LE.getAt (index - 1)
                                    |> Maybe.withDefault Component.emptyResults
                                    |> Component.extractMass
                                , transforms
                                    |> LE.getAt (index - 1)
                                    |> Maybe.andThen .country
                                )

                    tooltipText =
                        "Procédé\u{00A0}: "
                            ++ Process.getDisplayName transform.process
                            ++ (transform.country
                                    |> Component.loadEnergyMixes config.componentConfig
                                    |> Result.map
                                        (\{ elec, heat } ->
                                            "\nÉlectricité\u{00A0}: "
                                                ++ Process.getDisplayName elec
                                                ++ "\nChaleur\u{00A0}: "
                                                ++ Process.getDisplayName heat
                                        )
                                    |> Result.withDefault ""
                               )
                in
                [ transform.country
                    |> elementTransportView config [] True previousMass previousCountry
                , tr [ class "fs-7 border-top" ]
                    [ td [] []
                    , td [ class "text-end align-middle text-nowrap" ] []
                    , td
                        [ class "text-truncate align-middle w-66 cursor-help "
                        , style "max-width" "0"
                        , title tooltipText
                        ]
                        [ span [ class "ComponentElementIcon" ] [ Icon.transform ]
                        , text <| Process.getDisplayName transform.process
                        ]
                    , td [ class "text-end align-middle text-nowrap" ]
                        [ regionSelector
                            { countries = config.db.countries
                            , domId =
                                "transform-country-"
                                    ++ Component.targetElementToString targetElement
                                    ++ "-"
                                    ++ String.fromInt transformIndex
                            , scope = config.scope
                            , select = config.updateElementTransformCountry targetElement transformIndex
                            , selected = transform.country |> Maybe.map .code
                            }
                        ]
                    , td [ class "align-middle text-end text-nowrap" ]
                        [ Unit.qtyVariationRatioToFloat transform.process.qtyVariationRatio
                            |> String.fromFloat
                            |> text
                        ]
                    , td [ class "text-end align-middle text-nowrap" ]
                        [ Component.extractAmount transformResult
                            |> Format.amount transform.process
                        ]
                    , td [ class "text-end align-middle text-nowrap" ]
                        [ Component.extractImpacts transformResult
                            |> Format.formatImpact config.impact
                        ]
                    , td []
                        [ button
                            [ type_ "button"
                            , class "btn btn-sm btn-outline-secondary"
                            , transformIndex
                                |> config.removeElementTransform targetElement
                                |> onClick
                            ]
                            [ Icon.trash ]
                        ]
                    ]
                ]
            )
        |> List.concat


type alias RegionSelector msg =
    { countries : List Country
    , domId : String
    , scope : Scope
    , select : Maybe Country.Code -> msg
    , selected : Maybe Country.Code
    }


regionSelector : RegionSelector msg -> Html msg
regionSelector config =
    let
        scopedCountries =
            config.countries
                |> Scope.anyOf [ config.scope ]
                |> List.sortBy .name
    in
    scopedCountries
        |> List.map (\{ code, name } -> ( name, Just code ))
        |> (::) ( "Par défaut", Nothing )
        |> List.map
            (\( name, maybeCode ) ->
                option
                    [ maybeCode
                        |> Maybe.map Country.codeToString
                        |> Maybe.withDefault ""
                        |> value
                    , selected <| config.selected == maybeCode
                    ]
                    [ text <|
                        case maybeCode of
                            Just code ->
                                name ++ " (" ++ Country.codeToString code ++ ")"

                            Nothing ->
                                "---"
                    ]
            )
        |> select
            [ class "RegionSelector form-select form-select-sm"
            , id config.domId
            , autocomplete False
            , config.selected
                |> Maybe.andThen
                    (\code ->
                        scopedCountries
                            |> Country.findByCode code
                            |> Result.map .name
                            |> Result.toMaybe
                    )
                |> Maybe.withDefault "Par défaut"
                |> (++) "Région\u{00A0}: "
                |> title
            , onInput <|
                \str ->
                    config.select <|
                        if String.isEmpty str || str == "---" then
                            Nothing

                        else
                            Just <| Country.codeFromString str
            ]


quantityInput : Config db msg -> Index -> Quantity -> Html msg
quantityInput config itemIndex quantity =
    div [ class "input-group", style "width" "130px" ]
        [ input
            [ type_ "number"
            , class "form-control text-end"
            , quantity |> Component.quantityToInt |> String.fromInt |> value
            , step "1"
            , Attr.min "1"
            , disabled <| config.context == AdminContext
            , onInput <|
                \str ->
                    String.toInt str
                        |> Maybe.andThen
                            (\int ->
                                if int > 0 then
                                    Just int

                                else
                                    Nothing
                            )
                        |> Maybe.map (Component.quantityFromInt >> config.updateItemQuantity itemIndex)
                        |> Maybe.withDefault config.noOp
            ]
            []
        ]


assemblyView : Config db msg -> Html msg
assemblyView config =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Assemblage" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ Impact.empty
                    |> Format.formatImpact config.impact
                ]
            ]
        , div [ class "card-body" ]
            [ div [ class "d-flex align-items-center gap-2" ]
                [ label [ for "assembly-country" ] [ text "Pays d'assemblage" ]
                , countrySelector
                    { countries = config.db.countries
                    , domId = "assembly-country"
                    , scope = config.scope
                    , select = config.updateAssemblyCountry
                    , selected = config.query.assemblyCountry
                    }
                ]
            ]
        ]


distributionView : Config db msg -> LifeCycle -> Html msg
distributionView { componentConfig, db, impact, query, scope, updateDistribution } lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Distribution" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ lifeCycle.distribution.impacts
                    |> Format.formatImpact impact
                ]
            ]
        , [ div [ class "d-flex align-items-center gap-1" ]
                [ Icon.lock, text "France" ]
                |> Just
          , div [ class "d-flex align-items-center w-33 justify-content-end gap-1" ]
                [ Icon.package
                , lifeCycle.distribution.volume
                    |> Format.cubicMeters
                ]
                |> Just
          , -- only render distribution process selector if any is available
            case Component.getAvailableDistributionProcesses db scope of
                [] ->
                    Nothing

                distributionProcesses ->
                    distributionProcesses
                        |> List.map
                            (\process ->
                                option
                                    [ value (Process.idToString process.id)
                                    , selected <|
                                        List.member (Just process.id)
                                            [ componentConfig.distribution.defaultProcess |> Scope.dictGetMaybe scope |> Maybe.map .id
                                            , query.distribution
                                            ]
                                    ]
                                    [ text (Process.getDisplayName process) ]
                            )
                        |> select
                            [ class "form-select w-50"
                            , onInput (Process.idFromString >> updateDistribution)
                            ]
                        |> Just
          ]
            |> List.filterMap identity
            |> div [ class "card-body d-flex justify-content-between align-items-center gap-2" ]
        ]


useStageView : Config db msg -> LifeCycle -> Html msg
useStageView ({ impact, query } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Utilisation" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ lifeCycle.use
                    |> Impact.sumImpacts
                    |> Format.formatImpact impact
                ]
            ]
        , div [ class "d-flex flex-column p-0" ]
            [ query.consumptions
                |> quantifiedProcessList config
                    { deletionLabel = "Supprimer cette consommation"
                    , emptyListLabel = "Aucune consommation"
                    , expandFn = Component.expandConsumptions
                    , impactsList = lifeCycle.use
                    , removeFn = config.removeConsumption
                    , updateAmount = config.updateConsumptionAmount
                    }
            , addConsumptionButton config
            ]
        ]


addConsumptionButton : Config db msg -> Html msg
addConsumptionButton ({ openSelectConsumptionModal, query } as config) =
    let
        availableProcesses =
            listAvailableProcesses config Category.Use
                |> List.filter
                    (\{ id } ->
                        query.consumptions
                            |> List.map Component.getConsumptionProcessId
                            |> List.member id
                            |> not
                    )

        autocompleteState =
            availableProcesses
                |> AutocompleteSelector.init Process.getDisplayName
    in
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , disabled <| List.isEmpty availableProcesses
        , onClick <| openSelectConsumptionModal autocompleteState
        ]
        [ Icon.plus
        , text "Ajouter une consommation"
        ]


endOfLifeView : Config db msg -> LifeCycle -> Html msg
endOfLifeView ({ componentConfig, query, scope, updateRecyclable } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ div [ class "IngredientPlaneOrBoatSelector" ]
                [ div [ class "mb-0 d-flex" ]
                    [ div [ class "h5" ] [ text "Fin de vie" ]
                    ]
                ]
            , div [ class "d-flex align-items-center justify-content-between" ]
                [ span [ class "pe-3" ] [ text "Ce produit est-il recyclable\u{00A0}?" ]
                , div [ class "form-check form-check-inline" ]
                    [ input
                        [ type_ "radio"
                        , class "form-check-input"
                        , name "recyclable"
                        , id "recyclable-yes"
                        , onClick <| updateRecyclable True
                        , checked query.recyclable
                        ]
                        []
                    , label [ class "form-check-label", for "recyclable-yes" ]
                        [ text "Oui" ]
                    ]
                , div [ class "form-check form-check-inline" ]
                    [ input
                        [ type_ "radio"
                        , class "form-check-input"
                        , name "recyclable"
                        , id "recyclable-no"
                        , onClick <| updateRecyclable False
                        , checked <| not query.recyclable
                        ]
                        []
                    , label [ class "form-check-label", for "recyclable-no" ]
                        [ text "Non" ]
                    ]
                ]
            , div [ class "d-flex align-items-center justify-content-end gap-2 ps-2", style "min-width" "80px" ]
                [ lifeCycle.production
                    |> Component.getEndOfLifeImpacts
                        { config = componentConfig
                        , db = config.db
                        , scope = config.scope
                        }
                        query.recyclable
                    |> Format.formatImpact config.impact
                ]
            ]
        , div [ class "card-body table-responsive p-0" ]
            [ if config.componentConfig.endOfLife |> Config.scopeEnabled scope then
                div []
                    [ table [ class "table mb-0 fs-7" ]
                        [ thead []
                            [ tr []
                                [ th [ class "text-end" ] [ text "Matière" ]
                                , th [ class "text-end" ] [ text "Masse" ]
                                , th [ class "text-end" ] [ text "Recyclage" ]
                                , th [ class "text-end" ] [ text "Incinération" ]
                                , th [ class "text-end" ] [ text "Enfouissement" ]
                                , th [ class "text-end pe-3" ] [ text "Impact" ]
                                ]
                            ]
                        , lifeCycle.production
                            |> Component.getEndOfLifeDetailedImpacts
                                { config = componentConfig
                                , db = config.db
                                , scope = config.scope
                                }
                                query.recyclable
                            |> AnyDict.toList
                            |> List.sortBy (Tuple.first >> Category.materialTypeToLabel)
                            |> List.concatMap (endOfLifeMaterialRow config)
                            |> tbody []
                        ]
                    ]

              else
                div [ class "card-body d-flex align-items-center justify-content-start gap-2" ]
                    [ Icon.info
                    , text <| "Fin de vie non disponible pour le périmètre " ++ Scope.toLabel config.scope
                    ]
            ]
        ]


endOfLifeMaterialRow : Config db msg -> ( Category.Material, EndOfLifeMaterialImpacts ) -> List (Html msg)
endOfLifeMaterialRow ({ componentConfig, query, scope } as config) ( materialType, { collected, nonCollected } ) =
    let
        collectionShare =
            scope |> Component.getEndOfLifeScopeCollectionRate componentConfig query.recyclable

        nonCollectionShare =
            Split.complement collectionShare

        formatShareImpacts isRecycling { impacts, process, split } =
            if split == Split.zero then
                text "-"

            else
                let
                    impact =
                        impacts |> Impact.getImpact config.impact.trigram

                    formatted =
                        impacts |> Format.formatImpact config.impact
                in
                div []
                    [ if isRecycling && Unit.impactToFloat impact == 0 then
                        span [ class "cursor-help", title "Le recyclage est ici considéré sans impact" ]
                            [ formatted, text "*" ]

                      else
                        case process of
                            Just process_ ->
                                span [ class "cursor-help", title <| Process.getTechnicalName process_ ]
                                    [ formatted ]

                            Nothing ->
                                formatted
                    , small []
                        [ text "\u{00A0}(", split |> Format.splitAsPercentage 0, text ")" ]
                    ]
    in
    [ tr [ class "table-active" ]
        [ th [ class "text-end" ] [ text <| Category.materialTypeToLabel materialType ]
        , td [ class "text-end", colspan 4 ] []
        , td [ class "text-end pe-3 fw-bold" ]
            [ [ collected |> Tuple.second |> .recycling |> .impacts
              , collected |> Tuple.second |> .incinerating |> .impacts
              , collected |> Tuple.second |> .landfilling |> .impacts
              , nonCollected |> Tuple.second |> .recycling |> .impacts
              , nonCollected |> Tuple.second |> .incinerating |> .impacts
              , nonCollected |> Tuple.second |> .landfilling |> .impacts
              ]
                |> Impact.sumImpacts
                |> Format.formatImpact config.impact
            ]
        ]
    , tr []
        [ td [ class "text-end" ] [ text "Collecté à ", Format.splitAsPercentage 0 collectionShare ]
        , td [ class "text-end" ] [ collected |> Tuple.first |> Format.kg ]
        , td [ class "text-end" ] [ collected |> Tuple.second |> .recycling |> formatShareImpacts True ]
        , td [ class "text-end" ] [ collected |> Tuple.second |> .incinerating |> formatShareImpacts False ]
        , td [ class "text-end" ] [ collected |> Tuple.second |> .landfilling |> formatShareImpacts False ]
        , td [ class "text-end pe-3" ]
            [ [ collected |> Tuple.second |> .recycling |> .impacts
              , collected |> Tuple.second |> .incinerating |> .impacts
              , collected |> Tuple.second |> .landfilling |> .impacts
              ]
                |> Impact.sumImpacts
                |> Format.formatImpact config.impact
            ]
        ]
    , tr []
        [ td [ class "text-end" ] [ text "Non-collecté à ", Format.splitAsPercentage 0 nonCollectionShare ]
        , td [ class "text-end" ] [ nonCollected |> Tuple.first |> Format.kg ]
        , td [ class "text-end" ] [ nonCollected |> Tuple.second |> .recycling |> formatShareImpacts True ]
        , td [ class "text-end" ] [ nonCollected |> Tuple.second |> .incinerating |> formatShareImpacts False ]
        , td [ class "text-end" ] [ nonCollected |> Tuple.second |> .landfilling |> formatShareImpacts False ]
        , td [ class "text-end pe-3" ]
            [ [ nonCollected |> Tuple.second |> .recycling |> .impacts
              , nonCollected |> Tuple.second |> .incinerating |> .impacts
              , nonCollected |> Tuple.second |> .landfilling |> .impacts
              ]
                |> Impact.sumImpacts
                |> Format.formatImpact config.impact
            ]
        ]
    ]
