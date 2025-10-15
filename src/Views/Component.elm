module Views.Component exposing (editorView)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Component as Component
    exposing
        ( Amount
        , Component
        , ExpandedElement
        , Index
        , Item
        , LifeCycle
        , Quantity
        , Results
        , TargetElement
        , TargetItem
        )
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Dict.Any as AnyDict
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import List.Extra as LE
import Route exposing (Route)
import Views.Alert as Alert
import Views.Button as Button
import Views.Component.DownArrow as DownArrow
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link
import Views.Table as Table


type alias Config db msg =
    { addLabel : String
    , customizable : Bool
    , db : Component.DataContainer db
    , debug : Bool
    , detailed : List Index
    , docsUrl : Maybe String
    , explorerRoute : Maybe Route
    , impact : Definition
    , items : List Item
    , maxItems : Maybe Int
    , noOp : msg
    , openSelectComponentModal : Autocomplete Component -> msg
    , openSelectProcessModal : Category -> TargetItem -> Maybe Index -> Autocomplete Process -> msg
    , removeElement : TargetElement -> msg
    , removeElementTransform : TargetElement -> Index -> msg
    , removeItem : Index -> msg
    , results : LifeCycle
    , scopes : List Scope
    , setDetailed : List Index -> msg
    , title : String
    , updateElementAmount : TargetElement -> Maybe Amount -> msg
    , updateItemName : TargetItem -> String -> msg
    , updateItemQuantity : Index -> Quantity -> msg
    }


addComponentButton : Config db msg -> Html msg
addComponentButton { addLabel, db, openSelectComponentModal, scopes } =
    let
        availableComponents =
            db.components
                |> List.filter (not << Component.isEmpty)
                |> Scope.anyOf scopes

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


addElementButton : Config db msg -> TargetItem -> Html msg
addElementButton { db, openSelectProcessModal, scopes } targetItem =
    button
        [ type_ "button"
        , class "btn btn-link text-decoration-none"
        , class "d-flex justify-content-end align-items-center"
        , class "gap-2 w-100 p-0 pb-1 text-end"
        , db.processes
            |> Scope.anyOf scopes
            |> Process.listByCategory Category.Material
            |> List.sortBy Process.getDisplayName
            |> AutocompleteSelector.init Process.getDisplayName
            |> openSelectProcessModal Category.Material targetItem Nothing
            |> onClick
        ]
        [ Icon.puzzle
        , text "Ajouter un élément"
        ]


addElementTransformButton : Config db msg -> Process -> TargetElement -> Html msg
addElementTransformButton { db, items, openSelectProcessModal, scopes } material ( targetItem, elementIndex ) =
    let
        availableTransformProcesses =
            db.processes
                |> Scope.anyOf scopes
                |> Process.listAvailableMaterialTransforms material
                |> List.sortBy Process.getDisplayName
                |> Process.available (Component.elementTransforms ( targetItem, elementIndex ) items)

        autocompleteState =
            availableTransformProcesses
                |> AutocompleteSelector.init Process.getDisplayName
    in
    button
        [ type_ "button"
        , class "btn btn-link btn-sm w-100 text-decoration-none"
        , class "d-flex justify-content-start align-items-center"
        , class "gap-1 w-100 p-0 pb-1"
        , disabled <| List.isEmpty availableTransformProcesses
        , autocompleteState
            |> openSelectProcessModal Category.Transform targetItem (Just elementIndex)
            |> onClick
        ]
        [ Icon.plus
        , text "Ajouter une transformation"
        ]


componentView :
    Config db msg
    -> Index
    -> Item
    -> ( Quantity, Component, List ExpandedElement )
    -> Results
    -> List (Html msg)
