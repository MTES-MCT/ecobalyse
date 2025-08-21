module Views.Scope exposing
    ( scopeFilterForm
    , singleScopeForm
    )

import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


multipleScopesForm : (Scope -> Bool -> msg) -> List Scope -> Html msg
multipleScopesForm check scopes =
    div [ class "d-flex flex-row align-center input-group border" ]
        [ h3 [ class "h6 mb-0 input-group-text" ] [ text "Verticales" ]
        , Scope.all
            |> List.map
                (\scope ->
                    div [ class "form-check form-check-inline" ]
                        [ label [ class "form-check-label" ]
                            [ input
                                [ type_ "checkbox"
                                , class "form-check-input"
                                , checked <| List.member scope scopes
                                , onCheck <| check scope
                                ]
                                []
                            , text (Scope.toString scope)
                            ]
                        ]
                )
            |> div [ class "form-control bg-white" ]
        ]


scopeFilterForm : (List Scope -> msg) -> List Scope -> Html msg
scopeFilterForm update filtered =
    multipleScopesForm
        (\scope enabled ->
            if enabled then
                update (scope :: filtered)

            else
                update (List.filter ((/=) scope) filtered)
        )
        filtered


singleScopeForm : (Scope -> msg) -> Scope -> Html msg
singleScopeForm select selected =
    div [ class "d-flex flex-row gap-3 align-items-center" ]
        [ h3 [ class "h6 mb-0" ] [ text "Verticale" ]
        , Scope.all
            |> List.map
                (\scope ->
                    option
                        [ Attr.selected <| scope == selected
                        , value <| Scope.toString scope
                        ]
                        [ text <| Scope.toLabel scope ]
                )
            |> Html.select
                [ class "form-select"
                , onInput
                    (Scope.fromString
                        >> Result.withDefault selected
                        >> select
                    )
                ]
        ]
