module Views.Markdown exposing
    ( ContentType(..)
    , parse
    , simple
    )

import Data.Gitbook as Gitbook
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Markdown.Html as MdHtml
import Markdown.Parser as Parser
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Views.Alert as Alert
import Views.Icon as Icon
import Views.Link as Link


type ContentType
    = Simple String
    | Gitbook Gitbook.Page


siteUrl : String
siteUrl =
    "https://wikicarbone.beta.gouv.fr"


clean : String -> String
clean =
    String.split "\n\n" >> List.map String.trim >> String.join "\n\n"


renderer : Maybe Gitbook.Path -> Renderer (Html msg)
renderer maybePath =
    { defaultHtmlRenderer
        | link = renderLink maybePath
        , image = renderImage
        , html =
            MdHtml.oneOf
                [ MdHtml.tag "hint" renderHint
                    |> MdHtml.withAttribute "level"
                , MdHtml.tag "mark" renderMark
                    |> MdHtml.withAttribute "style"

                -- NOTE: sometimes gitbook exposes raw HTML in markdown
                , MdHtml.tag "a"
                    (\href title -> renderLink maybePath { title = title, destination = href })
                    |> MdHtml.withAttribute "href"
                    |> MdHtml.withOptionalAttribute "title"
                , MdHtml.tag "code" (code [])
                , MdHtml.tag "em" (em [])
                , MdHtml.tag "p" (p [ class "mb-1" ])
                ]
    }


renderHint : String -> List (Html msg) -> Html msg
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


renderMark : String -> List (Html msg) -> Html msg
renderMark style_ =
    span
        [ class "mark"
        , attribute "style" style_
        , style "background-color" "transparent"
        ]


renderLink : Maybe Gitbook.Path -> { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
renderLink maybePath { title, destination } =
    let
        destination_ =
            Gitbook.handleMarkdownGitbookLink maybePath destination

        baseAttrs =
            List.filterMap identity
                [ Maybe.map Attr.title title
                ]
    in
    if String.startsWith siteUrl destination_ then
        Link.internal (Attr.href (String.replace siteUrl "" destination_) :: baseAttrs)

    else if String.startsWith "http" destination_ then
        Link.external (Attr.href destination_ :: baseAttrs)

    else
        Link.internal (Attr.href destination_ :: baseAttrs)


renderImage : { title : Maybe String, alt : String, src : String } -> Html msg
renderImage { title, src, alt } =
    Html.img
        (List.filterMap identity
            [ Maybe.map Attr.title title
            , src
                |> String.replace "../.gitbook/assets/"
                    "https://raw.githubusercontent.com/MTES-MCT/wikicarbone/docs/.gitbook/assets/"
                |> Attr.src
                |> Just
            , Just <| Attr.alt alt
            , Just <| attribute "crossorigin" "anonymous"
            ]
        )
        []


simple : List (Attribute msg) -> String -> Html msg
simple attrs markdown =
    view attrs (Simple markdown)


view : List (Attribute msg) -> ContentType -> Html msg
view attrs content =
    case parse content of
        Ok rendered ->
            div (class "Markdown bottomed-paragraphs" :: attrs) rendered

        Err errors ->
            Alert.preformatted
                { title = Just "Des erreurs ont été rencontrées"
                , close = Nothing
                , level = Alert.Danger
                , content = [ text errors ]
                }


parse : ContentType -> Result String (List (Html msg))
parse content =
    let
        ( markdown, path ) =
            case content of
                Simple string ->
                    ( string, Nothing )

                Gitbook page ->
                    ( page.markdown, Just page.path )
    in
    clean markdown
        |> Parser.parse
        |> Result.mapError (List.map Parser.deadEndToString >> String.join "\n")
        |> Result.andThen (Markdown.Renderer.render (renderer path))
