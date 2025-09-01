module Views.Admin exposing
    ( header
    , scopedSearchForm
    , selectAll
    , selectCheckboxAll
    , selectCheckboxElement
    , toggleSelected
    )

import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Page.Admin.Section as AdminSection exposing (Section(..))
import RemoteData
import Request.BackendHttp exposing (WebData)
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


selectAll : Bool -> WebData (List { a | id : id }) -> List id
selectAll flag webData =
    case webData of
        RemoteData.Success elements ->
            if flag then
                List.map .id elements

            else
                []

        _ ->
            []


selectCheckboxAll : (Bool -> msg) -> List a -> List b -> Html msg
selectCheckboxAll check selected elements =
    input
        [ type_ "checkbox"
        , class "form-check-input"
        , style "margin-top" "5px"
        , id "all-selected"
        , onCheck check
        , checked (List.length selected == List.length elements)
        , attribute "aria-label" "tout sélectionner"
        ]
        []


selectCheckboxElement : (id -> String) -> (id -> Bool -> msg) -> id -> List id -> Html msg
selectCheckboxElement toString toggle id selected =
    input
        [ type_ "checkbox"
        , class "form-check-input"
        , style "margin-top" "5px"
        , Attr.id <| toString id ++ "-selected"
        , onCheck (toggle id)
        , checked (List.member id selected)
        , attribute "aria-label" "sélection"
        ]
        []


toggleSelected : id -> Bool -> List id -> List id
toggleSelected id add =
    if add then
        (::) id >> LE.unique

    else
        List.filter <| (/=) id
