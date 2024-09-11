module Views.CardTabs exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Tab msg =
    { active : Bool
    , label : Html msg
    , onTabClick : msg
    }


type alias Config msg =
    { attrs : List (Attribute msg)
    , content : List (Html msg)
    , tabs : List (Tab msg)
    }


view : Config msg -> Html msg
view { attrs, content, tabs } =
    div [ class "CardTabs card shadow-sm" ]
        (div (class "card-header px-0 pb-0 border-bottom-0 bg-white" :: attrs)
            [ tabs
                |> List.map
                    (\{ active, label, onTabClick } ->
                        li [ class "TabsTab nav-item", classList [ ( "active", active ) ] ]
                            [ button
                                [ class "nav-link no-outline border-top-0"
                                , classList [ ( "active", active ) ]
                                , onClick onTabClick
                                ]
                                [ label ]
                            ]
                    )
                |> ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-2 px-2" ]
            ]
            :: content
        )
