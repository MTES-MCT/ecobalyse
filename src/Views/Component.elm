module Views.Component exposing (editorView)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Component as Component exposing (Amount, Component, ExpandedElement, Id, Item, Quantity, Results)
import Data.Dataset as Dataset
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import List.Extra as LE
import Route
import Views.Alert as Alert
import Views.Button as Button
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


type alias Config db msg =
    { addLabel : String
    , customizable : Bool
    , db : Component.DataContainer db
    , detailed : List Id
    , docsUrl : Maybe String
    , impact : Definition
    , items : List Item
    , noOp : msg
    , openSelectComponentModal : Autocomplete Component -> msg
    , openSelectProcessModal : Category -> Component -> Maybe Int -> Autocomplete Process -> msg
    , removeElement : Component -> Int -> msg
    , removeElementTransform : Component -> Int -> Int -> msg
    , removeItem : Id -> msg
    , results : Results
    , scope : Scope
    , setDetailed : List Id -> msg
    , title : String
    , updateElementAmount : Component -> Int -> Maybe Amount -> msg
    , updateItemName : Component -> String -> msg
    , updateItemQuantity : Id -> Quantity -> msg
    }


addComponentButton : Config db msg -> Html msg
addComponentButton { addLabel, db, items, openSelectComponentModal, scope } =
    let
        availableComponents =
            db.components
                |> Scope.anyOf [ scope ]
                |> Component.available (List.map .id items)

        autocompleteState =
            AutocompleteSelector.init .name availableComponents
    in
    button
        [ class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , disabled <| List.isEmpty availableComponents
        , onClick <| openSelectComponentModal autocompleteState
        ]
        [ Icon.plus
        , text addLabel
        ]


addElementButton : Config db msg -> Component -> Html msg
addElementButton { db, openSelectProcessModal } component =
    button
        [ class "btn btn-link text-decoration-none"
        , class "d-flex justify-content-end align-items-center"
        , class "gap-2 w-100 p-0 pb-1 text-end"
        , db.processes
            |> Process.listByCategory Category.Material
            |> List.sortBy Process.getDisplayName
            |> AutocompleteSelector.init .name
            |> openSelectProcessModal Category.Material component Nothing
            |> onClick
        ]
        [ Icon.puzzle
        , text "Ajouter un élément"
        ]


addElementTransformButton : Config db msg -> Component -> Int -> Html msg
addElementTransformButton { db, openSelectProcessModal } component index =
    let
        availableTransformProcesses =
            db.processes
                |> Process.listByCategory Category.Transform
                |> List.sortBy Process.getDisplayName
                |> Process.available
                    (component.elements
                        |> LE.getAt index
                        |> Maybe.map .transforms
                        |> Maybe.withDefault []
                    )

        autocompleteState =
            AutocompleteSelector.init .name availableTransformProcesses
    in
    button
        [ class "btn btn-link btn-sm w-100 text-decoration-none"
        , class "d-flex justify-content-start align-items-center"
        , class "gap-1 w-100 p-0 pb-1"
        , disabled <| List.isEmpty availableTransformProcesses
        , autocompleteState
            |> openSelectProcessModal Category.Transform component (Just index)
            |> onClick
        ]
        [ Icon.plus
        , text "Ajouter une transformation"
        ]


