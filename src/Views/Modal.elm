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
    = CustomPercentWidth Int
    | ExtraLarge
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
            , attribute "data-dismiss" "modal"
            , on "click"
                (Json.Decode.at [ "target", "dataset", "dismiss" ] Json.Decode.string
                    |> Json.Decode.map (always config.close)
                )
            ]
            [ div
                ([ class "modal-dialog modal-dialog-centered modal-dialog-scrollable"
                 , attribute "aria-modal" "true"
                 ]
                    ++ (case config.size of
                            CustomPercentWidth width ->
                                [ class "modal-xl", style "width" (String.fromInt width ++ "%") ]

                            ExtraLarge ->
                                [ class "modal-xl" ]

                            Large ->
                                [ class "modal-lg" ]

                            Small ->
                                [ class "modal-sm" ]

                            Standard ->
                                []
                       )
                )
                [ modalContentTag
                    [ div [ class "modal-header d-flex justify-content-between align-items-center gap-2" ]
                        [ span [ class "h5 mb-0", attribute "aria-hidden" "true" ] [ text "→" ]
                        , div [ class "d-flex flex-column gap-1" ]
                            [ h5 [ class "modal-title lh-sm" ] [ text config.title ]
                            , case config.subTitle of
                                Just subTitle ->
                                    div [ class "text-muted fs-7 fw-normal" ] [ text subTitle ]

                                Nothing ->
                                    text ""
                            ]
                        , button
                            [ type_ "button"
                            , class "btn-close"
                            , attribute "aria-label" "Fermer"
                            , onClick config.close
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
