module Views.Admin exposing
    ( Section(..)
    , header
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


type Section
    = ComponentSection
    | ProcessSection


all : List ( Section, Route )
all =
    [ ( ComponentSection, Route.ComponentAdmin )

    -- TODO: update with process admin route once we have one
    , ( ProcessSection, Route.Home )
    ]


header : Section -> Html msg
header currentSection =
    div [ class "row" ]
        [ div [ class "col-md-6 col-lg-8" ]
            [ h1 [ class "mb-0" ] [ text "Ecobalyse Admin" ]
            ]
        , div [ class "col-md-6 col-lg-4 d-flex justify-content-end align-items-end" ]
            [ menu currentSection
            ]
        ]


menu : Section -> Html msg
menu currenSection =
    all
        |> List.map
            (\( section, route ) ->
                a
                    [ class "btn"
                    , classList
                        [ ( "btn-primary", section == currenSection )
                        , ( "btn-outline-primary", section /= currenSection )
                        ]
                    , Route.href route
                    ]
                    [ text (toString section) ]
            )
        |> nav
            [ class "btn-group w-100 w-md-auto mt-2"
            , attribute "role" "group"
            , attribute "aria-label" "Sections du back-office"
            ]


toString : Section -> String
toString section =
    case section of
        ComponentSection ->
            "Composants"

        ProcessSection ->
            "Procédés (à venir)"
