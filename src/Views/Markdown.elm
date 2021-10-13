module Views.Markdown exposing (..)

import Data.Gitbook as Gitbook
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Markdown.Html as MdHtml
import Markdown.Parser as Parser
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Views.Link as Link


gitbookUrlPathPrefixes : List String
gitbookUrlPathPrefixes =
    [ "faq", "glossaire", "methodologie" ]


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
                [ MdHtml.tag "hint" (\level -> div [ class <| "alert alert-" ++ level ])
                    |> MdHtml.withAttribute "level"
                , MdHtml.tag "p" (p [ class "mb-1" ]) -- NOTE: sometimes gitbook exposes raw HTML in markdown
                , MdHtml.tag "em" (em []) -- NOTE: sometimes gitbook exposes raw HTML in markdown
                ]
    }


renderLink : { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
renderLink { title, destination } =
    let
        destination_ =
            if gitbookUrlPathPrefixes |> List.any (\x -> String.startsWith x destination) then
                Gitbook.publicUrl destination

            else
                destination

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
