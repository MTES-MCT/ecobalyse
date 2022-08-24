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
        [ if List.isEmpty header then
            text ""

          else
            div [ class "card-header text-white d-flex justify-content-between gap-1" ]
                header
        , div [ class "card-body px-1 py-2 py-sm-3 d-grid gap-2 gap-sm-3 text-white" ] body
        , if List.isEmpty footer then
            text ""

          else
            div [ class "card-footer text-white d-flex justify-content-between gap-1" ]
                footer
        ]
