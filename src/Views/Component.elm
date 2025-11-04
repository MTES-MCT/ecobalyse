module Views.Component exposing (editorView)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Component as Component
    exposing
        ( Amount
        , Component
        , EndOfLifeMaterialImpacts
        , ExpandedElement
        , ExpandedItem
        , Index
        , Item
        , LifeCycle
        , Quantity
        , Results
        , TargetElement
        , TargetItem
        )
import Data.Country as Country exposing (Country)
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split
import Data.Unit as Unit
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
import Views.Transport as TransportView


type alias Config db msg =
    { addLabel : String
    , componentConfig : Component.Config
    , customizable : Bool
    , db : Component.DataContainer db
    , debug : Bool
    , detailed : List Index
    , docsUrl : Maybe String
    , explorerRoute : Maybe Route
    , impact : Definition
    , items : List Item
    , lifeCycle : Result String LifeCycle
    , maxItems : Maybe Int
    , noOp : msg
    , openSelectComponentModal : Autocomplete Component -> msg
    , openSelectProcessModal : Category -> TargetItem -> Maybe Index -> Autocomplete Process -> msg
    , removeElement : TargetElement -> msg
    , removeElementTransform : TargetElement -> Index -> msg
    , removeItem : Index -> msg
    , scope : Scope
    , setDetailed : List Index -> msg
    , title : String
    , updateElementAmount : TargetElement -> Maybe Amount -> msg
    , updateItemCountry : Index -> Maybe Country.Code -> msg
    , updateItemName : TargetItem -> String -> msg
    , updateItemQuantity : Index -> Quantity -> msg
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


addElementButton : Config db msg -> TargetItem -> Html msg
addElementButton { db, openSelectProcessModal, scope } targetItem =
    button
        [ type_ "button"
        , class "btn btn-link text-decoration-none"
        , class "d-flex justify-content-end align-items-center"
        , class "gap-2 w-100 p-0 pb-1 text-end"
        , db.processes
            |> Scope.anyOf [ scope ]
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
addElementTransformButton { db, items, openSelectProcessModal, scope } material ( targetItem, elementIndex ) =
    let
        availableTransformProcesses =
            db.processes
                |> Scope.anyOf [ scope ]
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


componentView : Config db msg -> Index -> Item -> ExpandedItem -> Results -> List (Html msg)
componentView config itemIndex item { component, country, elements, quantity } itemResults =
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
                        [ div [ class "d-flex gap-2" ] <|
                            if config.customizable then
                                [ input
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
                                , countrySelector
                                    { countries = config.db.countries
                                    , domId = "item-country-" ++ String.fromInt itemIndex
                                    , scope = config.scope
                                    , select = config.updateItemCountry itemIndex
                                    , selected = country
                                    }
                                ]

                            else
                                [ span [ class "fw-bold" ] [ text component.name ] ]
                        ]
                    , td [ class "text-end align-middle text-nowrap fs-7" ]
                        [ Component.extractMass itemResults
                            |> Format.kg
                        ]
                    , td [ class "text-end align-middle text-nowrap fs-7" ]
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
                (List.range 0 (List.length elements - 1))
                elements
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
editorView config =
    case config.lifeCycle of
        Err error ->
            Alert.simple
                { attributes = []
                , close = Nothing
                , content = [ text error ]
                , level = Alert.Danger
                , title = Just "Erreur de chargement du calculateur"
                }

        Ok lifeCycle ->
            lifeCycleView config lifeCycle


lifeCycleView : Config db msg -> LifeCycle -> Html msg
lifeCycleView ({ db, docsUrl, explorerRoute, maxItems, items, scope, title } as config) lifeCycle =
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
                    [ lifeCycle.production
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
                                            (Component.extractItems lifeCycle.production)
                                        )
                                )
                            ]
            , if maxItems == Just 1 then
                text ""

              else
                addComponentButton config
            ]
        , if (List.length items > 1) && List.member scope [ Scope.Object, Scope.Veli ] then
            div []
                [ DownArrow.view [] []
                , assemblyView config lifeCycle
                ]

          else
            text ""
        , if not (List.isEmpty items) && List.member scope [ Scope.Object, Scope.Veli ] then
            div []
                [ DownArrow.view [] []
                , endOfLifeView config lifeCycle
                ]

          else
            text ""
        , if config.debug then
            viewDebug items lifeCycle

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


