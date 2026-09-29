module Views.Component exposing
    ( Config
    , Context(..)
    , editorView
    , itemEditorView
    , productCategorySelectorView
    , scopeLabels
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
        , ProductionItem(..)
        , Quantity
        , Query
        , Requirements
        , Results
        , TargetElement
        , TargetItem
        )
import Data.Component.Amount as Amount exposing (Amount)
import Data.Component.Config as Config
import Data.Component.ProductCategory as ProductCategory exposing (ProductCategory)
import Data.Country as Country exposing (Country)
import Data.Country.Code as CountryCode
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
import Html.Events as Events exposing (..)
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Quantity
import Route exposing (Route)
import Views.Alert as Alert
import Views.Button as Button
import Views.Component.DownArrow as DownArrow
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link
import Views.Transport as TransportView


type alias Config db msg =
    { componentConfig : Component.Config
    , context : Context
    , db : Component.DataContainer db
    , debug : Bool
    , detailed : List Index
    , docsUrl : Maybe String
    , explorerRoute : Maybe Route
    , impact : Definition
    , labels : Labels
    , lifeCycle : Result String LifeCycle
    , noOp : msg
    , openItemEditModal : TargetItem -> msg
    , openSelectAssemblyOperationModal : Autocomplete Process -> msg
    , openSelectConsumptionModal : Autocomplete Process -> msg
    , openSelectPackagingModal : Autocomplete Process -> msg
    , openSelectProcessModal : Category -> TargetItem -> Maybe Index -> Autocomplete Process -> msg
    , openSelectProductionItem : Autocomplete ProductionItem -> msg
    , query : Query
    , removeAssemblyOperation : Index -> msg
    , removeConsumption : Index -> msg
    , removeElement : TargetElement -> msg
    , removeElementTransform : TargetElement -> Index -> msg
    , removeItem : Index -> msg
    , removePackaging : Index -> msg
    , scope : Scope
    , setDetailed : List Index -> msg
    , toggleTransportByAir : Split -> msg
    , toggleTransportCooling : Bool -> msg
    , updateAssemblyCountry : Maybe CountryCode.Code -> msg
    , updateConsumptionAmount : Index -> Maybe Amount -> msg
    , updateDistribution : Result String Process.Id -> msg
    , updateElementAmount : TargetElement -> Maybe Amount -> msg
    , updateElementMaterialCountry : TargetElement -> Maybe CountryCode.Code -> msg
    , updateElementTransformCountry : TargetElement -> Index -> Maybe CountryCode.Code -> msg
    , updateItemName : TargetItem -> String -> msg
    , updateItemQuantity : Index -> Quantity -> msg
    , updatePackagingAmount : Index -> Maybe Amount -> msg
    , updateRecyclable : Bool -> msg
    }


type Context
    = GenericContext
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


type alias Labels =
    { add : String
    , addElement : String
    , elementNoun : String
    , elementNounPlural : String
    , empty : String
    , itemName : String
    , noun : String
    , nounPlural : String
    , productionHeading : String
    , search : String
    , select : String
    }


{-| Scoped label.

FIXME: we should make these configurable in components/config.json

-}
scopeLabels : Context -> Scope -> Labels
scopeLabels context scope =
    case context of
        GenericContext ->
            case scope of
                Scope.Generic Scope.Food2 ->
                    { add = "Ajouter un ingrédient"
                    , addElement = "Ajouter un sous-ingrédient"
                    , elementNoun = "Sous-ingrédient"
                    , elementNounPlural = "Sous-ingrédients"
                    , empty = "Aucun ingrédient"
                    , itemName = "Nom de l'ingrédient"
                    , noun = "Ingrédient"
                    , nounPlural = "Ingrédients"
                    , productionHeading = "Recette"
                    , search = "tapez ici le nom de l’ingrédient pour le rechercher"
                    , select = "Sélectionnez un ingrédient"
                    }

                _ ->
                    { add = "Ajouter un matériau"
                    , addElement = "Ajouter un sous-matériau"
                    , elementNoun = "Sous-matériau"
                    , elementNounPlural = "Sous-matériaux"
                    , empty = "Aucun matériau"
                    , itemName = "Nom du matériau"
                    , noun = "Matériau"
                    , nounPlural = "Matériaux"
                    , productionHeading = "Production des matériaux"
                    , search = "tapez ici le nom du matériau pour le rechercher"
                    , select = "Sélectionnez un matériau"
                    }

        TextileTrimsContext ->
            -- Note: in Textile context, raw element handling is not available
            { add = "Ajouter un accessoire"
            , addElement = "Ajouter un élément"
            , elementNoun = "Élément"
            , elementNounPlural = "Éléments"
            , empty = "Aucun accessoire"
            , itemName = "Nom de l'accessoire"
            , noun = "Accessoire"
            , nounPlural = "Accessoires"
            , productionHeading = "Accessoires"
            , search = "tapez ici le nom de l’accessoire pour le rechercher"
            , select = "Sélectionnez un accessoire"
            }


{-| A view data structure carrying an always consistent representation of the row cells
of a material or transform process table row. This avoids having to deal with colspans
and so on.
-}
type alias ProcessRowCells msg =
    { actions : Html msg
    , amount : Html msg
    , country : Html msg
    , impact : Html msg
    , label : Html msg
    , waste : Html msg
    }


emptyProcessRowCells : ProcessRowCells msg
emptyProcessRowCells =
    { actions = text ""
    , amount = text ""
    , country = text ""
    , impact = text ""
    , label = text ""
    , waste = text ""
    }


{-| Renders an item editor modal element process table row
-}
processRow : List (Attribute msg) -> ProcessRowCells msg -> Html msg
processRow attributes cells =
    tr attributes
        [ td
            [ class "text-end align-middle text-nowrap ps-3 py-2"
            , style "min-width" "130px"
            , style "max-width" "150px"
            ]
            [ cells.amount ]
        , td [ class "align-middle", style "min-width" "16rem" ]
            [ cells.label ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ cells.waste ]
        , td [ class "align-middle", style "min-width" "12rem" ]
            [ cells.country ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ cells.impact ]
        , td [ class "pe-3 text-end align-middle text-nowrap" ]
            [ cells.actions ]
        ]


