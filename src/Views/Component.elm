module Views.Component exposing (editorView)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Component as Component exposing (Amount, Component, ExpandedElement, Id, Item, Quantity, Results)
import Data.Dataset as Dataset
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
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
    , allowExpandDetails : Bool
    , db : Component.DataContainer db
    , detailed : List Id
    , docsUrl : Maybe String
    , impact : Definition
    , items : List Item
    , noOp : msg
    , openSelectModal : Autocomplete Component -> msg
    , removeItem : Id -> msg
    , results : Component.Results
    , scope : Scope
    , setDetailed : List Id -> msg
    , title : String
    , updateElementAmount : Component -> Process.Id -> Maybe Amount -> msg
    , updateItemQuantity : Id -> Quantity -> msg
    }


addButton : Config db msg -> Html msg
addButton { addLabel, db, items, openSelectModal, scope } =
    let
        availableComponents =
            db.components
                |> Scope.anyOf [ scope ]
                |> Component.available (List.map .id items)

        -- FIXME: this should rather be initiated in page update
        autocompleteState =
            AutocompleteSelector.init .name availableComponents
    in
    button
        [ class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , id "add-new-element"
        , disabled <| List.isEmpty availableComponents
        , onClick <| openSelectModal autocompleteState
        ]
        [ i [ class "icon icon-plus" ] []
        , text addLabel
        ]


componentView :
    Config db msg
    -> ( Component.Quantity, Component, List ExpandedElement )
    -> Component.Results
    -> List (Html msg)
componentView config ( quantity, component, expandedElements ) itemResults =
    let
        collapsed =
            config.detailed
                |> List.member component.id
                |> not
    in
    List.concat
        [ [ tbody []
                [ tr []
                    [ th [ class "ps-3 align-middle", scope "col" ]
                        [ if config.allowExpandDetails then
                            button
                                [ class "btn btn-link text-dark text-decoration-none font-monospace fs-5  p-0 m-0"
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
                    , td [ class "ps-0 align-middle" ]
                        [ quantity |> quantityInput config component.id ]
                    , td [ class "align-middle text-truncate w-100 fw-bold", colspan 2 ]
                        [ text component.name ]
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
            List.map2 (elementView config component)
                expandedElements
                (Component.extractItems itemResults)

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
                            [ table [ class "table mb-0" ]
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
                                    :: (Component.extractItems results
                                            |> List.map2 (componentView config) expandedItems
                                            |> List.concat
                                       )
                                )
                            ]
            , addButton config
            ]
        , viewDebug items results
        ]


amountInput : Config db msg -> Component -> Process -> Amount -> Html msg
amountInput config component material amount =
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
                    >> config.updateElementAmount component material.id
            ]
            []
        , small [ class "input-group-text fs-8" ]
            [ text material.unit ]
        ]


elementView : Config db msg -> Component -> ExpandedElement -> Component.Results -> Html msg
elementView config component { amount, material, transforms } elementResults =
    let
        ( materialResults, transformResults ) =
            case Component.extractItems elementResults of
                [] ->
                    ( Component.emptyResults, [] )

                materialResults_ :: transformResults_ ->
                    ( materialResults_, transformResults_ )
    in
    tbody []
        (tr [ class "fs-7 text-muted" ]
            [ th [] []
            , th [ class "text-end", scope "col" ] [ text "Quantité finale" ]
            , th [ scope "col" ] [ text "Procédé" ]
            , th [ scope "col" ] [ text "Pertes" ]
            , th [ class "text-truncate", scope "col", Attr.title "Masse sortante" ] [ text "Masse" ]
            , th [ scope "col" ] [ text "Impact" ]
            , th [ scope "col" ] [ text "" ]
            ]
            :: tr [ class "fs-7" ]
                [ td [] []
                , td [ class "text-end align-middle text-nowrap ps-0", style "min-width" "130px" ]
                    [ amountInput config component material amount
                    ]
                , td [ class "align-middle text-truncate w-100" ]
                    [ text <| Process.getDisplayName material
                    ]
                , td [ class "align-middle text-end text-nowrap" ]
                    -- Note: waste is never taken into account at the material step
                    []
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Format.kg <| Component.extractMass materialResults ]
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Component.extractImpacts materialResults
                        |> Format.formatImpact config.impact
                    ]
                , td [ class "pe-3 align-middle text-nowrap" ]
                    []
                ]
            :: List.map3
                (\_ transform transformResult ->
                    tr [ class "fs-7" ]
                        [ td [] []
                        , td [ class "text-end align-middle text-nowrap" ] []
                        , td [ class "align-middle text-truncate w-100" ]
                            [ text <| Process.getDisplayName transform
                            ]
                        , td [ class "align-middle text-end text-nowrap" ]
                            [ formatWaste transform.waste ]
                        , td [ class "text-end align-middle text-nowrap" ]
                            [ Format.kg <| Component.extractMass transformResult
                            ]
                        , td [ class "text-end align-middle text-nowrap" ]
                            [ Component.extractImpacts transformResult
                                |> Format.formatImpact config.impact
                            ]
                        ]
                )
                (List.range 0 (List.length transforms))
                transforms
                transformResults
        )


quantityInput : Config db msg -> Id -> Component.Quantity -> Html msg
quantityInput config id quantity =
    div [ class "input-group", style "min-width" "90px", style "max-width" "120px" ]
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


formatWaste : Split -> Html msg
formatWaste waste =
    if Split.toPercent waste == 0 then
        text ""

    else
        Format.splitAsPercentage 3 waste
