module Page.Explore.Table exposing
    ( Column
    , Config
    , Facet
    , Facets
    , Table
    , Value(..)
    , viewDetails
    , viewList
    )

import Base64
import Csv.Encode as EncodeCsv exposing (Csv)
import Data.Scope as Scope exposing (Scope)
import Data.Text as Text
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (Route)
import Set exposing (Set)
import String.Normalize as Normalize
import Table as SortableTable
import Views.Alert as Alert
import Views.Markdown as Markdown
import Views.Table as TableView


type alias Table data comparable msg =
    { filename : String
    , toId : data -> String
    , toRoute : data -> Route
    , toSearchableString : data -> String
    , facets : List (Facet data)
    , columns : List (Column data comparable msg)
    , legend : List (Html msg)
    }


type alias Column data comparable msg =
    { label : String
    , toValue : Value comparable data
    , toCell : data -> Html msg
    }


type alias Facet data =
    { key : String
    , toValues : data -> List String
    }


type alias Facets =
    Dict String (Set String)


type Value comparable data
    = FloatValue (data -> Float)
    | IntValue (data -> Int)
    | NoValue
    | StringValue (data -> String)


type alias Config data msg =
    { toId : data -> String
    , toMsg : SortableTable.State -> msg
    , onFacetToggle : String -> String -> Bool -> msg
    , columns : List (SortableTable.Column data msg)
    , customizations : SortableTable.Customizations data msg
    , selectedFacets : Facets
    , search : String
    }


viewDetails :
    Scope
    -> ({ detailed : Bool, scope : Scope } -> Table data comparable msg)
    -> data
    -> Html msg
viewDetails scope createTable item =
    let
        { legend, columns } =
            createTable { detailed = True, scope = scope }
    in
    div []
        [ div [ class "text-muted fs-7" ] legend
        , TableView.responsiveDefault [ class "view-details" ]
            [ columns
                |> List.map
                    (\{ label, toCell } ->
                        tr []
                            [ th [] [ text label ]
                            , td [] [ toCell item ]
                            ]
                    )
                |> tbody []
            ]
        ]


viewList :
    (Route -> msg)
    -> Config data msg
    -> SortableTable.State
    -> Scope
    -> ({ detailed : Bool, scope : Scope } -> Table data comparable msg)
    -> List data
    -> Html msg
viewList routeToMsg defaultConfig tableState scope createTable items =
    let
        ({ filename, toId, toRoute, toSearchableString, facets, columns, legend } as table) =
            createTable { detailed = False, scope = scope }

        { customizations } =
            defaultConfig

        listCustomizations =
            TableView.freezeSortableHeaders
                { customizations
                    | rowAttrs = toRoute >> routeToMsg >> onClick >> List.singleton
                }

        config =
            SortableTable.customConfig
                { toId = toId
                , toMsg = defaultConfig.toMsg
                , columns =
                    columns
                        |> List.map
                            (\{ label, toCell, toValue } ->
                                SortableTable.veryCustomColumn
                                    { name = label
                                    , viewData = \item -> { attributes = [], children = [ toCell item ] }
                                    , sorter =
                                        -- Search handles sorting its own way
                                        if String.trim defaultConfig.search /= "" then
                                            SortableTable.unsortable

                                        else
                                            case toValue of
                                                FloatValue getFloat ->
                                                    SortableTable.increasingOrDecreasingBy getFloat

                                                IntValue getInt ->
                                                    SortableTable.increasingOrDecreasingBy getInt

                                                NoValue ->
                                                    SortableTable.unsortable

                                                StringValue getString ->
                                                    SortableTable.increasingOrDecreasingBy
                                                        (getString
                                                            >> String.toLower
                                                            >> Normalize.removeDiacritics
                                                        )
                                    }
                            )
                , customizations = listCustomizations
                }

        resultItems =
            items
                |> filterItems facets defaultConfig.selectedFacets
                |> searchItems defaultConfig toSearchableString

        csv =
            { filename = "ecobalyse-" ++ Scope.toString scope ++ "-" ++ filename ++ ".csv"
            , content =
                resultItems
                    |> toCSV table
                    |> EncodeCsv.toString
            }

        facetsEnabled =
            not (List.isEmpty facets)
    in
    if List.isEmpty items then
        Alert.simple
            { attributes = []
            , close = Nothing
            , content =
                [ text <| "Aucun composant disponible pour le secteur "
                , strong [] [ text <| Scope.toLabel scope ]
                ]
            , level = Alert.Info
            , title = Nothing
            }

    else
        div [ class "row g-3" ]
            [ div [ classList [ ( "col-xxl-10 col-xl-9 col-lg-9 col-md-12 col-sm-12", facetsEnabled ) ] ]
                [ div [ class "DatasetTable table-responsive table-scroll position-relative" ]
                    [ case resultItems of
                        [] ->
                            Alert.simple
                                { attributes = []
                                , close = Nothing
                                , content = [ text "Cette recherche n’a retourné aucun résultat" ]
                                , level = Alert.Info
                                , title = Nothing
                                }

                        nonEmptyResult ->
                            nonEmptyResult |> SortableTable.view config tableState
                    , div [ class "text-muted fs-7" ] legend
                    ]
                , div [ class "text-end pt-3" ]
                    [ a
                        [ class "btn btn-secondary"
                        , href <| "data:text/csv;base64," ++ Base64.encode csv.content
                        , download csv.filename
                        ]
                        [ text "Télécharger ces données au format CSV" ]
                    ]
                ]
            , viewFacetsSidebar defaultConfig facets items
            ]