componentView config itemIndex item ( quantity, component, expandedElements ) itemResults =
    let
        collapsed =
            config.detailed
                |> List.member itemIndex
                |> not
    in
    List.concat
        [ [ tbody []
                [ tr [ class "border-top border-bottom" ]
                    [ th [ class "ps-2 align-middle", scope "col" ]
                        [ if config.customizable && config.maxItems /= Just 1 then
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
                    , td [ class "ps-0 py-2 align-middle" ]
                        [ quantity |> quantityInput config itemIndex
                        ]
                    , td [ class "align-middle text-truncate w-100", colspan 2 ]
                        [ if config.customizable then
                            input
                                [ type_ "text"
                                , class "form-control"
                                , onInput (config.updateItemName ( component, itemIndex ))
                                , placeholder "Nom du composant"
                                , item.custom
                                    |> Maybe.andThen .name
                                    |> Maybe.withDefault component.name
                                    |> value
                                ]
                                []

                          else
                            span [ class "fw-bold" ] [ text component.name ]
                        ]
                    , td [ class "text-end align-middle text-nowrap" ]
                        [ Component.extractMass itemResults
                            |> Format.kg
                        ]
                    , td [ class "text-end align-middle text-nowrap" ]
                        [ Component.extractImpacts itemResults
                            |> Format.formatImpact config.impact
                        ]
                    , td [ class "pe-3 text-end align-middle text-nowrap" ]
                        [ if config.maxItems == Just 1 then
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
            List.map3
                (elementView config ( component, itemIndex ))
                (List.range 0 (List.length expandedElements - 1))
                expandedElements
                (Component.extractItems itemResults)

          else
            []
        , if not collapsed then
            [ tbody []
                [ tr [ class "border-top" ]
                    [ td [ colspan 7, class "pe-3" ]
                        [ addElementButton config ( component, itemIndex )
                        ]
                    ]
                ]
            ]

          else
            []
        ]


viewDebug : List Item -> LifeCycle -> Html msg
viewDebug items lifeCycle =
    div []
        [ details [ class "card-body py-2" ]
            [ summary [] [ text "Debug" ]
            , div [ class "row g-2" ]
                [ div [ class "col-6" ]
                    [ h5 [] [ text "Query" ]
                    , pre [ class "bg-light p-2 mb-0" ]
                        [ items
                            |> Encode.list Component.encodeItem
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
editorView ({ db, docsUrl, explorerRoute, maxItems, items, results, title } as config) =
    div [ class "d-flex flex-column" ]
        [ div [ class "card shadow-sm" ]
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
                    [ results.production
                        |> Component.extractImpacts
                        |> Format.formatImpact config.impact
                    , case docsUrl of
                        Just url ->
                            Button.docsPillLink
                                [ href url, target "_blank", style "height" "24px" ]
                                [ Icon.question ]

                        Nothing ->
                            text ""
                    ]
                ]
            , if List.isEmpty items then
                div [ class "card-body" ] [ text "Aucun élément." ]

              else
                case Component.expandItems db items of
                    Err error ->
                        Alert.simple
                            { attributes = []
                            , close = Nothing
                            , content = [ text error ]
                            , level = Alert.Danger
                            , title = Just "Erreur"
                            }

                    Ok expandedItems ->
                        div [ class "table-responsive" ]
                            [ table [ class "table table-sm table-borderless mb-0" ]
                                ((if maxItems == Just 1 then
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
                                        (List.map4 (componentView config)
                                            (List.range 0 (List.length items - 1))
                                            items
                                            expandedItems
                                            (Component.extractItems results.production)
                                        )
                                )
                            ]
            , if maxItems == Just 1 then
                text ""

              else
                addComponentButton config
            ]
        , if config.scopes /= [ Scope.Textile ] then
            div []
                [ DownArrow.view [] []
                , endOfLifeView config results.production
                ]

          else
            text ""
        , if config.debug then
            viewDebug items results

          else
            text ""
        ]


amountInput : Config db msg -> TargetElement -> Process.Unit -> Amount -> Html msg
amountInput config targetElement unit amount =
    let
        stringAmount =
            amount
                |> Component.amountToFloat
                |> String.fromFloat

        stepValue =
            case String.split "." stringAmount of
                -- This is an integer, increment by one to keep the integer value
                [ _ ] ->
                    "1"

                -- This is a float, increment at the precision of the float
                [ _, decimals ] ->
                    "0." ++ String.padLeft (String.length decimals) '0' "1"

                -- Should not happen, but who knows?
                _ ->
                    "0.01"
    in
    div [ class "input-group" ]
        [ input
            [ type_ "number"
            , class "form-control form-control-sm text-end incdec-arrows-left"
            , value stringAmount
            , Attr.min "0"
            , step stepValue
            , onInput <|
                String.toFloat
                    >> Maybe.map Component.Amount
                    >> config.updateElementAmount targetElement
            ]
            []
        , small [ class "input-group-text fs-8" ]
            [ text <| Process.unitToString unit ]
        ]


elementView : Config db msg -> TargetItem -> Index -> ExpandedElement -> Results -> Html msg
elementView config targetItem elementIndex { amount, material, transforms } elementResults =
    let
        ( materialResults, transformsResults ) =
            case Component.extractItems elementResults of
                [] ->
                    ( Component.emptyResults, [] )

                materialResults_ :: transformsResults_ ->
                    ( materialResults_, transformsResults_ )
    in
    tbody [ style "border-bottom" "1px solid #fff" ]
        (tr [ class "fs-7 text-muted" ]
            [ th [] []
            , th [ class "align-middle", scope "col" ]
                [ if material.unit == Process.Kilogram then
                    text "Masse finale"

                  else
                    text "Quantité finale"
                ]
            , th [ class "align-middle", scope "col" ]
                [ text <| "Élément #" ++ String.fromInt (elementIndex + 1) ]
            , th [ class "align-middle", scope "col" ]
                [ text "Pertes" ]
            , th [ class "align-middle text-truncate", scope "col", Attr.title "Masse sortante" ]
                [ material.unit |> Process.unitLabel |> text ]
            , th [ class "align-middle text-end", scope "col" ]
                [ Format.formatImpact config.impact <| Component.extractImpacts elementResults ]
            , th [] []
            ]
            :: elementMaterialView config ( targetItem, elementIndex ) materialResults material amount
            :: elementTransformsView config ( targetItem, elementIndex ) transformsResults transforms
            ++ (if config.scopes /= [ Scope.Textile ] then
                    [ tr []
                        [ td [ colspan 2 ] []
                        , td [ colspan 5 ]
                            [ addElementTransformButton config material ( targetItem, elementIndex )
                            ]
                        ]
                    ]

                else
                    []
               )
        )


selectMaterialButton : Config db msg -> TargetElement -> Process -> Html msg
selectMaterialButton { db, openSelectProcessModal } ( targetItem, elementIndex ) material =
    let
        availableMaterialProcesses =
            db.processes
                |> Process.listByCategory Category.Material
                |> List.sortBy Process.getDisplayName

        autocompleteState =
            AutocompleteSelector.init Process.getDisplayName availableMaterialProcesses
    in
    button
        [ type_ "button"
        , class "btn btn-sm btn-link text-decoration-none p-0"
        , autocompleteState
            |> openSelectProcessModal Category.Material targetItem (Just elementIndex)
            |> onClick
        ]
        [ span [ class "ComponentElementIcon" ] [ Icon.material ]
        , text <| Process.getDisplayName material
        ]


elementMaterialView : Config db msg -> TargetElement -> Results -> Process -> Amount -> Html msg
elementMaterialView config targetElement materialResults material amount =
    tr [ class "fs-7" ]
        [ td [] []
        , td [ class "text-end align-middle text-nowrap ps-0", style "min-width" "130px" ]
            [ if config.scopes == [ Scope.Textile ] then
                Format.amount material amount

              else
                amountInput config targetElement material.unit amount
            ]
        , td [ class "align-middle text-truncate w-100", title <| Process.getDisplayName material ]
            [ selectMaterialButton config targetElement material ]
        , td [ class "text-end align-middle text-nowrap" ]
            []
        , td [ class "text-end align-middle text-nowrap" ]
            [ Component.extractAmount materialResults
                |> Format.amount material
            ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Component.extractImpacts materialResults
                |> Format.formatImpact config.impact
            ]
        , td [ class "pe-3  text-nowrap" ]
            [ button
                [ type_ "button"
                , class "btn btn-sm btn-outline-secondary"
                , onClick (config.removeElement targetElement)
                ]
                [ Icon.trash ]
            ]
        ]


elementTransformsView : Config db msg -> TargetElement -> List Results -> List Process -> List (Html msg)
elementTransformsView config targetElement transformsResults transforms =
    List.map3
        (\transformIndex transformResult transform ->
            tr [ class "fs-7" ]
                [ td [] []
                , td [ class "text-end align-middle text-nowrap" ] []
                , td
                    [ class "text-truncate align-middle w-100"

                    -- Note: allows truncated ellipsis in table cells https://stackoverflow.com/a/11877033/330911
                    , style "max-width" "0"
                    , title <| Process.getDisplayName transform
                    ]
                    [ span [ class "ComponentElementIcon" ] [ Icon.transform ]
                    , text <| Process.getDisplayName transform
                    ]
                , td [ class "align-middle text-end text-nowrap" ]
                    [ Format.splitAsPercentage 2 transform.waste ]
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Component.extractAmount transformResult
                        |> Format.amount transform
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
        )
        (List.range 0 (List.length transforms))
        transformsResults
        transforms


quantityInput : Config db msg -> Index -> Quantity -> Html msg
quantityInput config itemIndex quantity =
    div [ class "input-group", style "width" "130px" ]
        [ input
            [ type_ "number"
            , class "form-control text-end"
            , quantity |> Component.quantityToInt |> String.fromInt |> value
            , step "1"
            , Attr.min "1"
            , disabled <| config.maxItems == Just 1
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


endOfLifeView : Config db msg -> Results -> Html msg
endOfLifeView config results =
    let
        formatShareImpacts ( split, impacts ) =
            div []
                [ impacts |> Format.formatImpact config.impact
                , text "\u{00A0}("
                , split |> Format.splitAsPercentage 0
                , text ")"
                ]
    in
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Fin de vie" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ case Component.getEndOfLifeImpacts config.db results of
                    Err error ->
                        span [ class "text-danger" ] [ text error ]

                    Ok impacts ->
                        Format.formatImpact config.impact impacts
                ]
            ]
        , div [ class "card-body p-0" ]
            [ Table.responsiveDefault
                []
                [ thead []
                    [ tr []
                        [ th [ class "ps-3" ] [ text "Matière" ]
                        , th [ class "text-end" ] [ text "Masse" ]
                        , th [ class "text-end" ] [ text "Recyclage" ]
                        , th [ class "text-end" ] [ text "Enfouissement" ]
                        , th [ class "text-end" ] [ text "Incinération" ]
                        , th [ class "text-end pe-3" ] [ text "Impact" ]
                        ]
                    ]
                , results
                    |> Component.getEndOfLifeDetailedImpacts config.db.processes
                    |> Result.map AnyDict.toList
                    |> Result.withDefault []
                    |> List.map
                        (\( materialType, ( mass, { incinerating, landfilling, recycling } ) ) ->
                            tr []
                                [ td [ class "ps-3" ] [ text <| Category.materialTypeToLabel materialType ]
                                , td [ class "text-end" ] [ Format.kg mass ]
                                , td [ class "text-end" ] [ formatShareImpacts recycling ]
                                , td [ class "text-end" ] [ formatShareImpacts incinerating ]
                                , td [ class "text-end" ] [ formatShareImpacts landfilling ]
                                , td [ class "text-end pe-3 fw-bold" ]
                                    [ [ Tuple.second recycling
                                      , Tuple.second incinerating
                                      , Tuple.second landfilling
                                      ]
                                        |> Impact.sumImpacts
                                        |> Format.formatImpact config.impact
                                    ]
                                ]
                        )
                    |> tbody []
                ]
            ]
        ]
