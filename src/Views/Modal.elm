module Views.Modal exposing (Size(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode


type alias Config msg =
    { close : msg
    , content : List (Html msg)
    , footer : List (Html msg)
    , formAction : Maybe msg
    , noOp : msg
    , size : Size
    , subTitle : Maybe String
    , title : String
    }


type Size
    = ExtraLarge
    | Large
    | Small
    | Standard


view : Config msg -> Html msg
view config =
    let
        modalContentAttrs =
            [ class "modal-content" ]

        modalContentTag =
            case config.formAction of
                Just msg ->
                    Html.form (modalContentAttrs ++ [ onSubmit msg ])

                Nothing ->
                    div modalContentAttrs
    in
    div [ class "Modal" ]
        [ div
            [ class "modal d-block fade show"
            , attribute "tabindex" "-1"
            , attribute "aria-modal" "true"
            , attribute "role" "dialog"
            , onClick config.close
            ]
            [ div
                [ class "modal-dialog modal-dialog-centered modal-dialog-scrollable"
                , classList
                    [ ( "modal-xl", config.size == ExtraLarge )
                    , ( "modal-lg", config.size == Large )
                    , ( "modal-sm", config.size == Small )
                    ]
                , attribute "aria-modal" "true"
                , stopPropagationOn "click" (Json.Decode.succeed ( config.noOp, True ))
                ]
                [ modalContentTag
                    [ div [ class "modal-header" ]
                        [ h5 [ class "modal-title lh-sm" ]
                            [ span [ class "me-2", attribute "aria-hidden" "true" ] [ text "→" ]
                            , text config.title
                            , case config.subTitle of
                                Just subTitle ->
                                    small [ class "text-muted fs-7 fw-normal ps-2" ] [ text subTitle ]

                                Nothing ->
                                    text ""
                            ]
                        , button
                            [ type_ "button"
                            , class "btn-close"
                            , onClick config.close
                            , attribute "aria-label" "Fermer"
                            ]
                            []
                        ]
                    , config.content
                        |> div [ class "modal-body no-scroll-chaining p-0" ]
                    , if not (List.isEmpty config.footer) then
                        div [ class "modal-footer bg-light" ] config.footer

                      else
                        text ""
                    ]
                ]
            ]
        , div [ class "modal-backdrop fade show" ] []
        ]
