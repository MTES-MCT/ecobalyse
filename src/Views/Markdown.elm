module Views.Markdown exposing (..)

import Data.Gitbook as Gitbook
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Markdown.Html as MdHtml
import Markdown.Parser as Parser
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Views.Icon as Icon
import Views.Link as Link


clean : String -> String
clean =
    String.split "\n\n" >> List.map String.trim >> String.join "\n\n"


renderer : Renderer (Html msg)
renderer =
    { defaultHtmlRenderer
        | link = renderLink
        , image = renderImage
        , html =
            MdHtml.oneOf
                [ MdHtml.tag "hint" renderHint
                    |> MdHtml.withAttribute "level"
                , MdHtml.tag "p" (p [ class "mb-1" ]) -- NOTE: sometimes gitbook exposes raw HTML in markdown
                , MdHtml.tag "em" (em []) -- NOTE: sometimes gitbook exposes raw HTML in markdown
                ]
    }


renderHint level content =
    let
        makeIcon icon =
            span [ class "fs-4", style "opacity" ".8", style "line-height" "0" ] [ icon ]
    in
    div
        [ class <| "d-flex justify-content-between align-items-start gap-2 alert alert-" ++ level
        ]
        [ case level of
            "danger" ->
                makeIcon Icon.exclamation

            "info" ->
                makeIcon Icon.info

            "warning" ->
                makeIcon Icon.warning

            _ ->
                text ""
        , div [ class "flex-fill" ] content
        ]


renderLink : { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
renderLink { title, destination } =
    let
        destination_ =
            Gitbook.handleMarkdownGitbookLink destination

        attrs =
            List.filterMap identity
                [ Just (Attr.href destination_)
                , Maybe.map Attr.title title
                ]
    in
    if String.startsWith "http" destination_ then
        Link.external attrs

    else
        Link.internal attrs


renderImage : { title : Maybe String, alt : String, src : String } -> Html msg
renderImage { title, src, alt } =
    Html.img
        (List.filterMap identity
            [ Maybe.map Attr.title title
            , src
                |> String.replace "../.gitbook/assets/" "https://raw.githubusercontent.com/MTES-MCT/wikicarbone/docs/.gitbook/assets/"
                |> Attr.src
                |> Just
            , Just <| Attr.alt alt
            , Just <| attribute "crossorigin" "anonymous"
            ]
        )
        []


view : List (Attribute msg) -> String -> Html msg
view attrs markdown =
    case
        clean markdown
            |> Parser.parse
            |> Result.mapError (List.map Parser.deadEndToString >> String.join "\n")
            |> Result.andThen (Markdown.Renderer.render renderer)
    of
        Ok rendered ->
            div ([ class "Markdown bottomed-paragraphs" ] ++ attrs) rendered

        Err errors ->
            div [ class "alert alert-danger" ]
                [ p [] [ text "Des erreurs ont été rencontrées\u{00A0}:" ]
                , pre [] [ text errors ]
                ]
