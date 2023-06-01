module Views.CardTabs exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { tabs : List { label : String, event : msg, active : Bool }
    , content : List (Html msg)
    }


view : Config msg -> Html msg
view { tabs, content } =
    div [ class "card shadow-sm" ]
        (div [ class "card-header px-0 pb-0 border-bottom-0" ]
            [ tabs
                |> List.map
                    (\{ label, event, active } ->
                        li [ class "TabsTab nav-item", classList [ ( "active", active ) ] ]
                            [ button
                                [ class "nav-link no-outline border-top-0"
                                , classList [ ( "active", active ) ]
                                , onClick event
                                ]
                                [ text label ]
                            ]
                    )
                |> ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-2 px-2" ]
            ]
            :: content
        )
