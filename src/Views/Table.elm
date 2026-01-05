module Views.Table exposing
    ( freezeSortableHeaders
    , percentageTable
    , responsiveDefault
    )

import Data.Impact.Definition exposing (Definition)
import Html exposing (..)
import Html.Attributes exposing (..)
import Table as SortableTable
import Views.Format as Format


type alias DataPoint msg =
    { entryAttributes : List (Attribute msg)
    , name : String
    , value : Float
    }


{-| Makes a sortable table header "frozen" when you scroll rows, "as in microsoft excel".
Note: parent html element must use `position:relative` and declare an height.
-}
freezeSortableHeaders : SortableTable.Customizations data msg -> SortableTable.Customizations data msg
freezeSortableHeaders customizations =
    { customizations
        | thead =
            \headers ->
                let
                    htmlDetails =
                        customizations.thead headers
                in
                { htmlDetails
                    | attributes = htmlDetails.attributes ++ [ class "sticky-md-top bg-white" ]
                }
    }


responsiveDefault : List (Attribute msg) -> List (Html msg) -> Html msg
responsiveDefault attrs content =
    div [ class "DatasetTable table-responsive table-scroll position-relative" ]
        [ table (class "table table-striped table-hover mb-0" :: attrs) content
        ]


percentageTable : Definition -> List (DataPoint msg) -> Html msg
percentageTable impactDefinition data =
    let
        values =
            List.map .value data

        ( total, minimum, maximum ) =
            ( List.sum values
            , values |> List.minimum |> Maybe.withDefault 0
            , values |> List.maximum |> Maybe.withDefault 0
            )
    in
    if total == 0 && maximum == 0 && minimum == 0 then
        text ""

    else
        div [ class "table-responsive", style "max-height" "400px" ]
            [ table [ class "table table-hover w-100 m-0" ]
                [ data
                    |> List.map
                        (\{ entryAttributes, name, value } ->
                            { entryAttributes = entryAttributes
                            , impact = value
                            , name = name
                            , percent = value / total * 100
                            , width =
                                if value < 0 then
                                    abs (value / minimum * 100)

                                else
                                    value / maximum * 100
                            }
                        )
                    |> List.map
                        (\{ entryAttributes, impact, name, percent, width } ->
                            let
                                entryTitle =
                                    name
                                        ++ ": "
                                        ++ Format.formatFloat 2 percent
                                        ++ "\u{202F}% ("
                                        ++ Format.formatFloat 2 impact
                                        ++ "\u{202F}"
                                        ++ impactDefinition.unit
                                        ++ ")"
                            in
                            tr
                                (title entryTitle
                                    :: entryAttributes
                                )
                                [ th [ class "text-truncate fw-normal fs-8", style "max-width" "200px" ] [ text name ]
                                , td [ class "HorizontalBarChart", style "width" "200px", style "vertical-align" "middle" ]
                                    [ div
                                        [ class "ext"
                                        , classList [ ( "pos", percent >= 0 ), ( "neg", percent < 0 ) ]
                                        ]
                                        [ div
                                            [ class "bar"
                                            , classList [ ( "bg-secondary", percent >= 0 ), ( "bg-success", percent < 0 ) ]
                                            , style "width" (String.fromFloat width ++ "%")
                                            ]
                                            []
                                        ]
                                    ]
                                , td [ class "text-end text-nowrap fs-8" ]
                                    [ Format.percent percent
                                    ]
                                ]
                        )
                    |> tbody []
                ]
            ]