{-| A view data structure carrying an always consistent representation of the
cells of a production item line table row. Avoids having to deal with colspans
and so on.
-}
type alias ItemRowCells msg =
    { actions : Html msg
    , expander : Html msg
    , impacts : Html msg
    , label : Html msg
    , quantity : Html msg
    , totalMass : Html msg
    , unitMass : Html msg
    }


emptyItemRowCells : ItemRowCells msg
emptyItemRowCells =
    { actions = text ""
    , expander = text ""
    , impacts = text ""
    , label = text ""
    , quantity = text ""
    , totalMass = text ""
    , unitMass = text ""
    }


{-| Renders a production item table row
-}
itemRow : List (Attribute msg) -> ItemRowCells msg -> Html msg
itemRow attributes cells =
    tr attributes
        [ td [ class "ps-2 py-2 align-middle" ]
            [ cells.expander ]
        , td [ class "py-2 text-end align-middle text-nowrap" ]
            [ cells.unitMass ]
        , td [ class "py-2 align-middle text-truncate w-100", style "max-width" "0" ]
            [ cells.label ]
        , td [ class "py-2 align-middle text-center" ]
            [ cells.quantity ]
        , td [ class "py-2 text-end align-middle text-nowrap" ]
            [ cells.totalMass ]
        , td [ class "py-2 text-end align-middle text-nowrap", style "min-width" "80px" ]
            [ cells.impacts ]
        , td [ class "py-2 pe-3 text-end align-middle text-nowrap" ]
            [ cells.actions ]
        ]


addProductionItemButton : Config db msg -> Html msg
addProductionItemButton ({ db } as config) =
    let
        availableComponents =
            db.components
                |> List.filter (not << Component.isEmpty)
                |> List.filter (.scope >> (==) config.scope)
                |> List.map ComponentItem

        availableMaterials =
            Category.Material
                |> listAvailableProcesses config
                -- Exclude packaging materials as they're available in a dedicated section
                |> List.filter (\{ categories } -> not <| List.member Category.Packaging categories)
                |> List.map MaterialItem

        availableProductionItems =
            availableComponents ++ availableMaterials

        autocompleteState =
            availableProductionItems
                |> List.sortBy Component.productionItemToLabel
                |> AutocompleteSelector.init Component.productionItemToLabel
    in
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , disabled <| List.isEmpty availableProductionItems
        , onClick <| config.openSelectProductionItem autocompleteState
        ]
        [ Icon.plus
        , text config.labels.add
        ]


addElementButton : Config db msg -> TargetItem -> Html msg
addElementButton config targetItem =
    button
        [ type_ "button"
        , class "btn btn-primary"
        , class "d-flex justify-content-center align-items-center gap-1"
        , createElementMaterialAutocomplete config.db config.scope
            |> config.openSelectProcessModal Category.Material targetItem Nothing
            |> onClick
        ]
        [ Icon.plus
        , text config.labels.addElement
        ]


addPackagingButton : Config db msg -> Html msg
addPackagingButton ({ query } as config) =
    let
        availablePackagingProcesses =
            listAvailableProcesses config Category.Packaging
                |> List.filter
                    (\{ id } ->
                        query.packagings
                            |> List.map Component.getPackagingProcessId
                            |> List.member id
                            |> not
                    )

        autocompleteState =
            availablePackagingProcesses
                |> AutocompleteSelector.init Process.getDisplayName
    in
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , onClick <| config.openSelectPackagingModal autocompleteState
        , disabled <| List.isEmpty availablePackagingProcesses
        ]
        [ Icon.plus
        , text "Ajouter un emballage"
        ]


{-| Creates an Autocomplete listing available, scoped, non-packaging materials
-}
createElementMaterialAutocomplete : Component.DataContainer db -> Scope -> Autocomplete Process
createElementMaterialAutocomplete db scope =
    Category.Material
        |> listAvailableProcesses { db = db, scope = scope }
        -- Exclude packaging materials as they're available in a dedicated section
        |> List.filter (\{ categories } -> not <| List.member Category.Packaging categories)
        |> AutocompleteSelector.init Process.getDisplayName


addElementTransformButton : Config db msg -> Process -> TargetElement -> Html msg
addElementTransformButton { db, openSelectProcessModal, query, scope } material ( targetItem, elementIndex ) =
    let
        availableTransformProcesses =
            db.processes
                |> List.filter .visible
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
        , class "btn btn-sm btn-outline-primary text-nowrap"
        , class "d-flex align-items-center gap-1"
        , disabled <| List.isEmpty availableTransformProcesses
        , autocompleteState
            |> openSelectProcessModal Category.Transform targetItem (Just elementIndex)
            |> onClick
        ]
        [ Icon.plus
        , text "Ajouter une transformation"
        ]


itemTableHeader : Config db msg -> Html msg
itemTableHeader config =
    itemRow [ class "fs-8 fw-normal text-muted border-bottom" ]
        { emptyItemRowCells
            | impacts = text "Impacts"
            , label = text config.labels.itemName
            , quantity = text "Quantité"
            , totalMass = text "Masse totale"
            , unitMass = text "Masse unitaire"
        }


itemView : Config db msg -> Index -> ExpandedItem -> Results -> List (Html msg)
itemView config itemIndex { component, elements, quantity } itemResults =
    let
        collapsed =
            config.detailed
                |> List.member itemIndex
                |> not
    in
    [ tbody
        (if itemIndex > 0 then
            -- Better visually separate components items when they're stacked and opened
            [ style "border-top" "1px solid #777" ]

         else
            []
        )
        [ itemRow [ class "border-bottom", classList [ ( "table-info", not collapsed ) ] ]
            { actions = itemActions config itemIndex component
            , expander = expandToggler config itemIndex collapsed
            , impacts =
                Component.getTotalImpacts itemResults
                    |> Format.formatImpact config.impact
            , label = span [ title component.name ] [ text component.name ]
            , quantity = quantity |> quantityInput config itemIndex
            , totalMass =
                Component.extractMass itemResults
                    |> Format.kg
            , unitMass =
                Component.extractUnitMass itemResults
                    |> Format.kg
            }
        ]
    , itemDetailedRows config elements itemResults
        |> tbody [ class "table-light", id <| itemDetailsId itemIndex, hidden collapsed ]
    ]


