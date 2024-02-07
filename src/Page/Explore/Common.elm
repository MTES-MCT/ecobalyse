module Page.Explore.Common exposing
    ( boolText
    , scopesView
    )

import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)


boolText : Bool -> String
boolText bool =
    if bool then
        "oui"

    else
        "non"


scopesView : { a | scopes : List Scope } -> Html msg
scopesView =
    .scopes
        >> List.map
            (\scope ->
                span [ class "badge badge-success" ]
                    [ text <| Scope.toLabel scope ]
            )
        >> div [ class "d-flex gap-1" ]
