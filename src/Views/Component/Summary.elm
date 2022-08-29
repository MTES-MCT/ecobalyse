module Views.Component.Summary exposing (Config, view)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Config msg =
    { header : List (Html msg)
    , body : List (Html msg)
    , footer : List (Html msg)
    }


view : Config msg -> Html msg
view { header, body, footer } =
    div [ class "card bg-primary shadow-sm" ]
        [ header
            |> div [ class "card-header text-white d-flex justify-content-between gap-1" ]
            |> viewUnless (List.isEmpty header)
        , body
            |> div [ class "card-body px-1 py-2 py-sm-3 d-grid gap-2 gap-sm-3 text-white" ]
            |> viewUnless (List.isEmpty body)
        , footer
            |> div [ class "card-footer text-white d-flex justify-content-between gap-1" ]
            |> viewUnless (List.isEmpty footer)
        ]


viewIf : Bool -> Html msg -> Html msg
viewIf condition html =
    if condition then
        html

    else
        text ""


viewUnless : Bool -> Html msg -> Html msg
viewUnless condition =
    viewIf (not condition)