expandToggler : Config db msg -> Index -> Bool -> Html msg
expandToggler config itemIndex collapsed =
    if config.context == TextileTrimsContext then
        text ""

    else
        button
            [ type_ "button"
            , class "btn btn-link text-muted text-decoration-none font-monospace fs-6 p-0 m-0"
            , title "Déplier/Replier"
            , attribute "aria-label" "Déplier/Replier"
            , attribute "aria-expanded"
                (if collapsed then
                    "false"

                 else
                    "true"
                )
            , attribute "aria-controls" <| itemDetailsId itemIndex
            , onClick <|
                config.setDetailed <|
                    if collapsed then
                        LE.unique <| itemIndex :: config.detailed

                    else
                        List.filter ((/=) itemIndex) config.detailed
            ]
            [ if collapsed then
                text "▶"

              else
                text "▼"
            ]


itemActions : Config db msg -> Index -> Component -> Html msg
itemActions config itemIndex component =
    let
        deleteButton =
            button
                [ type_ "button"
                , class "btn btn-sm btn-outline-secondary"
                , attribute "aria-label" "Supprimer"
                , onClick (config.removeItem itemIndex)
                ]
                [ Icon.trash ]

        editButton =
            button
                [ type_ "button"
                , class "btn btn-sm btn-outline-secondary"
                , attribute "aria-label" "Modifier la composition"
                , onClick (config.openItemEditModal ( component, itemIndex ))
                ]
                [ Icon.pencil ]
    in
    div [ class "btn-group" ]
        (if config.context == TextileTrimsContext then
            [ deleteButton ]

         else
            [ editButton, deleteButton ]
        )


itemDetailsId : Index -> String
itemDetailsId itemIndex =
    "item-table-" ++ String.fromInt itemIndex