type alias CountrySelector msg =
    { countries : List Country
    , domId : String
    , scope : Scope
    , select : Maybe Country.Code -> msg
    , selected : Maybe Country
    }


countrySelector : CountrySelector msg -> Html msg
countrySelector config =
    config.countries
        |> Scope.anyOf [ config.scope ]
        |> List.sortBy .name
        |> List.map (\{ code, name } -> ( name, Just code ))
        |> (::) ( "Monde", Nothing )
        |> List.map
            (\( name, maybeCode ) ->
                option
                    [ maybeCode
                        |> Maybe.map Country.codeToString
                        |> Maybe.withDefault ""
                        |> value
                    , selected <| Maybe.map .code config.selected == maybeCode
                    ]
                    [ text name ]
            )
        |> select
            [ class "form-select w-33"
            , id config.domId
            , onInput <|
                \str ->
                    config.select
                        (if String.isEmpty str then
                            Nothing

                         else
                            Just <| Country.codeFromString str
                        )
            ]


elementView : Config db msg -> TargetItem -> Index -> ExpandedElement -> Results -> Html msg
elementView config targetItem elementIndex { amount, country, material, transforms } elementResults =
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
            :: elementTransformsView config ( targetItem, elementIndex ) country transformsResults transforms
            ++ (if config.scope /= Scope.Textile then
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
            [ if config.scope == Scope.Textile then
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


elementTransformsView : Config db msg -> TargetElement -> Maybe Country -> List Results -> List Process -> List (Html msg)
elementTransformsView config targetElement maybeCountry transformsResults transforms =
    List.map3
        (\transformIndex transformResult transform ->
            let
                tooltipText =
                    "Procédé\u{00A0}: "
                        ++ Process.getDisplayName transform
                        ++ (Component.loadEnergyMixes config.db.processes maybeCountry
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
            tr [ class "fs-7" ]
                [ td [] []
                , td [ class "text-end align-middle text-nowrap" ] []
                , td
                    [ class "text-truncate align-middle w-100 cursor-help"

                    -- Note: allows truncated ellipsis in table cells https://stackoverflow.com/a/11877033/330911
                    , style "max-width" "0"
                    , title tooltipText
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


assemblyView : Config db msg -> LifeCycle -> Html msg
assemblyView config lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Assemblage" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ lifeCycle.transports.impacts
                    |> Format.formatImpact config.impact
                ]
            ]
        , div [ class "card-body" ]
            [ div []
                [ label [ for "assembly-country" ] [ text "Pays d'assemblage" ]
                , countrySelector
                    { countries = config.db.countries
                    , domId = "assembly-country"
                    , scope = config.scope

                    -- TODO: add updateAssemblyCountry event
                    , select = \_ -> config.noOp

                    -- TODO: after having query moved into config, use query.assemblyCountry
                    , selected = Nothing
                    }
                ]
            , lifeCycle.transports
                |> TransportView.viewDetails
                    { airTransportLabel = Nothing
                    , fullWidth = True
                    , hideNoLength = False
                    , onlyIcons = False
                    , roadTransportLabel = Nothing
                    , seaTransportLabel = Nothing
                    }
                |> div []
            ]
        ]


endOfLifeView : Config db msg -> LifeCycle -> Html msg
endOfLifeView ({ componentConfig } as config) lifeCycle =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header d-flex align-items-center justify-content-between" ]
            [ h2 [ class "h5 mb-0" ]
                [ text "Fin de vie" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ lifeCycle.production
                    |> Component.getEndOfLifeImpacts
                        { config = componentConfig
                        , db = config.db
                        , scope = config.scope
                        }
                    |> Format.formatImpact config.impact
                ]
            ]
        , div [ class "card-body table-responsive p-0" ]
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
                    |> AnyDict.toList
                    |> List.sortBy (Tuple.first >> Category.materialTypeToLabel)
                    |> List.concatMap (endOfLifeMaterialRow config)
                    |> tbody []
                ]
            ]
        ]


endOfLifeMaterialRow : Config db msg -> ( Category.Material, EndOfLifeMaterialImpacts ) -> List (Html msg)
endOfLifeMaterialRow ({ componentConfig, scope } as config) ( materialType, { collected, nonCollected } ) =
    let
        collectionShare =
            scope |> Component.getEndOfLifeScopeCollectionRate componentConfig

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
