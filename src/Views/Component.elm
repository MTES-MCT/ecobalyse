module Views.Component exposing (editorView)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Component as Component exposing (Component, ComponentItem)
import Data.Dataset as Dataset
import Data.Impact.Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Route
import Static.Db exposing (Db)
import Views.Alert as Alert
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


type alias Config msg =
    { componentItems : List ComponentItem
    , db : Db
    , detailedComponents : List Component.Id
    , impact : Definition
    , noOp : msg
    , openSelectModal : Autocomplete Component -> msg
    , removeComponentItem : Component.Id -> msg
    , results : Component.Results
    , scope : Scope
    , setDetailedComponents : List Component.Id -> msg
    , title : String
    , updateComponentItem : ComponentItem -> msg
    }


addComponentButton : Config msg -> Html msg
addComponentButton { componentItems, db, openSelectModal } =
    let
        availableComponents =
            db.object.components
                |> Component.available (List.map .id componentItems)

        autocompleteState =
            AutocompleteSelector.init .name availableComponents
    in
    button
        [ class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , id "add-new-element"
        , disabled <| List.length availableComponents == 0
        , onClick <| openSelectModal autocompleteState
        ]
        [ i [ class "icon icon-plus" ] []
        , text "Ajouter un composant"
        ]


componentView :
    Config msg
    -> ( Component.Quantity, Component, List ( Component.Amount, Process ) )
    -> Component.Results
    -> List (Html msg)
componentView config ( quantity, component, processAmounts ) itemResults =
    let
        collapsed =
            config.detailedComponents
                |> List.member component.id
                |> not
    in
    List.concat
        [ [ tr []
                [ th [ class "ps-3 align-middle", scope "col" ]
                    [ button
                        [ class "btn btn-link text-dark text-decoration-none font-monospace fs-5  p-0 m-0"
                        , onClick <|
                            config.setDetailedComponents
                                (if collapsed && not (List.member component.id config.detailedComponents) then
                                    LE.unique <| component.id :: config.detailedComponents

                                 else
                                    List.filter ((/=) component.id) config.detailedComponents
                                )
                        ]
                        [ if collapsed then
                            text "▶"

                          else
                            text "▼"
                        ]
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
                , td [ class "pe-3 align-middle text-nowrap" ]
                    [ button
                        [ class "btn btn-outline-secondary"
                        , onClick (config.removeComponentItem component.id)
                        ]
                        [ Icon.trash ]
                    ]
                ]
          , if not collapsed then
                tr [ class "fs-7 text-muted" ]
                    [ th [] []
                    , th [ class "text-end", scope "col" ] [ text "Quantité" ]
                    , th [ scope "col" ] [ text "Procédé" ]
                    , th [ scope "col" ] [ text "Densité" ]
                    , th [ scope "col" ] [ text "Masse" ]
                    , th [ scope "col" ] [ text "Impact" ]
                    , th [ scope "col" ] [ text "" ]
                    ]

            else
                text ""
          ]
        , if not collapsed then
            Component.extractItems itemResults
                |> List.map2 (processView config.impact) processAmounts

          else
            []
        ]


editorView : Config msg -> Html msg
editorView ({ db, componentItems, results, scope, title } as config) =
    div [ class "card shadow-sm mb-3" ]
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
            ]
        , if List.isEmpty componentItems then
            div [ class "card-body" ] [ text "Aucun élément." ]

          else
            case Component.expandComponentItems db.object componentItems of
                Err error ->
                    Alert.simple
                        { close = Nothing
                        , content = [ text error ]
                        , level = Alert.Danger
                        , title = Just "Erreur"
                        }

                Ok elements ->
                    div [ class "table-responsive" ]
                        [ table [ class "table mb-0" ]
                            [ thead []
                                [ tr [ class "fs-7 text-muted" ]
                                    [ th [] []
                                    , th [ class "ps-0", Attr.scope "col" ] [ text "Quantité" ]
                                    , th [ Attr.scope "col", colspan 2 ] [ text "Composant" ]
                                    , th [ Attr.scope "col" ] [ text "Masse" ]
                                    , th [ Attr.scope "col" ] [ text "Impact" ]
                                    , th [ Attr.scope "col" ] []
                                    ]
                                ]
                            , Component.extractItems results
                                |> List.map2 (componentView config) elements
                                |> List.concat
                                |> tbody []
                            ]
                        ]
        , addComponentButton config
        ]


processView : Definition -> ( Component.Amount, Process ) -> Component.Results -> Html msg
processView selectedImpact ( amount, process ) itemResults =
    tr [ class "fs-7" ]
        [ td [] []
        , td [ class "text-end text-nowrap" ]
            [ Format.amount process amount ]
        , td [ class "align-middle text-truncate w-100" ]
            [ text <| Process.getDisplayName process ]
        , td [ class "align-middle text-end text-nowrap" ]
            [ Format.density process ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Format.kg <| Component.extractMass itemResults ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Component.extractImpacts itemResults
                |> Format.formatImpact selectedImpact
            ]
        , td [ class "pe-3 align-middle text-nowrap" ]
            []
        ]


quantityInput : Config msg -> Component.Id -> Component.Quantity -> Html msg
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
                        |> Maybe.map
                            (\nonNullInt ->
                                config.updateComponentItem
                                    { id = id
                                    , quantity = Component.quantityFromInt nonNullInt
                                    }
                            )
                        |> Maybe.withDefault config.noOp
            ]
            []
        ]
