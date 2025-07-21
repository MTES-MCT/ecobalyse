module Views.Admin exposing (header)

import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Admin.Section as AdminSection exposing (Section(..))
import Route


all : List ( Section, Bool )
all =
    [ ( AccountSection, True )
    , ( ComponentSection, True )
    , ( ProcessSection, False )
    ]


header : Section -> Html msg
header currentSection =
    div [ class "row pb-2" ]
        [ div [ class "col-lg-6 col-xl-8" ]
            [ h1 [ class "mb-0 d-flex align-items-baseline gap-2" ]
                [ small [ class "h3 text-muted" ] [ text "Admin" ]
                , text <| AdminSection.toLabel currentSection
                ]
            ]
        , div [ class "col-lg-6 col-xl-4 d-flex justify-content-end align-items-end" ]
            [ menu currentSection
            ]
        ]


menu : Section -> Html msg
menu currenSection =
    all
        |> List.map
            (\( section, enabled ) ->
                a
                    [ class "btn"
                    , classList
                        [ ( "btn-primary", section == currenSection )
                        , ( "btn-outline-primary", section /= currenSection )
                        , ( "disabled", not enabled )
                        ]
                    , Route.href <| Route.Admin section
                    ]
                    [ text (AdminSection.toLabel section) ]
            )
        |> nav
            [ class "btn-group w-100 w-md-auto mt-2"
            , attribute "role" "group"
            , attribute "aria-label" "Sections du back-office"
            ]