itemDetailedRows : Config db msg -> List ExpandedElement -> Results -> List (Html msg)
itemDetailedRows config elements itemResults =
    if List.isEmpty elements then
        List.singleton <|
            itemRow [ class "bg-light border-bottom" ]
                { emptyItemRowCells | label = text "Aucun élément" }

    else
        List.map2
            (elementSummaryRow config itemResults)
            elements
            (Component.extractItems itemResults)


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
lifeCycleView ({ db, docsUrl, explorerRoute, impact, query, scope } as config) lifeCycle =
    div [ class "d-flex flex-column" ]
        [ div [ class "card shadow-sm" ]
            [ div [ class "card-header d-flex align-items-center justify-content-between gap-2" ]
                [ h2 [ class "h5 mb-0" ]
                    [ text config.labels.productionHeading
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
                , div [ class "d-flex flex-fill justify-content-end align-items-center gap-2" ]
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
                , documentationLink config "production"
                ]
            , if List.isEmpty query.items then
                div [ class "card-body" ]
                    [ text config.labels.empty
                    ]

              else
                case Component.expandItems db query.items of
                    Err error ->
                        error |> simpleError (Just "Erreur")

                    Ok expandedItems ->
                        div [ class "table-responsive" ]
                            [ table [ class "table table-sm table-borderless mb-0" ]
                                (thead []
                                    [ itemTableHeader config ]
                                    :: List.concat
                                        (List.map3 (itemView config)
                                            (List.range 0 (List.length query.items - 1))
                                            expandedItems
                                            (Component.extractItems lifeCycle.production)
                                        )
                                )
                            ]
            , addProductionItemButton config
            ]
        , if Scope.isGeneric scope && not (List.isEmpty query.items) then
            div []
                [ DownArrow.view
                    [ div [ class "d-flex justify-content-end align-items-center gap-1" ]
                        [ text "Transport", span [] [ Icon.package, Icon.forkWay, Icon.package ] ]
                    ]
                    [ div [ class "d-flex gap-2" ]
                        [ lifeCycle.transports.toAssembly.impacts
                            |> Format.formatImpact impact
                        , smallDocumentationLink config "transport"
                        ]
                    ]
                , assemblyView config lifeCycle
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


documentationLink : Config db msg -> String -> Html msg
documentationLink { componentConfig, scope } section =
    case Component.getDocLink componentConfig scope section of
        Just docUrl ->
            Button.docsPillLink
                [ class "bg-secondary"
                , style "height" "24px"
                , href docUrl
                , Attr.title "Documentation"
                , target "_blank"
                ]
                [ Icon.question ]

        Nothing ->
            text ""


smallDocumentationLink : Config db msg -> String -> Html msg
smallDocumentationLink { componentConfig, scope } section =
    case Component.getDocLink componentConfig scope section of
        Just docUrl ->
            Button.smallPillLink
                [ class "text-muted"
                , href docUrl
                , Attr.title "Documentation"
                , target "_blank"
                ]
                [ Icon.question ]

        Nothing ->
            text ""


packagingView : Config db msg -> LifeCycle -> Html msg
packagingView ({ query } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between gap-2" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Emballage" ]
            , div [ class "d-flex flex-fill justify-content-end align-items-center gap-2" ]
                [ lifeCycle.packaging
                    |> Impact.sumImpacts
                    |> Format.formatImpact config.impact
                ]
            , documentationLink config "packaging"
            ]
        , query.packagings
            |> quantifiedProcessList config
                lifeCycle
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


quantifiedProcessList : Config db msg -> LifeCycle -> QuantifiedProcessListConfig quantified msg -> List quantified -> Html msg
quantifiedProcessList { db, impact } lifeCycle listConfig quantifiedProcesses =
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
                                            [ amountInput
                                                { event = listConfig.updateAmount index
                                                , readonly = List.member Category.ProductMassDependent process.categories
                                                , unit = process.unit
                                                }
                                                (Component.useProcessAmount lifeCycle process amount)
                                            ]
                                        , td
                                            [ class "align-middle text-truncate w-66 cursor-help "
                                            , style "max-width" "0"
                                            , [ Process.getDisplayName process
                                              , Process.getTechnicalName process
                                              ]
                                                |> String.join "\n"
                                                |> title
                                            ]
                                            [ text <| Process.getDisplayName process ]
                                        , td [ class "align-middle text-end text-nowrap" ]
                                            [ listConfig.impactsList
                                                |> LE.getAt index
                                                |> Maybe.withDefault Impact.empty
                                                |> Format.formatImpact impact
                                            ]
                                        , td [ class "align-middle pe-3 pt-2" ]
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
            |> transportToDistributionView config lifeCycle.productMass
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

        -- transport cooling is only available when both boat and lorry cooled transport
        -- processes are available in current scope
        transportCoolingAvailable =
            List.all (\{ scopes } -> List.member scope scopes)
                [ componentConfig.transports.modeProcesses.boatCooling
                , componentConfig.transports.modeProcesses.lorryCooling
                ]
    in
    DownArrow.view
        [ div [ class "d-flex justify-content-end align-items-center gap-2" ]
            [ text "Transport"
            , Icon.package
            , Format.kg mass
            , if transportCoolingAvailable then
                cooledTransportToggler config

              else
                text ""
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
            , smallDocumentationLink config "transport"
            ]
        ]


togglerView : { checked : Bool, id : String, label : String, onCheck : Bool -> msg } -> Html msg
togglerView { checked, id, label, onCheck } =
    div [ class "d-flex justify-content-end align-items-center gap-2" ]
        [ input
            [ type_ "checkbox"
            , class "form-check-input"
            , Attr.id id
            , Attr.checked checked
            , Events.onCheck onCheck
            ]
            []
        , Html.label [ class "form-check-label", for id ]
            [ text label ]
        ]


airTransportToggler : Config db msg -> Html msg
airTransportToggler ({ query } as config) =
    togglerView
        { checked = query.transportOptions.byAir == Split.full
        , id = "transportByAirSwitch"
        , label = "par avion"
        , onCheck = Split.fromBool >> config.toggleTransportByAir
        }


cooledTransportToggler : Config db msg -> Html msg
cooledTransportToggler ({ query } as config) =
    togglerView
        { checked = query |> Component.getTransportCooling (requirementsFromConfig config)
        , id = "transportCoolingSwitch"
        , label = "réfrigéré"
        , onCheck = config.toggleTransportCooling
        }


noTransportView : Html msg
noTransportView =
    DownArrow.view [] []


type alias AmountInputConfig msg =
    { event : Maybe Amount -> msg
    , readonly : Bool
    , unit : Process.Unit
    }


amountInput : AmountInputConfig msg -> Amount -> Html msg
amountInput { event, readonly, unit } amount =
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
            ([ type_ "number"
             , class "form-control form-control-sm text-end incdec-arrows-left"
             , value stringAmount
             , Attr.min "0"
             , step stepValue
             , onInput <| Amount.fromString >> event
             ]
                ++ (if readonly then
                        [ Attr.readonly readonly
                        , title "Cette quantité n'est pas modifiable"
                        , class "cursor-not-allowed"
                        ]

                    else
                        []
                   )
            )
            []
        , small [ class "input-group-text fs-8" ]
            [ text <| Process.unitToString unit ]
        ]


type alias CountrySelector msg =
    { attrs : List (Attribute msg)
    , countries : List Country
    , disabled : Bool
    , domId : String
    , scope : Scope
    , select : Maybe CountryCode.Code -> msg
    , selected : Maybe CountryCode.Code
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
                        |> Maybe.map CountryCode.toString
                        |> Maybe.withDefault ""
                        |> value
                    , selected <| config.selected == maybeCode
                    ]
                    [ text name ]
            )
        |> select
            (config.attrs
                ++ [ class "form-select w-33"
                   , id config.domId
                   , autocomplete False
                   , disabled config.disabled
                   , onInput <|
                        \str ->
                            config.select <|
                                if String.isEmpty str then
                                    Nothing

                                else
                                    Just <| CountryCode.fromString str
                   ]
            )


{-| Renders elements summary when an item is expanded
-}
elementSummaryRow : Config db msg -> Results -> ExpandedElement -> Results -> Html msg
elementSummaryRow config itemResults { amount, material, transforms } elementResults =
    let
        elementMass =
            Component.extractMass elementResults

        materialLabel { country, process } =
            String.join " "
                [ Process.getDisplayName process
                , "(" ++ (country |> Maybe.map .name |> Maybe.withDefault "Inconnu") ++ ")"
                ]

        amountInfo =
            span [ class "d-flex text-muted fs-8" ]
                [ if material.process.unit /= Process.Kilogram then
                    span [] [ text "(", Format.amount material.process amount, text ")\u{00A0}" ]

                  else
                    text ""
                , Format.kg elementMass
                ]
    in
    itemRow [ class "fs-7 border-top" ]
        { emptyItemRowCells
            | impacts =
                Component.getTotalImpacts elementResults
                    |> Format.formatImpact config.impact
            , label =
                div [ class "d-flex flex-column" ]
                    [ div [ title <| materialLabel material ]
                        [ text <| materialLabel material
                        ]
                    , div
                        [ class "d-flex align-items-center gap-1 text-muted"
                        , title <| Component.transformListToString transforms
                        ]
                        [ if List.isEmpty transforms then
                            text "Aucune transformation"

                          else
                            text <| Component.transformListToString transforms
                        ]
                    ]
            , unitMass =
                div [ class "d-flex flex-column align-items-end" ]
                    [ Component.extractUnitMass itemResults
                        |> Component.elementMassShare elementMass
                        |> Format.splitAsPercentage 1
                    , amountInfo
                    ]
        }


