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
        values =
            List.map Tuple.second data

        ( total, minimum, maximum ) =
            ( List.sum values
            , values |> List.maximum |> Maybe.withDefault 0
            , values |> List.maximum |> Maybe.withDefault 0
            )
    in
    if total == 0 || maximum == 0 then
        text ""

    else
        table [ class "table table-hover w-100 m-0" ]
            [ data
                |> List.map
                    (\( name, value ) ->
                        { name = name
                        , impact = value
                        , percent = value / total * 100
                        , width =
                            if value < 0 then
                                abs (value / minimum * 100)

                            else
                                value / maximum * 100
                        }
                    )
                |> List.map
                    (\{ name, impact, percent, width } ->
                        tr [ title <| name ++ ": " ++ Format.formatFloat 2 percent ++ "\u{202F}% (" ++ Format.formatFloat 2 impact ++ "\u{202F}µPts)" ]
                            [ th [ class "text-truncate fw-normal fs-8", style "max-width" "200px", title name ] [ text name ]
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
