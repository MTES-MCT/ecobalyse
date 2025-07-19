module Views.Admin exposing (header)

import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Admin.Section as AdminSection exposing (Section(..))
import Route exposing (Route)


all : List ( Section, Route, Bool )
all =
    [ ( AccountSection, Route.Admin AccountSection, True )
    , ( ComponentSection, Route.Admin ComponentSection, True )
    , ( ProcessSection, Route.Admin ProcessSection, False )
    ]


header : Section -> Html msg
header currentSection =
    div [ class "row" ]
        [ div [ class "col-md-6 col-lg-8" ]
            [ h1 [ class "mb-0" ]
                [ text "Administration"
                , small [ class "h3 text-muted" ] [ text <| " des " ++ AdminSection.toLabel currentSection ]
                ]
            ]
        , div [ class "col-md-6 col-lg-4 d-flex justify-content-end align-items-end" ]
            [ menu currentSection
            ]
        ]


menu : Section -> Html msg
menu currenSection =
    all
        |> List.map
            (\( section, route, enabled ) ->
                a
                    [ class "btn"
                    , classList
                        [ ( "btn-primary", section == currenSection )
                        , ( "btn-outline-primary", section /= currenSection )
                        , ( "disabled", not enabled )
                        ]
                    , Route.href route
                    ]
                    [ text (AdminSection.toLabel section) ]
            )
        |> nav
            [ class "btn-group w-100 w-md-auto mt-2"
            , attribute "role" "group"
            , attribute "aria-label" "Sections du back-office"
            ]
