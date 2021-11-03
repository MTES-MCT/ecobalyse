module Views.Modal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode


type alias Config msg =
    { size : Size
    , close : msg
    , noOp : msg
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
            , custom "mouseup"
                (Decode.succeed
                    { message = config.close
                    , stopPropagation = True
                    , preventDefault = True
                    }
                )
            ]
            [ div
                [ class "modal-dialog modal-dialog-centered modal-dialog-scrollable"
                , classList
                    [ ( "modal-xl", config.size == ExtraLarge )
                    , ( "modal-lg", config.size == Large )
                    , ( "modal-sm", config.size == Small )
                    ]
                , attribute "aria-modal" "true"
                ]
                [ div
                    [ class "modal-content"
                    , custom "mouseup"
                        (Decode.succeed
                            { message = config.noOp
                            , stopPropagation = True
                            , preventDefault = True
                            }
                        )
                    ]
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
                    , div [ class "modal-body" ]
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
