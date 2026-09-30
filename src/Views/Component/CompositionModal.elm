module Views.Component.CompositionModal exposing (view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Complement as Complement
import Data.Component as Component
    exposing
        ( ExpandedElement
        , ExpandedItem
        , ExpandedLocalizedProcess
        , Index
        , LifeCycle
        , Query
        , Results
        , TargetElement
        , TargetItem
        )
import Data.Component.Amount exposing (Amount)
import Data.Country as Country exposing (Country)
import Data.Country.Code as CountryCode
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Mass exposing (Mass)
import Quantity
import Views.Alert as Alert
import Views.Component.AmountInput as AmountInput
import Views.Component.ProcessRow as ProcessRow exposing (emptyProcessRow)
import Views.Component.RegionSelector as RegionSelector
import Views.Format as Format
import Views.Icon as Icon


{-| Config required by the composition modal.
-}
type alias Config db msg =
    { componentConfig : Component.Config
    , db : Component.DataContainer db
    , impact : Definition
    , labels :
        { addElement : String
        , elementNoun : String
        , elementNounPlural : String
        , itemLabelCaption : String
        , itemName : String
        }
    , lifeCycle : LifeCycle
    , openSelectProcessModal : Category -> TargetItem -> Maybe Index -> Autocomplete Process -> msg
    , query : Query
    , removeElement : TargetElement -> msg
    , removeElementTransform : TargetElement -> Index -> msg
    , scope : Scope
    , updateElementAmount : TargetElement -> Maybe Amount -> msg
    , updateElementMaterialCountry : TargetElement -> Maybe CountryCode.Code -> msg
    , updateElementTransformCountry : TargetElement -> Index -> Maybe CountryCode.Code -> msg
    , updateItemName : TargetItem -> String -> msg
    }


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


createElementMaterialAutocomplete : Component.DataContainer db -> Scope -> Autocomplete Process
createElementMaterialAutocomplete db scope =
    db.processes
        |> Process.listAvailableByCategory scope Category.Material
        -- Exclude packaging materials as they're available in a dedicated section
        |> List.filter (\{ categories } -> not <| List.member Category.Packaging categories)
        |> AutocompleteSelector.init Process.getDisplayName


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
        AmountInput.view
            { event = config.updateElementAmount targetElement
            , readonly = False
            , unit = process.unit
            }
            amount


{-| Renders a single item element's composition rows (header, summary, raw material, transforms, transport)
-}
elementCompositionRows : Config db msg -> TargetElement -> ExpandedElement -> Results -> Results -> List (Html msg)
elementCompositionRows config targetElement ({ amount, material, transforms } as expandedElement) itemResults elementResults =
    let
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

        totalImpact =
            impactPill config <| Component.getTotalImpacts elementResults

        elementSummary =
            ProcessRow.view [ class "fs-7" ]
                { emptyProcessRow
                    | amount =
                        amount |> elementAmountInput config targetElement material.process
                    , impact =
                        if transportImpacts == Impact.empty then
                            totalImpact

                        else
                            span []
                                [ totalImpact
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
                [ ProcessRow.view [ class "fs-7 text-muted" ]
                    { emptyProcessRow | label = text "Aucune transformation" }
                ]

            else
                ProcessRow.columnHeaders
                    { amount = "Quantité"
                    , country = "Origine"
                    , label = "Intitulé"
                    , waste = "Pertes"
                    }
                    :: transformProcessRows config
                        elementCooling
                        targetElement
                        transformsResults
                        transforms
                    ++ (LE.last transformsResults
                            |> Maybe.map Component.extractMass
                            |> Maybe.withDefault (Component.extractMass materialResults)
                            |> finalElementTransportView config elementCooling (Component.getFinalElementCountry expandedElement)
                       )
    in
    elementHeader config targetElement
        :: elementSummary
        :: compositionSectionHeading "Matière première" Nothing
        :: materialCompositionRows config targetElement materialResults material
        ++ materialTransportView config elementCooling materialResults material transforms
        ++ (compositionSectionHeading "Étape de transformation"
                (Just <| addElementTransformButton config material.process targetElement)
                :: transformRows
           )


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
            ProcessRow.view attributes
                { emptyProcessRow
                    | label = error |> Alert.simpleError (Just "Erreur de calcul de distance")
                }

        Ok transport ->
            let
                renderCountry maybeCountry =
                    case maybeCountry of
                        Just { code, name } ->
                            abbr [ title name ] [ text <| CountryCode.toString code ]

                        Nothing ->
                            text "Région inconnue"

                renderModeIfAny icon distance =
                    if distance |> Quantity.greaterThan Quantity.zero then
                        [ icon, Format.km distance ]

                    else
                        []
            in
            ProcessRow.view (class "fs-7 text-muted" :: attributes)
                { emptyProcessRow
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
                        div [ class "d-flex align-items-center gap-1 text-nowrap text-muted" ]
                            [ text "Transport\u{00A0}"
                            , renderCountry maybeFrom
                            , text " → "
                            , renderCountry maybeTo
                            ]
                }


{-| Render transports from the last transform step of an element to the assembly or distribution stage
-}
finalElementTransportView : Config db msg -> Bool -> Maybe Country -> Mass -> List (Html msg)
finalElementTransportView ({ db, query, scope } as config) cooling elementCountry mass =
    db.countries
        |> Scope.anyOf [ scope ]
        |> Country.resolveMaybe query.assembly.country
        |> Result.map (elementTransportView config [ class "subdued" ] cooling mass elementCountry)
        |> Result.map List.singleton
        |> Result.withDefault []


impactPill : Config db msg -> Impacts -> Html msg
impactPill config impacts =
    span [ class "ImpactPill bg-info-subtle" ]
        [ impacts |> Format.formatImpact config.impact
        ]


itemCompositionModalBody : Config db msg -> TargetItem -> ExpandedItem -> Results -> Html msg
itemCompositionModalBody config targetItem { component, elements } itemResults =
    let
        elementCount =
            List.length elements

        compositionStat : String -> List (Html msg) -> Html msg
        compositionStat caption value =
            div [ class "d-flex flex-column" ]
                [ dt [ class "fs-8 text-muted order-2 mb-0" ] [ text caption ]
                , dd [ class "fw-bold text-secondary order-1 mb-0 ps-0" ] value
                ]
    in
    div [ class "d-flex flex-column gap-3 p-3" ]
        [ div [ class "d-flex flex-row align-items-center gap-2" ]
            [ label [ class "text-nowrap", for "item-label" ] [ text config.labels.itemLabelCaption ]
            , input
                [ type_ "text"
                , class "form-control"
                , id "item-label"
                , placeholder config.labels.itemName
                , value component.name
                , onInput (config.updateItemName targetItem)
                ]
                []
            ]

        -- FIXME: responsive gap
        , div
            [ class "d-flex flex-wrap gap-4 align-items-center bg-info-subtle border rounded row-gap-1 column-gap-2 column-gap-lg-5 p-3"
            , attribute "aria-live" "polite"
            ]
            [ span [ class "d-flex align-items-center gap-2" ]
                [ span [ class "fs-4 mt-1 text-secondary opacity-75", attribute "aria-hidden" "true" ] [ Icon.info ]
                , span [ class "fw-bold text-secondary" ] [ text "Détails de la composition" ]
                ]
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
                [ text <| "Liste des " ++ String.toLower config.labels.elementNounPlural ++ " et leurs étapes de transformation" ]
            , addElementButton config targetItem
            ]
        , div [ class "table-responsive" ]
            [ table [ class "CompositionElements table table-sm table-borderless mb-0 w-100" ]
                (caption [ class "visually-hidden" ]
                    [ text <| "Composition des " ++ String.toLower config.labels.elementNounPlural ]
                    :: (if List.isEmpty elements then
                            [ tbody []
                                [ ProcessRow.view [] { emptyProcessRow | label = text "Aucun élément" }
                                ]
                            ]

                        else
                            List.map3
                                (\elementIndex expandedElement elementResults ->
                                    tbody [ class "composition-element" ] <|
                                        elementCompositionRows config
                                            ( targetItem, elementIndex )
                                            expandedElement
                                            itemResults
                                            elementResults
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
                       )
                )
            ]
        ]


{-| Transport that _leaves_ an element's raw material step:

  - with a transform, it's the transport toward the first transformation step
  - without any transforms, trabnsport is toward assembly directly

-}
materialTransportView : Config db msg -> Bool -> Results -> ExpandedLocalizedProcess -> List ExpandedLocalizedProcess -> List (Html msg)
materialTransportView config cooling materialResults material transforms =
    case transforms of
        firstTransform :: _ ->
            [ firstTransform.country
                |> elementTransportView config
                    []
                    cooling
                    (Component.extractMass materialResults)
                    material.country
            ]

        [] ->
            Component.extractMass materialResults
                |> finalElementTransportView config cooling material.country


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
            ProcessRow.view [ class "fs-7" ]
                { emptyProcessRow
                    | actions = modifyMaterialButton config targetElement
                    , amount =
                        Component.extractAmount materialResults
                            |> Format.amount material.process
                    , country =
                        RegionSelector.view
                            { attrs = []
                            , classes = "RegionSelector form-select-sm w-100"
                            , countries = config.db.countries
                            , disabled = False
                            , domId = "material-country-" ++ Component.targetElementToString targetElement
                            , emptyLabel = "---"
                            , hideLabel = True
                            , label = Just "Région"
                            , scope = config.scope
                            , select = config.updateElementMaterialCountry targetElement
                            , selected = material.country |> Maybe.map .code
                            , showCode = True
                            }
                    , impact =
                        impactPill config <| Component.getTotalImpacts materialResults
                    , label =
                        span [ class "fw-bold", title <| Process.getDisplayName material.process ]
                            [ text <| Process.getDisplayName material.process
                            ]
                }

        complementsRow =
            if complementsImpacts /= Complement.emptyComplementsResultsImpacts then
                [ ProcessRow.view [ class "fs-7 text-muted" ]
                    { emptyProcessRow
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


modifyMaterialButton : Config db msg -> TargetElement -> Html msg
modifyMaterialButton config ( targetItem, elementIndex ) =
    button
        [ type_ "button"
        , class "btn btn-sm btn-outline-primary text-nowrap"
        , attribute "aria-label" "Changer de matière première"
        , config.db.processes
            |> Process.listAvailableByCategory config.scope Category.Material
            |> AutocompleteSelector.init Process.getDisplayName
            |> config.openSelectProcessModal Category.Material targetItem (Just elementIndex)
            |> onClick
        ]
        [ Icon.pencil ]


transformProcessRows :
    Config db msg
    -> Bool
    -> TargetElement
    -> List Results
    -> List ExpandedLocalizedProcess
    -> List (Html msg)
transformProcessRows config cooling targetElement transformsResults transforms =
    transforms
        |> List.indexedMap
            (\transformIndex transform ->
                let
                    transformResult =
                        transformsResults
                            |> LE.getAt transformIndex
                            |> Maybe.withDefault Component.emptyResults

                    -- note: outbound transport from the raw material step is rendered in the material section
                    inboundTransport =
                        case transformIndex of
                            0 ->
                                []

                            index ->
                                let
                                    previousMass =
                                        transformsResults
                                            |> LE.getAt (index - 1)
                                            |> Maybe.withDefault Component.emptyResults
                                            |> Component.extractMass

                                    previousCountry =
                                        transforms
                                            |> LE.getAt (index - 1)
                                            |> Maybe.andThen .country
                                in
                                [ transform.country
                                    |> elementTransportView config [] cooling previousMass previousCountry
                                ]

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
                inboundTransport
                    ++ [ ProcessRow.view [ class "fs-7 border-top" ]
                            { emptyProcessRow
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
                                    RegionSelector.view
                                        { attrs = []
                                        , classes = "RegionSelector form-select-sm w-100"
                                        , countries = config.db.countries
                                        , disabled = False
                                        , domId =
                                            "transform-country-"
                                                ++ Component.targetElementToString targetElement
                                                ++ "-"
                                                ++ String.fromInt transformIndex
                                        , emptyLabel = "---"
                                        , hideLabel = True
                                        , label = Just "Région"
                                        , scope = config.scope
                                        , select = config.updateElementTransformCountry targetElement transformIndex
                                        , selected = transform.country |> Maybe.map .code
                                        , showCode = True
                                        }
                                , impact =
                                    impactPill config <| Component.extractImpacts transformResult
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


requirementsFromConfig : Config db msg -> Component.Requirements db
requirementsFromConfig config =
    { config = config.componentConfig
    , db = config.db
    , scope = config.scope
    }


{-| Production item composition editor modal body.
-}
view : Config db msg -> TargetItem -> Html msg
view ({ lifeCycle, query } as config) ( _, itemIndex ) =
    case Component.expandItems config.db query.items of
        Err error ->
            Alert.simpleError (Just "Erreur") error

        Ok expandedItems ->
            case LE.getAt itemIndex expandedItems of
                Just expandedItem ->
                    Component.extractItems lifeCycle.production
                        |> LE.getAt itemIndex
                        |> Maybe.withDefault Component.emptyResults
                        |> itemCompositionModalBody config ( expandedItem.component, itemIndex ) expandedItem

                Nothing ->
                    Alert.simpleError (Just "Erreur") "Composant introuvable"