componentView : Config db msg -> Item -> ( Quantity, Component, List ExpandedElement ) -> Results -> List (Html msg)
componentView config item ( quantity, component, expandedElements ) itemResults =
    let
        collapsed =
            config.detailed
                |> List.member component.id
                |> not
    in
    List.concat
        [ [ tbody []
                [ tr [ class "border-top border-bottom" ]
                    [ th [ class "ps-2 align-middle", scope "col" ]
                        [ if config.customizable then
                            button
                                [ class "btn btn-link text-muted text-decoration-none font-monospace fs-5 p-0 m-0"
                                , onClick <|
                                    config.setDetailed <|
                                        if collapsed && not (List.member component.id config.detailed) then
                                            LE.unique <| component.id :: config.detailed

                                        else
                                            List.filter ((/=) component.id) config.detailed
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
                        [ quantity |> quantityInput config component.id ]
                    , td [ class "align-middle text-truncate w-100", colspan 2 ]
                        [ if config.customizable then
                            input
                                [ type_ "text"
                                , class "form-control"
                                , onInput (config.updateItemName component)
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
                        [ button
                            [ class "btn btn-outline-secondary"
                            , onClick (config.removeItem component.id)
                            ]
                            [ Icon.trash ]
                        ]
                    ]
                ]
          ]
        , if not collapsed then
            List.map3
                (elementView config component)
                (List.range 0 (List.length expandedElements - 1))
                expandedElements
                (Component.extractItems itemResults)
                |> List.intersperse (tbody [ class "m-0 p-0 border" ] [ td [ colspan 7 ] [] ])

          else
            []
        , if not collapsed then
            [ tbody []
                [ tr [ class "border-top" ]
                    [ td [ colspan 7, class "pe-3" ]
                        [ addElementButton config component
                        ]
                    ]
                ]
            ]

          else
            []
        ]


viewDebug : List Item -> Results -> Html msg
viewDebug items results =
    details [ class "card-body py-2" ]
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
                    [ results
                        |> Component.encodeResults (Just Definition.Ecs)
                        |> Encode.encode 2
                        |> text
                    ]
                ]
            ]
        ]


editorView : Config db msg -> Html msg
editorView ({ db, docsUrl, items, results, scope, title } as config) =
    div []
        [ div [ class "card shadow-sm mb-3" ]
            [ div [ class "card-header d-flex align-items-center justify-content-between" ]
                [ h2 [ class "h5 mb-0" ]
                    [ text title
                    , Link.smallPillExternal
                        [ Route.href (Route.Explore scope (Dataset.Components scope Nothing))
                        , Attr.title "Explorer"
                        , attribute "aria-label" "Explorer"
                        ]
                        [ Icon.search ]
                    ]
                , div [ class "d-flex align-items-center gap-2" ]
                    [ results
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
                            { close = Nothing
                            , content = [ text error ]
                            , level = Alert.Danger
                            , title = Just "Erreur"
                            }

                    Ok expandedItems ->
                        div [ class "table-responsive" ]
                            [ table [ class "table table-sm table-borderless mb-0" ]
                                (thead []
                                    [ tr [ class "fs-7 text-muted" ]
                                        [ th [] []
                                        , th [ class "ps-0", Attr.scope "col" ] [ text "Quantité" ]
                                        , th [ Attr.scope "col", colspan 2 ] [ text "Composant" ]
                                        , th [ Attr.scope "col" ] [ text "Masse" ]
                                        , th [ Attr.scope "col" ] [ text "Impact" ]
                                        , th [ Attr.scope "col" ] []
                                        ]
                                    ]
                                    :: List.concat
                                        (List.map3 (componentView config)
                                            items
                                            expandedItems
                                            (Component.extractItems results)
                                        )
                                )
                            ]
            , addComponentButton config
            ]
        , viewDebug items results
        ]


amountInput : Config db msg -> Component -> String -> Int -> Amount -> Html msg
amountInput config component unit index amount =
    div [ class "input-group" ]
        [ input
            [ type_ "number"
            , class "form-control form-control-sm text-end incdec-arrows-left"
            , amount
                |> Component.amountToFloat
                |> String.fromFloat
                |> value
            , Attr.min "0"
            , step "0.01"
            , onInput <|
                String.toFloat
                    >> Maybe.map Component.Amount
                    >> config.updateElementAmount component index
            ]
            []
        , small [ class "input-group-text fs-8" ]
            [ text unit ]
        ]


elementView : Config db msg -> Component -> Int -> ExpandedElement -> Results -> Html msg
elementView config component index { amount, material, transforms } elementResults =
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
                [ if material.unit == "kg" then
                    text "Masse finale"

                  else
                    text "Quantité finale"
                ]
            , th [ class "align-middle", scope "col" ] [ text <| "Élément #" ++ String.fromInt (index + 1) ]
            , th [ class "align-middle", scope "col" ] [ text "Pertes" ]
            , th [ class "align-middle text-truncate", scope "col", Attr.title "Masse sortante" ] [ text "Masse" ]
            , th [ class "align-middle", scope "col" ] [ text "Impact" ]
            , th [ class "align-middle", scope "col" ] []
            ]
            :: elementMaterialView config component index materialResults material amount
            :: elementTransformsView config component index transformsResults transforms
            ++ (if List.member config.scope [ Scope.Object, Scope.Veli ] then
                    [ tr []
                        [ td [ colspan 2 ] []
                        , td [ colspan 5 ]
                            [ addElementTransformButton config component index
                            ]
                        ]
                    ]

                else
                    []
               )
        )


selectMaterialButton : Config db msg -> Component -> Int -> Process -> Html msg
selectMaterialButton { db, openSelectProcessModal } component index material =
    let
        availableMaterialProcesses =
            db.processes
                |> Process.listByCategory Category.Material
                |> List.sortBy Process.getDisplayName

        autocompleteState =
            AutocompleteSelector.init .name availableMaterialProcesses
    in
    button
        [ class "btn btn-sm btn-link text-decoration-none p-0"
        , autocompleteState
            |> openSelectProcessModal Category.Material component (Just index)
            |> onClick
        ]
        [ span [ class "ComponentElementIcon" ] [ Icon.material ]
        , text <| Process.getDisplayName material
        ]


elementMaterialView : Config db msg -> Component -> Int -> Results -> Process -> Amount -> Html msg
elementMaterialView config component index materialResults material amount =
    tr [ class "fs-7" ]
        [ td [] []
        , td [ class "text-end align-middle text-nowrap ps-0", style "min-width" "130px" ]
            [ if config.scope == Scope.Textile then
                amount
                    |> Component.amountToFloat
                    |> Format.formatRichFloat 3 material.unit

              else
                amountInput config component material.unit index amount
            ]
        , td [ class "align-middle text-truncate w-100", title material.name ]
            [ selectMaterialButton config component index material
            ]
        , td [ class "text-end align-middle text-nowrap" ]
            []
        , td [ class "text-end align-middle text-nowrap" ]
            [ Format.kg <| Component.extractMass materialResults ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Component.extractImpacts materialResults
                |> Format.formatImpact config.impact
            ]
        , td [ class "pe-3  text-nowrap" ]
            [ button
                [ class "btn btn-sm btn-outline-secondary"
                , onClick (config.removeElement component index)
                ]
                [ Icon.trash ]
            ]
        ]


elementTransformsView : Config db msg -> Component -> Int -> List Results -> List Process -> List (Html msg)
elementTransformsView config component index transformsResults transforms =
    List.map3
        (\transformIndex transformResult transform ->
            tr [ class "fs-7" ]
                [ td [] []
                , td [ class "text-end align-middle text-nowrap" ] []
                , td
                    [ class "text-truncate align-middle w-100"

                    -- Note: allows truncated ellipsis in table cells https://stackoverflow.com/a/11877033/330911
                    , style "max-width" "0"
                    , title transform.name
                    ]
                    [ span [ class "ComponentElementIcon" ] [ Icon.transform ]
                    , text <| Process.getDisplayName transform
                    ]
                , td [ class "align-middle text-end text-nowrap" ]
                    [ Format.splitAsPercentage 2 transform.waste ]
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Format.kg <| Component.extractMass transformResult
                    ]
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Component.extractImpacts transformResult
                        |> Format.formatImpact config.impact
                    ]
                , td []
                    [ button
                        [ class "btn btn-sm btn-outline-secondary"
                        , transformIndex
                            |> config.removeElementTransform component index
                            |> onClick
                        ]
                        [ Icon.trash ]
                    ]
                ]
        )
        (List.range 0 (List.length transforms))
        transformsResults
        transforms


quantityInput : Config db msg -> Id -> Quantity -> Html msg
quantityInput config id quantity =
    div [ class "input-group", style "width" "130px" ]
        [ input
            [ type_ "number"
            , class "form-control text-end"
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
                        |> Maybe.map (Component.quantityFromInt >> config.updateItemQuantity id)
                        |> Maybe.withDefault config.noOp
            ]
            []
        ]