itemEditorView : Config db msg -> TargetItem -> Html msg
itemEditorView ({ query } as config) ( _, itemIndex ) =
    case ( config.lifeCycle, Component.expandItems config.db query.items ) of
        ( Ok lifeCycle, Ok expandedItems ) ->
            case LE.getAt itemIndex expandedItems of
                Just expandedItem ->
                    let
                        itemResults =
                            lifeCycle.production
                                |> Component.extractItems
                                |> LE.getAt itemIndex
                                |> Maybe.withDefault Component.emptyResults
                    in
                    compositionModalBody config ( expandedItem.component, itemIndex ) expandedItem itemResults

                Nothing ->
                    simpleError (Just "Erreur") "Composant introuvable"

        ( Err error, _ ) ->
            simpleError (Just "Erreur") error

        ( Ok _, Err error ) ->
            simpleError (Just "Erreur") error


compositionModalBody : Config db msg -> TargetItem -> ExpandedItem -> Results -> Html msg
compositionModalBody config targetItem { component, elements } itemResults =
    let
        elementCount =
            List.length elements

        compositionStat : String -> List (Html msg) -> Html msg
        compositionStat caption value =
            div [ class "d-flex flex-column" ]
                [ span [ class "fw-bold" ] value
                , span [ class "fs-8 text-muted" ] [ text caption ]
                ]
    in
    div [ class "d-flex flex-column gap-3 p-3" ]
        [ div []
            [ label [ class "form-label", for "component-composition-label" ]
                [ text "Libellé" ]
            , input
                [ type_ "text"
                , class "form-control"
                , id "component-composition-label"
                , placeholder config.labels.itemName
                , value component.name
                , onInput (config.updateItemName targetItem)
                ]
                []
            ]
        , div [ class "d-flex flex-wrap gap-4 justify-content-evenly align-items-center bg-info-subtle border rounded p-3" ]
            [ text "Détails de la composition"
            , compositionStat
                (String.toLower <|
                    if elementCount == 1 then
                        config.labels.elementNoun

                    else
                        config.labels.elementNounPlural
                )
                [ text <| String.fromInt elementCount ]
            , compositionStat "poids total"
                [ Component.extractUnitMass itemResults
                    |> Format.kg
                ]
            , compositionStat "impact total"
                [ Component.getTotalImpacts itemResults
                    |> Format.formatImpact config.impact
                ]
            ]
        , div [ class "d-flex justify-content-between align-items-center gap-2" ]
            [ h3 [ class "h5 mb-0" ]
                [ text <| "Liste des " ++ String.toLower config.labels.nounPlural ++ " et leurs étapes de transformation" ]
            , addElementButton config targetItem
            ]
        , div [ class "table-responsive" ]
            [ table [ class "CompositionElements table table-sm table-borderless mb-0 w-100" ] <|
                if List.isEmpty elements then
                    [ tbody []
                        [ processRow [] { emptyProcessRowCells | label = text "Aucun élément" }
                        ]
                    ]

                else
                    List.map3
                        (\elementIndex expandedElement ->
                            elementCompositionRows config itemResults targetItem elementIndex expandedElement
                                >> tbody [ class "composition-element" ]
                        )
                        (List.range 0 (elementCount - 1))
                        elements
                        (Component.extractItems itemResults)
                        |> List.intersperse
                            -- use an empty table row to separate elements
                            (tbody [ class "composition-element-gap" ]
                                [ tr [ attribute "aria-hidden" "true" ]
                                    [ td [ colspan 6 ] [] ]
                                ]
                            )
            ]
        ]


elementCompositionRows :
    Config db msg
    -> Results
    -> TargetItem
    -> Index
    -> ExpandedElement
    -> Results
    -> List (Html msg)
elementCompositionRows config itemResults targetItem elementIndex ({ amount, material, transforms } as expandedElement) elementResults =
    let
        targetElement =
            ( targetItem, elementIndex )

        elementCooling =
            Process.isTransportedCooled material.process

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

        elementMass =
            Component.extractMass elementResults

        share =
            Component.extractUnitMass itemResults
                |> Component.elementMassShare elementMass

        transportImpacts =
            stageItems
                |> List.filter (Component.extractStage >> (==) (Just Component.TransportStage))
                |> List.map Component.extractImpacts
                |> Impact.sumImpacts

        elementSummary =
            processRow [ class "fs-7" ]
                { emptyProcessRowCells
                    | amount =
                        amount |> elementAmountInput config targetElement material.process
                    , impact =
                        if transportImpacts == Impact.empty then
                            Component.getTotalImpacts elementResults
                                |> Format.formatImpact config.impact

                        else
                            span []
                                [ Component.getTotalImpacts elementResults
                                    |> Format.formatImpact config.impact
                                    |> List.singleton
                                    |> span [ class "ImpactPill" ]
                                , span [ class "text-muted fw-normal" ]
                                    [ text " (dont transport "
                                    , transportImpacts |> Format.formatImpact config.impact
                                    , text ")"
                                    ]
                                ]
                    , label =
                        span [ class "text-muted" ]
                            [ text <| "Poids du " ++ String.toLower config.labels.elementNoun ++ "\u{00A0}: "
                            , span [ class "fw-bold" ] [ Format.kg elementMass ]
                            , text " ("
                            , share |> Format.splitAsPercentage 0
                            , text ")"
                            ]
                }

        transformRows =
            if List.isEmpty transforms then
                [ processRow [ class "fs-7 text-muted" ]
                    { emptyProcessRowCells | label = text "Aucune transformation" }
                ]

            else
                processColumnHeaders
                    { amount = "Quantité"
                    , country = "Origine"
                    , label = "Intitulé"
                    , waste = "Pertes"
                    }
                    :: transformProcessRows config
                        elementCooling
                        targetElement
                        materialResults
                        material.country
                        transformsResults
                        transforms
    in
    elementHeader config targetElement
        :: elementSummary
        :: compositionSectionHeading "Matière première" Nothing
        :: materialCompositionRows config targetElement materialResults material
        ++ compositionSectionHeading "Étape de transformation"
            (Just <| addElementTransformButton config material.process targetElement)
        :: transformRows
        ++ [ LE.last transformsResults
                |> Maybe.map Component.extractMass
                |> Maybe.withDefault (Component.extractMass materialResults)
                |> finalElementTransportView config elementCooling (Component.getFinalElementCountry expandedElement)
           ]


