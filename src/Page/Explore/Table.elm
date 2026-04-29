module Page.Explore.Table exposing
    ( Column
    , Config
    , Facet
    , Facets
    , Table
    , Value(..)
    , updateFacets
    , viewDetails
    , viewList
    )

import Csv.Encode exposing (Csv)
import Data.Scope as Scope exposing (Scope)
import Data.Text as Text
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Route exposing (Route)
import Set exposing (Set)
import String.Normalize as Normalize
import Table as SortableTable
import Views.Alert as Alert
import Views.Table as TableView


type alias Table data comparable msg =
    { filename : String
    , toId : data -> String
    , toRoute : data -> Route
    , toSearchableWords : data -> List String
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
    , downloadCsv : String -> Csv -> msg
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
        ({ filename, toId, toRoute, toSearchableWords, facets, columns, legend } as table) =
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
            items |> applyFiltersAndSearch defaultConfig facets toSearchableWords

        csv =
            { filename = "ecobalyse-" ++ Scope.toString scope ++ "-" ++ filename ++ ".csv"
            , content =
                resultItems
                    |> toCSV table
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
                    [ if List.isEmpty resultItems then
                        Alert.simple
                            { attributes = []
                            , close = Nothing
                            , content = [ text "Cette recherche n’a retourné aucun résultat" ]
                            , level = Alert.Info
                            , title = Nothing
                            }

                      else
                        resultItems |> SortableTable.view config tableState
                    , div [ class "text-muted fs-7" ] legend
                    ]
                , div [ class "text-end pt-3" ]
                    [ button
                        [ class "btn btn-secondary"
                        , onClick <| defaultConfig.downloadCsv csv.filename csv.content
                        ]
                        [ text "Télécharger ces données au format CSV" ]
                    ]
                ]
            , div
                [ class "col-xxl-2 col-xl-3 col-lg-3 col-md-12 col-sm-12 overflow-y-scroll sticky-top"
                ]
                [ viewFacetsSidebar defaultConfig facets items
                ]
            ]


applyFiltersAndSearch : Config data msg -> List (Facet data) -> (data -> List String) -> List data -> List data
applyFiltersAndSearch config facets toSearchableWords =
    filterItems config facets
        >> searchItems config toSearchableWords


viewFacet : Config data msg -> List data -> Facet data -> Html msg
viewFacet ({ selectedFacets } as config) items { key, toValues } =
    let
        selectedValues =
            Dict.get key selectedFacets
                |> Maybe.withDefault Set.empty

        -- group values to have selected first, available last
        ( selectedOptions, availableOptions ) =
            items
                |> List.concatMap toValues
                |> LE.unique
                |> List.foldl
                    (\value ( selected, available ) ->
                        if Set.member value selectedValues then
                            ( value :: selected, available )

                        else
                            ( selected, value :: available )
                    )
                    ( [], [] )
                |> Tuple.mapBoth Text.sortI18nStrings Text.sortI18nStrings
    in
    div [ class "FacetCard card" ]
        [ div [ class "card-header fw-bold py-2" ] [ text key ]
        , div
            [ class "FacetCardBody card-body d-flex flex-column gap-1 p-2 no-scroll-chaining"
            , attribute "data-scroll-id" key
            ]
            (if List.isEmpty (selectedOptions ++ availableOptions) then
                [ em [ class "text-muted small" ] [ text "Aucune valeur disponible" ] ]

             else
                List.concat
                    [ selectedOptions |> List.map (viewFacetOption config True key)
                    , if not (List.isEmpty selectedOptions) then
                        [ div [ class "FacetCardSeparator border-bottom" ] [] ]

                      else
                        []
                    , availableOptions |> List.map (viewFacetOption config False key)
                    ]
            )
        ]


viewFacetOption : Config data msg -> Bool -> String -> String -> Html msg
viewFacetOption config isSelected key value =
    label
        [ class "form-check d-flex align-items-start gap-2 cursor-pointer"
        , classList [ ( "fw-semibold", isSelected ) ]
        , title value
        ]
        [ input
            [ type_ "checkbox"
            , class "form-check-input mt-1 no-outline"
            , checked isSelected
            , onCheck (config.onFacetToggle key value)
            ]
            []
        , span [ class "form-check-label text-truncate" ] [ text value ]
        ]


viewFacetsSidebar : Config data msg -> List (Facet data) -> List data -> Html msg
viewFacetsSidebar config facets items =
    facets
        |> List.map (viewFacet config items)
        |> div [ class "d-flex flex-column gap-2" ]


filterItems : Config data msg -> List (Facet data) -> List data -> List data
filterItems { selectedFacets } facets =
    List.filter
        (\item ->
            facets
                |> List.all
                    (\{ key, toValues } ->
                        selectedFacets
                            |> Dict.get key
                            |> Maybe.map
                                (\selectedValues ->
                                    if Set.isEmpty selectedValues then
                                        True

                                    else
                                        selectedValues
                                            |> Set.toList
                                            |> List.any (\value -> item |> toValues |> List.member value)
                                )
                            |> Maybe.withDefault True
                    )
        )


searchItems : Config data msg -> (data -> List String) -> List data -> List data
searchItems { search } toSearchableWords =
    Text.search
        { minQueryLength = 2
        , query = search
        , toSearchableWords = toSearchableWords
        }


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


updateFacets : String -> String -> Bool -> Facets -> Facets
updateFacets key value checked =
    Dict.update key
        (Maybe.withDefault Set.empty
            >> (if checked then
                    Set.insert value

                else
                    Set.remove value
               )
            >> Just
        )


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
