module Views.Component.ProductionTable exposing (view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Component as Component
    exposing
        ( Component
        , ExpandedElement
        , ExpandedItem
        , Index
        , ProductionItem(..)
        , Quantity
        , Query
        , Results
        , TargetItem
        )
import Data.Impact.Definition exposing (Definition)
import Data.Process as Process
import Data.Process.Category as Category
import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Route exposing (Route)
import Views.Alert as Alert
import Views.Button as Button
import Views.Component.ItemRow as ItemRow exposing (emptyItemRow)
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


type alias Config db msg =
    { canEditItemComposition : Bool
    , db : Component.DataContainer db
    , detailed : List Index
    , docsUrl : Maybe String
    , documentationLink : Html msg
    , explorerRoute : Maybe Route
    , impact : Definition
    , labels :
        { add : String
        , empty : String
        , itemName : String
        , productionHeading : String
        }
    , noOp : msg
    , openItemEditModal : TargetItem -> msg
    , openSelectProductionItem : Autocomplete ProductionItem -> msg
    , query : Query
    , removeItem : Index -> msg
    , scope : Scope
    , setDetailed : List Index -> msg
    , updateItemQuantity : Index -> Quantity -> msg
    }


addProductionItemButton : Config db msg -> Html msg
addProductionItemButton ({ db } as config) =
    let
        availableComponents =
            db.components
                |> List.filter (not << Component.isEmpty)
                |> List.filter (.scope >> (==) config.scope)
                |> List.map ComponentItem

        availableMaterials =
            db.processes
                |> Process.listAvailableByCategory config.scope Category.Material
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
    ItemRow.view [ class "fs-7 border-top" ]
        { emptyItemRow
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


expandToggler : Config db msg -> Index -> Bool -> Html msg
expandToggler config itemIndex collapsed =
    if not config.canEditItemComposition then
        text ""

    else
        let
            label =
                if collapsed then
                    "Déplier les détails"

                else
                    "Replier les détails"
        in
        button
            [ type_ "button"
            , class "btn btn-link text-muted text-decoration-none font-monospace fs-6 p-0 m-0"
            , title label
            , attribute "aria-label" label
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
        (if config.canEditItemComposition then
            [ editButton, deleteButton ]

         else
            [ deleteButton ]
        )


itemDetailedRows : Config db msg -> List ExpandedElement -> Results -> List (Html msg)
itemDetailedRows config elements itemResults =
    if List.isEmpty elements then
        List.singleton <|
            ItemRow.view [ class "bg-light border-bottom" ]
                { emptyItemRow | label = text "Aucun élément" }

    else
        List.map2
            (elementSummaryRow config itemResults)
            elements
            (Component.extractItems itemResults)


itemDetailsId : Index -> String
itemDetailsId itemIndex =
    "item-table-" ++ String.fromInt itemIndex


itemTableHeader : Config db msg -> Html msg
itemTableHeader config =
    -- Note: header cells use <th scope="col"> so thead semantics stay valid for AT
    tr [ class "fs-8 fw-normal text-muted border-bottom" ]
        [ th [ class "ps-2 py-2 align-middle", scope "col" ]
            [ span [ class "visually-hidden" ] [ text "Détails" ] ]
        , th [ class "py-2 text-end align-middle text-nowrap", scope "col" ]
            [ text "Masse unitaire" ]
        , th [ class "py-2 align-middle text-truncate w-100", style "max-width" "0", scope "col" ]
            [ text config.labels.itemName ]
        , th [ class "py-2 align-middle text-center", scope "col" ]
            [ text "Quantité" ]
        , th [ class "py-2 text-end align-middle text-nowrap", scope "col" ]
            [ text "Masse totale" ]
        , th [ class "py-2 text-end align-middle text-nowrap", style "min-width" "80px", scope "col" ]
            [ text "Impacts" ]
        , th [ class "py-2 pe-3 text-end align-middle text-nowrap", scope "col" ]
            [ span [ class "visually-hidden" ] [ text "Actions" ] ]
        ]


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
        [ ItemRow.view [ class "border-bottom", classList [ ( "table-info", not collapsed ) ] ]
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


view : Config db msg -> Results -> Html msg
view ({ docsUrl, explorerRoute, query } as config) productionResults =
    div [ class "card shadow-sm" ]
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
                    [ productionResults
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
            , config.documentationLink
            ]
        , if List.isEmpty query.items then
            div [ class "card-body" ]
                [ text config.labels.empty
                ]

          else
            case Component.expandItems config.db query.items of
                Err error ->
                    error |> Alert.simpleError (Just "Erreur")

                Ok expandedItems ->
                    div [ class "table-responsive" ]
                        [ table [ class "table table-sm table-borderless mb-0" ]
                            (thead []
                                [ itemTableHeader config ]
                                :: List.concat
                                    (List.map3 (itemView config)
                                        (List.range 0 (List.length query.items - 1))
                                        expandedItems
                                        (Component.extractItems productionResults)
                                    )
                            )
                        ]
        , addProductionItemButton config
        ]