compositionSectionHeading : String -> Maybe (Html msg) -> Html msg
compositionSectionHeading title maybeAction =
    -- Note: heading rows span the table because they're not data. Process rows keep defining
    -- the shared columns, so amounts and impacts stay aligned across all elements
    tr [ class "composition-section" ]
        [ td [ class "p-3 pb-2", colspan 6 ]
            [ div [ class "d-flex justify-content-between align-items-center gap-2" ]
                [ span [ class "fw-bold" ] [ text title ]
                , maybeAction |> Maybe.withDefault (text "")
                ]
            ]
        ]


elementHeader : Config db msg -> TargetElement -> Html msg
elementHeader config (( ( component, _ ), elementIndex ) as targetElement) =
    tr []
        [ td [ class "py-2 px-3", colspan 6 ]
            [ div [ class "d-flex justify-content-between align-items-center gap-2" ]
                [ span [ class "fw-bold" ]
                    [ text <| config.labels.elementNoun ++ " " ++ String.fromInt (elementIndex + 1) ]
                , if List.length component.elements > 1 then
                    deleteElementButton config targetElement

                  else
                    text ""
                ]
            ]
        ]


deleteElementButton : Config db msg -> TargetElement -> Html msg
deleteElementButton config targetElement =
    button
        [ type_ "button"
        , class "btn btn-sm btn-outline-secondary text-nowrap"
        , class "d-flex align-items-center gap-1"
        , attribute "aria-label" "Supprimer l’élément"
        , onClick (config.removeElement targetElement)
        ]
        [ Icon.trash
        , text "Supprimer"
        ]


elementAmountInput : Config db msg -> TargetElement -> Process -> Amount -> Html msg
elementAmountInput config targetElement process amount =
    if config.scope == Scope.Textile then
        Format.amount process amount

    else
        amountInput
            { event = config.updateElementAmount targetElement
            , readonly = False
            , unit = process.unit
            }
            amount


processColumnHeaders : { amount : String, country : String, label : String, waste : String } -> Html msg
processColumnHeaders headers =
    processRow [ class "fs-8 fw-normal text-muted" ]
        { emptyProcessRowCells
            | amount = text headers.amount
            , country = text headers.country
            , impact = text "Impact"
            , label = text headers.label
            , waste = text headers.waste
        }


{-| Render transports from last transform step to assembly or distribution stage
-}
finalElementTransportView : Config db msg -> Bool -> Maybe Country -> Mass -> Html msg
finalElementTransportView ({ db, query, scope } as config) cooling elementCountry mass =
    db.countries
        |> Scope.anyOf [ scope ]
        |> Country.resolveMaybe query.assembly.country
        |> Result.map (elementTransportView config [ class "subdued" ] cooling mass elementCountry)
        |> Result.withDefault (text "")


listAvailableProcesses :
    { config | db : Component.DataContainer db, scope : Scope }
    -> Category
    -> List Process
listAvailableProcesses { db, scope } category =
    db.processes
        |> List.filter .visible
        |> Scope.anyOf [ scope ]
        |> Process.listByCategory category
        |> List.sortBy Process.getDisplayName


modifyMaterialButton : Config db msg -> TargetElement -> Html msg
modifyMaterialButton config ( targetItem, elementIndex ) =
    button
        [ type_ "button"
        , class "btn btn-sm btn-outline-primary text-nowrap"
        , attribute "aria-label" "Changer de matière première"
        , listAvailableProcesses config Category.Material
            |> AutocompleteSelector.init Process.getDisplayName
            |> config.openSelectProcessModal Category.Material targetItem (Just elementIndex)
            |> onClick
        ]
        [ Icon.pencil ]


materialCompositionRows :
    Config db msg
    -> TargetElement
    -> Results
    -> ExpandedLocalizedProcess
    -> List (Html msg)
materialCompositionRows config targetElement materialResults material =
    let
        complementsImpacts =
            Component.extractComplementsImpacts materialResults

        materialRow =
            processRow [ class "fs-7" ]
                { emptyProcessRowCells
                    | actions = modifyMaterialButton config targetElement
                    , amount =
                        Component.extractAmount materialResults
                            |> Format.amount material.process
                    , country =
                        regionSelector
                            { countries = config.db.countries
                            , domId = "material-country-" ++ Component.targetElementToString targetElement
                            , scope = config.scope
                            , select = config.updateElementMaterialCountry targetElement
                            , selected = material.country |> Maybe.map .code
                            }
                    , impact =
                        span [ class "ImpactPill" ]
                            [ Component.getTotalImpacts materialResults
                                |> Format.formatImpact config.impact
                            ]
                    , label =
                        span [ class "fw-bold", title <| Process.getDisplayName material.process ]
                            [ text <| Process.getDisplayName material.process
                            ]
                }

        complementsRow =
            if complementsImpacts /= Complement.emptyComplementsResultsImpacts then
                [ processRow [ class "fs-7 text-muted" ]
                    { emptyProcessRowCells
                        | impact =
                            complementsImpacts
                                |> Complement.mergeComplementsResultsImpacts
                                |> Format.formatImpact config.impact
                        , label =
                            span
                                [ class "cursor-help fs-8"
                                , title (Format.formatComplementsResultsImpactsToString config.impact complementsImpacts)
                                ]
                                [ span [ class "ComponentElementIcon" ] [ Icon.calculator ]
                                , text "Dont compléments"
                                ]
                    }
                ]

            else
                []
    in
    materialRow :: complementsRow


