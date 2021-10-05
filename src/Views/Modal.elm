module Views.Modal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { size : Size
    , close : msg
    , title : String
    , content : List (Html msg)
    , footer : List (Html msg)
    }


type Size
    = ExtraLarge
    | Large
    | Small
    | Standard


view : Config msg -> Html msg
view config =
    div [ class "Modal" ]
        [ div
            [ class "modal d-block fade show"
            , attribute "tabindex" "-1"
            , attribute "aria-modal" "true"
            , attribute "role" "dialog"
            ]
            [ div
                [ class "modal-dialog modal-dialog-centered modal-dialog-scrollable"
                , classList
                    [ ( "modal-xl", config.size == ExtraLarge )
                    , ( "modal-lg", config.size == Large )
                    , ( "modal-sm", config.size == Small )
                    ]
                ]
                [ div [ class "modal-content" ]
                    [ div [ class "modal-header bg-primary text-light" ]
                        [ h6 [ class "modal-title" ] [ text config.title ]
                        , button
                            [ type_ "button"
                            , class "btn-close invert"
                            , onClick config.close
                            , attribute "aria-label" "Close"
                            ]
                            []
                        ]
                    , div [ class "modal-body px-3 px-md-4 py-2 py-md-3" ]
                        config.content
                    , if config.footer /= [] then
                        div [ class "modal-footer bg-light" ] config.footer

                      else
                        text ""
                    ]
                ]
            ]
        , div [ class "modal-backdrop fade show" ] []
        ]
