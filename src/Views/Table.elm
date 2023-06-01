module Views.Table exposing
    ( percentageTable
    , responsiveDefault
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


responsiveDefault : List (Attribute msg) -> List (Html msg) -> Html msg
responsiveDefault attrs content =
    div [ class "DatasetTable table-responsive" ]
        [ table
            (class "table table-striped table-hover table-responsive mb-0"
                :: attrs
            )
            content
        ]


percentageTable : List ( String, Float ) -> Html msg
percentageTable data =
    let
        total =
            data |> List.map Tuple.second |> List.sum

        strongest =
            data |> List.map Tuple.second |> List.maximum |> Maybe.withDefault 100

        dataWithPercentages =
            data
                |> List.map
                    (\( name, value ) ->
                        { name = name
                        , percent = value / total * 100
                        , vsStrongest = value / strongest * 100
                        }
                    )
    in
    table [ class "table w-100 m-0" ]
        [ dataWithPercentages
            |> List.map
                (\{ name, percent, vsStrongest } ->
                    tr []
                        [ th [ class "text-truncate fw-normal fs-8", style "max-width" "200px" ] [ text name ]
                        , td [ style "width" "200px", style "vertical-align" "middle" ]
                            [ div [ class "progress bg-white", style "width" "100%", style "height" "13px" ]
                                [ div
                                    [ class "progress-bar bg-secondary"
                                    , style "width" (String.fromFloat vsStrongest ++ "%")
                                    ]
                                    []
                                ]
                            ]
                        , td [ class "text-end fs-8" ]
                            [ Format.percent percent
                            ]
                        ]
                )
            |> tbody []
        ]