elementTransportView : Config db msg -> List (Attribute msg) -> Bool -> Mass -> Maybe Country -> Maybe Country -> Html msg
elementTransportView ({ query } as config) attributes cooling transportedMass maybeFrom maybeTo =
    let
        { transportOptions } =
            query

        displayElementTransport =
            transportedMass
                |> Component.computeTransportedMassImpacts (requirementsFromConfig config)
                    -- Notes:
                    --   - air transport is always disabled before assembly (see Component.computeTransports)
                    --   - cooling before assembly is driven by the material process, not the transport option
                    { transportOptions | byAir = Split.zero, cooling = Just cooling }
                    maybeFrom
                    maybeTo
    in
    case displayElementTransport of
        Err error ->
            processRow attributes
                { emptyProcessRowCells
                    | label = error |> simpleError (Just "Erreur de calcul de distance")
                }

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
            processRow (class "fs-7 text-muted" :: attributes)
                { emptyProcessRowCells
                    | country =
                        div [ class "d-flex flex-wrap justify-content-end align-items-center gap-2" ] <|
                            -- Note: it's supposed for now that a plane can transport either cooled or non-cooled stuff
                            renderModeIfAny Icon.plane transport.air
                                ++ renderModeIfAny Icon.boat transport.sea
                                ++ renderModeIfAny Icon.boatCooled transport.seaCooled
                                ++ renderModeIfAny Icon.bus transport.road
                                ++ renderModeIfAny Icon.busCooled transport.roadCooled
                                ++ [ Icon.package
                                   , Format.kg transportedMass
                                   ]
                    , impact =
                        transport.impacts
                            |> Format.formatImpact config.impact
                    , label =
                        text <| "Transport " ++ renderCountry maybeFrom ++ " → " ++ renderCountry maybeTo
                }


transformProcessRows :
    Config db msg
    -> Bool
    -> TargetElement
    -> Results
    -> Maybe Country
    -> List Results
    -> List ExpandedLocalizedProcess
    -> List (Html msg)
transformProcessRows config cooling targetElement materialResults materialCountry transformsResults transforms =
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
                    |> elementTransportView config [] cooling previousMass previousCountry
                , processRow [ class "fs-7 border-top" ]
                    { emptyProcessRowCells
                        | actions =
                            button
                                [ type_ "button"
                                , class "btn btn-sm btn-outline-secondary"
                                , attribute "aria-label" "Supprimer la transformation"
                                , transformIndex
                                    |> config.removeElementTransform targetElement
                                    |> onClick
                                ]
                                [ Icon.trash ]
                        , amount =
                            Component.extractAmount transformResult
                                |> Format.amount transform.process
                        , country =
                            regionSelector
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
                        , impact =
                            span [ class "ImpactPill" ]
                                [ Component.extractImpacts transformResult
                                    |> Format.formatImpact config.impact
                                ]
                        , label =
                            span [ class "fw-bold cursor-help", title tooltipText ]
                                [ text <| Process.getDisplayName transform.process
                                ]
                        , waste =
                            Format.qtyVariationRatioAsWastePercent transform.process.qtyVariationRatio
                    }
                ]
            )
        |> List.concat


type alias RegionSelector msg =
    { countries : List Country
    , domId : String
    , scope : Scope
    , select : Maybe CountryCode.Code -> msg
    , selected : Maybe CountryCode.Code
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
                        |> Maybe.map CountryCode.toString
                        |> Maybe.withDefault ""
                        |> value
                    , selected <| config.selected == maybeCode
                    ]
                    [ text <|
                        case maybeCode of
                            Just code ->
                                name ++ " (" ++ CountryCode.toString code ++ ")"

                            Nothing ->
                                "---"
                    ]
            )
        |> select
            [ class "RegionSelector form-select form-select-sm w-100"
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
                            Just <| CountryCode.fromString str
            ]


quantityInput : Config db msg -> Index -> Quantity -> Html msg
quantityInput config itemIndex quantity =
    div [ class "input-group", style "width" "70px" ]
        [ input
            [ type_ "number"
            , class "form-control form-control-sm text-end"
            , quantity |> Component.quantityToInt |> String.fromInt |> value
            , step "1"
            , Attr.min "1"
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


assemblyView : Config db msg -> LifeCycle -> Html msg
assemblyView ({ db, impact, query, scope } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between gap-2" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Assemblage" ]
            , div [ class "d-flex flex-fill justify-content-end align-items-center gap-2" ]
                [ lifeCycle.assembly
                    |> Component.extractImpacts
                    |> Format.formatImpact impact
                ]
            , documentationLink config "assembly"
            ]
        , div [ class "card-body d-flex flex-column gap-3 p-0" ]
            [ div [ class "d-flex align-items-center gap-2 px-3 pt-3" ]
                [ label [ for "assembly-country" ] [ text "Pays d’assemblage" ]
                , countrySelector
                    { attrs = []
                    , countries = db.countries
                    , disabled = False
                    , domId = "assembly-country"
                    , scope = scope
                    , select = config.updateAssemblyCountry
                    , selected = query.assembly.country
                    }
                ]
            , case
                query
                    |> Component.getAssemblyOperations (requirementsFromConfig config)
                    |> Component.expandAssembly db query.assembly.country
              of
                Err error ->
                    div [ class "px-3 pb-3" ] [ error |> simpleError (Just "Erreur") ]

                Ok expandedOperations ->
                    if List.isEmpty expandedOperations then
                        div [ class "px-3 pb-3 text-muted" ] [ text "Aucun procédé d’assemblage" ]

                    else
                        table [ class "table table-sm mb-0 border-top" ]
                            [ thead []
                                [ tr [ class "fs-7 text-muted bg-light" ]
                                    [ th [ class "bg-light ps-3 align-middle", Attr.scope "col" ] [ text "Opération" ]
                                    , th [ class "bg-light align-middle text-end", Attr.scope "col" ] [ text "Pertes" ]
                                    , th [ class "bg-light align-middle text-end", Attr.scope "col" ] [ text "Masse" ]
                                    , th [ class "bg-light align-middle text-end", Attr.scope "col" ] [ text "Impact" ]
                                    , th [ class "bg-light align-middle", Attr.scope "col" ] []
                                    ]
                                ]
                            , tbody []
                                (expandedOperations
                                    |> List.indexedMap
                                        (\index { process } ->
                                            let
                                                operationResult =
                                                    lifeCycle.assembly
                                                        |> Component.extractItems
                                                        |> LE.getAt index
                                                        |> Maybe.withDefault Component.emptyResults
                                            in
                                            tr []
                                                [ td [ class "ps-3 align-middle w-100" ]
                                                    [ text <| Process.getDisplayName process ]
                                                , td [ class "align-middle text-end text-nowrap" ]
                                                    [ Format.qtyVariationRatioAsWastePercent process.qtyVariationRatio
                                                    ]
                                                , td [ class "align-middle text-end text-nowrap" ]
                                                    [ operationResult
                                                        |> Component.extractMass
                                                        |> Format.kg
                                                    ]
                                                , td [ class "align-middle text-end text-nowrap" ]
                                                    [ operationResult
                                                        |> Component.extractImpacts
                                                        |> Format.formatImpact impact
                                                    ]
                                                , td [ class "align-middle pe-3 text-end" ]
                                                    [ button
                                                        [ type_ "button"
                                                        , class "btn btn-sm btn-outline-secondary"
                                                        , title "Supprimer ce procédé d’assemblage"
                                                        , onClick (config.removeAssemblyOperation index)
                                                        ]
                                                        [ Icon.trash ]
                                                    ]
                                                ]
                                        )
                                )
                            ]
            , addAssemblyOperationButton config
            ]
        ]