viewFacetsSidebar : Config data msg -> List (Facet data) -> List data -> Html msg
viewFacetsSidebar config facets items =
    if List.isEmpty facets then
        text ""

    else
        div [ class "col-xxl-2 col-xl-3 col-lg-3 col-md-12 col-sm-12" ]
            [ facets
                |> List.map (viewFacet config items)
                |> div [ class "d-flex flex-column gap-2 sticky-top", style "top" "10px" ]
            ]


viewFacet : Config data msg -> List data -> Facet data -> Html msg
viewFacet { selectedFacets, onFacetToggle } items { key, toValues } =
    let
        selectedValues =
            Dict.get key selectedFacets
                |> Maybe.withDefault Set.empty

        availableValues =
            items
                |> List.concatMap toValues
                |> Set.fromList
                |> Set.toList
    in
    div [ class "card fs-8" ]
        [ div [ class "card-header fw-semibold py-2" ] [ text key ]
        , div
            [ class "card-body d-flex flex-column gap-1 p-2"
            , style "max-height" "200px"
            , style "overflow-y" "auto"
            ]
            (if List.isEmpty availableValues then
                [ em [ class "text-muted small" ] [ text "Aucune valeur disponible" ] ]

             else
                availableValues
                    -- selected facet values first
                    |> List.sortBy
                        (\value ->
                            if Set.member value selectedValues then
                                0

                            else
                                1
                        )
                    |> List.map
                        (\value ->
                            Html.label [ class "form-check d-flex align-items-start gap-2 cursor-pointer", title value ]
                                [ input
                                    [ type_ "checkbox"
                                    , class "form-check-input mt-1 no-outline"
                                    , checked (Set.member value selectedValues)
                                    , onCheck (onFacetToggle key value)
                                    ]
                                    []
                                , span [ class "form-check-label text-truncate" ] [ text value ]
                                ]
                        )
            )
        ]


searchItems : Config data msg -> (data -> String) -> List data -> List data
searchItems { search } toSearchableString =
    Text.search
        { minQueryLength = 2
        , query = search
        , toString = toSearchableString
        }


filterItems : List (Facet data) -> Facets -> List data -> List data
filterItems facets selectedFacets =
    List.filter
        (\item ->
            facets
                |> List.all
                    (\{ key, toValues } ->
                        case Dict.get key selectedFacets of
                            Just selectedValues ->
                                if Set.isEmpty selectedValues then
                                    True

                                else
                                    Set.toList selectedValues
                                        |> List.all (\selectedValue -> toValues item |> List.member selectedValue)

                            Nothing ->
                                True
                    )
        )


toCSV : Table data comparable msg -> List data -> Csv
toCSV { columns } items =
    let
        nonEmptyColumns =
            columns
                |> List.filter (.label >> (/=) "")
    in
    { headers =
        nonEmptyColumns
            |> List.map .label
    , records =
        items
            |> List.map
                (\item ->
                    nonEmptyColumns
                        |> List.map (.toValue >> valueToString item)
                )
    }


valueToString : data -> Value comparable data -> String
valueToString item toValue =
    case toValue of
        FloatValue getFloat ->
            getFloat item |> String.fromFloat

        IntValue getInt ->
            getInt item |> String.fromInt

        NoValue ->
            "N/A"

        StringValue getString ->
            getString item
