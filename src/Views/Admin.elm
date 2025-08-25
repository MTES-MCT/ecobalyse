module Views.Admin exposing
    ( header
    , scopedSearchForm
    )

import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Admin.Section as AdminSection exposing (Section(..))
import Route
import Views.Scope as ScopeView


all : List ( Section, Bool )
all =
    List.sortBy (Tuple.first >> AdminSection.toLabel >> String.toLower)
        [ ( AccountSection, True )
        , ( ComponentSection, True )
        , ( ProcessSection, True )
        ]


header : Section -> Html msg
header currentSection =
    div [ class "row pb-2" ]
        [ div [ class "col-lg-6 col-xl-8" ]
            [ h1 [ class "mb-0 d-flex align-items-baseline" ]
                [ small [ class "h3 text-muted" ] [ text "Admin/" ]
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


scopedSearchForm :
    { scopes : List Scope
    , search : String -> msg
    , searched : String
    , updateScopes : List Scope -> msg
    }
    -> Html msg
scopedSearchForm { scopes, search, searched, updateScopes } =
    div [ class "row g-3" ]
        [ div [ class "col-lg-8" ]
            [ ScopeView.scopeFilterForm updateScopes scopes ]
        , div [ class "col-lg-4 position-relative" ]
            [ input
                [ type_ "search"
                , class "form-control"
                , style "height" "calc(100% - 1px)"
                , placeholder "🔍 Rechercher"
                , onInput search
                , value searched
                ]
                []
            ]
        ]
