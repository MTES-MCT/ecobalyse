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


type
    ContentType
    -- FIXME: remove the Gitbook type as this is not used anymore
    = Gitbook Gitbook.Page
    | Simple String


siteUrl : String
siteUrl =
    "https://ecobalyse.beta.gouv.fr"


clean : String -> String
clean =
    String.split "\n\n" >> List.map String.trim >> String.join "\n\n"


renderer : Maybe Gitbook.Path -> Renderer (Html msg)
renderer maybePath =
    { defaultHtmlRenderer
        | html =
            MdHtml.oneOf
                [ MdHtml.tag "hint" renderHint
                    |> MdHtml.withAttribute "level"
                , MdHtml.tag "mark" renderMark
                    |> MdHtml.withAttribute "style"

                -- NOTE: sometimes gitbook exposes raw HTML in markdown
                , MdHtml.tag "a"
                    (\href title -> renderLink maybePath { destination = href, title = title })
                    |> MdHtml.withAttribute "href"
                    |> MdHtml.withOptionalAttribute "title"
                , MdHtml.tag "code" (code [])
                , MdHtml.tag "em" (em [])
                , MdHtml.tag "p" (p [ class "mb-1" ])
                ]
        , image = renderImage
        , link = renderLink maybePath
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


renderLink : Maybe Gitbook.Path -> { destination : String, title : Maybe String } -> List (Html msg) -> Html msg
renderLink maybePath { destination, title } =
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


renderImage : { alt : String, src : String, title : Maybe String } -> Html msg
renderImage { alt, src, title } =
    Html.img
        (List.filterMap identity
            [ Maybe.map Attr.title title
            , src
                |> String.replace "../.gitbook/assets/"
                    "https://raw.githubusercontent.com/MTES-MCT/ecobalyse/docs/.gitbook/assets/"
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
        Err errors ->
            Alert.preformatted
                { close = Nothing
                , content = [ text errors ]
                , level = Alert.Danger
                , title = Just "Des erreurs ont été rencontrées"
                }

        Ok rendered ->
            div (class "Markdown bottomed-paragraphs" :: attrs) rendered


parse : ContentType -> Result String (List (Html msg))
parse content =
    let
        ( markdown, path ) =
            case content of
                Gitbook page ->
                    ( page.markdown, Just page.path )

                Simple string ->
                    ( string, Nothing )
    in
    clean markdown
        |> Parser.parse
        |> Result.mapError (List.map Parser.deadEndToString >> String.join "\n")
        |> Result.andThen (Markdown.Renderer.render (renderer path))
