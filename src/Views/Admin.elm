module Views.Admin exposing
    ( Section(..)
    , viewMenu
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


toString : Section -> String
toString section =
    case section of
        ComponentSection ->
            "Composants"

        ProcessSection ->
            "Procédés (à venir)"


viewMenu : List (Attribute msg) -> Section -> Html msg
viewMenu attributes currenSection =
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
            ([ class "btn-group"
             , attribute "role" "group"
             , attribute "aria-label" "Sections du back-office"
             ]
                ++ attributes
            )