addAssemblyOperationButton : Config db msg -> Html msg
addAssemblyOperationButton ({ openSelectAssemblyOperationModal, query } as config) =
    let
        availableProcesses =
            listAvailableProcesses config Category.Assembly
                |> List.filter
                    (\{ id } ->
                        -- prevent adding the same operation twice
                        query
                            |> Component.getAssemblyOperations (requirementsFromConfig config)
                            |> List.member id
                            |> not
                    )

        autocompleteState =
            availableProcesses
                |> AutocompleteSelector.init Process.getDisplayName
    in
    button
        [ type_ "button"
        , class "btn btn-outline-primary w-100 rounded-0 gap-1"
        , class "d-flex justify-content-center align-items-center"
        , disabled <| List.isEmpty availableProcesses
        , onClick <| openSelectAssemblyOperationModal autocompleteState
        ]
        [ Icon.plus
        , text "Ajouter un procédé d’assemblage"
        ]


distributionView : Config db msg -> LifeCycle -> Html msg
distributionView ({ componentConfig, db, impact, query, scope, updateDistribution } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between gap-2" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Distribution" ]
            , div [ class "d-flex flex-fill justify-content-end align-items-center gap-2" ]
                [ lifeCycle.distribution.impacts
                    |> Format.formatImpact impact
                ]
            , documentationLink config "distribution"
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
                    let
                        distribution =
                            query
                                |> Component.getDistributionProcessId
                                    { config = componentConfig, db = db, scope = scope }
                    in
                    distributionProcesses
                        |> List.map
                            (\process ->
                                option
                                    [ value (Process.idToString process.id)
                                    , selected (distribution == Just process.id)
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
        [ div [ class "card-header d-flex align-items-center justify-content-between gap-2" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Utilisation" ]
            , div [ class "d-flex flex-fill justify-content-end align-items-center gap-2" ]
                [ lifeCycle.use
                    |> Impact.sumImpacts
                    |> Format.formatImpact impact
                ]
            , documentationLink config "use"
            ]
        , div [ class "d-flex flex-column p-0" ]
            [ query
                |> Component.getConsumptions (requirementsFromConfig config)
                |> quantifiedProcessList config
                    lifeCycle
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
                        query
                            |> Component.getConsumptions (requirementsFromConfig config)
                            |> List.map .processId
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
        [ div [ class "card-header d-flex align-items-center justify-content-between gap-2" ]
            [ div [ class "IngredientPlaneOrBoatSelector" ]
                [ div [ class "mb-0 d-flex" ]
                    [ div [ class "h5" ] [ text "Fin de vie" ]
                    ]
                ]
            , div [ class "d-flex flex-fill align-items-center justify-content-center" ]
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
            , lifeCycle.endOfLife
                |> Format.formatImpact config.impact
            , documentationLink config "eol"
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
                        , Component.getEndOfLifeDetailedImpacts
                            { config = componentConfig
                            , db = config.db
                            , scope = config.scope
                            }
                            query.recyclable
                            lifeCycle
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


type alias ProductCategorySelector msg =
    { onSelect : Maybe ProductCategory.Id -> msg
    , products : List ProductCategory
    , query : Query
    , scope : Scope.GenericScope
    }


productCategorySelectorView : ProductCategorySelector msg -> Html msg
productCategorySelectorView { onSelect, products, query, scope } =
    let
        scopedProducts =
            products
                |> ProductCategory.findByScope scope
                |> List.sortBy .label
    in
    if List.isEmpty scopedProducts || List.isEmpty query.items then
        text ""

    else
        div [ class "d-flex flex-row align-items-center gap-2 my-3" ]
            [ label
                [ Attr.for "product-category"
                , class "form-label fw-bold text-nowrap"
                ]
                [ text "Catégorie de produit" ]
            , select
                [ Attr.id "product-category"
                , class "form-select"
                , onInput <|
                    \str ->
                        if String.isEmpty str then
                            onSelect Nothing

                        else
                            ProductCategory.idFromString str
                                |> Result.map (Just >> onSelect)
                                |> Result.withDefault (onSelect Nothing)
                ]
                (option [ value "", selected (query.product == Nothing) ]
                    [ text "Autres" ]
                    :: List.map
                        (\product ->
                            option
                                [ value (ProductCategory.idToString product.id)
                                , selected (query.product == Just product.id)
                                ]
                                [ text product.label ]
                        )
                        scopedProducts
                )
            ]
